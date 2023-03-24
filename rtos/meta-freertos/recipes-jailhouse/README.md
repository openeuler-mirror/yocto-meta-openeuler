## recipes-jailhouse 目录说明

meta-freertos 层存放 Freertos 相关 demo 文件，recipes-jailhouse 目录为 jailhouse 虚拟化程序配合验证的 Freertos_demo 程序，从源代码编译构建。

## 使用方法

添加meta-freertos 层：

```shell
bitbake-layers add-layer path/meta-freertos
```

执行构建命令：

```
bitbake jailhouse-freertos
```
