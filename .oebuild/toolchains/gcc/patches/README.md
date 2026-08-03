# patches

openEuler Embedded 交叉编译链构建期间，**除各组件 src-openeuler 仓库内 *.spec 中
声明的 Patch\* 之外**额外需要应用的本仓专有补丁。

## 命名规范

补丁文件名必须以 `<pkg>-` 作为前缀，其中 `<pkg>` 与 `configs/config.xml` 中
对应组件的变量名（如 `glibc`、`gcc`、`binutils`）一致，且**只能出现一次**
`<pkg>-` 前缀：

```
<pkg>-<short-description>.patch
```

例如：

| 文件名                                              | 适用组件 |
| --------------------------------------------------- | -------- |
| glibc-revert-reserve-relocation-information-for-sysboost.patch | glibc    |
| gcc-foo-bar.patch                                   | gcc      |

理由：`prepare.sh` 的 `do_patch` 用 `ls ${OE_PATCH_DIR}/ | grep "^${pkg}-"`
枚举属于该组件的 OE 专有补丁，前缀不匹配则不会被应用。

## 应用顺序

`prepare.sh` 对每个组件按以下顺序应用补丁：

1. 先从 src-openeuler 仓库内的 `*.spec` 提取 `PatchXXXX:` 列表，按 spec 顺序
   应用 spec 内列出的补丁；
2. 再应用本目录下匹配 `<pkg>-` 前缀的所有补丁（按文件名字典序）。

## 补丁格式

- 统一使用 `diff -p1` 风格（即 `--- a/...` / `+++ b/...`），由 `prepare.sh`
  以 `patch -p1` 应用；
- 末尾保留一个空行，避免相邻补丁被 `patch` 误连。
