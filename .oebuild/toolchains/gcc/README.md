# gcc — openEuler Embedded GCC 交叉编译链

## 介绍

本目录用于构建 openEuler Embedded 的 GCC 交叉编译链。所有产物均由
[crosstool-NG 1.26.0](http://crosstool-ng.org/) 驱动，源码来自
`.oebuild/manifest.yaml` 中声明的 src-openeuler 镜像，并通过本目录的
`prepare.sh` / `update.sh` 完成下载、解包、补丁与配置刷新。

## 目录结构

```
gcc/                             # .oebuild/toolchains/gcc/（旧路径 cross-tools → 本目录）
├── README.md                     # 本文件
├── release.yaml                  # gitee release 元数据（CI 用）
├── prepare.sh                    # 下载源码 + 解包 + 应用 spec 内与 OE 专有补丁
├── update.sh                     # 修改 GCC 头文件特性 + 用真实路径刷新 config_*
├── configs/
│   ├── config.xml                # 全局版本/路径定义（被 prepare.sh/update.sh source）
│   ├── config_aarch64            # arm64   + glibc 2.38  + gcc 12.3.0  （CI 构建）
│   ├── config_aarch64-musl       # arm64   + musl 1.2.3  + gcc 10.3.0  （LEGACY，见下）
│   ├── config_arm32              # arm32   + glibc 2.38  + gcc 12.3.0  （CI 构建）
│   ├── config_arm32-musl         # arm32   + musl 1.2.4  + gcc 12.3.0  （CI 构建）
│   ├── config_riscv64            # riscv64 + glibc 2.38  + gcc 12.3.0  （CI 构建）
│   ├── config_riscv64-musl       # riscv64 + musl 1.2.4  + gcc 12.3.0  （社区自建，未上 CI）
│   └── config_x86_64             # x86_64  + glibc 2.38  + gcc 12.3.0  （CI 构建）
└── patches/
    ├── README.md                 # 补丁命名规范
    └── glibc-revert-reserve-relocation-information-for-sysboost.patch
```

## 工作流

```
            ┌──────────────────┐
            │ .oebuild/        │
            │  manifest.yaml   │  ← 14 个组件的 remote_url + version（commit）
            └────────┬─────────┘
                     │ 读取
                     ▼
            ┌──────────────────┐
            │ configs/         │
            │  config.xml     │  ← 全局版本号、目录名、MANIFEST 指针
            └────────┬─────────┘
                     │ source
        ┌────────────┴────────────┐
        ▼                         ▼
┌───────────────┐         ┌──────────────────┐
│ prepare.sh    │         │ update.sh        │
│ - git clone   │         │ - 改 GCC 头文件   │
│   14 个仓库   │         │   （aarch64/     │
│ - 解包 tar    │         │    riscv64 走    │
│ - 应用 spec   │         │    lib64；       │
│   内补丁      │         │    libstdc++.so  │
│ - 应用 patches│         │    加 relro/now/ │
│   目录补丁    │         │    noexecstack） │
└──────┬────────┘         │ - 用真实路径刷新 │
       │                  │   config_* 中    │
       │                  │   CT_*_CUSTOM_   │
       │                  │   LOCATION       │
       │                  └────────┬─────────┘
       │                           │
       └─────────────┬─────────────┘
                     ▼
            open_source/<pkg>/<pkg>-<ver>/    ← 已就绪源码
            config_<arch>                     ← 已就绪配置
                     │
                     ▼  cp config_<arch> .config && ct-ng build
            x-tools/<target>-openeuler-linux-gnu/
```

`prepare.sh` 与 `update.sh` 必须先后执行：前者准备源码，后者把
config 文件中的占位路径 `${OPENSOURCE_DIR}/...` 替换为实际绝对路径
（并修改 GCC 头文件）。跳过 `update.sh` 直接 `ct-ng build` 也可以，因为
config 内已使用 `${OPENSOURCE_DIR}` 变量，但 GCC 头文件特性（lib64 链接器、
libstdc++ 安全选项）不会生效。

## 容器

构建链容器镜像：

```
swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest
```

> 注意：自行起容器时务必加 `-u openeuler` 指定非 root 用户，crosstool-NG
> 默认拒绝在 root 下构建。

最终 gcc 配置可用 `*gcc -v` 查看，例（aarch64）：

```
COLLECT_GCC=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu/bin/aarch64-openeuler-linux-gnu-gcc
Target: aarch64-openeuler-linux-gnu
Configured with: ... --with-arch=armv8-a --enable-default-pie --libdir=${CT_PREFIX_DIR}/lib64 ...
gcc version 12.3.0 (crosstool-NG 1.26.0)
```

## 构建方式

构建有三种入口：自动构建（CI 风格，由 oebuild 一键触发）、交互构建
（oebuild 生成配置后人工执行剩余步骤）、原始构建（全手动，便于理解流程）。
**三种方式的 prepare.sh / update.sh 调用方式完全相同**：先 `cd` 进
`gcc/` 目录，再 `./prepare.sh [work_dir]` 然后 `./update.sh`。
`work_dir` 缺省即当前目录；脚本通过 `$BASH_SOURCE` 自定位，因此也支持从
任意位置以绝对路径调用。

### 1. 自动构建模式

```
oebuild generate          # 弹出菜单 → Build Toolchain → Auto Build
                          # → 勾选要构建的编译链（可多选）→ ESC → y 保存
```

oebuild 自动按选定 config 依次跑 `prepare.sh` → `update.sh` → `ct-ng build`。

### 2. 交互构建模式

```
oebuild generate          # 弹出菜单 → Build Toolchain → Interactive Build
                          # → ESC → y 保存退出，会打印进入构建目录的提示
cd <build_dir>            # 进入 oebuild 生成的构建目录
oebuild toolchain         # 进入 toolchain 构建交互 shell
```

进入交互 shell 后会看到提示：

```
Welcome to the openEuler Embedded build environment, where you
can create openEuler Embedded cross-chains tools by follows:
./prepare.sh ./
cp config_aarch64 .config && ct-ng build
cp config_aarch64-musl .config && ct-ng build
cp config_arm32 .config && ct-ng build
cp config_arm32-musl .config && ct-ng build
cp config_x86_64 .config && ct-ng build
cp config_riscv64 .config && ct-ng build
cp config_riscv64-musl .config && ct-ng build
```

按提示先准备源码（在 gcc/ 目录内调用 prepare.sh，把工作目录
作为参数传入；oebuild 生成的构建目录下已包含 gcc/ 子目录）：

```
cd gcc
./prepare.sh ../          # ../ 即上层构建目录，作为 work_dir
./update.sh
```

然后选择需要的 config 进行构建：

```
cd ..
cp config_aarch64 .config && ct-ng build
```

### 3. 原始构建模式（推荐初学者）

最直观，全程手动，便于理解每一步在做什么。

1. 起 SDK 容器：

   ```
   docker run -it -u openeuler \
       -v /dev/net/tun:/dev/net/tun \
       swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest \
       bash
   ```

2. 克隆源码（depth=1 提高效率）：

   ```
   git clone https://gitee.com/openeuler/yocto-meta-openeuler.git --depth=1
   ```

3. 进入 gcc，跑 prepare.sh 下载并解包所有依赖（产物落在
   `gcc/open_source/<pkg>/<pkg>-<ver>/`）：

   ```
   cd yocto-meta-openeuler/.oebuild/toolchains/gcc
   ./prepare.sh
   ```

4. 跑 update.sh，应用 GCC 特性补丁并把 config 中的占位路径替换为绝对路径：

   ```
   ./update.sh
   ```

5. 选择一个 config，执行构建（产物落在 `gcc/x-tools/<target>/`）：

   ```
   cp config_aarch64 .config
   ct-ng build
   ```

## 产物打包

crosstool-NG 默认输出到 `${HOME}/x-tools/<target-triple>/`。CI 流水线
（`.oebuild/workflows/jenkinsfile_toolchain_release`）按统一命名规范
重命名并打包；本地下线后建议沿用同一命名，便于与 CI 产物对齐：

| target triple                       | tar 名称                              |
| ----------------------------------- | ------------------------------------- |
| aarch64-openeuler-linux-gnu         | openeuler_gcc_arm64le.tar.gz          |
| arm-openeuler-linux-gnueabi         | openeuler_gcc_arm32le.tar.gz          |
| x86_64-openeuler-linux-gnu          | openeuler_gcc_x86_64.tar.gz           |
| riscv64-openeuler-linux-gnu         | openeuler_gcc_riscv64.tar.gz          |
| arm-openeuler-linux-musleabi        | openeuler_gcc_arm32le-musl.tar.gz     |
| aarch64-openeuler-linux-musl        | openeuler_gcc_arm64le-musl.tar.gz     |
| riscv64-openeuler-linux-musl        | openeuler_gcc_riscv64-musl.tar.gz     |

打包示例（aarch64）：

```
cd x-tools
mv aarch64-openeuler-linux-gnu openeuler_gcc_arm64le
tar czf openeuler_gcc_arm64le.tar.gz openeuler_gcc_arm64le
```

## release.yaml

`release.yaml` 是 gitee release 的元数据，被 CI 流水线
（`embedded-ci` 仓的 `main.py create_release`）消费。字段含义：

| 字段              | 含义                                            |
| ----------------- | ----------------------------------------------- |
| `tag_name`        | 发行版 tag（与 `name` 同步）                    |
| `name`            | 发行版名称                                       |
| `body`            | 发行版描述（多行；列出本发行版包含哪些产物 tar） |
| `target_commitish`| tag 关联分支                                     |
| `owner`           | gitee 工作组                                     |
| `repo`            | gitee 仓库名                                     |

升级 toolchain 版本时同步修改本文件，CI 会据其创建 gitee release 并上传
`x-tools/` 下所有 tar。

## 关于 config_aarch64-musl（LEGACY）

`config_aarch64-musl` 目前停留在 **gcc 10.3.0 / crosstool-NG 1.25.0 /
binutils 2.37 / musl 1.2.3 / gdb 11.x / gmp 6.2.1 / isl 0.16.1** 等旧栈，
与 `configs/config.xml` 及 SDK 容器（ct-ng 1.26.0）不一致，**未在 CI 中
构建**，仅作历史保留。如需 aarch64 + musl 工具链，建议基于
`config_riscv64-musl` 的版本栈新建 `config_aarch64-musl`（即采用
gcc 12.3.0 / musl 1.2.4 / gdb 14.1 / gmp 6.3.0 / isl 0.24 等）。
