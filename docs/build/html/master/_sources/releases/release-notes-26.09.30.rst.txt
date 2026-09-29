:orphan:

.. _openeuler_embedded_26_09_30:

openEuler Embedded 26.09
###########################

openEuler Embedded 26.09特性上最大亮点是统一了交叉编译链基础设施并新增ARM32 Clang+musl编译链，
同时将kernel6基线推进到6.6.0-174.0.0，IB-Robot具身智能开发框架完成推理架构整体重构并
新增具身Agent、语音、感知与导航等全栈能力，
并系统性修复了版本测试中发现的一系列问题。

本版的主要更新如下：

* 基础设施

  - 统一交叉编译链体系：GCC/LLVM/Clang+musl三类编译链收拢到toolchains/目录，新增menu.sh
    统一的容器化构建入口，保留旧路径符号链接向后兼容

  - 新增ARM32 Clang+musl交叉编译链，支持qemu-arm musl镜像与hipico等ARM32板卡的构建

  - 移除OPENEULER_PREBUILT_TOOLS预编译主机工具机制，回归Poky标准构建模型；SDK默认输出
    精简模式，可通过OPENEULER_FULL_SDK_ENABLE切换完整模式

* Linux框架

  - kernel6（6.6内核）基线从6.6.0-82.0.0推进到6.6.0-174.0.0，完善qemu-aarch64、树莓派、
    飞腾、x86-64等平台的kernel6支持，修复xsched系统调用链接、RT补丁获取、clang内核
    补丁基线不匹配等问题

  - systemd成为默认init manager，并使能运行时硬件看门狗，修复内核panic后单板
    无法狗复位的问题

  - 标准镜像预置root密码（openEuler@2021），兼顾开箱即用体验，可选恢复首次登录
    改密的安全策略

  - 完善内核配置：riscv64使能NFSD/AUDIT，x86-64使能NFS服务器，清理k3s/kubeedge
    等feature的5.10专属内核选项

  - 组件例行升级与修复：opensbi升级到1.2，pseudo升级到1.9.11，缓解内核CVE-2026-31431

  - 完善镜像体验：新增动态motd与登录banner重构，修复rootfs自动扩容与最小系统
    初始化脚本

* 关键特性

  - IB-Robot具身智能开发框架：围绕具身智能机器人开发完成以下核心更新：

    - 推理服务架构整体重构：以manifest驱动的统一执行管线取代全部历史运行时，
      支持Torch原生、Ascend ACL、RKNN（RK3588）、海思Worker、后摩HMM、ONNX
      Runtime六类后端与分布式云边协同

    - PI0.5端侧部署全链路：VLM/Action-Expert拆分建模、ONNX导出与等价性验证、
      ATC OM转换、W8A8量化，torch_models独立成包并承载Ascend 310P运行时

    - 具身Agent体系：25个技能目录、safety_guard安全防护、robot_skill_cli受控
      CLI网关及自然语言Agent（VLM场景理解与任务规划、多供应商模型路由）

    - 语音全栈能力：voice_tts_service（ZipVoice ONNX）、声源定向（FullSubNet），
      ASR统一到本地sherpa-onnx，语音模型bundle化部署

    - 感知与操作：RGB-D语义建图、开放词表感知（RAM++/GroundingDINO/SAM2）、
      闭环抓取与GraspGen抓取规划（Ascend 310P加速）

    - 移动平台与导航：LeKiwi移动底盘全链路、MID-360激光雷达建图避障（FAST_LIO）、
      D435i+MID-360标定工作流

    - 新增RTP视频传输（Ascend/NVIDIA硬件编解码）与ibrobot_tracing端到端追踪
      及Web性能分析工作台

    - 工程基线：LeRobot受管补丁栈（基线v0.6.0）、CANN 8.1依赖基线、
      OpenHarmony板端发布流水线

* 南北向生态

  - 南向BSP：

    - 新增cv610-ai-ipc机器（基于Hi3516CV610，采用WS73 USB WiFi）

    - 统一飞腾D2000/FT2000-4/PhytiumPi机器配置，内核源迁移至飞腾维护仓库并升级

    - 修复树莓派UEFI headless启动问题，预配置UEFI变量实现免菜单冷启动

    - 完善qemu平台：riscv64的opensbi固件依赖、默认内存调整、tap网络接口名保持等

  - 北向软件：

    - 新增fake-hwclock（无RTC电池板卡断电重启后的时间保持）与GLib ABI兼容性
      检查工具

    - 移除已停止维护的originbot相关软件包
