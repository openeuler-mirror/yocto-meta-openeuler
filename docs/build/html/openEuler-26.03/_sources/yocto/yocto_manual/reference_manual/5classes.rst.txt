.. _5_classes:

========
5 类文件
========

类文件用于抽象通用功能并在多个配方（.bb）文件中共享。要使用类文件，只需确保配方继承了该类。在大多数情况下，当配方继承一个类时，启用其功能就足够了。然而，在某些情况下，您可能需要在配方中设置变量或覆盖某些默认行为。

通常在配方中找到的任何元数据也可以放在类文件中。类文件通过扩展名
.bbclass 进行标识，通常放置在 Source Directory 下的 meta*/
目录的一组子目录之一：

- classes-recipe/ - 旨在单独由配方继承的类

- classes-global/ - 旨在全局继承的类

- classes/ - 使用上下文未明确定义的类

类文件也可以通过 BUILDDIR（例如 build/）指向，与 conf 目录中的 .conf
文件相同。类文件通过与搜索 .conf 文件相同的方法在 BBPATH 中进行搜索。

本章仅讨论最有用和重要的类。Source Directory 中的 meta/classes\*
目录中确实存在其他类。您可以直接引用 .bbclass 文件以获取更多信息。

5.1 allarch 类
===============

allarch
类被继承给不产生特定于架构的输出的配方。该类禁用了通常需要用于生成可执行二进制文件的配方的功能（例如，在构建交叉编译器和
C 库作为先决条件，并在打包过程中拆分调试符号）。

.. note:: 

    与某些发行版配方（例如 Debian）不同，通过使用 RDEPENDS 和
    TUNE_PKGARCH 变量来依赖调整的 OpenEmbedded
    配方，不应配置为所有架构使用
    allarch。即使配方不产生特定于架构的输出，这也是正确的。

    将此类配方配置为所有架构会导致具有不同调整的机器的 `do_package_write_\*`
    任务具有不同的签名。此外，即使配方从未更改，每次构建不同 MACHINE
    的映像时都会发生不必要的重建。

默认情况下，所有配方都继承 base 和 package
类，这些类启用了生成可执行输出所需的功能。如果您的配方仅生成包含配置文件、媒体文件或脚本（例如
Python 和 Perl）的包，则应继承 allarch 类。

5.2 archiver 类
================

archiver 类支持在二进制文件发布时同时发布源代码和其他材料。

有关 source archiver 的更多详细信息，请参阅 Yocto Project Development
Tasks Manual
中的“\ `在产品生命周期中维护开源许可合规性 <https://docs.yoctoproject.org/dev-manual/licenses.html#maintaining-open-source-license-compliance-during-your-product-s-lifecycle>`__\ ”部分。您还可以查看
ARCHIVER_MODE
变量以获取有关帮助控制存档创建的变量标志（varflags）的信息。

5.3 autotools 类
=================

autotools\* 类支持使用 GNU Autotools 构建的软件包。

autoconf、automake 和 libtool
软件包带来了标准化。这个类定义了一组任务（例如 configure、compile
等），适用于所有使用 Autotools
的软件包。通常只需定义一些标准变量，然后简单地继承 autotools
类就足够了。这些类也可以与模拟 Autotools
的软件一起使用。有关更多信息，请参阅 Yocto Project Development Tasks
Manual 中的“构建一个 Autotooled Package”部分。

默认情况下，autotools\* 类使用 out-of-tree 构建（即 autotools.bbclass 在
B != S 的情况下构建）。

如果配方构建的软件不支持使用 out-of-tree 构建，您应该让配方继承
autotools-brokensep 类。autotools-brokensep 类的行为与 autotools\*
类相同，但在 B == S 的情况下构建。当 out-of-tree
构建支持不存在或损坏时，这种方法很有用。

.. note:: 

   如果可能的话，建议修复并使用 out-of-tree 支持。

了解由 autotools\* 类定义的任务如何工作以及它们在幕后做了什么是有用的。

- do_configure — 重新生成 configure 脚本（使用
   autoreconf），然后使用交叉编译期间使用的标准参数集启动它。您可以通过
   EXTRA_OECONF 或 PACKAGECONFIG_CONFARGS 变量向 configure
   传递额外参数。

- do_compile — 运行 make 命令，并指定编译器和链接器的参数。您可以通过
   EXTRA_OEMAKE 变量传递额外的参数。

- do_install — 运行 make install 命令，并将 ${D} 作为 DESTDIR
   传递进去。

5.4 base 类
============

base 类是特殊的，因为每个 .bb
文件都会隐式地继承该类。这个类包含了一些标准基本任务的定义，例如获取、解压缩、配置（默认为空）、编译（运行任何存在的
Makefile）、安装（默认为空）和打包（默认为空）。这些任务通常被其他类（如
autotools\* 类或 package 类）覆盖或扩展。

该类还包含一些常用的函数，例如 oe_runmake，它使用在 EXTRA_OEMAKE
变量中指定的参数以及直接传递给 oe_runmake 的参数来运行 make。

5.5 bash-completion
====================

为构建包含 bash-completion 数据的配方设置适当的打包和依赖项。

5.6 bin_package 类
====================

bin_package 类是帮助配方提取二进制包（例如
RPM）的内容并安装这些内容，而不是从源代码构建二进制文件的辅助类。二进制包被提取，然后创建配置输出包格式的新包。提取和安装专有二进制文件是一个很好的使用此类的例子。

.. note:: 

    对于不包含子目录的 RPM 和其他软件包，您应该指定适当的 fetcher
    参数以指向子目录。例如，如果 BitBake 使用的是 Git
    fetcher（git://），则“subpath”参数将检出限制为树的特定子路径。以下是一个示例，其中
    ${BP} 用于使文件提取到预期的默认值 S 的子目录中：

   ::

      SRC_URI = "git://example.com/downloads/somepackage.rpm;branch=main;subpath=${BP}"

   有关支持的 BitBake Fetchers 的更多信息，请参阅 BitBake User Manual
   中的“Fetchers”部分。

5.7 binconfig 类
=================

binconfig 类有助于纠正 shell 脚本中的路径。

在 pkg-config 成为主流之前，库会提供 shell
脚本来提供有关构建软件所需的库和包含路径的信息（通常命名为
LIBNAME-config）。此类可帮助任何使用此类脚本的配方。

在暂存期间，OpenEmbedded 构建系统将此类脚本安装到 sysroots/
目录中。继承此类会导致这些脚本中的所有路径更改为指向 sysroots/
目录，以便所有使用该脚本的构建都使用交叉编译布局的正确目录。有关更多信息，请参阅
BINCONFIG_GLOB 变量。

5.8 binconfig-disabled 类
==========================

binconfig 类的替代版本，通过使它们返回错误来禁用二进制配置脚本，从而使用
pkg-config 查询信息。要禁用的脚本应在继承该类的配方中使用 BINCONFIG
变量指定。

5.9 buildhistory 类
=====================

buildhistory类记录构建输出元数据的历史，该元数据可用于检测可能的回归，也可用于分析构建输出。有关使用构建历史的更多信息，请参阅Yocto项目开发任务手册中的“\ `维护构建输出质量 <https://docs.yoctoproject.org/dev-manual/build-quality.html#maintaining-build-output-quality>`__\ ”部分。

5.10 buildstats 类
====================

buildstats 类记录了构建期间执行的每个任务的性能统计信息（例如，耗时、CPU
使用率和 I/O 使用率）。

当您使用此类时，输出将进入 BUILDSTATS_BASE 目录，默认为
${TMPDIR}/buildstats/。您可以使用
scripts/pybootchartgui/pybootchartgui.py
分析耗时，该脚本生成整个构建过程的级联图表，可用于突出显示瓶颈。

通过本地.conf 文件中的 USER_CLASSES
变量启用收集构建统计信息的默认设置。因此，您无需执行任何操作即可启用该类。但是，如果您想禁用该类，只需从
USER_CLASSES 列表中删除“buildstats”。

5.11 buildstats-summary 类
============================

当全局继承时，在构建结束时打印有关 sstate
重用的统计信息。为了使其正常工作，此类需要启用 buildstats 类。

5.12 cargo 类
===============

cargo 类允许使用 Cargo 编译 Rust 语言程序。Cargo 是 Rust
的包管理器，允许获取包依赖项并构建您的程序。

使用此类可以非常方便地构建 Rust 程序。您只需要使用 SRC_URI
变量指向一个可以通过 Cargo 构建的源代码仓库，通常是由 cargo new
命令创建的，包含 Cargo.toml 文件、Cargo.lock 文件和 src 子目录。

如果您想构建和打包程序的测试，请继承 ptest-cargo 类而不是 cargo。

在 zvariant_3.12.0.bb 配方中，您将找到一个示例（还展示了如何处理可能的
git 源依赖项）。另一个只有 crate 依赖项的示例是 uutils-coreutils
配方，它是由 cargo-bitbake 工具生成的。

此类继承了 cargo_common 类。

5.13 cargo_c 类
================

cargo_c 类可以被配方继承，以生成一个可以由 C/C++ 代码调用的 Rust
库。继承此类的配方只需将 inherit cargo 替换为 inherit cargo_c。

请参阅 rust-c-lib-example_git.bb 示例配方。

5.14 cargo_common 类
======================

cargo_common 类是一个内部类，不打算直接使用。

一个例外是“rust”配方，用于构建 Rust 编译器和运行时库，它由 Cargo 构建，但不能使用 cargo 类。这就是为什么引入了这个类。


5.15 cargo-update-recipe-crates 类
====================================

cargo-update-recipe-crates 类允许配方开发人员通过读取源代码树中的
Cargo.lock 文件来更新 SRC_URI 中的 Cargo crate 列表。

要做到这一点，为您的程序创建一个配方，例如使用 devtool，使其继承 cargo
和 cargo-update-recipe-crates，然后运行：

::

   bitbake -c update_crates recipe

这将创建一个 recipe-crates.inc 文件，您可以将其包含在您的配方中：

::

   require ${BPN}-crates.inc

这也是您可以使用 cargo-bitbake 工具实现的目标。

5.16 ccache 类
================

ccache 类启用了构建过程中的 C/C++
编译器缓存。这个类用于在构建期间提供轻微的性能提升。

有关 C/C++ 编译器缓存的信息，请参阅
https://ccache.samba.org/。有关如何在配置文件中启用此机制、如何为特定配方禁用它以及如何在构建之间共享
ccache 文件的详细信息，请参阅 ccache.bbclass 文件。

然而，使用该类可能会导致意外的副作用。因此，不建议使用此类。

5.17 chrpath 类
=================

chrpath 类是“chrpath”实用程序的包装器，在构建过程中用于 nativesdk、cross
和 cross-canadian 配方中，以更改二进制文件中的 RPATH
记录，从而使它们可重定位。

5.18 cmake 类
===============

cmake 类允许配方使用 CMake 构建系统来构建软件。您可以使用 EXTRA_OECMAKE
变量指定要传递给 cmake 命令行的附加配置选项。

默认情况下，cmake 类使用 Ninja 而不是 GNU make
进行构建，这提供了更好的构建性能。如果一个配方在使用 Ninja
时出现问题，那么该配方可以将 OECMAKE_GENERATOR 变量设置为 Unix Makefiles
以改用 GNU make。

如果您需要安装由正在构建的应用程序提供的自定义 CMake 工具链文件，则应在
do_install 期间将它们安装到首选的 CMake
模块目录：\ ``${D}${datadir}/cmake/modules/``\ 。

5.19 cml1 类
==============

cml1 类提供了对 Linux
内核风格的构建配置系统的基本支持。“cml”代表“Configuration Menu
Language”，它起源于 Linux 内核，但也用于其他项目，如 U-Boot 和
BusyBox。它也可以被叫做“kconfig”。

5.20 compress_doc 类
=======================

启用对手册页和信息页的压缩。该类旨在全局继承。默认的压缩机制是
gz（gzip），但您可以通过设置 DOC_COMPRESS 变量来选择另一种机制。

5.21 copyleft_compliance 类
=============================

copyleft_compliance 类保留源代码以遵守许可证。该类是 archiver
类的替代方案，尽管它已被弃用，但仍被一些用户使用。

5.22 copyleft_filter 类
=========================

archiver 和 copyleft_compliance 类用于过滤许可证的类。copyleft_filter
类是内部类，不建议直接使用。

5.23 core-image 类
=====================

core-image 类为 core-image-\* 图像配方提供通用定义，例如支持额外的
IMAGE_FEATURES。

5.24 cpan\* 类
=================

cpan\* 类支持 Perl 模块。

Perl
模块的配方非常简单。这些配方通常只需要指向源文件的存档，然后继承适当的类文件。构建分为两种方法，具体取决于模块作者使用的方法。

- 使用旧的基于 Makefile.PL 的构建系统的模块需要在它们的配方中使用
   cpan.bbclass。

- 使用基于 Build.PL 的构建系统的模块需要在它们的配方中使用
   cpan_build.bbclass。

