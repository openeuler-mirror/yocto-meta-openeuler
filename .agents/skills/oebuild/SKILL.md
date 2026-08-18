---
name: oebuild
description: '使用 oebuild 构建、配置、更新或排查 openEuler Embedded 构建问题。覆盖 oebuild init/update/generate/bitbake/manifest/runqemu/menv/clear 命令、Docker 容器生命周期、compile.yaml、inotify 限制、构建目录配置、qemu-aarch64 及其他平台构建。触发关键词：oebuild、bitbake、compile.yaml、构建容器、openeuler-image、生成构建、更新层、runqemu、docker 容器、QEMU AArch64。'
argument-hint: "描述任务，例如 '构建 openeuler-image-tiny' 或 '生成 rpi64 构建配置'"
---

# Skill: oebuild — OpenEuler Embedded 构建元工具

oebuild 是一个基于 Python 的元工具，封装了 BitBake 并管理 OpenEuler Embedded
基于 Docker 的构建环境。实际构建**在容器内**进行；oebuild 负责启动、配置和
复用该容器。

源码位置：`<workspace-root>/src/oebuild/`

> `<workspace-root>` 表示 oebuild 工作区根目录，具体路径因开发者环境而异。

---

## 工作区布局

```
<workspace-root>/                       ← oebuild 工作区根目录
├── .venv/                              # 包含 oebuild 二进制的 Python venv
├── .oebuild/
│   └── config                          # 全局配置：docker 镜像地址、yocto-meta-openeuler 远端
├── src/
│   ├── oebuild/                        # oebuild 源码
│   ├── yocto-poky/                     # OE 核心（oe-init-build-env、bitbake/）
│   ├── yocto-meta-openembedded/        # 社区 meta 层
│   └── yocto-meta-openeuler/           # OpenEuler Embedded 发行版层
└── build/
    └── qemu_arm64/                     # QEMU AArch64 构建目录
        ├── compile.yaml                # 由 oebuild bitbake 解析的构建配置
        └── .env                        # 会话间持久化的容器 ID
```

**关键常量（来自 `oebuild/const.py`）：**

| 常量 | 值 |
|---|---|
| 默认容器镜像 | `swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest` |
| 容器源码挂载点 | `/usr1/openeuler/src` |
| 容器构建挂载点 | `/home/openeuler/build` |
| 容器用户 | `openeuler` |

---

## 前置条件

### 1. 激活 Python venv（每个 shell 会话一次）

```bash
source <workspace-root>/.venv/bin/activate
```

验证：

```bash
which oebuild   # → <workspace-root>/.venv/bin/oebuild
oebuild --version
```

> **不要**在每条命令前重复 source venv。一次激活对整个会话有效。

### 2. Docker

构建容器必须可用：

```bash
docker images | grep openeuler-container
# 如果缺失：
docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest
```

### 3. inotify 监视限制

BitBake 与 VS Code 同时运行时通常会超过内核默认值（`65536`）。构建前增大限制：

```bash
sudo sysctl -w fs.inotify.max_user_watches=524288
sudo sysctl -w fs.inotify.max_user_instances=512
```

超出限制时的报错：
```
pyinotify.WatchManagerError: add_watch: ... Errno=No space left on device (ENOSPC)
```

如需永久生效，在 `/etc/sysctl.conf` 中添加：
```
fs.inotify.max_user_watches=524288
fs.inotify.max_user_instances=512
```

---

## 完整工作流：从零到构建出镜像

```
oebuild init <dir>   →   oebuild update   →   oebuild generate   →   cd build/<target>   →   oebuild bitbake <image>
```

### 第 1 步 — `oebuild init`

初始化一个新的 oebuild 工作区目录：

```bash
oebuild init <directory> [-u yocto_remote_url] [-b branch]
```

| 参数 | 默认值 | 说明 |
|---|---|---|
| `directory` | 必填 | 要创建的目录名 |
| `-u` | `https://atomgit.com/openeuler/yocto-meta-openeuler.git` | yocto-meta-openeuler 远端 |
| `-b` | `master` | yocto-meta-openeuler 分支 |

创建内容：
```
<directory>/
├── .oebuild/config    ← 全局配置（docker 标签、yocto 远端）
└── src/               ← 执行 oebuild update 后存放源码仓库
```

> 本工作区已执行过 `init`。现有环境请使用 `oebuild update` 刷新。

### 第 2 步 — `oebuild update`

拉取 Docker 镜像、下载/更新源码与各层：

```bash
# 按顺序更新全部（yocto + docker + 层）
oebuild update

# 更新单个组件
oebuild update yocto          # 克隆/刷新 yocto-meta-openeuler
oebuild update docker [-tag X] # 拉取容器镜像（可指定标签）
oebuild update layer          # 依据 .oebuild/common.yaml 更新依赖 meta 层
```

`.oebuild/config` 配置文件控制使用的 Docker 标签和 yocto 远端/分支。

