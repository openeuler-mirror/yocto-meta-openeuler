---
name: send-pr
description: '向 yocto-meta-openeuler 上游仓库提交 PR 时使用。覆盖从 upstream 创建功能分支、cherry-pick 提交、推送到 fork、通过 GitCode API 创建 PR。触发关键词：PR、pull request、upstream、merge request、发送 PR、创建 PR、提交到上游。'
argument-hint: "要发送的 commit SHA 或分支名，例如 '22df813' 或 'qemu-remove-boot'"
---

# Skill: send-pr — 向上游提交 Pull Request

本技能处理向 GitCode/AtomGit 上的 openEuler 上游仓库提交 PR 的完整工作流。

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

### 第 4 步 — 通过 API 创建 PR

使用 GitCode API 和 private-token 认证（token 从环境变量 `GITCODE_TOKEN` 读取，
无需手动输入；若未配置先执行 `export GITCODE_TOKEN=<token>`）：

```bash
curl -s -X POST "https://gitcode.com/api/v5/repos/openeuler/yocto-meta-openeuler/pulls" \
  -H "Content-Type: application/json" \
  -H "private-token: $GITCODE_TOKEN" \
  -d '{
    "title": "<PR 标题（中文）>",
    "body": "<PR 描述（中文）>",
    "head": "<fork用户名>:<branch-name>",
    "base": "master"
  }'
```

**PR 格式约定：**

- Commit 消息：**英文**（已在提交中）
- PR 标题与描述：**中文**
- AI 协助生成的提交，PR 与 Commit Message **必须**包含 Agent 元数据（见下）

**元数据填写要求**（依据 openEuler 社区生成式AI工具使用与开源贡献策略，
来源：<https://www.openeuler.openatom.cn/zh/community/ai-coding-assistants/>）：

- Agent平台信息（Tool）：**平台名称及版本**，如 `Qoder 1.8.1`、`Claude Code 2.1.156`
- 模型信息（Model）：**模型名称及版本**，如 `DeepSeek-V4-Flash`、`GPT-4o`
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
- [ ] 否
- [x] 是
  1. Agent平台信息: <Agent平台名称及版本>
  2. 模型信息: <AI模型名称及版本>
  3. Prompt摘要: <核心提示词或核心意图>

### 希望检视人员了解:
1. 代码由AI辅助开发者编写，且开发者已人工逐行核对逻辑、校验功能正确性，且与开发者预期一致；
```

**Commit Message 元数据：**

AI 协助生成的提交必须在 Footer 中追加（`Signed-off-by` 仍为最后一行）：

```
Co-Authored-By: <AI模型名称及版本>
```

---

## API 响应

成功响应包含：

- `web_url`: PR 链接（如 https://gitcode.com/openeuler/yocto-meta-openeuler/merge_requests/XXXX）
- `number`: PR 编号
- `state`: "opened"

---

## PR 创建之后

切回 master 继续后续工作：

```bash
git checkout master
```

---

## 常见问题

| 问题 | 原因 | 解决方法 |
|---|---|---|
| `404 token not found` | 认证格式错误 | 使用 `-H "private-token: $GITCODE_TOKEN"` 请求头 |
| `Invalid header parameter: private-token` | token 位置错误 | token 必须在请求头，不能放在 body |
| `Branch not found` | 分支未推送到 fork | 先执行 `git push <fork远端名> <branch>` |
| Commit 包含无关改动 | 从本地 master 建分支 | 始终从 `upstream/master` 建分支 |

---

## 检查清单

- [ ] 分支从 `upstream/master` 创建（而非本地 master）
- [ ] 仅 cherry-pick 了相关提交
- [ ] 分支已推送到个人 fork 远端
- [ ] PR 标题为中文
- [ ] PR 描述包含：背景、改动说明、影响范围、测试建议
- [ ] PR 描述包含 AI 参与声明与 Agent 元数据（Agent平台信息**含版本号**、模型信息、Prompt摘要）
- [ ] PR 披露的模型信息与 Commit Message 的 `Co-Authored-By` **一致**（门禁要求）
- [ ] Commit Message 包含 `Co-Authored-By`（AI 协助生成时）
- [ ] PR 创建后已切回 master
