# GitCode Actions PR 门禁（.gitcode/workflows/）

> **目标读者**：需要修改本门禁的人类或 AI agent。本文覆盖全部已验证的平台事实、
> 设计决策与调试经验，读完即可安全上手。文中所有"已验证"结论均有线上运行日志
> 佐证（2026-11 期间，runner 版本 0.0.11.4）；未验证的假设会显式标注。
>
> 本门禁由 Jenkins 的 `.oebuild/workflows/jenkinsfile_gate` 移植而来，
> 映射关系见 §9。

---

## 1. 这是什么

openEuler Embedded 的 PR 门禁，运行在 GitCode Actions（自托管 k8s runner）上：

| 检查 | job | 耗时 |
|---|---|---|
| 文档构建（Sphinx，`-W` 严格模式） | `build_docs` | ~5 分钟（含环境） |
| 六个镜像构建（qemu-aarch64/arm32、x86-64、hieulerpi1、qemu-riscv64、phytium） | `build_*` | 每个约 1~3 小时（视缓存） |

触发方式：PR open/update/reopen、PR 评论 `/retest`、页面手动 workflow_dispatch。
结果展示在 PR 检查页（由 `associate-pr-comment` 插件关联，仅在 build_docs 的
第一步调用一次即可）。

## 2. 文件清单

```
.gitcode/workflows/
├── README.md                       # 本文件
├── openeuler_embedded_PR_gate.yml  # workflow 定义（7 个 job）
└── scripts/
    ├── checkout_pr.sh              # 双检出：脚本钉 base，PR 代码进 worktree
    ├── build_docs.sh               # 文档构建（切 jenkins 用户 + Sphinx）
    └── build_image.sh              # 镜像构建（oebuild 全流程 + 三重判据）
```

依赖的仓库外资产：

- **CI 容器镜像** `swr.cn-north-4.myhuaweicloud.com/openeuler-embedded-2/openeuler-ci:latest`
  （~20GB）：openEuler 24.03 + oebuild（装在 `/home/jenkins/.local`）+ jenkins
  用户（uid 1001，可免密 sudo）+ 文档工具链。构建自仓库
  `.oebuild/dockerfile/openeuler-container/Dockerfile_CI`（调试期推送到
  `openeuler-embedded-2` 测试镜像站；正式化后应推主站 `openeuler-embedded`）。
- **共享源码缓存** `$GATE_SHARE_DIR`（见 §4.5）。

## 3. 平台已验证事实（修改前必读）

以下结论全部经过线上运行日志实证。**违反这些事实的写法会静默失败或行为错乱**。

### 3.1 步骤永远以 root 执行

`container.options: --user jenkins` 被runner 静默忽略，所有步骤 `id -un` = root。
因此**所有构建脚本必须自行切换到 jenkins 用户**（bitbake/oebuild 拒绝 root）：

```bash
if [ "$(id -un)" != "jenkins" ]; then
    exec runuser -u jenkins -- env ... bash "$0" "$@"
fi
```

见 `checkout_pr.sh` 之外的三个构建脚本头部。root 切用户不需要 sudo，用 `runuser`。

### 3.2 checkout 插件永远检 base 分支，不是 PR

对 PR 事件与评论事件（`/retest`，`ATOMGIT_TRIGGER_TYPE=pull_request_comment`）：

> **触发器必须用 `pull_request_target` 而非 `pull_request`**：评审确认
> `pull_request` 语义下 runner 会执行 **PR 侧**的 workflow 定义——PR 只要改
> `.gitcode/workflows/` 就能改写自己的门禁（如把 run 步骤换成 `exit 0`）。
> `pull_request_target` 保证 workflow 定义取自 base 分支。`/retest` 评论
> 触发（`pull_request_comment`）天然取 master 侧定义，已实测安全。

```
ATOMGIT_REF=refs/heads/master        ← 插件跟随此 ref
fetch ... origin +<master-tip>:refs/remotes/origin/master
git checkout --force -B master refs/remotes/origin/master
```

即插件检出的永远是 **master**。但下面两个变量在两种事件下都可用：

```
ATOMGIT_HEAD_REF=test/gitcode-action   ← PR 源分支（分支名，不含 refs/heads/）
ATOMGIT_BASE_REF=master                ← PR 目标分支
```

另外：`ATOMGIT_EVENT_PATH` 指向的 event.json **不存在**（无法解析事件 payload），
环境变量里也**没有 PR 编号**。GitCode 服务端暴露 GitLab 风格 PR ref
（`refs/merge-requests/<n>/head` 与 `/merge`，可用 `git ls-remote` 确认），
但拿不到 n 就无法使用。这就是 §4.1 双检出设计用 `ATOMGIT_HEAD_REF` 的原因。

