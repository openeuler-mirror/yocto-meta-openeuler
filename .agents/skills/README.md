# AI Agent 技能库 (Skills)

此目录包含了专为 AI Agent（如 Claude Code、Gemini CLI、OpenCode 等）设计的
技能插件，用于自动化 yocto-meta-openeuler 编译链项目的开发工作流。每个技能
都定义了精准的触发条件（Description），并提供了执行复杂任务所需的工具和上下文。

## 技能清单

| 技能名称 | 分类 | 一句话描述 | 主要触发场景 (Triggers) |
| --- | --- | --- | --- |
| [intro](intro) | 引导 | 所有 skill 的统一导航入口，按仓库状态推荐技能 | 「介绍」「有哪些功能」「help」「入门」「intro」等。 |
| [oebuild](oebuild) | 构建 | OpenEuler Embedded 构建全流程与容器环境管理 | oebuild init/update/generate/bitbake/runqemu，Docker 容器、compile.yaml 配置。 |
| [yocto-openeuler-recipe](yocto-openeuler-recipe) | 构建 | BitBake recipe 新增/更新/分析，openEuler 源码适配 | 新增/更新 recipe 与 bbappend，SRC_URI file:// 适配、补丁合并。 |
| [toolchain-build](toolchain-build) | 构建 | 通过 `menu.sh` 构建 GCC/LLVM/Clang+musl 交叉编译链 | `menu.sh`、`ct-ng build`、容器构建、产物验证。 |
| [sstate-cache-debug](sstate-cache-debug) | 构建 | 诊断 sstate-cache 未命中与 native 意外重建 | bitbake-diffsigs 对比签名、machine conf 误用 export 哈希污染。 |
| [sdk-verify](sdk-verify) | 构建/测试 | 一键验证 SDK（do_populate_sdk 产物）的内核驱动与 C/C++ 交叉编译能力 | SDK 生成或改动后的回归验证，覆盖 qemu-aarch64/qemu-arm/qemu-riscv64。 |
| [ibrobot-test](ibrobot-test) | 构建/测试 | IB-Robot 跨平台功能测试（qemu 无 NPU / 真机昇腾） | 构建 oebridge/ibrobot/systemd 镜像、100G 大磁盘从盘启动、run_tests/inference 推理闭环。 |
| [send-pr](send-pr) | 工作流 | 向 GitCode/AtomGit 上游仓库提交 PR | 从 upstream 建分支、cherry-pick、推送 fork、GitCode API 创建 PR。 |
| [toolchain-git-flow](toolchain-git-flow) | 工作流 | Git 提交与推送全流程，强制 DCO/gitlint 规范 | 提交代码、推送、检查提交信息、修复 gitlint 报错。 |
| [git-commit](git-commit) | 工作流 | commit message 格式与写作规范 | 标题/正文/签名、Co-Authored-By AI 元数据、单一逻辑变更拆分。 |
| [toolchain-architecture](toolchain-architecture) | 知识 | 编译链目录结构、oebuild 集成与向后兼容设计 | 目录结构、符号链接、容器镜像设计、工作原理。 |

> 各技能的详细触发关键词见各自 `SKILL.md` 的 `description` 字段。

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

## AtomGit / GitCode 集成

本仓库远端为 AtomGit（atomgit.com），上游 PR 通过 GitCode 平台创建。
远端配置因开发者而异，操作前用 `git remote -v` 确认（`upstream` 指主仓库，
个人 fork 远端名与用户名因人而异）。完整 PR 流程与 GitCode API 用法见
[send-pr 技能](send-pr/SKILL.md)。

所有符合 Agent Skills 标准的客户端都会自动扫描 `.agents/skills/`，
详见 [agentskills.io](https://agentskills.io)。
