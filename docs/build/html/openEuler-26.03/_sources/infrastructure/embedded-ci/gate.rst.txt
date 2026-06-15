.. _gate:

gate门禁命令-gate
######################################

此命令用于处理拉取请求业务，包括提交信息检查、图像构建等，具体参数信息如下。

在jenkins-file中，我们会对pull_request的一些值设置对应的别名，方便我们动态设置参数值，例如空间使用pull_request.base.repo.namespace，可以设置别名为giteeTargetNameSpace，仓名采用repository.name，可以设置别名为giteeRepoName，其他的如giteetoken，$giteePullRequestid等等都是如此。

-s: share_dir
--------------

此参数用于指定容器的share地址，按需填写即可，具体示例如下：

.. code-block:: console

    -s share_dir

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

-juser: jenkins_user
---------------------

此参数用于指定jenkins用户名，一般取值为$JUSER，按需填写即可，具体示例如下：

.. code-block:: console

    -juser $JUSER

-jpwd: jenkins_pwd
-------------------

此参数用于指定jenkins密码，一般取值为$JPASSWD，按需填写即可，具体示例如下：

.. code-block:: console

    -jpwd $JPASSWD

-b: branch
-----------

此参数用于指定具体的仓库分支，按需填写即可，具体示例如下：

.. code-block:: console

    -b branch_name

-pr: pr_num
------------

此参数用于指定对应的pr提交id数据，按需获取到pr_id填写即可，具体示例如下：

.. code-block:: console

    -pr pr_id

-is_test: is_test
------------------

此参数用于指定是否为测试使用，只需填写参数名，无需指定后续参数，请按需填写，具体示例如下：

.. code-block:: console

    -is_test