### 3.3 container.volumes 被忽略

workflow 里写 `volumes:` 不会挂载任何东西（mountinfo 证实）。**不要在
workflow 里配置 volumes**。共享目录必须在 runner 环境侧由运维预置
（当前 `/home/jenkins/ccache` 已预置好）。

### 3.4 其他已验证行为

- 每个 job 是独立的 k8s pod，7 个 job 并行、互相隔离（`/tmp` 不共享）。
- 步骤脚本以 `bash -e` 执行；我们的脚本另设 `set -euo pipefail`。
- `ATOMGIT_RUN_ID`（= `atomgit.run_id` 上下文）每次运行唯一，用于构建目录命名。
- pod 首次在某节点运行时要拉 20GB 镜像，Pending 可达几十分钟，属正常。
- workflow 文件本身取自 **master**（`ATOMGIT_WORKFLOW_REF=...@refs/heads/master`），
  PR 分支上的 workflow 改动不会生效，必须先合入 master。
- 并发配置：`concurrency QUEUE` + 按 `mr_id` 抢占（yml 顶部）。

### 3.5 本仓库的提交规范（gitlint 强制）

commit-msg 钩子跑 gitlint，**必须有正文**（UB2: Body is missing）：

```
<area>: <subject>            # 英文，简短

正文（说明 why/what，每行 <100 字符）

Signed-off-by: ...           # git commit -s 自动加
```

只有标题没有正文的提交会被拒绝（交互确认在 CI 环境中表现为直接 Aborted）。

---

## 4. 执行模型与关键设计

### 4.1 双检出（裁判/运动员分离）

**问题**：插件检的是 master（§3.2），直接用就是"门禁测 master"；但反过来把
工作区切到 PR 分支也不对——gate 脚本（build_image.sh 等）会变成 PR 里的版本，
**运动员改裁判规则**（恶意/失误的 PR 可以让自己的门禁变绿）。

**方案**（`checkout_pr.sh`，每个 job 的 checkout 步骤之后执行）：

```
插件检出（master，不动）          = 裁判：gate 脚本，钉在 base 分支
/tmp/gate-pr-code（git worktree） = 运动员：被测代码 = ATOMGIT_HEAD_REF 的 tip
```

实现要点：

- 工作区先 `checkout -B $BASE_REF refs/remotes/origin/$BASE_REF` 钉死在 base。
- `git fetch --depth=${GATE_PR_FETCH_DEPTH:-10} origin $ATOMGIT_HEAD_REF` 后
  `git worktree add --detach` 生成 worktree。**tip commit 的树已包含 PR 全部
  commit 的变更叠加**（commit 是快照）；fetch 一段历史只为 git log 诊断可读。
- worktree 保留 git 历史：oebuild 的 os-release（`os-release.bbappend` 的
  `get_oee_revision`）读 `repo.head.object.hexsha`，detached HEAD 可正常读。
- 无 PR 上下文（`ATOMGIT_HEAD_REF` 为空，如 workflow_dispatch）时不动任何
  东西，构建脚本回退到工作区检出。
- **fail-closed**：PR 上下文已确认（HEAD_REF 非空且 ≠ base）后，fetch 或
  worktree 失败一律 `exit 1` 让 job 失败——静默回退 base 会造成"测错代码
  却报绿"的假绿（评审意见采纳）。
- 构建脚本选择被测代码的方式（build_image.sh / build_docs.sh 相同）：

```bash
REPO_DIR="${GATE_PR_CODE_DIR:-/tmp/gate-pr-code}"
if [ ! -e "${REPO_DIR}/.git" ]; then          # worktree 的 .git 是文件
    REPO_DIR="$(git rev-parse --show-toplevel)"
fi
```

- **fork PR 支持**：`git fetch origin <head分支>` 失败时（fork PR 的源分支
  不在目标仓），经平台 API 解析 PR（匹配 head 分支 + base 分支 +
  `ATOMGIT_SOURCE_REPOSITORY_ID`），依次从 fork 仓拉分支 →
  `refs/merge-requests/<n>/head` → `/merge` 兜底；全部失败才 exit 1
  （fail-closed）。
- **API 认证顺序（匿名优先）**：runner 注入的 `ATOMGIT_TOKEN` 在 workflow
  未声明 `pr` 权限时会被 pulls API 拒绝（线上实证：带坏凭证比不带更糟），
  而公开仓匿名可读。因此先匿名请求、失败再带 token（覆盖私有仓，需
  workflow 声明 `pr: read`）。解析失败的真实原因会打进 job 日志。

