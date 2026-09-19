.. _put_to_dst:

put_to_dst数据存储命令-put_to_dst
######################################

此命令用于将用于将某物放置到目的地，包括其他本地目录、已安装的共享磁盘、远程服务器等。

具体参数如下所示，其中-i参数和-u参数在-t参数指定为0，也就是远端存储时必填，-w参数和-k参数二选其一必填，否则存储会报错，-i、-u、-t、-w和-k参数主要是为了实现ssh链接使用。

-t: dst_type
-------------

此参数用于选择存储方式，0表示远端存储，1表示共享磁盘或者本地文件，具体示例如下：

.. code-block:: console

    -t 0

-dd: dst_dir
-------------

此参数用于指定存储的文件夹名称，具体示例如下：

.. code-block:: console

    -dd $remote_dir

-ld: local_dir
---------------

此参数用于本地需要传输的文件夹名称，具体示例如下：

.. code-block:: console

    -ld $local_dir

-sign: sign_file
-----------------

此参数用于指定是否需要为每个文件进行sha256sum编码，会在文件中修改或者添加sha256sum编码，具体示例如下：

.. code-block:: console

    -sign

-d: delete_original
--------------------

此参数用于指定是否需要删除原始文件，具体示例如下：

.. code-block:: console

    -d

-i: remote_dst_ip
-------------------

此参数用于指定远端ip，请按实际需求填写，具体示例如下：

.. code-block:: console

    -i $remote_ip

-u: remote_dst_user
--------------------

此参数用于指定远端用户名，请按实际需求填写，具体示例如下：

.. code-block:: console

    -u $username

-w: remote_dst_pwd
-------------------

此参数用于指定远端用户名对应的密码，请按实际需求填写，具体示例如下：

.. code-block:: console

    -w $password

-k: remote_dst_sshkey
----------------------

此参数用于指定远端sshkey值，请按实际需求填写，具体示例如下：

.. code-block:: console

    -k $remote_key
