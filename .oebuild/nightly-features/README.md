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

the sample of categories: 
  - **`mcs/`**: Virtualization and multi-tenant core components (MCS, Micrun, z/VM, etc.)
  - **`containers/`**: Container runtime support (containerd/isulad/docker/podman) and Kubernetes helpers.
  - **`system/`**: Init managers, debug tooling, OpenBMC, webserver stacks.
  - **`robotics/`**: Robotics middleware stacks (ROS 2, AiROS).
  - **`kernel/`**: Kernel series overrides (Kernel 6.x, RT kernel).
  - **`desktop/`**: UI/graphics support (Qt5, OpenGL, Wayland, X11).
  - **`toolchain/`**: Compiler and libc options (Clang, musl).
  - **`package_manager/`**: Package managers (EPKG, openEuler bridge).
  - **`hypervisor/`**: Low-level hypervisor options, may be referenced by `mcs/` selections.

## YAML Feature Specification

### File Structure & Identification

  * **Directory Structure**: `nightly-features/<category_id>/<leaf_id>.yaml`
  * **Category ID**: Derived directly from the directory name.
  * **Feature ID (Leaf)**: Defined in the `id` field of the YAML.
  * **Full ID**: `<category_id>/<leaf_id>` (Globally unique identifier).
  * **Category Root Feature ID** when **category_id** is euqal to **leaf_id**, `<category_id>/<leaf_id>` can be shorten to be a prefix `<category_id>` 
  ```
  mcs dir contains mcs.yaml, which id shoule be mcs/mcs, but due to this rule, the id must be mcs, not mcs/mcs
  and mcs.yaml sub_feats baremetal, should be mcs/baremetal, not mcs/mcs/baremetal!
  ``` 


### Feature Schema

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
      > we can use mcs, defining these pedestal as sub_feats of mcs, and set one_of to achive the goal
      > mcs .one_of: `[self/xen, self/baremetal, self/jailhouse]`
  
  NOTICE: it is no need to introduce conflict keyword in
  
### The `self` Keyword

  * **Usage**: Used in `dependencies`, `selects`, `one_of`, and `choice` fields.
  * **Resolution**: Replaced at parse time with the current feature's namespace.
      * Example: `self/A` inside `B/BB.yaml`(id=BB) resolves to `B/BB/A`.
      * Example: `self/A` inside `B/BB.yaml`（id=B) resolves to `B/A`.

-----

## Dependency Graph Rules (Strict Mode)

### Visibility Chain Principle

A feature is **Visible** in the menu if and only if:

1.  It is supported by the target **Machine**.
2.  All its **`dependencies`** are satisfied (Enabled).
3.  Its **Parent** (if it is a sub-feature) is Enabled.

### Machine Support Propagation

If a dependency does not support the current machine, the dependent feature is strictly hidden.

-----

## Examples

### Simple Feature

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
    - 'IMAGE_INSTALL:append = " glibc-binary-localedata-en-us glibc-binary-localedata-zh-cn "'
```

### Feature with Dependencies & Auto-Select

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

### Feature with `one_of` (Restructured)

*File: `nightly-features/mcs/mcs.yaml`*

```yaml
id: mcs
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

### Feature with `sub_feats` and `choice`

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

### Feature with Machine Restrictions

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


# Implementation Specification

To ensure a seamless experience between the CLI (`oebuild generate`-compatible) and the Menuconfig TUI, the system relies on a **Declarative** input model and the same Artifact (`compile.yaml`)

  * **oebuild geneate** cli compatibility
  * **Artifact Path**: the same `<build_dir>/compile.yaml`
  * **Workflow**:
    1.  **Load**: Parser reads all Feature YAMLs
    2.  **Modify**: Apply CLI arguments (`-f`) or User Interface changes.
    3.  **Resolve**: Execute the **Resolution Algorithm** (Dependency/Logic checks).
    > for menuconfig mode, the resolution is with a dynamic kconfig file generation procedure
    4.  **Save**: Write to `compile.yaml` this part of generaion logic should be compatible with oebuild generate, which geneate compile.yaml

## CLI Command Interface

The CLI treats feature selection as a declaration of intent.

### TL;DR

Too long; Don't Read.

just learn oebuild generate(neo-generate) examples below:

```sh
oebuild generate -p <machine> [-f <feature_identifier>]... [-d <build_dir>]
oebuild neo-generate -p <machine> [-f <feature_identifier>]... -d <build_dir>
```

