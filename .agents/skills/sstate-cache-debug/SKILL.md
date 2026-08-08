---
name: sstate-cache-debug
description: '诊断 BitBake sstate-cache 未命中、native 任务意外重建时使用。覆盖用 bitbake -S none 生成 sigdata、bitbake-diffsigs 对比任务签名、定位哈希差异根因、machine conf 中误用 export 导致 native 哈希污染等。触发关键词：sstate-cache、缓存未命中、sstate miss、bitbake-diffsigs、sigdata、任务哈希、native 重建、BB_BASEHASH_IGNORE_VARS、ROOTFS_PACKAGE_ARCH、export。'
argument-hint: "描述意外重建的 recipe 与两个构建目录，例如 'cmake-native 在 qemu_arm64 与 rpi-64 间未共享 sstate'"
---

# Skill: sstate-cache-debug — 用 bitbake-diffsigs 诊断 sstate 缓存未命中

本技能覆盖如何诊断 BitBake sstate-cache 条目为何在不同构建目录或机器间未被
复用，提供对比任务签名、定位根因、应用修复的分步流程——基于 OpenEuler
Embedded 工作区。与 `sstate-optimizer` agent 互补：该 agent 侧重性能优化策略，
本技能侧重具体的 miss 诊断与修复操作。

---

## 前置条件

- 已激活 Python venv：`source <workspace-root>/.venv/bin/activate`
- 至少完成过一次构建（sstate 已填充且 `tmp/stamps/` 存在）
- 两个容器在运行（`docker ps` 验证）：每个构建目录一个

容器映射（用 `docker inspect <name>` 确认）：

- `<container-A>` → `build/qemu_arm64`
- `<container-B>` → `build/rpi-64`

> 容器名为 Docker 自动生成的随机名，请按你实际的容器名替换。

---

## 第 1 步：确认意外重建

当 native 包（如 `cmake-native`、`python3-native`）意外重建时，先确认 sstate
未命中：

```bash
# 在新构建对应的容器内
docker exec <container-B> bash -c "
  cd /home/openeuler/build/rpi-64 &&
  source /usr1/openeuler/src/yocto-poky/oe-init-build-env . >/dev/null 2>&1 &&
  bitbake -e cmake-native 2>/dev/null | grep '^SSTATE_DIR='
"
```

确认两个构建共享同一 `SSTATE_DIR`（指向 `${OPENEULER_SP_DIR}/sstate-cache`）。

---

## 第 2 步：不执行任务生成 sigdata

用 `bitbake -S none` 仅计算并写入签名文件，不运行任何任务：

```bash
# qemu_arm64 容器
docker exec <container-A> bash -c "
  cd /home/openeuler/build/qemu_arm64 &&
  source /usr1/openeuler/src/yocto-poky/oe-init-build-env . >/dev/null 2>&1 &&
  bitbake -S none cmake-native 2>&1 | tail -3
"

# rpi-64 容器
docker exec <container-B> bash -c "
  cd /home/openeuler/build/rpi-64 &&
  source /usr1/openeuler/src/yocto-poky/oe-init-build-env . >/dev/null 2>&1 &&
  bitbake -S none cmake-native 2>&1 | tail -3
"
```

sigdata 文件写入：

```
tmp/stamps/<arch>/<recipe-name>/<version>.do_<task>.sigdata.<hash>
```

native 包的 arch 为 `x86_64-linux`。

---

## 第 3 步：定位 sigdata 并对比哈希

```bash
# 列出两个构建中 cmake-native 的 sigdata
ls build/qemu_arm64/tmp/stamps/x86_64-linux/cmake-native/
ls build/rpi-64/tmp/stamps/x86_64-linux/cmake-native/
```

若同一任务（如 `do_compile`）的文件名哈希（`.sigdata.` 之后的部分）在两个
构建间不同，sstate 就不会被复用。

---

## 第 4 步：运行 bitbake-diffsigs

在宿主机上运行 `bitbake-diffsigs`（两个构建共享宿主机 `src/` 挂载）：

```bash
# 先激活 venv
source <workspace-root>/.venv/bin/activate

SIG1=<workspace-root>/build/qemu_arm64/tmp/stamps/x86_64-linux/cmake-native/<version>.do_compile.sigdata.<hash1>
SIG2=<workspace-root>/build/rpi-64/tmp/stamps/x86_64-linux/cmake-native/<version>.do_compile.sigdata.<hash2>

PYTHONPATH=<workspace-root>/src/yocto-poky/bitbake/lib \
  python3 <workspace-root>/src/yocto-poky/bitbake/bin/bitbake-diffsigs "$SIG1" "$SIG2"
```

或直接用 Python API 获取机器可读输出：

```python
import sys
sys.path.insert(0, '<workspace-root>/src/yocto-poky/bitbake/lib')
import bb.siggen

result = bb.siggen.compare_sigfiles(sig1_path, sig2_path, recursecb=None, color=False, collapsed=True)
print('\n'.join(result))
```

API 签名：`compare_sigfiles(a, b, recursecb=None, color=False, collapsed=False)`

---

## 第 5 步：解读输出

diff 输出报告以下变化：

1. **变量值** —— 某变量的值在两个构建间发生了变化
2. **变量依赖列表** —— 任务所依赖的变量集合发生了变化
3. **文件校验和** —— 任务引用的某文件发生了变化

### 关键模式：变量出现在一个依赖集合而不在另一个

```
Dependency on Variable ROOTFS_PACKAGE_ARCH was removed
Dependency on Variable ROOTFS_PACKAGE_ARCH:virtclass-multilib-lib32 was removed
```

