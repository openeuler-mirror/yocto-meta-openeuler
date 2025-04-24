.. _rust:

Rust支持
######################################

本章介绍openEuler Embedded中对于Rust语言的支持。

为什么选择Rust
---------------------
1. **运行效率**：Rust类似C++，提供了零开销抽象、可以深入底层进行优化的能力。因此Rust的运行效率可以达到C++同一级别，高于Go等需要GC的语言。
#. **内存安全性**：Rust提供了一套基于借用、生命周期等语法用于防止发生内存不安全的行为，编译器会在编译时期就帮助程序员避免大多数错误。
#. **更好的包管理工具**：Rust提供了Cargo工具用于管理Rust项目的构建、下载依赖与分发等。

openEuler Embedded对于Rust工具链的支持
----------------------------------------
目前openEuler Embedded中的Rust工具链主要包含以下组件：

1. ``cargo.bbclass`` ：用于提供yocto构建Rust项目的支持。``cargo.bbclass`` 定义了一系列Task用于构建基于Cargo工具组织的Rust项目，同时也定义了一系列变量支持编译的自定义。Rust项目的recipe可以通过继承`cargo`类，定义一些标准变量就可以实现项目的构建与发布。
#. ``rustc-bin-cross`` 与 ``cargo-bin-cross``：用于引入Rust编译器 ``rustc`` 和包管理工具 ``cargo`` 的recipe，目前是通过官方提供的预编译二进制包完成项目搭建。
#. ``rust-demo``：定义了一个简单的Rust项目用于展示工具链的使用方法。

Rust工具链使用方法
-------------------
首先新建一个recipe用于存放Rust项目的源代码。以下是一个简单的recipe文件内容：

.. code-block:: console

	inherit cargo
	SUMMARY = "Rust simple demo"
	DESCRIPTION = "A demo using openeuler Rust toolchain"
	LICENSE = "MIT"
	LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

	SRC_URI = "file://demo-src"
	S = "${WORKDIR}/demo-src"
	SRCREV = "${AUTOREV}"

首先最重要的是recipe需要继承cargo类 ``inherit cargo`` 这样项目就可以使用Rust工具链去构建安装。之后可以设置yocto常用的变量。

Rust项目应该通过cargo工具进行管理，源代码目录应该遵循以下目录结构：

.. code-block:: console

	demo-src
		├── Cargo.toml

		└── src

			└── main.rs

需要将项目的源文件目录 ``S`` 设置在Rust项目 ``Cargo.toml`` 所在目录，否则会报告无法找到 ``Cargo.toml`` 的错误。需要注意：本例通过 ``file`` 的方式进行fetch，所以将 ``S`` 变量设置为fetch后的文件夹目录。如果你使用git方式去fetch源文件，则需要修改 ``S`` 为 ``${WORKDIR}/git`` （fetch参数默认时）。

如果Rust项目需要通过 ``crate-io`` 拉取依赖项， ``CARGO_CRATES_SOURCE`` 变量提供了一个配置crates替换源的方法，需要设该变量为一个非空值，通过配置该变量的flag进行镜像源的配置，具体可以参考 `Cargo源配置 <https://doc.rust-lang.org/cargo/reference/source-replacement.html>`_。下面是使用 `TUNA镜像 <https://mirrors.tuna.tsinghua.edu.cn/help/crates.io-index.git/>`_ 需要增加的配置：

.. code-block:: console

	CARGO_CRATES_SOURCE = "tuna"
	CARGO_CRATES_SOURCE[registry] = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"


==================== ===============================================================================================
变量名 				   说明
==================== ===============================================================================================
EXTRA_CARGO_FLAGS      额外的传递给 ``cargo`` 的flag
EXTRA_RUSTFLAGS 	   额外的传递给Rust编译器的flag
CARGO_BUILD_TYPE	   构建类型，应该为 ``"--release"`` 或 ``"--debug"``
CARGO_FEATURES 		   一个空格划分的列表，代表需要启用的Cargo特性（详见 ``cargo build --feature ...`` 相关信息）
==================== ===============================================================================================


为什么没有使用openEuler生态中的Rust工具链
---------------------------------------------
目前openEuler源代码 `仓库 <https://gitee.com/src-openeuler/rust/tree/master/>`_ 中提供了Rust工具链的源代码，openEuler发行版也支持安装 ``rustc`` 与 ``cargo`` 工具。但是因为以下原因没有使用：

1. 完全从源代码构建Rust工具链是比较繁琐的。因为 ``rustc`` 还需要构建LLVM编译器后端，整个构建的中间文件可以达到10G级别的大小。参考 `面向嵌入式场景的构建系统Yocto应用与思考 <https://mp.weixin.qq.com/s/zyC9NFu9SAHYBkD3HTrZYA>`_ 中的构建原则，我们更倾向于使用已编译好的包进行构建。
#. openEuler发行版可以安装Rust工具链，但是在x86平台下只能安装x86的 ``rust-std`` Rust标准库，如果需要进行交叉编译，还需要安装目标平台的Rust标准库，因此无法通过本机工具的方法构建

基于以上原因目前使用官方的预编译包。更好的解决办法是openEuler可以提供在x86安装不同平台的Rust标准库的方法，这样既能保证同源，也能减少从源码构建的复杂性。


增加对于新版本Rust工具链的支持
------------------------------
如果需要升级Rust工具链，或是需要特定版本的Rust工具链，可以修改 ``cargo-bin-cross_${PV}.bb`` 和 ``rustc-bin-cross_${PV}.bb`` 为需要的版本，之后将两个bb文件中的安装包获取地址以及校验码更新即可适配新版本工具链。

鸣谢
-------
本特性基于 `meta-rust-bin <https://github.com/rust-embedded/meta-rust-bin>`_ 项目进行开发，遵守开源MIT协议。
