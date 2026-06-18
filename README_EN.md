# yocto-meta-openeuler

## Overview

The build system for openEuler Embedded is based on the Yocto Poky Project. Poky is the reference distribution of the Yocto Project. A key concept in Yocto is the layer model, which groups related recipes into a layer to simplify customization. Recipes in later-added layers can override recipes from previously added layers.

`yocto-meta-openeuler` is a collection of Yocto recipe layers, build tools, and development documentation for building openEuler Embedded. By customizing layers such as `meta-openeuler`, we implement a wide range of optimizations and integrations for openEuler Embedded, including:

- Sharing and co-evolving Linux packages with other openEuler scenarios
- Using prebuilt toolchains and libc libraries to speed up builds
- Reusing prebuilt host tools and containerized builds to improve build efficiency
- Applying optimizations tailored for embedded scenarios

## Directory Structure

 * `scripts`: Helper scripts for setting up the build environment, such as downloading repositories and initializing build configs.

   `meta-openeuler`: Yocto layer for building openEuler Embedded, including related configurations and recipes.

   `bsp`: Board Support Package layer for openEuler Embedded, containing supported hardware platforms such as QEMU and Raspberry Pi 4B.

   `RTOS`: Real-Time Operating System abstraction layer for hybrid Linux + RTOS deployment scenarios. Currently supports RT-Thread and Zephyr.

   `docs`: Documentation for openEuler Embedded usage and development. The documentation is automatically built by CI and published at the following address:

- [**openEuler Embedded Development and Usage Document**](https://pages.openeuler.openatom.cn/embedded/docs/build/html/master/)

## Quick Start

Use oebuild to quickly build openEuler Embedded.

Currently, openEuler Embedded can be built only in the x86 64-bit Linux environment. For details, see the description document:

[**Using oebuild to quickly build openEuler Embedded**](https://pages.openeuler.openatom.cn/embedded/docs/build/html/master/oebuild/index.html)

oebuild automatically clones the repository in the `src` directory by Git. By default, the repository is switched to the latest development branch, that is, `master`.

The following directory structure is automatically generated after the oebuild is built:

```bash
<openEuler Embedded build root (user-created)>
├── build  Build workspace
    ├── output  Generated images
    ├── tmp  Temporary build files
├── src    All openEuler Embedded source packages
```

## Contribution

1. Fork this repository.
2. Create the Feat_xxx branch. (The name corresponds to the feature to be developed.) Each feature uses an independent branch. The advantage is that multiple irrelevant features can be developed at the same time and pull requests are created without affecting each other. This reduces the complexity of code repository management.
3. Commit code.
    
    A qualified `git commit` is as follows. Please describe the relevant information as much as possible, such as the change, reason, and verification. (The contents to be replaced are contained in \[\]. The actual submitted information does not need to contain \[\].)
    
    ```bash
    [module name, e.g. docs]: [git commit msg title (what to change)]
    
    [git commit msg body (detailed explanation of what to change, why to change, and even how to verify)]
    
    Signed-off-by: [name] <[email]>
    ```
    
    This repository uses gitlint to check each `git commit`. You are advised to use [**gitlint**](https://jorisroovers.com/gitlint) avoid CI access check failure.

4. Create a pull request, wait for the review, and merge the code into the repository. (You can choose to delete the branches used for development after the merge.)
