.. _diff_files:

diff_files差异文件获取命令-diff_files
######################################

此命令用于获取某一次提交中的分支与比对分支的具体文件差异，来进行后续提交文件代码规范检查，具体有如下参数。

在jenkins-file中，我们会对pull_request的一些值设置对应的别名，方便我们动态设置参数值，例如空间使用pull_request.base.repo.namespace，可以设置别名为giteeTargetNameSpace，仓名采用repository.name，可以设置别名为giteeRepoName，其他的如giteetoken，$giteePullRequestid等等都是如此。

-r: repo_dir
------------

此参数用于指定容器中的gitee仓库地址，一般取值为/home/jenkins/agent/$giteeRepoName，具体示例如下：

.. code-block:: console

    -r /home/jenkins/agent/$giteeRepoName

--remote_name: remote_name
---------------------------

此参数用于指定远程仓库分支目录名，一般默认值为origin，可按需更改，具体示例如下：

.. code-block:: console

    --remote_name origin

--pre_branch
-------------

此参数用于指定pr提交经过fetch后的分支名称，一般取值为pr_$giteePullRequestid，具体示例如下：

.. code-block:: console

    --pre_branch pr_$giteePullRequestid

--diff_branch: diff_branch
---------------------------

此参数用于指定进行比对的分支，一般默认为master分支，可按需更改，具体示例如下：

.. code-block:: console

    --diff_branch master
