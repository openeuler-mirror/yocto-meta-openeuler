# workflows简介

workflows承载着整个openEuler Embedded基础设施相关的自动化控制脚本，里面包含有门禁运行脚本、CI运行脚本、CI失败补偿运行脚本、gcc交叉编译链发布脚本、llvm交叉编译链发布脚本以及nativesdk发布脚本，下面将依次介绍各个脚本的作用以及相应工程的承载环境。所有的jenkinsfile运行在jenkins的pipline工程中，由流水线来指定，以下将详细给出如何创建基本的pipline工程。

> 注意：jenkins环境的搭建请自行学习，查找，这里不做细述。

1. 创建pipline工程

   在创建好的目录下，在左边的菜单栏点击"新建Item"，接下来会弹出一个会话框，提示输入一个任务名称，自行输入任务名称，然后在下面任务类型列表中选择Pipline类型，然后点击"确定"。

2. 构建触发器设置

   构建触发器的作用是用于触发该任务的执行机制，这里我们经常用到的有两种，一种是定时构建，另一种是webhook触发。

3. 选定执行jenkinsfile

   在流水线模块中可以定制需要执行的jenkinsfile脚本，在定义中有两种，一种是选定"Pipeline script"，此时在下方的输入框中直接填入jenkinsfile，这样的方式适用于在线调试时随时能够更改脚本，另一种是"Pipeline script from SCM"，顾名思义，jenkinsfile取自SCM（软件配置管理），此时选定下方SCM的来源为git，然后输入相关的配置参数，有以下配置参数根据具体情况填写：

   - Repository URL：用于填写git的仓的地址
   - Credentials：如果对应的git仓需要凭证，则该配置参数需要进行配置
   - Branches to Build：用户指定仓的分支，一般为"\*/master"，可以根据具体情况设置为其他分支，具体格式为"\*/xxx"
   - 脚本路径：该参数用于指定在检出的仓下要执行的jenkinsfile脚本的具体路径，以仓的路径为根目录，不可以带仓名，例如jenkinsfile的真实路径是yocto-meta-openeuler/.oebuild/workflows/jenkinsfile_gate，则该参数应设置为".oebuild/workflows/jenkinsfile_gate"

4. 设定外部变量

   因为脚本的执行需要一系列外部变量，有外部变量的作用是为了脚本执行更加的灵活，例如如果是门禁，则需要知道来源于哪个源码仓，提交的pr ID是多少，评论区的评论是什么等等，其他也一样，这里我们有两种方式来设定外部变量，一种直接在构建时设定的变量，另一种是webhook传入的变量，这两种方式都可以设定某个变量的值在jenkinsfile中运行，外部变量在jenkinsfile中的引用语法一般为"$"或"${}"，例如外部变量名为NAME，则jenkinsfile中引用此变量的方式为"\$NAME"或"${NAME}"，推荐第二种。

   - 直接在构建时设定的变量：在general中选择列表下面的"This project is parameterized"，在点击添加参数下来列表按钮，在弹出的变量类型中有bool值，单选，字符串等等，这里不做详细介绍，我们用字符串来讲解，选定字符串后在弹出的虚线框中"String Parameter"标明这是在设定字符串变量，下面的名称即为要设定的变量名，例如可以设定"NAME"，再下面的默认值即为要设定的变量值

   - webhook传入的变量：在构建触发器列表下选择"Generic Webhook Trigger"，在新弹出的页面下点击新增"Post content parameters"，在弹出的虚线框即为一个变量设定的内容，以下将详细介绍虚线框中各个字段的意义：

     - Variable：变量名，即需要定义的变量名称

     - Expression：取值表达类型，该字段意思为从什么数据结构中获取字段，有两种数据结构，一种是JSONPath，代表从json数据结构中获取值，另一种是XPath，代表从xml数据结构中获取值

       这里以一个简单的json数据来对取值做演示：

       json数据：

       ```
       {
       	"aaa":{
       		"bbb": {
       			"nnn": "kkk"
       		}
       	}
       }
       ```

       则获取nnn的值的方式为"$.aaa.bbb.nnn"，获取省略$直接使用"aaa.bbb.nnn"，xml格式同理

     - Value filter：对相应的值取正则，这里填写正则匹配项

     - Default value：默认值，即如果不存在相应的值则选择默认值

