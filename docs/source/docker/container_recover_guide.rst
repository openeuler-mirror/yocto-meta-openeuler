OpenEuler容器镜像使用指导
=========================
1. 准备docker环境
*******************
a) 检查当前环境是否已安装docker环境
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- docker version

b) 如果没有安装，可参考官方链接安装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
官网地址：http://www.dockerinfo.net/document

openEuler环境可参考Centos安装Docker

- sudo yum install docker

2. 从华为云pull容器镜像到本地
******************************
- docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/rtos-openeuler-21.03:v001

3. 使用pull下来的镜像启动容器（启动命令仅供参考）
************************************************
a) 启动容器
^^^^^^^^^^^^^
- docker run -idt swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/rtos-openeuler-21.03:v001 bash

b) 查看已启动的容器id
^^^^^^^^^^^^^^^^^^^^^^^
- docker ps

例如容器id为xxxxxx

c) 进入容器
^^^^^^^^^^^^^
- docker exec -it xxxxxx bash

4. 开始构建，具体过程不再赘述。
*******************************
