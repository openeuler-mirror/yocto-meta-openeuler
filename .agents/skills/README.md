# AI Agent 技能库 (Skills)

此目录包含了专为 AI Agent（如 Claude Code、Gemini CLI、OpenCode 等）设计的
技能插件，用于自动化 yocto-meta-openeuler 编译链项目的开发工作流。每个技能
都定义了精准的触发条件（Description），并提供了执行复杂任务所需的工具和上下文。

## 技能清单

| 技能名称 | 分类 | 主要触发场景 (Triggers) |
| --- | --- | --- |
| [intro](intro) | 引导 | 「介绍」「有哪些功能」「help」「入门」「intro」等，作为所有 skill 的导航入口。 |
| [toolchain-build](toolchain-build) | 构建 | 构建 GCC/LLVM/Clang+musl 交叉编译链，`menu.sh`、`ct-ng build`、容器构建等。 |
| [toolchain-git-flow](toolchain-git-flow) | 工作流 | 提交代码、推送至个人 fork，确保符合 openEuler DCO/Commit 规范。 |
| [toolchain-architecture](toolchain-architecture) | 知识 | 理解统一目录结构、oebuild 集成、向后兼容符号链接与容器镜像设计。 |

---

## 技能分类说明

### 引导入口

- **技能导航 ([intro](intro))**: 所有 skill 的统一入口，展示分类列表与使用示例，
  并根据仓库状态智能推荐最合适的 skill。

### 编译链构建

- **编译链构建 ([toolchain-build](toolchain-build))**: 通过 `menu.sh` 构建
  GCC / LLVM / Clang+musl 三类交叉编译链，自动管理 Docker 容器（镜像检测、
  UID 匹配、目录挂载、CT_PREFIX 安装控制）。

### 工作流

- **Git 工作流 ([toolchain-git-flow](toolchain-git-flow))**: 自动化执行
  openEuler Embedded 繁琐的提交规范校验（DCO sign-off、gitlint 规则），
  覆盖暂存、提交、推送、PR 描述生成全流程。

### 知识

- **架构顾问 ([toolchain-architecture](toolchain-architecture))**: 充当项目的
  架构师，解答关于统一目录结构、oebuild 集成、向后兼容符号链接、容器镜像
  设计等架构问题。

---

## 如何增加新技能

若要向本项目添加新技能，请遵循以下步骤：

1. 在 `.agents/skills/` 下创建一个新目录。
2. 添加 `SKILL.md` 文件，确保 `description` 字段采用 **if-then** 条件触发风格
   （包含中英双语关键词）。
3. 编写技能所需的配套脚本（Python/Bash）或库文件。
4. 更新此 `README.md` 文件，将新技能添加到清单表格中。

### SKILL.md 格式

```yaml
---
name: <skill-name>
description: "<if-then trigger description with bilingual keywords>"
---

# <Skill Title>

<skill body: instructions, execution steps, troubleshooting, etc.>
```

### 命名与拆分原则

1. **优先按资源/工作流命名**：用 `toolchain-build`、`toolchain-git-flow`，
   不要用 `run-menu` 这类只覆盖一个动词的名字。
2. **description 要覆盖完整生命周期动词**：同一个 skill 的 description 应
   同时包含 build / compile / prepare / verify 等常见动作。
3. **先按"领域 + 资源"拆，再按"专业能力"细分**。
4. **为泛化请求保留引导层**：`intro` 负责导航到具体 skill。

---

## AtomGit 集成

本仓库远端为 AtomGit（atomgit.com），PR / Issue 操作使用 AtomGit 平台。

- `origin`: `git@atomgit.com:alichinese_admin/yocto-meta-openeuler.git`（个人 fork）
- `upstream`: `https://atomgit.com/openeuler/yocto-meta-openeuler`（主仓库）

PR 创建链接格式：
```
https://atomgit.com/<username>/yocto-meta-openeuler/merge_requests/new?source_branch=<branch>
```

如需 AtomGit API 集成，在项目根目录的 `config.json` 中配置 Token：

```json
{
  "atomgit": {
    "token": "$ATOMGIT_TOKEN",
    "owner": "openeuler",
    "repo": "yocto-meta-openeuler",
    "baseUrl": "https://api.atomgit.com"
  }
}
```

设置环境变量：
```bash
export ATOMGIT_TOKEN="your_token_here"
```

所有符合 Agent Skills 标准的客户端都会自动扫描 `.agents/skills/`，
详见 [agentskills.io](https://agentskills.io)。
