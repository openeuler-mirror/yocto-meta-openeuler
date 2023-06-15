## recipes-jailhouse 目录说明

meta-freertos 层存放 Freertos 相关 demo 文件，recipes-jailhouse 目录为 jailhouse 虚拟化程序在qemu上配合验证的 freertos_demo 程序，从源代码编译构建。

## freertos_demo 在 oebuild中的使用方法

前置依赖添加 Jailhouse：[Jailhouse构建指导](https://openeuler.gitee.io/yocto-meta-openeuler/master/features/jailhouse.html) 

1.1 在编译目录下的compile.yaml文件中添加meta-freertos 层：

```
layers:
- yocto-meta-openeuler/rtos/meta-freertos
```

1.2 添加 jailhouse-freertos 到镜像文件

```
vim src/yocto-meta-openeuler/meta-openeuler/recipes-core/packagegroups/packagegroup-mcs.bb

# 在jailhouse后面追加 jailhouse-freertos，如下：
RDEPENDS_${PN} = " \
${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse jailhouse-freertos', '', d)} \
"
```

1.3 执行构建命令：

```
oebuild bitbake openeuler-image-mcs
```