# Neo oebuild feature generation specifications

> **Core Feature**: Dependency handling is integrated into the `local.conf` and `bblayers.conf` generation procedure.

Features are stored as individual YAML files organized by category directories. The directory structure serves as the source of truth for categorization.

## Feature Categories

`categories.yaml`

  - **`mcs/`**: Virtualization and multi-tenant core components (MCS, Micrun, z/VM, etc.)
  - **`containers/`**: Container runtime support (containerd/isulad/docker/podman) and Kubernetes helpers.
  - **`system/`**: Init managers, debug tooling, OpenBMC, webserver stacks.
  - **`robotics/`**: Robotics middleware stacks (ROS 2, AiROS).
  - **`kernel/`**: Kernel series overrides (Kernel 6.x, RT kernel).
  - **`desktop/`**: UI/graphics support (Qt5, OpenGL, Wayland, X11).
  - **`toolchain/`**: Compiler and libc options (Clang, musl).
  - **`package_manager/`**: Package managers (EPKG, openEuler bridge).
  - **`hypervisor/`**: Low-level hypervisor options referenced by `mcs/` selections.

## YAML Feature Specification

### 1\. File Structure & Identification

  * **Directory Structure**: `nightly-features/<category_id>/<leaf_id>.yaml`
  * **Category ID**: Derived directly from the directory name.
  * **Feature ID (Leaf)**: Defined in the `id` field of the YAML.
  * **Full ID**: `<category_id>/<leaf_id>` (Globally unique identifier).

### 2\. Feature Schema

#### Core Meta

  * **`id`** (Required): The leaf identifier of the feature.
  * **`name`**: Display name in menuconfig (defaults to `id` if not specified).
  * **`prompt`**: Description shown in menuconfig interface.
  * **`machines`**: List of supported machines.
      * Empty list `[]` or omitted implies **all machines**.
      * **Recursive Rule**: If a feature does not support a machine, it and all its sub-features/dependents become invisible for that machine.

#### Configuration Injection (`config`)

Defines what is injected into the Yocto build environment.

  * **`config`**:
      * **`local_conf`**: List of strings appended to `conf/local.conf`.
      * **`layers`**: List of strings appended to `conf/bblayers.conf`.

#### Hierarchy & Organization (`sub_feats`)

  * **`sub_feats`**: A **List** of feature objects defined inline.
      * **Visibility**: Visible only when the parent is enabled. Default state is **unchecked** (unless selected by logic).
      * **Usage**: Must be used to define items before they can be referenced in `one_of` or `choice`.

#### Selection Controls

  * **`one_of`**: **Mandatory Single Choice**.

      * **Format**: List of Feature IDs (Strings).
      * **Constraint**: **No inline YAML definitions**. All items must be defined in `sub_feats` or be external features.
      * **`default_one_of`**: The ID of the default selection.

  * **`choice`**: **Optional Multiple Selection**.

      * **Format**: List of Feature IDs (Strings).
      * Allows selecting 0 to N options.

#### Dependency Management

  * **`dependencies`**: **Prerequisites**.

      * List of Feature IDs.
      * **Logic**: If *any* dependency is disabled (or unsupported by machine), this feature is **hidden**.

  * **`selects`**: **Auto-select**.

      * List of Feature IDs.
      * **Logic**: If this feature is enabled, all listed features are **automatically enabled**.

### 3\. The `self` Keyword

  * **Usage**: Used in `dependencies`, `selects`, `one_of`, and `choice` fields.
  * **Resolution**: Replaced at parse time with the current feature's namespace.
      * Example: `self/baremetal` inside `mcs/mica.yaml` resolves to `mcs/mica/baremetal`.

-----

## Dependency Graph Rules (Strict Mode)

### 1\. Visibility Chain Principle

A feature is **Visible** in the menu if and only if:

1.  It is supported by the target **Machine**.
2.  All its **`dependencies`** are satisfied (Enabled).
3.  Its **Parent** (if it is a sub-feature) is Enabled.

### 2\. Machine Support Propagation

If a dependency does not support the current machine, the dependent feature is strictly hidden.

-----

## Examples

### 1\. Simple Feature

*File: `nightly-features/package_manager/oebridge.yaml`*