### 4.2 用户切换与 git 属主

- 脚本开头 `exec runuser -u jenkins -- env <保留的环境变量> bash "$0" "$@"`。
  **注意 runuser 不会透传环境变量**，需要什么（GATE_*、PATH）就在 `env` 里
  显式列出，新增环境变量时必须同步加到这里。
- 切换后 jenkins 访问 root 属主的检出/worktree 会被 git 拒绝
  （dubious ownership），脚本里已有 `git config --global --add safe.directory '*'`。

### 4.3 镜像构建流程（build_image.sh）

对 Jenkins `translateCompileToHost` + `dynamicBuild` 的等价移植：

1. **生成 compile.yaml**（python heredoc，参数经 argv 传入——**heredoc 定界符
   带引号时 shell 不展开变量**，别在引号 heredoc 里写 `$VAR`）：
   - `build_in: host`（在容器内直接构建，不用 docker-in-docker）
   - `cache_src_dir: $GATE_SHARE_DIR/$TARGET_BRANCH/oebuild_workspace/src`
     （TARGET_BRANCH = GATE_TARGET_BRANCH 覆盖值，否则取 ATOMGIT_BASE_REF，
     最后回退 master）
     （GATE_SHARE_DIR 为空则不写该字段）
   - `local_conf` 追加 `DATETIME = "20260101000000"`（**固定值**：跨运行 sstate
     复用的关键）和 `INHERIT += "rm_work"`
   - `bitbake_cmds` 过滤掉 `do_populate_sdk`
2. `oebuild init /tmp/oebuild-gate-<image>-<run_id>`（每次运行临时工作区），
   init 后有存在性守卫（oebuild 报错可能 exit 0，见 §6）。
3. `ln -sfn "${REPO_DIR}" src/yocto-meta-openeuler`——**必须 `-sfn`**：
   目标已存在且是指向目录的符号链接时，`-sf` 会把链接建到旧目标*里面*，
   只有 `-n`（no-dereference）才会替换链接本身。
4. `oebuild <compile.yaml> | tee <log>`（实时输出 + 留档）。
5. 三重判据（§6），失败时打印日志尾部 80 行。
6. 清理：删掉整个临时工作区；**共享缓存不动**。

### 4.4 文档构建流程（build_docs.sh）

1. 切 jenkins 用户（同 §4.2）。
2. 从 `REPO_DIR` 复制 `docs/` 到 `/tmp` 可写副本（检出/worktree 对 jenkins
   不可写），`pip3 install -r scripts/requirements-doc.txt`（清华源），
   `make html SPHINXOPTS="-W"`（警告即失败，与官方 embedded-ci 的
   openeuler_doc 目标一致）。文档依赖与已知告警修复见仓库
   `scripts/requirements-doc.txt` 及 docs 相关 commit。

### 4.5 共享源码缓存

- 路径推导：`CACHE_SRC_DIR = $GATE_SHARE_DIR/$TARGET_BRANCH/oebuild_workspace/src`
  （TARGET_BRANCH 优先级：`GATE_TARGET_BRANCH` 覆盖 → `ATOMGIT_BASE_REF`
  （runner 注入，PR/评论事件都可用）→ `master` 兜底），
  与 Jenkins `$shareDir/$branch/oebuild_workspace/src` 同构。
- oebuild 语义（`sync_repo_from_cache`）：src 里已有→跳过；缓存有→rsync；
  都没有→网络克隆，随后 `download_repo_from_manifest` checkout manifest 锁定
  版本（缓存陈旧无害，版本正确性由 checkout 保证）。
- 缓存由外部维护（本门禁只读）。GATE_SHARE_DIR 置空即完全禁用缓存。

---

## 5. 环境变量参考

| 变量 | 定义处 | 默认 | 说明 |
|---|---|---|---|
| `GATE_RUN_ID` | workflow env（`atomgit.run_id`） | — | 每次运行唯一，构建目录命名 |
| `GATE_SHARE_DIR` | workflow env | `/home/jenkins/ccache/openeuler_embedded` | 共享缓存根；空 = 禁用 |
| `GATE_TARGET_BRANCH` | 可选 | 空（取 `ATOMGIT_BASE_REF`） | 缓存分支段（强制覆盖用） |
| `GATE_PR_CODE_DIR` | 可选 | `/tmp/gate-pr-code` | PR worktree 路径 |
| `GATE_PR_FETCH_DEPTH` | 可选 | `10` | PR 分支历史拉取深度 |

新增 workflow env 后**必须**把它加进两个构建脚本 runuser 的 `env` 透传列表，
否则切换用户后值为空。