这两种构建方法都继承 cpan-base 类以提供基本的 Perl 支持。

5.25 create-spdx 类
======================

create-spdx 类提供了基于图像和 SDK 内容自动创建 SPDX SBOM 文档的支持。

该类应从配置文件中全局继承：

::

   INHERIT += "create-spdx"

顶层 SPDX 输出文件以 JSON 格式生成为 IMAGE-MACHINE.spdx.json 文件，位于
Build Directory 中的 tmp/deploy/images/MACHINE/
目录下。同一目录中还有其他相关文件，以及在 tmp/deploy/spdx 中。

此类的确切行为以及输出量可以通过
SPDX_PRETTY、SPDX_ARCHIVE_PACKAGED、SPDX_ARCHIVE_SOURCES 和
SPDX_INCLUDE_SOURCES 变量进行控制。

有关这些变量的描述以及“创建软件材料清单”部分，请参阅 `Yocto Project
Development
Manual <https://docs.yoctoproject.org/dev-manual/sbom.html#creating-a-software-bill-of-materials>`__\ 。

5.26 cross 类
================

cross 类提供了构建交叉编译工具的配方的支持。

5.27 cross-canadian 类
=========================

cross-canadian 类为构建用于 SDK 的 Canadian Cross-compilation
工具的配方提供支持。有关这些交叉编译工具的更多讨论，请参阅《Yocto
项目概述和概念手册》中的“交叉开发工具链生成”部分。

5.28 crosssdk 类
===================

crosssdk 类提供了构建用于构建 SDK
的交叉编译工具的配方的支持。有关这些交叉编译工具的更多讨论，请参阅 Yocto
项目概述和概念手册中的“交叉开发工具链生成”部分。

5.29 cve-check
==================

cve-check类在构建时使用BitBake查找已知的CVE（常见漏洞和暴露）。这个类应该从配置文件中全局继承：

::

   INHERIT += "cve-check"

要过滤掉已知不会影响Poky和OE-Core软件的过时CVE数据库条目，请在构建配置文件中添加以下行：

::

   include cve-extra-exclusions.inc

您还可以通过向BitBake传递-c cve_check来查找特定包中的漏洞。

使用Bitbake构建软件后，CVE检查输出报告可在
*tmp/deploy/cve*\ 中找到，图像特定的摘要在\ *tmp/deploy/images/.cve*\ 或\ *tmp/deploy/images/.json*\ 文件中。

在构建过程中，CVE检查器会对检测到的任何处于Unpatched状态的问题发出构建时间警告，这意味着CVE问题似乎会影响正在编译的软件组件和版本，并且没有应用解决该问题的补丁。检测到的CVE问题的其它状态是：Patched表示已经应用了解决该问题的补丁，以及Ignored表示可以忽略该问题。

CVE问题的Patched状态是通过具有格式CVE-ID.patch的补丁文件检测的，例如CVE-2019-20633.patch，在SRC_URI中使用CVE元数据，并在补丁文件的提交消息中使用格式CVE:
CVE-ID。

如果配方中添加了CVE-ID作为CVE_STATUS变量的标志，并且状态映射为Ignored，那么CVE状态将被报告为Ignored：

::

   CVE_STATUS[CVE-2020-15523] = "not-applicable-platform: Issue only applies on Windows"

如果CVE检查报告配方包含误报或漏报，可以通过调整CVE产品名称来修复这些问题，使用CVE_PRODUCT和CVE_VERSION变量。CVE_PRODUCT默认为纯配方名称BPN，可以使用以下语法将其调整为一个或多个CVE数据库供应商和产品对：

::

   CVE_PRODUCT = "flex_project:flex"

其中flex_project是CVE数据库供应商名称，flex是产品名称。同样，如果默认的配方版本PV与上游发布中的软件组件的版本号或CVE数据库不匹配，则可以使用CVE_VERSION变量设置与CVE数据库兼容的版本号，例如：

::

   CVE_VERSION = "2.39"

CVE数据库条目中的任何错误、缺失或不完整信息都应通过NVD反馈表在CVE数据库中进行修复。

用户应注意，安全是一个过程，而不是一个产品，因此CVE检查、分析结果、修补和更新软件也应作为一个常规过程来进行。CVE检查器可靠检测问题所需的数据和假设经常以各种方式被破坏。这些问题只能通过审查问题的详细信息、迭代生成的报告以及关注其他Linux发行版和更大的开源社区中发生的事情来检测。

您可以在“\ `《开发任务手册》 <https://docs.yoctoproject.org/dev-manual/vulnerabilities.html#checking-for-vulnerabilities>`__\ ”的“检查漏洞”部分中找到更多详细信息。

5.30 debian类
================

Debian类将输出包重命名为遵循Debian命名策略的包名（例如，glibc变为libc6，glibc-devel变为libc6-dev）。重命名包括库名称和版本作为包名的一部分。

如果一个配方为多个库创建包（.so类型的共享对象文件），请在配方中使用LEAD_SONAME变量来指定应用命名方案的库。

5.31 deploy类
================

Deploy类处理将文件部署到DEPLOY_DIR_IMAGE目录。这个类的主要功能是通过共享状态加速部署步骤。继承此类的配方应定义自己的do_deploy函数，将要部署的文件复制到DEPLOYDIR，并使用addtask在适当的位置添加任务，通常在do_compile或do_install之后。然后，该类负责将文件从DEPLOYDIR阶段化到DEPLOY_DIR_IMAGE。

5.32 devidetree类
====================

Devicetree类允许构建一个编译不在内核树中的设备树源文件的配方。

编译非树形设备树源的过程与内核树中设备树编译过程相同。这包括能够包含来自内核的源，例如SoC
dtsi文件以及C头文件，如gpio.h。

do_compile任务将编译两种类型的文件：

- 带有.dts扩展名的常规设备树源文件。

- 检测到文件内容中存在/plugin/;字符串的设备树覆盖层。