这表示该变量存在于构建 A 的任务依赖图中，但不在构建 B 中。若该变量在各
machine conf 中取值不同，会污染**所有**依赖它的任务哈希——包括本不该依赖
它的 native 任务。

---

## 已知根因：对 machine 专属变量使用 `export`

### 问题

在 OpenEuler Embedded 中，部分 machine conf 对仅对目标 rootfs 有意义的变量
使用了 `export` 关键字：

```bitbake
# qemu-aarch64.conf  ← 有问题的写法
export ROOTFS_PACKAGE_ARCH = "aarch64"
export ROOTFS_PACKAGE_ARCH:virtclass-multilib-lib32 = "armv7l"
```

`export` 关键字导致 BitBake：

1. 将该变量传递给**每个**任务的 shell 环境
2. 将其纳入**每个**任务的依赖集合（包括 `cmake-native`、`python3-native` 等）
3. 将其值纳入 sigdata 哈希

当另一 machine（如 `raspberrypi4-64`）未 export 该变量或赋不同值时，每个
native 任务都会得到不同哈希——整条 native 栈缓存未命中。

### 修复

**选项 1 —— 移除 `export`（推荐）**：该变量未被任何 `.bbclass`、`.bb` 或
shell 脚本消费，仅作为 `.conf` 文件内的信息性元数据。

```bitbake
# 修复前：
export ROOTFS_PACKAGE_ARCH = "aarch64"
export ROOTFS_PACKAGE_ARCH:virtclass-multilib-lib32 = "armv7l"

# 修复后：
ROOTFS_PACKAGE_ARCH = "aarch64"
ROOTFS_PACKAGE_ARCH:virtclass-multilib-lib32 = "armv7l"
```

**选项 2 —— 加入 `BB_BASEHASH_IGNORE_VARS`**：若 `export` 确因运行时需要而
保留，则将该变量排除在哈希计算外：

```bitbake
# 在 openeuler.conf 中：
BB_BASEHASH_IGNORE_VARS:append = " ROOTFS_PACKAGE_ARCH"
```

---

## 通用规则：何时在 BitBake 中使用 `export`

仅当满足以下条件时才使用 `export`：

- 构建脚本（`do_*` 任务内的 shell 命令）确实从环境读取该变量，**且**
- 该变量的值确实影响任务输出

不要对以下变量使用 `export`：

- 仅被其他 `.conf` 变量消费的 machine 元数据
- 值随 MACHINE 变化但影响 NATIVE 任务哈希的变量
- 已在 `BB_BASEHASH_IGNORE_VARS` 中的变量

---

## 检查 BB_BASEHASH_IGNORE_VARS

验证哪些变量已被排除在哈希计算外：

```bash
docker exec <container-A> bash -c "
  cd /home/openeuler/build/qemu_arm64 &&
  source /usr1/openeuler/src/yocto-poky/oe-init-build-env . >/dev/null 2>&1 &&
  bitbake -e 2>/dev/null | grep '^BB_BASEHASH_IGNORE_VARS='
"
```

OpenEuler 中 `openeuler.conf` 向该列表追加：

```bitbake
BB_BASEHASH_IGNORE_VARS:append = " OPENEULER_SP_DIR do_openeuler_fetch MANIFEST_LIST"
```

`SSTATE_DIR` 和 `SOURCE_DATE_EPOCH` 已由 poky 的 `bitbake.conf` 排除。

---

## 验证修复

移除 `export` 后，重新生成 sigdata 并验证哈希一致：

```bash
# 在两个构建中重新生成 sigdata
docker exec <container-A> bash -c "cd /home/openeuler/build/qemu_arm64 && source /usr1/openeuler/src/yocto-poky/oe-init-build-env . >/dev/null 2>&1 && bitbake -S none cmake-native"
docker exec <container-B> bash -c "cd /home/openeuler/build/rpi-64 && source /usr1/openeuler/src/yocto-poky/oe-init-build-env . >/dev/null 2>&1 && bitbake -S none cmake-native"

# 对比文件名哈希后缀 —— 现在应一致
ls build/qemu_arm64/tmp/stamps/x86_64-linux/cmake-native/*.do_compile.sigdata.*
ls build/rpi-64/tmp/stamps/x86_64-linux/cmake-native/*.do_compile.sigdata.*
```

若哈希后缀一致，两个构建将对该任务共享 sstate。

---

## 故障排查：容器 Python 依赖

在全新容器中运行 `bitbake -e` 时可能遇到：

```
ModuleNotFoundError: No module named 'yaml'
ModuleNotFoundError: No module named 'git'
```

修复：

```bash
docker exec <container> bash -c "pip3 install pyyaml gitpython -q"
```

---

## 参考变量

| 变量 | 用途 | 是否排除于哈希 |
|----------|---------|---------------------|
| `BB_SIGNATURE_HANDLER` | 签名算法（`OEEquivHash`） | 不适用（配置项） |
| `BB_HASHSERVE` | 本地哈希等价服务 socket | 是（在 `BB_HASHEXCLUDE_COMMON`） |
| `BB_BASEHASH_IGNORE_VARS` | 排除于任务哈希的变量 | 不适用 |
| `SSTATE_DIR` | sstate 缓存目录 | 是（在 `BB_BASEHASH_IGNORE_VARS`） |
| `SSTATE_MIRRORS` | 远程 sstate 镜像 URL | 默认未设置 |
| `SOURCE_DATE_EPOCH` | 可复现构建 epoch | 是（在 `BB_BASEHASH_IGNORE_VARS`） |
| `ROOTFS_PACKAGE_ARCH` | 目标 rootfs 包架构标签 | **未排除** —— 不要 `export` |
