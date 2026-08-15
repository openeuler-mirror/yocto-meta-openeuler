# AI Agent 技能库 (Skills)

此目录包含了专为 AI Agent（如 Claude Code、Gemini CLI、OpenCode 等）设计的
技能插件，用于自动化 yocto-meta-openeuler 编译链项目的开发工作流。每个技能
都定义了精准的触发条件（Description），并提供了执行复杂任务所需的工具和上下文。

## 技能清单

| 技能名称 | 分类 | 主要触发场景 (Triggers) |
| --- | --- | --- |
| [intro](intro) | 引导 | 「介绍」「有哪些功能」「help」「入门」「intro」等，作为所有 skill 的导航入口。 |
| [oebuild](oebuild) | 构建 | oebuild init/update/generate/bitbake/runqemu 等构建流程，Docker 容器、compile.yaml 配置。 |
| [send-pr](send-pr) | 工作流 | 向上游仓库提交 PR，从 upstream 建分支、cherry-pick、推送 fork、GitCode API 创建 PR。 |
| [yocto-openeuler-recipe](yocto-openeuler-recipe) | 构建 | 新增/更新/分析 BitBake recipe 与 bbappend，SRC_URI file:// 适配、补丁合并。 |
| [sstate-cache-debug](sstate-cache-debug) | 构建 | 诊断 sstate-cache 未命中，bitbake-diffsigs 对比签名、machine conf 误用 export 导致 native 哈希污染。 |
| [ibrobot-test](ibrobot-test) | 构建/测试 | 构建 qemu-aarch64 镜像(oebridge/ibrobot/systemd)+ 跨平台测试 IB-Robot(qemu 无 NPU / 真机昇腾):setup/build、`run_tests.sh`(组件单测/colcon + `inference` 推理闭环冒烟,ACT 模型 zip)、torch_npu/ROS domain/跳过包互导/resnet18 等典型失败诊断。 |
| [toolchain-build](toolchain-build) | 构建 | 构建 GCC/LLVM/Clang+musl 交叉编译链，`menu.sh`、`ct-ng build`、容器构建等。 |
| [toolchain-git-flow](toolchain-git-flow) | 工作流 | 提交代码、推送至个人 fork，确保符合 openEuler DCO/Commit 规范。 |
| [git-commit](git-commit) | 工作流 | 编写符合 openEuler 规范的 commit message：标题格式、正文 why/what、Signed-off-by。 |
| [toolchain-architecture](toolchain-architecture) | 知识 | 理解统一目录结构、oebuild 集成、向后兼容符号链接与容器镜像设计。 |
| [sdk-verify](sdk-verify) | 构建/测试 | 验证 SDK（do_populate_sdk 产物）是否支持内核驱动与用户态 C/C++ 开发，一键交叉编译 + QEMU 运行验证，覆盖 qemu-aarch64/qemu-arm/qemu-riscv64。 |

---

## 技能分类说明

### 引导入口

- **技能导航 ([intro](intro))**: 所有 skill 的统一入口，展示分类列表与使用示例，
  并根据仓库状态智能推荐最合适的 skill。

### 构建

- **oebuild 构建工具 ([oebuild](oebuild))**: 管理 OpenEuler Embedded 的
  构建全流程——init/update/generate/bitbake/manifest/runqemu 等命令、
  Docker 容器生命周期、compile.yaml 配置与 inotify 限制等。
- **Recipe 适配 ([yocto-openeuler-recipe](yocto-openeuler-recipe))**:
  新增/更新/分析 BitBake recipe 与 bbappend，定位 src-openeuler 源码、
  适配 file:// 风格 SRC_URI、合并 openEuler 与上游补丁并验证构建。
- **编译链构建 ([toolchain-build](toolchain-build))**: 通过 `menu.sh` 构建
  GCC / LLVM / Clang+musl 三类交叉编译链，自动管理 Docker 容器（镜像检测、
  UID 匹配、目录挂载、CT_PREFIX 安装控制）。
- **sstate 缓存调试 ([sstate-cache-debug](sstate-cache-debug))**: 诊断
  sstate-cache 未命中与 native 任务意外重建，用 `bitbake -S none` 生成
  sigdata、`bitbake-diffsigs` 对比任务签名、定位 machine conf 误用 `export`
  导致的哈希污染并修复。
- **IB-Robot 跨平台测试 ([ibrobot-test](ibrobot-test))**:
  构建 qemu-aarch64 镜像（`oebridge`+`ibrobot`+`systemd`）、创建 100G 大容量磁盘作根盘、从盘启动 qemu，并在 guest 内完成 IB-Robot 的
  `setup.sh`/`build.sh`/`run_tests.sh` 功能测试（组件单测/colcon + `inference` 推理闭环冒烟，ACT 模型 zip）；区分 qemu（无 NPU，`TORCH_DEVICE_BACKEND_AUTOLOAD=0`）与真机（Ascend+CANN，torch_npu 可用，跑完整 ACT 推理闭环）；覆盖 `torch_npu` 自动加载、
  ROS 域守卫、跳过包互导、`colcon test` 误报、resnet18 离线缓存等典型失败的诊断与修复。
- **SDK 验证 ([sdk-verify](sdk-verify))**: 端到端验证 SDK 安装包能力——用
  一键脚本自动完成 SDK 安装、用户态 C/C++ 交叉编译、内核驱动模块编译
  （kernel-devsrc），经 `oebuild runqemu nographic` 启动 qemu 镜像并
  scp 传输产物、SSH 登录运行验证（insmod + 运行测试程序），覆盖
  qemu-aarch64/qemu-arm/qemu-riscv64，用于 SDK 生成或内容改动后的
  快速回归。

### 工作流

- **提交 PR ([send-pr](send-pr))**: 向 GitCode/AtomGit 上游仓库提交 PR，
  从 `upstream/master` 创建功能分支、cherry-pick 提交、推送到 fork、
  通过 GitCode API 创建中文 PR。
- **Git 工作流 ([toolchain-git-flow](toolchain-git-flow))**: 自动化执行
  openEuler Embedded 繁琐的提交规范校验（DCO sign-off、gitlint 规则），
  覆盖暂存、提交、推送、PR 描述生成全流程。
- **Commit Message 规范 ([git-commit](git-commit))**: 提供 openEuler
  commit message 的格式与写作规范——标题 `scope: subject`、正文 why/what
  原则、Signed-off-by、单一逻辑变更拆分与批量改写。

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

## AtomGit / GitCode 集成

本仓库远端为 AtomGit（atomgit.com），上游 PR 通过 GitCode 平台创建。

远端配置因开发者而异，操作前用 `git remote -v` 确认：

- `upstream`：主仓库 `openeuler/yocto-meta-openeuler`
- 个人 fork：远端名（如 `origin`、`myrepo`）与用户名因人而异

PR 创建链接格式（GitCode）：
```
https://gitcode.com/<username>/yocto-meta-openeuler/merge_requests/new?source_branch=<branch>
```

如需 API 集成，可参考 `send-pr` 技能中的 GitCode API v5 用法。

所有符合 Agent Skills 标准的客户端都会自动扫描 `.agents/skills/`，
详见 [agentskills.io](https://agentskills.io)。
