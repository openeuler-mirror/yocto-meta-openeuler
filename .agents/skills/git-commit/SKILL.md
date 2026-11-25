---
name: git-commit
description: '编写符合 openEuler Embedded 规范的 git commit message 时使用。覆盖标题格式（area: subject）、正文 why/what 写作原则、Signed-off-by 签名、Co-Authored-By AI 元数据、单一逻辑变更拆分、commit_scope 文档与代码分离、批量改写 commit 信息。触发关键词：commit message、提交信息格式、标题规则、正文规范、Signed-off-by、Co-Authored-By、git commit -s、单一逻辑变更、commit_scope、文档代码分离、amend、reword。'
argument-hint: "要提交/改写的改动描述，例如 '修复 openeuler.bbclass 空子目录问题'"
---

# Skill: git-commit — 编写规范的 Commit Message

本技能提供 openEuler Embedded 社区 commit message 的格式与写作规范。专注于
"写好一条提交信息"，与 [send-pr](../send-pr/SKILL.md)（向上游提交 PR）和
`toolchain-git-flow`（提交推送全流程）互补。

## 格式

```
<area>: <what changed, imperative mood, ≤72 chars 推荐>
<blank line>
<body — why and what, NOT how>
<blank line>
Co-Authored-By: <AI模型名称及版本>
Signed-off-by: Name <email>
```

## 标题规则

- 使用 `<area>: <summary>` —— area 为组件/文件/recipe 名（不含路径），与 gitlint
  `title-form` 校验的 `<area>: <subject>` 一致。
- 祈使句：`fix`、`add`、`remove`、`use`，而非 `fixed`/`adds`。
- 长度：门禁硬上限 80 字符（revert 提交 102，见 `.gitlint`），推荐 ≤ 72；
  结尾无句号。
- 示例：
  - `openeuler.bbclass: avoid empty subdirs in DL_DIR during checksum evaluation`
  - `python3-idna: consolidate CVE patch into versioned .bb file`
  - `cni: use OEE_ARCHIVE_SUB_DIR and drop redundant OPENEULER_REPO_NAMES`

## 正文规则

- 与标题之间隔一个空行。
- 说明改动**为什么**必要、**解决什么问题**（why + what）。
- 不要逐行描述代码如何工作——diff 本身已说明（NOT how）。
- 目标 **3–4 行**，尽量不超过 6 行（门禁是 body ≤ 100 行、每行 ≤ 100 字符，
  6 行只是本项目约定），按 72 字符换行。
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
  cherry-pick 场景例外：其后的 `(cherry picked from commit ...)` 行允许紧跟
  `Signed-off-by`（gitlint `cherry-pick-check` 明确支持，且中间不能有空行）。
- AI 协助生成的提交必须在 `Signed-off-by` 之前追加 `Co-Authored-By:` 行。
- **模型名称及版本必须每次提交时动态确定**：取当前会话实际使用的 AI 模型，
  不得照抄历史 commit 或文档示例中的模型名——模型会更换，历史信息不一定正确。
  若无法确定，向用户确认后再提交：

```
Co-Authored-By: <本次提交实际使用的AI模型名称及版本>
```

### 门禁还会检查

`scripts/gitlint/openeuler_embedded_commit_rules.py` 实际校验、但上面未覆盖的点：

- subject 至少 2 个词；冒号后恰好一个空格；标题结尾不带 `?:!.,;`
- footer 内不能有空行；footer 最多 20 行
- `Co-developed-by` 必须紧跟一行 `Signed-off-by`；多出的 `Signed-off-by`
  必须与 `Co-developed-by` 配对
- `Fixes: <12 位 SHA>(<原提交标题>)`；`Closes:` 链接目前要求
  `https://gitee.com/openeuler/` 前缀（规则如此，与 PR 托管在 AtomGit 无关）

自查：`gitlint --msg-filename /tmp/msg.txt`，或直接 `git commit`（本克隆已装
commit-msg hook）。

## 单一逻辑变更一次提交

按关注点拆分 commit，而非按文件数量：

- 一个 class 的 bug 修复 → 1 commit
- 一个 recipe 的冗余配置清理 → 1 commit
- 两个相关文件修复同一告警 → 1 commit（含两个文件）
- 不相关的改动 → 即使在同一文件中也拆成独立 commit

## 文档与代码必须分开提交（commit_scope 门禁）

门禁的 `commit_scope` 检查（embedded-ci `-target commit_scope`）会逐个 commit
检查文件集合：**同一个 commit 不允许同时修改 `docs/` 下的文档和其他文件**
（代码、recipe、配置、样例）。违反时 PR 门禁直接失败。

- 功能改动需要同步文档时，先提交代码，再用独立的 `docs: ...` commit 提交文档。
- 当前实现按 `docs/` 目录判定文档；`.oebuild/**/README.md` 等不在该目录下的
  Markdown 历史上可与配置同提交，拿不准时仍建议归入 docs commit。
- 若已经混提，必须重排历史（reset + 重新 cherry-pick/commit）；仅改 commit
  message 无效——门禁检查的是每个 commit 的文件集合。
- 推送前自查：

```bash
base=upstream/master
for c in $(git rev-list "$base"..HEAD); do
  echo "=== $(git log -1 --format='%h %s' "$c")"
  git show --name-only --format= "$c"
done
```

确认每个 commit 的文件列表要么全是 `docs/`，要么不含 `docs/`。规则来源见
`.oebuild/workflows/README.md` 的 code check 说明与
`docs/source/infrastructure/embedded-ci/codecheck.rst`。

## 工作流

```bash
# 仅暂存本次 commit 的文件
git add <file1> [file2 ...]

# 将 message 写入文件以避免 shell 引号问题，然后：
git commit -s -F /tmp/msg.txt

# 或对短 message 内联：
git commit -s -m "area: title" -m "Body paragraph."
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

- [ ] 标题为 `<area>: <summary>`，祈使句，≤ 80 字符（门禁，推荐 ≤ 72）
- [ ] 正文说明 why/what，3–4 行，按 72 字符换行
- [ ] 末行为 `Signed-off-by`（`git commit -s`）
- [ ] AI 协助生成时包含 `Co-Authored-By: <本次提交实际使用的AI模型名称及版本>`（在 `Signed-off-by` 之前）
- [ ] `Co-Authored-By` 模型名为**本次提交动态确定**（非历史 commit / 文档示例照抄）
- [ ] 按单一逻辑变更拆分 commit
- [ ] 没有 commit 同时包含 `docs/` 文档与其他改动（commit_scope 门禁）
