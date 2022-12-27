.. _commit_msg:

git commit提交规范
######################################

开发人员通过git commit和gitee pr的形式向openEuler Embedded进行贡献，其中git commit msg需遵循相应的规范。
openEuler Embedded部署了基于gitlint的机制来检查git commit是否符合规划，具体的规则位于 :file:`.gitlint` 文件中。

- **commit msg规范**

commit msg提交规范由三部分组成:title, body, foot

title简明说明该次pr提交信息，（：）号前面是模块儿名，后面是简要信息

body详细说明该次提交的信息

foot由固定格式组成,第一部分是Signed-off-by，空格后是开发者用户名，再空格后是开发者邮箱，Signed off信息一般由
git在提交时自动生成。

    script: this is title

    this is body

    Signed-off-by: xxx <xxx@yy.com>

- **范例**

以下是一个提交范例

    yocto: support compile xxx

    support compile xxx, this module is new and deal some archs now not supporting

    Signed-off-by: xxx <xxx@xxx.com>
