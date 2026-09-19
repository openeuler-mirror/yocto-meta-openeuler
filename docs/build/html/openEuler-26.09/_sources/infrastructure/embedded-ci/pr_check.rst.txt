.. _pr_check:

pr_check获取pr任务范围命令-pr_check
######################################

此命令用于筛选当前代码中的更改，并确定需要执行哪些检查任务，具体示例如下：

在jenkins-file中，我们会对pull_request的一些值设置对应的别名，方便我们动态设置参数值，例如空间使用pull_request.base.repo.namespace，可以设置别名为giteeTargetNameSpace，仓名采用repository.name，可以设置别名为giteeRepoName，其他的如giteetoken，$giteePullRequestid等等都是如此。

-o: owner
----------

此参数用于指定工作空间，一般取值为openeuler，也可以是用户的个人空间，具体示例如下：

.. code-block:: console

    -o openeuler

-p: repo
---------

此参数用于指定具体的gitee仓库名称，按需填写即可，具体示例如下：

.. code-block:: console

    -p repoName

-gt: gitee_token
-----------------

此参数用于指定具体的gitee_token，用于请求gitee的数据信息时使用，一般取值为$GITEETOKEN，具体示例如下：

.. code-block:: console

    -gt $GITEETOKEN

-pr: pr_num
------------

此参数用于指定对应的pr提交id数据，一般取值为$giteePullRequestid，具体示例如下：

.. code-block:: console

    -pr $giteePullRequestid
