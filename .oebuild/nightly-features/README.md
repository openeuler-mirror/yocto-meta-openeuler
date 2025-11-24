# Neo oebuild feature generation specifications

> **Core Feature**: 
> 1. Systemetic
>     Dependency handling is integrated into the bitbake global variables settings procedure.
> 2. Simple
>     Handle only positive dependencies and simple conflicts(may be no conflict handling)  , 
>     we do not handle complex negative dependencies such as conflicts,
>     conflicts should be handled in bitbake recipes

Features are stored as individual YAML files organized by category directories. The directory structure serves as the source of truth for categorization.

## Feature Categories


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
  * when **category_id** is euqal to **leaf_id**, `<category_id>/<leaf_id>` can be shorten to be a prefix `<category_id>` 
  ```
  mcs dir contains mcs.yaml, which id is mcs/mcs
  hence we can shorten it to mcs, and mcs/mcs/micrun can be mcs/micrun
  ``` 


### 2\. Feature Schema

#### Core Meta

  * **`id`** (Required): The leaf identifier of the feature. id cannot be "self"
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
      * **Usage**: Must be used to define items before they can be referenced in **Selection Controls** (`one_of`, `choice`).
      * **non-recursive**: Recursive sub_feat is **forbidden**

#### Choice Controls

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
  
  Constraints Proposal (Not Introduced Yet) 
      
  * **conflicts**: **Global Exclusion**.
  
      * List of Feature IDs.
      * Supported Syntax: Full IDs, or self/ references to sub-features.
      * Logic: If any feature listed here is currently Enabled (or selected to be enabled), the current feature cannot be enabled.
      * Usage: Used to define mutual exclusivity between features that are not siblings (i.e., not covered by one_of).
      * NOTICE: we can avoid conflicts key by add a new feature layer:
      > for example, mcs/baremetal, mcs/xen, mcs/jailhouse should be exclusive and mcs must select one of them
      > we can use mcs/ped, defining these pedestal as sub_feats of mcs/ped, and set one_of to achive the goal
      > mcs/ped.one_of: `[self/xen, self/baremetal, self/jailhouse]`
  
  NOTICE: it is no need to introduce conflict keyword in
  
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
    name: isulad container engine
    config:
       local_conf:
         - 'VIRTUAL-RUNTIME_container_engine:append = "isulad"'
  
  - id: containerd
    name: containerd container engine
    config:
       local_conf:
         - 'VIRTUAL-RUNTIME_container_engine:append = "containerd"'

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

### 6. Feature with Global Conflicts

```yaml
# File: nightly-features/system/network-manager.yaml
id: dummy-zvm
prompt: dummy zvm conflict example


conflicts:
  - yocto/packagegroup-kernel-modules  # Cannot coexist with systemd-networkd
  - self                # Just an example: maybe the main daemon conflicts with its own wifi sub-feat in some weird mode
```

# oebuild generate cli spec



# CLI & Interaction Specification

To ensure a seamless experience between the CLI (`oebuild generate`) and the Menuconfig TUI, the system relies on a **Declarative** input model and a shared **State Artifact**.

## 1\. Unified State Management

Both the CLI and Menuconfig must operate on a single "Source of Truth" to ensure interoperability. They do not write directly to `local.conf` immediately; instead, they modify a feature state file.

  * **oebuild geneate** compatibility
  * **Artifact Path**: `<build_dir>/compile.yaml`
  * **Workflow**:
    1.  **Load**: Parser reads all Feature YAMLs
    2.  **Modify**: Apply CLI arguments (`-f`) or User Interface changes.
    3.  **Resolve**: Execute the **Resolution Algorithm** (Dependency/Logic checks).
    4.  **Save**: Write to `compile.yaml` this part of generaion logic should be compatible with oebuild generate, which geneate compile.yaml
    5.  **Generate**: detailed configuration is written to `local.conf` / `bblayers.conf` based on the finalized state.

## 2\. CLI Command Interface

The CLI treats feature selection as a declaration of intent.

### Syntax

```bash
oebuild generate -p <machine> [-f <feature_identifier>]...
```

### Identifier Resolution Rules

The CLI accepts flexible identifiers to maximize user convenience. The parser must resolve them in the following strict order:

1.  **Exact Full ID Match**:
      * Input: `mcs/mica` -\> Matches `mcs/mica`.
      * Input: `mcs/mica/xen` -\> Matches sub-feature `xen` under `mcs/mica`.
2.  **Unique Leaf ID Match**:
      * Input: `k3s` -\> Scans all features. If only `containers/k3s` exists, match it.
      * *Error Condition*: If both `containers/k3s` and `networking/k3s` exist, abort with **Ambiguity Error**.
3.  **Duplcated prefix Short Match**:
      * Input: `mcs` prefix -\> consider as  `mcs/mcs` if there is mcs feature located under category mcs.
      * Non-recursive handling
      * when **category_id** is euqal to **leaf_id**, `<category_id>/<leaf_id>` can be shorten to be a prefix `<category_id>` 
