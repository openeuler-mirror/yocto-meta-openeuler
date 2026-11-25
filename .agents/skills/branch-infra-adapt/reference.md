# branch-infra-adapt 参考：已知坑

本文件收录分支适配中踩过的坑（26.09 实践沉淀），按需阅读。

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