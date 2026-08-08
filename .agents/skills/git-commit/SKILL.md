---
name: git-commit
description: '编写符合 openEuler Embedded 规范的 git commit message 时使用。覆盖标题格式（scope: subject）、正文 why/what 写作原则、Signed-off-by 签名、Co-Authored-By AI 元数据、单一逻辑变更拆分、批量改写 commit 信息。触发关键词：commit message、提交信息格式、标题规则、正文规范、Signed-off-by、Co-Authored-By、git commit -s、单一逻辑变更、amend、reword。'
argument-hint: "要提交/改写的改动描述，例如 '修复 openeuler.bbclass 空子目录问题'"
---

# Skill: git-commit — 编写规范的 Commit Message

本技能提供 openEuler Embedded 社区 commit message 的格式与写作规范。专注于
"写好一条提交信息"，与 [send-pr](../send-pr/SKILL.md)（向上游提交 PR）和
`toolchain-git-flow`（提交推送全流程）互补。

## 格式

```
<scope>: <what changed, imperative mood, ≤72 chars>
<blank line>
<body — why and what, NOT how>
<blank line>
Co-Authored-By: <AI模型名称及版本>
Signed-off-by: Name <email>
```

## 标题规则

- 使用 `<scope>: <summary>` —— scope 为文件/组件/recipe 名（不含路径）。
- 祈使句：`fix`、`add`、`remove`、`use`，而非 `fixed`/`adds`。
- ≤ 72 字符，结尾无句号。
- 示例：
  - `openeuler.bbclass: avoid empty subdirs in DL_DIR during checksum evaluation`
  - `python3-idna: consolidate CVE patch into versioned .bb file`
  - `cni: use OEE_ARCHIVE_SUB_DIR and drop redundant OPENEULER_REPO_NAMES`

## 正文规则

- 与标题之间隔一个空行。
- 说明改动**为什么**必要、**解决什么问题**（why + what）。
- 不要逐行描述代码如何工作——diff 本身已说明（NOT how）。
- 目标 **3–4 行**，硬上限 6 行，按 72 字符换行。
- bug 修复：一句根因 + 一句修复。
- 清理：一句原问题 + 一句所做改动。
- 若一次 commit 因不同原因触碰多个文件，每个额外关注点加一句（而非整段）。
- 拿不准就少写——reviewer 看的是 diff，不是小说。

### 好的正文（简洁，4 行）

```
ros_distro_humble.bbclass rewrites libdir to /usr/lib at RecipePreFinalise,
but python3's _sysconfigdata.py lives under lib64/python-sysconfigdata/.
Override python3targetconfig.bbclass to append the absolute lib64 path to
PYTHONPATH, fixing ModuleNotFoundError for ROS setuptools3 recipes on aarch64.
```

### 差的正文（同一改动，过于冗长）

```
The underlying cause is that on aarch64, openeuler sets baselib="lib64"
(BASE_LIB:tune-aarch64 = "lib64" in arch-arm64.inc), so the standard libdir
is /usr/lib64. However, ros_distro_humble.bbclass calls ros_libdir_set() via
bb.event.RecipePreFinalise which rewrites libdir to /usr/lib to match ROS
upstream's hard-coded install paths. As a result, STAGING_LIBDIR now resolves
to recipe-sysroot/usr/lib for all ROS target recipes, while _sysconfigdata.py
is still installed under usr/lib64/python-sysconfigdata/. The fix is to add a
new python3targetconfig.bbclass override in meta-openeuler/classes/ that also
appends ${STAGING_DIR_HOST}${exec_prefix}/lib64/python-sysconfigdata to
PYTHONPATH. This absolute path always resolves to the correct location
regardless of whether libdir has been modified by ros_libdir_set...
```

## Sign-off 与 AI 元数据

- 始终以 `Signed-off-by: Name <email>` 作为最后一行，使用 `git commit -s` 自动追加。
- AI 协助生成的提交必须在 `Signed-off-by` 之前追加 `Co-Authored-By:` 行，
  标注实际使用的 AI 模型名称及版本（随模型变化更新）：

```
Co-Authored-By: <AI模型名称及版本>
```

## 单一逻辑变更一次提交

按关注点拆分 commit，而非按文件数量：

- 一个 class 的 bug 修复 → 1 commit
- 一个 recipe 的冗余配置清理 → 1 commit
- 两个相关文件修复同一告警 → 1 commit（含两个文件）
- 不相关的改动 → 即使在同一文件中也拆成独立 commit

## 工作流

```bash
# 仅暂存本次 commit 的文件
git add <file1> [file2 ...]

# 将 message 写入文件以避免 shell 引号问题，然后：
git commit -s -F /tmp/msg.txt

# 或对短 message 内联：
git commit -s -m "scope: title" -m "Body paragraph."
# AI 协助时追加：-m "Co-Authored-By: <AI模型名称及版本>"
```

## 批量改写多条 commit

在不改动内容的情况下重写最近 N 条 commit message：

```bash
git reset --soft HEAD~N          # 撤销 N 条 commit，保留改动在暂存区
git add <files-for-commit-1>
git commit -s -F /tmp/msg1.txt
git add <files-for-commit-2>
git commit -s -F /tmp/msg2.txt
# ...
```

当 message 文件已预先准备好时，优先用此方式替代 `git rebase -i` + reword
——更简单，且避免交互式编辑器问题。

---

## 检查清单

- [ ] 标题为 `<scope>: <summary>`，祈使句，≤72 字符
- [ ] 正文说明 why/what，3–4 行，按 72 字符换行
- [ ] 末行为 `Signed-off-by`（`git commit -s`）
- [ ] AI 协助生成时包含 `Co-Authored-By: <AI模型名称及版本>`（在 `Signed-off-by` 之前）
- [ ] 按单一逻辑变更拆分 commit
