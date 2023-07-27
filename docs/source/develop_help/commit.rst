.. _commit_msg:

git commit提交规范
######################################

开发人员通过git commit和gitee pr的形式向openEuler Embedded进行贡献，其中git commit msg需遵循相应的规范。
openEuler Embedded部署了基于 `gitlint <https://jorisroovers.com/gitlint/latest>`_ 的机制来检查git commit是否符合规划，具体的规则位于 :file:`.gitlint` 文件中。

- **commit msg规范**

commit msg提交规范由三部分组成:title, body, foot

title简明说明该次pr提交信息，（：）号前面是模块儿名，后面是简要信息

body详细说明该次提交的信息

foot由固定格式组成,第一部分是Signed-off-by，空格后是开发者用户名，再空格后是开发者邮箱，Signed off信息一般由
git在提交时自动生成。

    script: this is title

    this is body

    Signed-off-by: xxx <xxx@yy.com>

.. _commit_msg_template:

- **范例**

以下是一个提交范例

    yocto: support compile xxx

    support compile xxx, this module is new and deal some archs now not supporting

    Signed-off-by: xxx <xxx@xxx.com>

- **本地检查commit msg**

1.安装gitlint工具：

.. code-block:: shell

  $ pip install gitlint

2. `设置Commit-msg hook <https://jorisroovers.com/gitlint/latest/commit_hooks/>`_ ，使得在每次提交时可按照代码仓根目录下的 :file:`.gitlint` 配置的规则，来自动检查您的提交消息。在代码仓下的任意目录中执行如下命令即可：

.. code-block:: shell

  $ gitlint install-hook

- **配置提交模板**
    
1.在本地任意位置创建一个模板文件template.txt， 内容如 :ref:`范例 <commit_msg_template>` 所示。

2.执行如下命令之一,选择进行全局配置或者当前代码仓配置，配置git的提交模板:

.. code-block:: shell

  $ git config --local commit.template /path/to/template.txt   //需在对应代码仓的文件夹下执行，只为该代码仓提交时配置模板
  $ git config --global commit.template /path/to/template.txt  //全局配置该模板

- **.gitlint文件内容**
  
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