openEuler容器构建指导
======================

1. 准备主机端docker工具
************************

a) 检查当前环境是否已安装docker环境
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    docker version

b) 如果没有安装，可参考官方链接安装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

官网地址：http://www.dockerinfo.net/document

openEuler环境可参考Centos安装Docker

.. code-block:: console

    sudo yum install docker

2. 获取容器镜像
****************

a) 从华为云pull镜像到宿主机
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/rtos-openeuler-21.03:v001

3. 拉起容器构建环境（启动命令仅供参考）
*************************************

a) 启动容器
^^^^^^^^^^^^^

.. code-block:: console

    docker run -idt --network host swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/rtos-openeuler-21.03:v001 bash

b) 查看已启动的容器id
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    docker ps

c) 进入容器
^^^^^^^^^^^^

.. code-block:: console

    docker exec -it 容器id bash

4. yocto一键式构建流程
*************************************

a) clone yocto-meta-openeuler代码仓
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    git clone https://gitee.com/openeuler/yocto-meta-openeuler.git -b openEuler-22.03-LTS -v /usr1/openeuler/src/yocto-meta-openeuler

b) 下载源码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    cd /usr1/openeuler/src/yocto-meta-openeuler/scripts
    sh download_code.sh /usr1/openeuler/src

c) 开始编译
******************************************

.. code-block:: console

    chown -R huawei:users /usr1
    su huawei
    cd /usr1/openeuler/src/yocto-meta-openeuler/scripts
    source compile.sh aarch64-std /usr1/build /usr1/openeuler/gcc/openeuler_gcc_arm64le

- 编译架构: aarch64-std、aarch64-pro、arm-std、raspberrypi4-64

- 构建目录: /usr1/build

- 源码目录: /usr1/openeuler/src

- 编译器所在路径: /usr1/openeuler/gcc/openeuler_gcc_arm64le

    - aarch64-std、aarch64-pro、raspberrypi4-64使用openeuler_gcc_arm64le编译器

    - arm-std使用openeuler_gcc_arm32le编译器

d) 获取结果件
**************

结果件默认生成在构建目录下的output

如aarch64-std编译完成后产物如下：

- openeuler嵌入式镜像: Image-5.10.0

- openeuler嵌入式sdk工具链: openeuler-glibc-x86_64-openeuler-image-aarch64-qemu-aarch64-toolchain-21.09.30.sh

- openeuler嵌入式文件系统: openeuler-image-qemu-aarch64-20220318114250.rootfs.cpio.gz

- openeuer嵌入式压缩镜像: zImage