>注意：以下所有外部变量的取值，涉及到webhook的都以gitee的webhook的数据结构为准。

## jenkinsfile_gate

该脚本用于门禁的运行，其运行需要有外部条件触发，触发条件是在评论区输入"Hi"或者"/retest"即可触发，门禁的stage运行流程如下：

- clone embedded-ci

  下载功能函数库，功能函数库在前期检查中需要用到，主要是对一些常用的行为动作做了统一封装。

- pre

  前置检查，该检查会先查看是否有正在进行的同pr任务，如果有则停止。然后执行pr_check功能，pr_check将会对提交的代码进行筛查，筛查结果将被赋值到env.pr_check_result，主要有文档编译与镜像编译，如果提交代码涉及到文档，则会记录docs，如果提交代码涉及到纯代码，则会记录code，下一步会根据传入的结果来确定执行什么样的任务。

- code check

  提交信息检查，该检查主要针对commit信息是否符合规范进行检查，主要分两项，一项是commit_msg，另一项是commit_scope，commit_msg检查单个commit提交信息是否符合规范，commit_scope检查单个commit是否存在文档与代码同时提交，需要注意的是我们并不允许单次commit同时提交文档与代码。

- check task

  任务运行，该stage会将编译相关的任务以并行的方式执行，在执行并行任务之前，会对"code check"结果进行判断，如果"code check"检查结果为True，则执行并行任务，否则不执行，以下则对并行stage做介绍：

  - docs：执行文档构建
  - qemu_aarch64：执行qemu-aarch64的基础OS构建
  - qemu_aarch64_tiny：执行qemu-aarch64-tiny的OS构建
  - qemu_arm：执行qemu-arm的基础OS构建
  - qemu_x86：执行x86-64的基础OS构建

- post 阶段

  该阶段表示无论前面"check task"以何种状态结束，都会执行的动作，主要是对前面的任务结果做最终整理，并将整理结果发布到对应的pr评论区下。

>注意：运行节点调用的容器镜像为swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-ci-test

其依赖的外部变量列表如下：

| 变量名               | 变量值/默认值                               | 说明                                           |
| -------------------- | ------------------------------------------- | ---------------------------------------------- |
| giteeRepoName        | repository.name                             | 触发webhook的仓名                              |
| giteePullRequestid   | pull_request.number                         | 提交pr的ID号                                   |
| giteeSourceBranch    | pull_request.head.ref                       | 提交pr的分支名                                 |
| giteeTargetBranch    | pull_request.base.ref                       | 要合入的目标分支                               |
| giteeSourceNamespace | pull_request.head.repo.namespace            | 提交pr的namespace                              |
| giteeTargetNamespace | pull_request.base.repo.namespace            | 要合入的目标namespace                          |
| giteeCommitter       | pull_request.user.login                     | pr提交者                                       |
| comment              | comment.body                                | 评论内容                                       |
| commitCount          | pull_request.commits                        | 此pr提交的commit数                             |
| embeddedRemote       | https://gitee.com/openeuler/embedded-ci.git | 运行脚本需要的功能库                           |
| embeddedBranch       | master                                      | 运行脚本需要的功能库分支名                     |
| node                 | xxxx                                        | 运行任务的节点名                               |
| giteeId              | xxxx                                        | 目标分支的管理者ID                             |
| jenkinsId            | xxxx                                        | jenkins的管理者ID，用于对一些jenkins任务做管理 |

## jenkinsfile_ci

该脚本用于CI的运行，主要由两个任务stage组成，一个是"init task"，其主要作用是下载功能函数库"embedded-ci"，另一个是"build task"，其下分布5个并行的stage，每个stage会构建相应的OS镜像。具体构建的OS镜像不再展开细述，请直接参考stage名就可以看出。这里将对每个构建stage的流程做详细讲解：

