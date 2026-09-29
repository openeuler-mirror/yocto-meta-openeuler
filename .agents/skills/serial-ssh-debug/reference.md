# serial-ssh-debug 参考细节

本文件补充 SKILL.md 的环境级细节，按需阅读。

## 陷阱 1：VMware USB 透传（Windows 宿主 → Linux VM）

症状：USB 设备号漂移（`lsusb` 中 Device 号变化）、长时间 USB 传输中断连、
STM32CubeProgrammer DFU 烧录中途挂死。

三层加固：

1. **VM 内（Linux）**：对 ST DFU 设备禁 USB autosuspend
   `/etc/udev/rules.d/90-stm32-dfu-nosuspend.rules`：
   ```
   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
   ```
   然后 `sudo udevadm control --reload && sudo udevadm trigger`。
2. **Windows 宿主**：设备管理器逐个 USB Root Hub 取消"允许计算机关闭此设备
   以节约电源"；电源选项禁用"USB 选择性挂起"。
3. **VMware**：VM 设置 USB 控制器兼容性设 USB 3.1；烧录/长传输期间不挂起 VM。

串口透传（COM→ttyUSB0）是短时低速通信，一般不受此影响；但设备重插后 VM 内
会重新枚举，`chmod` 的权限会丢失。

## 陷阱 2：STM32MP2 以太网接口命名 endX → ethX

ST MP2 的 U-Boot/内核 DT 里 ethernet alias 使 systemd-udev（253+）把接口从
内核名 `ethX` 改名为 `endX`（`en`=ethernet + `d`=devicetree + alias 序号），
导致 openEuler 默认 `/etc/systemd/network/10-eth-static.network`（`Name=eth*`）
匹配不上，networkd 落到 `80-wired.network`（DHCP=yes），无 DHCP 时只剩
IPv4LL 169.254.x.x。

判定：

```bash
udevadm info /sys/class/net/end1 | grep ID_NET_NAME   # ID_NET_NAME_ONBOARD=end1
cat /proc/cmdline                                     # 有无 net.ifnames=0
```

修复（构建期）：machine conf 追加（参照
`meta-openeuler/conf/machine/qemu-aarch64.conf` 的做法）：

```
UBOOT_EXTLINUX_KERNEL_ARGS:append = " net.ifnames=0"
```

经 `extlinuxconf-stm32mp.bbclass` 写入各 `{board}_extlinux.conf` 的 APPEND 行。
修复后接口名回 `eth0/eth1`，默认静态配置（192.168.7.2/24 + DHCP=ipv4）开箱即用。

## 陷阱 3：U-Boot extlinux 多份配置，改错文件白改

ST/MYiR BSP 的 bootfs boot 分区下通常并存多份启动配置：

```
/boot/mmc0_extlinux/extlinux.conf                     # 通用（SD 卡分支）
/boot/mmc0_extlinux/myb-stm32mp257x-2GB_extlinux.conf # per-DTB
/boot/mmc1_extlinux/extlinux.conf                     # 通用（eMMC 分支）
/boot/mmc1_extlinux/myb-stm32mp257x-2GB_extlinux.conf # per-DTB（实际通常用这份）
```

boot.scr 逻辑：优先 `extlinux/${board_name}_extlinux.conf`，fallback 到通用
`extlinux.conf`。**板上临时验证**改 per-DTB 那份（用串口日志确认）：
`grep -h APPEND` 各文件 + 串口重启日志的 `Found /Retrieving file: /append:`
三行，即可确定真实加载的文件与展开后的 cmdline。

注意 APPEND 行里的 `${loglevel}` `${console}` 等变量由 U-Boot 环境展开，
纯文本参数（如 `net.ifnames=0`）原样透传；改完 `sync` 后 reboot，用
`cat /proc/cmdline` 验证。

## 陷阱 4：烧录后首次上电检查单

1. boot 开关位置正确（eMMC 启动/DFU 模式），完全断电 5 秒再上电（不是复位）
2. 串口 115200：看到 `INFO: BL2` = TF-A 正常；`U-Boot ...` = FIP 正常
3. `Starting kernel` 后无输出 → 内核/DTB；有输出但卡在 systemd → 用户态
4. eMMC 分区布局（ST FlashLayout）：fsbla1/2 + metadata + fip 在 boot 分区，
   bootfs/vendorfs/rootfs/userfs 在 user 分区；`/boot` 挂载 bootfs
5. SSH 不通先回串口：`ip -br addr` 看地址，再按 SKILL.md 决策树排查

## 陷阱 5：networkd 配置文件权限与运行身份

systemd-networkd 以 `systemd-network` 用户运行（`DynamicUser=no`），
`/etc/systemd/network/*.network` 权限必须 **0644**。600 权限时日志静默报
`Failed to open configuration file ... Permission denied` 并跳过，接口落到
其它配置——是"配置明明写了却不生效"的高频根因。

## 陷阱 6：判网络连通的层次与 ICMP 假阴性

| 层次 | 命令 | 通过标准 | 失败含义 |
|---|---|---|---|
| 链路 | `ip -br link` | LOWER_UP | 网线/PHY/协商 |
| 地址 | `ip -br addr` | 同网段地址 | DHCP/静态配置问题 |
| 二层 | `ip neigh` | 对端 REACHABLE | 对端不存在/IP 未配 |
| 三层 | `ping` | 回包 | 若二层通则多为防火墙 |
| 四层 | `ssh`/`nc -z` | TCP 建连 | 服务未装/端口策略 |

Windows 笔记本默认在"公用网络"配置文件下拦 ICMPv4 Echo——**ping 不通但
ARP REACHABLE、SSH 能连是常见组合**，不要把 ping 失败当网络故障。

## 环境速记（本工作区/myd-ld25x-oee 实例）

- 串口 `/dev/ttyUSB0` 115200；SSH `root@192.168.7.2`（默认静态）密码
  `openEuler@2021`
- 板上 `/boot` = mmcblk1p6（bootfs），rootfs = mmcblk1p8
- 内核 cmdline 关键词：`root=PARTUUID=... rootwait rw earlyprintk earlycon
  loglevel=3 console=ttySTM0,115200 [net.ifnames=0]`
