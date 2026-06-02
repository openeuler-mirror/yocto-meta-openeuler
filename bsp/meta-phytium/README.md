# meta-phytium

## 介绍

该 meta 层为 openEuler Embedded 提供飞腾平台 BSP 支持，目前支持飞腾处理器如下:

- D3000M
- S5000C
- FT2000-4
- D2000
- E2000
- phytiumpi

## 目录结构

```
├── classes
│   └── image_types_genimage.bbclass    # 自定义镜像类，封装genimage镜像 
├── conf                                # 层配置、机型硬件配置目录
│   ├── layer.conf                      # Layer 全局配置、层依赖、加载规则
│   └── machine                         # 飞腾machine描述文件
├── custom-licenses                     # 自定义开源许可证存放目录
│   └── PPL-1.0                         # PPL-1.0 许可证文本
├── genimage                            # genimage 分区布局配置模板
│   ├── efi-phytium.config              # 飞腾平台 EFI 启动镜像分区配置
│   ├── sdcard-phytium.config           # 飞腾板卡 SD 卡镜像分区配置
├── README.md                           # 层使用、编译、适配说明文档
├── recipes-bsp                         # 板级支持包(BSP)相关
│   ├── grub                            # GRUB 引导程序定制
│   └── phyuboot                        # 飞腾 U-Boot 引导固件
├── recipes-core 
│   └── images                          # 系统镜像配方，产出不同格式镜像
│               - genimage  (精细控制分区偏移,对齐,多镜像拼接)
│               - iso  (安装盘）（飞腾派不支持）
│               - wic  (标准分区镜像)
├── recipes-devtool                     # 镜像制作依赖工具
│   ├── confuse
│   ├── genext2fs
│   └── genimage
├── recipes-kernel                      # 内核相关配方，为openEuler内核追加飞腾平台补丁
│   └── linux
│       ├── files                       # 内核补丁、配置文件等附属文件
│       ├── linux-openeuler.bbappend    # 标准内核
│       ├── linux-openeuler-rt.bbappend # 实时内核
│       └── linux-phytium.inc           # 内核公共配置
└── wic 
    └── efi-image-phytium.wks           # WIC 镜像制作脚本
```

## 定制化构建

支持编译SD卡镜像(只适用于飞腾派开发板，其他开发板请忽略)

在local.conf.sample 里添加变量如下变量

```
$ vim src/yocto-meta-openeuler/.oebuild/local.conf.sample
$ MACHINE_FEATURES += " sd"
```
