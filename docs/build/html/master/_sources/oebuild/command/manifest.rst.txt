.. _command_index_manifest:

manifest管理命令-manifest
######################################

该命令用于对openEuler Embedded的基线进行管理，对openEuler Embedded的基线来说，目前只涉及上游源码包的git信息，对于相关的构建环境并不包括进去。manifest命令有两个功能，分别是生成基线文件和根据基线文件更新基线源码。

- 生成基线文件功能：oebuild对于生成openEuler Embedded的基线文件采用的方法就是遍历src目录下的上游源码包，如果该包有git信息，则会将该包git信息追加到指定的manifest.yaml文件中，并且会对上游remote命名为upstream。


- 根据基线文件更新基线源码功能：与生成基线文件功能相反，oebuild以基线为准更新源码也将会解析指定的基线文件，然后将所有记录的上游源码包下载或更新到src目录，一般来说，该命令应用的场景为封闭式开发环境，在构建过程中无法连接外网，因此需要提前下载好代码。

该命令的使用范例如下：

.. code-block:: console

    oebuild manifest [-c create] [-r recover] [-m_dir manifest_dir]

.. warning:: 
    在这里需要着重说明的是，openEuler Embedded的基线文件放置在根目录下的 `.oebuild/manifest.yaml` ，与openeuler_fetch紧密结合，在下载上游源码包时会解析manifest.yaml，然后寻找对应上游包的信息，根据上游包git信息进行包下载，如果manifest.yaml基线文件不存在，则会以分支方式下载，此时上游源码包就是该分支最新的代码。


-m: manifest_dir
----------------

该参数表示基线文件manifest.yaml的路径，参数后面需要跟manifest.yaml的路径，该参数不管是用于生成基线文件还是根据基线文件更新上游源码都是需要指定的，该参数使用方式如下：

.. code-block:: console

    oebuild manifest -m_dir /some/local/manifest.yaml

-c: create
----------

该参数表示用于生成基线文件，该参数使用方式如下：

.. code-block:: console

    oebuild manifest -c -m_dir /some/local/manifest.yaml

-r: recover
-----------

该参数表示用于根据基线文件更新基线源码，该参数使用方式如下：

.. code-block:: console

    oebuild manifest -r -m_dir /some/local/manifest.yaml


.. note:: 需要注意的是，在更新上游源码的过程中，对于某个包如果已经存在该仓，那么oebuild会遍历该仓下所有remote，然后与解析的remote_url进行对比，如果比对成功，则直接以该remote进行fetch操作，然后将对应的version检出来，如果比对不成功，则oebuild会在该仓下创建一个remote，并命名为upstream，指向的remote_url即为从manifest.yaml解析出来的remote_url，然后对upstream进行fetch操作，再将对应的version检出来。
