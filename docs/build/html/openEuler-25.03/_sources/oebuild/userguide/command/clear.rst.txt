.. _command_index_clear:

清理命令-clear
#######################

该命令用于对oebuild工作目录的清理，在用oebuild执行构建openEuler Embedded的过程中，会有一些额外的文件，这些文件也不需要长时间存在，而清理这些文件对于用户来说是一件比较繁琐的事情，因此oebuild添加了该命令用于对这些文件进行清理。该命令使用范例如下：

.. code-block:: console

    oebuild clear [docker]

目前清理命令只有对docker的清理，因为oebuild在选择使用容器端构建openEuler Embedded时，就会持续的启用容器，随着时间推移启用的容器会越来越多，虽然容器对资源的占用很小，但是数量太多仍然会影响计算机性能，并且对容器的管理将不再方便。对容器清理时容器ID的获取来源于构建目录下的.env.yaml文件，该文件中记录着构建运行时的环境参数，环境参数中包含有本次构建的容器ID，然后oebuild会首先将该容器关闭，然后再删除，以此完成oebuild对容器的清理。

oebuild对容器的清理命令如下：

.. code-block:: console

    oebuild clear docker 
