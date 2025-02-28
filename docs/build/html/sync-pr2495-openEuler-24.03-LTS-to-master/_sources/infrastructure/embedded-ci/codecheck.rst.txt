.. _codecheck:

codecheck代码检查命令-codecheck
######################################

此命令可以针对pr中的commit_scope，commit_msg和代码规范进行检查，通过在jenkins中设置不同的检查项来进行不同的检查。

在jenkins-file中，我们会对pull_request的一些值设置对应的别名，方便我们动态设置参数值，例如空间使用pull_request.base.repo.namespace，可以设置别名为giteeTargetNameSpace，仓名采用repository.name，可以设置别名为giteeRepoName，其他的如giteetoken，$giteePullRequestid等等都是如此。

具体命令参数如下：

-c: check_code
---------------

此参数用于指定jenkins中的代码仓地址，用于检查对应仓库中某次pr的代码规范，也可以不做选择，具体示例如下：

.. code-block:: console

    -c /home/jenkins/agent/$giteeRepoName

-target: target
----------------

此参数用于指定具体执行哪一项检查，目前有commit_msg，commit_scope及code_check检查。其中commit_msg用于检查提交信息是否合规，commit_scope用于检查提交文件是否合规，code_check用于检查提交代码是否合规。

具体示例如下：

.. code-block:: console

    -target [commit_msg commit_scope code_check]

-o: owner
-------------

此参数用于指定gitee空间，默认为openeuler，也可以是用户的个人空间，一般取值为$giteeTargetNamespace，具体示例如下：

.. code-block:: console

    -o $giteeTargetNamespace

-p: repo
------------

此参数用于指定具体仓库名称，一般取值为$giteeRepoName，具体示例如下：

.. code-block:: console

    -p $giteeRepoName

-gt: gitee_token
-----------------

此参数用于获取gitee的token信息用于获取gitee请求权限，一般取值为$GITEETOKEN，具体示例如下：

.. code-block:: console

    -gt $GITEETOKEN

-pr: pr_num
-------------

此参数用于当前需要检查的pr_id，一般取值为$giteePullRequestid，具体示例如下：

.. code-block:: console

    -pr $giteePullRequestid

-dfs: diff_files
-----------------

此参数用于指定差异文件，一般用于选项为code_check时，来检查对应差异文件的代码提交是否合规，一般取值为"$diff_files"，具体示例如下：

.. code-block:: console

    -dfs "$diff_files"


上述参数设置完毕后，一般会在命令结尾指定log日志存放地址，具体示例如下：

.. code-block:: console

    > ${logDir}/${randomStr}.log

其中logDir为jenkins-file中设置的指定值，randomStr为对应方法生成的uuid。