该类将生成的设备树二进制部署到\ *${DEPLOY_DIR_IMAGE}/devicetree/*\ 中。这与kernel-devicetree类所做的类似，添加了devicetree子目录以避免名称冲突。此外，设备树被填充到sysroot中，以便通过sysroot从其他配方中访问。

默认情况下，位于DT_FILES_PATH目录中的所有设备树源文件都将被编译。要选择特定的源文件，请将DT_FILES设置为相对于DT_FILES_PATH的文件列表（以空格分隔）。为了方便起见，可以使用.dts和.dtb扩展名。

在非覆盖设备树二进制文件中附加额外的填充。这通常可以用作在启动时添加额外属性的额外空间。可以通过将DT_PADDING_SIZE设置为所需的大小（以字节为单位）来修改填充大小。

有关控制此类的其他变量，请参阅devicetree.bbclass源代码。

以下是继承此类的示例recipes-kernel/linux/devicetree-acme.bb配方的摘录：

::

   inherit devicetree
   COMPATIBLE_MACHINE = "^mymachine$"
   SRC_URI:mymachine = "file://mymachine.dts"

5.33 devshell类
==================

devshell类添加了do_devshell任务。是否包含此类由发行版策略决定。有关使用devshell的更多信息，请参阅Yocto项目开发任务手册中的“\ `使用开发Shell <https://docs.yoctoproject.org/dev-manual/development-shell.html#using-a-development-shell>`__\ ”部分。

5.34 devupstream 类
====================

devupstream类使用BBCLASSEXTEND添加一个从替代URI（例如Git）获取而不是tarball的配方变体。以下是一个例子：

::

   BBCLASSEXTEND = "devupstream:target"
   SRC_URI:class-devupstream = "git://git.example.com/example;branch=main"
   SRCREV:class-devupstream = "abcd1234"

将上述语句添加到您的配方中，会创建一个默认优先级设置为“-1”的变体。因此，您需要选择要使用的配方变体。任何开发特定的调整都可以通过使用class-devupstream覆盖来实现。以下是一个例子：

::

   DEPENDS:append:class-devupstream = " gperf-native"
   do_configure:prepend:class-devupstream() {
       touch ${S}/README
   }

该类目前仅支持创建目标配方的开发变体，不支持原生或原生sdk变体。

BBCLASSEXTEND语法（即devupstream:target）提供了对原生和原生sdk变体的支持。因此，此功能可以在将来的版本中添加。

由于BitBake的自动获取依赖项（例如subversion-native），对其他版本控制系统（如Subversion）的支持有限。

5.35 externalsrc类
===================

externalsrc类支持从OpenEmbedded构建系统外部的源代码构建软件。从外部源代码树构建软件意味着不使用构建系统的正常获取、解压缩和修补过程。

默认情况下，OpenEmbedded构建系统使用S和B变量来定位解压缩的配方源代码并构建它。当您的配方继承externalsrc类时，您使用EXTERNALSRC和EXTERNALSRC_BUILD变量最终定义S和B。

默认情况下，此类期望源代码支持使用B变量指向OpenEmbedded构建系统放置从配方生成的对象的目录的配方构建。默认情况下，B目录设置为以下内容，与源目录（S）分开：

::

   ${WORKDIR}/${BPN}-{PV}/

有关这些变量的更多信息，请参阅WORKDIR、BPN和PV变量。

有关externalsrc类的更多信息，请参阅Source
Directory中的\ *meta/classes/externalsrc.bbclass*\ 中的注释。有关如何使用externalsrc类的信息，请参阅Yocto项目开发任务手册中的“从外部源代码构建软件”部分。

5.36 extausers类
==================

extrausers类允许在镜像级别应用额外的用户和组配置。继承这个类可以在全局或从镜像配方中进行，允许使用EXTRA_USERS_PARAMS变量执行额外的用户和组操作。

.. note:: 

    使用extrausers类添加的用户和组操作与特定配方之外的配方无关。因此，可以在整个镜像上执行操作。使用useradd*类将用户和组配置添加到特定的配方中。

以下是一个在镜像配方中使用此类的示例：

::

   inherit extrausers
   EXTRA_USERS_PARAMS = "
       useradd -p '' tester;
       groupadd developers;
       userdel nobody;
       groupdel -g video;
       groupmod -g 1020 developers;
       usermod -s /bin/sh tester;
       "

以下是一个添加名为“tester-jim”和“tester-sue”的两个用户并分配密码的示例。首先在主机上创建（转义）密码哈希：

::

   printf "%q" $(mkpasswd -m sha256crypt tester01)

生成的哈希被设置为一个变量并在useradd命令参数中使用：

::

   inherit extrausers
   PASSWD = "\$X\$ABC123\$A-Long-Hash"
   EXTRA_USERS_PARAMS = "
       useradd -p '${PASSWD}' tester-jim;
       useradd -p '${PASSWD}' tester-sue;
       "

最后，以下是一个设置root密码的示例：

::

   inherit extrausers
   EXTRA_USERS_PARAMS = "
       usermod -p '${PASSWD}' root;
       "

.. note:: 

   从安全的角度来看，硬编码默认密码通常不是一个好主意，甚至在某些司法管辖区是非法的。如果您正在构建生产镜像，建议不要这样做。

5.37 features_check类
=======================

features_check类允许各个配方检查所需的和冲突的DISTRO_FEATURES、MACHINE_FEATURES或COMBINED_FEATURES。

该类支持以下变量：

- REQUIRED_DISTRO_FEATURES

- CONFLICT_DISTRO_FEATURES

- ANY_OF_DISTRO_FEATURES

- REQUIRED_MACHINE_FEATURES

- CONFLICT_MACHINE_FEATURES

- ANY_OF_MACHINE_FEATURES

- REQUIRED_COMBINED_FEATURES

- CONFLICT_COMBINED_FEATURES

- ANY_OF_COMBINED_FEATURES

如果配方中使用上述变量指定的任何条件不满足，则配方将被跳过，如果构建系统尝试构建配方，则会触发错误。

5.38 fontcache类
==================

fontcache类为字体包生成适当的安装后和卸载后（postinst和postrm）脚本。这些脚本调用Fontconfig的fc-cache将字体添加到字体信息缓存中。由于缓存文件是特定于架构的，如果需要在图像创建期间在构建主机上运行postinst脚本，则使用QEMU运行fc-cache。

如果安装的字体不在主包中，而是在其他包中，请设置FONT_PACKAGES以指定包含字体的包。

5.39 fs-uuid类
================

fs-uuid类从\ :math:`{ROOTFS}中提取UUID，该函数被调用时必须已经构建了`\ {ROOTFS}。fs-uuid类仅适用于ext文件系统，并依赖于tune2fs。

5.40 gconf类
================

gconf类为需要安装GConf模式的配方提供通用功能。这些模式将被放入一个单独的包（${PN}-gconf）中，该包在继承此类时自动创建。此包使用适当的安装后和卸载后（postinst/postrm）脚本来在目标映像中注册和注销模式。

5.41 gettext类
=================

gettext类提供对使用GNU
gettext国际化和本地化系统的软件的构建支持。所有使用gettext的软件配方都应该继承这个类。

5.42 github-releases类
========================

对于从github获取发布tarball的配方，github-releases类为检查可用上游版本（以支持devtool升级和自动升级助手（AUH））提供了一种标准方法。

要使用它，请在配方的inherit行中添加“github-releases”，如果GITHUB_BASE_URI的默认值不合适，则在配方中设置自己的值。然后，您应该在配方中设置SRC_URI的值时使用${GITHUB_BASE_URI}。

5.43 gnomebase类
=================

gnomebase类是用于从GNOME堆栈构建软件的配方的基本类。该类将SRC_URI设置为从GNOME镜像下载源代码，并使用典型的GNOME安装路径扩展FILES。

5.44 go类
==========

go类支持构建Go程序。该类的行为由必需的GO_IMPORT变量控制，并由可选的GO_INSTALL和GO_INSTALL_FILTEROUT变量控制。

要使用Yocto
Project构建一个Go程序，您可以使用\ `go-helloworld_0.1.bb <https://git.yoctoproject.org/poky/tree/meta/recipes-extended/go-examples/go-helloworld_0.1.bb>`__\ 配方作为示例。

5.45 go-mod类
==============

go-mod类允许使用Go模块，并继承go类。

请参阅相关的\ `GO_WORKDIR <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-GO_WORKDIR>`__\ 变量。

5.46 gobject-introspection类
==============================

提供支持构建支持GObject内省的软件的配方。只有在“gobject-introspection-data”功能也在DISTRO_FEATURES中，并且“qemu-usermode”也在MACHINE_FEATURES中时，此功能才启用。

.. note::

   默认情况下，此功能通过backfill实现，如果不适用，则应分别通过DISTRO_FEATURES_BACKFILL_CONSIDERED或MACHINE_FEATURES_BACKFILL_CONSIDERED禁用。

5.47 grub-efi类
=================

grub-efi类提供了用于构建可引导映像的特定于grub-efi的功能。

该类支持以下变量：

`INITRD <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-INITRD>`__\ ：指示要连接并用作初始RAM磁盘（initrd）的文件系统映像列表（可选）。

`ROOTFS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-ROOTFS>`__\ ：指示要包含作为根文件系统的映像（可选）。

`GRUB_GFXSERIAL <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-GRUB_GFXSERIAL>`__\ ：将其设置为“1”以在启动菜单中具有图形和串行功能。

`LABELS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-LABELS>`__\ ：自动配置的目标列表。

`APPEND <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-APPEND>`__\ ：每个LABEL的附加字符串覆盖列表。

`GRUB_OPTS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-GRUB_OPTS>`__\ ：要添加到配置中的其他选项（可选）。选项使用分号字符（；）分隔。

`GRUB_TIMEOUT <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-GRUB_TIMEOUT>`__\ ：执行默认LABEL之前的超时时间（可选）。

5.48 gsettings类
==================

gsettings类为需要安装GSettings（glib）模式的配方提供了通用功能。这些模式被认为是主包的一部分。在目标映像中注册和解注册模式时，会添加适当的后安装和后删除（postinst/postrm）脚本片段。

5.49 gtk-doc类
================

gtk-doc类是一个帮助类，用于拉入适当的gtk-doc依赖项并禁用gtk-doc。

5.50 gtk-icon-cache类
========================

gtk-icon-cache类为使用GTK+并安装图标的包生成适当的后安装和后删除（postinst/postrm）脚本片段。这些脚本片段调用gtk-update-icon-cache将字体添加到GTK+的图标缓存中。由于缓存文件是特定于架构的，因此如果需要在映像创建期间在构建主机上运行postinst脚本片段，则使用QEMU运行gtk-update-icon-cache。

5.51 gtk-immodules-cache类
=============================

gtk-immodules-cache类为安装虚拟键盘的GTK+输入法模块的包生成适当的后安装和后删除（postinst/postrm）脚本片段。这些脚本片段调用gtk-update-icon-cache将输入法模块添加到缓存中。由于缓存文件是特定于架构的，因此如果需要在映像创建期间在构建主机上运行postinst脚本片段，则使用QEMU运行gtk-update-icon-cache。

如果正在安装的输入法模块位于主包之外的其他包中，请设置\ `GTKIMMODULES_PACKAGES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-GTKIMMODULES_PACKAGES>`__\ 以指定包含模块的包。

5.52 gzipnative类
===================

gzipnative类允许使用不同版本的本地gzip和pigz，而不是从构建主机中获取这些工具的版本。

5.53 icecc类
==============

icecc类支持Icecream，它有助于将编译工作分配给远程机器。

该类为本地和交叉编译器创建带有指向icecc的符号链接的目录。根据每个配置或编译，OpenEmbedded构建系统将目录添加到PATH列表的开头，然后设置ICECC_CXX和ICECC_CC变量，这些变量分别是g++和gcc编译器的路径。

对于交叉编译器，该类创建一个包含Yocto
Project工具链的tar.gz文件，并相应地设置ICECC_VERSION，这是交叉开发工具链中使用的交叉编译器版本。

该类处理所有三个不同的编译阶段（即本地、交叉内核和目标）并创建必要的环境tar.gz文件以供远程机器使用。该类还支持SDK生成。

如果在您的local.conf文件中未设置ICECC_PATH，则该类尝试使用which定位icecc二进制文件。如果在您的local.conf文件中设置了ICECC_ENV_EXEC，则该变量应指向用户提供的icecc-create-env脚本。如果您不指向用户提供的脚本，则构建系统使用配方icecc-create-env_0.1.bb中提供的默认脚本。

.. note::

   这是一个修改后的版本，而不是与icecream一起提供的脚本。

如果您不希望Icecream分布式编译支持应用于特定配方或类，则可以在local.conf文件中使用ICECC_RECIPE_DISABLE和ICECC_CLASS_DISABLE变量分别列出这些配方和类，以使OpenEmbedded构建系统在本地处理这些编译。

此外，您可以在local.conf文件中使用ICECC_RECIPE_ENABLE变量列出配方，以强制启用具有空PARALLEL_MAKE变量的配方的icecc。

继承icecc类会更改所有sstate签名。因此，如果开发团队拥有一个填充SSTATE_MIRRORS的专用构建系统，并且他们希望重用来自SSTATE_MIRRORS的sstate，那么所有开发人员和构建系统都需要要么继承icecc类，要么都不继承。

在发行级别上，您可以继承icecc类以确保所有构建者都从相同的sstate签名开始。在继承类之后，您可以通过以下方式禁用功能：

::

   INHERIT_DISTRO:append = " icecc"
   ICECC_DISABLED ??= "1"

这种做法确保每个人都使用相同的签名，但还需要那些确实想使用Icecream的人单独启用该功能，如下所示在local.conf文件中：

::

   ICECC_DISABLED = ""

5.54 image类
==============

image类帮助支持创建不同格式的图像。首先，使用rootfs*.bbclass文件之一（取决于使用的包格式）从包中创建根文件系统，然后创建一个或多个图像文件。

- IMAGE_FSTYPES变量控制要生成的图像类型。

- IMAGE_INSTALL变量控制要安装到图像中的软件包列表。

有关自定义图像的信息，请参阅Yocto
Project开发任务手册中的“\ `自定义图像 <https://docs.yoctoproject.org/4.0.17/dev-manual/customizing-images.html#customizing-images>`__\ ”部分。有关如何创建图像的信息，请参阅Yocto
Project概述和概念手册中的“图像”部分。

5.55 image-buildinfo类
========================

image-buildinfo类默认将包含构建信息的纯文本文件写入目标文件系统的\ *${sysconfdir}/buildinfo*\ （由IMAGE_BUILDINFO_FILE指定）。这可以用于手动确定任何给定图像的来源。它输出两个部分：

1. Build Configuration:
   变量及其值的列表（由IMAGE_BUILDINFO_VARS指定，默认为DISTRO和DISTRO_VERSION）

2. Layer Revisions: 构建中使用的所有层的修订版本。

此外，在构建SDK时，它将默认将相同的内容写入/buildinfo（由SDK_BUILDINFO_FILE指定）。

5.56 image_types类
=====================

image_types类定义了您可以通过IMAGE_FSTYPES变量启用的所有标准图像输出类型。您可以使用此类作为如何添加对自定义图像输出类型的支持的参考。

默认情况下，image类会自动启用image_types类。image类使用IMGCLASSES变量如下：

::

   IMGCLASSES = "rootfs_${IMAGE_PKGTYPE} image_types ${IMAGE_CLASSES}"
   IMGCLASSES += "${@['populate_sdk_base', 'populate_sdk_ext']['linux' in d.getVar("SDK_OS")]}"
   IMGCLASSES += "${@bb.utils.contains_any('IMAGE_FSTYPES', 'live iso hddimg', 'image-live', '', d)}"
   IMGCLASSES += "${@bb.utils.contains('IMAGE_FSTYPES', 'container', 'image-container', '', d)}"
   IMGCLASSES += "image_types_wic"
   IMGCLASSES += "rootfs-postcommands"
   IMGCLASSES += "image-postinst-intercepts"
   inherit ${IMGCLASSES}

image_types类还处理图像的转换和压缩。

.. note::

   要构建VMware
   VMDK图像，需要将“wic.vmdk”添加到IMAGE_FSTYPES中。对于Virtual Box
   Virtual Disk Image（“vdi”）和QEMU Copy On Write Version
   2（“qcow2”）图像也是如此。

5.57 image-live类
===================

这个类控制构建“实时”（即HDDIMG和ISO）图像。实时图像包含用于传统引导的syslinux，以及如果MACHINE_FEATURES包含“efi”时由EFI_PROVIDER指定的引导程序。

通常，您不会直接使用此类。相反，您将“live”添加到IMAGE_FSTYPES中。

5.58 insane类
===============

insane类在包生成过程中添加了一个步骤，以便OpenEmbedded构建系统生成输出质量保证检查。执行一系列检查，检查构建的输出中常见的运行时问题。分发策略通常决定是否包含此类。

您可以配置这些检查，使特定的测试失败引发警告或错误消息。通常，新测试的失败会生成警告。当元数据处于已知且良好状态时，随后对同一测试的失败将生成错误消息。请参阅“QA错误和警告消息”一章，了解使用默认配置时可能会遇到的警告和错误消息列表。

使用WARN_QA和ERROR_QA变量来控制这些检查的行为（即在您的自定义发行版配置中）。然而，要在配方中跳过一个或多个检查，您应该使用INSANE_SKIP。例如，要跳过配方主包中符号链接.so文件的检查，请在配方中添加以下内容。您需要意识到，在此示例中必须使用包名覆盖${PN}：

::

   INSANE_SKIP:${PN} += "dev-so"

请注意，QA检查的目的是检测包输出中的实际或潜在问题。因此，在禁用这些检查时要谨慎。

以下是您可以使用WARN_QA和ERROR_QA变量列出的测试：

- already-stripped：检查生成的二进制文件是否在构建系统提取调试符号之前已经被剥离。上游软件项目的常见做法是默认剥离输出二进制文件的调试符号。为了使用-dbg包在目标上进行调试，必须禁用此剥离。

- arch：检查任何二进制文件的可执行和可链接格式（ELF）类型、位大小和字节顺序，以确保它们与目标架构匹配。如果有任何二进制文件不匹配该类型，则此测试将失败，因为存在不兼容。该测试可能表明使用了错误的编译器或编译器选项。有时，像引导加载程序这样的软件可能需要绕过此检查。

- buildpaths：检查输出文件中指向构建主机上的路径的位置。这些不仅会泄露有关构建环境的信息，还会阻碍二进制可重现性。

- build-deps：确定是否存在通过DEPENDS、显式RDEPENDS或任务级依赖项指定的构建时依赖项，以匹配任何运行时依赖项。这种确定特别有助于发现运行时依赖项在哪里被检测到并在打包过程中添加。如果在元数据中没有指定显式依赖项，那么在打包阶段确保依赖项已构建就太晚了，因此在do_rootfs任务中将包安装到映像中时可能会出现错误，因为自动检测的依赖项未得到满足。例如，update-rc.d类会自动向安装initscript的包添加对initscripts-functions包的依赖项，该initscript引用了/etc/init.d/functions。配方真的应该在initscripts-functions包上为所涉及的包指定显式的RDEPENDS，以便OpenEmbedded构建系统能够确保initscripts配方实际上已经构建，从而提供initscripts-functions包。

- configure-gettext：检查如果配方正在构建使用automake的东西，并且automake文件包含AM_GNU_GETTEXT指令，那么配方也应该继承gettext类，以确保在构建过程中可以使用gettext。

- compile-host-path：检查do_compile日志中是否有使用构建主机上的路径的迹象。使用此类路径可能导致构建输出受到主机污染。

- debug-deps：检查所有包（除了-dbg包）是否不依赖于-dbg包，否则会导致打包错误。

- debug-files：检查除-dbg包以外的任何内容中是否有.debug目录。调试文件应该全部在-dbg包中。因此，任何其他地方打包的内容都是不正确的打包。

- dep-cmp：检查运行时包之间的依赖关系（即在RDEPENDS、RRECOMMENDS、RSUGGESTS、RPROVIDES、RREPLACES和RCONFLICTS变量值中）是否有无效的版本比较语句。任何无效的比较都可能在传递给包管理器时触发失败或不良行为。

- desktop：对任何.desktop文件运行desktop-file-validate程序，以验证其内容是否符合.desktop文件的规范。

- dev-deps：检查所有包（除了-dev或-staticdev包）是否不依赖于-dev包，否则将是一个打包错误。

- dev-so：检查.so符号链接是否在-dev包中，而不是在任何其他包中。通常，这些符号链接仅用于开发目的。因此，-dev包是它们的正确位置。在极少数情况下，例如动态加载模块，这些符号链接需要在主包中。

- empty-dirs：检查包是否没有将文件安装到通常预期为空的目录（如/tmp）。由QA_EMPTY_DIRS变量指定要检查的目录列表。

- file-rdeps：检查OpenEmbedded构建系统在打包时确定的文件级依赖项是否得到满足。例如，一个shell脚本可能以#!/bin/bash行开始。这一行将转化为对/bin/bash的文件依赖项。OpenEmbedded构建系统支持的三个包管理器中，只有RPM直接处理文件级依赖项，自动解析为提供文件的包。然而，其他两个包管理器缺乏该功能并不意味着依赖项仍然不需要解决。这个QA检查试图确保明确声明的RDEPENDS存在，以处理在打包文件中检测到的任何文件级依赖项。

- files-invalid：检查FILES变量值中是否包含“//”，这是无效的。

- host-user-contaminated：检查配方产生的包是否不包含/home以外的任何文件，其用户或组ID与运行BitBake的用户匹配。匹配通常表明文件正在以错误的UID/GID安装，因为目标ID独立于主机ID。有关更多信息，请参阅描述do_install任务的部分。

- incompatible-license：当包因标记为INCOMPATIBLE_LICENSE中的许可证而被排除创建时报告。

- install-host-path：检查do_install日志中是否有使用构建主机上的路径的迹象。使用此类路径可能导致构建输出受到主机污染。

- installed-vs-shipped：报告在do_install中已安装但未通过FILES变量包含在任何包中的文件。在构建过程中稍后的映像中不会出现任何包中的文件。理想情况下，所有已安装的文件都应打包或根本不安装。如果文件在任何包中都不需要，可以在do_install结束时删除这些文件。

- invalid-chars：检查配方元数据变量DESCRIPTION、SUMMARY、LICENSE和SECTION中是否不包含非UTF-8字符。一些包管理器不支持此类字符。

- invalid-packageconfig：检查PACKAGECONFIG中是否添加了未定义的特性。例如，对于不存在以下形式的名称“foo”：

   ::

      PACKAGECONFIG[foo] = "..."

- la：检查.la文件中是否包含任何TMPDIR路径。任何包含这些路径的.la文件都是错误的，因为libtool在自动使用这些文件时会添加正确的sysroot前缀。

- ldflags：确保二进制文件是使用构建系统提供的LDFLAGS选项进行链接的。如果此测试失败，请检查LDFLAGS变量是否已传递给链接器命令。

- libdir：检查库是否被安装到错误的（可能是硬编码的）安装路径。例如，此测试将捕获安装/lib/bar.so的配方，当\ :math:`{base_libdir}为“lib32”时。另一个例子是当配方安装/usr/lib64/foo.so，而`\ {libdir}为“/usr/lib”时。

- libexec：检查包中是否包含/usr/libexec中的文件。如果明确将libexecdir变量设置为/usr/libexec，则不执行此检查。

- mime：检查如果包包含mime类型文件（${datadir}/mime/packages中的.xml文件），配方是否还继承了mime类，以确保这些文件得到正确安装。

- mime-xdg：检查如果包包含一个带有’MimeType’键的.desktop文件，配方是否继承了mime-xdg类，这是激活该文件所必需的。

- missing-update-alternatives：检查如果配方设置了ALTERNATIVE变量，配方是否还继承了update-alternatives，以便正确设置替代项。

- packages-list：检查通过PACKAGES变量值多次列出同一包。以这种方式安装包可能会在打包过程中引起错误。

- patch-fuzz：检查补丁文件中是否存在模糊，这可能会使它们在底层代码更改时错误地应用。

- patch-status-core：检查OE-Core层中配方的补丁头的Upstream-Status是否指定且有效。

- patch-status-noncore：检查除OE-Core之外的层中配方的补丁头的Upstream-Status是否指定且有效。

- perllocalpod：检查配方是否正确安装和打包了perllocal.pod。

- perm-config：报告fs-perms.txt中格式无效的行。

- perm-line：报告fs-perms.txt中格式无效的行。

- perm-link：报告fs-perms.txt中指定’link’的行，其中指定的目标已经存在。

- perms：目前，此检查未使用但保留。

- pkgconfig：检查.pc文件中是否包含任何TMPDIR/WORKDIR路径。任何包含这些路径的.pc文件都是错误的，因为pkg-config在访问这些文件时会添加正确的sysroot前缀。

- pkgname：检查PACKAGES中的所有包名称是否不包含无效字符（即除了0-9、a-z、.、+和-之外的字符）。

- pkgv-undefined：检查do_package期间PKGV变量是否未定义。

- pkgvarcheck：检查RDEPENDS、RREMCOMMENDS、RSUGGESTS、RCONFLICTS、RPROVIDES、RREPLACES、FILES、ALLOW_EMPTY、pkg_preinst、pkg_postinst、pkg_prerm和pkg_postrm等变量，并报告是否存在不是特定于包的变量集。在没有包后缀的情况下使用这些变量是不好的做法，可能会不必要地复杂化同一配方内其他包的依赖关系或产生其他意外后果。

- pn-overrides：检查配方的名称（PN）值是否出现在OVERRIDES中。如果配方的名称使其PN值与OVERRIDES中的某个值匹配（例如，PN恰好与MACHINE或DISTRO相同），则可能会产生意外后果。例如，像FILES:${PN}
   = “xyz”这样的赋值实际上会变成FILES = “xyz”。

- rpaths：检查二进制文件中是否包含构建系统路径，如TMPDIR。如果此测试失败，说明链接器命令传递了错误的-rpath选项，您的二进制文件可能存在安全隐患。

- shebang-size：检查打包脚本中的shebang行（第一行的#!）长度是否超过128个字符，这可能会导致运行时根据操作系统出现错误。

- split-strip：报告从二进制文件中剥离或删除调试符号失败。

- staticdev：检查非静态dev包中的静态库文件（ `*.a` ）。

- src-uri-bad：检查配方设置的SRC_URI值是否包含对\ :math:`{PN}（而不是正确的`\ {BPN}）的引用，或者是否引用了不稳定的Github存档tarball。

- symlink-to-sysroot：检查包中的符号链接是否指向主机上的TMPDIR。这样的符号链接在主机上可以工作，但在目标系统上运行时显然是无效的。

- textrel：检查ELF二进制文件的.text部分是否包含重定位，这可能导致运行时性能影响。有关运行时性能问题的更多信息，请参阅“QA错误和警告消息”中的ELF二进制消息的解释。

- unhandled-features-check：检查如果配方设置了features_check类支持的变量之一（例如REQUIRED_DISTRO_FEATURES），则配方还应继承features_check以使要求实际生效。

- unimplemented-ptest：检查上游测试是否实现了ptest。

- unlisted-pkg-lics：检查应用于包的所有声明的许可证也是否在配方级别声明（即LICENSE: `*` 中的任何许可证应出现在LICENSE中）。

- useless-rpaths：检查二进制文件中的动态库加载路径（rpaths），默认情况下标准系统的链接器会搜索这些路径（例如/lib和/usr/lib）。虽然这些路径不会导致任何破坏，但它们确实浪费空间且没有必要。

- usrmerge：如果usrmerge在DISTRO_FEATURES中，此检查将确保没有包将文件安装到根目录（/bin、/sbin、/lib、/lib64）中。

- var-undefined：报告在do_package期间对打包至关重要的变量（即WORKDIR、DEPLOY_DIR、D、PN和PKGD）未定义的情况。

- version-going-backwards：如果启用了buildhistory类，当正在写入的包的版本低于之前写入的同名包时，将会报告。如果您将输出包放入feed并在目标系统上使用该feed升级包，包的版本倒退可能导致目标系统无法正确升级到包的“新”版本。

   .. note::

      这只与您在目标系统上使用运行时包管理相关。

- xorg-driver-abi：检查所有包含Xorg驱动程序的包都有ABI依赖关系。xserver-xorg配方提供了驱动程序ABI名称。所有驱动程序都应依赖于它们所针对的ABI版本。包含xorg-driver-input.inc或xorg-driver-video.inc的驱动程序配方将自动获取这些版本。因此，您只需要明确添加对二进制驱动程序配方的依赖关系。

5.59 kernel类
================

kernel类描述了Linux内核构建类（kernel
class）的功能和特性。它处理构建Linux内核，并包含构建所有内核树的代码。所需的头文件被暂存到STAGING_KERNEL_DIR目录中，以允许使用module类进行树外模块构建。

如果SRC_URI中列出了一个名为defconfig的文件，那么默认情况下，do_configure会将其复制为.config文件，并将其自动用作构建的内核配置。如果已经存在.config文件，则不会执行此复制操作：这允许配方通过其他方式在do_configure:prepend中生成配置。

每个构建的内核模块都单独打包，并通过解析modinfo输出来创建模块之间的依赖关系。如果需要所有模块，则安装kernel-modules包将安装所有带有模块的包以及其他各种内核包，如kernel-vmlinux。

内核类包含逻辑，允许在构建内核映像时嵌入初始RAM文件系统（Initramfs）映像。有关如何构建Initramfs的信息，请参阅Yocto
Project开发任务手册中的“构建初始RAM文件系统（Initramfs）映像”部分。

内核和模块类内部使用了其他一些类，包括kernel-arch、module-base和linux-kernel-base类。

5.60 kernel-arch类
=====================

kernel-arch类用于设置Linux内核编译（包括模块）的ARCH环境变量。

5.61 kernel-devicetree类
============================

kernel-devicetree类由内核类继承，支持设备树生成。

它的行为主要由以下变量控制：

`KERNEL_DEVICETREE_BUNDLE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-KERNEL_DEVICETREE_BUNDLE>`__\ ：是否将内核和设备树捆绑在一起

`KERNEL_DTBDEST <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-KERNEL_DTBDEST>`__\ ：安装DTB文件的目录

`KERNEL_DTBVENDORED <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-KERNEL_DTBVENDORED>`__\ ：是否保留供应商子目录

`KERNEL_DTC_FLAGS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-KERNEL_DTC_FLAGS>`__\ ：dtc（设备树编译器）的标志

`KERNEL_PACKAGE_NAME <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-KERNEL_PACKAGE_NAME>`__\ ：内核包的基本名称

5.62 kernel-fitimage类
=========================

kernel-fitimage类提供了将内核映像、设备树、U-boot脚本、Initramfs捆绑包和RAM磁盘打包到单个FIT映像中的支持。理论上，FIT映像可以支持任意数量的内核、U-boot脚本、Initramfs捆绑包、RAM磁盘和设备树。然而，kernel-fitimage目前仅支持有限的用例：一个内核映像、一个可选的U-boot脚本、一个可选的Initramfs捆绑包、一个可选的RAM磁盘和任意数量的设备树。

要创建FIT映像，需要将KERNEL_CLASSES设置为包含“kernel-fitimage”，并将KERNEL_IMAGETYPE、KERNEL_ALT_IMAGETYPE或KERNEL_IMAGETYPES之一设置为包含“fitImage”。

在创建FIT映像时传递给mkimage
-D的设备树编译器选项由UBOOT_MKIMAGE_DTCOPTS变量指定。

kernel-fitimage创建的FIT映像中只能添加一个内核，并且内核映像在FIT中是必需的。U-Boot加载内核映像的地址由UBOOT_LOADADDRESS指定，入口点由UBOOT_ENTRYPOINT指定。如果这些地址是64位的，则必须将FIT_ADDRESS_CELLS设置为“2”。

可以在kernel-fitimage创建的FIT映像中添加多个设备树，设备树是可选的。U-Boot加载设备树的地址由UBOOT_DTBO_LOADADDRESS（设备树覆盖）和UBOOT_DTB_LOADADDRESS（设备树二进制文件）指定。

kernel-fitimage创建的FIT映像中只能添加一个RAM磁盘，RAM磁盘在FIT中是可选的。U-Boot加载RAM磁盘映像的地址由UBOOT_RD_LOADADDRESS指定，入口点由UBOOT_RD_ENTRYPOINT指定。当指定INITRAMFS_IMAGE时，将RAM磁盘添加到FIT映像中，并要求INITRAMFS_IMAGE_BUNDLE不设置为1。

kernel-fitimage创建的FIT映像中只能添加一个Initramfs捆绑包，Initramfs捆绑包在FIT中是可选的。当使用Initramfs时，内核配置为将根文件系统与同一二进制文件中的内核捆绑在一起（例如：zImage-initramfs-MACHINE.bin）。当将内核复制到RAM并执行时，它会解压缩Initramfs根文件系统。可以通过指定INITRAMFS_IMAGE来启用Initramfs捆绑包，并要求INITRAMFS_IMAGE_BUNDLE设置为1。U-boot加载Initramfs捆绑包的地址由UBOOT_LOADADDRESS指定，入口点由UBOOT_ENTRYPOINT指定。

kernel-fitimage创建的FIT映像中只能添加一个U-boot启动脚本，启动脚本是可选的。启动脚本在ITS文件中指定为包含U-boot命令的文本文件。使用启动脚本时，用户应配置U-boot
do_install任务以将脚本复制到sysroot。因此，可以通过kernel-fitimage类将脚本包含在FIT映像中。在运行时，可以通过配置U-boot
CONFIG_BOOTCOMMAND定义从FIT映像加载启动脚本并执行它。

kernel-fitimage生成的FIT映像在适当设置UBOOT_SIGN_ENABLE、UBOOT_MKIMAGE_DTCOPTS、UBOOT_SIGN_KEYDIR和UBOOT_SIGN_KEYNAME变量时会进行签名。kernel-fitimage使用的默认FIT_HASH_ALG和FIT_SIGN_ALG值分别为“sha256”和“rsa2048”。可以使用kernel-fitimage类在将FIT_GENERATE_KEYS和UBOOT_SIGN_ENABLE都设置为“1”时生成用于签名FIT映像的密钥。

5.63 kernel-grub类
=====================

kernel-grub类在安装RPM以更新部署目标上的内核时，使用内核作为优先级启动机制来更新引导区域和引导菜单。

5.64 kernel-module-split类
=============================

kernel-module-split类为将 Linux 内核模块分割成单独的包提供了通用功能。

5.65 kernel-uboot类
======================

kernel-uboot类提供了从vmlinux风格内核源代码构建的支持。

5.66 kernel-uimage类
========================

kernel-uimage类提供对打包uImage的支持。

5.67 kernel-yocto类
========================

kernel-yocto类提供了从linux-yocto风格内核源仓库构建的通用功能。

5.68 kernelsrc类
====================

kernelsrc类设置了Linux内核源代码和版本。

5.69 lib_package类
======================

lib_package类支持构建库并生成可执行二进制文件的配方，其中这些二进制文件不应默认与库一起安装。相反，这些二进制文件被添加到单独的${PN}-bin包中，以使它们的安装成为可选。

5.70 libc*类
===============

libc*类支持构建带有libc的包的配方：

- libc-common类提供构建libc的通用支持。

- libc-package类支持打包glibc和eglibc。

5.71 license类
==================

license类提供许可证清单的创建和许可证排除。该类默认启用，使用INHERIT_DISTRO变量的默认值。

5.72 linux-kernel-base类
===========================

linux-kernel-base类为从Linux内核源代码树构建的配方提供通用功能。这些构建超出了内核本身。例如，Perf配方也继承这个类。

5.73 linuxloader类
=====================

提供linuxloader()函数，该函数给出平台上提供的动态加载器/链接器的值。这个值被许多其他类使用。

5.74 logging类
=================

logging类提供了用于记录各种BitBake严重性级别（即bbplain、bbnote、bbwarn、bberror、bbfatal和bbdebug）的消息的标准shell函数。

该类默认启用，因为它被基类继承。

5.75 meson类
=================

meson类允许创建使用Meson构建系统构建软件的配方。您可以使用MESON_BUILDTYPE、MESON_TARGET和EXTRA_OEMESON变量来指定要通过meson命令行传递的其他配置选项。

5.76 metadata_scm类
=======================

metadata_scm类提供了查询源代码管理器（SCM）仓库的分支和修订的功能。

基类使用这个类在每次构建开始前打印每个层的修订版本。metadata_scm类默认启用，因为它被基类继承。

5.77 migrate_localcount类
============================

migrate_localcount类验证配方的localcount数据并适当增加它。

5.78 mime类
===============

mime类为安装MIME类型文件的包生成适当的post-install和post-remove（postinst/postrm）脚本。这些脚本调用update-mime-database将MIME类型添加到共享数据库中。

5.79 mime-xdg类
===================

mime-xdg类为安装包含MimeType条目的.desktop文件的包生成适当的post-install和post-remove（postinst/postrm）脚本。这些脚本调用update-desktop-database将MIME类型添加到由桌面文件处理的MIME类型数据库中。

由于这个类，当用户在最近创建的图像上通过文件浏览器打开文件时，他们不必从所有已知应用程序的池中选择要打开文件的应用程序，即使它们无法打开选定的文件。

如果您的配方将其.desktop文件作为绝对符号链接安装，则无法通过此类的当前实现检测到此类文件。在这种情况下，您必须将相应的包名称添加到MIME_XDG_PACKAGES变量中。

5.80 mirrors类
=================

mirrors类为源代码镜像设置了一些标准的MIRRORS条目。这些镜像提供了一条备用路径，以防配方中指定的上游源在SRC_URI中无法使用。

该类默认启用，因为它被基类继承。

5.81 module类
================

module类提供对构建树外Linux内核模块的支持。该类继承了module-base和kernel-module-split类，并实现了do_compile和do_install任务。该类提供了构建和打包内核模块所需的一切。

有关树外Linux内核模块的一般信息，请参阅Yocto Project
Linux内核开发手册中的“\ `Incorporating Out-of-Tree
Modules <https://docs.yoctoproject.org/4.0.17/kernel-dev/common.html#incorporating-out-of-tree-modules>`__\ ”部分。

5.82 module-base类
=====================

module-base类提供了构建Linux内核模块的基本功能。通常，包含一个或多个内核模块并具有自己的构建模块方式的软件的配方会继承这个类，而不是继承module类。

5.83 multilib*类
===================

multilib*类提供支持，用于构建具有不同目标优化或目标架构的库，并在同一图像中并行安装它们。

有关使用Multilib功能的更多信息，请参阅Yocto
Project开发任务手册中的“\ `将多个版本的库文件组合到一个映像中 <https://docs.yoctoproject.org/4.0.17/dev-manual/libraries.html#combining-multiple-versions-of-library-files-into-one-image>`__\ ”部分。

5.84 native类
=================

``native``\ 类提供了为在构建主机上运行的工具（即使用构建主机上的编译器或其他工具的工具）构建配方的常见功能。

您可以通过几种不同的方式创建在主机上本地运行的工具的配方：

- 创建一个继承\ ``native``\ 类的\ ``myrecipe-native.bb``\ 配方。如果您使用此方法，必须在配方中将继承语句放在所有其他继承语句之后，以便最后继承\ ``native``\ 类。注意：

      当以这种方式创建配方时，配方名称必须遵循以下命名约定：

      ::

         myrecipe-native.bb

      不使用这种命名约定可能导致由于现有代码依赖于该命名约定而引起的微妙问题。

- 创建或修改包含以下内容的目标配方：

   ::

      BBCLASSEXTEND = "native"

   在配方内部，使用：class-native和：class-target覆盖来指定特定于各自本地或目标情况的任何功能。

尽管应用方式不同，但\ ``native``\ 类在两种方法中都有使用。第二种方法的优势在于，您不需要为本地和目标分别拥有两个单独的配方（假设您需要两者）。配方的所有共同部分都会自动共享。

5.85 nativesdk类
====================

``nativesdk``\ 类提供了希望构建作为SDK一部分运行的工具的配方的常见功能（即在SDKMACHINE上运行的工具）。

您可以通过几种不同的方式创建在SDK机器上运行的工具的配方：

- 创建一个继承\ ``nativesdk``\ 类的\ ``nativesdk-myrecipe.bb``\ 配方。如果您使用此方法，必须在配方中将继承语句放在所有其他继承语句之后，以便最后继承\ ``nativesdk``\ 类。

- 通过添加以下内容来创建任何配方的\ ``nativesdk``\ 变体：

   ::

      BBCLASSEXTEND = "nativesdk"

   在配方内部，使用：class-nativesdk和：class-target覆盖来指定特定于各自的SDK机器或目标情况的任何功能。

.. note::

   创建配方时，必须遵循以下命名约定：

   ::

      nativesdk-myrecipe.bb

   不这样做可能会导致代码依赖于该命名约定而引起微妙的问题。

尽管应用方式不同，但\ ``nativesdk``\ 类在两种方法中都有使用。第二种方法的优势在于，您不需要为SDK机器和目标分别拥有两个单独的配方（假设您需要两者）。配方的所有共同部分都会自动共享。

5.86 nopackages类
=====================

禁用不需要打包的配方和类中的打包任务。

5.87 npm类
=============

提供使用节点包管理器（NPM）获取的Node.js软件的支持。

.. note::

   目前，继承此类的配方必须使用npm://获取器来自动获取和打包依赖项。

有关如何创建NPM包的信息，请参阅Yocto
Project开发任务手册中的“\ `创建Node包管理器（NPM）包 <https://docs.yoctoproject.org/4.0.17/dev-manual/packages.html#creating-node-package-manager-npm-packages>`__\ ”部分。

5.88 oelint类
=================

``oelint``\ 类是元数据/类中可用的过时的lint检查工具，位于源目录中。

有一些类可能在OE-Core中一般有用，但实际上从未在OE-Core本身中使用过。\ ``oelint``\ 类就是这样一个示例。然而，了解这个类可以减少多个层之间不同版本的类似类的传播。

5.89 overlayfs类
===================

在嵌入式系统设计中，通常希望拥有一个只读的根文件系统。但是，许多不同的应用程序可能希望对文件系统的某部分具有读写访问权限。当更新机制覆盖整个根文件系统时，但您可能希望在更新之间保留应用程序数据，这尤其有用。overlayfs类通过使用overlayfs并同时保持基础根文件系统为只读来实现这一点。

要使用此类，请在机器配置中设置分区overlayfs将用作上层的挂载点。底层文件系统可以是任何受overlayfs支持的文件系统。这必须在您的机器配置中完成：

::

   OVERLAYFS_MOUNT_POINT[data] = "/data"

.. note::

   - 如果您在配方中重新定义此变量，QA检查将无法捕获文件存在！

   - 只有systemd挂载单元文件的存在被检查，而不是其内容。

   - 要获取有关overlayfs、其内部和受支持操作的更多详细信息，请参阅Linux内核的官方文档。

该类假设您在BSP（例如systemd-machine-units配方）中的其他地方定义了一个名为data.mount的systemd单元，并将其安装到映像中。

然后您可以在配方基础上指定可写目录（例如在my-application.bb中）：

::

   OVERLAYFS_WRITABLE_PATHS[data] = "/usr/share/my-custom-application"

要支持多个挂载点，您可以使用不同的标志变量。假设我们希望文件系统上有一个可写位置，但不需要数据在重新启动后仍然存在，那么我们可以为tmpfs文件系统使用mnt-overlay.mount单元。

在您的机器配置中：

::

   OVERLAYFS_MOUNT_POINT[mnt-overlay] = "/mnt/overlay"

然后在您的配方中：

::

   OVERLAYFS_WRITABLE_PATHS[mnt-overlay] = "/usr/share/another-application"

在实践中，您的应用程序配方可能需要在运行之前挂载多个覆盖层以避免写入底层文件系统（在只读文件系统的情况下可能是禁止的）。overlayfs提供了一个用于挂载覆盖层的systemd辅助服务。此辅助服务的名称为${PN}-overlays.service，可以在您的应用程序配方（以下示例中的application）systemd单元中添加以下内容来依赖它：

::

   [Unit]
   After=application-overlays.service
   Requires=application-overlays.service

.. note::

   该类不支持/etc目录本身，因为systemd依赖于它。要在overlayfs中获取/etc，请参见overlayfs-etc。

5.90 overlayfs-etc类
=====================

为了在overlayfs中获取/etc目录，需要在早期启动阶段进行特殊处理。其思想是提供一个自定义的init脚本，在启动实际的init程序之前挂载/etc，因为后者已经需要挂载/etc。

示例用法：

::

   IMAGE_FEATURES += "overlayfs-etc"

.. note::

   该类不能直接继承。使用\ `IMAGE_FEATURES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-IMAGE_FEATURES>`__\ 或\ `EXTRA_IMAGE_FEATURES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-EXTRA_IMAGE_FEATURES>`__\ 。

您的机器配置应该定义至少您要使用的overlayfs的设备、挂载点和文件系统类型：

::

   OVERLAYFS_ETC_MOUNT_POINT = "/data"
   OVERLAYFS_ETC_DEVICE = "/dev/mmcblk0p2"
   OVERLAYFS_ETC_FSTYPE ?= "ext4"

要控制更多的挂载选项，您应该考虑设置挂载选项（默认情况下使用默认值）：

::

   OVERLAYFS_ETC_MOUNT_OPTIONS = "wsync"

该类提供了两种生成/sbin/init的选项：

-  默认选项是将原始的/sbin/init重命名为/sbin/init.orig，并将生成的init放在原始名称下，即/sbin/init。它的优势是您无需更改任何内核参数即可使其工作，但它的限制是包管理无法使用，因为更新init管理器会删除生成的脚本。

-  如果您希望保留原始的init，可以设置：

   ::

      OVERLAYFS_ETC_USE_ORIG_INIT_NAME = "0"

   然后生成的init将被命名为/sbin/preinit，您需要在引导加载器配置中手动扩展内核参数。

5.91 own-mirrors类
====================

own-mirrors类使得设置自己的PREMIRRORS变得更加容易，这些PREMIRRORS是首先从其中获取源代码的地方，然后再尝试从每个配方中SRC_URI指定的上游获取。

要使用这个类，全局继承它并指定SOURCE_MIRROR_URL。以下是一个例子：

::

   INHERIT += "own-mirrors"
   SOURCE_MIRROR_URL = "http://example.com/my-source-mirror"

您可以在\ `SOURCE_MIRROR_URL <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SOURCE_MIRROR_URL>`__\ 中只指定一个URL。

5.92 package类
=================

package类支持从构建的输出生成包。核心通用功能位于package.bbclass中。特定包类型的代码位于这些特定的包类中：package_deb、package_rpm、package_ipk。

您可以通过在conf/local.conf配置文件（位于Build
Directory中）中使用PACKAGE_CLASSES变量来控制结果包格式的列表，您可以在其中指定一个或多个包类型。由于图像是从包生成的，因此需要包类才能启用图像生成。此变量中列出的第一个类用于图像生成。

如果您选择设置开发主机上的存储库（包源），以便DNF可以使用它，那么在目标上运行图像时，可以从源安装包（即运行时安装包）。有关更多信息，请参阅Yocto
Project开发任务手册中的“使用运行时包管理”部分。

您选择的特定包类可能会影响构建时间性能和空间占用。一般来说，使用IPK构建包比使用RPM构建相同或相似的包大约需要30％的时间。这个比较考虑了具有所有先前构建的依赖项的完整包的构建。这种差异的原因是RPM包管理器创建并处理比IPK包管理器更多的元数据。因此，如果您正在构建较小的系统，您可能希望将PACKAGE_CLASSES设置为“package_ipk”。

然而，在做出包管理器决策之前，您还应该考虑一些关于使用RPM的进一步事项：

-  RPM由于处理更多的元数据而开始提供比IPK更多的功能。例如，这些信息包括单个文件类型、文件校验和生成和安装评估、稀疏文件支持、多库系统的冲突检测和解决、ACID风格的升级以及回滚的重新打包能力。

-  对于较小的系统，使用RPM时Berkeley数据库和元数据的额外空间可能会影响您执行设备升级的能力。

您可以在这些两个Yocto项目邮件列表链接中找到有关包类影响的更多信息：

-  https://lists.yoctoproject.org/pipermail/poky/2011-May/006362.html

-  https://lists.yoctoproject.org/pipermail/poky/2011-May/006363.html

5.93 package_deb类
====================

package_deb类提供了使用Debian（即.deb）文件格式创建包的支持。该类确保将包以.deb文件格式写入${DEPLOY_DIR_DEB}目录。

这个类继承了package类，并通过local.conf文件中的\ `PACKAGE_CLASSES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-PACKAGE_CLASSES>`__\ 变量启用。

5.94 package_ipk类
====================

package_ipk类提供了使用IPK（即.ipk）文件格式创建包的支持。该类确保将包以.ipk文件格式写入${DEPLOY_DIR_IPK}目录。

这个类继承了package类，并通过local.conf文件中的\ `PACKAGE_CLASSES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-PACKAGE_CLASSES>`__\ 变量启用。

5.95 package_rpm类
====================

package_rpm类提供了使用RPM（即.rpm）文件格式创建包的支持。该类确保将包以.rpm文件格式写入${DEPLOY_DIR_RPM}目录。

这个类继承了package类，并通过local.conf文件中的\ `PACKAGE_CLASSES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-PACKAGE_CLASSES>`__\ 变量启用。

5.96 packagedata类
=====================

packagedata类提供了读取PKGDATA_DIR中找到的pkgdata文件的通用功能。这些文件包含由OpenEmbedded构建系统生成的每个输出包的信息。

这个类默认启用，因为它被继承到package类中。

5.97 packagegroup类
=====================

packagegroup类设置了适用于包组配方（例如PACKAGES、PACKAGE_ARCH、ALLOW_EMPTY等）的默认值。强烈建议所有包组配方都继承这个类。

有关如何使用此类的信息，请参阅Yocto
Project开发任务手册中的“\ `使用自定义包组定制图像 <https://docs.yoctoproject.org/4.0.17/dev-manual/customizing-images.html#customizing-images-using-custom-package-groups>`__\ ”部分。

以前，这个类被称为任务类。

5.98 patch类
===============

patch类提供了在do_patch任务期间应用补丁的所有功能。

这个类默认启用，因为它被继承到基类中。

5.99 perlnative类
====================

当一个配方继承perlnative类时，它支持使用构建系统构建的Perl的本地版本，而不是使用构建主机提供的Perl版本。

5.100 pypi类
=================

pypi类为从PyPI（Python包索引）构建Python模块的配方设置了适当的变量。默认情况下，它根据BPN确定PyPI包名称（如果存在，则剥离“python-”或“python3-”前缀），但在一些情况下，您可能需要在配方中手动设置PYPI_PACKAGE。

pypi类设置的变量包括\ `SRC_URI <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SRC_URI>`__\ 、\ `SECTION <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SECTION>`__\ 、\ `HOMEPAGE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-HOMEPAGE>`__\ 、\ `UPSTREAM_CHECK_URI <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UPSTREAM_CHECK_URI>`__\ 、\ `UPSTREAM_CHECK_REGEX <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UPSTREAM_CHECK_REGEX>`__\ 和\ `CVE_PRODUCT <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-CVE_PRODUCT>`__\ 。

5.101 python_flit_core类
===========================

python_flit_core类启用了构建声明PEP-517兼容的flit_core.buildapi构建后端的Python模块，该构建后端在pyproject.toml的[build-system]部分中声明（参见\ `PEP-518 <https://www.python.org/dev/peps/pep-0518/>`__\ ）。

使用flit_core.buildapi构建的Python模块是纯Python（没有C或Rust扩展）。

在内部，它使用了python_pep517类。

5.102 python_pep517类
========================

python_pep517类构建和安装一个Python
wheel二进制存档（参见\ `PEP-517 <https://peps.python.org/pep-0517/>`__\ ）。

配方不会直接继承这个类，而是通常另一个类会继承它并添加相关的本地依赖项。

执行此操作的类示例包括python_flit_core、python_setuptools_build_meta和python_poetry_core。

5.103 python_poetry_core类
=============================

python_poetry_core类启用了使用Poetry Core构建系统的Python模块的构建。

在内部，它使用了python_pep517类。

5.104 python_pyo3类
======================

python_pyo3类帮助确保使用PyO3构建的用Rust编写的Python扩展正确设置了交叉编译环境。

这个类是\ `python-setuptools3_rust <https://docs.yoctoproject.org/4.0.17/ref-manual/classes.html#ref-classes-python-setuptools3-rust>`__\ 类的内部类，不应该直接在配方中使用。

5.105 python-setuptools3_rust类
==================================

python-setuptools3_rust类启用了使用PyO3实现的用Rust编写的Python扩展的构建。这使得可以像编写C语言一样轻松地编译和分发用Rust编写的Python扩展。

这个类继承了setuptools3和python_pyo3类。

5.106 pixbufcache类
======================

pixbufcache类为安装pixbuf加载器的包生成适当的post-install和post-remove（postinst/postrm）脚本。这些脚本调用update_pixbuf_cache将pixbuf加载器添加到缓存中。由于缓存文件是特定于架构的，因此如果需要在创建映像期间在构建主机上运行postinst脚本，则使用QEMU运行update_pixbuf_cache。

如果正在安装的pixbuf加载器位于配方的主包之外，请设置\ `PIXBUF_PACKAGES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-PIXBUF_PACKAGES>`__\ 以指定包含加载器的包。

5.107 pkgconfig类
====================

pkgconfig类通过使用pkg-config提供了一种获取头文件和库信息的标准方法。该类旨在将pkg-config平滑地集成到使用它的库中。

在暂存期间，BitBake将pkg-config数据安装到sysroots/目录中。通过在pkg-config中使用sysroot功能，pkgconfig类不再需要操作这些文件。

5.108 populate_sdk类
=======================

populate_sdk类提供了对仅SDK的配方的支持。有关使用do_populate_sdk任务构建交叉开发工具链时获得的优势的信息，请参阅Yocto
Project应用程序开发和可扩展软件开发工具包（eSDK）手册中的“\ `构建SDK安装程序 <https://docs.yoctoproject.org/4.0.17/sdk-manual/appendix-obtain.html#building-an-sdk-installer>`__\ ”部分。

5.109 populate_sdk_*类
=========================

populate_sdk_*类支持SDK创建，包括以下类：

-  populate_sdk_base：支持在所有包管理器（即DEB、RPM和opkg）下创建SDK的基类。

-  populate_sdk_deb：支持在Debian包管理器下创建SDK。

-  populate_sdk_rpm：支持在RPM包管理器下创建SDK。

-  populate_sdk_ipk：支持在opkg（IPK格式）包管理器下创建SDK。

-  populate_sdk_ext：支持在所有包管理器下创建可扩展的SDK。

populate_sdk_base类根据\ `IMAGE_PKGTYPE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-IMAGE_PKGTYPE>`__\ 继承适当的populate_sdk_*（即deb、rpm和ipk）。

基类确保所有源和目标目录都已建立，然后填充SDK。填充SDK后，populate_sdk_base类构建两个sysroots：${SDK_ARCH}-nativesdk，包含交叉编译器及相关工具；以及目标，包含为SDK使用配置的目标根文件系统。这两个映像位于SDK_OUTPUT，其中包括以下内容：

::

   ${SDK_OUTPUT}/${SDK_ARCH}-nativesdk-pkgs
   ${SDK_OUTPUT}/${SDKTARGETSYSROOT}/target-pkgs

最后，基本的populate
SDK类创建工具链环境设置脚本、SDK的tarball和安装程序。

相应的populate_sdk_deb、populate_sdk_rpm和populate_sdk_ipk类各自支持特定类型的SDK。这些类由populate_sdk_base类继承和使用。

有关交叉开发工具链生成的更多信息，请参阅Yocto项目概述和概念手册中的“\ `交叉开发工具链生成 <https://docs.yoctoproject.org/4.0.17/overview-manual/concepts.html#cross-development-toolchain-generation>`__\ ”部分。有关使用do_populate_sdk任务构建交叉开发工具链时获得的优势的信息，请参阅Yocto项目应用程序开发和可扩展软件开发工具包（eSDK）手册中的“\ `构建SDK安装程序 <https://docs.yoctoproject.org/4.0.17/sdk-manual/appendix-obtain.html#building-an-sdk-installer>`__\ ”部分。

5.110 prexport类
==================

prexport类提供了导出PR值的功能。

.. note::

   这个类不是直接使用的，而是在使用“bitbake-prserv-tool
   export”时启用的。

5.111 primport类
====================

primport类提供了导入PR值的功能。

.. note::

   这个类不是直接使用的，而是在使用“bitbake-prserv-tool
   import”时启用的。

5.112 prserv类
=================

prserv类提供了使用PR服务的功能，以便自动管理每个配方的PR变量的递增。

这个类默认启用，因为它被包类继承。然而，OpenEmbedded构建系统不会启用此功能，除非已设置PRSERV_HOST。

5.113 ptest类
================

ptest类提供了打包和安装为构建提供这些测试的软件的配方的运行时测试的功能。

这个类旨在被各个配方继承。然而，除非“ptest”出现在\ `DISTRO_FEATURES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-DISTRO_FEATURES>`__\ 中，否则该类的功能在很大程度上是禁用的。有关使用ptest进行包测试的更多信息，请参阅Yocto项目开发任务手册中的“\ `使用ptest测试包 <https://docs.yoctoproject.org/4.0.17/dev-manual/packages.html#testing-packages-with-ptest>`__\ ”部分。

5.114 ptest-cargo类
=======================

ptest-cargo类是一个扩展了cargo类的类，它分别添加了compile_ptest_cargo和install_ptest_cargo步骤来构建和安装Cargo.toml文件中定义的测试套件，并将其放入一个专用的-ptest包中。

5.115 ptest-gnome类
=====================

启用针对GNOME包的特定于包的测试（ptests），这些测试旨在使用gnome-desktop-testing执行。

有关设置和运行ptests的信息，请参阅Yocto项目开发任务手册中的“\ `使用ptest测试包 <https://docs.yoctoproject.org/4.0.17/dev-manual/packages.html#testing-packages-with-ptest>`__\ ”部分。

5.116 python3-dir类
=====================

python3-dir类提供了Python 3的基本版本、位置和站点包位置。

5.117 python3native类
========================

python3native类支持使用构建系统构建的Python
3的本地版本，而不是构建主机提供的版本。

5.118 python3targetconfig类
==============================

python3targetconfig类支持使用构建系统构建的Python
3的本地版本，而不是构建主机提供的版本，但可以访问目标机器的配置（例如正确的安装目录）。这也增加了对目标python3的依赖关系，因此仅在适当的地方使用以避免不必要地延长构建时间。

5.119 qemu类
===============

qemu类提供了需要QEMU或测试QEMU存在性的配方的功能。通常，这个类用于在构建主机上使用QEMU的应用程序仿真模式运行目标系统的程序。

5.120 recipe_sanity类
=======================

recipe_sanity类检查可能存在的任何影响构建的主机系统配方先决条件（例如设置的变量或存在的软件）。

5.121 relocatable类
=====================

relocatable类启用将二进制文件安装到sysroot时进行重定位。

该类利用chrpath类，并被cross和native类使用。

5.122 remove-libtool类
=========================

remove-libtool类向do_install任务添加了一个后置函数，用于删除由libtool安装的所有.la文件。删除这些文件会导致它们在sysroot和目标包中都不存在。

如果配方需要安装.la文件，则可以通过以下方式覆盖删除：

::

   REMOVE_LIBTOOL_LA = "0"

.. note::

   remove-libtool类默认情况下未启用。

5.123 report-error类
=======================

report-error类支持启用错误报告工具，该工具允许您将构建错误信息提交到中央数据库。

该类收集有关配方、配方版本、任务、机器、发行版、构建系统、目标系统、主机发行版、分支、提交和日志的调试信息。从这些信息中，使用JSON格式创建并存储报告文件在${`LOG_DIR <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-LOG_DIR>`__}/error-report中。

5.124 rm_work类
=================

rm_work类支持删除临时工作区，这可以减轻构建过程中对硬盘的需求。

OpenEmbedded构建系统在构建过程中可能会使用大量的磁盘空间。其中一部分是每个配方的${TMPDIR}/work目录下的工作文件。一旦构建系统为一个配方生成了软件包，该配方的工作文件就不再需要了。然而，默认情况下，构建系统会保留这些文件以供检查和可能的调试目的。如果您希望在构建过程中删除这些文件以节省磁盘空间，可以通过在Build
Directory中找到的local.conf文件中添加以下内容来启用rm_work：

::

   INHERIT += "rm_work"

如果您正在修改和构建配方的工作目录中的源代码，启用rm_work可能会导致您的源代码更改丢失。要排除某些配方的工作目录不被rm_work删除，您可以将您正在处理的配方的名称添加到RM_WORK_EXCLUDE变量中，该变量也可以在local.conf文件中设置。以下是一个例子：

::

   RM_WORK_EXCLUDE += "busybox glibc"

5.125 rootfs*类
==================

rootfs*类支持为映像创建根文件系统，包括以下类：

rootfs-postcommands类，它定义了映像配方的文件系统后处理函数。

rootfs_deb类，它支持使用.deb包构建的映像的根文件系统的创建。

rootfs_rpm类，它支持使用.rpm包构建的映像的根文件系统的创建。

rootfs_ipk类，它支持使用.ipk包构建的映像的根文件系统的创建。

rootfsdebugfiles类，它将在构建主机上找到的附加文件直接安装到根文件系统中。

根文件系统是从包中创建的，具体使用哪个rootfs*文件取决于PACKAGE_CLASSES变量。

有关如何创建根文件系统映像的信息，请参阅Yocto项目概述和概念手册中的“映像生成”部分。

5.126 rust类
===============

rust类是一个内部类，仅在“rust”配方中使用，用于构建Rust编译器和运行时库。除了这个配方之外，它不打算直接使用。

5.127 rust-common类
=======================

rust-common类是cargo_common和rust类的内部类，不打算直接使用。

5.128 sanity类
================

sanity类检查主机系统上是否存在先决软件，以便用户可以了解可能影响其构建的潜在问题。该类还执行来自local.conf配置文件的基本用户配置检查，以防止常见的错误导致构建失败。分发策略通常决定是否包含此类。

5.129 scons类
=================

scons类支持需要使用SCons构建系统的软件的配方。您可以使用EXTRA_OESCONS变量指定要传递给SCons命令行的附加配置选项。

5.130 sdl类
==============

sdl类支持需要使用Simple DirectMedia Layer（SDL）库构建软件的配方。

5.131 python_setuptools_build_meta
python_setuptools_build_meta类启用了在pyproject.toml的[build-system]部分声明PEP-517兼容的setuptools.build_meta构建后端的Python模块的构建（参见\ `PEP-518 <https://www.python.org/dev/peps/pep-0518/>`__\ ）。

使用setuptools.build_meta构建的Python模块可以是纯Python，也可以包含C或Rust扩展。

内部使用python_pep517类。

5.132 setuptools3类
=======================

setuptools3类支持使用基于setuptools的构建系统（例如仅具有setup.py且尚未迁移到官方pyproject.toml格式）的Python
3.x扩展。如果您的配方使用这些构建系统，则配方需要继承setuptools3类。

.. note::

   setuptools3类的do_compile任务现在调用setup.py
   bdist_wheel来构建wheel二进制存档格式（参见PEP-427）。

   由此产生的一个后果是，仍然使用来自Python标准库的已弃用的distutils的遗留软件无法作为轮子进行打包。一种常见的解决方案是从distutils.core导入setup替换为从setuptools导入setup。

.. note::

   setuptools3类的do_install任务现在安装wheel二进制存档。在当前版本的setuptools中，legacy
   setup.py
   install方法已被弃用。如果setup.py不能与wheel一起使用，例如它在Python模块或标准入口点之外创建文件，那么应该使用setuptools3_legacy。

5.133 setuptools3_legacy类
=============================

setuptools3_legacy类支持使用基于setuptools的构建系统（例如仅具有setup.py且尚未迁移到官方pyproject.toml格式）的Python
3.x扩展。与setuptools3不同，它使用传统的setup.py构建和安装命令，而不是wheels。这种对setuptools的使用已被弃用，但仍然相对常见。

5.134 setuptools3-base类
===========================

setuptools3-base类为支持构建Python版本3.x扩展的其他类提供可重用的基类。如果您需要setuptools3类未提供的功能，您可能希望继承setuptools3-base。一些配方不需要setuptools3类中的任务，而是继承此类。

5.135 sign_rpm类
===================

sign_rpm类支持生成签名RPM包。

5.136 siteconfig类
=====================

siteconfig类提供处理站点配置的功能。该类由autotools*类用于加速do_configure任务。

5.137 siteinfo类
==================

siteinfo类提供了其他类或配方可能需要的目标信息。

例如，考虑Autotools，它可能需要在目标硬件上执行的测试。由于在交叉编译时通常不可能这样做，因此使用站点信息提供缓存的测试结果，以便可以跳过这些测试，但仍然提供正确的值。meta/site目录包含按不同类别（如架构、字节顺序和使用的libc）排序的测试结果。站点信息通过CONFIG_SITE变量提供当前构建中包含相关数据的一组文件，Autotools会自动获取这些文件。

该类还提供了可以在元数据中的其他地方使用的变量，如\ `SITEINFO_ENDIANNESS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SITEINFO_ENDIANNESS>`__\ 和\ `SITEINFO_BITS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SITEINFO_BITS>`__\ 。

5.138 sstate类
==================

sstate类提供了对共享状态（sstate）的支持。默认情况下，通过\ `INHERIT_DISTRO <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-INHERIT_DISTRO>`__\ 变量的默认值启用该类。

有关sstate的更多信息，请参阅Yocto项目概述和概念手册中的“\ `共享状态缓存 <https://docs.yoctoproject.org/4.0.17/overview-manual/concepts.html#shared-state-cache>`__\ ”部分。

5.139 staging类
=================

staging类将文件安装到各个配方工作目录的sysroots中。该类包含以下关键任务：

负责处理最终出现在配方sysroots中的文件的do_populate_sysroot任务。

将文件安装到各个配方工作目录（即WORKDIR）中的do_prepare_recipe_sysroot任务（是populate_sysroot任务的“伙伴”任务）。

staging类中的代码相当复杂，基本上分为两个阶段：

-  第一阶段：第一阶段处理希望与其他依赖其原始配方的配方共享文件的配方。通常，这些依赖项通过do_install任务安装到 `{D}` 中。do_populate_sysroot任务将其中一部分文件复制到 `{SYSROOT_DESTDIR}` 中。这部分文件由SYSROOT_DIRS、SYSROOT_DIRS_NATIVE和SYSROOT_DIRS_IGNORE变量控制。

   .. note::

      此外，配方还可以通过在\ `SYSROOT_PREPROCESS_FUNCS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SYSROOT_PREPROCESS_FUNCS>`__\ 变量中声明处理函数来进一步自定义这些文件。

   从这些文件构建一个共享状态（sstate）对象，并将文件放入build/tmp/sysroots-components/的子目录中。扫描这些文件中的硬编码路径到原始安装位置。如果在文本文件中找到位置，则将硬编码的位置替换为令牌，并创建一个需要此类替换的文件列表。这些调整称为“FIXME”。扫描需要路径的文件列表由SSTATE_SCAN_FILES变量控制。

-  第二阶段：第二阶段处理希望使用另一个配方并通过DEPENDS变量声明对该配方的依赖关系的配方。当执行此任务时，它将在配方工作目录（即WORKDIR）中创建recipe-sysroot和recipe-sysroot-native。OpenEmbedded构建系统在配方工作目录中创建指向sysroots-components中相关文件副本的硬链接。

   .. note::

      如果无法创建硬链接，则构建系统使用实际副本。

   然后，构建系统根据第一阶段中创建的列表解决任何“FIXMEs”到路径的问题。

   最后，在sysroot中具有前缀“postinst-”的任何${bindir}中的文件都将被执行。

   .. note::

      尽管不建议一般使用这样的sysroot
      post安装脚本，但这些文件确实允许解决一些问题，如用户创建和模块索引。

因为配方可能还有其他依赖项（例如，do_unpack[depends] += “tar-native:do_populate_sysroot”），所以还将extend_recipe_sysroot添加为依赖于DEPENDS之外的其他任务的预函数。

在将依赖项安装到sysroot中时，代码遍历依赖关系图并处理依赖关系，方式与从sstate安装时的依赖关系相同。这意味着，例如，本地工具将添加其本地依赖项，但目标库不会遍历或安装其依赖项。使用相同的sstate依赖项代码，因此无论是否使用sstate，构建都应该相同。要更仔细地了解，请参阅sstate类中的setscene_depvalid()函数。

构建系统小心维护它安装的文件的清单，以便可以根据需要安装给定的依赖项。还会存储已安装项目的sstate哈希，以便如果它发生变化，构建系统可以重新安装它。

5.140 syslinux类
==================

syslinux类提供了构建可启动映像的特定于syslinux的功能。

该类支持以下变量：

`INITRD <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-INITRD>`__\ ：指示要连接并用作初始RAM磁盘（initrd）的文件系统映像列表。这个变量是可选的。

`ROOTFS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-ROOTFS>`__\ ：指示要包含为根文件系统的文件系统映像。这个变量是可选的。

`AUTO_SYSLINUXMENU <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-AUTO_SYSLINUXMENU>`__\ ：当设置为“1”时，启用创建自动菜单。

`LABELS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-LABELS>`__\ ：列出自动配置的目标。

`APPEND <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-APPEND>`__\ ：列出每个标签的附加字符串覆盖。

`SYSLINUX_OPTS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SYSLINUX_OPTS>`__\ ：列出要添加到syslinux文件的额外选项。分号字符分隔多个选项。

`SYSLINUX_SPLASH <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SYSLINUX_SPLASH>`__\ ：使用引导菜单时，列出VGA引导菜单的背景。

`SYSLINUX_DEFAULT_CONSOLE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SYSLINUX_DEFAULT_CONSOLE>`__\ ：设置为“console=ttyX”以更改内核引导默认控制台。

`SYSLINUX_SERIAL <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SYSLINUX_SERIAL>`__\ ：设置替代串行端口。或者，当变量设置为空字符串时，关闭串行。

`SYSLINUX_SERIAL_TTY <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SYSLINUX_SERIAL_TTY>`__\ ：设置替代的“console=tty…”内核引导参数。

5.141 systemd类
==================

systemd类为安装systemd单元文件的配方提供支持。

除非你在DISTRO_FEATURES中包含“systemd”，否则该类的功能将被禁用。

在这个类下，配方或Makefile（即配方在do_install任务期间调用的内容）将单元文件安装到\ :math:`{D}`\ {systemd_unitdir}/system。如果被安装的单元文件进入的包不是主包，你需要在配方中设置SYSTEMD_PACKAGES以标识文件将被安装的包。

你应该将SYSTEMD_SERVICE设置为服务文件的名称。你还应该使用包名覆盖来指示该值适用的包。如果该值适用于配方的主包，请使用${PN}。以下是来自connman配方的示例：

::

   SYSTEMD_SERVICE:${PN} = "connman.service"

除非将\ `SYSTEMD_AUTO_ENABLE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SYSTEMD_AUTO_ENABLE>`__\ 设置为“disable”，否则服务将设置为在启动时自动启动。

有关systemd的更多信息，请参阅Yocto项目开发任务手册中的“\ `选择初始化管理器 <https://docs.yoctoproject.org/4.0.17/dev-manual/init-manager.html#selecting-an-initialization-manager>`__\ ”部分。

5.142 systemd-boot类
=======================

systemd-boot类为构建可启动映像提供了特定于systemd-boot引导加载器的功能。这是一个内部类，不建议直接使用。

.. note::

   systemd-boot类是Yocto项目早期版本中使用的gummiboot类与systemd项目合并的结果。

将EFI_PROVIDER变量设置为“\ `systemd-boot <https://www.freedesktop.org/wiki/Software/systemd/systemd-boot/>`__\ ”以使用此类。这样做将创建一个独立的EFI引导加载器，不依赖于systemd。

有关此类中使用和支持的更多变量的信息，请参阅SYSTEMD_BOOT_CFG、SYSTEMD_BOOT_ENTRIES和SYSTEMD_BOOT_TIMEOUT变量。

您还可以查看Systemd-boot文档以获取更多信息。

5.143 terminal类
==================

terminal类提供对启动终端会话的支持。OE_TERMINAL变量控制用于会话的终端模拟器。

其他类在需要启动单独的终端会话时使用terminal类。例如，假设PATCHRESOLVE设置为“user”的patch类、cml1类和devshell类都使用terminal类。

5.144 testimage类
====================

testimage类支持使用QEMU和实际硬件对映像运行自动化测试。这些类处理加载测试并启动映像。要使用这些类，您需要执行设置环境的步骤。

要启用此类，请将以下内容添加到您的配置中：

::

   IMAGE_CLASSES += "testimage"

测试是在目标系统上通过ssh运行的命令。每个测试都用Python编写，并使用unittest模块。

当使用以下命令调用时，testimage类会在映像上运行测试：

::

   $ bitbake -c testimage image

或者，如果您希望在构建每个映像后自动运行测试，可以设置TESTIMAGE_AUTO：

::

   TESTIMAGE_AUTO = "1"

有关如何启用、运行和创建新测试的信息，请参阅Yocto项目开发任务手册中的“执行自动化运行时测试”部分。

5.145 testsdk类
=================

这个类支持针对软件开发工具包（SDKs）运行自动化测试。testsdk类在调用时会在SDK上运行测试，使用以下命令：

::

   $ bitbake -c testsdk image

.. note::

   最佳实践是使用IMAGE_CLASSES而不是INHERIT来继承testsdk类以进行自动SDK测试。

5.146 texinfo类
==================

该类应由在构建时调用texinfo实用程序的上游软件包配方继承。本机和交叉配方使用texinfo-dummy-native提供的虚拟脚本以提高性能。目标架构配方使用真正的Texinfo实用程序。默认情况下，它们使用主机系统上的Texinfo实用程序。

.. note::

   如果您想使用与构建系统一起提供的Texinfo配方，可以从\ `ASSUME_PROVIDED <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-ASSUME_PROVIDED>`__\ 中删除“texinfo-native”，并从\ `SANITY_REQUIRED_UTILITIES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SANITY_REQUIRED_UTILITIES>`__\ 中删除makeinfo。

5.147 toaster类
==================

toaster类收集有关软件包和映像的信息，并将它们作为BitBake用户界面可以接收的事件发送。当运行Toaster用户界面时启用该类。

此类不应直接使用。

5.148 toolchain-scripts类
===========================

toolchain-scripts类提供用于设置已安装SDK环境的脚本。

5.149 typecheck类
=====================

typecheck类提供了验证配置级别设置的变量值与其定义类型是否匹配的支持。OpenEmbedded构建系统允许您使用“type”
varflag定义变量的类型。以下是一个例子：

::

   IMAGE_FEATURES[type] = "list"

5.150 uboot-config类
uboot-config类为机器提供U-Boot配置支持。在配方中指定机器的方法如下：

::

   UBOOT_CONFIG ??= <default>
   UBOOT_CONFIG[foo] = "config,images,binary"

您还可以使用以下方法指定机器：

::

   UBOOT_MACHINE = "config"

有关\ `UBOOT_CONFIG <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_CONFIG>`__\ 和\ `UBOOT_MACHINE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_MACHINE>`__\ 变量的更多信息，请参阅相关文档。

5.151 uboot-sign类
=====================

uboot-sign类提供对U-Boot的验证启动支持。它旨在从U-Boot配方中继承。

以下是此类使用的一些变量：

`SPL_MKIMAGE_DTCOPTS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SPL_MKIMAGE_DTCOPTS>`__\ ：构建FIT映像时U-Boot
mkimage的DTC选项。

`SPL_SIGN_ENABLE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SPL_SIGN_ENABLE>`__\ ：启用对FIT映像进行签名。

`SPL_SIGN_KEYDIR <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SPL_SIGN_KEYDIR>`__\ ：包含签名密钥的目录。

`SPL_SIGN_KEYNAME <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-SPL_SIGN_KEYNAME>`__\ ：签名密钥的基本文件名。

`UBOOT_FIT_ADDRESS_CELLS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_ADDRESS_CELLS>`__\ ：FIT映像的#address-cells值。

`UBOOT_FIT_DESC <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_DESC>`__\ ：编码到FIT映像中的描述字符串。

`UBOOT_FIT_GENERATE_KEYS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_GENERATE_KEYS>`__\ ：如果密钥尚不存在，则生成密钥。

`UBOOT_FIT_HASH_ALG <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_HASH_ALG>`__\ ：FIT映像的哈希算法。

`UBOOT_FIT_KEY_GENRSA_ARGS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_KEY_GENRSA_ARGS>`__\ ：openssl
genrsa参数。

`UBOOT_FIT_KEY_REQ_ARGS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_KEY_REQ_ARGS>`__\ ：openssl
req参数。

`UBOOT_FIT_SIGN_ALG <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_SIGN_ALG>`__\ ：FIT映像的签名算法。

`UBOOT_FIT_SIGN_NUMBITS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_SIGN_NUMBITS>`__\ ：FIT映像签名的私钥大小。

`UBOOT_FIT_KEY_SIGN_PKCS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FIT_KEY_SIGN_PKCS>`__\ ：用于FIT映像签名的公钥证书的算法。

`UBOOT_FITIMAGE_ENABLE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_FITIMAGE_ENABLE>`__\ ：启用生成U-Boot
FIT映像。

`UBOOT_MKIMAGE_DTCOPTS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-UBOOT_MKIMAGE_DTCOPTS>`__\ ：在重建包含内核的FIT映像时U-Boot
mkimage的DTC选项。

有关验证启动和签名过程的详细信息，请参阅\ `U-Boot <https://source.denx.de/u-boot/u-boot/-/blob/master/doc/uImage.FIT/verified-boot.txt>`__\ 的文档。

另请参阅\ `kernel-fitimage <https://docs.yoctoproject.org/4.0.17/ref-manual/classes.html#ref-classes-kernel-fitimage>`__\ 类的描述，该类模仿了此类。

5.152 uninative类
=====================

uninative类试图将构建系统与主机发行版的C库隔离，以便在不同主机发行版之间实现原生共享状态工件的重用。启用此类时，将在构建开始时下载包含预构建C库的tarball。在Poky参考发行版中，通过meta/conf/distro/include/yocto-uninative.inc默认启用此功能。其他不源自poky的发行版也可以通过“require
conf/distro/include/yocto-uninative.inc”来使用此功能。或者，如果您愿意，可以自己构建uninative-tarball食谱，发布生成的tarball（例如通过HTTP）并适当设置UNIINATIVE_URL和UNIINATIVE_CHECKSUM。有关示例，请参阅meta/conf/distro/include/yocto-uninative.inc。

extensible SDK也无条件使用uninative类。构建extensible
SDK时，会构建uninative-tarball，并且生成的tarball包含在SDK中。

5.153 update-alternatives类
==============================

update-alternatives类帮助alternatives系统处理多个来源提供相同命令的情况。当几个具有相同或相似功能的程序以相同的名称安装时，就会发生这种情况。例如，ar命令可以从busybox、binutils和elfutils包中获得。update-alternatives类处理重命名二进制文件，以便可以在没有冲突的情况下安装多个包。无论安装或随后删除了哪些包，ar命令仍然可以正常工作。该类在每个包中重命名冲突的二进制文件，并在安装或删除包期间将最高优先级的二进制文件创建为符号链接。

要使用此类，您需要定义一些变量：

`ALTERNATIVE <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-ALTERNATIVE>`__

`ALTERNATIVE_LINK_NAME <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-ALTERNATIVE_LINK_NAME>`__

`ALTERNATIVE_TARGET <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-ALTERNATIVE_TARGET>`__

`ALTERNATIVE_PRIORITY <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-ALTERNATIVE_PRIORITY>`__

这些变量列出了一个包所需的替代命令，提供了链接的路径名，目标的默认链接等。有关如何使用此类的详细信息，请参阅update-alternatives.bbclass文件中的注释。

.. note::

   您可以直接在食谱中使用update-alternatives命令。然而，在大多数情况下，此类简化了事情。

5.154 update-rc.d类
======================

update-rc.d类使用update-rc.d安全地代表包安装初始化脚本。OpenEmbedded构建系统负责细节，如确保在删除包之前停止脚本，并在安装包时启动脚本。

三个变量控制这个类：\ `INITSCRIPT_PACKAGES <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-INITSCRIPT_PACKAGES>`__\ 、\ `INITSCRIPT_NAME <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-INITSCRIPT_NAME>`__\ 和\ `INITSCRIPT_PARAMS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-INITSCRIPT_PARAMS>`__\ 。有关详细信息，请参阅变量链接。

5.155 useradd\* 类
====================

useradd*类支持为目标上的包使用添加用户或组。例如，如果您有包含应在其自己的用户或组下运行的系统服务的包，可以使用这些类来启用用户或组的创建。Source
Directory中的meta-skeleton/recipes-skeleton/useradd/useradd-example.bb食谱提供了一个简单的例子，展示了如何向两个包添加三个用户和组。

useradd_base类提供用户或组设置的基本功能。

useradd*类支持USERADD_PACKAGES、USERADD_PARAM、GROUPADD_PARAM和GROUPMEMS_PARAM变量。

useradd-staticids类支持添加具有静态用户标识（uid）和组标识（gid）值的用户或组。

OpenEmbedded构建系统在包安装时分配uid和gid值的默认行为是动态添加它们。这对于不关心结果用户和组的值变成什么的程序来说是正常的。在这些情况下，安装的顺序决定了最终的uid和gid值。然而，如果非确定的uid和gid值成为问题，您可以通过设置静态值来覆盖这些值的默认动态应用。当您设置静态值时，OpenEmbedded构建系统会在BBPATH中查找文件/passwd和文件/group文件以获取值。

要使用静态uid和gid值，您需要设置一些变量。请参阅USERADDEXTENSION、USERADD_UID_TABLES、USERADD_GID_TABLES和USERADD_ERROR_DYNAMIC变量。您还可以查看useradd*类以获取更多信息。

.. note::

   您不会直接使用useradd-staticids类。您可以通过设置USERADDEXTENSION变量来启用或禁用该类。如果在配置系统中启用或禁用该类，TMPDIR可能包含错误的uid和gid值。删除TMPDIR目录将纠正此情况。

5.156 utility-tasks类
========================

utility-tasks类为所有配方提供各种“实用”类型的任务支持，例如do_clean和do_listtasks。

这个类默认启用，因为它被基类继承。

5.157 utils类
================

utils类提供了一些通常在内联Python表达式中使用的有用的Python函数（例如${@…}）。一个示例用途是bb.utils.contains()。

这个类默认启用，因为它被基类继承。

5.158 vala类
==============

vala类支持需要构建使用Vala编程语言编写的软件的配方。

5.159 waf类
=============

waf类支持需要构建使用Waf构建系统构建的软件的配方。您可以使用\ `EXTRA_OECONF <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-EXTRA_OECONF>`__\ 或\ `PACKAGECONFIG_CONFARGS <https://docs.yoctoproject.org/4.0.17/ref-manual/variables.html#term-PACKAGECONFIG_CONFARGS>`__\ 变量指定要传递给Waf命令行的附加配置选项。