## 6. 判定标准（fail-closed）

镜像构建成功必须**同时满足**三项（缺一判失败）：

1. oebuild 退出码 = 0
2. 构建日志中无 `ERROR` 行
3. `${BUILD_OUT}/tmp/deploy/images` 下存在产物文件

原因：oebuild 的 root 检查等早期错误**只打日志就 return（exit 0）**，只看退出码
必然假绿。文档构建以 `make html -W` 退出码为准（Sphinx 严格模式）。

## 7. 常见修改配方

### 新增一个构建目标

1. 确认 `.oebuild/samples/<arch>/<name>.yaml` 存在（arch 取
   aarch64/arm32/x86-64/riscv64）。
2. 在 yml 里复制任一 `build_*` job，改名字和 `build_image.sh <arch> <name>` 参数。
   job 结构固定为三步：Checkout → Point the build at the PR → Build。

### 临时停用某个构建

整段 job 注释掉即可（历史上用过行首 `#x` 前缀的方案，恢复时去掉前缀）。

### 调整缓存

- 换缓存根：改 workflow env `GATE_SHARE_DIR`（节点侧要有该目录）。
- 禁用：`GATE_SHARE_DIR: ''`。
- 新分支缓存隔离：默认已按 `ATOMGIT_BASE_REF` 自动推导；需要强制覆盖时设
  `GATE_TARGET_BRANCH`。

### 让 PR 评论触发更多指令

yml 的 `pull_request_comment.comments` 列表加条目（如 `/retest-full`），语义为
评论内容匹配。

## 8. 调试手册（故障特征 → 根因 → 处置）

| 日志特征 | 根因 | 处置 |
|---|---|---|
| `can not use oebuild in root` | 脚本丢失了 runuser 切换（§4.2） | 恢复脚本头部的用户切换块 |
| `cd: /tmp/oebuild-gate-...: No such file or directory` | oebuild init 静默失败（exit 0），工作区未创建 | 看 init 守卫上方日志；历史上根因是 root 拒绝或父目录不存在 |
| `detected dubious ownership in repository` | jenkins 读 root 属主的 git 仓库 | 确认 `git config --global --add safe.directory '*'` 在切换用户之后执行 |
| `basehash value changed ... metadata is not deterministic`（os-release） | 构建期间代码仓的 HEAD 变了——os-release.bbappend 在每次 parse 时读 `repo.head.object.hexsha` | **构建期间绝不能 commit/改动被测仓库**（本地复现时踩过：构建中提交注释导致 25 个 reparse 错误） |
| 构建"成功"但什么都没干（PASSED 秒回） | oebuild exit-0 假阳性 | 三重判据（§6）就是防这个；若复现说明判据被削弱了 |
| job 长时间 Pending | 节点首次拉 20GB 镜像 | 等待；同一节点后续秒起 |
| `/retest` 无反应 | 并发 QUEUE 排队/抢占 | 看流水线页面的队列状态 |
| `couldn't find remote ref <分支>` 后接 `api resolution failed -` | fork PR 的 API 解析失败：token 被拒 + 匿名也失败 | 匿名通常对公开仓可用；查日志里的具体 HTTP 错误（401/403/网络）与 workflow 的 `pr: read` 声明 |
| `no open PR matches head <分支>` | API 正常但没找到匹配的 PR | 核对 head/base 分支名与 `ATOMGIT_SOURCE_REPOSITORY_ID`；PR 可能已关闭 |
| `discovered PR=[]`（若见到） | 旧版脚本按 PR 号发现；现版本用 HEAD_REF，不应再出现 | 升级到双检出版 checkout_pr.sh |

### 本地复现方法（改脚本后先本地跑，再上线）

```bash
# docs 冒烟（在 CI 镜像里以 root 调用，模拟 runner）：
docker run --rm -u root --entrypoint bash \
  -v /path/to/yocto-meta-openeuler:/repo:ro \
  swr.cn-north-4.myhuaweicloud.com/openeuler-embedded-2/openeuler-ci:latest \
  -c 'cd /repo && bash .gitcode/workflows/scripts/build_docs.sh'

# 镜像构建冒烟（timeout 截断，看 init/检出/cache 路径是否正常）：
docker run --rm -u root --entrypoint bash \
  -v /path/to/yocto-meta-openeuler:/repo:ro \
  swr.cn-north-4.myhuaweicloud.com/openeuler-embedded-2/openeuler-ci:latest \
  -c 'cd /repo && timeout 40 bash .gitcode/workflows/scripts/build_image.sh aarch64 qemu-aarch64 2>&1 | head -20'

# checkout_pr.sh 模拟（克隆仓库后注入环境变量）：
ATOMGIT_HEAD_REF=test/gitcode-action ATOMGIT_BASE_REF=master \
  bash .gitcode/workflows/scripts/checkout_pr.sh
```