### 第 3 步 — `oebuild generate` / `oebuild new`

创建 `compile.yaml` 构建配置：

```bash
# 交互式菜单（不带参数）
oebuild generate

# 直接生成
oebuild generate -p qemu-aarch64 -f systemd -f openeuler-qt

# 新版等价命令
oebuild new -p qemu-aarch64
```

关键参数：

| 标志 | 全名 | 说明 |
|---|---|---|
| `-p` | `platform` | 目标板卡/machine（默认：`qemu-aarch64`） |
| `-f` | `feature` | 启用的特性，可重复 |
| `-t` | `toolchain_dir` | 外部 GCC 工具链路径 |
| `-n` | `nativesdk_dir` | 外部 nativesdk 路径 |
| `-s` | `sstate_cache` | 宿主机 sstate-mirrors 路径 |
| `-s_dir` | `sstate_dir` | sstate-cache 存放位置 |
| `-m` | `tmp_dir` | `tmp/` 构建输出位置 |
| `-tag` | `--docker_tag` | 覆盖 Docker 镜像标签 |
| `-d` | build directory | 构建目录名（默认 = 平台名） |
| `-l` | `--list` | 列出支持的平台和特性 |
| `-df` | `disable_fetch` | 禁用 `openeuler_fetch`（改用 yocto DL_DIR） |

输出：`build/<platform>/compile.yaml`

### 第 4 步 — `oebuild bitbake`

在 Docker 容器内构建。**必须在包含 `compile.yaml` 的构建目录中执行**：

```bash
cd <workspace-root>/build/qemu_arm64
oebuild bitbake <target>
```

#### 常用用法

```bash
# 构建完整镜像
oebuild bitbake openeuler-image-tiny

# 构建单个 recipe
oebuild bitbake libfoo

# 执行特定任务
oebuild bitbake -c compile libfoo
oebuild bitbake -c cleansstate libfoo

# 进入容器内的交互 shell（不带目标 = 进入 shell）
oebuild bitbake

# 查看变量
oebuild bitbake -e libfoo 2>/dev/null | grep -E "^(PV|SRC_URI|S)="

# 构建多个目标
oebuild bitbake libsepol libselinux

# 使用自定义容器镜像
oebuild bitbake openeuler-image-tiny --with-docker-image=my-image:tag
```

#### oebuild bitbake 的工作原理

1. 读取当前目录下的 `compile.yaml`
2. 使用配置的镜像和卷挂载启动（或复用）Docker 容器
3. 在容器内以完整配置的 OE 环境运行 `bitbake <target>`
4. 容器内无需手动执行 `oe-init-build-env` 或激活 venv

**容器卷挂载（来自 `compile.yaml`）：**

```
<workspace>/src/         → /usr1/openeuler/src
<workspace>/build/xxx/   → /home/openeuler/build/xxx
<toolchain_dir>/         → /usr1/openeuler/native_gcc   （设置了 toolchain_dir 时）
```

#### 停止正在运行的构建

```bash
docker exec <container_name> bash -c "pkill -f bitbake; pkill -f cooker"
# 查找容器名：
docker ps
```

#### 预期成功输出

```
NOTE: Tasks Summary: Attempted 1649 tasks of which 1649 didn't need to be rerun and all succeeded.
```

---

## compile.yaml 参考

本工作区 `qemu_arm64` 构建的 `compile.yaml`：

```yaml
build_in: docker
machine: qemu-aarch64
toolchain_type: EXTERNAL_TOOLCHAIN:aarch64
repos:
  - yocto-poky
  - yocto-meta-openembedded
docker_param:
  image: swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest
  parameters: -itd --network host
  volumns:
    - /dev/net/tun:/dev/net/tun
    - <workspace-root>/src:/usr1/openeuler/src
    - <workspace-root>/build/qemu_arm64:/home/openeuler/build/qemu_arm64
  command: bash
```

关键字段：

| 字段 | 说明 |
|---|---|
| `build_in` | `docker` 或 `host` |
| `machine` | BitBake `MACHINE` 值 |
| `toolchain_type` | `EXTERNAL_TOOLCHAIN:aarch64` 或 `EXTERNAL_TOOLCHAIN_LLVM` |
| `docker_param.image` | 使用的容器镜像 |
| `docker_param.volumns` | 宿主机 ↔ 容器路径映射 |

---

## 其他命令

### `oebuild manifest`

管理上游包下载的源码基线文件：

```bash
# 从当前工作区创建 manifest
oebuild manifest create [-f manifest.yaml]

# 下载 manifest 中列出的单个仓库
oebuild manifest download zlib [-f manifest.yaml]

# 下载 manifest 中所有仓库
oebuild manifest download [-f manifest.yaml]
```

### `oebuild runqemu`

在仿真中运行构建好的 QEMU 镜像（在容器内封装 poky `runqemu`）：

```bash
# 无图形运行（无显示环境时必需）
oebuild runqemu nographic

# 带内核参数
oebuild runqemu nographic bootparams="console=ttyAMA0"
```

