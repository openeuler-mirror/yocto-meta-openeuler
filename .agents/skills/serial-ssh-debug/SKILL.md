---
name: serial-ssh-debug
description: 'openEuler Embedded 真机板卡的串口登录调试与 SSH 登录调试。串口是托底通道：通过串口查看 TF-A/BL2、U-Boot、内核启动日志，判断系统启动是否正常、网络是否就绪；网络可用时切换 SSH 进行进一步测试验证。覆盖：串口设备发现与权限、串口会话脚本、启动链日志抓取、网络就绪判定决策树、sshd keyboard-interactive 登录、VMware USB 透传与防火墙问题、U-Boot extlinux 启动排查。触发关键词：串口调试、串口登录、serial console、ttyUSB、板子连不上、SSH 登录、启动日志、TF-A、U-Boot、bootloader、板上验证、开机验证、板卡调试。'
argument-hint: "描述调试任务，例如 '板子起不来，看串口日志' 或 '验证板上网络并跑 SSH 测试'"
---

# Skill: serial-ssh-debug — 真机串口/SSH 登录调试

## 分层策略（核心思想）

openEuler Embedded 真机上网络**未必 ready**（无 DHCP、驱动未加载、IP 未配、
防火墙拦截），但**串口永远可用**。按以下顺序推进，逐层升级：

```
串口（托底）─── 启动链是否正常？──否──> 分析 TF-A/U-Boot/内核日志定位
     │
     是：shell 可登录，ip addr 看网络
     │
网络就绪？──否──> 串口内修复网络（配 IP / 查驱动 / 查 networkd）
     │
     是：切换 SSH（批量命令、scp 传文件、脚本化测试）
```

串口与 SSH 可**并行使用**：SSH 跑长命令时用串口看实时反应；SSH 失败时串口
永远是退路。

## 第一步：串口会话

### 设备与权限

```bash
ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null   # USB 转串口通常是 ttyUSB0（115200 8N1）
```

权限不足（`root:dialout` 660）时：

```bash
sudo usermod -aG dialout $USER   # 持久（重登录后生效）
sudo chmod a+rw /dev/ttyUSB0     # 立即生效（设备重插后需重做）
```

脚本依赖 pyserial：`pip3 install --user --break-system-packages pyserial`

### 会话脚本 scripts/serial_console.py

三种模式（脚本路径以技能目录为准）：

```bash
# 1. peek：被动监听 N 秒（不干预板子；抓启动日志的默认方式）
python3 scripts/serial_console.py peek 6

# 2. exec：自动登录并执行命令（每条命令输出以 ===BEGIN/===END 包裹）
python3 scripts/serial_console.py exec "uname -a" "ip -br addr" "uptime"

# 3. send：原始发送一行（手工交互，例如在 U-Boot 下敲命令）
python3 scripts/serial_console.py send "printenv bootcmd"
```

- 不同板卡用 `SERIAL_PORT=/dev/ttyACM0 SERIAL_BAUD=115200` 覆盖
- 默认登录 `root`，密码默认 `openEuler@2021`（按实际板卡调整脚本 `login()`）
- 提示符匹配陷阱：openEuler 默认 root 提示符是 `hostname ~ #`（`~` 与 `#`
  之间有空格），匹配模式必须包含 `"~ #"`，只匹配 `"~#"` 会导致已登录仍判为失败

### 抓完整启动日志（TF-A → U-Boot → 内核）

重启板子并后台全量记录（grep 会丢上下文，先落盘再分析）：

```bash
# 后台开始串口记录
python3 scripts/serial_console.py peek 100 > /tmp/boot.log 2>&1 &
sleep 3
# 让板子重启（串口 exec 或 SSH 均可）
python3 scripts/serial_console.py exec "reboot"
sleep 85
grep -aE "Found|Retrieving|append:|Command line|Starting kernel" /tmp/boot.log
```

启动链各阶段判读：

| 阶段 | 日志特征 | 说明 |
|---|---|---|
| TF-A (BL2/BL31) | `INFO: BL2: Loading image id ...` | 到此说明 SoC 上电与启动介质正常 |
| U-Boot | `U-Boot 2023.10-...`、`Loading Environment from MMC... OK` | 环境读取失败常见于首次烧录 |
| extlinux 加载 | `Found /mmc1_extlinux/xxx_extlinux.conf` + `append: <cmdline>` | **看真实加载的文件和 cmdline**（见 reference.md 陷阱 5） |
| 内核 | `Starting kernel ...` 后 Linux banner | 无输出=内核/DTB 问题 |
| 用户态 | systemd 启动、最终 `login:` 提示符 | openEuler logo + `ip: x.x.x.x` motd 行 |

