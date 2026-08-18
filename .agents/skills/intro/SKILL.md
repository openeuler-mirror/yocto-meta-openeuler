---
name: intro
description: 'yocto-meta-openeuler 编译链技能引导入口。当用户输入"介绍"、"有哪些功能"、"有哪些skill"、"我应该用哪个skill"、"help"、"帮助"、"入门"、"intro"、"getting started"、"what skills"、"available commands"、"能做什么"、"怎么用"或首次接触项目时使用。作为所有其他 skill 的统一导航起点，展示分类列表、使用示例并根据仓库当前状态推荐最合适的 skill。'
---

# yocto-meta-openeuler Copilot Skill 引导中心

Agent 在触发本 skill 时，**必须首先**向用户展示以下欢迎文案（原样输出，不做修改）：

> 欢迎使用 yocto-meta-openeuler AI Agent！

---

## 技能分类列表

### 构建

| Skill | 一句话描述 |
| :--- | :--- |
| **oebuild** | oebuild 构建工具：init/update/generate/bitbake/runqemu 全流程 |
| **yocto-openeuler-recipe** | 新增/更新 BitBake recipe 与 bbappend，file:// SRC_URI 适配 |
| **sstate-cache-debug** | 诊断 sstate-cache 未命中，bitbake-diffsigs 对比签名、export 哈希污染 |
| **toolchain-build** | 通过 `menu.sh` 构建 GCC / LLVM / Clang+musl 交叉编译链（Docker 容器化） |
| **sdk-verify** | 一键验证 SDK：交叉编译 C/C++ + 内核模块，qemu 内 SSH 验证 |
| **ibrobot-test** | IB-Robot 跨平台测试：qemu-aarch64（无 NPU）/ 真机昇腾（ACT 推理闭环） |

### 工作流

| Skill | 一句话描述 |
| :--- | :--- |
| **send-pr** | 从 upstream 建分支、推送 fork、通过 GitCode API 向上游提交 PR |
| **toolchain-git-flow** | 提交代码、推送至个人 fork，确保符合 openEuler Embedded DCO / gitlint 规范 |
| **git-commit** | 编写符合 openEuler 规范的 commit message（标题、正文、Signed-off-by） |

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
写/改 commit message           → git-commit
提交标题正文怎么写             → git-commit
目录结构是怎样的               → toolchain-architecture
oebuild 和 menu.sh 的关系      → toolchain-architecture
向后兼容怎么做的               → toolchain-architecture
如何构建 openeuler-image       → oebuild
更新/生成构建配置              → oebuild
新增/更新 recipe               → yocto-openeuler-recipe
bbappend / SRC_URI 适配        → yocto-openeuler-recipe
sstate 缓存未命中/意外重建      → sstate-cache-debug
native 任务哈希不一致           → sstate-cache-debug
验证 SDK / 内核模块编译        → sdk-verify
IB-Robot 测试 / 推理闭环       → ibrobot-test
发送 PR 到上游                 → send-pr
创建 merge request             → send-pr
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

## 远端路由优先级

当用户在 yocto-meta-openeuler 仓库里提到 PR / merge request / Issue / review /
comments，且没有明确说 GitHub / github.com 时，Agent 应默认使用 GitCode/AtomGit
相关操作。

仓库远端配置因开发者而异（`upstream` 指主仓库，个人 fork 远端名与用户名
因人而异），涉及推送或 PR 的操作前**必须**先运行 `git remote -v` 确认实际
配置。完整 PR 流程见 `send-pr` 技能。