> 需要镜像 recipe 包含 `IMAGE_CLASSES += "qemuboot"`。
> 机器相关的 QEMU 参数在 `yocto-meta-openeuler/conf/machine/` 中。

### `oebuild clear`

清理之前构建遗留的 Docker 容器：

```bash
oebuild clear docker
```

读取每个构建目录中的 `.env` 文件找到容器 ID，然后停止并删除它们。

### `oebuild menv`

管理基于 OpenEuler 镜像构建的 SDK 开发环境：

```bash
oebuild menv create -d <sdk-dir> -n <env-name>    # 从预初始化的 SDK 目录
oebuild menv create -f <sdk-shell-file> -n <name>  # 从 SDK 安装脚本
oebuild menv list                                   # 列出已安装的 SDK 环境
oebuild menv remove -n <env-name>                   # 删除 SDK 环境
oebuild menv active -n <env-name>                   # 激活用于开发
```

### `oebuild deploy-target` / `oebuild undeploy-target`

向运行中的目标机器在线部署/撤销部署软件包：

```bash
oebuild deploy-target <package> user@<ip>
oebuild undeploy-target <package> user@<ip>
```

### `oebuild mugentest`

对目标机器运行 mugen 功能测试：

```bash
oebuild mugentest \
  --mugen-path /path/to/mugen \
  --ip <target-ip> \
  --user <user> \
  --password <password> \
  --port <port>
```

然后选择测试套件：1=Tiny 镜像、2=OS 基础、3=安全配置、4=嵌入式开发。

---

## 快速命令参考

| 命令 | 说明 |
|---|---|
| `oebuild init <dir>` | 创建新的 oebuild 工作区 |
| `oebuild update` | 拉取容器 + 更新 yocto 仓库和层 |
| `oebuild update docker` | 仅拉取/更新容器镜像 |
| `oebuild update yocto` | 仅更新 yocto-meta-openeuler |
| `oebuild update layer` | 仅更新依赖层 |
| `oebuild generate [-p platform] [-f feature]` | 创建 `compile.yaml` 构建配置 |
| `oebuild new [-p platform] [-f feature]` | 同 `generate`（新版实现） |
| `oebuild bitbake <target>` | 在容器中构建 BitBake 目标 |
| `oebuild bitbake -c <task> <recipe>` | 运行特定 BitBake 任务 |
| `oebuild bitbake -e <recipe>` | 输出展开后的 BitBake 环境 |
| `oebuild bitbake -c cleansstate <recipe>` | 清理 recipe 的 sstate 缓存 |
| `oebuild bitbake`（无参数） | 进入容器内的交互构建 shell |
| `oebuild manifest create` | 从当前工作区生成 manifest |
| `oebuild manifest download <repo>` | 下载特定源码仓库 |
| `oebuild runqemu nographic` | 在终端中运行 QEMU 镜像 |
| `oebuild clear docker` | 删除遗留构建容器 |
| `oebuild menv list` | 列出已安装的 SDK 环境 |
| `oebuild deploy-target <pkg> user@ip` | 向目标在线部署软件包 |
| `oebuild mugentest ...` | 在目标上运行 mugen 测试 |

---

## 故障排查

### `oebuild: command not found`

需要激活 venv：
```bash
source <workspace-root>/.venv/bin/activate
```

### ENOSPC / inotify 错误

```bash
sudo sysctl -w fs.inotify.max_user_watches=524288
sudo sysctl -w fs.inotify.max_user_instances=512
```

### Docker 容器无法启动

```bash
docker images | grep openeuler-container
docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest
```

### `Please do it in compile workspace which contain compile.yaml`

运行 `oebuild bitbake` 前必须先 `cd` 到构建目录：

```bash
cd <workspace-root>/build/qemu_arm64
oebuild bitbake <target>
```

### 构建挂起或容器过期

```bash
docker ps                    # 查找容器名（Docker 随机名，按实际输出替换）
docker exec <container_name> bash -c "pkill -f bitbake; pkill -f cooker"
oebuild clear docker         # 清理已停止的容器
```

### 重新进入已有容器（无需重建）

容器 ID 保存在 `build/<target>/.env` 中。下次调用 `oebuild bitbake` 时，
oebuild 读取 `.env` 并复用运行中的容器——无需冷启动。

---

## 构建配置总结（qemu-aarch64）

| 字段 | 值 |
|---|---|
| Machine | `qemu-aarch64` |
| Distro | `openeuler` |
| 目标 sysroot | `aarch64-openeuler-linux` |
| 工具链 | 外部 GCC（`/usr1/openeuler/gcc/openeuler_gcc_arm64le`） |
| GCC 版本 | `12.3.1` |
| 容器 | `openeuler-container:latest` |
| 层 | meta、meta-oe、meta-python、meta-networking、meta-filesystems、meta-openeuler、meta-openeuler-bsp |
