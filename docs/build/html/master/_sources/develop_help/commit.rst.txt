.. _commit_msg:

git commit提交规范
######################################

开发人员通过git commit和gitee pr的形式向openEuler Embedded进行贡献，其中git commit msg需遵循相应的规范。
openEuler Embedded部署了基于 `gitlint <https://jorisroovers.com/gitlint/latest>`_ 的机制来检查git commit是否符合规划，具体的规则位于 :file:`.gitlint` 文件中。

commit msg样式与示例
========================

  commit msg提交规范样式如下(具体规则请看 :ref:`详细说明 <详细说明>` )：

  .. code-block:: shell
  
    header
    <blank line>
    body
    <blank line>
    footer

.. _完整示例1:

  完整示例1：

  .. code-block:: shell

    #此commit仅做示例，非真实commit
    yocto: Update poky-4.0 grammer details

    update yocto grammer: replace '_' with ':' for yocto version stability.
    
    Signed-off-by: zhangsan <zhangsan@163.com>

.. _完整示例2:

  完整示例2：

  .. code-block:: shell

    #此commit仅做示例，非真实commit
    ros2: Fix ros2 sdk bugs for humble     

    * fix ament depend 
    * avoid pythonpath err in colcon
    * fix find_path err in numpy for cross-compile
    
    Fixes: adii232naidf(ros2: Upgrade ros2 sdk for humble)  #假定这是对应产生问题的commit，非真实commit
    Closes: https://gitee.com/openeuler/yocto-meta-openeuler/issues/T7SQ40?from=project-issue   #假设这是要关闭的issue，非真实链接
    Co-developed-by: zhangsan <zhangsan@163.com>    #共同贡献者
    Signed-off-by: zhangsan <zhangsan@163.com>
    Co-developed-by: lisi <lisi@163.com>            #共同贡献者
    Signed-off-by: lisi <lisi@163.com>
    Signed-off-by: lihua <lisi@163.com>             #提交人，共同贡献者之一     

.. _完整示例3:

  完整示例3：

  .. code-block:: shell

    #此commit仅做示例，非真实commit，实际版本更新内容未完全罗列
    yocto!: Update poky version to 4.0(kirkstone)

    * upgrade yocto version, because it can be maintained for longer.

    * Here are the changes made during this upgrade:
      - some variables have changed their names.
      - because of the uncertainty in future default branch names in git repositories, 
        it is now required to add a branch name to all URLs described by git:// and gitsm:// SRC_URI entries. 
      - distutils has been deprecated upstream in Python 3.10 and thus the distutils* classes have 
        been moved to meta-python. Recipes that inherit the distutils* classes should be updated to
        inherit setuptools* equivalents instead.
      - some recipes have been removed.
      - :append/:prepend in combination with other operators.

    Link: https://docs.yoctoproject.org/migration-guides/migration-4.0.html
    Signed-off-by: wangermazi <wangermazi@163.com>

.. _详细说明:

