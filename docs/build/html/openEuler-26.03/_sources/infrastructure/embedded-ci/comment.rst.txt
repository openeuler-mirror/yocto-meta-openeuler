.. _comment:

comment格式化ci或gate结果命令-comment
######################################

此命令用于格式化来自gate或者ci的结果，格式化完成之后用于展示。

在jenkins-file中，我们会对pull_request的一些值设置对应的别名，方便我们动态设置参数值，例如空间使用pull_request.base.repo.namespace，可以设置别名为giteeTargetNameSpace，仓名采用repository.name，可以设置别名为giteeRepoName，其他的如giteetoken，$giteePullRequestid等等都是如此。

此命令有以下参数：

-m: method
-----------

此参数用于指定结果来源，从gate和ci中二选一进行填写，具体示例如下：

.. code-block:: console

    -m ci

-o: owner
----------

此参数用于指定gitee工作空间，可以openeuler，也可以是用户的个人空间，一般取值为$repoNamespace，具体示例如下：

.. code-block:: console

    -o $repoNamespace

-p: repo
----------

此参数用于指定仓库名称，一般取值为$repoName，具体示例如下：

.. code-block:: console

    -p $repoName

-dt: duration_time
-------------------

此参数用于表示ci或者gate整体耗时，暂无具体示例，在jenkins-file中以如下方法获得：

.. code-block:: console

    def duration_time = System.currentTimeMillis() - currentBuild.startTimeInMillis

-gt: gitee_token
------------------

此参数用于在程序代码中添加gitee用户token，方便后续请求gitee数据，一般取值为$GITEETOKEN，具体示例如下：

.. code-block:: console

    -gt $GITEETOKEN

-pr: pr_num
------------

此参数用于指定对应的pr_id，一般取值为$giteePullRequestid，具体示例如下：

.. code-block:: console

    -pr $giteePullRequestid

-b: branch
-----------

此参数用于指定仓库的具体分支信息，按需填入即可，暂无具体示例。

-chk: checks
-------------

此参数用于解析传入的所有检查内容，将二进制流数据转为json数据最后进行格式化输出，具体传入示例如下:

.. code-block:: console

    $chks

其中chks为jenkins-file中定义的list对象，在每一项检查结束之后会将数据传入到之前定义的STAGES_RES对象中，在进行数据遍历之后生成chks对象，具体示例如下：

.. code-block:: console

    def chks = ""
        for (int i = 0; i < STAGES_RES.size(); ++i) {
            chks = "${chks} -chk ${STAGES_RES[i]}"
        }

