# meta-phytium

## 介绍

该 meta 层为 openEuler Embedded 提供飞腾平台 BSP 支持，目前支持的处理器如下
- FT2000-4
- D2000
- E2000
    - phytiumpi

## 目录结构

* **conf** : machine 描述文件与该 layer 描述文件
* **recipes-core** : 描述镜像成品的格式,目前已支持如下格式:
    - wic (分区镜像)

* **recipes-kernel** : 为 linux-openeuler 内核附加飞腾平台相关 patch
* **wic** : 存放描述 wic 镜像分区布局的 wks 模板文件 (wks.in)