commit msg详细说明
======================

  1. commit msg由三部分组成，分别为 ``header`` ， ``body`` 和 ``footer`` ，每部分都不可少，且 ``header`` 与 ``body`` ， ``body`` 与 ``footer`` 之间都必须有空行，整体commit msg使用英文描述。

  2. ``header`` 行必须有且仅有一行，形式为 ``<area>: <subject>`` , 在冒号后有一个空格，行长度不超过80字符，其中：

    - ``area`` 非空，一般为配方名称，或要更改的文件的简短路径，若同时修改多个配方，也可使用更抽象的属类，比如config, 层的名字，docs等。

    - ``subject`` 非空，应包含对更改的简介描述。必须使用祈使句和现在时态，即不可使用'changed'或'changes',而是使用'change'（具体解释可见 `此 <https://365git.tumblr.com/post/3308646748/writing-git-commit-messages>`_ ）。第一个字母必须大写，不能在末尾加句号，不能包含表情符号，至少包含3个单词。

    - 特殊情况请看 :ref:`第7点 <第7点>` 。 

  3. ``body`` 为提交的详细描述，非空，每行不超过100个字符，不能包含表情符号，并使用祈使句和现在时态。

    - 应包含改变的动机（why），改变的内容（what），怎样改变的（how），并将其与以前的行为进行对比。

    - 如果提交跨5个文件或者50行代码，应在 ``body`` 中描述出来，文档相关的提交除外。

    - 过程中可使用之前的 commit id（SHA-1的前12个字符），需同时带上对应的 ``header`` 信息。

    - 可以使用连字符或星号表示更多段落，同时可以配合使用悬挂缩进，所有段落可适当用空行分开增强可读性。示例见 :ref:`完整示例3 <完整示例3>` 。

  4. ``footer`` 包含一个或多个标签，每个标签为一行（除 ``BREAKING-CHANGE`` 标签），每行标签的形式为 ``<tag-name>: <tag-context>`` ，注意冒号后面有一个空格。标签之间不空行。原则上每行不超过100个字符，除非标签包含完整URL链接等情况.另外 ``footer`` 必须包含 ``Signed-off-by`` 标签，且必须将其作为 ``footer`` 的末尾标签。以下为可使用标签的介绍：

    ``Signed-off-by`` ：社区不允许匿名贡献，每个commiter都必须进行身份确认（需要 `签署CLA <https://www.openeuler.org/zh/community/contribution/detail.html>`_ ）。格式为：
    
    .. code-block:: shell
      
      #commiter-name为提交者的真实姓名拼音，如张三，李四 应分别为 zhangsan,lisi 
      #random@developer.example.org 必须为签署协议时账号绑定的邮箱
      Signed-off-by: commiter-name <random@developer.example.org>

    ``Closes`` ：用于说明该次提交修复了 `issue问题 <https://gitee.com/openeuler/yocto-meta-openeuler/issues>`_ ，标签后带上被修复的issue链接，如果多个issue被修复，则每行写一个issue，如下所示：

    .. code-block:: shell
      
      Closes: https://gitee.com/openeuler/yocto-meta-openeuler/issues/I7SQ40?from=project-issue
      Closes: https://gitee.com/openeuler/yocto-meta-openeuler/issues/I7071W?from=project-issue

    ``Fixes`` ：用于说明该次提交是为了解决之前 commit id 带来的问题，标签后附加之前产生问题的提交，包括其commit id（取SHA-1的前12个字符）和对应的header信息，如下所示（假设解决 :ref:`完整示例2 <完整示例2>` 带来的问题）：

    .. code-block:: shell
    
      Fixes: 54a4f0239f2e(yocto: update poky-4.0 grammer)

    ``Co-developed-by`` ：用于说明代码是由多个开发人员共同贡献，向共同作者提供归属（除了提交者本人）。每个 ``Co-developed-by`` 标签下都必须紧跟 ``Signed-off-by`` 标签，形式为（也可见于 :ref:`完整示例2 <完整示例2>` ）：

    .. code-block:: shell

      Co-developed-by: First Co-Author <first@coauthor.example.org>
      Signed-off-by: First Co-Author <first@coauthor.example.org>
      Co-developed-by: Second Co-Author <second@coauthor.example.org>
      Signed-off-by: Second Co-Author <second@coauthor.example.org>

    ``Link`` ：用于使用附加背景和详细信息的网页对该次提交予以说明，此时，标签后接完整URL，示例如 :ref:`完整示例3 <完整示例3>` 。

    ``BREAKING-CHANGE`` ：用于说明该次提交包含重大变更。标签后应描述更改内容、原因及迁移位置等信息，每行不超过100个字符。示例如下：
    
    .. code-block:: console

      BREAKING-CHANGE: isolate scope bindings definition has changed and
      the inject option for the directive controller injection was removed.
    
      To migrate the code follow the example below:
      
      Before:
      
      scope: {
        myAttr: 'attribute',
        myBind: 'bind',
        myExpression: 'expression',
        myEval: 'evaluate',
        myAccessor: 'accessor'
      }
      
      After:
      
      scope: {
        myAttr: '@',
        myBind: '@',
        myExpression: '&',
        // myEval - usually not useful, but in cases where the expression is assignable, you can use '='
        myAccessor: '=' // in directive's template change myAccessor() to myAccessor
      }

  5. 如需包含重大变更，有两种方式：

    5.1.在 ``footer`` 中加入 ``BREAKNG-CHANGE`` 标签，在标签中描述变更的完整信息。

    5.2.在 ``header`` 行中的冒号前加一个 ``！`` ，并且在 ``body`` 中完整描述重大变更信息。此时不需要再在 ``footer`` 中加入 ``BREAKING-CHANGE`` 标签。在 :ref:`完整示例3 <完整示例3>` 就使用了此方法。

  6. 一次合并请求不能超过10次提交。