1. 下载yocto-meta-openeuler源码
2. 生成随机数，为了后期日志文件名的命名
3. 创建日志存放目录
4. 执行OS构建任务，这里需要注意的是，OS构建应用的功能函数库中openeuler-image功能，该功能专门对openEuler Embedded的OS构建做了封装，详细参数请查看embedded-ci
5. 将OS二进制发布件发送到远程服务器
6. 删除编译目录，这是由于每个jenkins节点在启动后会分配容量有限的空间，yocto本身的运行机制会产生大量的文件，会占用大量的空间，如果不进行删除，后续的编译任务将会由于空间不足而失败

>注意：运行节点调用的容器镜像为swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-ci-test

其依赖的外部变量列表如下：

| 变量名          | 变量值/默认值                               | 说明                                           |
| --------------- | ------------------------------------------- | ---------------------------------------------- |
| embeddedRemote  | https://gitee.com/openeuler/embedded-ci.git | 运行脚本需要的功能库                           |
| embeddedBranch  | master                                      | 运行脚本需要的功能库分支名                     |
| node            | xxxx                                        | 运行任务的节点名                               |
| giteeId         | xxxx                                        | 目标分支的管理者ID                             |
| jenkinsId       | xxxx                                        | jenkins的管理者ID，用于对一些jenkins任务做管理 |
| repoNamespace   | openeuler                                   | openEuler 源码空间名                           |
| repoName        | yocto-meta-openeuler                        | openEuler源码仓名                              |
| ciBranch        | master                                      | CI执行的源码分支名                             |
| remoteIP        | xxx                                         | CI执行完二进制发布件发送的目标平台IP           |
| remoteUname     | xxx                                         | CI执行完二进制发布件发送的目标平台用户名       |
| remoteID        | xxx                                         | CI执行完二进制发布件发送的目标平台登录密钥     |
| remoteDir       | xxx                                         | CI执行完二进制发布件发送到目标平台的           |
| mugenRemote     | https://gitee.com/openeuler/mugen.git       | openEuler 测试框架mugen仓                      |
| mugenBranch     | master                                      | openEuler 测试框架mugen分支名                  |
| commentRepoName | yocto-meta-openeuler                        | CI结果发送仓，结果以issue方式承载              |

## jenkinsfile_ci_input

该脚本用于CI失败的补偿任务，其作用是CI目前承担的OS构建任务非常多，当有一些不确定性的因素导致CI失败后需要重新编译，我们此时只需要编译失败的OS镜像即可，该脚本即用于此。该工程与CI工程总体上一致，唯一的区别是每个构建OS的stage由条件触发，这个条件是外部输入参数IMAGE_NAME是否与stage相等，如果相等则执行，否则放行，而IMAGE_NAME即为需要补偿构建的参数。

>注意：运行节点调用的容器镜像为swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-ci-test

其依赖的外部变量列表如下：

| 变量名          | 变量值/默认值                               | 说明                                           |
| --------------- | ------------------------------------------- | ---------------------------------------------- |
| embeddedRemote  | https://gitee.com/openeuler/embedded-ci.git | 运行脚本需要的功能库                           |
| embeddedBranch  | master                                      | 运行脚本需要的功能库分支名                     |
| node            | xxxx                                        | 运行任务的节点名                               |
| giteeId         | xxxx                                        | 目标分支的管理者ID                             |
| jenkinsId       | xxxx                                        | jenkins的管理者ID，用于对一些jenkins任务做管理 |
| repoNamespace   | openeuler                                   | openEuler 源码空间名                           |
| repoName        | yocto-meta-openeuler                        | openEuler源码仓名                              |
| ciBranch        | master                                      | CI执行的源码分支名                             |
| remoteIP        | xxx                                         | CI执行完二进制发布件发送的目标平台IP           |
| remoteUname     | xxx                                         | CI执行完二进制发布件发送的目标平台用户名       |
| remoteID        | xxx                                         | CI执行完二进制发布件发送的目标平台登录密钥     |
| remoteDir       | xxx                                         | CI执行完二进制发布件发送到目标平台的           |
| mugenRemote     | https://gitee.com/openeuler/mugen.git       | openEuler 测试框架mugen仓                      |
| mugenBranch     | master                                      | openEuler 测试框架mugen分支名                  |
| commentRepoName | yocto-meta-openeuler                        | CI结果发送仓，结果以issue方式承载              |
| IMAGE_NAME      | xxx                                         | 需要构建的OS镜像名                             |

