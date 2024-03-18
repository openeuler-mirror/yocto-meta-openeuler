# DockerFile介绍

### Dockerfile
此文件主要用于个人构建镜像生成，以openEuler-23.09镜像为基础，按照如下步骤进行镜像生成。

1.下载个人构建所需依赖软件包。

2.添加名称为openeuler的组和用户，且uid和gid均为1000。

3.下载cross-ng-1.26.0压缩包，安装ct-ng工具。

4.从openeuler工作环境的yocto-meta-openeuler仓库中下载最新的nativesdk和toolchain发行版，并将其安装到指定位置

5.安装python依赖包

### Dockerfile_CI
此文件主要用于CI构建镜像生成，以openEuler-23.09镜像为基础，按照如下步骤进行镜像生成。

1.下载个人构建所需依赖软件包。

2.添加名称为jenkins的组和用户，且uid和gid均为1001。

3.下载并安装jenkins环境，为jenkins外部调用做准备。

4.挂载/home/jenkins/agent文件夹和/home/jenkins/.jenkins文件夹

5.下载cross-ng-1.26.0压缩包，安装ct-ng工具。

6.从openeuler工作环境的yocto-meta-openeuler仓库中下载最新的nativesdk和toolchain发行版，并将其安装到指定位置。
