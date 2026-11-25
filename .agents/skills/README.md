# AI Agent 技能库 (Skills)

本目录包含 yocto-meta-openeuler 仓库的 AI Agent 技能（遵循 Agent Skills 标准），
配套的专业 Agent 定义在 [../agents/](../agents/)。每个技能通过 frontmatter 的
`description` 声明触发条件，并附带执行所需的脚本与参考资料。

本文件中的技能清单是**唯一清单来源**；`intro` 技能只做导航与推荐，不再重复
列表。

## 技能清单

| 技能名称 | 分类 | 一句话描述 | 主要触发场景 (Triggers) |
| --- | --- | --- | --- |
| [intro](intro) | 引导 | 技能导航入口，按仓库状态推荐技能 | 「介绍」「有哪些功能」「help」「入门」「intro」等。 |
| [oebuild](oebuild) | 构建 | openEuler Embedded 构建全流程与容器环境管理 | oebuild init/update/generate/bitbake/runqemu，Docker 容器、compile.yaml 配置。 |
| [yocto-openeuler-recipe](yocto-openeuler-recipe) | 构建 | BitBake recipe 新增/更新/分析，openEuler 源码适配 | 新增/更新 recipe 与 bbappend，SRC_URI file:// 适配、补丁合并。 |
| [yocto-openeuler-patch-analysis](yocto-openeuler-patch-analysis) | 构建 | 多来源补丁分析与融合（src-openeuler + yocto + 本层），配合 yocto-openeuler-recipe | 补丁分类/取舍、冲突/重复/死补丁检测、patch-fuzz 消除、do_patch 顺序与验证。 |
| [toolchain-build](toolchain-build) | 构建 | 通过 `menu.sh` 构建 GCC/LLVM/Clang+musl 交叉编译链 | `menu.sh`、`ct-ng build`、容器构建、产物验证。 |
| [sstate-cache-debug](sstate-cache-debug) | 构建 | 诊断 sstate-cache 未命中与 native 意外重建 | bitbake-diffsigs 对比签名、machine conf 误用 export 哈希污染。 |
| [sdk-verify](sdk-verify) | 构建/测试 | 一键验证 SDK（do_populate_sdk 产物）的内核驱动与 C/C++ 交叉编译能力 | SDK 生成或改动后的回归验证，覆盖 qemu-aarch64/qemu-arm/qemu-riscv64。 |
| [ibrobot-test](ibrobot-test) | 构建/测试 | IB-Robot 跨平台功能测试（qemu 无 NPU / 真机昇腾） | 构建 oebridge/ibrobot/systemd 镜像、100G 大磁盘从盘启动、run_tests/inference 推理闭环。 |
| [serial-ssh-debug](serial-ssh-debug) | 测试/调试 | 真机板卡串口登录调试与 SSH 登录调试，串口托底判启动链与网络就绪，网络可用时切 SSH | 串口登录、ttyUSB、板子连不上、TF-A/U-Boot 启动日志、SSH 登录、板上验证、网络就绪判定。 |
| [send-pr](send-pr) | 工作流 | 向 AtomGit 上游仓库提交 PR | 从 upstream 建分支、cherry-pick、推送 fork、ag-cli 创建并验证 PR。 |
| [branch-infra-adapt](branch-infra-adapt) | 工作流 | 拉取新版本分支并适配分支基础设施 | 「拉 XX 分支」「适配基础设施」「版本分支工程适配」：env.yaml 容器标签、samples 镜像名、init_env 参数、镜像脚本克隆分支、Dockerfile 基础镜像同步及 PR 提交。 |
| [toolchain-git-flow](toolchain-git-flow) | 工作流 | Git 提交与推送全流程（适用于全仓库），强制 DCO/gitlint 规范 | 提交代码、推送、检查提交信息、修复 gitlint 报错。 |
| [git-commit](git-commit) | 工作流 | commit message 格式与写作规范 | 标题/正文/签名、Co-Authored-By AI 元数据、单一逻辑变更拆分。 |
| [toolchain-architecture](toolchain-architecture) | 知识 | 编译链目录结构、oebuild 集成与向后兼容设计 | 目录结构、符号链接、容器镜像设计、工作原理。 |

> 各技能的详细触发关键词见各自 `SKILL.md` 的 `description` 字段。

## 专业 Agent

位于 [../agents/](../agents/)。用于深度诊断：客户端支持 subagent 时按 frontmatter
调用，否则把 `.agent.md` 正文作为提示词使用。

| Agent | 职责 |
| --- | --- |
| [recipe-analyzer](../agents/recipe-analyzer.agent.md) | recipe/bbclass/变量溯源静态分析 |
| [rootfs-expert](../agents/rootfs-expert.agent.md) | rootfs 构建与 image 生成 |
| [kernel-debugger](../agents/kernel-debugger.agent.md) | 内核启动/panic/设备树调试 |
| [sstate-optimizer](../agents/sstate-optimizer.agent.md) | sstate 缓存与构建性能 |

---

## 如何增加新技能

1. 在 `.agents/skills/` 下创建目录 `<skill-name>/`（小写字母、数字、连字符）。
2. 添加 `SKILL.md`：frontmatter 必须含 `name`（与目录名一致）与 `description`
   （"当…时使用"+ 中英双语关键词，**不超过 1024 字符**）；可选 `argument-hint`。
3. 主体只写流程与判定标准。长案例与环境细节放到同目录的 `reference.md`（按需
   加载，见 `serial-ssh-debug`、`yocto-openeuler-patch-analysis` 的写法），
   可执行脚本放到 `scripts/`，正文里用相对技能目录的路径引用。
4. 更新本文件的技能清单表格。`intro` 不需要同步（它指向本文件）。

### SKILL.md 格式

```yaml
---
name: <skill-name>
description: "<当…时使用 + 中英双语关键词>"
# 可选
argument-hint: "<一句话示例>"
---

# <Skill Title>

<流程、判定标准、故障排查；细节引用 reference.md / scripts/>
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

本仓库远端为 AtomGit（atomgit.com），上游 PR 通过 `ag-cli` 创建。远端配置因
开发者而异，操作前用 `git remote -v` 确认（`upstream` 指主仓库，个人 fork 远端
名与用户名因人而异）。完整 PR 流程见 [send-pr 技能](send-pr/SKILL.md)。

所有符合 Agent Skills 标准的客户端都会自动扫描 `.agents/skills/`，
详见 [agentskills.io](https://agentskills.io)。