## 第二步：网络就绪判定（串口内完成）

在串口 exec 中按决策树快速判定（每层都能定位一种根因）：

```bash
ip -br link          # 1. LOWER_UP?  无 = 网线/PHY 问题
ip -br addr          # 2. 有地址?  169.254.x.x = 无 DHCP（IPv4LL 兜底）
ip route show        # 3. 目标网段路由存在?
ip neigh show        # 4. 对端 REACHABLE = 二层通（ARP 有应答）
ping -c 2 <peer>     # 5. 不通但 ARP 通 = ICMP 被防火墙拦（不算网络故障）
```

**关键判据**：ARP REACHABLE + ping 不通 ≠ 网络故障，通常是防火墙拦 ICMP；
用 TCP/SSH 验证代替 ping。

IPv4LL（169.254.x.x）出现说明 DHCP 拿不到：对点连接笔记本无 DHCP 服务器属
正常，配置静态 IP 即可。openEuler 默认静态配置在
`/etc/systemd/network/10-eth-static.network`（`Name=eth*`，192.168.7.2/24）。
排查 networkd 三板斧：

```bash
journalctl -u systemd-networkd -b | grep "Configuring with"   # 实际选中哪个配置
cat /proc/cmdline                                             # 命名策略相关参数
udevadm info /sys/class/net/<iface> | grep ID_NET_NAME        # 接口名来源
```

若接口名是 `endX`/`enpX` 而非 `ethX`，默认配置不生效——ST MP2 系被 udev
DT-alias 策略改名（`ID_NET_NAME_ONBOARD=end1`），解法是内核 cmdline 加
`net.ifnames=0`（详见 reference.md 陷阱 6）。

## 第三步：SSH 通道（网络就绪后）

### 登录命令模板

openEuler Embedded 的 sshd 通常**只开 keyboard-interactive**（不开 password
认证），直接 `sshpass ssh` 会报 `Too many authentication failures`：

```bash
sshpass -p 'openEuler@2021' ssh \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o PubkeyAuthentication=no -o PreferredAuthentications=keyboard-interactive \
  root@<板IP> "hostname; uptime"
```

认证失败时用 `ssh -v` 看 `Authentications that can continue:` 行确认服务端
实际开放的认证方式。

### SSH 与串口的配合

- 长时间命令（灌盘、压测）走 SSH，串口 peek 盯日志
- 板卡重启实验：SSH 发 reboot（断连正常），串口看启动，重启后 IP 可能变化
  （DHCP → 静态配置变更时注意换地址重连）
- 传文件用 `scp`（同样带 `-o` 认证参数）

## 常见故障速查

| 症状 | 根因 | 处理 |
|---|---|---|
| `/dev/ttyUSB0: Permission denied` | 不在 dialout 组 | chmod a+rw（即时）+ usermod -aG dialout（持久） |
| 串口执行 exec 报 login failed 但板子在 shell | 提示符匹配模式不含 `"~ #"` | 修正 PROMPT_PATS |
| 设备重插后突然 Permission denied | chmod 是易失的，udev 重建设备 | 重跑 chmod；dialout 组生效后免维护 |
| SSH: `Too many authentication failures` | sshd 只开 keyboard-interactive | 加 `-o PreferredAuthentications=keyboard-interactive -o PubkeyAuthentication=no` |
| ping 不通但 SSH/TCP 正常 | 防火墙拦 ICMP（Windows 常见） | 不用 ping 做连通判据；或防火墙放行 ICMPv4 Echo |
| VM 内 USB 设备号漂移/烧录断连 | VMware USB 透传 + USB autosuspend | udev 禁 autosuspend + Windows 关选择性挂起（详见 reference.md） |
| 静态 IP 不生效、只有 169.254 | networkd 选中了别的配置 / 接口名不匹配 `Name=eth*` | journalctl 看 `Configuring with`；接口改名问题加 net.ifnames=0 |
| 改 extlinux.conf 不生效 | U-Boot 实际加载 per-board 配置（`{board}_extlinux.conf`） | 串口日志看 `Found ...` 确认真实文件 |
| 板端 networkd 报 `Failed to open ... Permission denied` | 配置文件权限 600，networkd 非 root 运行 | `chmod 644 /etc/systemd/network/*.network` |

## 详细参考

更多环境细节（VMware 透传加固、STM32MP2 命名与启动配置陷阱、烧录后首次
上电检查单）见 [reference.md](reference.md)。