## 9. 与 Jenkins 原版的映射

| Jenkins（.oebuild/workflows/） | GitCode Actions（本目录） |
|---|---|
| `jenkinsfile_gate` pipeline | `openeuler_embedded_PR_gate.yml` |
| init 阶段 `downloadYoctoWithPr` → `clone_repo_with_pr`（fetch `+refs/merge-requests/N/head`） | `checkout_pr.sh`（用 HEAD_REF 分支 + worktree，等价语义） |
| pre 阶段（去重/抢占登记） | yml 的 `concurrency` + 平台自身 |
| code check（commit_msg/scope） | **未移植**（可后续加 colcon/pytest 型 job 或 script 步骤） |
| docs 阶段（embedded-ci `openeuler_doc` = `make html -W`） | `build_docs.sh`（等价） |
| 各镜像阶段 `dynamicBuild`/`buildTask` | `build_image.sh` + 各 `build_*` job |
| `translateCompileToHost`（compile yaml 生成） | build_image.sh 的 python heredoc（§4.3 步骤 1） |
| `cacheSrcDir = $shareDir/$branch/oebuild_workspace/src` | `CACHE_SRC_DIR` 同构推导（§4.5） |
| 结果评论（comment 阶段） | **未移植**（结果只在 PR 检查页；`associate-pr-comment` 仅做关联） |

## 10. 已知限制 / 待办

- **pull_request（open/update/reopen）事件下 `ATOMGIT_REF` 的值未采样**
  （预期同样是 base 分支，双检出设计对两种事件都免疫，但日志尚未确认过）。
- ~~fork PR 不支持~~：已支持（API 解析 + fork/merge-ref 拉取，见 §4.1）。
  残余限制：API 不可达或 token 失效时 fail-closed。
- runner 忽略 `container.volumes`/`options` 的问题已向平台反馈方向确认
  （文档承诺 vs 实现缺失），若平台修复，可考虑恢复声明式配置——但双检出/
  用户切换逻辑**仍需保留**（它们解决的是插件行为与 oebuild 约束，与挂载无关）。
- 共享缓存目前只读（外部维护）；如果缓存长期为空且变慢，考虑按 run 回填。
- `code check`（commit message / scope）未移植。
- 正式化收尾：CI 镜像推主站 `openeuler-embedded`，workflow 镜像引用同步改。

## 11. 修改后的验证清单

```bash
# 1. 语法
python3 -c "import yaml; yaml.safe_load(open('.gitcode/workflows/openeuler_embedded_PR_gate.yml'))"
bash -n .gitcode/workflows/scripts/*.sh

# 2. 本地冒烟（§8 的命令）

# 3. 提交（gitlint：必须有正文）
git commit -s -m "<area>: <subject>" -m "<正文>"

# 4. 推送 action master（workflow 只认 master，见 §3.4）
git push action action-master:master

# 5. 测试 PR（ComputingActionTest/yocto-meta-openeuler #1，
#    分支 test/gitcode-action）评论 /retest
# 6. 读日志重点：
#    - "Point the build at the PR" 步骤：code under test 是否 PR tip、
#      gate scripts 是否 base
#    - build_docs / build_* 的用户切换打印（"started as root" → "as jenkins"）
#    - build_image 的 yaml 生成输出（build_in/cache_src_dir/bitbake_cmds）
#    - 三重判据与 PASSED
```

## 12. 历史决策存档（为什么是这样）

- **runuser 而非 sudo**：步骤以 root 执行，root 切用户无需 sudo；runuser 参数
  原样透传，su -c 的引号拼接易错。
- **`ln -sfn`**：见 §4.3 步骤 3 的坑。
- **DATETIME 固定值**：Jenkins 用 `getNowDatetime()`（运行内固定、跨运行变化）；
  我们用固定值，跨运行 sstate 命中率更高，是严格超集。
- **worktree 而非整目录 clone**：省一次全量 clone；worktree 共享对象库且保留
  git 历史（os-release 需要）。
- **`env` 显式透传**：runuser 不继承环境（§4.2）。
- **文档构建复制到 /tmp**：检出目录对 jenkins 只读。
- **yml 的 6 个构建 job 不抽公共脚本步骤**：GitCode Actions 无 YAML 锚点，
  重复是刻意的；修改时注意 7 处同步（含 docs）。
