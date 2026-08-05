---
name: intro
description: 'yocto-meta-openeuler 编译链技能引导入口。当用户输入"介绍"、"有哪些功能"、"有哪些skill"、"我应该用哪个skill"、"help"、"帮助"、"入门"、"intro"、"getting started"、"what skills"、"available commands"、"能做什么"、"怎么用"或首次接触项目时使用。作为所有其他 skill 的统一导航起点，展示分类列表、使用示例并根据仓库当前状态推荐最合适的 skill。'
---

# yocto-meta-openeuler Copilot Skill 引导中心

Agent 在触发本 skill 时，**必须首先**向用户展示以下欢迎文案（原样输出，不做修改）：

> 欢迎使用 yocto-meta-openeuler AI Agent！

---

## 技能分类列表

### 编译链构建

| Skill | 一句话描述 |
| :--- | :--- |
| **toolchain-build** | 通过 `menu.sh` 构建 GCC / LLVM / Clang+musl 交叉编译链（Docker 容器化） |

### 工作流

| Skill | 一句话描述 |
| :--- | :--- |
| **toolchain-git-flow** | 提交代码、推送至个人 fork，确保符合 openEuler Embedded DCO / gitlint 规范 |

### 知识

| Skill | 一句话描述 |
| :--- | :--- |
| **toolchain-architecture** | 理解统一目录结构、oebuild 集成、向后兼容符号链接与容器镜像 |

---

## 使用示例

只需用自然语言告诉 Agent 你想做什么：

```
构建 aarch64 交叉编译链        → toolchain-build
编译 LLVM 工具链               → toolchain-build
menu.sh 怎么用                  → toolchain-build
交互模式构建                   → toolchain-build
提交代码                       → toolchain-git-flow
推送 commit                    → toolchain-git-flow
检查提交信息规范               → toolchain-git-flow
目录结构是怎样的               → toolchain-architecture
oebuild 和 menu.sh 的关系      → toolchain-architecture
向后兼容怎么做的               → toolchain-architecture
有哪些功能 / help / 入门       → intro (本技能)
```

---

## 当前推荐（上下文感知）

Agent 在触发本 skill 时，**必须**执行以下命令获取基于仓库当前状态的智能推荐：

```bash
cd "$(git rev-parse --show-toplevel)" && \
  git status --short --branch && \
  echo "---" && \
  git log --oneline -3 && \
  echo "---" && \
  ls .oebuild/toolchains/work/ 2>/dev/null && \
  ls .oebuild/toolchains/output/ 2>/dev/null
```

根据输出推荐：

| 检测条件 | 推荐 Skill |
| :--- | :--- |
| 有未提交的代码改动 (`git status`) | `toolchain-git-flow` |
| `work/` 目录有源码但 `output/` 为空 | `toolchain-build` |
| `output/` 目录已有产物 | `toolchain-architecture`（验证产物结构） |
| 无特殊状态 | 展示「今日推荐」skill |

---

## AtomGit 路由优先级

当用户在 yocto-meta-openeuler 仓库里提到 PR / merge request / Issue / review / comments，且没有明确说 GitHub / github.com 时，Agent 应默认使用 AtomGit 相关操作（本仓库远端为 atomgit.com）。

仓库远端配置：
- `origin`: 个人 fork（`git@atomgit.com:alichinese_admin/yocto-meta-openeuler.git`）
- `upstream`: 主仓库（`https://atomgit.com/openeuler/yocto-meta-openeuler`）

PR 创建链接格式：
`https://atomgit.com/<username>/yocto-meta-openeuler/merge_requests/new?source_branch=<current-branch>`