## jenkinsfile_llvm_release

该脚本应用于llvm toolchain版本发布，类似于门禁工程，需要由外部条件触发，这里的外部条件是在评论区输入"/llvm_toolchain_release"评论即可触发。llvm_toolchain版本发布stage流程如下：

- check release

  版本检测，llvm的版本发布需要由pr进行控制，并且对pr的格式有一定的要求，这里要求pr的标题一定是"版本升级到xxx"，而该stage即为检测此pr是否是版本发布的pr，如果是则将env.is_release置为true，否则置为false，接下来下面所有的stage都是围绕着env.is_release为true来执行。

- download repo

  下载相关代码仓，这里主要是两个，一个是功能函数库"embedded-ci"，另一个是yocto-meta-openeuler源码，这里的源码版本为pr提出时的版本。

- download aarch64 chans

  下载openeuler-aarch4的编译链，这是因为llvm的构建需要用到aarch64的编译链。

- prepare source

  准备源码，这一步只是执行了./prepare.sh脚本，该脚本的作用是下载编译llvm需要的依赖库或者源码。

- build llvm toolchain

  执行llvm 交叉编译链的编译，详细步骤不再细述。

- release llvm-toolchain

  llvm版本发布，该流程会调用功能函数库中create_release功能来进行二进制版本发布，而版本发布平台为gitee上openEuler 源码仓。

>注意：运行节点调用的容器镜像为swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk-ci

其依赖的外部变量列表如下：

| 变量名               | 变量值/默认值                               | 说明                                           |
| -------------------- | ------------------------------------------- | ---------------------------------------------- |
| embeddedRemote       | https://gitee.com/openeuler/embedded-ci.git | 运行脚本需要的功能库                           |
| embeddedBranch       | master                                      | 运行脚本需要的功能库分支名                     |
| node                 | xxxx                                        | 运行任务的节点名                               |
| giteeId              | xxxx                                        | 目标分支的管理者ID                             |
| jenkinsId            | xxxx                                        | jenkins的管理者ID，用于对一些jenkins任务做管理 |
| giteePullRequestid   | pull_request.number                         | 提交pr的ID号                                   |
| giteeSourceBranch    | pull_request.head.ref                       | 提交pr的分支名                                 |
| giteeTargetBranch    | pull_request.base.ref                       | 要合入的目标分支                               |
| giteeSourceNamespace | pull_request.head.repo.namespace            | 提交pr的namespace                              |
| giteeTargetNamespace | pull_request.base.repo.namespace            | 要合入的目标namespace                          |
| giteeCommitter       | pull_request.user.login                     | pr提交者                                       |
| comment              | comment.body                                | 评论内容                                       |
| commitCount          | pull_request.commits                        | 此pr提交的commit数                             |
| pull_action          | $.action                                    | pr的行为，例如已合入，等待合入等               |
| pr_title             | pull_request.title                          | pr标题                                         |

## jenkinsfile_nativesdk_release

该脚本应用于nativesdk版本发布，类似于门禁工程，需要由外部条件触发，这里的外部条件是在评论区输入"/nativesdk_release"评论即可触发。nativesdk版本发布stage流程如下：

- check release

  版本检测，nativesdk的版本发布需要由pr进行控制，并且对pr的格式有一定的要求，这里要求pr的标题一定是"版本升级到xxx"，而该stage即为检测此pr是否是版本发布的pr，如果是则将env.is_release置为true，否则置为false，接下来下面所有的stage都是围绕着env.is_release为true来执行。

- download repo

  下载相关代码仓，这里主要是两个，一个是功能函数库"embedded-ci"，另一个是yocto-meta-openeuler源码，这里的源码版本为pr提出时的版本。

- build sdk

  执行nativesdk的构建。

- release nativesdk

  nativesdk版本发布，该流程会调用功能函数库中create_release功能来进行二进制版本发布，而版本发布平台为gitee上openEuler 源码仓。

>注意：运行节点调用的容器镜像为swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-ci-test

其依赖的外部变量列表如下：

