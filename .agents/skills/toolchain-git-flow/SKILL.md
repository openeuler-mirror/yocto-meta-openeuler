---
name: toolchain-git-flow
description: '处理符合 openEuler Embedded 规范的 Git 提交与推送工作流。当用户要求 git commit、git push、提交代码、推送代码、git status、commit -s、DCO sign-off、检查提交信息、符合规范、Signed-off-by、gitlint，或准备提交代码时使用。强制执行 openEuler Embedded 提交信息格式（area: subject、body、Signed-off-by footer）。'
---

# toolchain-git-flow Skill

自动化 yocto-meta-openeuler 项目的 Git 提交和推送流程，强制执行
openEuler Embedded 提交规范（DCO sign-off + gitlint 规则）。

## 核心规范

### 0. 提交范围 — 只提交当前任务相关的文件

**不要盲目 `git add .` 提交所有内容。** 暂存前仔细检查 `git diff` 和
`git status`，确保只包含当前任务相关的文件。

实践规则：
1. 仔细检查 `git status` 输出。
2. 使用 `git add <具体路径>` 暂存相关文件，不要从仓库根目录 `git add .`。
3. 如果出现与当前任务无关的已修改文件，跳过它们，除非用户明确要求包含。
4. `work/` 和 `output/` 目录已加入 `.gitignore`，不应出现在暂存区。

### 1. 提交信息格式

必须严格遵循以下结构，各部分之间恰好一个空行：

```
<area>: <subject>

<body>

<footer_tags>
```

- **标题 (<area>: <subject>)**：
  - 格式：`<module>: <brief description>`（如 `menu: move output dir to toolchains/output`）
  - 长度限制：非 revert 提交最多 80 字符，revert 提交最多 102 字符
  - subject 至少 2 个单词，末尾无标点
  - 冒号后恰好一个空格
  - **不允许中文字符**
- **Body**：
  - 必须提供详细描述，解释 "why" 和 "what"
  - 每行最多 100 字符（包含 URL 的行除外）
  - **不允许中文字符**
- **Footer（标签）**：
  - 必须包含 `Signed-off-by: Name <email>`
  - `Signed-off-by` 必须是最后一行
  - 允许的标签：`Signed-off-by`、`Closes`、`Fixes`、`Co-developed-by`、`Link`、`Assisted-by`
  - 标签首字母大写，冒号后一个空格
  - `Fixes` 格式：`Fixes: <12-char-SHA1>(<original-commit-title>)`
  - `Closes` 格式：`Closes: https://gitee.com/openeuler/<repo>/pull/<NUM>`

### 2. 强制要求

- **所有提交必须签名**：使用 `git commit -s`（或 `-m` + 手动添加 `Signed-off-by`）。
  确保 `Signed-off-by` 行在最后。
- **远程仓库**：
  - `origin`：个人 fork（用于推送代码）
  - `upstream`：主项目仓库（用于提交 Pull Request）
- **gitlint 验证**：提交后运行 gitlint 检查（仓库已配置 `.gitlint` 和
  `scripts/gitlint/openeuler_embedded_commit_rules.py`）。

### 3. openEuler Embedded 特有规则

仓库的 gitlint 规则文件（`.gitlint`）定义了以下额外检查：
- body 最少 15 字符
- body 最多 100 行，footer 最多 20 行
- body 和 footer 每行最多 100 字符
- 不允许在 title 和 message 中出现中文字符
- `Closes` 标签前缀必须是 `https://gitee.com/openeuler/`

## 执行步骤

### 状态判断

如果用户明确要求**仅本地提交**（如"只提交不推送"），只执行 Phase 1、2
和 Phase 3 的本地提交部分。跳过推送、PR 链接和 PR 描述生成。

### Phase 1: 检查和总结

```bash
cd "$(git rev-parse --show-toplevel)"

# 查看 git 状态
git status

# 查看改动内容
git diff

# 查看最近提交（参考格式）
git log --oneline -5
```

1. 在仓库根目录运行 `git status`。
2. 向用户总结待提交的改动内容。

### Phase 2: 组建提交信息

1. 帮助用户起草提交信息（Title, Body, Footer），遵循上述规范。
2. **验证**：检查标题长度、格式、空行、中文字符。
3. **确认暂存范围**：向用户展示将要提交的文件，明确标注排除的文件。
4. **检查 gitlint 规则**：确保提交信息符合 `.gitlint` 规则。

### Phase 3: 执行提交和推送

**重要**：只提交与当前任务相关的文件。

1. 暂存相关文件：`git add <具体路径>`（不要 `git add .`）。
2. 验证暂存区：`git diff --cached --stat`。
3. 执行提交（使用 `-s` 自动追加 `Signed-off-by`，不要手动添加）：
   ```bash
   git commit -s -m "<area>: <subject>" -m "<body>"
   ```
   或分步：
   ```bash
   git commit -s  # 打开编辑器
   ```
4. 如果**不是"仅本地提交"**：
   - 执行 `git push origin <branch>`（amend 推送使用 `--force-with-lease`）。
   - 获取远端信息：`git remote get-url origin`。
   - 检查 PR：push 输出或远端 hook 响应中是否包含 PR/MR URL。
     如果包含，提取 PR 编号。
   - **如果已有 PR**：PR 描述现在已过时，需要同步更新。分析 PR 中所有
     commit，重新生成完整的 PR 描述（中文），覆盖更新。
   - **如果没有 PR**：生成 AtomGit PR 链接：
     `https://atomgit.com/<username>/yocto-meta-openeuler/merge_requests/new?source_branch=<current-branch>`
     并从提交信息 body 组成 PR 描述。

## PR 描述格式

PR 描述应使用**中文**，包含以下部分：

```
### 背景
<为什么需要这个 PR>

### 主要变更
<具体做了什么>

### 关键修复（如有）
<bug 修复列表>

### 使用方式
<代码示例>

### 提交列表
<commit 列表>
```

## 常用命令参考

| 操作 | 命令 |
| --- | --- |
| 推送到个人 fork | `git push origin <branch>` |
| 强制推送（amend） | `git push origin <branch> --force-with-lease` |
| 签名提交 | `git commit -s` |
| 撤销最近提交（保留改动） | `git reset --soft HEAD~1` |
| 检查提交信息 | `git log --format="%B" -1` |
| 查看 gitlint 规则 | `cat .gitlint` |

## Git 用户信息

Git 提交人信息（`user.name` / `user.email`）由各开发者本地配置，
`git commit -s` 会自动据此生成 `Signed-off-by` 行。查看当前配置：

```bash
git config user.name
git config user.email
```

## 何时使用

- 用户要求提交代码
- 用户要求推送 commit
- 用户要求检查提交信息规范
- 用户要求创建 PR 描述
- 用户要求修复 gitlint 报错

## 何时不使用

- 查看文件内容（使用 Read 工具）
- 搜索代码（使用 Grep/Glob 工具）
- 构建编译链（使用 toolchain-build skill）