.. _第7点:

  7. 如果是进行以往提交的回退，则 ``area`` 填写为revert， ``subject`` 为被回退提交的 commit id 和header信息，在 ``body`` 中应写回退的原因。比如要回退以上 :ref:`完整示例1 <完整示例1>` （假设其commit id前12位为：54a4f0239f2e），则commit msg为：

    .. code-block:: shell
    
      revert: 54a4f0239f2e(yocto: Update poky-4.0 grammer details)

      some reasons for revert.

      Signed-off-by: developer <random@developer.example.org>

本地检查commit msg
===========================

  1. 安装gitlint工具：

    .. code-block:: shell

      $ pip install gitlint

  2. `设置Commit-msg hook <https://jorisroovers.com/gitlint/latest/commit_hooks/>`_ ，使得在每次提交时可按照代码仓根目录下的 :file:`.gitlint` 配置的规则，来自动检查您的提交消息。在代码仓下的任意目录中执行如下命令即可：

    .. code-block:: shell

      $ gitlint install-hook

配置提交模板
===============

  1. 在本地任意位置创建一个模板文件 ``template.txt`` ， 内容填写你想要的模板。以下内容可以作为一个示例模板(记得替换下your-name和your-email为你自己的名字和邮箱)：

    .. code-block:: shell

      area: subject

      *why
      *what
      *how

      Signed-off-by: your-name <your-email>

  2. 执行如下命令之一,选择进行全局配置或者当前代码仓配置，配置git的提交模板:

    .. code-block:: shell

      $ git config --local commit.template /path/to/template.txt   //需在对应代码仓的文件夹下执行，只为该代码仓提交时配置模板
      $ git config --global commit.template /path/to/template.txt  //全局配置该模板

.gitlint文件内容
===================
  
