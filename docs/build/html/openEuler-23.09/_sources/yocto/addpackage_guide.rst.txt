.. _yocto_add_software_package:

新增软件包指导
###############################

配方（bb文件）是 Yocto 项目中的基本组件。Yocto 构建系统构建的每个软件组件都需要一个配方来定义组件；bbappend 文件是 bb 文件的补充，在最后解析。

新增软件包到镜像中需要软件包的源码和对应的 bb 文件。

主要过程
==============

1. **源码获取**

源码通常在 `src-openEuler <https://gitee.com/organizations/src-openeuler/projects>`_ 上获取，如果 src-openEuler 上不存在对应源码，则会从 bb 文件指定上游获取源码。

2. **获取配方（bb文件）**

先确认已有的 yocto 仓库中是否存在需要软件包的 bb 文件：

.. code-block:: console

    $ find yocto-* -name <package>*.bb

如果没有找到则可以在 `OpenEmbedded Layer <http://layers.openembedded.org/layerindex/branch/master/recipes/>`_ 搜索，然后拷贝需要的文件（bb、补丁等）到 meta-openeuler 层。

3. **适配配方**

| bbappend 文件作为 bb 文件的补充，开发者可以通过在 bbappend 文件中增加内容来对 bb 文件进行覆盖更改，而不用直接对 bb 文件进行更改。
| 开发者首先在 meta-openeuler 层 bb 文件对应的目录下创建 bbappend 文件，文件命名为 <package>_%.bbappend，Yocto 中 "%" 为通配符，这样命名能匹配任何一个找到的 bb 文件版本；下一步根据构建需求编写 bbappend 内容，并做好相应注释说明，大多数情况下编写的内容如下：

- OPENEULER_REPO_NAME: src-openEuler存储仓名称；
- OPENEULER_BRANCH: src-openEuler源码仓库分支；
- PV: 版本；
- SRC_URI: 源码来源；
- SRC_URI[md5sum/sha256sum]: 源码校验码；
- S: 源码解压后目录。

.. code-block:: console

    OPENEULER_REPO_NAME = "仓库具体命名"
    PV = "版本号"
    SRC_URI:remove = "原源码链接"
    SRC_URI:prepend = "file://源码包 \
    "
    SRC_URI[sha256sum] = "校验码" //执行 sha256sum 源码包
    S = "${WORKDIR}/${BP}" //BP变量表示软件名-版本号，如果不符合则需要修改

举例：查看 meta-openeuler/recipes-support/libjitterentropy/libjitterentropy_%.bbappend 的编写。

优先构建未支持的依赖包，从下往上依次适配；查看依赖方法：

.. code-block:: console

    bitbake <package> -g  //此命令输出软件依赖到文件中
    cat pn-buildlist

4. **单包构建**

.. code-block:: console

    $ bitbake <package>

5. **加入镜像**

单包构建完成后，将所需子包追加到包管理 bb 文件 RDEPNDNS 变量中（文件位于 meta-openeuler/recipes-core/packagegroups/packagegroup-xxx.bb）。例如：

.. code-block:: console

    RDEPENDS:${PN} += "audit"

6. **构建镜像**

openeuler-image-tiny 镜像中只包含了运行系统所需的最基本的包文件，构建所需时间较少；为了避免构建时间过长，推荐先将所需子包加入到 openeuler-image-tiny 镜像进行验证，验证通过后再加入到 openeuler-image 镜像中。

.. code-block:: console

    bitbake openeuler-image or openeuler-image-tiny

这时产生的镜像中已经包含了你所需的软件包。
