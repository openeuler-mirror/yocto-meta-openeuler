---
name: branch-infra-adapt
description: '拉取新版本分支并适配分支基础设施（infra adaptation）。当用户要求"拉一个 XX 分支"、"创建 openEuler-X 分支"、"适配分支基础设施/构建环境"、"新版本分支工程适配"时触发。覆盖：env.yaml 容器标签、samples 镜像名、workflows/init_env.groovy 环境参数、镜像脚本克隆分支、Dockerfile 基础镜像引用的同步修改，以及提交 PR 到上游分支。触发关键词：拉分支、新分支、版本分支、适配基础设施、adapt branch、release branch、env.yaml、init_env、容器镜像标签、26.09、24.03-LTS-Next。'
argument-hint: "分支名，例如 'openEuler-26.09'"
---

# Skill: branch-infra-adapt — 新版本分支基础设施适配

为 openEuler Embedded 新版本分支（如 `openEuler-26.09`）完成工程基础设施适配。
参照基线：`openEuler-24.03-LTS-Next` 分支的历史适配 + `openEuler-26.09` 的完整实践。

**输入**：分支名（如 `openEuler-26.09`）。由分支名推导版本标签：
`openEuler-<X>` → docker tag `<x>`（小写、去前缀，如
`openEuler-24.03-LTS-Next` → `24.03-lts-next`，`openEuler-26.09` → `26.09`）。

---

## 第 0 步：前置确认

1. `git fetch upstream`，确认基于最新 `upstream/master` 拉分支：
   ```bash
   git checkout -b <branch> upstream/master
   git push origin <branch> -u
   ```
2. 检查上游是否已存在同名分支（决定 PR base 是否可用）：
   ```bash
   git ls-remote upstream refs/heads/<branch>
   ```
   上游已有该分支时，PR 直接以其为 base；没有时先完成改动，PR base 仍填
   `<branch>`（发布侧创建后可合入）。
3. 与用户确认外部镜像依赖现状（见文末"外部依赖清单"），不存在的依赖
   属预期（分支建好后由本分支流水线产出/GA 发布），但需在 PR 中注明。

## 第 1 步：`.oebuild/env.yaml` — 容器标签（3 行）

```yaml
docker_tag: "latest"                → "<tag>"
docker_image: "...openeuler-container:latest"  → "...openeuler-container:<tag>"
sdk_docker_image: "...openeuler-sdk:latest"    → "...openeuler-sdk:<tag>"
```

**不要动**：各 arch 的 toolchain_md5 / runtime_md5（工具链内容未变）。

## 第 2 步：`.oebuild/samples/` — 全部 sample 的容器镜像名

对 57 个（以实际 grep 为准）sample yaml 统一替换：

```bash
grep -rln "openeuler-container:latest" .oebuild/samples/ \
  | xargs sed -i 's|openeuler-container:latest|openeuler-container:<tag>|'
```

## 第 3 步：`.oebuild/workflows/init_env.groovy` — CI 环境参数（5 处）

| 参数 | master 默认值 | 分支值 |
|---|---|---|
| `env.yoctoBranch` | `"master"` | `"<branch>"` |
| `env.ciBranch` | `"master"` | `"<branch>"` |
| `env.openEulerImgRemoteDir` | `"/data/logs/packages/master"` | `"/data/logs/packages/<branch>"` |
| `env.baseImgUrl` | `.../packages/master` | `.../packages/<branch>` |
| `env.targetImgUrl` | `.../dailybuild/EBS-openEuler-Mainline/embedded_img` | `.../dailybuild/EBS-<branch>/embedded_img` |

**不要动**：`env.embeddedBranch`、`env.mugenBranch`（保持 `master`，
Next/26.09 分支均未改）。

## 第 4 步：镜像脚本中的克隆分支

`meta-openeuler/recipes-core/images/files/oebridge-extra-command-ibrobot.sh`
等会 `git clone -b master` 打包仓库的脚本，改为 `-b <branch>`：
```bash
git clone -b master --single-branch --depth 1 https://atomgit.com/openeuler/IB_Robot.git
                → -b <branch>
```
排查方法：`grep -rn 'clone -b master' meta-openeuler/ bsp/ rtos/`。