4.  **Sub-feature Short Match**:
      * Input: `xen` -\> If `hypervisor/xen` exists, match it. If `mcs/mica/xen` (sub-feature) is the only other `xen`, match it.
      * *Priority*: Top-level features take precedence over sub-features if names collide.

## 3\. Resolution Algorithm (The Brain)

When a feature is requested via CLI, the parser must execute the following logic sequence:

### Step A: Visibility & Machine Check

Before enabling any feature `F`:

1.  Check `F.machines`. If the current machine is not supported, **Abort** with error.
2.  If `F` is a sub-feature, recursively check its Parent's machine support.

### Step B: Dependency Expansion (Auto-Resolution)

Conflict logics are just dummy, leave a space for future, do not really do those conflicts dep calculation:

0. **Conflict Check** (Pre-flight):
> Before enabling feature F, check its conflicts list.
> If any feature C in F.conflicts is already in the Enabled Set:
> Abort with Conflict Error: "Cannot enable 'F' because it conflicts with enabled feature 'C'."
> Symmetry Check: Also check if any already enabled feature E lists F in its conflicts.
1.  **Enable F**. Add `F` to the Enabled Set.
2.  **Dependencies**: For each ID in `F.dependencies`, recursively execute **Step A** and **Step B**.
3.  **Selects**: 
> For each ID in `F.selects`, recursively execute **Step A** and **Step B**.
> Note: If a selects target triggers a Conflict Error, the entire operation fails.
4.  **Auto Parent Selection**: If `F` is a sub-feature, automatically **Enable its Parent**.

### Step C: `one_of` / `choice` Logic

Handling selections within a feature group (e.g., Hypervisors in `mcs/mica`):

1.  **User Priority**: Explicit CLI arguments (`-f xen`) **always override** defaults.
2.  **Conflict Detection**:
      * If a `one_of` group has multiple options enabled via explicit CLI args (e.g., `-f baremetal -f xen`), **Abort** with **Conflict Error**.
3.  **Default Fallback**:
      * If a `one_of` group has **NO** options selected by the user, and **NO** options selected by `selects` from other features:
          * Apply `default_one_of` (if defined).
          * If no default is defined, leave it empty (unless logic requires it, in which case, warn).


## 4\. Error Handling Standards

The parser must provide actionable error messages.

### Case 1: Ambiguity

```text
[Error] Ambiguous feature ID: 'debug'
Candidates:
  - system/debug
  - mcs/debug
Please use the Full ID (e.g., -f system/debug).
```

### Case 2: Machine Incompatibility

```text
[Error] Feature 'xen' is not supported on machine 'raspberrypi4'.
Trace:
  - Requested: mcs/mica
  - Selected: mcs/mica/xen (User Input)
  - Constraint: xen requires machine [qemu-aarch64, x86-64]
```

### Case 3: Mutually Exclusive Conflict

```text
[Error] Conflict in feature 'mcs/mica':
You requested both 'baremetal' and 'xen', but they are mutually exclusive (one_of).
```

## oebuild generate options

### list

now `oebuild neo-generate --list` remains flatten, which is terrible to read:

```
│ hypervisor/jailhouse                   hi3093, kp920, ok3568, qemu-aarch64, raspberrypi4-64         │
│ hypervisor/xen                         kp920, phytiumpi, qemu-aarch64                               │
│ kernel/kernel6                         all                                                          │
│ kernel/rt                              all                                                          │
│ mcs/mica                               hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│ mcs/mica-rtos                          hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│ mcs/mica-rtos/uniproton                hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│ mcs/mica-rtos/zephyr                   hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│ mcs/mica/baremetal                     hi3093, hieulerpi1, kp920, ok3568, qemu-aarch64,             │
│                                        raspberrypi4-64, x86-64                                      │
│ mcs/mica/jailhouse                     hi3093, kp920, ok3568, qemu-aarch64, raspberrypi4-64         │
│ mcs/mica/xen                           phytiumpi, qemu-aarch64                                      │
│ mcs/micrun                             phytiumpi, qemu-aarch64  
```

what we want is indentation by depth 

```

│ mcs
│ - mcs/mica                              hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│  - mcs/mica/baremetal                     hi3093, hieulerpi1, kp920, ok3568, qemu-aarch64,             │
│                                        raspberrypi4-64, x86-64                                      │
│  - mcs/mica/jailhouse                     hi3093, kp920, ok3568, qemu-aarch64, raspberrypi4-64         │
│  - mcs/mica/xen                           phytiumpi, qemu-aarch64                                      │
│  - mcs/mica-rtos                         hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│   - mcs/mica-rtos/uniproton              hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│   - mcs/mica-rtos/zephyr                hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│ - mcs/micrun                             phytiumpi, qemu-aarch64  
```



# Additional Current implementation requirements

* due to undetermined conflict rules, I remained a simple conflict handling logic branch, 
  leave a placeholder for *conflict*.
  and I'm not really calculating conflicts, this is an unstable syntax
  
* implementation the new oebuild generate in oebuild/app/plugins/neo-generate  
  

# Yocto global variables readjustment

## mcs variables

TODO
