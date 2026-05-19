# GLib 2.0 ABI 兼容性检测工具

## 概述

本目录包含四种架构的预编译 GLib ABI 兼容性检测程序，用于验证目标设备上的 GLib 运行时库与交叉编译时使用的 GLib 版本是否 ABI 兼容。

## 校验值

校验值以标准校验文件方式存储：

- `sha256sums` - SHA256 校验值
- `md5sums` - MD5 校验值

验证文件完整性：

```bash
sha256sum -c sha256sums
md5sum -c md5sums
```

## 编译方法

检测程序通过 `meta-openeuler/recipes-core/glib-2.0/glib-2.0_%.bbappend` 中定义的 `do_populate_abi_check` 任务编译，源码位于 `meta-openeuler/recipes-core/glib-2.0/glib-2.0/glib-abi-check.c`。

### 前置条件

- 已配置目标架构的 openEuler Embedded 构建环境（oebuild）
- GLib 2.0 配方已完成构建（至少执行过 `do_install`）

### 编译步骤

```bash
# 进入目标架构的构建目录后执行
oebuild bitbake glib-2.0 -c do_populate_abi_check
```

编译产物位于：
```
tmp/work/<架构>/glib-2.0/<版本>/build/glib-abi-check
```

注意：`do_populate_abi_check` 任务**不会**在正常构建时自动执行，需要通过 `-c do_populate_abi_check` 手动触发。

### 编译原理

该任务使用安装目录 `${D}` 中的 GLib 头文件和库文件编译 `glib-abi-check.c`，确保检测程序与部署到目标设备的 GLib 版本一致。

## 运行方法

1. 将对应架构的检测程序拷贝到目标设备：

```bash
scp glib-abi-check-<架构> root@<目标IP>:/root/glib-abi-check
```

2. 在目标设备上执行：

```bash
chmod +x /root/glib-abi-check
/root/glib-abi-check
```

3. 查看输出，成功运行结果如下：

```
========================================
GLib 2.0 ABI Check
Compile-time GLib version: 2.78.3
Runtime GLib version: 2.78.3
========================================

[PASS] Compile-time and runtime GLib version match

[1/4] Basic type size check
[PASS] sizeof(gint) == 4
...

Total: 25  Passed: 25  Failed: 0
========================================
GLib 2.0 ABI compatible!
```

如果有测试项失败，程序返回退出码 1 并输出 `GLib 2.0 ABI incompatible!`。

## 检测内容

### [1/4] 版本匹配检查

验证编译时 GLib 版本（头文件）与运行时 GLib 版本（共享库）是否一致。版本不匹配说明目标设备上的 GLib 版本与编译时使用的版本不同。

### [2/4] 基本类型大小检查

验证 GLib 基本类型的大小是否符合预期：

| 类型 | 预期大小 |
|---|---|
| gint | 4 字节 |
| guint | 4 字节 |
| gint64 | 8 字节 |
| guint64 | 8 字节 |
| gpointer | sizeof(void*) |
| gsize | sizeof(size_t) |
| gssize | sizeof(ssize_t) |

### [3/4] 核心数据结构布局检查

验证 GLib 核心数据结构布局是否有效，并打印实际大小供参考：

| 结构体 | 说明 |
|---|---|
| GString | 动态字符串（打印实际大小） |
| GList | 双向链表（预期：3 * sizeof(gpointer)） |
| GSList | 单向链表（预期：2 * sizeof(gpointer)） |
| GArray | 动态数组（打印实际大小） |
| GByteArray | 字节数组（预期：与 GArray 相同） |
| GError | 错误报告（打印实际大小） |

### [4/4] 枚举常量检查

使用 `G_TYPE_IS_FUNDAMENTAL()` 验证 GType 基本类型常量在运行时是否有效，验证 GSeekType 枚举值是否互不相同。打印实际值供参考。

### [5/4] 核心函数检查

测试 GLib 基础函数是否正常工作：

| 函数 | 测试内容 |
|---|---|
| g_malloc / g_free | 内存分配与释放 |
| g_strdup | 字符串复制 |
| g_string_new / g_string_free | 动态字符串创建与销毁 |
| g_list_append / g_list_free | 双向链表操作 |
| g_hash_table_new / g_hash_table_destroy | 哈希表创建与销毁 |

## 常见问题

- **版本不匹配**：确保目标设备上的 GLib 版本与交叉编译时使用的版本一致
- **类型大小不匹配**：可能是因为编译的二进制与目标环境的 32 位/64 位架构不匹配
- **函数测试失败**：可能是因为目标设备上的 GLib 共享库损坏或不兼容
- **Permission denied**：目标设备的 /tmp 可能以 noexec 方式挂载，请将检测程序拷贝到 /root 或其他具有执行权限的目录

## 英文文档

See [README_en.md](README_en.md) for English documentation.
