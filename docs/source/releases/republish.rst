.. _republish:

商业发行版发行说明
################################

本章介绍第三方公司发行openEuler嵌入式商业发行版的要求和建议，具体如下：

1. 要求：

 (1) 要求基于openEuler嵌入式代码工程制作，软件包可以随意裁剪与增加( `构建指导 <https://embedded.pages.openeuler.org/master/yocto/index.html>`_ )

2. 建议：

 (1) 关键软件包版本（例如glib） 和配置（例如内核PAGE_SIZE大小） 和openEuler保持一致。
 (2) 开发工具链推荐使用openEuler嵌入式官方发行版本。
 (3) 采用嵌入式特有 `安全加固规则 <https://embedded.pages.openeuler.org/master/linux/security/index.html>`_
 (4) 发行版提供面向具体行业的镜像文件（内核镜像和rootfs） 和开发工具链。
