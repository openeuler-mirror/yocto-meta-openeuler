---
name: send-pr
description: '向 yocto-meta-openeuler 上游仓库提交 PR 时使用。覆盖从 upstream 创建功能分支、cherry-pick 提交、推送到 fork、通过 ag-cli 创建并验证 PR。触发关键词：PR、pull request、upstream、merge request、发送 PR、创建 PR、提交到上游、ag-cli、AtomGit。'
argument-hint: "要发送的 commit SHA 或分支名，例如 '22df813' 或 'qemu-remove-boot'"
---

# Skill: send-pr — 向上游提交 Pull Request

本技能处理向 AtomGit 上的 openEuler 上游仓库提交 PR 的完整工作流。

## 仓库配置

远端配置因开发者而异：

- `upstream`：主仓库 `openeuler/yocto-meta-openeuler`（PR 目标）
- 个人 fork：远端名（如 `origin`、`myrepo`）与用户名因人而异

操作前先确认实际配置：

```bash
git remote -v
```

---

## 工作流

### 第 1 步 — 从上游创建功能分支

始终从干净的上游 master 建分支，而不是本地 master：

```bash
git fetch upstream
git checkout -b <branch-name> upstream/master
```

### 第 2 步 — Cherry-pick 提交

将特定提交带到新分支：

```bash
git cherry-pick <commit-sha>
```

多个提交：

```bash
git cherry-pick <sha1> <sha2> ...
```

### 第 3 步 — 推送到 fork

将分支推送到个人 fork（远端名因人而异，此处以 `myrepo` 为例）：

```bash
git push <fork远端名> <branch-name> -u
```

### 第 4 步 — 使用 ag-cli 创建 PR

前置条件（首次使用）：

```bash
npm install -g @hust-open-atom-club/atomgit-cli
# 全局目录无写权限（EACCES）时改用用户级 prefix，并确保 ~/.local/bin 在 PATH 中：
# npm install -g --prefix "$HOME/.local" @hust-open-atom-club/atomgit-cli

ag-cli auth status        # 未登录时执行 ag-cli auth login
```

从个人 fork 的远端地址确认用户名（例如 `git@atomgit.com:vonhust/yocto-meta-openeuler.git`
中的 `vonhust`）：

```bash
git remote -v
```

将 PR 描述写入文件后创建 PR（`--body-file` 避免中文与换行的转义问题）：

```bash
ag-cli pr create openeuler/yocto-meta-openeuler \
  --title "<PR 标题（中文）>" \
  --body-file /tmp/pr-body.md \
  --base master \
  --head "<fork用户名>:<branch-name>"
```

- 必须显式传入 `openeuler/yocto-meta-openeuler`：本仓库通常同时存在 `upstream`
  与个人 fork 两个 AtomGit 远端，省略仓库参数会导致推断不明确。
- 跨 fork PR 的 `--head` 使用 `<fork用户名>:<分支名>`，ag-cli 会自动转换为
  AtomGit API 所需的 `<用户名>/<仓库>:<分支>` 格式。
- 需要草稿 PR 时追加 `--draft`。

成功输出示例：

```
Created PR #123: https://atomgit.com/openeuler/yocto-meta-openeuler/pull/123
```

**PR 格式约定：**

- Commit 消息：**英文**（已在提交中）
- PR 标题与描述：**中文**
- AI 协助生成的提交，PR 与 Commit Message **必须**包含 Agent 元数据（见下）

**元数据填写要求**（依据 openEuler 社区生成式AI工具使用与开源贡献策略，
来源：<https://www.openeuler.openatom.cn/zh/community/ai-coding-assistants/>）：

- Agent平台信息（Tool）：**平台名称及版本**，取当前会话实际使用的 Agent
  平台（如 `<Agent平台名称及版本>`），不得照抄历史或示例
- 模型信息（Model）：**模型名称及版本**，取当前会话实际使用的模型
  （如 `<AI模型名称及版本>`）；平台与模型信息均必须**每次提交时动态
  确定**，不得照抄历史 commit 或文档示例中的名称——平台与模型会更换，
  历史信息不一定正确；无法确定时先向用户确认再提交
- Prompt摘要：简要概述核心提示词或核心意图
- **一致性门禁**：Commit Message 中 `Co-Authored-By` 的模型信息必须与 PR
  披露的模型信息一致，不一致会被社区门禁拦截

**PR 描述模板：**

```
## 背景

<背景说明，为什么要做这个改动>

## 改动说明

1. <改动点1>
2. <改动点2>

## 影响范围

- <影响的目标/平台>

## 测试建议

<如何验证改动正确>

### 当前PR是否有AI参与:
- [ ]  否

- [x]  是
__1. Agent平台信息: <Agent平台名称及版本>
__2. 模型信息: <AI模型名称及版本>
__3. Prompt摘要: <核心提示词或核心意图>

### 希望检视人员了解:
1. 代码由AI辅助开发者编写，且开发者已人工逐行核对逻辑、校验功能正确性，且与开发者预期一致；
```

**Commit Message 元数据：**

AI 协助生成的提交必须在 Footer 中追加（`Signed-off-by` 仍为最后一行），
模型名称及版本与 PR 元数据一致，取**本次提交动态确定**的当前会话模型：

```
Co-Authored-By: <本次提交实际使用的AI模型名称及版本>
```

---

### 第 5 步 — 验证 PR

```bash
ag-cli pr view openeuler/yocto-meta-openeuler <PR编号>
ag-cli pr checks openeuler/yocto-meta-openeuler <PR编号> --watch
```

---

## PR 创建之后

确认 PR 链接与内容无误后，切回 master 继续后续工作：

```bash
git checkout master
```

---

## 常见问题

| 问题 | 原因 | 解决方法 |
|---|---|---|
| `ag-cli: command not found` | 未安装 CLI，或用户级安装目录不在 PATH | 按第 4 步安装；用户级安装时检查 `~/.local/bin` 是否在 PATH |
| `No local credentials` | 未登录 AtomGit | 执行 `ag-cli auth login` 后重试 |
| PR 建到了个人 fork 仓库 | 省略仓库参数导致推断到个人远端 | 显式传入 `openeuler/yocto-meta-openeuler` |
| `Branch not found` | 分支未推送到 fork，或 `--head` 用户名/分支名有误 | 先 push，再用 `git remote -v` 核对 fork 用户名 |
| Commit 包含无关改动 | 从本地 master 建分支 | 始终从 `upstream/master` 建分支 |

---

## 检查清单

- [ ] 分支从 `upstream/master` 创建（而非本地 master）
- [ ] 仅 cherry-pick 了相关提交
- [ ] 分支已推送到个人 fork 远端
- [ ] `ag-cli` 已安装且已登录（`ag-cli auth status` 通过）
- [ ] 创建命令显式指定了上游仓库与 `--head <fork用户名>:<分支名>`
- [ ] 已用 `ag-cli pr view` 确认 PR 链接与内容
- [ ] PR 标题为中文
- [ ] PR 描述包含：背景、改动说明、影响范围、测试建议
- [ ] PR 描述包含 AI 参与声明与 Agent 元数据（Agent平台信息**含版本号**、模型信息、Prompt摘要，均为本次动态确定）
- [ ] PR 披露的模型信息与 Commit Message 的 `Co-Authored-By` **一致**（门禁要求）
- [ ] 模型信息为**本次提交动态确定**（非历史 commit / 文档示例照抄）
- [ ] Commit Message 包含 `Co-Authored-By`（AI 协助生成时）
- [ ] PR 创建后已切回 master
