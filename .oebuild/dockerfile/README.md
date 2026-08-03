# DockerFile介绍

openEuler Embedded涉及到的容器镜像有两种，一种是构建嵌入式镜像的容器，其相关的Dockerfile存放在openeuler-image目录，另一种是构建交叉编译链的容器，其相关的Dockerfile存放在openeuler-sdk目录，在每个目录下都会有两个Dockerfile，其中一个是Dockerfile，其用来构建对应的容器镜像，另一个是Dockerfile_CI，其用来构建所对应的基础设施运行的容器镜像。

`openeuler-sdk/Dockerfile` 构建的容器镜像同时提供 GCC 7.3.0（ct-ng 交叉链构建）与 GCC 12.4.0（LLVM/Clang 构建）双版本主机编译器，以及 cmake 3.27.9、ninja 1.11.1，所有交叉编译链均可在同一容器中构建。详见 `.oebuild/toolchains/README.md`。

容器镜像编译命令如下（这里以构建嵌入式容器镜像为例）：

```
cd openeuler-image
docker build -t openeuler-container:latest .
```

交叉编译链容器构建命令：

```
cd openeuler-sdk
docker build -t openeuler-sdk:latest .
```
