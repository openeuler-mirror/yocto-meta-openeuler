# OpenEuler Nightly Features - 开发者快速上手指南

> 基于最新分层分类机制 (2025年11月重构版本)

## 🚀 什么是 Nightly Features？

Nightly Features 是 OpenEuler 构建系统的功能配置机制，通过 YAML 文件定义构建特性，支持依赖管理、机器兼容性检查和配置片段注入。

## 📁 目录结构

```
.oebuild/nightly-features/
├── containers/          # 容器运行时 (K3s, Docker, containerd等)
├── desktop/            # UI/图形支持 (Qt5, Wayland, X11等)
├── hypervisor/         # 虚拟化底层支持 (Xen, Jailhouse等)
├── kernel/             # 内核相关 (Kernel 6.x, RT内核等)
├── mcs/                # 虚拟化核心组件 (MCS, Micrun, z/VM等)
├── package_manager/    # 包管理器 (EPKG, openEuler Bridge等)
├── robotics/           # 机器人中间件 (ROS 2, AiROS等)
├── system/             # 系统级功能 (调试工具, Web服务等)
└── toolchain/          # 工具链 (Clang, musl, minimal等)
```

## 🛠️ 快速开始

### 1. 创建新特性

在对应分类目录下创建 YAML 文件：

```yaml
# .oebuild/nightly-features/containers/myapp.yaml
id: myapp                          # 特性ID (唯一)
name: My Application              # 显示名称
prompt: Enable My Application     # 菜单描述
machines: [qemu-aarch64]          # 支持的机器 (空=全部)

dependencies: [containers]        # 依赖特性
selects: []                       # 自动选择特性

config:
  layers:                         # Yocto层
    - meta-myapp
  repos:                          # 外部仓库
    - name: myapp-repo
      url: https://github.com/example/myapp.git
  local_conf:                     # local.conf配置
    - 'DISTRO_FEATURES:append = " myapp "'
    - 'MYAPP_VERSION = "1.0"'
```

### 2. 添加子特性

支持在特性内部定义子选项：

```yaml
id: myservice
name: My Service
sub_feats:
  - id: client
    name: Client Only
    config:
      local_conf:
        - 'MYSERVICE_MODE = "client"'
  - id: server
    name: Server Mode
    config:
      local_conf:
        - 'MYSERVICE_MODE = "server"'
        - 'MYSERVER_PORT = "8080"'

one_of: [myservice/client, myservice/server]
default_one_of: myservice/client
```

### 3. 依赖管理

#### 基本依赖
```yaml
dependencies: [containers/k3s]    # 依赖特性可见
```

#### 自动选择
```yaml
selects: [system/debug]           # 启用时自动选择debug
```

#### 单选约束
```yaml
one_of:
  - containers/docker
  - containers/podman
default_one_of: containers/docker
```

## 📋 使用场景示例

### 场景1: 添加容器化应用
```yaml
# containers/mycontainer-app.yaml
id: mycontainer-app
name: My Container App
prompt: Deploy MyApp in containers
machines: [qemu-aarch64, raspberrypi4-64]
dependencies: [containers]
selects: [containers/containerd]
config:
  local_conf:
    - 'DISTRO_FEATURES:append = " mycontainer-app "'
    - 'MYAPP_CONTAINER_IMAGE = "myapp:latest"'
```

### 场景2: 系统服务集成
```yaml
# system/myservice.yaml
id: myservice
name: My System Service
prompt: Enable background system service
sub_feats:
  - id: minimal
    name: Minimal Install
    config:
      local_conf:
        - 'MYSERVICE_INSTALL = "minimal"'
  - id: full
    name: Full Install
    dependencies: [system/webserver]
    config:
      local_conf:
        - 'MYSERVICE_INSTALL = "full"'
        - 'MYSERVICE_WEBUI = "1"'
```

### 场景3: 机器特定配置
```yaml
# kernel/mykernel-mod.yaml
id: mykernel-mod
name: My Kernel Module
machines: [qemu-aarch64, hi3093]  # 仅特定机器
dependencies: [kernel]
config:
  local_conf:
    - 'KERNEL_MODULE_AUTOLOAD:append = " mymodule"'
  # 机器特定配置
  machine_overrides:
    hi3093:
      local_conf:
        - 'MYMODULE_HARDWARE = "hi3093-specific"'
```

## 🔧 高级特性

### self 关键字
使用 `self/` 引用当前特性命名空间：
```yaml
id: init-manager
selects: [self/busybox, self/systemd]
sub_feats:
  - id: busybox
  - id: systemd
```

### 机器兼容性
```yaml
machines: []           # 所有机器支持
machines: [qemu-aarch64, raspberrypi4-64]  # 指定机器
```

### 配置类型
- `layers`: 包含的Yocto层
- `repos`: 外部Git仓库
- `local_conf`: local.conf片段

## ⚡ 常用命令

### 生成配置
```bash
oebuild generate -f containers/k3s -m qemu-aarch64
```

### 菜单配置
```bash
oebuild generate menuconfig
```

### 验证特性
```bash
# 检查语法
python -c "import yaml; yaml.safe_load(open('your-feature.yaml'))"

# 验证依赖关系
oebuild features validate
```

## 🎯 最佳实践

### 1. 命名规范
- ID使用小写字母和连字符: `my-feature`
- 分类目录使用复数: `containers`, `systems`
- 文件名与ID一致: `my-feature.yaml`

### 2. 依赖设计
- 最小化依赖: 只依赖真正需要的特性
- 避免循环依赖
- 使用 `selects` 谨慎，避免过度自动选择

### 3. 机器支持
- 明确指定支持的机器
- 使用空列表表示支持所有机器
- 考虑不同架构的兼容性

### 4. 配置管理
- local.conf片段保持简洁
- 使用变量而非硬编码
- 提供合理的默认值

## 🚨 常见问题

### Q: 特性在menuconfig中不可见？
**A**: 检查依赖项是否满足，机器是否在支持列表中

### Q: 依赖冲突如何处理？
**A**: 使用 `one_of` 约束互斥特性，合理设计依赖链

### Q: 如何调试特性加载？
**A**: 使用 `oebuild features list` 查看可用特性状态

### Q: 机器特定配置怎么做？
**A**: 在 `config` 下添加 `machine_overrides` 部分

## 📚 相关文档

- [完整规范](README.md) - 详细的YAML格式和依赖系统说明
- [架构设计](README.md#dependency-graph-rules) - 依赖图规则和可见性链
- [示例集合](README.md#example-complete-feature-definition) - 完整特性定义示例

## 🔗 快速参考

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | string | ✅ | 特性唯一标识 |
| `name` | string | ❌ | 显示名称 (默认=id) |
| `category` | string | ❌ | 分类验证 |
| `prompt` | string | ❌ | 菜单描述 |
| `machines` | list | ❌ | 支持的机器 |
| `dependencies` | list | ❌ | 依赖特性 |
| `selects` | list | ❌ | 自动选择 |
| `one_of` | list | ❌ | 单选约束 |
| `config` | dict | ❌ | 配置信息 |

---

**💡 提示**: 本文档基于2025年11月重构的新机制，旧版 `.oebuild/features/` 已废弃，请使用新的分层分类结构。