```sh
# generate xen-based-mica, and with oebridge, for hi3591
oebuild generate -p hi3591 -f mcs -f xen -f oebridge
oebuild neo-generate -p hi3591 -f mcs/xen -f oebridge

# generate micrun
oebuild generate -p qemu-aarch64 -f micrun -f mcs -f xen -f containers
oebuild neo-generate -p qemu-aarch64 -f micrun 

# generate qemu-aarch64 target, install k3s-server
oebuild generate -p qemu-aarch64 -f k3s -d target; 
cd target; sed -i 's/k3s-agent/k3s-server/g' ./compile.yaml
oebuild generate -p qemu-aarch64 -f k3s-server -d target; 
oebuild bitbake openeuler-image # found conflicts when building!


# generate qemu-aarch64 target, install both k3s-server and k3s-agent
oebuild generate -p qemu-aarch64 -f k3s -d target;
cd target;
sed '/k3s-agent/a\ k3s-server' ./compile.yaml

oebuild neo-generate -p qemu-aarch64 -f k3s-server -f k3s-agent -d target;  # Error! k3s-agent and k3s-server are conflicting

```


### Identifier Resolution Rules

The CLI accepts flexible identifiers to maximize user convenience. The parser must resolve them in the following strict order:

1.  **Exact Full ID Match**:
      * Input: `mcs/mcs` -\> Matches `mcs/mcs`.
      * Input: `mcs/mcs/xen` -\> Matches sub-feature `xen` under `mcs/mcs`.
2.  **Unique Leaf ID Match**:
      * Input: `k3s` -\> Scans all features. If only `containers/k3s` exists, match it.
      * *Error Condition*: If both `containers/k3s` and `networking/k3s` exist, abort with **Ambiguity Error**.
3.  **Category feature**: 
      This is kind of "syntax sugar"  rule, 
      When category id equals to root feature id, this feature becames the category root feature, whose full id is the `<category_id`, instead of `<category_id>/<same_feat_id>`
      And root features has highest priority, see example below:
      * dir FEAT
      |---- FEAT.yaml, define sub_feat XA, XA full id is `FEAT/XA`, FEAT is root category
      |---- FEATB.yaml, define sub_feat XB, XB full id is `FEAT/FEATB/XB`
      |---- XA.yaml,id=XA     # not allowed, because full id is `FEAT/XA.yaml`, conflict with FEAET.XA
      |---- XB.yaml,id=XB     # allowed, because XB full id is `FEAT/XB`
      
      User can spell the feature without repeat the name, 
      * Input: `mcs/xen` is like `mcs/(mcs)/xen`, when there is a mcs category, a mcs feature, with a `sub_feat` called xen
      * Input: `mcs` is like `mcs/(mcs)`, when there is a mcs category, a mcs feature, in this case, the feature can be matched by *Rule3* as well,
        match both the rules, if two results is different, abort with **Ambiguity Error** message about the conflicts
    
4.  **Sub-feature Short Match**:
      * Input: `xen` -\> If `hypervisor/xen` exists, match it. If `mcs/mcs/xen` (sub-feature) is the only other `xen`, match it.
      * *Priority*: Top-level features take precedence over sub-features if names collide.
      
## Error Handling Standards

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
  - Requested: mcs/mcs
  - Selected: mcs/mcs/xen (User Input)
  - Constraint: xen requires machine [qemu-aarch64, x86-64]
```

### Case 3: Mutually Exclusive Conflict

```text
[Error] Conflict in feature 'mcs/mcs':
You requested both 'baremetal' and 'xen', but they are mutually exclusive (one_of).
```

## list options modification

now `oebuild neo-generate --list` prints features tree instead of flat list

```
│ mcs
│ - mcs/mcs                              hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│  - mcs/mcs/baremetal                     hi3093, hieulerpi1, kp920, ok3568, qemu-aarch64,             │
│                                        raspberrypi4-64, x86-64                                      │
│  - mcs/mcs/jailhouse                     hi3093, kp920, ok3568, qemu-aarch64, raspberrypi4-64         │
│  - mcs/mcs/xen                           phytiumpi, qemu-aarch64                                      │
│  - mcs/mcs-rtos                         hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│   - mcs/mcs-rtos/uniproton              hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│   - mcs/mcs-rtos/zephyr                hi3093, hieulerpi1, kp920, ok3568, phytiumpi, qemu-aarch64,  │
│                                        raspberrypi4-64, x86-64                                      │
│ - mcs/micrun                             phytiumpi, qemu-aarch64  
```
