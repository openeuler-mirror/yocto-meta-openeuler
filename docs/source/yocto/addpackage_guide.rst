openEuler新增软件包指导
###############################

配方（.bb 文件）是 Yocto 项目环境中的基本组件。 OpenEmbedded 构建系统构建的每个软件组件都需要一个配方来定义组件；

新增软件包到镜像中需要有软件包的源码，对应的bb文件。

主要过程
********************

1. **源码获取/下载**

软件包源码放在src（yocto-meta-openeuler同级目录）下。

2. **获取配方（.bb文件）**
    
从yocto-poky仓库寻找相应软件包的bb文件；

.. code-block:: console

    find yocto-poky -name package*.bb

`OpenEmbedded Layer <http://layers.openembedded.org/layerindex/branch/master/recipes/>`_ 可直接搜索相应软件包的bb文件。

    
3. **适配配方**

在上一步中如果未找到相应版本的bb文件，可基于相近版本修改;

.. code-block:: console

    mv package_version1.bb package_version2.bb //修改bb文件名为所需版本

修改bb文件适配openEuler yocto工程，主要需要修改如下字段；

SRC_URI：表示软件包来源，修改源码包来源为本地，如果源码是从src-openEuler下载到本地，src-openEuler上该软件包有额外补丁也需要加上。

.. code-block:: console

    SRC_URI = "file://package//${BP}.tar.*"   //BP变量表示软件名-版本号，*需改为相应的后缀。

依赖相关字段，如inherit、DEPENDS、RDEPENDS；

.. code-block:: console

    bitbake <package> -g  //此命令可查看软件依赖
    cat pn-buildlist

发现未支持依赖需优先编译依赖软件或者视情况解耦掉依赖软件。删除不支持的依赖，如inherit texinfo update-alternatives python3，这些class需要引入软件包，暂时没有支持起来。

4. **单包编译**

    bitbake <package>

5. **加入镜像**

bb文件适配完成并验证ok后，将所需子包追加到layer配置文件RDEPNDNS变量中（ 当前配置文件位于yocto-meta-openeuler工程meta-openeuler /recipes-core/packagegroups/packagegroup-xxx.bb ）。

如果在加入镜像中与已有子包文件发生冲突的话需选择需要的子包，将另一个包从RDEPENDS变量值去除，但这个操作可能会引起一些麻烦，由于被删除子包中可能会包含其它必要的文件。

6. **编译镜像**

.. code-block:: console

    bitbake openeuler-image

这时产生的镜像中已经包含了你所需的软件包功能。