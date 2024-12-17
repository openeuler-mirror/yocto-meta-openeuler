.. _release_index:

版本变更日志
########################

该文档讲解oebuild各版本变更的日志

0.0.30
======

- 修复了0.0.29版本中对于 `generate platform` platform参数默认值不存在的bug，原默认值为aarch64-std，由于openEuler Embedded对于aarch64-std的名称改为qemu-aarch64，因此这里做适配性修改。
- 修复了 `generate -l` 帮助命令的信息，在用户对platform参数或feature参数输错后，会显示 `oebuild generate -l` 命令提示信息，原提示信息未随着该命令的变更而做相应的改动，因此该版本做了修复。