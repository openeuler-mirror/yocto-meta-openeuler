# yocto k3s

这个目录提供了在 openEuler Embedded 上构建和运行 [k3s](https://k3s.io/) 所需的 BitBake 配方、补丁和运行时脚本。k3s 是基于 Apache License 2.0 的精简版 Kubernetes，非常适合边缘和资源受限设备。

我们重写了meta-virtualization的k3s配方，方便在 openEuler Yocto 构建体系里直接使用。

---

## 这套配方能够做什么

- **一次构建输出 server 或 agent**：`k3s` 多路复用二进制会同时提供 `kubectl`、`crictl` 和 `ctr`（在使用外部 containerd 时自动跳过 `ctr`）。
- **按需切换容器运行时**：可以设定 isulad、外部 containerd  作为 k3s external endpoint，或者默认使用 k3s 自带的 bundle containerd。
- **可控的依赖获取方式**：考虑不同的网络情况，支持在 `do_fetch` 阶段完成 go module 下载，也支持在 `do_compile` 阶段联网下载依赖。

---

## 快速开始

1. 在 oebuild generate 中添加 k3s feature, 默认启用 k3s-agent
2. 可以在 `local.conf` 中将 DISTRO_FEATURES:append = "k3s-agent" 改为 "k3s-server", 来构建 完整的k3s server二进制，默认静态链接分发
3. 运行：
   ```bash
   bitbake k3s
   ```
  默认会构建带 bundle containerd 的版本（当前为 v1.27.15-rc2+k3s1）, isulad作为外部endpoint时k3s的版本为v1.22.6

---

## 如何定制构建

### 选择容器运行时

用 `K3S_EXTERNAL_ENDPOINT` 指定运行时：

```conf
# conf/local.conf
K3S_EXTERNAL_ENDPOINT ?= "containerd"  # "containerd", "isulad" or "bundle-containerd"(默认)
```

- 设为 `isulad` 或 `containerd`：选择对应版本并生成带 `--container-runtime-endpoint` 的 systemd 配置。
- 留空：使用 k3s 自带的 bundle containerd。
- 设置其他值：自动回退为 containerd 并打印警告。

### 控制依赖下载方式

构建时默认允许 `do_compile` 访问网络。如果需要在 `do_fetch` 阶段一次性拉全依赖，可提前运行：

```bash
python3 oe-go-mod-autogen.py --repo https://github.com/k3s-io/k3s.git --rev <k3s-tag>
```

把生成的 `src_uri-*.inc` 和 `relocation-*.inc` 放到当前目录，BitBake 就会从镜像源而不是网络获取依赖。

### 其他常用选项

| 变量 | 作用 | 示例 |
| --- | --- | --- |
| `K3S_PREBUILD_BINARY` | 为 `1` 时跳过源码编译，改为下载官方预编译二进制 | `K3S_PREBUILD_BINARY = "1"` |
| `K3S_AGENT_BUILD_TAGS` | 追加自定义 Go build tag | `K3S_AGENT_BUILD_TAGS += "selinux"` |
| `IMAGE_INSTALL` | 往镜像里一次性加入 server/agent | `IMAGE_INSTALL:append = " k3s k3s-agent"` |

---

## `k3s_%.bbappend` 做了哪些事情

1. **版本与依赖选择**：根据 `K3S_EXTERNAL_ENDPOINT` 设定不同分支、Go 依赖和 reloc 文件，保证 isulad/containerd/bundle-containerd 三套代码路径正确。
2. **构建参数管理**：统一配置 Go 环境、编译标志、是否使用预编译二进制等选项。
3. **安装多路复用二进制**：生成 `k3s` 主程序，并按需创建 `kubectl`、`crictl`、`ctr` 等符号链接。
4. **systemd 集成**：安装 `k3s.service`、`k3s-agent.service`，复制一份 `.ori` 供调试，自动注入容器运行时依赖和 `--container-runtime-endpoint`。
5. **运行时脚本**：把 `k3s-install-agent`、`k3s-killall.sh`、`k3s-clean` 等脚本装进镜像，方便初始化和清理节点。

---

## 运行时会安装哪些文件

- **k3s-killall.sh**：停止所有 k3s 相关进程、卸载挂载点、清理网络与 iptables，通常由 `k3s.service` 在停止时调用。
- **k3s-kill-agent**：只针对 agent 节点的清理脚本。
- **k3s-install-agent**：功能更完整的安装脚本，负责生成 agent 的 systemd drop-in、配置 isulad/containerd、导入离线镜像等。
- **k3s-agent.sh**：较轻量的脚本，仅负责写入 token/server 参数并重启 agent。
- **k3s.service / k3s-agent.service**：server 与 agent 的 systemd 单元，内置无限制重启策略并根据运行时自动附加 `Requires` / `After`。

---

## 配置并启动 k3s agent

### 推荐：使用 `k3s-agent` 脚本

```bash
k3s-install-agent -t <token> -s https://<server>:6443
```

常用参数：

- `-t/--token`：server 上的 `/var/lib/rancher/k3s/server/node-token`
- `-s/--server`：server API 地址
- `-e/--endpoint`：覆盖容器运行时（默认为构建时写入的值）
- `--airgap <tar>`：导入离线镜像。使用外部 containerd 时会调用 `containerd-ctr -n k8s.io images import <tar>`，使用 isulad 时会调用 `isula load -i <tar>`
- `--skip-airgap`：跳过离线镜像导入
- `--isula-setup`：只做 isulad 调整后退出

脚本执行流程概览：

1. 写入 `/etc/systemd/system/k3s-agent.service.d/10-env.conf`
2. 视运行时决定是否修改 `/etc/isulad/daemon.json` 或导入 containerd 镜像
3. 清理旧的 `/var/lib/rancher/k3s/agent`
4. `systemctl daemon-reload && systemctl restart --now k3s-agent`

### 轻量方案：`k3s-agent.sh`

若只想传 token 与 server，可执行：

```bash
k3s-agent.sh -t <token> -s https://<server>:6443
```

> 提示：在同一台机器上同时跑 server + agent 做测试时，请直接执行 `k3s agent ...`，不要运行安装脚本，以免它清理掉 Flannel 网络。

---

## 资源与调试建议

- **内存**：QEMU 默认 256 MB 内存不足以跑 k3s，建议至少 2 GB。示例：`runqemu ... qemuparams="-m 2048"`。
- **磁盘**：core-image* 组合需要额外空间，常见做法是在镜像配方或 `local.conf` 增加  
  `IMAGE_ROOTFS_EXTRA_SPACE = "2097152"`（增加约 2 GB）。
- **查看日志**：`journalctl -xeu k3s`。
- **常用引导命令**：
  ```bash
  runqemu qemu-aarch64 nographic kvm slirp qemuparams="-m 2048"
  ```

---

## 关于依赖与 airgap 构建

如果需要完全离线的构建或部署：

1. 使用 `oe-go-mod-autogen.py` 生成指定版本的 go module 镜像清单。
2. 将生成的 `src_uri-*.inc` 与 `relocation-*.inc` 文件加入配方目录。
3. 在目标设备上使用 `k3s-install-agent --airgap /path/to/k3s-airgap-images-<arch>.tar.gz` 导入镜像。脚本会根据运行时自动选择 `isula load` 或 `containerd-ctr images import`。

---

## 更多

- k3s 官方文档：<https://rancher.com/docs/k3s/latest/en/>
- 网络选项（CNI、Flannel 后端等）：<https://rancher.com/docs/k3s/latest/en/installation/network-options/>

欢迎在本目录基础上继续扩展，例如增加新的运行时、引入更多 Go build tags，或编写自定义镜像配方。只需扩展对应的 `.inc` 文件和 `bbappend` 即可。
