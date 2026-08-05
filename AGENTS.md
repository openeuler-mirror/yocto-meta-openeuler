# AGENTS.md

本文件为 AI Agent（Claude Code、Gemini CLI、OpenCode 等）提供
yocto-meta-openeuler 编译链项目的全局指引。

## 项目概述

yocto-meta-openeuler 是 openEuler Embedded 的 Yocto 元数据层，包含
交叉编译链构建系统。三类编译链（GCC / LLVM / Clang+musl）统一收拢在
`.oebuild/toolchains/` 下，通过 `menu.sh` 提供 Docker 容器化构建入口。

## 仓库结构

```
yocto-meta-openeuler/
├── .agents/                 # AI Agent 技能库
│   └── skills/              # SKILL.md 技能定义（详见 .agents/skills/README.md）
├── .oebuild/
│   ├── toolchains/          # 统一编译链目录
│   │   ├── menu.sh          # 统一构建入口（Bash，Docker 容器化）
│   │   ├── gcc/             # GCC 交叉编译链（crosstool-NG 驱动）
│   │   ├── llvm/            # LLVM 主机工具链
│   │   ├── clang-musl-arm32/ # Clang+musl ARM32 专用编译链
│   │   ├── work/            # 工作目录（gitignore）
│   │   ├── output/          # 产物目录（gitignore）
│   │   └── README.md        # 编译链文档
│   ├── dockerfile/
│   │   └── openeuler-sdk/   # 统一容器镜像 Dockerfile
│   ├── workflows/           # CI jenkinsfile
│   └── manifest.yaml        # oebuild 清单
├── scripts/gitlint/         # openEuler Embedded 提交规范规则
├── .gitlint                 # gitlint 配置
└── config.json              # AtomGit API 集成配置
```

## 远程仓库

- `origin`: `git@atomgit.com:alichinese_admin/yocto-meta-openeuler.git`（个人 fork）
- `upstream`: `https://atomgit.com/openeuler/yocto-meta-openeuler`（主仓库）

## 技能索引

可用技能详见 [.agents/skills/README.md](.agents/skills/README.md)。

| Skill | 用途 |
| --- | --- |
| `intro` | 技能导航入口 |
| `toolchain-build` | 构建 GCC/LLVM/Clang+musl 交叉编译链 |
| `toolchain-git-flow` | 提交/推送代码，DCO 合规 |
| `toolchain-architecture` | 目录结构/oebuild/向后兼容 |

## 关键约束

### 提交规范

- 所有 commit 必须包含 `Signed-off-by`（DCO sign-off）
- 提交信息格式：`<area>: <subject>`（英文，无中文）
- Body 必须解释 why/what，每行 <= 100 字符
- `Signed-off-by` 必须是最后一行
- gitlint 规则见 `.gitlint` 和 `scripts/gitlint/openeuler_embedded_commit_rules.py`

### 构建产物

- `work/` 和 `output/` 目录已 gitignore，不提交仓库
- 不要 `git add .`，只暂存当前任务相关的文件

### 向后兼容

- `.oebuild/cross-tools` → `toolchains/gcc`（符号链接）
- `.oebuild/llvm-toolchain` → `toolchains/llvm`（符号链接）
- `.oebuild/arm32-clang-musl-toolchain` → `toolchains/clang-musl-arm32`（符号链接）
- oebuild Python 包（外部依赖）和 CI jenkinsfile 通过旧路径访问，不可破坏

## Git 用户

- 用户名：`alichinese_admin`
- 邮箱：`lixinyu44@huawei.com`
- Signed-off-by 格式：`Signed-off-by: alichinese_admin <lixinyu44@huawei.com>`
