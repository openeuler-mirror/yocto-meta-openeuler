.. _utest:

utest镜像测试命令-utest
######################################

此命令用于测试对应镜像，具体示例如下：

-a: arch
---------

该参数用于指定构建架构，如aarch64，x86，arm32等，具体示例如下：

.. code-block:: console

    -a aarch64

-target: target
----------------

该参数用于指定目标镜像来源，具体示例如下：

.. code-block:: console

    -target openeuler_image

-td: target_directory
----------------------

该参数用于指定构建产物目录，具体示例如下：

.. code-block:: console

    -td /home/jenkins/oebuild_workspace/build/${stageName}

-tm: mugen_url
---------------

该参数用于指定测试框架仓库路径，具体示例如下：

.. code-block:: console

    -tm ${mugenRemote}

-tb: mugen_branch
------------------

该参数用于指定测试框架仓库分支，具体示例如下：

.. code-block:: console

    -tb ${mugenBranch}