```yaml
id: oebridge
name: oebridge
prompt: Enable openEuler binary package fetching
# machines: [] -> Implies all machines supported

config:
  local_conf:
    - 'DISTRO_FEATURES:append = " oebridge"'
    - 'SERVER_MIRROR = "https://mirrors.tuna.tsinghua.edu.cn/openeuler"'
    - 'SERVER_VERSION = "openEuler-24.03-LTS"'
    - 'GLIBC_GENERATE_LOCALES:append = "en_US.UTF-8 zh_CN.UTF-8"'
```

### 2\. Feature with Dependencies & Auto-Select

*File: `nightly-features/containers/k3s.yaml`*

```yaml
id: k3s
name: K3s Kubernetes
prompt: Enable K3s (default k3s-agent)
machines: [qemu-aarch64, phytiumpi]

dependencies:
  - containers

selects:
  - self/k3s-agent
  - self/k3s-server

config:
  layers:
    - yocto-meta-virtualization
  local_conf:
    - 'DISTRO_FEATURES:append = " k3s-agent "'

sub_feats:
  - id: k3s-agent
    name: K3s Agent
    config:
      local_conf:
        - 'DISTRO_FEATURES:append = " k3s-agent "'

  - id: k3s-server
    name: K3s Server
    config:
      local_conf:
        - 'DISTRO_FEATURES:append = " k3s-server "'
```

### 3\. Feature with `one_of` (Restructured)

*File: `nightly-features/mcs/mica.yaml`*

```yaml
id: mica
name: MCS, Mixed Criticality System
prompt: Enable the MCS virtualization stack
machines: [qemu-aarch64, raspberrypi4-64, hi3093, ok3568, kp920, x86-64, hieulerpi1]

config:
  layers:
    - yocto-meta-openeuler/rtos/meta-openeuler-rtos
    - yocto-meta-openeuler/rtos/meta-zephyr
  local_conf:
    - 'DISTRO_FEATURES:append = " mcs "'
    - 'RPI_USE_UEFI:raspberrypi4-64 = "1"'

# 1. Define sub-features first
sub_feats:
  - id: baremetal
    name: Baremetal (openAMP)
    dependencies: [hypervisor/baremetal]
    config:
      local_conf:
        - 'MCS_FEATURES ?= "openamp"'

  - id: xen
    name: Xen virtualization
    dependencies: [hypervisor/xen]
    config:
      local_conf:
        - 'MCS_FEATURES ?= "xen"'

  - id: jailhouse
    name: Jailhouse
    dependencies: [hypervisor/jailhouse]
    config:
      local_conf:
        - 'MCS_FEATURES ?= "jailhouse"'

# 2. Reference them by ID
one_of:
  - self/baremetal
  - self/xen
  - self/jailhouse

default_one_of: self/baremetal
```

### 4\. Feature with `sub_feats` and `choice`

*File: `nightly-features/containers/containers.yaml`*

```yaml
id: containers
name: Container host support
prompt: Enable container tooling
machines: [qemu-aarch64, phytiumpi, raspberrypi4-64, x86-64]

config:
  local_conf:
    - 'DISTRO_FEATURES:append = " virtualization "'

# Define sub-features
sub_feats:
  - id: isulad
    name: iSulaD
    config:
       local_conf:
         - 'CONTAINER_rUNTIME = "isulad"'
  
  - id: containerd
    name: containerd
    config:
       local_conf:
         - 'CONTAINER_rUNTIME = "containerd"'

  - id: download
    name: Manually download container engine
    prompt: >
      Use manually downloaded container engine at runtime
      do not build it in image

# Optional multi-selection
choice:
  - self/isulad
  - self/containerd
  - self/download
```

### 5\. Feature with Machine Restrictions

*File: `nightly-features/toolchain/clang.yaml`*

```yaml
id: clang
name: Clang toolchain
prompt: Enable the Clang toolchain
machines: [qemu-aarch64, raspberrypi4-64, x86-64]

config:
  layers:
    - yocto-meta-openeuler/meta-clang
  local_conf:
    - 'DISTRO_FEATURES:append = " clang ld-is-lld"'
    - 'DISTRO_FEATURES_NATIVE:append = " clang "'
    - 'EXTERNAL_TOOLCHAIN_CLANG_BIN = "${EXTERNAL_TOOLCHAIN_LLVM}/bin"'
```

# Yocto global variables readjustment

## mcs variables

TODO