::

    # Edit this file as you like.
    #
    # All these sections are optional. Each section with the exception of [general] represents
    # one rule and each key in it is an option for that specific rule.
    #
    # Rules and sections can be referenced by their full name or by id. For example
    # section "[body-max-line-length]" could also be written as "[B1]". Full section names are
    # used in here for clarity.
    #
    [general]
    # Ignore certain rules, this example uses both full name and id
    # ignore=title-trailing-punctuation, T3

    # verbosity should be a value between 1 and 3, the commandline -v flags take precedence over this
    # verbosity = 2

    # By default gitlint will ignore merge, revert, fixup and squash commits. 
    # ignore-merge-commits=true
    # ignore-revert-commits=true
    # ignore-fixup-commits=true
    # ignore-squash-commits=true

    # Ignore any data send to gitlint via stdin
    # ignore-stdin=true

    # Fetch additional meta-data from the local repository when manually passing a 
    # commit message to gitlint via stdin or --commit-msg. Disabled by default.
    # staged=true

    # Hard fail when the target commit range is empty. Note that gitlint will
    # already fail by default on invalid commit ranges. This option is specifically
    # to tell gitlint to fail on *valid but empty* commit ranges.
    # Disabled by default.
    # fail-without-commits=true

    # Enable debug mode (prints more output). Disabled by default.
    # debug=true

    # Enable community contributed rules
    # See http://jorisroovers.github.io/gitlint/contrib_rules for details
    # contrib=contrib-title-conventional-commits,CC1
    contrib=CC1

    # Set the extra-path where gitlint will search for user defined rules
    # See http://jorisroovers.github.io/gitlint/user_defined_rules for details
    # extra-path=examples/

    # This is an example of how to configure the "title-max-length" rule and
    # set the line-length it enforces to 50
    [title-max-length]
    line-length=72

    # Conversely, you can also enforce minimal length of a title with the
    # "title-min-length" rule:
    [title-min-length]
    min-length=5

    # title cannot have trailing whitespace(space or tab)
    [title-trailing-whitespace]

    # [title-must-not-contain-word]
    # Comma-separated list of words that should not occur in the title. Matching is case
    # insensitive. It's fine if the keyword occurs as part of a larger word (so "WIPING"
    # will not cause a violation, but "WIP: my title" will.
    # words=wip

    [title-match-regex]
    # python-style regex that the commit-msg title must match
    # Note that the regex can contradict with other rules if not used correctly
    # (e.g. title-must-not-contain-word).
    regex=^(([0-9a-zA-Z]|-|_){1,}(: ))(.){1,}$

    [body-max-line-length]
    line-length=80

    [body-min-length]
    min-length=70

    # Body cannot hava trailing whitespace
    [body-trailing-whitespace]

    [author-valid-email]

    [body-first-line-empty]

    # [body-is-missing]
    # Whether to ignore this rule on merge commits (which typically only have a title)
    # default = True
    # ignore-merge-commits=false

    # [body-changed-file-mention]
    # List of files that need to be explicitly mentioned in the body when they are changed
    # This is useful for when developers often erroneously edit certain files or git submodules.
    # By specifying this rule, developers can only change the file when they explicitly reference
    # it in the commit message.
    # files=gitlint-core/gitlint/rules.py,README.md

    # [body-match-regex]
    # python-style regex that the commit-msg body must match.
    # E.g. body must end in My-Commit-Tag: foo
    # regex=My-Commit-Tag: foo$

    # [author-valid-email]
    # python-style regex that the commit author email address must match.
    # For example, use the following regex if you only want to allow email addresses from foo.com
    # regex=[^@]+@foo.com

    # [ignore-by-title]
    # Ignore certain rules for commits of which the title matches a regex
    # E.g. Match commit titles that start with "Release"
    # regex=^Release(.*)

    # Ignore certain rules, you can reference them by their id or by their full name
    # Use 'all' to ignore all rules
    # ignore=T1,body-min-length

    # [ignore-by-body]
    # Ignore certain rules for commits of which the body has a line that matches a regex
    # E.g. Match bodies that have a line that that contain "release"
    # regex=(.*)release(.*)
    #
    # Ignore certain rules, you can reference them by their id or by their full name
    # Use 'all' to ignore all rules
    # ignore=T1,body-min-length

    # [ignore-body-lines]
    # Ignore certain lines in a commit body that match a regex.
    # E.g. Ignore all lines that start with 'Co-Authored-By'
    # regex=^Co-Authored-By

    # [ignore-by-author-name]
    # Ignore certain rules for commits of which the author name matches a regex
    # E.g. Match commits made by dependabot
    # regex=(.*)dependabot(.*)
    #
    # Ignore certain rules, you can reference them by their id or by their full name
    # Use 'all' to ignore all rules
    # ignore=T1,body-min-length

    # This is a contrib rule - a community contributed rule. These are disabled by default.
    # You need to explicitly enable them one-by-one by adding them to the "contrib" option
    # under [general] section above.
    # [contrib-title-conventional-commits]
    # Specify allowed commit types. For details see: https://www.conventionalcommits.org/
    # types = bugfix,user-story,epic