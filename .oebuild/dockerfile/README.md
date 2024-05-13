# DockerFile介绍

openEuler Embedded涉及到的容器镜像有两种，一种是构建嵌入式镜像的容器，其相关的Dockerfile存放在openeuler-image目录，另一种是构建交叉编译链的容器，其相关的Dockerfile存放在openeuler-sdk目录，在没个目录下都会有两个Dockerfile，其中一个是Dockerfile，其用来构建对应的容器镜像，另一个是Dockerfile_CI，其用来构建所对应的基础设施运行的容器镜像。

容器镜像编译命令如下（这里以构建嵌入式容器镜像为例）：

```
cd openeuler-image
docker build -t openeuler-container:latest .
```