## 第 5 步：Dockerfile 基础镜像同步（3 个文件）

| 文件 | 改动 |
|---|---|
| `.oebuild/dockerfile/openeuler-container/Dockerfile_CI` | `FROM ...openeuler-container:latest` → `:<tag>` |
| `.oebuild/dockerfile/openeuler-sdk/Dockerfile_CI` | `FROM ...openeuler-sdk:latest` → `:<tag>` |
| `.oebuild/dockerfile/openeuler-container/Dockerfile_IBRobot` | `ARG BASE_URL=.../EBS-openEuler-Mainline/...` → `EBS-<branch>`；两阶段 `FROM hub.oepkgs.net/openeuler/openeuler:24.03` → `openeuler:<版本>` |

**不要动**：`openeuler-container/Dockerfile`（工具链基础镜像，OS 基础与
release 资产版本由工具链发布流水线管理）、`Dockerfile_Docs_CI` 的 OS 基础。

## 第 6 步：验证

1. `python3 -c "import yaml; yaml.safe_load(open('.oebuild/env.yaml'))"`（YAML 合法性）
2. `grep -rn "openeuler-container:latest" .oebuild/samples/ | wc -l` 应为 0
3. init_env.groovy 5 处替换逐一核对（每处应恰好出现 1 次）
4. 外部依赖可用性探测（结果记入 PR，不存在的注明"待产出"）：
   ```bash
   docker manifest inspect swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:<tag>
   docker manifest inspect hub.oepkgs.net/openeuler/openeuler:<version>
   ```

## 第 7 步：提交与 PR

- 遵循 [git-commit](../git-commit) 与 [send-pr](../send-pr) 技能：
  commit 标题建议 `oebuild: adapt environment for the <branch> branch`，
  body 分点列出 4 类改动，`Co-Authored-By` + `Signed-off-by` 收尾。
- PR：head = fork 的 `<branch>`，base = 上游 `<branch>`。
- PR 描述注明外部依赖状态（如"SWR `<tag>` 标签由本分支流水线产出；
  oepkgs `openeuler:<版本>` 随 GA 发布"）。
- Dockerfile 同步类改动若与主适配分属两个提交，可分次 PR（先合主适配）。

---

## 外部依赖清单（分支 CI 完整跑通的前提）

| 依赖 | 产出方 | 探测命令 |
|---|---|---|
| SWR `openeuler-container:<tag>` | 本分支容器构建流水线（`jenkinsfile_container_build`） | `docker manifest inspect` |
| SWR `openeuler-sdk:<tag>` | 本分支 SDK 构建流水线 | 同上 |
| oepkgs `openeuler:<version>` OS 镜像 | openEuler 版本 GA 发布 | 同上 |
| EBS `dailybuild/EBS-<branch>/` 路径 | 本分支 CI 首轮镜像构建产出 | curl 目录列表 |
| release 资产（toolchains-* 等） | 既有 release 复用；缺失需补传 | `curl -sL .../merge_data.sh` |

## 已知坑（26.09 实践沉淀）

1. **release 资产缺失**：`llvm-toolchain-v0.1.1` 曾缺 `merge_data.sh` 导致
   容器构建 404。修复方式：按 `toolchains-v0.1.8` 的原版风格（仅 cat 合并
   分卷 + rm 分卷，**不解压**——Dockerfile 自己 tar）补写脚本并以 **LF 换行**
   上传；CRLF 会导致 `$'\r': command not found`。
2. **Docker 层缓存掩盖问题**：CI/本地构建命中旧缓存时不重新下载资产，
   26.09 已为全部容器构建 workflow 加 `--no-cache`（新分支合入后自动生效）。
3. **分卷合并脚本不通用**：v0.1.2 的 merge_data.sh 自带解压+删合并包，
   与 Dockerfile 中"脚本后再 tar zxf"的流程不兼容；补传脚本必须与
   Dockerfile 调用时序匹配。
4. **基础镜像标签先有鸡还是先有蛋**：Dockerfile_CI 的 `FROM :<tag>` 依赖
   本分支先产出基础镜像——容器构建 job 的顺序是先 Dockerfile（基础镜像）
   再 Dockerfile_CI（CI 镜像），正常流水线顺序执行即可。
