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

-  do_configure — 重新生成 configure 脚本（使用
   autoreconf），然后使用交叉编译期间使用的标准参数集启动它。您可以通过
   EXTRA_OECONF 或 PACKAGECONFIG_CONFARGS 变量向 configure
   传递额外参数。

-  do_compile — 运行 make 命令，并指定编译器和链接器的参数。您可以通过
   EXTRA_OEMAKE 变量传递额外的参数。

-  do_install — 运行 make install 命令，并将 ${D} 作为 DESTDIR
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

-  使用旧的基于 Makefile.PL 的构建系统的模块需要在它们的配方中使用
   cpan.bbclass。

-  使用基于 Build.PL 的构建系统的模块需要在它们的配方中使用
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

-  带有.dts扩展名的常规设备树源文件。

-  检测到文件内容中存在/plugin/;字符串的设备树覆盖层。

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

-  REQUIRED_DISTRO_FEATURES

-  CONFLICT_DISTRO_FEATURES

-  ANY_OF_DISTRO_FEATURES

-  REQUIRED_MACHINE_FEATURES

-  CONFLICT_MACHINE_FEATURES

-  ANY_OF_MACHINE_FEATURES

-  REQUIRED_COMBINED_FEATURES

-  CONFLICT_COMBINED_FEATURES

-  ANY_OF_COMBINED_FEATURES

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