| 变量名               | 变量值/默认值                               | 说明                                           |
| -------------------- | ------------------------------------------- | ---------------------------------------------- |
| embeddedRemote       | https://gitee.com/openeuler/embedded-ci.git | 运行脚本需要的功能库                           |
| embeddedBranch       | master                                      | 运行脚本需要的功能库分支名                     |
| node                 | xxxx                                        | 运行任务的节点名                               |
| giteeId              | xxxx                                        | 目标分支的管理者ID                             |
| jenkinsId            | xxxx                                        | jenkins的管理者ID，用于对一些jenkins任务做管理 |
| giteePullRequestid   | pull_request.number                         | 提交pr的ID号                                   |
| giteeSourceBranch    | pull_request.head.ref                       | 提交pr的分支名                                 |
| giteeTargetBranch    | pull_request.base.ref                       | 要合入的目标分支                               |
| giteeSourceNamespace | pull_request.head.repo.namespace            | 提交pr的namespace                              |
| giteeTargetNamespace | pull_request.base.repo.namespace            | 要合入的目标namespace                          |
| giteeCommitter       | pull_request.user.login                     | pr提交者                                       |
| comment              | comment.body                                | 评论内容                                       |
| commitCount          | pull_request.commits                        | 此pr提交的commit数                             |
| pull_action          | $.action                                    | pr的行为，例如已合入，等待合入等               |
| pr_title             | pull_request.title                          | pr标题                                         |

## jenkinsfile_toolchain_release

该脚本应用于gcc toolchain版本发布，类似于门禁工程，需要由外部条件触发，这里的外部条件是在评论区输入"/toolchain_release"评论即可触发。gcc_toolchain版本发布stage流程如下：

- check release

  版本检测，gcc的版本发布需要由pr进行控制，并且对pr的格式有一定的要求，这里要求pr的标题一定是"版本升级到xxx"，而该stage即为检测此pr是否是版本发布的pr，如果是则将env.is_release置为true，否则置为false，接下来下面所有的stage都是围绕着env.is_release为true来执行。

- download repo

  下载相关代码仓，这里主要是两个，一个是功能函数库"embedded-ci"，另一个是yocto-meta-openeuler源码，这里的源码版本为pr提出时的版本。

- prepare source

  准备源码，这一步执行了prepare.sh与update.sh脚本，该脚本的作用是下载编译gcc需要的依赖库或者源码。

- build toolchain

  执行gcc交叉编译链的编译，详细步骤不再细述。

- package toolchain

  对gcc编译产物进行打包。

- release gcc-toolchain

  gcc版本发布，该流程会调用功能函数库中create_release功能来进行二进制版本发布，而版本发布平台为gitee上openEuler 源码仓。

>注意：运行节点调用的容器镜像为swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk-ci

其依赖的外部变量列表如下：

| 变量名               | 变量值/默认值                               | 说明                                           |
| -------------------- | ------------------------------------------- | ---------------------------------------------- |
| embeddedRemote       | https://gitee.com/openeuler/embedded-ci.git | 运行脚本需要的功能库                           |
| embeddedBranch       | master                                      | 运行脚本需要的功能库分支名                     |
| node                 | xxxx                                        | 运行任务的节点名                               |
| giteeId              | xxxx                                        | 目标分支的管理者ID                             |
| jenkinsId            | xxxx                                        | jenkins的管理者ID，用于对一些jenkins任务做管理 |
| giteePullRequestid   | pull_request.number                         | 提交pr的ID号                                   |
| giteeSourceBranch    | pull_request.head.ref                       | 提交pr的分支名                                 |
| giteeTargetBranch    | pull_request.base.ref                       | 要合入的目标分支                               |
| giteeSourceNamespace | pull_request.head.repo.namespace            | 提交pr的namespace                              |
| giteeTargetNamespace | pull_request.base.repo.namespace            | 要合入的目标namespace                          |
| giteeCommitter       | pull_request.user.login                     | pr提交者                                       |
| comment              | comment.body                                | 评论内容                                       |
| commitCount          | pull_request.commits                        | 此pr提交的commit数                             |
| pull_action          | $.action                                    | pr的行为，例如已合入，等待合入等               |
| pr_title             | pull_request.title                          | pr标题                                         |

