.. _clone_repo:

clone_repo拉取对应仓库命令-clone_repo
######################################

此命令主要用于拉取对应仓库的指定分支或者指定pr的代码，拉取完成之后进行后续的代码检查等其他步骤。

clone_repo主要有如下参数：

-r: remote_url
---------------

此参数用于指定对应的远程仓库地址，具体示例如下：

.. code-block:: console

    -r https://gitee.com/openeuler/yocto-meta-openeuler.git

在jenkins-file中，可以动态指定，例如空间使用pull_request.base.repo.namespace，可以设置别名为giteeTargetNameSpace，仓名采用repository.name，可以设置别名为giteeRepoName，因此在jenkins-file中，该参数可以这样设定 -r https://gitee.com/${giteeTargetNameSpace}/${giteeRepoName}。

-w: workspace
--------------

此参数用于指定代码存放的主目录，一般设置为/home/jenkins/agent，具体示例如下：

.. code-block:: console

    -w /home/jenkins/agent

-p: repo
----------

此参数与-w参数结合使用，会在-w指定的目录下创建名为-p对应入参文件夹，将指定的提交拷贝到目录下，此参数一般默认为gitee的仓库名称，具体示例如下：

.. code-block:: console

    -p yocto-meta-openeuler

一般该参数在jenkins-file中使用repository.name，别名可以设置为giteeRepoName，因此可以这样设置该参数-p ${giteeRepoName}。

-pr: pr_num
------------

此参数用于指定gitee中的某次pr提交的id，对于这次提交进行代码拉取，具体示例如下：

.. code-block:: console

    -pr Integer.parseInt(giteePullRequestid)

-v: version
------------

此参数用于指定仓库中的某一版本进行代码拉取，与-pr参数互斥，具体示例如下：

.. code-block:: console

    -v version_name

-dp: depth
-----------

此参数用于指定git clone深度，也就是git对应的depth参数，默认值为1，按照具体需求进行修改，具体示例如下：

.. code-block:: console

    -dp 1

一般clone代码仓会要求将commit提交附带上，以便进行commit检查，因此深度一般单次pr的commit数量相匹配，例如单次pr的commit有4个，那么建议深度也设置为4，在gitee webhook中，commit数量可以使用pull_request.commits指定，可以设置别名为commitCount，那么在jenkins-file中，该参数可以这样设置 -dp Integer.parseInt(${commitCount})。
