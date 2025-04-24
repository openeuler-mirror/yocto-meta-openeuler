.. _serial:

serial数据转换命令-serial
######################################

此命令用于将param编码为base64代码，结果可以使用作为字符串参数，当我们使用某些对象参数时，它将无效在命令中，所以我们将对象设置为字符串来解决它。

具体参数如下：

-c: params
------------

此参数用于传入对应的数据，然后转换为对应的字符串参数，具体示例如下：

.. code-block:: console

    -c name=${name}
    -c action=${action}
    -c result=${check_res}
    -c log_path=${log_path
