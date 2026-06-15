.. _bitbake:

BitBake 手册
##############


=======
1 概述
=======

欢迎来到BitBake用户手册。本手册提供了关于BitBake工具的信息。这些信息尽可能地独立于使用BitBake的系统，例如OpenEmbedded和Yocto项目。在某些情况下，手册中使用了构建系统的情景或示例来帮助理解。对于这些情况，手册会明确说明上下文。

1.1 介绍
=========

从根本上讲，BitBake是一个通用任务执行引擎，它允许在复杂的任务间依赖性约束中高效且并行地运行shell和Python任务。BitBake的一个主要用户OpenEmbedded，利用这一核心，采用面向任务的方法构建嵌入式Linux软件堆栈。

从概念上讲，BitBake在某些方面与GNU Make相似，但有显著的不同：

-  BitBake根据提供的元数据执行任务，这些元数据构建了任务。元数据存储在配方文件（.bb）和相关的配方“追加”文件（.bbappend）、配置（.conf）以及底层的包含（.inc）文件中，还有类（.bbclass）文件中。这些元数据为BitBake提供了关于运行哪些任务以及这些任务之间的依赖关系的指令。

-  BitBake包含了一个获取源代码的fetcher库，它能够从各种地方获取源代码，如本地文件、源代码控制系统或网站。

-  每个要构建的单元（例如，一个软件）的指令被称为“配方”文件，其中包含有关该单元的所有信息（依赖性、源文件位置、校验和、描述等等）。

-  BitBake包含了客户端/服务器抽象，可以通过命令行使用，也可以通过XML-RPC作为服务使用，并且拥有几种不同的用户界面。

1.2 历史和目标
===============

BitBake最初是OpenEmbedded项目的一部分。它的灵感来自Gentoo
Linux发行版使用的Portage包管理系统。2004年12月7日，OpenEmbedded项目团队成员Chris
Larson将该项目拆分为两个独立的部分：

-  BitBake，一个通用任务执行器

-  OpenEmbedded，BitBake所使用的一个元数据集

今天，BitBake是OpenEmbedded项目的主要基础，该项目被用于构建和维护诸如Poky参考发行版这样的Linux发行版，这是在Yocto项目的框架下开发的。

在BitBake出现之前，没有任何其他构建工具能够满足一个有抱负的嵌入式Linux发行版的需求。所有被传统桌面Linux发行版使用的构建系统都缺乏重要的功能，而且在嵌入式领域中普遍存在的基于Buildroot的临时构建系统既不具可扩展性也不易于维护。

BitBake的一些重要原始目标包括：

-  处理交叉编译。

-  处理包间依赖性（目标架构上的构建时、原生架构上的构建时和运行时）。

-  支持在给定的软件包内运行任意数量的任务，包括但不限于获取上游源代码、解压它们、修补它们、配置它们等等。

-  对构建和目标系统来说，要与Linux发行版无关。

-  要与架构无关。

-  支持多个构建和目标操作系统（例如Cygwin、BSDs等）。

-  要自包含，而不是紧密集成到构建机的根文件系统中。

-  处理针对目标架构、操作系统、发行版和机器的条件元数据。

-  易于使用工具来提供本地元数据和操作所需的软件包。

-  易于使用BitBake在多个项目之间协作构建。

-  提供一个继承机制，以在许多软件包之间共享通用的元数据。

随着时间的推移，显然需要一些进一步的要求：

-  处理基础配方的变体（例如，本地版、软件开发套件版和多版本库）。
-  将元数据分层，并允许层与层之间的增强或覆盖。
-  允许将给定任务的一组输入变量表示为校验和。基于该校验和，允许使用预构建组件加速构建过程。

BitBake满足了所有原始要求，并通过对基本功能进行扩展来反映更多的额外需求。灵活性和强大一直是其优先考虑的事项。BitBake具有高度可扩展性，并支持嵌入式Python代码和执行任意任务。

1.3 概念
=========

BitBake是一个用Python语言编写的程序。在最高层次上，BitBake解释元数据，决定需要运行哪些任务，并执行这些任务。与GNU
Make类似，BitBake控制软件的构建方式。GNU
Make通过“makefiles”来实现其控制，而BitBake则使用“配方”。

BitBake通过允许定义更复杂的任务，如组装整个嵌入式Linux发行版，扩展了像GNU
Make这样的简单工具的能力。

本节的其余部分介绍了几个概念，理解这些概念有助于更好地利用BitBake的力量。

1.3.1 Recipes
---------------

BitBake配方文件，以.bb文件扩展名表示，是最基础的元数据文件。这些配方文件为BitBake提供以下信息：

-  关于软件包的描述性信息（作者、主页、许可证等）
-  配方的版本
-  现有的依赖关系（构建时和运行时依赖）
-  源代码的位置以及如何获取它
-  源代码是否需要任何补丁，如何找到它们，以及如何应用它们
-  如何配置和编译源代码
-  如何将生成的构件组装成一个或多个可安装的软件包
-  在目标机器上安装所创建的软件包的位置
-  在BitBake的上下文中，或任何使用BitBake作为其构建系统的项目中，带有.bb扩展名的文件被称为配方。

.. note::

   “软件包”这个词也常用来描述配方。然而，由于同一个词被用来描述项目的打包输出，最好保持一个单一的描述性术语-“配方”。换句话说，一个单独的“配方”文件完全有能力生成多个相关但可单独安装的“软件包”。实际上，这种能力相当常见。

1.3.2 Configuration Files
---------------------------

配置文件，以.conf扩展名表示，定义了各种配置变量，这些变量管理项目的构建过程。这些文件分为几个区域，定义了机器配置、发行版配置、可能的编译器调优、通用的公共配置以及用户配置。主要的配置文件是示例bitbake.conf文件，它位于BitBake源代码树的conf目录中。

1.3.3 Classes
---------------

类文件，以.bbclass扩展名表示，包含在元数据文件之间共享的有用信息。BitBake源代码树目前带有一个名为base.bbclass的类元数据文件。您可以在classes目录中找到这个文件。base.bbclass类文件是特殊的，因为它总是自动包含在所有配方和类中。这个类包含了标准基本任务的定义，如获取、解包、配置（默认为空）、编译（运行任何存在的Makefile）、安装（默认为空）和打包（默认为空）。这些任务经常被项目开发过程中添加的其他类覆盖或扩展。

1.3.4 Layers
--------------

层允许您将不同类型的自定义隔离开来。虽然当您在处理单个项目时，可能会觉得将所有内容保留在一个层中很诱人，但是您的元数据越模块化，就越容易应对未来的变化。

为了说明如何使用层来保持模块化，考虑您可能对特定目标机器所做的定制。这类定制通常驻留在一个特殊的层中，而不是一个通用的层，称为板级支持包（BSP）层。此外，机器定制应该与支持新GUI环境的配方和元数据隔离开来。这种情况为您提供了几个层：一个用于机器配置，另一个用于GUI环境。然而，重要的是要理解，BSP层仍然可以在不污染GUI层本身的情况下，为GUI环境层内的配方添加特定于机器的内容。您可以通过一个BitBake追加文件（.bbappend）来实现这一点。

1.3.5 Append Files
--------------------

追加文件，即具有.bbappend文件扩展名的文件，可以扩展或覆盖现有配方文件中的信息。

BitBake期望每个追加文件都有一个相应的配方文件。此外，追加文件和相应的配方文件必须使用相同的根文件名。文件名只能在使用的文件类型后缀上有所不同（例如，formfactor_0.0.bb和formfactor_0.0.bbappend）。

追加文件中的信息扩展或覆盖了底层的、同名的配方文件中的信息。

当您命名一个追加文件时，可以使用“%”通配符来允许匹配配方名称。例如，假设您有一个如下命名的追加文件：

::

   busybox_1.21.%.bbappend

该追加文件将匹配任何busybox_1.21.x.bb版本的配方。因此，追加文件将匹配以下配方名称：

::

   busybox_1.21.1.bb
   busybox_1.21.2.bb
   busybox_1.21.3.bb

.. note::

   “%”字符的使用是有限的，它只能在追加文件名的.bbappend部分前面直接使用。您不能在名称的任何其他位置使用通配符。

如果busybox配方更新为busybox_1.3.0.bb，追加文件名将不会匹配。然而，如果您将追加文件命名为busybox_1.%.bbappend，那么您将会有一个匹配。

在最普遍的情况下，您可以将追加文件命名为像busybox_%.bbappend这样简单的名字，以完全独立于版本。

1.4 获取 BitBake
================

您可以通过几种不同的方式获取BitBake：:

-  **克隆BitBake：** 使用Git克隆BitBake源代码存储库是获取BitBake的推荐方法。克隆存储库可以轻松获取错误修复，并能够访问稳定分支和主分支。一旦您克隆了BitBake，您应该使用最新的稳定分支进行开发，因为主分支是用于BitBake开发的，可能包含不太稳定的更改。

   您通常需要与所使用的元数据匹配的BitBake版本。元数据通常是向后兼容的，但不支持向前兼容。

   以下是一个克隆BitBake存储库的示例：

   ::

      $ git clone git://git.openembedded.org/bitbake

   此命令将BitBake
   Git存储库克隆到一个名为bitbake的目录中。或者，如果您想将新目录命名为其他名称而不是bitbake，您可以在git
   clone命令后指定一个目录。以下是一个将目录命名为bbdev的示例：

   ::

      $ git clone git://git.openembedded.org/bitbake bbdev

-  **使用发行版包管理系统进行安装：** 这种方法不推荐，因为大多数情况下，您的发行版提供的BitBake版本比BitBake存储库的快照要落后几个版本。

-  **获取BitBake的快照：** 从源代码存储库下载BitBake的快照，可以让您访问已知的分支或发布版本的BitBake。

   .. note::

      如前所述，克隆Git存储库是获取BitBake的首选方法。克隆存储库使得在稳定分支添加补丁时更容易进行更新。

   以下示例下载BitBake版本1.17.0的快照：

   ::

      $ wget https://git.openembedded.org/bitbake/snapshot/bitbake-1.17.0.tar.gz
      $ tar zxpvf bitbake-1.17.0.tar.gz

   使用tar工具解压tarball后，您将得到一个名为bitbake-1.17.0的目录。

-  **使用随您的构建检出而来的BitBake：** 获取BitBake副本的最后一个可能性是，它已经包含在您检出的基于BitBake的更大构建系统中，例如Poky。与其手动检出各个层并自行粘合它们，不如直接检出整个构建系统。这个检出将包含一个经过彻底测试，与其他组件兼容的BitBake版本。有关如何检出特定基于BitBake的构建系统的信息，请查阅该构建系统的支持文档。

1.5 The BitBake 命令
=====================

bitbake命令是BitBake工具的主要接口。本节介绍BitBake命令的语法，并提供了几个执行示例。

1.5.1. 用法和语法
-----------------

以下是BitBake的用法和语法：

::

   $ bitbake -h
   Usage: bitbake [options] [recipename/target recipe:do_task ...]

       Executes the specified task (default is 'build') for a given set of target recipes (.bb files).
       It is assumed there is a conf/bblayers.conf available in cwd or in BBPATH which
       will provide the layer, BBFILES and other configuration information.

   -h 或 --help：显示帮助信息并退出。

   -b BUILDFILE 或 --buildfile=BUILDFILE：从特定的.bb配方文件中直接执行任务。注意，这不会处理其他配方文件中的任何依赖项。

   -k 或 --continue：在出错后尽可能继续执行。尽管失败的目标及其依赖项无法构建，但在停止之前尽可能多地构建其他内容。

   -f 或 --force：强制运行指定的目标/任务（使任何现有的标记文件失效）。

   -c CMD 或 --cmd=CMD：指定要执行的任务。可用的确切选项取决于元数据。一些示例可能是'compile'、'populate_sysroot'或'listtasks'，后者可以列出可用的任务列表。
   -C INVALIDATE_STAMP 或 --clear-stamp=INVALIDATE_STAMP`：使指定任务的标记无效，然后运行指定目标的默认任务。

   -r PREFILE 或 --read=PREFILE：在读取bitbake.conf之前读取指定的文件。

   -R POSTFILE 或 --postread=POSTFILE：在读取bitbake.conf之后读取指定的文件。

   -v` 或 --verbose：启用shell任务的跟踪（使用'set -x'）。还将bb.note(...)消息打印到stdout（除了将它们写入${T}/log.do_<task>）。

   -D` 或 --debug：增加调试级别。您可以多次指定此选项。-D将调试级别设置为1，其中只打印bb.debug(1, ...)消息到stdout；-DD将调试级别设置为2，其中打印bb.debug(1, ...)和bb.debug(2, ...)消息；等等。没有-D，不打印任何调试消息。请注意，-D仅影响stdout的输出。所有调试消息都写入${T}/log.do_taskname，无论调试级别如何。

   -q 或 --quiet：减少终端上的日志消息数据输出。您可以多次指定此选项。

   -n 或 --dry-run：不执行，只是进行动作模拟。

   -S SIGNATURE_HANDLER 或 --dump-signatures=SIGNATURE_HANDLER：转储签名构造信息，不执行任务。SIGNATURE_HANDLER参数传递给处理程序。两个常见值是none和printdiff，但处理程序可能定义更多/更少。none表示仅转储签名，printdiff表示将转储的签名与缓存的签名进行比较。

   -p 或 --parse-only：解析BB配方文件后退出。

   -s 或 --show-versions：显示所有配方文件的当前和首选版本。

   -e 或 --environment：显示全局或每个配方的环境，包括关于变量设置/更改位置的信息。

   -g 或 --graphviz：为指定目标保存依赖关系树信息，采用dot语法。

   -l DEBUG_DOMAINS 或 --log-domains=DEBUG_DOMAINS：显示指定日志域的调试日志。

   -P 或 --profile：分析命令并保存报告。

   -u UI 或 --ui=UI：要使用的用户界面（knotty，ncurses，taskexp或teamcity - 默认knotty）。

   --token=XMLRPCTOKEN：指定连接到远程服务器时要使用的连接令牌。

   --revisions-changed：根据上游浮动修订是否已更改来设置退出代码。

   --server-only：不带UI运行bitbake，仅启动一个服务器（cooker）进程。

   -B BIND 或 --bind=BIND：bitbake xmlrpc服务器要绑定的名称/地址。

   -T SERVER_TIMEOUT 或 --idle-timeout=SERVER_TIMEOUT：由于不活动而卸载bitbake服务器的超时设置为-1表示不卸载，默认：环境变量BB_SERVER_TIMEOUT。

   --no-setscene：不运行任何setscene任务。sstate将被忽略，需要的一切将构建。

   --skip-setscene：如果将执行setscene任务，则跳过setscene任务。从sstate恢复的任务将保留，不像--no-setscene。

   --setscene-only：仅运行setscene任务，不运行任何实际任务。

   --remote-server=REMOTE_SERVER：连接到指定的服务器。

   -m 或 --kill-server：终止任何正在运行的bitbake服务器。

   --observe-only：作为仅观察客户端连接到服务器。

   --status-only：检查远程bitbake服务器的状态。

   -w WRITEEVENTLOG 或 --write-log=WRITEEVENTLOG：将构建的事件日志写入bitbake事件json文件。使用空字符串自动分配名称。

   --runall=RUNALL：为指定目标的任务图中的任何配方运行指定的任务（即使它否则不会运行）。

   --runonly=RUNONLY：在指定目标的任务图中仅运行指定的任务（以及这些任务可能具有的任何任务依赖项）。

1.5.2 Examples
----------------

这个部分提供了一些示例，展示了如何使用BitBake。

1.5.2.1 执行单个配方的任务
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

执行单个配方文件的任务相对简单。你指定有问题的文件，BitBake解析它并执行指定的任务。如果你没有指定一个任务，BitBake会执行默认的任务，即“构建”。在这样做时，BitBake遵循任务间的依赖关系。

以下命令在foo_1.0.bb配方文件上运行构建任务，这是默认任务：

::

   $ bitbake -b foo_1.0.bb

以下命令在foo.bb配方文件上运行清理任务：

::

   $ bitbake -b foo.bb -c clean

.. note::

   “-b”选项明确不处理配方依赖性。除了用于调试目的外，建议您使用下一节中介绍的语法。

1.5.2.2 执行一组配方文件的任务
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

当一个人想要管理多个.bb文件时，会引入许多额外的复杂性。显然，需要有一种方法告诉BitBake哪些文件是可用的，以及在这些文件中，你想要执行哪些。每个配方还需要有一种方式来表达其依赖性，无论是构建时还是运行时。当多个配方提供相同的功能，或者存在多个版本的配方时，你必须有一种方式来表达对配方的偏好。

bitbake命令，在不使用“–buildfile”或“-b”时，仅接受一个“PROVIDES”。你不能提供其他任何东西。默认情况下，配方文件通常“PROVIDES”其“packagename”，如下例所示：

::

   $ bitbake foo

下面的例子“提供”了包名，并使用“-c”选项告诉BitBake只执行do_clean任务：

::

   $ bitbake -c clean foo

1.5.2.3 执行任务和配方组合的列表
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

BitBake命令行支持在指定多个目标时，为各个目标指定不同的任务。例如，假设你有两个目标（或配方）myfirstrecipe和mysecondrecipe，你需要BitBake为第一个配方运行taskA，为第二个配方运行taskB：

::

   $ bitbake myfirstrecipe:do_taskA mysecondrecipe:do_taskB

1.5.2.4 生成依赖图
^^^^^^^^^^^^^^^^^^^

BitBake能够使用dot语法生成依赖图。你可以使用Graphviz的dot工具将这些图转换为图像。

当你生成一个依赖图时，BitBake会在当前工作目录写入两个文件：

-  task-depends.dot：显示任务之间的依赖关系。这些依赖关系与BitBake的内部任务执行列表相匹配。
-  pn-buildlist：显示要构建的目标的简单列表。

要停止依赖于common depends，使用-I
depend选项，BitBake会从图中省略它们。省略这些信息可以产生更易读的图。这样，你可以从图中移除继承自base.bbclass等类的DEPENDS。

以下是创建依赖图的两个示例。第二个示例从图中省略了OpenEmbedded中常见的depends：

::

   $ bitbake -g foo
   $ bitbake -g -I virtual/kernel -I eglibc foo

1.5.2.5 执行多配置构建
^^^^^^^^^^^^^^^^^^^^^^^

BitBake能够使用单个命令构建多个映像或包，其中不同目标需要不同的配置（多配置构建）。在这种情况下，每个目标被称为“多配置”。

要完成多配置构建，你必须使用构建目录中的并行配置文件分别为每个目标定义配置。这些多配置配置文件的位置是特定的。它们必须驻留在当前构建目录的conf子目录中的multiconfig子目录中。以下是两个独立目标的示例：

.. image:: ./images/1.5.2.5_0.png

这种必需的文件层次结构的原因是，BBPATH变量在解析层之前不会被构建。因此，除非配置文件位于当前工作目录中，否则无法将其用作预配置文件。

至少，每个配置文件必须定义BitBake用于构建的机器和临时目录。建议的做法是，你不要重叠构建期间使用的临时目录。

除了为每个目标分别配置配置文件外，你还必须启用BitBake执行多配置构建。启用是通过在local.conf配置文件中设置BBMULTICONFIG变量来完成的。例如，假设你在构建目录中为目标1和目标2定义了配置文件。在local.conf文件中的以下语句既启用了BitBake执行多配置构建，又指定了两个额外的多配置：

::

   BBMULTICONFIG = "target1 target2"

一旦目标配置文件就绪，并且BitBake已被启用以执行多配置构建，使用以下命令形式开始构建：

::

   $ bitbake [mc:multiconfigname:]target [[[mc:multiconfigname:]target] ... ]

以下是两个额外的多配置：target1和target2的示例：

::

   $ bitbake mc::target mc:target1:target mc:target2:target

1.5.2.6 启用多配置构建依赖项
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

在多配置构建中，有时目标（多配置）之间可能存在依赖关系。例如，假设为了构建一个特定架构的映像，需要存在另一个不同架构构建的根文件系统。换句话说，第一个多配置的映像依赖于第二个多配置的根文件系统。这种依赖本质上是构建一个多配置的配方中的任务依赖于构建另一个多配置的配方中任务的完成。

要在多配置构建中启用依赖项，你必须在配方中使用以下语句形式声明依赖项：

::

   task_or_package[mcdepends] = "mc:from_multiconfig:to_multiconfig:recipe_name:task_on_which_to_depend"

为了更好地展示如何使用这个语句，考虑一个带有两个多配置：target1和target2的例子：

::

   image_task[mcdepends] = "mc:target1:target2:image2:rootfs_task"

在这个例子中，from_multiconfig是“target1”，to_multiconfig是“target2”。包含image_task的映像配方上的任务依赖于用于构建与“target2”多配置相关联的image2的rootfs_task的完成。

一旦你设置了这个依赖项，你可以使用以下BitBake命令构建“target1”多配置：

::

   $ bitbake mc:target1:image1

这个命令执行创建“target1”多配置的image1所需的所有任务。由于依赖关系，BitBake还会执行“target2”多配置构建的rootfs_task。

让配方依赖于另一个构建的根文件系统可能看起来没那么有用。考虑对image1配方中的语句进行以下更改：

::

   image_task[mcdepends] = "mc:target1:target2:image2:image_task"

在这种情况下，由于“target1”构建依赖于它，BitBake必须为“target2”构建创建image2。

因为“target1”和“target2”启用了多配置构建并且有各自的配置文件，BitBake将每个构建的工件放置在各自的临时构建目录中。

=======
2 执行
=======

运行BitBake的主要目的是生成某种输出，如单个可安装包、内核、软件开发工具包，甚至是完整的、特定于板的可引导Linux映像，包括引导加载程序、内核和根文件系统。当然，你可以使用选项执行bitbake命令，使其执行单个任务，编译单个配方文件，捕获或清除数据，或者简单地返回有关执行环境的信息。

本章描述了当你使用它创建映像时，BitBake的执行过程从头到尾。执行过程是使用以下命令形式启动的：

::

   $ bitbake target 

有关BitBake命令及其选项的信息，请参阅“BitBake命令”部分。

.. note::

   在执行BitBake之前，你应该通过设置项目local.conf配置文件中的BB_NUMBER_THREADS变量，利用构建主机上的可用并行线程执行。

   确定构建主机此值的常见方法是运行以下命令：

   ::

      $ grep processor /proc/cpuinfo

   此命令返回处理器数量，考虑到超线程。因此，具有超线程的四核构建主机最有可能显示八个处理器，这是你将分配给BB_NUMBER_THREADS的值。

   一个可能更简单的解决方案是，一些Linux发行版（例如Debian和Ubuntu）提供了ncpus命令。

2.1 解析基础配置元数据
=========================

BitBake做的第一件事就是解析基础配置元数据。基础配置元数据包括你项目的bblayers.conf文件，以确定BitBake需要识别哪些层，所有必要的layer.conf文件（每个层一个），和bitbake.conf。数据本身有各种类型：

-  **配方：**\ 有关特定软件部分的详细信息。
-  **类数据：**\ 构建信息的抽象（例如，如何构建Linux内核）。
-  **配置数据：**\ 特定于机器的设置、策略决策等等。配置数据充当将一切绑定在一起的粘合剂。

layer.conf文件用于构造诸如BBPATH和BBFILES之类的关键变量。BBPATH用于在conf和classes目录下搜索配置和类文件。BBFILES用于定位配方文件和配方追加文件（.bb和.bbappend）。如果没有bblayers.conf文件，会假定用户已经在环境中直接设置了BBPATH和BBFILES。

接下来，使用刚刚构建的BBPATH变量来定位bitbake.conf文件。bitbake.conf文件也可能使用include或require指令包含其他配置文件。

在解析配置文件之前，BitBake会查看某些变量，包括：

-  `BB_ENV_PASSTHROUGH <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_ENV_PASSTHROUGH>`__
-  `BB_ENV_PASSTHROUGH_ADDITIONS <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_ENV_PASSTHROUGH_ADDITIONS>`__
-  `BB_PRESERVE_ENV <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_PRESERVE_ENV>`__
-  `BB_ORIGENV <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_ORIGENV>`__
-  `BITBAKE_UI <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BITBAKE_UI>`__

此列表中的前四个变量与BitBake在任务执行期间处理shell环境变量的方式有关。默认情况下，BitBake清理环境变量并对shell执行环境进行严格控制。然而，通过使用这前四个变量，你可以控制允许BitBake在任务执行期间在shell中使用的环境变量。有关这些变量如何工作以及如何使用它们的更多信息，请参阅“\ `将信息传递到构建任务环境 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#passing-information-into-the-build-task-environment>`__\ ”部分以及变量词汇表中关于这些变量的信息。

基础配置元数据是全局的，因此会影响所有执行的配方和任务。

BitBake首先搜索当前工作目录以查找可选的conf/bblayers.conf配置文件。该文件应包含一个BBLAYERS变量，该变量是由空格分隔的‘层’目录列表。回想一下，如果BitBake找不到bblayers.conf文件，那么它会假设用户已经在环境中直接设置了BBPATH和BBFILES变量。

对于此列表中的每个目录（层），都会定位并解析一个conf/layer.conf文件，并将LAYERDIR变量设置为找到层的目录。这样做的理念是，这些文件会自动为给定的构建目录正确设置BBPATH和其他变量。

然后，BitBake期望在用户指定的BBPATH中的某个地方找到conf/bitbake.conf文件。该配置文件通常包含include指令，以引入任何其他元数据，如特定于架构、机器、本地环境等的文件。

在BitBake
.conf文件中只允许有变量定义和include指令。一些变量直接影响BitBake的行为。这些变量可能是根据先前提到的环境变量从环境中设置的，或者在配置文件中设置的。“`变量词汇表 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#variables-glossary>`__”章节提供了一份完整变量列表。

解析配置文件后，BitBake使用其基本继承机制（通过类文件）来继承一些标准类。当遇到负责获取该类的inherit指令时，BitBake会解析一个类。

base.bbclass文件总是被包含的。在配置中使用INHERIT变量指定的其他类也被包含。BitBake在BBPATH中的路径下的classes子目录中搜索类文件，方式与配置文件相同。

了解执行环境中使用的配置文件和类文件的一个好方法是运行以下BitBake命令：

::

   $ bitbake -e > mybb.log

检查mybb.log的顶部可以显示执行环境中使用的许多配置文件和类文件。

.. note::

   你需要了解BitBake解析大括号的方式。如果配方在函数内使用闭合大括号，且该字符没有前导空格，BitBake会产生解析错误。如果你在shell函数中使用一对大括号，闭合大括号不能位于行首且没有前导空格。

   下面是一个导致BitBake产生解析错误的例子：

   ::

      fakeroot create_shar() {
         cat << "EOF" > ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.sh
      usage()
      {
         echo "test"
         ######  The following "}" at the start of the line causes a parsing error ######
      }
      EOF
      }

      Writing the recipe this way avoids the error:
      fakeroot create_shar() {
         cat << "EOF" > ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.sh
      usage()
      {
         echo "test"
         ###### The following "}" with a leading space at the start of the line avoids the error ######
       }
      EOF
      }

2.2 定位和解析配方
==================

在配置阶段，BitBake会设置BBFILES。现在BitBake使用它来构建要解析的配方列表，以及要应用的任何追加文件（.bbappend）。BBFILES是一个由空格分隔的可用文件列表，并支持通配符。一个例子可能是：

::

   BBFILES = "/path/to/bbfiles/*.bb /path/to/appends/*.bbappend"

BitBake解析使用BBFILES定位的每个配方和追加文件，并将各种变量的值存储到数据存储中。

.. note::

   追加文件按照在BBFILES中遇到的顺序应用。

对于每个文件，都会制作一份基础配置的副本，然后逐行解析配方。任何inherit语句都会导致BitBake使用BBPATH作为搜索路径来查找并解析类文件（.bbclass）。最后，BitBake按顺序解析在BBFILES中找到的任何追加文件。

一种常见的约定是使用配方文件名来定义元数据片段。例如，在bitbake.conf中，配方名称和版本用于设置变量PN和PV：

::

   PN = "${@bb.parse.vars_from_file(d.getVar('FILE', False),d)[0] or 'defaultpkgname'}"
   PV = "${@bb.parse.vars_from_file(d.getVar('FILE', False),d)[1] or '1.0'}"

在这个例子中，一个名为“something_1.2.3.bb”的配方会将PN设置为“something”，PV设置为“1.2.3”。

在配方解析完成时，BitBake会得到该配方定义的任务列表和由键值对组成的数据集，以及关于任务的依赖信息。

BitBake并不需要所有这些信息。它只需要这些信息的一小部分来对配方做出决策。因此，BitBake缓存了它感兴趣的值，并没有存储其他信息。经验表明，重新解析元数据比尝试将其写入磁盘然后重新加载要快。

在可能的情况下，后续的BitBake命令会重用这个配方信息的缓存。这个缓存的有效性是通过首先计算基础配置数据的校验和（参见\ `BB_HASHCONFIG_IGNORE_VARS <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_HASHCONFIG_IGNORE_VARS>`__\ ）然后检查校验和是否匹配来确定的。如果校验和与缓存中的匹配，且配方和类文件没有变化，BitBake就能够使用缓存。BitBake随后重新加载关于配方的缓存信息，而不是从头开始重新解析。

配方文件集合的存在是为了允许用户拥有多个包含完全相同软件包的.bb文件的仓库。例如，用户可以轻易地使用它们来制作上游仓库的本地副本，但包含用户不希望上游的自定义修改。这里有一个例子：

::

   BBFILES = "/stuff/openembedded/*/*.bb /stuff/openembedded.modified/*/*.bb"
   BBFILE_COLLECTIONS = "upstream local"
   BBFILE_PATTERN_upstream = "^/stuff/openembedded/"
   BBFILE_PATTERN_local = "^/stuff/openembedded.modified/"
   BBFILE_PRIORITY_upstream = "5"
   BBFILE_PRIORITY_local = "10"

.. note::

   层次结构机制现在是收集代码的首选方法。虽然集合代码仍然存在，但其主要用途是设置层优先级和处理层之间的重叠（冲突）。

2.3 Providers
==============

假设BitBake已被指示执行一个目标，并且所有配方文件都已被解析，BitBake开始计算如何构建该目标。BitBake查看每个配方的PROVIDES列表。PROVIDES列表是配方可能被知道的名称列表。每个配方的PROVIDES列表通过配方的PN变量隐式创建，也可以通过配方的PROVIDES变量显式创建，这是可选的。

当一个配方使用PROVIDES时，该配方的功能可以在除了隐式的PN名称之外的其他替代名称下找到。作为一个例子，假设一个名为keyboard_1.0.bb的配方包含以下内容：

::

   PROVIDES += "fullkeyboard"

这个配方的PROVIDES列表变成了“keyboard”，这是隐式的，以及“fullkeyboard”，这是显式的。因此，keyboard_1.0.bb中找到的功能可以在两个不同的名称下找到。

2.4 Preferences
================

PROVIDES列表只是解决目标配方问题的一部分。因为目标可能有多个提供者，BitBake需要通过确定提供者偏好来对提供者进行优先级排序。

一个目标有多个提供者的常见例子是“virtual/kernel”，它在每个内核配方的PROVIDES列表上。每台机器通常通过在机器配置文件中使用类似以下内容的行来选择最佳的内核提供者：

::

   PREFERRED_PROVIDER_virtual/kernel = "linux-yocto"

默认的PREFERRED_PROVIDER是与目标同名的提供者。BitBake遍历它需要构建的每个目标，并使用此过程解析它们及其依赖项。

理解如何选择提供者变得复杂的一个事实是，给定提供者可能存在多个版本。BitBake默认选择提供者的最高版本。版本比较使用与Debian相同的方法进行。您可以使用PREFERRED_VERSION变量指定特定版本。您可以使用DEFAULT_PREFERENCE变量影响顺序。

默认情况下，文件的优先级为“0”。将DEFAULT_PREFERENCE设置为“-1”意味着配方不太可能被使用，除非明确引用。将DEFAULT_PREFERENCE设置为“1”意味着配方很可能会被使用。PREFERRED_VERSION会覆盖任何DEFAULT_PREFERENCE设置。DEFAULT_PREFERENCE通常用于标记较新和更具实验性的配方版本，直到它们经过足够的测试被认为是稳定的。

当有多个给定配方的“版本”时，BitBake默认选择最新版本，除非另有规定。如果所提到的配方具有比其他配方（默认值为0）更低的DEFAULT_PREFERENCE，则它不会被选中。这允许维护配方文件仓库的人员指定他们对默认选择版本的偏好。此外，用户可以指定他们偏好的版本。

如果第一个配方命名为a_1.1.bb，那么PN变量将被设置为“a”，PV变量将被设置为1.1。

因此，如果存在名为a_1.2.bb的配方，BitBake将默认选择1.2。然而，如果您在BitBake解析的.conf文件中定义以下变量，您可以改变该偏好：

::

   PREFERRED_VERSION_a = "1.1"

.. note::

   一个配方提供两个版本是常见的——一个是稳定的、有编号的（并且首选的）版本，另一个是从源代码仓库自动检出的版本，被认为是更“前沿”的，但只能明确选择。

   例如，在OpenEmbedded代码库中，有一个标准的、带版本的BusyBox配方文件busybox_1.22.1.bb，但也有一个基于Git的版本busybox_git.bb，它明确包含了一行

   ::

      DEFAULT_PREFERENCE = "-1"

   以确保除非开发者另有选择，否则总是首选编号的、稳定版本。

2.5 Dependencies
=================

每个BitBake构建的目标都包括多个任务，如获取、解压、打补丁、配置和编译。为了在多核系统上获得最佳性能，BitBake将每个任务视为具有自己依赖项集的独立实体。

依赖项通过几个变量定义。您可以在本手册末尾的变量术语表中查找BitBake使用的变量信息。在基本层面上，只需知道BitBake在计算依赖项时使用DEPENDS和RDEPENDS变量即可。

有关BitBake处理依赖项的更多信息，请参阅\ `依赖项 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#dependencies>`__\ 部分。

2.6 任务列表
=============

基于生成的提供者列表和依赖信息，BitBake现在可以准确计算出它需要运行哪些任务以及以何种顺序运行它们。\ `《执行任务》 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-execution.html#executing-tasks>`__\ 一节有更多关于BitBake如何选择下一个要执行的任务的信息。

构建现在从BitBake开始，它会分叉出线程，直到达到在BB_NUMBER_THREADS变量中设置的限制。只要任务准备好运行，这些任务的所有依赖项都已满足，并且没有超过线程阈值，BitBake就会继续分叉线程。

值得注意的是，通过正确设置BB_NUMBER_THREADS变量，你可以大大加快构建时间。

每个任务完成后，会在STAMP变量指定的目录写入一个时间戳。在后续运行中，BitBake查看tmp/stamps内的构建目录，并不会重新运行已经完成的任务，除非发现时间戳无效。目前，只有在每个配方文件的基础上考虑无效的时间戳。例如，如果给定目标的配置戳的时间戳大于编译时间戳，那么编译任务会重新运行。然而，重新运行编译任务对依赖于该目标的其他提供者没有影响。

时间戳的确切格式是部分可配置的。在较新版本的BitBake中，哈希值被追加到戳上，以便如果配置发生变化，戳就变得无效，任务会自动重新运行。这个哈希值或使用的签名由配置的签名策略管理（见\ `《校验和（签名）节》 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-execution.html#checksums-signatures>`__\ 了解信息）。还可以使用[stamp-extra-info]任务标志将额外的元数据追加到戳上。例如，OpenEmbedded使用此标志使某些任务具有机器特定性。

.. note::

   有些任务被标记为“nostamp”任务。当这些任务运行时，不会创建时间戳文件。因此，“nostamp”任务总是会重新运行。

有关任务的更多信息，请参阅\ `《任务》 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#tasks>`__\ 一节。

2.7 执行任务
============

任务可以是shell任务或Python任务。对于shell任务，BitBake会将一个shell脚本写入\ ``${T}/run.do_taskname.pid``\ ，然后执行该脚本。生成的shell脚本包含所有导出的变量和所有变量展开后的shell函数。shell脚本的输出进入文件\ ``${T}/log.do_taskname.pid``\ 。查看运行文件中展开的shell函数和日志文件中的输出是一种有用的调试技术。

对于Python任务，BitBake在内部执行任务并将信息记录到控制终端。BitBake的未来版本将以类似于处理shell任务的方式将函数写入文件。日志记录也将以类似于shell任务的方式进行处理。

BitBake运行任务的顺序由其任务调度器控制。可以配置调度器并为特定用例定义自定义实现。有关更多信息，请参阅控制行为的这些变量：

-  `BB_SCHEDULER <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_SCHEDULER>`__

-  `BB_SCHEDULERS <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_SCHEDULERS>`__

可以在任务的主函数之前和之后运行函数。这是通过使用任务的[prefuncs]和[postfuncs]标志来完成的，这些标志列出了要运行的函数。

2.8 校验（签名）
================

校验和是一个任务输入的唯一签名。任务的签名可以用来判断一个任务是否需要运行。由于是任务输入的变化触发了任务的运行，BitBake需要检测给定任务的所有输入。对于shell任务来说，这相对简单，因为BitBake为每个任务生成一个“run”
shell脚本，并且可以创建一个校验和，让你很好地了解任务数据何时发生变化。

使问题复杂化的是，有些东西不应该包含在校验和中。首先，有给定任务的实际特定构建路径——工作目录。工作目录的变化并不重要，因为它不应该影响目标包的输出。排除工作目录的简单方法是将其设置为某个固定值，并为“run”脚本创建校验和。BitBake更进一步，使用\ `BB_BASEHASH_IGNORE_VARS <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_BASEHASH_IGNORE_VARS>`__\ 变量定义了一个列表，该列表中的变量在生成签名时永远不应该被包括。

另一个问题是“run”脚本包含了可能会或可能不会被调用的函数。增量构建解决方案包含了代码，用于确定shell函数之间的依赖关系。这段代码用于将“run”脚本削减到最小集合，从而解决这个问题，并作为额外好处使“run”脚本更易读。

到目前为止，我们有了针对shell脚本的解决方案。Python任务怎么办？即使这些任务更难，也适用同样的方法。这个过程需要弄清楚Python函数访问了哪些变量以及它调用了哪些函数。同样，增量构建解决方案包含了代码，首先确定变量和函数的依赖关系，然后为作为任务输入的数据创建校验和。

就像工作目录的情况一样，存在应该忽略依赖关系的情况。对于这些情况，你可以通过使用以下类似的行来指示构建过程忽略依赖关系：

::

   PACKAGE_ARCHS[vardepsexclude] = "MACHINE"

这个例子确保了PACKAGE_ARCHS变量不依赖于MACHINE的值，即使它确实引用了它。

同样，也有一些情况我们需要添加BitBake无法找到的依赖项。你可以通过使用以下类似的行来完成这一点：

::

   PACKAGE_ARCHS[vardeps] = "MACHINE"

这个例子明确地将MACHINE变量添加为PACKAGE_ARCHS的依赖项。

考虑一个内联Python的情况，例如，BitBake无法弄清楚依赖关系。当以调试模式运行时（即使用-DDD），BitBake在发现它无法弄清楚依赖关系的东西时会产生输出。

到目前为止，这一节只讨论了任务的直接输入。基于直接输入的信息在代码中被称为“basehash”。然而，还有一个问题是任务的间接输入——那些已经构建好并存在于构建目录中的东西。特定任务的校验和（或签名）需要添加该任务所依赖的所有任务的哈希值。选择添加哪些依赖项是一个策略决策。然而，其效果是生成一个主校验和，它结合了basehash和任务依赖项的哈希值。

在代码层面，有多种方法可以影响basehash和依赖任务哈希值。在BitBake配置文件中，我们可以给BitBake一些额外的信息来帮助它构建basehash。以下声明实际上导致了一个全局变量依赖排除列表——永远不会被包含在任何校验和中的变量。这个例子使用了OpenEmbedded的变量来帮助说明这个概念：

::

   BB_BASEHASH_IGNORE_VARS ?= "TMPDIR FILE PATH PWD BB_TASKHASH BBPATH DL_DIR \
       SSTATE_DIR THISDIR FILESEXTRAPATHS FILE_DIRNAME HOME LOGNAME SHELL \
       USER FILESPATH STAGING_DIR_HOST STAGING_DIR_TARGET COREBASE PRSERV_HOST \
       PRSERV_DUMPDIR PRSERV_DUMPFILE PRSERV_LOCKDOWN PARALLEL_MAKE \
       CCACHE_DIR EXTERNAL_TOOLCHAIN CCACHE CCACHE_DISABLE LICENSE_PATH SDKPKGSUFFIX"

上一个例子排除了作为TMPDIR一部分的工作目录。

决定通过依赖链包含哪些依赖任务的哈希值的规则更加复杂，通常使用Python函数来完成。meta/lib/oe/sstatesig.py中的代码显示了两个这样的例子，并且还说明了如果愿意，您可以将您自己的策略插入到系统中。这个文件定义了OpenEmbedded-Core使用的基本签名生成器：“OEBasicHash”。默认情况下，在BitBake中启用了一个虚拟的“noop”签名处理器。这意味着行为与之前的版本没有变化。OE-Core通过bitbake.conf文件中的这个设置默认使用“OEBasicHash”签名处理器：

::

   BB_SIGNATURE_HANDLER ?= "OEBasicHash"

“OEBasicHash”
`BB_SIGNATURE_HANDLER <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_SIGNATURE_HANDLER>`__\ 的主要特性是它将任务哈希添加到戳记文件中。得益于此，任何元数据的变化都会改变任务哈希，自动导致任务再次运行。这样就无需增加PR值，而且对元数据的更改会自动波及整个构建。

同样值得注意的是，签名生成器的最终结果是使某些依赖和哈希信息可供构建使用。这些信息包括：

-  BB_BASEHASH_task-taskname：每个任务的基础哈希。
-  BB_BASEHASH_filename:taskname：每个依赖任务的基础哈希。
-  BB_TASKHASH：当前运行任务的哈希。

值得注意的是，BitBake的“-S”选项允许您调试BitBake对签名的处理。传递给-S的选项允许使用不同的调试模式，既可以使用BitBake自己的调试函数，也可以使用可能在元数据/签名处理器本身中定义的调试函数。最简单的参数是“none”，它会导致一系列签名信息被写入与指定目标相对应的STAMPS_DIR。另一个目前可用的参数是“printdiff”，它导致BitBake尝试建立最接近的签名匹配（例如，在sstate缓存中），然后在匹配项上运行bitbake-diffsigs以确定两个戳记树分叉的戳记和差异。

.. note::

   未来的BitBake版本可能会通过额外的“-S”参数提供其他签名处理器。

您可以在\ `任务校验和和Setscene部分 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#task-checksums-and-setscene>`__\ 找到有关校验和元数据的更多信息。

2.9 Setscene
==============

setscene过程使BitBake能够处理“预构建”的工件。处理和重用这些工件的能力让BitBake不必每次都从头开始构建某个东西，而是尽可能使用现有的构建工件。

BitBake需要可靠的数据来指示一个工件是否兼容。前一节中描述的签名提供了表示工件是否兼容的理想方式。如果签名相同，一个对象可以被重用。

如果一个对象可以被重用，问题就变成了如何用预构建的工件替换给定的任务或一组任务。BitBake通过“setscene”过程解决这个问题。

当BitBake被要求构建一个给定的目标时，在构建任何东西之前，它首先询问是否为它正在构建的任何目标或任何中间目标提供了缓存信息。如果有可用的缓存信息，BitBake使用这些信息而不是运行主要任务。

BitBake首先调用由\ `BB_HASHCHECK_FUNCTION <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_HASHCHECK_FUNCTION>`__\ 变量定义的函数，该函数带有它想要构建的任务列表和相应的哈希。这个函数旨在快速返回它认为可以获得工件的任务列表。

接下来，对于作为可能性返回的每个任务，BitBake执行可能覆盖的工件的任务的setscene版本。任务的setscene版本在任务名称后附加了字符串“_setscene”。因此，例如，名为xxx的任务有一个名为xxx_setscene的setscene任务。任务的setscene版本执行并提供必要的工件，返回成功或失败。

如前所述，一个工件可以覆盖多个任务。例如，如果你已经有了编译后的二进制文件，获取编译器是没有意义的。为了处理这个问题，BitBake为每个成功的setscene任务调用\ `BB_SETSCENE_DEPVALID <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_SETSCENE_DEPVALID>`__\ 函数，以知道是否需要获取该任务的依赖项。

您可以在\ `任务校验和和Setscene部分 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#task-checksums-and-setscene>`__\ 找到有关setscene元数据的更多信息。

2.10 Logging
===============

除了标准的命令行选项来控制构建在执行时的详细程度，bitbake还支持通过BB_LOGCONFIG变量对Python日志设施进行用户自定义配置。这个变量定义了一个JSON或YAML的日志配置，将被智能地合并到默认配置中。日志配置按照以下规则合并：

如果顶层键bitbake_merge被设置为False，用户定义的配置将完全替换默认配置。在这种情况下，所有其他规则都被忽略。

用户配置必须有一个与默认配置值匹配的顶级版本。

在handlers、formatters或filters中定义的任何键，将被合并到默认配置中的相同部分，如果有冲突，用户指定的键将替换默认键。实际上，这意味着如果默认配置和用户配置都指定了一个名为myhandler的处理程序，用户定义的处理程序将替换默认处理程序。为了防止用户无意中替换默认的处理程序、格式化器或过滤器，所有的默认处理程序都以“BitBake.”为前缀命名。

如果用户定义了一个logger，并且key
bitbake_merge设置为False，那么该logger将被用户配置完全替换。在这种情况下，没有其他规则适用于该logger。

对于给定的logger，所有用户定义的过滤器和处理程序属性都将与默认logger的相应属性合并。例如，如果用户配置为BitBake.SigGen添加了一个名为myFilter的过滤器，而默认配置添加了一个名为BitBake.defaultFilter的过滤器，这两个过滤器都将应用于该logger。

作为第一个例子，您可以创建一个hashequiv.json的用户日志配置文件，将所有VERBOSE或更高优先级的Hash
Equivalence相关消息记录到一个名为hashequiv.log的文件中：

::

   {
       "version": 1,
       "handlers": {
           "autobuilderlog": {
               "class": "logging.FileHandler",
               "formatter": "logfileFormatter",
               "level": "DEBUG",
               "filename": "hashequiv.log",
               "mode": "w"
           }
       },
       "formatters": {
               "logfileFormatter": {
                   "format": "%(name)s: %(levelname)s: %(message)s"
               }
       },
       "loggers": {
           "BitBake.SigGen.HashEquiv": {
               "level": "VERBOSE",
               "handlers": ["autobuilderlog"]
           },
           "BitBake.RunQueue.HashEquiv": {
               "level": "VERBOSE",
               "handlers": ["autobuilderlog"]
           }
       }
   }

然后在conf/local.conf中设置\ `BB_LOGCONFIG <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_LOGCONFIG>`__\ 变量：

::

   BB_LOGCONFIG = "hashequiv.json"

另一个例子是这个warn.json文件，用于将所有WARNING及更高优先级的消息记录到warn.log文件中：

::

   {
       "version": 1,
       "formatters": {
           "warnlogFormatter": {
               "()": "bb.msg.BBLogFormatter",
               "format": "%(levelname)s: %(message)s"
           }
       },

       "handlers": {
           "warnlog": {
               "class": "logging.FileHandler",
               "formatter": "warnlogFormatter",
               "level": "WARNING",
               "filename": "warn.log"
           }
       },

       "loggers": {
           "BitBake": {
               "handlers": ["warnlog"]
           }
       },

       "@disable_existing_loggers": false
   }

注意，BitBake的结构化日志辅助类在lib/bb/msg.py中实现。

===============
3 语法和操作符
===============

BitBake文件有自己的语法。这种语法与其他几种语言有相似之处，但也具有一些独特的特性。本节描述了可用的语法和操作符，并提供了示例。

3.1 基本语法
============

本节提供了一些基本的语法示例。

3.1.1 基本变量设置
------------------

以下示例将VARIABLE设置为“value”。这个赋值在语句被解析时立即发生。这是一个“硬”赋值。

::

   VARIABLE = "value"

正如预期的那样，如果你在赋值中包含前导或尾随空格，这些空格会被保留：

::

   VARIABLE = " value"
   VARIABLE = "value "

将VARIABLE设置为“”会将其设置为空字符串，而将变量设置为“
”会将其设置为空格（即这两个值不相同）。

::

   VARIABLE = ""
   VARIABLE = " "

在设置变量的值时，你可以使用单引号代替双引号。这样做允许你使用包含双引号字符的值：

::

   VARIABLE = 'I have a " in my value'

.. note::

   与Bourneshell不同，在所有其他情况下，单引号与双引号的工作方式完全相同。它们不会抑制变量扩展。

3.1.2 修改现有变量
-------------------

有时你需要修改现有变量。以下是一些可能需要修改现有变量的情况：

-  自定义使用该变量的配方。
-  更改在*.bbclass文件中使用的变量的默认值。
-  更改*.bbappend文件中的变量以覆盖原始配方中的变量。
-  更改配置文件中的变量，以便该值覆盖现有配置。

更改变量值有时可能取决于原始赋值方式以及更改的预期目的。特别是，当你将一个值附加到一个具有默认值的变量时，结果值可能不是你所期望的。在这种情况下，你提供的值可能会替换默认值而不是追加到默认值。

如果你更改了变量的值后发生了无法解释的事情，你可以使用BitBake检查可疑变量的实际值。你可以对配置和配方级别的更改进行检查：

-  对于配置更改，使用以下命令：这个命令显示配置文件（例如local.conf、bblayers.conf、bitbake.conf等）被解析后的变量值。

   ::

      $ bitbake -e

   这个命令显示了在配置文件（即local.conf、bblayers.conf、bitbake.conf等）被解析后的变量值。

   .. note::

      在命令的输出中，被导出到环境的变量前面会带有字符串“export”。

-  要查找特定配方中对给定变量的更改，请使用以下命令：

   ::

      $ bitbake recipename -e | grep VARIABLENAME=\"

   这个命令用于检查变量是否真的进入了特定配方。

3.1.3 行连接
--------------

在函数之外，BitBake会在解析语句之前将任何以反斜杠字符（“”）结尾的行与下一行连接起来。“"字符最常见的用途是将变量赋值分割成多行，如下例所示：

::

   FOO = "bar \
          baz \
          qaz"

在连接行时，“”字符和其后的换行符都会被移除。因此，没有换行符会出现在FOO的值中。

考虑这个额外的例子，其中两个赋值都将“barbaz”赋给FOO：

::

   FOO = "barbaz"
   FOO = "bar\
   baz"

.. note::

   BitBake不会解释变量值中的转义序列，如 `\n` 。要使其生效，必须将值传递给一些解释转义序列的实用程序，例如printf或 `echo -n`。

3.1.4 变量扩展
---------------

变量可以使用类似于Bourneshells中变量扩展的语法引用其他变量的内容。以下赋值将导致A包含“aval”，而B计算结果为“preavalpost”。

::

   A = "aval"
   B = "pre${A}post"

.. note::

   与Bourneshells不同，花括号是必须的：只有\ ``${FOO}``\ 而不是\ ``$FOO``\ 被识别为FOO的扩展。

“=”操作符不会立即扩展右侧的变量引用。相反，扩展被推迟到实际使用赋值给的变量时。结果取决于被引用变量的当前值。以下示例应该阐明了这种行为：

::

   A = "${B} baz"
   B = "${C} bar"
   C = "foo"
   *At this point, ${A} equals "foo bar baz"*
   C = "qux"
   *At this point, ${A} equals "qux bar baz"*
   B = "norf"
   *At this point, ${A} equals "norf baz"*

将这种行为与立即变量扩展（：=）操作符对比。

如果在不存在的变量上使用变量扩展语法，字符串将保持不变。例如，给定以下赋值，只要FOO不存在，BAR就会扩展为字面字符串“${FOO}”。

::

   BAR = "${FOO}"

3.1.5 设置默认值(?=)
--------------------

你可以使用“？=”操作符来实现对变量的“软”赋值。这种类型的赋值允许你在语句解析时定义一个未定义的变量，但如果该变量有值，则保留该值不变。这里有一个例子：

::

   A ?= "aval"

如果在这个语句被解析的时候，A已经被设置，那么该变量保持它的值。然而，如果A尚未设置，该变量将被设置为“aval”。

.. note::

   这种赋值是立即的。因此，如果对单个变量存在多个“？=”赋值，最终会使用其中的第一个。

3.1.6 设置弱默认值(??=)
--------------------------

变量的弱默认值是指，如果没有通过其他任何赋值操作符为该变量分配值时，该变量将扩展为此值。“？？=”
操作符会立即生效，替换之前定义的任何弱默认值。这里有一个例子：

::

   W ??= "x"
   A := "${W}" # Immediate variable expansion
   W ??= "y"
   B := "${W}" # Immediate variable expansion
   W ??= "z"
   C = "${W}"
   W ?= "i"

解析后我们将得到：

::

   A = "x"
   B = "y"
   C = "i"
   W = "i"

追加和前置非覆盖样式不会替换弱默认值，这意味着解析后：

::

   W ??= "x"
   W += "y"

我们将得到：

::

   W = " y"

另一方面，覆盖样式的追加/前置/移除是在替换了任何活动的弱默认值之后应用的：

::

   W ??= "x"
   W:append = "y"

解析后我们将得到：

::

   W = "xy"

3.1.7 立即变量扩展(:=)
----------------------

“：=”操作符使变量的内容立即扩展，而不是在变量实际使用时扩展：

::

   T = "123"
   A := "test ${T}"
   T = "456"
   B := "${T} ${C}"
   C = "cval"
   C := "${C}append"

在这个例子中，即使T的最终值为“456”，A也包含“test
123”。变量B最终将包含“456
cvalappend”。这是因为在（立即）扩展期间，对未定义变量的引用保持不变。这与GNU
Make不同，在GNU
Make中，未定义的变量扩展为空。变量C包含“cvalappend”，因为${C}立即扩展为“cval”。

3.1.8 追加(+=)和前置(=+)带空格
------------------------------

追加和前置值是常见的操作，可以使用“+=”和“=+”操作符来完成。这些操作符在当前值和前置或追加值之间插入一个空格。

这些操作符在解析期间立即生效。以下是一些示例：

::

   B = "bval"
   B += "additionaldata"
   C = "cval"
   C =+ "test"

变量B包含“bval additionaldata”，C包含“test cval”。

3.1.9 追加(.=)和前置(=.)无空格
------------------------------

如果你想在没有插入空格的情况下追加或前置值，使用“.=”和“=.”操作符。

这些操作符在解析期间立即生效。以下是一些示例：

::

   B = "bval"
   B .= "additionaldata"
   C = "cval"
   C =. "test"

变量B包含“bvaladditionaldata”，C包含“testcval”。

3.1.10 追加和前置（覆盖样式语法）
-----------------------------------

你也可以使用覆盖样式语法来追加和前置一个变量的值。当你使用这种语法时，不会插入空格。

这些操作符与“：=”、“.=”、“=.”、“+=”和“=+”操作符的不同之处在于，它们的效果是在变量扩展时应用的，而不是立即应用。以下是一些示例：

::

   B = "bval"
   B:append = " additional data"
   C = "cval"
   C:prepend = "additional data "
   D = "dval"
   D:append = "additional data"

变量B变为“bval additional data”，C变为“additional data
cval”。变量D变为“dvaladditional data”。

.. note::

   使用覆盖语法时，你必须控制所有的空格。

.. note::

   覆盖是按照这个顺序应用的：“：append”、“：prepend”、“：remove”。

也可以向shell函数和BitBake风格的Python函数追加和前置。有关示例，请参阅“\ `Shell
Functions <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#shell-functions>`__\ ”和“\ `BitBake-Style
Python
Functions <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#bitbake-style-python-functions>`__\ ”部分。

3.1.11 移除（覆盖样式语法）
------------------------------

你可以使用移除覆盖样式语法从列表中删除值。指定一个要移除的值会导致该变量中所有出现的该值都被移除。与“：append”和“：prepend”不同，不需要在值前或值后添加空格。

当你使用这种语法时，BitBake期望一个或多个字符串。周围的空格和间距会被保留。以下是一个例子：

::

   FOO = "123 456 789 123456 123 456 123 456"
   FOO:remove = "123"
   FOO:remove = "456"
   FOO2 = " abc def ghi abcdef abc def abc def def"
   FOO2:remove = "\
       def \
       abc \
       ghi \
       "

变量FOO变为“ 789 123456 ”，FOO2变为“ abcdef ”。

与“：append”和“：prepend”一样，“：remove”是在变量扩展时应用的。

.. note::

   覆盖是按照这个顺序应用的：“：append”、“：prepend”、“：remove”。这意味着不可能重新追加之前已移除的字符串。然而，通过使用一个中间变量，将其内容传递给“：remove”，修改该中间变量就相当于保留在：中的字符串，可以撤销“：remove”操作。

   ::

      FOOREMOVE = "123 456 789"
      FOO:remove = "${FOOREMOVE}"
      ...
      FOOREMOVE = "123 789"

   这扩展为 FOO:remove = “123 789”。

.. note::

   覆盖应用顺序可能与变量解析历史不匹配，即 bitbake -e的输出可能包含在“：append”之前的“：remove”，但结果将是已移除的字符串，因为“：remove”最后处理。

3.1.12 覆盖样式操作优点
-----------------------

与“+=”和“=+”操作符相比，覆盖样式操作“：append”、“：prepend”和“：remove”的一个优点是，覆盖样式操作符提供了保证的操作。例如，考虑一个需要将值“val”添加到变量FOO的类foo.bbclass，以及如下所示使用foo.bbclass的配方：

::

   inherit foo
   FOO = "initial"

如果 foo.bbclass 使用“+=”操作符，如下所示，那么 FOO
的最终值将是“initial”，这不是我们想要的：

::

   FOO += "val"

另一方面，如果 foo.bbclass 使用“：append”操作符，那么 FOO
的最终值将是“initial val”，这是预期的结果：

::

   FOO:append = " val"

.. note::

   永远不需要将“+=”与“：append”一起使用。以下赋值序列会将“barbaz”追加到FOO：

   ::

      FOO:append = "bar"
      FOO:append = "baz"

   在之前的例子中，将第二个赋值改为使用“+=”的唯一效果是在追加的值前添加空格（由于“+=”操作符的工作方式）。

覆盖样式操作的另一个优点是，您可以将它们与其他覆盖操作结合使用，如“\ `条件语法（覆盖） <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#conditional-syntax-overrides>`__\ ”部分所述。

3.1.13 变量标志语法
-------------------

变量标志是BitBake的变量属性或特性的实现方式。这是将额外信息标记到变量上的一种方法。您可以在“变量标志”部分了解更多关于变量标志的通用信息。

您可以定义、追加和前置变量标志的值。之前提到的所有标准语法操作都适用于变量标志，除了覆盖样式语法（即“：prepend”、“：append”和“：remove”）。

以下是一些设置变量标志的示例：

::

   FOO[a] = "abc"
   FOO[b] = "123"
   FOO[a] += "456"

变量FOO有两个标志：[a]和[b]。这两个标志分别立即设置为“abc”和“123”。[a]标志变为“abc
456”。

不需要预先定义变量标志。您可以直接开始使用它们。一个极其常见的应用是将一些简要的文档附加到BitBake变量，如下所示：

::

   CACHE[doc] = "The directory holding the cache of the metadata."

.. note: 
   
   注意

   在Python代码中，以单个下划线（_）开头的变量标志名是允许的，但会被d.getVarFlags(“VAR”)忽略。这样的标志名在BitBake内部使用。

3.1.14 内联Python变量扩展
--------------------------

你可以使用内联Python变量扩展来设置变量。这里有一个例子：

.. code:: python

   DATE = "${@time.strftime('%Y%m%d',time.gmtime())}"

这个例子将把DATE变量设置为当前日期。

这个特性最常用的可能是从BitBake的内部数据字典d中提取变量的值，以下几行代码分别选择了包的名称和其版本号的值：

::

   PN = "${@bb.parse.vars_from_file(d.getVar('FILE', False),d)[0] or 'defaultpkgname'}"
   PV = "${@bb.parse.vars_from_file(d.getVar('FILE', False),d)[1] or '1.0'}"

.. note::

   就“=”和“：=”操作符而言，内联Python表达式的工作方式与变量扩展相同。给定以下赋值，每次扩展FOO时都会调用foo()函数：

   .. code:: python

      FOO = "${@foo()}"

   与此相对的是以下立即赋值，其中foo()函数只在解析赋值时被调用一次：

   .. code:: python

      FOO := "${@foo()}"

   要在解析过程中使用Python代码设置变量的不同方法，请参阅“\ `匿名Python函数 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#anonymous-python-functions>`__\ ”部分。

3.1.15 取消设置变量
--------------------

可以通过使用“unset”关键字完全从BitBake的内部数据字典中移除一个变量或变量标志。这里有一个例子：

.. code:: python

   unset DATE
   unset do_fetch[noexec]

这两条语句将移除DATE和do_fetch[noexec]标志。

3.1.16 提供路径名
------------------

在为BitBake指定路径名时，不要使用波浪号（“-”）作为您的主目录的快捷方式。这样做可能会导致BitBake无法识别该路径，因为BitBake不会像shell那样扩展这个字符。

相反，请提供一个更完整的路径，如下所示：

.. code::

   BBLAYERS ?= " 
       /home/scott-lenovo/LayerA 
   "

3.2 导出变量到环境
===================

导出变量到运行任务的环境可以通过使用export关键字来实现。例如，在以下示例中，当运行do_foo任务时，它会打印“来自环境的值”：

.. code:: bash

   export ENV_VARIABLE
   ENV_VARIABLE = "value from the environment"

   do_foo() {
       bbplain "$ENV_VARIABLE"
   }

注意：在这种情况下，BitBake不会展开\ ``$ENV_VARIABLE``\ ，因为它缺少必要的{}。相反，\ ``$ENV_VARIABLE``\ 由shell展开。

无论\ ``export ENV_VARIABLE``\ 出现在赋值给ENV_VARIABLE之前还是之后，都不重要。

还可以将export与为变量设置值结合使用。以下是一个例子：

.. code:: bash

   export ENV_VARIABLE = "variable-value"

在bitbake -e的输出中，导出到环境的变量前面带有“export”。

通常导出到环境的一些变量包括CC和CFLAGS，这些变量会被许多构建系统捕获。

3.3 条件语法（覆盖）
=======================

BitBake使用OVERRIDES来控制在解析配方和配置文件之后，哪些变量被覆盖。这一节描述了您如何使用OVERRIDES作为条件元数据，讨论了与OVERRIDES相关的键扩展，并提供了帮助理解的一些例子。

3.3.1 条件元数据
-----------------

您可以使用OVERRIDES来有条件地选择变量的特定版本，以及有条件地追加或前置变量的值。

.. note::

   覆盖只能使用小写字符、数字和破折号。特别是，在覆盖名称中不允许使用冒号，因为它们用于将覆盖项彼此分离以及与变量名分离。

-  选择变量：OVERRIDES
   变量是一个由冒号分隔的列表，包含您想要满足条件的项目。因此，如果您有一个基于“arm”条件的变量，并且“arm”在
   OVERRIDES
   中，那么将使用该变量的“arm”特定版本，而不是非条件版本。这里有一个例子：

   ::

      OVERRIDES = "architecture:os:machine"
      TEST = "default"
      TEST:os = "osspecific"
      TEST:nooverride = "othercondvalue"

   在这个例子中，OVERRIDES
   变量列出了三个覆盖项：“architecture”、“os”和“machine”。变量 TEST
   本身具有默认值“default”。您可以通过将“os”覆盖项附加到变量（即
   TEST:os）来选择 TEST 变量的 os 特定版本。

   为了更好地理解这一点，考虑一个实际的例子，假设一个基于 OpenEmbedded
   元数据的 Linux 内核配方文件。配方文件中的以下行首先将内核分支变量
   KBRANCH 设置为默认值，然后根据构建的体系结构有条件地覆盖该值：

   ::

      KBRANCH = "standard/base"
      KBRANCH:qemuarm = "standard/arm-versatile-926ejs"
      KBRANCH:qemumips = "standard/mti-malta32"
      KBRANCH:qemuppc = "standard/qemuppc"
      KBRANCH:qemux86 = "standard/common-pc/base"
      KBRANCH:qemux86-64 = "standard/common-pc-64/base"
      KBRANCH:qemumips64 = "standard/mti-malta64"

-  **附加和前置：**\ BitBake 还支持基于特定项目是否列在 OVERRIDES
   中，对变量值进行追加（append）和前置（prepend）操作。这里有一个例子：

   ::

      DEPENDS = "glibc ncurses"
      OVERRIDES = "machine:local"
      DEPENDS:append:machine = "libmad"

   在这个例子中，DEPENDS 变为 “glibc ncurses libmad”。

   再次使用一个基于 OpenEmbedded 元数据的 Linux
   内核配方文件作为示例，以下行将根据体系结构有条件地追加到
   KERNEL_FEATURES 变量：

   ::

      KERNEL_FEATURES:append = " ${KERNEL_EXTRA_FEATURES}"
      KERNEL_FEATURES:append:qemux86=" cfg/sound.scc cfg/paravirt_kvm.scc"
      KERNEL_FEATURES:append:qemux86-64=" cfg/sound.scc cfg/paravirt_kvm.scc"

-  **为单个任务设置变量：**\ BitBake
   支持仅为单个任务的持续时间设置变量。这里有一个例子：

   ::

      FOO:task-configure = "val 1"
      FOO:task-compile = "val 2"

   在之前的示例中，执行 do_configure 任务时，FOO 的值为 “val 1”，而执行
   do_compile 任务时，值为 “val 2”。

   内部实现上，这是通过在 do_compile 任务的本地数据存储的 OVERRIDES
   值前加上任务（例如“task-compile:”）来实现的。

   您也可以使用这种语法与其他组合（例如“：prepend”）一起使用，如下所示：

   ::

      EXTRA_OEMAKE:prepend:task-compile = "${PARALLEL_MAKE} "

.. note::

   在BitBake 1.52（Honister3.4）之前，OVERRIDES的语法使用_而不是：，因此您仍然会找到很多文档使用_append、_prepend和_remove等。

   有关详细信息，请参阅YoctoProject手册迁移说明中的 `Overrides语法 <https://docs.yoctoproject.org/migration-guides/migration-3.4.html#override-syntax-changes>` 更改部分。

3.3.2 key键扩展
----------------

key键扩展发生在BitBake数据存储被最终确定时。为了更好地理解这一点，考虑以下示例：

::

   A${B} = "X"
   B = "2"
   A2 = "Y"

在这种情况下，在解析完成后，BitBake将${B}扩展为“2”。此扩展导致在扩展之前设置为“Y”的A2变为“X”。

3.3.3 范例
------------

尽管之前的解释展示了变量定义的不同形式，但当变量操作符、条件覆写和无条件覆写结合在一起时，确切地理解发生了什么可能还是很难。这一部分将通过一些常见的场景及其解释来展示通常令用户感到困惑的变量交互。

关于覆写和各种“追加”操作符生效的顺序，人们常常感到困惑。请记住，使用“：append”和“：prepend”进行的追加或前置操作并不会导致立即赋值，不像“+=”、“.=”、“=+”或“=.”那样。考虑以下示例：

::

   OVERRIDES = "foo"
   A = "Z"
   A:foo:append = "X"

在这种情况下，A被无条件地设置为“Z”，而“X”被无条件且立即追加到变量A:foo。由于还没有应用覆写，A:foo因追加而被设置为“X”，而A简单地等于“Z”。

然而，应用覆写会改变情况。由于“foo”列在OVERRIVES中，条件变量A被替换为“foo”版本，即等于“X”。所以实际上，A:foo替换了A。

下一个示例改变了覆写和追加的顺序：

::

   OVERRIDES = "foo"
   A = "Z"
   A:append:foo = "X"

在这种情况下，处理覆写之前，A被设置为“Z”，而A:append:foo被设置为“X”。然而，一旦应用了“foo”的覆写，A就被追加了“X”。因此，A变成了“ZX”。请注意，没有追加空格。

下一个示例将追加和覆写的顺序颠倒回第一个示例的样子：

::

   OVERRIDES = "foo"
   A = "Y"
   A:foo:append = "Z"
   A:foo:append = "X"

在这种情况下，在任何覆写被解决之前，A使用立即赋值被设置为“Y”。这个立即赋值之后，A:foo被设置为“Z”，然后进一步追加“X”，使得变量被设置为“ZX”。最后，应用“foo”的覆写导致条件变量A变成“ZX”（即A被A:foo替换）。

最后一个示例混合了一些不同的操作符：

::

   A = "1"
   A:append = "2"
   A:append = "3"
   A += "4"
   A .= "5"

在这种情况下，追加操作符的类型影响了BitBake多次遍历代码时的赋值顺序。最初，由于使用了立即操作符的三条语句，A被设置为“1
45”。在这些赋值完成后，BitBake应用“：append”操作。这些操作导致A变成了“1
4523”。

3.4 共享功能
==============

BitBake允许通过包含文件（.inc）和类文件（.bbclass）来共享元数据。例如，假设你有一段通用的功能，比如一个任务定义，你希望在多个配方之间共享。在这种情况下，创建一个包含通用功能的.bbclass文件，然后在你的配方中使用inherit指令来继承这个类，将是共享任务的常见方式。

这一部分介绍了BitBake提供的机制，让你能够在配方之间共享功能。具体来说，这些机制包括include、inherit、INHERIT和require指令。

3.4.1. 定位包含文件和类文件
---------------------------

BitBake使用BBPATH变量来定位所需的包含文件和类文件。此外，BitBake还会搜索当前目录以查找包含和要求指令。

.. note::

   BBPATH变量类似于环境变量PATH。

为了使包含文件和类文件能够被BitBake找到，它们需要位于可以在BBPATH中找到的“classes”子目录中。

3.4.2 inherit 指令
---------------------

在编写配方或类文件时，你可以使用继承指令来继承一个类（.bbclass）的功能。BitBake仅支持在配方和类文件（即.bb和.bbclass）中使用此指令。

继承指令是一种基本的手段，用于指定你的配方所需的类文件中包含的功能。例如，你可以轻易地抽象出一个构建使用Autoconf和Automake的包的任务，并将这些任务放入一个类文件中，然后让你的配方继承那个类文件。

作为一个示例，你的配方可以使用以下指令来继承autotools.bbclass文件。该类文件将包含使用Autotools的通用功能，可以在配方之间共享：

::

   inherit autotools

在这种情况下，BitBake会在BBPATH中搜索目录classes/autotools.bbclass。

.. note::

   你可以通过在“继承”语句之后这样做，来覆盖配方中继承类的任何值和函数。

如果你想要使用指令来继承多个类，请用空格将它们分隔开。以下示例显示了如何同时继承buildhistory和rm_work类：

::

   inherit buildhistory rm_work

与include和require指令相比，继承指令的一个优势是你可以有条件地继承类文件。你可以通过在继承语句后使用变量表达式来实现这一点。这里有一个示例：

::

   inherit ${VARNAME}

如果要设置VARNAME，需要在解析继承语句之前进行设置。在这种情况下，实现条件继承的一种方法是使用覆盖：

::

   VARIABLE = ""
   VARIABLE:someoverride = "myclass"

另一种方法是使用匿名Python。这里有一个示例：

::

   python () {
       if condition == value:
           d.setVar('VARIABLE', 'myclass')
       else:
           d.setVar('VARIABLE', '')
   }

或者，你可以使用以下形式的内联Python表达式：

::

   inherit ${@'classname' if condition else ''}
   inherit ${@functionname(params)}

在所有情况下，如果表达式计算结果为空字符串，该语句不会触发语法错误，因为它变成了一个空操作。

3.4.3 include 指令
---------------------

BitBake理解include指令。这个指令使得BitBake解析你指定的任何文件，并将该文件插入到那个位置。这个指令很像Make中的等效指令，除了如果在include行上指定的路径是相对路径，BitBake会在BBPATH内找到它能找到的第一个文件。

与仅限制于类（即.bbclass）文件的继承指令相比，include指令是一种更通用的包含功能的方法。对于不适合.bbclass文件的任何其他类型的共享或封装的功能或配置，都可以使用include指令。

例如，假设你需要一个配方来包含一些自我测试定义：

::

   include test_defs.inc

.. note::

   如果找不到文件，include指令不会产生错误。因此，如果你期望包含的文件应该存在，建议使用require而不是include。这样做可以确保在找不到文件时会产生错误。

3.4.4 require 指令
---------------------

BitBake理解require指令。这个指令的行为就像include指令一样，除了如果找不到要包含的文件，BitBake会引发解析错误。因此，任何你需要的文件都会被插入到正在解析的文件中指令的位置。

require指令，就像前面描述的include指令一样，与仅限于类（即.bbclass）文件的继承指令相比，是一种更通用的包含功能的方法。require指令适用于任何其他类型的共享或封装的功能或配置，不适合.bbclass文件。

类似于BitBake处理include的方式，如果在require行上指定的路径是相对路径，BitBake会在BBPATH内找到它能找到的第一个文件。

例如，假设你有两个版本的配方（例如foo_1.2.2.bb和foo_2.0.0.bb），其中每个版本都包含一些可以共享的相同功能。你可以创建一个名为foo.inc的包含文件，其中包含构建“foo”所需的公共定义。你还需要确保foo.inc位于你的两个配方文件所在的同一目录中。一旦这些条件设置好，你就可以使用require指令在每个配方内部共享该功能：

::

   require foo.inc

3.4.5 inherit配置指令
----------------------

当创建一个配置文件（.conf）时，你可以使用INHERIT配置指令来继承一个类。BitBake仅支持在配置文件中使用这个指令。

例如，假设你需要从配置文件中继承一个名为abc.bbclass的类文件，可以如下所示：

::

   INHERIT += "abc"

这个配置指令会在解析过程中导致指定的类在指令点被继承。与继承指令一样，.bbclass文件必须位于BBPATH中指定的某个目录的“classes”子目录中。

.. note::

   由于.conf文件在BitBake执行期间首先被解析，因此使用INHERIT继承类实际上是全局继承（即对所有配方）。

如果你想使用该指令继承多个类，可以在local.conf文件中的同一行上提供它们。用空格分隔类。以下示例显示了如何同时继承autotools和pkgconfig类：

::

   INHERIT += "autotools pkgconfig"

3.5 函数
===========

BitBake支持以下类型的函数：

-  Shell函数：用shell脚本编写的函数，可以直接作为函数、任务或两者执行。它们也可以被其他shell函数调用。

-  BitBake风格的Python函数：用Python编写的函数，由BitBake或其他Python函数使用bb.build.exec_func()执行。

-  Python函数：用Python编写的函数，由Python执行。

-  匿名Python函数：在解析过程中自动执行的Python函数。

无论函数的类型如何，您只能在类（.bbclass）和配方（.bb或.inc）文件中定义它们。

3.5.1 shell 函数
-------------------

这是一个关于BitBake中shell函数的说明。在BitBake中，你可以使用shell脚本编写函数，这些函数可以直接作为函数、任务或两者执行。它们也可以被其他shell函数调用。例如，下面是一个简单的shell函数定义：

.. code:: shell

   some_function () {
       echo "Hello World"
   }

当你在你的配方或类文件中创建这些类型的函数时，你需要遵循shell编程规则。这些脚本由/bin/sh执行，可能不是bash
shell，而可能是诸如dash之类的东西。你不应该在shell函数中使用Bash特有的脚本（bashisms）。

你可以在shell函数上应用覆盖和覆盖风格的操作符，如：append和：prepend。最常见的用法是在.bbappend文件中修改主配方中的函数。它也可以用于修改从类继承的函数。

例如，考虑以下代码：

.. code:: shell

   do_foo() {
       bbplain first
       fn
   }

   fn:prepend() {
       bbplain second
   }

   fn() {
       bbplain third
   }

   do_foo:append() {
       bbplain fourth
   }

运行do_foo将输出以下内容：

::

   recipename do_foo: first
   recipename do_foo: second
   recipename do_foo: third
   recipename do_foo: fourth

.. note::

   注意，覆盖和覆盖风格的操作符可以应用于任何shell函数，而不仅仅是任务。

你可以使用bitbake -e recipename命令查看所有覆盖应用后的最终组装函数。

3.5.2 bitbake-style python 函数
----------------------------------

这些函数是用Python编写的，并且由BitBake或其他使用bb.build.exec_func()的Python函数执行。

一个示例的BitBake函数是：

.. code:: python

   python some_python_function () {
       d.setVar("TEXT", "Hello World")
       print d.getVar("TEXT")
   }

因为Python的“bb”和“os”模块已经被导入，你不需要再导入这些模块。在这些类型的函数中，数据存储（“d”）是一个全局变量，总是自动可用的。

.. note::

   变量表达式（例如${X}）在Python函数中不再被扩展。这种行为是故意的，以便允许你自由地将变量值设置为可扩展表达式，而不会过早地扩展它们。如果你确实希望在Python函数中扩展一个变量，请使用d.getVar(“X”)。或者，对于更复杂的表达式，使用d.expand()。

与shell函数类似，你也可以对BitBake风格的Python函数应用覆盖和覆盖风格的操作符。

作为一个例子，考虑以下代码：

.. code:: python

   python do_foo:prepend() {
       bb.plain("first")
   }

   python do_foo() {
       bb.plain("second")
   }

   python do_foo:append() {
       bb.plain("third")
   }

运行do_foo将输出以下内容：

::

   recipename do_foo: first
   recipename do_foo: second
   recipename do_foo: third

你可以使用bitbake -e recipename命令查看所有覆盖应用后的最终组装函数。

3.5.3 python 函数
-------------------

这些函数是用Python编写的，并由其他Python代码执行。Python函数的例子是实用函数，你打算从内联Python中或在其他Python函数中调用它们。下面是一个示例：

.. code:: python

   def get_depends(d):
       if d.getVar('SOMECONDITION'):
           return "dependencywithcond"
       else:
           return "dependency"

   SOMECONDITION = "1"
   DEPENDS = "${@get_depends(d)}"

这将导致DEPENDS包含dependencywithcond。

以下是关于Python函数需要了解的一些事项：

Python函数可以接受参数。

BitBake数据存储不是自动可用的。因此，你必须将其作为参数传递给函数。

“bb”和“os” Python模块是自动可用的。你不需要导入它们。

3.5.4 bitbake-style python 函数与python函数对比
------------------------------------------------

以下是BitBake风格的Python函数和常规Python函数（用“def”定义的）之间的一些重要区别：

-  只有BitBake风格的Python函数可以作为任务。

-  覆盖和覆盖风格的操作符只能应用于BitBake风格的Python函数。

-  只有常规Python函数可以接收参数并返回值。

-  变量标志，如[dirs]、[cleandirs]和[lockfiles]，可以用于BitBake风格的Python函数，但不能用于常规Python函数。

-  BitBake风格的Python函数会生成一个单独的 `{T}/run.function-name.pid脚本来运行函数，并且如果它们作为任务执行，还会在{T}/log.function-name.pid` 中生成日志文件。

-  常规Python函数是“内联”执行的，不会在${T}中生成任何文件。

-  常规Python函数使用通常的Python语法调用。BitBake风格的Python函数通常是任务，由BitBake直接调用，但也可以通过使用bb.build.exec_func()函数从Python代码中手动调用。例如：
   
   .. code:: 
   
      python  bb.build.exec_func("my_bitbake_style_function", d)
   
   .. note::
 
      bb.build.exec_func()也可以用来从Python代码中运行shell函数。如果你想在同一个任务中先运行一个shell函数，然后运行Python函数，那么你可以使用一个父帮助器Python函数，它首先使用bb.build.exec_func()运行shell函数，然后运行Python代码。

   要从使用bb.build.exec_func()执行的函数中检测错误，你可以捕获bb.build.FuncFailed异常。

   .. note::

      元数据（配方和类）中的函数不应自己引发bb.build.FuncFailed。相反，bb.build.FuncFailed应被视为被调用函数失败并通过引发异常的一般指示器。例如，由bb.fatal()引发的异常将在bb.build.exec_func()内部被捕获，并且会相应地引发bb.build.FuncFailed。

由于它们的简单性，除非您需要特定于BitBake风格Python函数的功能，否则您应该更喜欢常规Python函数而不是BitBake风格的Python函数。元数据中的常规Python函数是比BitBake风格Python函数更近期的发明，旧代码倾向于更频繁地使用bb.build.exec_func()。

3.5.5. 匿名Python函数
---------------------

有时在解析期间以编程方式设置变量或执行其他操作会很有用。为此，您可以定义特殊的Python函数，称为匿名Python函数，这些函数在解析结束时运行。例如，以下代码根据另一个变量的值有条件地设置一个变量：

.. code:: python

   python () {
       if d.getVar('SOMEVAR') == 'value':
           d.setVar('ANOTHERVAR', 'value2')
   }

将函数标记为匿名函数的等效方法是给它命名为“__anonymous”，而不是没有名称。

匿名Python函数总是在解析结束时运行，无论它们在哪里定义。如果配方中包含许多匿名函数，它们将按照在配方中定义的顺序运行。作为示例，请考虑以下代码段：

.. code:: python

   python () {
       d.setVar('FOO', 'foo 2')
   }

   FOO = "foo 1"

   python () {
       d.appendVar('BAR',' bar 2')
   }

   BAR = "bar 1"

前面的示例在概念上等效于以下代码段：

.. code:: python

   FOO = "foo 1"
   BAR = "bar 1"
   FOO = "foo 2"
   BAR += "bar 2"

FOO的最终值为“foo 2”，BAR的值为“bar 1 bar
2”。就像在第二个代码段中一样，在匿名函数中设置的变量值对任务可用，任务总是在解析后运行。

在匿名函数运行之前，会应用覆盖和覆盖样式操作符，如“：append”。在以下示例中，FOO的最终值为“foo
from anonymous”：

.. code:: python

   FOO = "foo"
   FOO:append = " from outside"

   python () {
       d.setVar("FOO", "foo from anonymous")
   }

有关您可以与匿名Python函数一起使用的方法，请参阅“\ `Functions You Can
Call From Within
Python <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#functions-you-can-call-from-within-python>`__\ ”部分。有关在解析期间运行Python代码的不同方法，请参阅“\ `Inline
Python Variable
Expansion <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#inline-python-variable-expansion>`__\ ”部分。

3.5.6 类函数的灵活继承
-----------------------

通过编码技巧和使用EXPORT_FUNCTIONS，BitBake支持从类中导出一个函数，使得类函数作为该函数的默认实现出现，但如果继承该类的配方需要定义自己的函数版本，仍然可以调用。

要理解这个特性的好处，考虑一个基本场景，即一个类定义了一个任务函数，你的配方继承了这个类。在这个基本场景中，你的配方继承了类中定义的任务函数。如果你希望的话，你的配方可以通过使用“：prepend”或“：append”操作分别在函数的开始和结束处添加内容，或者完全重新定义函数。然而，如果它重新定义了函数，就没有方法来调用类版本的函数。EXPORT_FUNCTIONS提供了一个机制，使配方的版本能够调用原始版本的函数。

要利用这种技术，你需要以下东西：

-  类需要按照以下方式定义函数：

   ::

      classname_functionname

   例如，如果你有一个名为bar.bbclass的类文件和一个名为do_foo的函数，类必须按照以下方式定义函数：

   ::

      bar_do_foo

-  类需要包含以下EXPORT_FUNCTIONS语句：

   ::

      EXPORT_FUNCTIONS functionname

   例如，继续使用相同的示例，bar.bbclass中的语句应该是：

   ::

      EXPORT_FUNCTIONS do_foo

-  你需要在你的配方中适当地调用函数。继续使用相同的示例，如果你的配方需要调用类版本的函数，它应该调用bar_do_foo。假设do_foo是一个shell函数，并且如上所述使用了EXPORT_FUNCTIONS，那么配方的函数可以有条件地调用类版本的函数，如下所示：

   ::

      do_foo() {
          if [ somecondition ] ; then
              bar_do_foo
          else
              # Do something else
          fi
      }

   要调用你在配方中定义的修改后的函数，请将其称为do_foo。

在这些条件满足的情况下，你的单个配方可以在类文件中定义的原始函数和配方中定义的修改后的函数之间自由选择。如果你没有设置这些条件，你将仅限于使用其中一个函数。

3.6 任务
========

任务是BitBake执行单元，它们组成了BitBake可以为给定的配方运行的步骤。任务仅在配方和类中受支持（即在.bb文件中以及从.bb文件包含或继承的文件中）。按照惯例，任务的名称以 `do_` 开头。

3.6.1. 将函数提升为任务
-----------------------

任务是已通过使用addtask命令提升为任务的shell函数或BitBake风格的Python函数。addtask命令还可以选择性地描述任务与其他任务之间的依赖关系。以下是一个示例，展示了如何定义任务并声明一些依赖项：

.. code:: python

   do_printdate () {
       import time
       print(time.strftime('%Y%m%d', time.gmtime()))
   }
   addtask printdate after do_fetch before do_build

addtask的第一个参数是要提升为任务的函数名称。如果名称不是以 `do_` 开头，将隐式添加 `do_` ，这强制执行所有任务名称以` do_` 开头的约定。

在上述示例中，do_printdate任务成为do_build任务的依赖项，do_build任务是默认任务（即除非明确指定其他任务，否则由bitbake命令运行的任务）。此外，do_printdate任务还依赖于do_fetch任务。运行do_build任务会导致首先运行do_printdate任务。

   **注意**

   **如果你尝试上述示例，可能会发现do_printdate任务只在你第一次使用bitbake命令构建配方时运行。这是因为BitBake在初始运行后认为任务“最新”。如果你希望强制任务始终重新运行以进行实验，可以通过使用[nostamp]变量标志使BitBake始终认为任务“过期”，如下所示：**

   ::

      do_printdate[nostamp] = "1"

   **你还可以通过提供-f选项来显式运行任务，如下所示：**

   ::

      $ bitbake recipe -c printdate -f

   **当使用bitbake recipe -c
   task命令手动选择要运行的任务时，可以省略任务名称中的“do_”前缀。**

你可能会想知道在不指定任何依赖关系的情况下使用addtask的实际效果，如下例所示：

::

   addtask printdate

在此示例中，假设没有通过其他方式添加依赖关系，唯一运行任务的方式是通过显式选择它，使用bitbake
recipe -c
printdate。你可以使用do_listtasks任务列出配方中定义的所有任务，如下例所示：

::

   $ bitbake recipe -c listtasks

有关任务依赖关系的更多信息，请参阅“依赖关系”部分。

有关可用于任务的变量标志的信息，请参阅“变量标志”部分。

.. note::

   虽然不常见，但在调用addtask时定义多个任务作为依赖项是可能的。例如，以下代码段来自OpenEmbedded类文件package_tar.bbclass：

   ::

      addtask package_write_tar before do_build after do_packagedata do_package

   注意package_write_tar任务必须等到do_packagedata和do_package都完成后才能执行。

3.6.2 删除一个任务
-------------------

除了能够添加任务，你还可以删除它们。只需使用deltask命令即可删除任务。例如，要删除前几节中使用的示例任务，你可以使用以下命令：

::

   deltask printdate

如果你使用deltask命令删除了一个具有依赖关系的任务，那么这些依赖关系不会被重新连接。例如，假设你有名为do_a、do_b和do_c的三个任务。此外，do_c依赖于do_b，而do_b又依赖于do_a。在这种情况下，如果你使用deltask删除了do_b，则通过do_b存在的do_c与do_a之间的隐式依赖关系不再存在，且do_c的依赖项不会更新为包含do_a。因此，do_c可以在do_a之前自由运行。

如果你想保持这样的依赖关系完整，可以使用[noexec]变量标志来禁用任务，而不是使用deltask命令将其删除：

::

   do_b[noexec] = "1"

3.6.3 将信息传递到构建任务环境中
---------------------------------

在运行任务时，BitBake严格控制构建任务的shell执行环境，以确保构建机器上的无关污染不会影响构建。

.. note::

   默认情况下，BitBake清理环境，仅包含在其传递列表中导出或列出的内容，以确保构建环境是可重现且一致的。您可以通过设置BB_PRESERVE_ENV变量来阻止这种“清理”。

因此，如果您确实希望某些内容传递到构建任务环境中，您必须采取以下两个步骤：

1. 告诉BitBake从环境中加载您想要的内容到数据存储中。您可以通过BB_ENV_PASSTHROUGH和BB_ENV_PASSTHROUGH_ADDITIONS变量来实现。例如，假设您希望阻止构建系统访问您的$HOME/.ccache目录。以下命令将环境变量CCACHE_DIR添加到BitBake的传递列表中，以允许该变量进入数据存储：

   ::

      export BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS CCACHE_DIR"

2. 告诉BitBake将您加载到数据存储中的内容导出到每个正在运行的任务的任务环境中。将某些内容从环境中加载到数据存储（上一步）只能使其在数据存储中可用。要将它们导出到每个正在运行的任务的任务环境，请在您的本地配置文件local.conf或发行版配置文件中使用类似以下命令：

   ::

      export CCACHE_DIR

   .. note::

      上述步骤的一个副作用是BitBake将变量记录为构建过程的依赖项，例如在setscene校验和中。如果这样做导致不必要的任务重建，您还可以标记该变量，以便setscene代码在创建校验和时忽略依赖关系。

有时，能够从原始执行环境中获取信息是很有用的。BitBake将原始环境的副本保存在一个名为BB_ORIGENV的特殊变量中。

BB_ORIGENV变量返回一个可以使用标准数据存储操作符查询的数据存储对象，例如getVar(,
False)。数据存储对象可用于查找原始DISPLAY变量等。以下是一个例子：

::

   origenv = d.getVar("BB_ORIGENV", False)
   bar = origenv.getVar("BAR", False)

前面的例子从原始执行环境中返回BAR。

===============
4 文件下载支持
===============

BitBake的fetch模块是一个独立的库代码片段，用于处理从远程系统下载源代码和文件的复杂过程。获取源代码是构建软件的基石之一。因此，此模块构成了BitBake的重要部分。

当前的fetch模块被称为“fetch2”，它指的是这是API的第二个主要版本。原始版本已经过时，并已从代码库中移除。因此，在所有情况下，本手册中的“fetch”都指代“fetch2”。

4.1 下载（Fetch）
==================

BitBake在获取源代码或文件时会执行几个步骤。fetcher代码库处理两个不同的过程，首先是从某个地方（缓存或其他方式）获取文件，然后将这些文件解压缩到特定的位置和可能的特定方式。获取和解压缩文件通常后面跟着可选的补丁操作。然而，补丁操作不在此模块的覆盖范围内。

执行此过程的第一部分的代码如下：

.. code:: python

   src_uri = (d.getVar('SRC_URI') or "").split()
   fetcher = bb.fetch2.Fetch(src_uri, d)
   fetcher.download()

这段代码设置了一个fetch类的实例。该实例使用来自SRC_URI变量的空格分隔的URL列表，然后调用download方法来下载文件。

创建fetch类的实例通常接下来会执行以下操作：

.. code:: python

   rootdir = l.getVar('WORKDIR')
   fetcher.unpack(rootdir)

这段代码将下载的文件解压缩到由WORKDIR指定的目录中。

.. note::

   为了方便，这些示例中的命名与OpenEmbedded使用的变量相匹配。如果你想查看上述代码的实际效果，可以检查OpenEmbedded类文件base.bbclass。

SRC_URI和WORKDIR变量没有硬编码到fetcher中，因为这些fetcher方法可以使用（并且正在使用）不同的变量名进行调用。例如，在OpenEmbedded中，共享状态（sstate）代码使用fetch模块来获取sstate文件。

当调用download()方法时，BitBake尝试通过特定的搜索顺序解析URL来查找源文件：

-  预镜像站点：BitBake首先使用预镜像来尝试查找源文件。这些位置使用PREMIRRORS变量定义。
-  源URI：如果预镜像失败，BitBake会使用原始URL（例如来自SRC_URI）。
-  镜像站点：如果获取失败，BitBake接下来会使用MIRRORS变量定义的镜像位置。

对于传递给fetcher的每个URL，fetcher会调用处理特定URL类型的子模块。当你为SRC_URI变量提供URL时，这种行为可能会引起一些混淆。请考虑以下两个URL：

::

   https://git.yoctoproject.org/git/poky;protocol=git
   git://git.yoctoproject.org/git/poky;protocol=http

在前者的情况下，URL被传递给了wget
fetcher，它不理解“git”。因此，后者是正确的形式，因为Git
fetcher知道如何使用HTTP作为传输方式。

以下是一些常用的镜像定义示例：

.. code::

   PREMIRRORS ?= "
      bzr://.*/.\*  http://somemirror.org/sources/ \
      cvs://.*/.\*  http://somemirror.org/sources/ \
      git://.*/.\*  http://somemirror.org/sources/ \
      hg://.*/.\*   http://somemirror.org/sources/ \
      osc://.*/.\*  http://somemirror.org/sources/ \
      p4://.*/.\*   http://somemirror.org/sources/ \
      svn://.*/.\*   http://somemirror.org/sources/"

   MIRRORS =+ "
      ftp://.*/.\*   http://somemirror.org/sources/ \
      http://.*/.\*  http://somemirror.org/sources/ \
      https://.*/.\* http://somemirror.org/sources/"

值得注意的是，BitBake支持跨URL。可以在HTTP服务器上将Git仓库映射为tarball。这就是前面示例中\ ``git://``\ 映射所做的事情。

由于网络访问速度较慢，BitBake会维护一个从网络上下载的文件的缓存。所有非本地（即从互联网下载）的源文件都会被放置在下载目录中，该目录由DL_DIR变量指定。

文件的完整性对于重现构建至关重要。对于非本地档案的下载，fetcher代码可以验证SHA-256和MD5校验和以确保正确下载了档案。你可以通过以下方式使用带有适当varflags的SRC_URI变量指定这些校验和：

.. code::

   SRC_URI[md5sum] = "value"
   SRC_URI[sha256sum] = "value"

你也可以将校验和作为SRC_URI的参数进行指定，如下所示：

.. code::

   SRC_URI = "http://example.com/foobar.tar.bz2;md5sum=4a8e0f237e961fd7785d19d07fdb994d"

如果存在多个URIs，你可以直接如前面的示例那样指定校验和，或者你可以命名URLs。以下语法展示了如何命名URIs：

.. code::

   SRC_URI = "http://example.com/foobar.tar.bz2;name=foo"
   SRC_URI[foo.md5sum] = 4a8e0f237e961fd7785d19d07fdb994d

在文件被下载并进行了校验和检查之后，会在DL_DIR中放置一个“.done”标记。BitBake在后续构建中使用此标记以避免再次下载或比较文件的校验和。

.. note::

   假设本地存储不会受到数据损坏。如果不是这种情况，将会有更大的问题需要担心。

如果设置了\ `BB_STRICT_CHECKSUM <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_STRICT_CHECKSUM>`__\ ，任何没有校验和的下载都会触发错误消息。可以使用BB_NO_NETWORK变量使任何尝试的网络访问成为致命错误，这对于检查镜像是否完整以及其他事情都很有用。

如果将\ `BB_CHECK_SSL_CERTS <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_CHECK_SSL_CERTS>`__\ 设置为0，则会禁用SSL证书检查。这个变量默认为1，所以通常会检查SSL证书。

4.2 解压
=========

解压过程通常紧随下载之后。对于所有非Git URL，BitBake使用通用的解压方法。

在URL中可以指定许多参数来控制解压阶段的行为：

-  unpack：控制是否解压URL组件。如果设置为“1”（默认值），则组件会被解压。如果设置为“0”，则解压阶段不会对文件进行操作。当你希望复制一个档案而不进行解压时，这个参数很有用。
-  dos：适用于.zip和.jar文件，指定是否对文本文件使用DOS行尾转换。
-  striplevel：在提取时去除文件名中的指定数量的前导组件（层级）。
-  subdir：将特定的URL解压到根目录下指定的子目录中。

解压调用会自动解压缩并提取带有“.Z”、“.z”、“.gz”、“.xz”、“.zip”、“.jar”、“.ipk”、“.rpm”、“.srpm”、“.deb”和“.bz2”扩展名的文件，以及各种tarball扩展名的组合。

如前所述，Git
fetcher有自己的解压方法，该方法针对与Git树一起工作进行了优化。基本上，这种方法通过将树克隆到最终目录中来工作。该过程使用引用完成，因此只需要一个Git元数据的中央副本。

4.3 Fetchers
===============

正如前面提到的，URL前缀决定了BitBake使用哪个fetcher子模块。每个子模块可以支持不同的URL参数，这些参数在以下部分中有所描述。

4.3.1 Local file fetcher (``file://``)
--------------------------------------

这个子模块处理以file://开头的URL。你在URL中指定的文件名可以是文件的绝对路径或相对路径。如果文件名是相对的，那么FILESPATH变量的内容会像用于查找可执行文件的PATH一样被使用。如果找不到文件，就假设在调用download()方法时它已经存在于DL_DIR中。

如果你指定了一个目录，整个目录都会被解压。

以下是几个示例URL，第一个是相对的，第二个是绝对的：

.. code::

   SRC_URI = "file://relativefile.patch"
   SRC_URI = "file:///Users/ich/very_important_software"

4.3.2 HTTP/FTP wget fetcher (``http://``, ``ftp://``, ``https://``)
-------------------------------------------------------------------

这个fetcher从web和FTP服务器获取文件。在内部，fetcher使用wget工具。

使用的可执行文件和参数由FETCHCMD_wget变量指定，该变量默认为合理的值。fetcher支持一个参数“downloadfilename”，允许指定下载文件的名称。当处理多个同名文件时，指定下载文件的名称有助于避免在DL_DIR中发生冲突。

如果在SRC_URI中指定了用户名和密码，每个请求（包括重定向）都会添加一个Basic
Authorization头部。如果要将Authorization头部限制在第一个请求中，可以在参数列表中添加“redirectauth=0”。

以下是一些示例URL：

.. code::

   SRC_URI = "http://oe.handhelds.org/not_there.aac"
   SRC_URI = "ftp://oe.handhelds.org/not_there_as_well.aac"
   SRC_URI = "ftp://you@oe.handhelds.org/home/you/secret.plan"

.. note::

   由于URL参数由分号分隔，这可能在解析也包含分号的URL时引入歧义，例如：

   .. code::

      SRC_URI = "http://abc123.org/git/?p=gcc/gcc.git;a=snapshot;h=a5dd47"

   这样的URL应该通过将分号替换为‘&’字符来修改：

   .. code::

      SRC_URI = "http://abc123.org/git/?p=gcc/gcc.git&a=snapshot&h=a5dd47"

   在大多数情况下，这样做应该有效。万维网联盟（W3C）建议在查询中将分号和‘&’视为相同。请注意，由于URL的性质，您可能还必须指定下载文件的名称：

   .. code::

      SRC_URI = "http://abc123.org/git/?p=gcc/gcc.git&a=snapshot&h=a5dd47;downloadfilename=myfile.bz2"

4.3.3 CVS fetcher (``(cvs://``)
-------------------------------

这个子模块负责从CVS版本控制系统中检出文件。你可以使用许多不同的变量来配置它：

-  FETCHCMD_cvs：运行cvs命令时要使用的可执行文件的名称。这个名称通常是“cvs”。
-  SRCDATE：获取CVS源代码时要使用的日期。特殊的“now”值会导致每次构建时都更新检出。
-  CVSDIR：指定临时检出保存的位置。该位置通常是DL_DIR/cvs。
-  CVS_PROXY_HOST：用作cvs命令的“proxy=”参数的名称。
-  CVS_PROXY_PORT：用作cvs命令的“proxyport=”参数的端口号。

除了标准的用户名和密码URL语法，你还可以配置fetcher使用各种URL参数：

支持的参数如下：

-  “method”：与CVS服务器通信时要使用的协议。默认情况下，此协议是“pserver”。如果将“method”设置为“ext”，BitBake会检查“rsh”参数并设置CVS_RSH。你可以使用“dir”来处理本地目录。
-  “module”：指定要检出的模块。你必须提供此参数。
-  “tag”：描述应该使用哪个CVS TAG进行检出。默认情况下，TAG为空。
-  “date”：指定一个日期。如果没有指定“date”，则使用配置中的SRCDATE来检出特定日期。特殊的“now”值会导致每次构建时都更新检出。
-  “localdir”：用于重命名模块。实际上，你是在将模块解包到的输出目录重命名为相对于CVSDIR的特殊目录。
-  “rsh”：与“method”参数一起使用。
-  “scmdata”：当设置为“keep”时，会在fetcher创建的tarball中保留CVS元数据。tarball会扩展到工作目录。默认情况下，会删除CVS元数据。
-  “fullpath”：控制检出结果是否在模块级别，这是默认设置，或者在更深的路径上。
-  “norecurse”：导致fetcher仅检出指定的目录，而不递归进入任何子目录。
-  “port”：CVS服务器连接的端口。

以下是一些示例URL：

.. code::

   SRC_URI = "cvs://CVSROOT;module=mymodule;tag=some-version;method=ext"
   SRC_URI = "cvs://CVSROOT;module=mymodule;date=20060126;localdir=usethat"

4.3.4 Subversion (SVN) Fetcher (``svn://``)
-------------------------------------------

这个fetcher子模块从Subversion源代码控制系统中获取代码。所使用的可执行文件由FETCHCMD_svn指定，默认为“svn”。fetcher的临时工作目录由SVNDIR设置，通常为DL_DIR/svn。

支持的参数如下：

-  “module”：要检出的svn模块的名称。您必须提供此参数。您可以将此参数视为您想要的仓库数据的顶级目录。
-  “path_spec”：在指定svn模块中要检出的特定目录。
-  “protocol”：要使用的协议，默认为“svn”。如果将“protocol”设置为“svn+ssh”，则还会使用“ssh”参数。
-  “rev”：要检出的源代码的修订版本。
-  “scmdata”：当设置为“keep”时，在编译期间会保留“.svn”目录。默认情况下，这些目录会被删除。
-  “ssh”：当“protocol”设置为“svn+ssh”时使用的可选参数。您可以使用此参数指定svn使用的ssh程序。
-  “transportuser”：在需要时，设置传输的用户名。默认情况下，此参数为空。传输用户名与主URL中使用的用户名不同，后者传递给subversion命令。

以下是使用svn的三个示例：

.. code::

   SRC_URI = "svn://myrepos/proj1;module=vip;protocol=http;rev=667"
   SRC_URI = "svn://myrepos/proj1;module=opie;protocol=svn+ssh"
   SRC_URI = "svn://myrepos/proj1;module=trunk;protocol=http;path_spec=${MY_DIR}/proj1"

4.3.5 Git Fetcher (``git://``)
------------------------------

这个fetcher子模块从Git源代码控制系统中获取代码。fetcher通过在GITDIR（通常是DL_DIR/git2）中创建一个远程的裸克隆来工作。然后在解包阶段，当需要检出特定树时，这个裸克隆会被克隆到工作目录中。这是通过使用替代和引用来完成的，以最小化磁盘上重复数据的数量，并使解包过程快速。可执行文件可以通过FETCHCMD_git设置。

这个fetcher支持以下参数：

-  “protocol”：用于获取文件的协议。默认情况下，当设置了主机名时，协议是“git”。如果没有设置主机名，Git协议是“file”。您还可以使用“http”、“https”、“ssh”和“rsync”。

   .. note::

      当协议是“ssh”时，SRC_URI中期望的URL与通常传递给 `git clone` 命令并由Git服务器提供的URL不同。例如，GitLab服务器在通过SSH克隆mesa时返回的URL是 `git@gitlab.freedesktop.org:mesa/mesa.git` ，然而SRC_URI中期望的URL是以下形式：

      ::

         SRC_URI = "git://git@gitlab.freedesktop.org/mesa/mesa.git;branch=main;protocol=ssh;..."

      注意项目路径前的冒号字符被替换为了一个斜杠。

-  “nocheckout”：当设置为“1”时，告诉fetcher在解包时不检出源代码。将此选项设置为URL，其中有自定义程序来检出代码。默认值为“0”。

-  “rebaseable”：表示上游Git仓库可以被变基。如果修订可以从分支脱离，您应该将此参数设置为“1”。在这种情况下，源镜像tarball是按修订进行的，这会降低效率。变基上游Git仓库可能会导致当前修订从上游仓库消失。此选项提醒fetcher小心保留本地缓存以供将来使用。此参数的默认值为“0”。

-  “nobranch”：当设置为“1”时，告诉fetcher不检查分支的SHA验证。默认值为“0”。将此选项设置为引用对任何命名空间（分支、标签等）都有效的提交的配方，而不是分支。

-  “bareclone”：告诉fetcher在目标目录中克隆一个裸克隆，而不检出工作树。只提供原始Git元数据。此参数也意味着“nocheckout”参数。

-  “branch”：要克隆的Git树的分支。除非“nobranch”设置为“1”，否则这是一个必须的参数。分支参数的数量必须与名称参数的数量匹配。

-  “rev”：用于检出的修订。默认为“master”。

-  “tag”：指定用于检出的标签。为了让BitBake正确解析标签，它必须访问网络。因此，标签通常不被使用。就Git而言，“tag”参数的行为实际上与“rev”参数相同。

-  “subpath”：限制检出树的特定子路径。默认情况下，检出整个树。

-  “destsuffix”：放置检出的路径的名称。默认情况下，路径是git/。

-  “usehead”：启用本地git://
   URLs使用当前分支HEAD作为使用AUTOREV的修订。“usehead”参数意味着没有分支，并且仅在传输协议是file://时才有效。

以下是一些示例URL：

::

   SRC_URI = "git://github.com/fronteed/icheck.git;protocol=https;branch=${PV};tag=${PV}"
   SRC_URI = "git://github.com/asciidoc/asciidoc-py;protocol=https;branch=main"
   SRC_URI = "git://git@gitlab.freedesktop.org/mesa/mesa.git;branch=main;protocol=ssh;..."

.. note::

   当使用git作为软件主源代码的获取器时，S应该相应地设置：

   ::

      S = "${WORKDIR}/git"

.. note::

   在 `git://` urls中直接指定密码是不支持的。有几个原因：SRC_URI经常被写入日志和其他地方，这可能会泄露密码；分享元数据时也很容易忘记删除密码。可以使用SSH密钥、-/.netrc和-/.ssh/config文件作为替代方案。**

使用git
fetcher可能会引起意外行为。Bitbake需要将标签解析为特定修订，为此，它必须连接到并使用上游仓库。这是因为标签指向的修订可能会改变，我们已经看到这种情况发生在知名公共仓库中。这可能意味着比预期更多的网络连接，并且每次构建时都可能重新解析配方。由于上游仓库是唯一准确解析修订的真相来源，因此也会绕过源镜像。因此，虽然fetcher可以支持标签，但我们建议在配方中具体说明修订。

4.3.6 Git Submodule Fetcher (``gitsm://``)
------------------------------------------

这个fetcher子模块继承自Git
fetcher，并通过获取仓库的子模块来扩展该fetcher的行为。SRC_URI按照在Git
Fetcher (git://)部分中描述的方式传递给Git fetcher。

.. note::

   当在’git://‘和’gitsm://’ URLs之间切换时，您必须清理配方。

   Git Submodules fetcher不是一个完全的fetcher实现。该fetcher存在已知问题，即它不能正确使用常规的源镜像基础设施。此外，它获取的子模块源对于许可和源存档基础设施是不可见的。

4.3.7 ClearCase Fetcher (``ccrc://``)
-------------------------------------

这个fetcher子模块从ClearCase仓库中获取代码。

要使用这个fetcher，确保您的recipe有正确的SRC_URI、SRCREV和PV设置。这里有一个示例：

::

   SRC_URI = "ccrc://cc.example.org/ccrc;vob=/example_vob;module=/example_module"
   SRCREV = "EXAMPLE_CLEARCASE_TAG"
   PV = "${@d.getVar("SRCREV", False).replace("/", "+")}}"

fetcher使用rcleartool或cleartool远程客户端，取决于哪个可用。

以下是SRC_URI语句的选项：

-  vob：ClearCase VOB的名称，必须包含前置的“/”字符。此选项是必需的。

-  module：所选VOB中的模块，必须包含前置的“/”字符。

   .. note::

      模块和vob选项组合以创建视图配置规范中的加载规则。例如，考虑本节开头的SRC_URI语句中的vob和module值。将这些值组合得到以下结果：

      ::

         proto：协议，可以是http或https。

默认情况下，fetcher创建一个配置规范。如果您希望将规范写入默认区域之外的地方，请在您的recipe中使用CCASE_CUSTOM_CONFIG_SPEC变量来定义规范的位置。

.. note::

   如果指定了此变量，SRCREV将失去其功能。然而，即使它没有定义要获取的内容，SRCREV仍然用于在获取后标记存档。

这里还有一些其他值得注意的行为：

-  当使用cleartool时，cleartool的登录由系统处理，无需特殊步骤。
-  为了在使用认证用户的情况下使用rcleartool，在使用fetcher之前需要进行“rcleartool
   login”。

4.3.8 Perforce Fetcher (``p4://``)
----------------------------------

这个fetcher子模块从Perforce源代码控制系统中获取代码。使用的可执行文件由FETCHCMD_p4指定，默认为“p4”。fetcher的临时工作目录由P4DIR设置，默认为“DL_DIR/p4”。fetcher不使用perforce客户端，而是依赖于p4文件来检索文件列表，以及p4
print将那些文件的内容本地传输。

要使用这个fetcher，确保你的recipe有正确的SRC_URI、SRCREV和PV值。p4可执行文件能够使用由系统P4CONFIG环境变量定义的配置文件来定义Perforce服务器的URL和端口，以及用户名和密码（如果你不想在recipe本身中保留这些值的话）。如果你选择不使用P4CONFIG，或者明确设置P4CONFIG可以包含的变量，你可以指定P4PORT值，即服务器的URL和端口号，并在recipe中的SRC_URI中直接指定用户名和密码。

以下是一个依赖P4CONFIG指定服务器URL和端口、用户名和密码，并获取Head
Revision的示例：

::

   SRC_URI = "p4://example-depot/main/source/..."
   SRCREV = "${AUTOREV}"
   PV = "p4-${SRCPV}"
   S = "${WORKDIR}/p4"

以下是一个指定服务器URL和端口、用户名和密码，并根据标签获取Revision的示例：

::

   P4PORT = "tcp:p4server.example.net:1666"
   SRC_URI = "p4://user:passwd@example-depot/main/source/..."
   SRCREV = "release-1.0"
   PV = "p4-${SRCPV}"
   S = "${WORKDIR}/p4"

.. note::

   在你的recipe中，你应该始终将S设置为“${WORKDIR}/p4”。

默认情况下，fetcher会从本地文件路径中去除仓库位置。在上面的示例中，example-depot/main/source/的内容将被放置在${WORKDIR}/p4中。对于在某些情况下希望在本地保留远程仓库路径的一部分的情况，fetcher支持两个参数：

-  “module”：
   要获取的顶级仓库位置或目录。此参数的值也可以指向仓库中的一个文件，在这种情况下，本地文件路径将包括模块路径。
-  “remotepath”：
   当其值为“keep”时，fetcher将在指定的本地位置镜像完整的仓库路径，即使与module参数结合使用。

以下是使用module参数的示例：

::

   SRC_URI = "p4://user:passwd@example-depot/main;module=source/..."

在这种情况下，顶级目录source/的内容将被获取到\ :math:`{P4DIR}，包括该目录本身。顶级目录将在`\ {P4DIR}/source/处可访问。

以下是使用remotepath参数的示例：

::

   SRC_URI = "p4://user:passwd@example-depot/main;module=source/...;remotepath=keep"

在这种情况下，顶级目录source/的内容将被获取到\ :math:`{P4DIR}，但完整的仓库路径将在本地被镜像。顶级目录将在`\ {P4DIR}/example-depot/main/source/处可访问。

4.3.9 Repo Fetcher (``repo://``)
--------------------------------

这个fetcher子模块从google-repo源代码控制系统中获取代码。它通过启动并同步仓库的源到REPODIR，通常为${DL_DIR}/repo来工作。

此fetcher支持以下参数：

-  “protocol”：获取仓库清单的协议（默认：git）。
-  “branch”：要获取的仓库的分支或标签（默认：master）。
-  “manifest”：清单文件的名称（默认：default.xml）。

以下是一些示例URL：

::

   SRC_URI = "repo://REPOROOT;protocol=git;branch=some_branch;manifest=my_manifest.xml"
   SRC_URI = "repo://REPOROOT;protocol=file;branch=some_branch;manifest=my_manifest.xml"

4.3.10 Az Fetcher (``az://``)
-----------------------------

这个子模块从Azure存储帐户获取数据，它从HTTP wget
fetcher继承其功能，但修改其行为以适应非公共数据的共享访问签名（SAS）的使用。

此类功能由以下变量设置：

-  AZ_SAS：Azure存储共享访问签名为资源提供安全的委托访问，如果设置了此变量，Az
   Fetcher将在从云端获取工件时使用它。

您可以按照下面的方式指定AZ_SAS变量：

::

   AZ_SAS = "se=2021-01-01&sp=r&sv=2018-11-09&sr=c&skoid=<skoid>&sig=<signature>"

这是一个示例URL：

::

   SRC_URI = "az://<azure-storage-account>.blob.core.windows.net/<foo_container>/<bar_file>"

在设置镜像定义时，也可以使用\ `PREMIRRORS <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-PREMIRRORS>`__\ 变量。

4.3.11 GCP Fetcher (``gs://``)
------------------------------

这个子模块从\ `Google Cloud Storage
Bucket <https://cloud.google.com/storage/docs/buckets>`__\ 中获取数据。它使用\ `Google
Cloud Storage
Python客户端 <https://cloud.google.com/python/docs/reference/storage/latest>`__\ 来检查存储桶中对象的状态并下载它们。使用Python客户端比使用gsutil等命令行工具要快得多。

获取器需要安装Google Cloud Storage Python客户端和gsutil工具。

获取器要求机器具有访问所选存储桶的有效凭据。身份验证的说明可以在\ `Google
Cloud文档 <https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev>`__\ 中找到。

如果在OpenEmbedded构建系统中使用，获取器可以通过指定SSTATE_MIRRORS变量来从GCS存储桶获取sstate工件，如下所示：

::

   SSTATE_MIRRORS ?= "\
       file://.* gs://<bucket name>/PATH \
   "

获取器还可以在配方中使用：

::

   SRC_URI = "gs://<bucket name>/<foo_container>/<bar_file>"

然而，文件的校验和也应该提供：

::

   SRC_URI[sha256sum] = "<sha256 string>"

4.3.12 Crate Fetcher (``crate://``)
-----------------------------------

这个子模块用于获取\ `Rust语言的“crates” <https://doc.rust-lang.org/reference/glossary.html?highlight=crate#crate>`__\ ，即Rust库和程序的代码，以便进行编译。这些crates通常在https://crates.io/上共享，但此获取器还支持其他crate注册中心。

SRC_URI设置的格式必须为：

::

   SRC_URI = "crate://REGISTRY/NAME/VERSION"

例如：

::

   SRC_URI = "crate://crates.io/glob/0.2.11"

4.3.14 NPM shrinkwrap Fetcher (``npmsw://``)
--------------------------------------------

这个子模块从NPM
shrinkwrap描述文件中获取源代码，该文件列出了NPM包的依赖项并锁定它们的版本。

SRC_URI设置的格式必须为：

::

   SRC_URI = "npmsw://some.registry.url;ParameterA=xxx;ParameterB=xxx;..."

此获取器支持以下参数：

-  “dev”：将此参数设置为1以安装“devDependencies”。
-  “destsuffix”：指定用于解压缩依赖项的目录（默认为${S}）。

请注意，shrinkwrap文件也可以由具有此类依赖项的包的配方提供，例如：

::

   SRC_URI = " \
       npm://registry.npmjs.org/;package=cute-files;version=${PV} \
       npmsw://${THISDIR}/${BPN}/npm-shrinkwrap.json \
       "

可以使用devtool自动生成此类文件，如Yocto Project的创建\ `Node Package
Manager (NPM)
Packages <https://docs.yoctoproject.org/dev-manual/packages.html#creating-node-package-manager-npm-packages>`__\ 部分所述。

4.3.15 Other Fetchers
---------------------

以下是一些其他可用的获取子模块：

-  Bazaar（bzr://）
-  Mercurial（hg://）
-  OSC（osc://）
-  S3（s3://）
-  安全FTP（sftp://）
-  安全Shell（ssh://）
-  使用Git Annex的树（gitannex://）

目前还没有关于这些较少使用的获取子模块的文档。但是，您可能会发现代码易于阅读和理解。

4.4 Auto Revisions
------------------

我们会在此记录 AUTOREV 和
`SRCREV_FORMAT <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-SRCREV_FORMAT>`__\ 。

==============
5 变量术语表
==============

这个章节列出了BitBake常用的变量，并对它们的功能和内容进行了概述。

.. note::

   以下是关于本词汇表中列出的变量的一些要点：

   -  本词汇表中列出的变量是特定于BitBake的。因此，描述仅限于该上下文。
   -  此外，其他使用BitBake的系统（例如Yocto项目和OpenEmbedded）中也存在与本词汇表中的名称相同的变量。对于这种情况，这些系统中的变量扩展了本词汇表中所描述的变量的功能。

-  ASSUME_PROVIDED：

   列出BitBake不尝试构建的配方名称（PN值）。相反，BitBake假设这些配方已经构建好了。

   在OpenEmbedded-Core中，\ `ASSUME_PROVIDED <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-ASSUME_PROVIDED>`__\ 主要用于指定不应构建的本地工具。例如，当指定git-native时，允许使用主机上的Git二进制文件，而不是构建git-native。

-  AZ_SAS：

   Azure存储共享访问签名，当使用Azure存储获取器时。此变量可以被定义，以便获取器使用它进行身份验证并获得对非公开工件的访问权限：

   ::

      AZ_SAS = ""se=2021-01-01&sp=r&sv=2018-11-09&sr=c&skoid=<skoid>&sig=<signature>""

   ::

      有关更多信息，请参阅Microsoft的Azure存储文档：https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview

-  B： BitBake在配方构建过程中执行函数的目录。

-  BB_ALLOWED_NETWORKS：
   指定获取所需源代码时允许使用的主机的空格分隔列表。以下是关于此变量的注意事项：

   -  如果未设置BB_NO_NETWORK或设置为“0”，则仅使用此主机列表。

   -  支持有限的“*”通配符字符，用于匹配主机名开头。例如，以下设置匹配git.gnu.org、ftp.gnu.org和foo.git.gnu.org。

      ::

         BB_ALLOWED_NETWORKS = "\*.gnu.org"

      重要：

      “\ *”字符仅在主机名开头起作用，并且必须与主机名的其余部分隔离。您不能在名称的任何其他位置或与名称的前部分结合使用通配符字符。*

      例如，\ ``*.foo.bar``\ 是受支持的，而\ ``*aa.foo.bar``\ 则不受支持。

   -  不在主机列表中的镜像将被跳过并在调试中记录。

   -  尝试访问不在主机列表中的网络会导致失败。

   将BB_ALLOWED_NETWORKS与PREMIRRORS结合使用非常有用。将您要使用的主机添加到PREMIRRORS中，可以确保从允许的位置获取源代码，并避免在SRC_URI语句中出现不允许的主机时引发错误。这是因为在成功从PREMIRRORS获取后，获取器不会尝试使用SRC_URI中列出的主机。

-  BB_BASEHASH_IGNORE_VARS：

   列出从校验和和依赖数据中排除的变量。因此，被排除的变量可以更改而不影响校验和机制。一个常见的例子是构建路径的变量。BitBake的输出不应该（通常也不会）依赖于它所在的目录。

-  BB_CACHEDIR：

   指定代码解析器缓存目录（与CACHE和PERSISTENT_DIR不同，尽管如果需要可以将它们设置为相同的值）。默认值为“${TOPDIR}/cache”。

-  BB_CHECK_SSL_CERTS：

   指定在获取时是否应检查SSL证书。默认值为1，如果值设置为0则不检查证书。

-  BB_CONSOLELOG：

   指定BitBake的用户界面在构建过程中将输出写入的日志文件的路径。

-  BB_CURRENTTASK：

   包含当前正在运行的任务的名称。名称不包括do_前缀。

-  BB_DANGLINGAPPENDS_WARNONLY：

   定义BitBake如何处理附加文件（.bbappend）没有相应的配方文件（.bb）的情况。这种情况通常发生在层次结构不同步时（例如，oe-core更新了配方版本，旧配方不再存在，而其他层尚未更新为配方的新版本）。

   默认的致命行为是最安全的，因为当某些东西不同步时，这是最合理的反应。意识到你的更改不再被应用是很重要的。

-  BB_DEFAULT_TASK：

   当没有指定任务时要使用的默认任务（例如，使用-c命令行选项）。指定的任务名称不应包括do_前缀。

-  BB_DEFAULT_UMASK：

   如果指定了并且没有设置任务特定的umask标志，则应用于任务的默认umask。

-  BB_DISKMON_DIRS：

   在构建过程中监控磁盘空间和可用inode，并允许您根据这些参数控制构建。

   默认情况下禁用磁盘空间监控。设置此变量时，请使用以下格式：

   ::

      BB_DISKMON_DIRS = "<action>,<dir>,<threshold> [...]"

      where:

         <action> is:
            HALT:      Immediately halt the build when
                       a threshold is broken.
                       当违反阈值时立即停止构建。
            STOPTASKS: Stop the build after the currently
                       executing tasks have finished when
                       a threshold is broken.
                       当违反阈值时，在当前执行的任务完成后停止构建。
            WARN:      Issue a warning but continue the
                       build when a threshold is broken.
                       Subsequent warnings are issued as
                       defined by the
                       BB_DISKMON_WARNINTERVAL variable,
                       which must be defined.
                       当违反阈值时发出警告但继续构建。后续警告按照
                       定义的BB_DISKMON_WARNINTERVAL变量发出，该变量
                       必须定义。

         <dir> is:
            Any directory you choose. You can specify one or
            more directories to monitor by separating the
            groupings with a space.  If two directories are
            on the same device, only the first directory
            is monitored.
            您可以选择任何目录。您可以通过用空格分隔分组来指定一个
            或多个要监控的目录。如果两个目录位于同一设备上，则只监控
            第一个目录。

         <threshold> is:
            Either the minimum available disk space,
            the minimum number of free inodes, or
            both.  You must specify at least one.  To
            omit one or the other, simply omit the value.
            Specify the threshold using G, M, K for Gbytes,
            Mbytes, and Kbytes, respectively. If you do
            not specify G, M, or K, Kbytes is assumed by
            default.  Do not use GB, MB, or KB.
            可以是最小可用磁盘空间、最小空闲inode数量或两者。
            您必须至少指定一个。要省略其中一个，只需省略该值。
            使用G、M、K分别表示Gbytes、Mbytes和Kbytes来指定阈值。
            如果您没有指定G、M或K，默认假设为Kbytes。不要使用GB、MB或KB。

   以下是一些示例：

   ::

      BB_DISKMON_DIRS = "HALT,${TMPDIR},1G,100K WARN,${SSTATE_DIR},1G,100K"
      BB_DISKMON_DIRS = "STOPTASKS,${TMPDIR},1G"
      BB_DISKMON_DIRS = "HALT,${TMPDIR},,100K"

   第一个示例只有在您还设置了BB_DISKMON_WARNINTERVAL变量时才有效。此示例导致构建系统在\ ``${TMPDIR}``\ 中的磁盘空间降至1
   Gbyte以下或可用空闲inode数量降至100
   Kbytes以下时立即停止。由于提供了两个目录，构建系统还会在\ ``${SSTATE_DIR}``\ 目录中的磁盘空间降至1
   Gbyte以下或空闲inode数量降至100
   Kbytes以下时发出警告。后续警告将按照BB_DISKMON_WARNINTERVAL变量定义的时间间隔发出。

   第二个示例在${TMPDIR}目录中的最小磁盘空间降至1
   Gbyte以下时，在所有当前执行的任务完成后停止构建。在这种情况下，不会对空闲inode进行磁盘监控。

   最后一个示例在\ ``${TMPDIR}``\ 目录中的空闲inode数量降至100
   Kbytes以下时立即停止构建。在这种情况下，不会对该目录本身的磁盘空间进行监控。

-  BB_DISKMON_WARNINTERVAL：

   定义磁盘空间和空闲inode警告间隔。

   如果您打算使用BB_DISKMON_WARNINTERVAL变量，您还必须使用BB_DISKMON_DIRS变量并将其动作定义为“WARN”。在构建过程中，每当磁盘空间或空闲inode数量进一步减少时，都会按照各自的间隔发出后续警告。

   如果您没有提供BB_DISKMON_WARNINTERVAL变量，但使用了带有“WARN”动作的BB_DISKMON_DIRS，则磁盘监控间隔默认为以下值：BB_DISKMON_WARNINTERVAL
   = “50M,5K”

   在配置文件中指定该变量时，请使用以下格式：

   ::

      BB_DISKMON_WARNINTERVAL = "<disk_space_interval>,<disk_inode_interval>"

      where:

         <disk_space_interval> is:
            An interval of memory expressed in either
            G, M, or K for Gbytes, Mbytes, or Kbytes,
            respectively. You cannot use GB, MB, or KB.
            间隔以G、M或K表示，分别对应Gbytes、Mbytes或Kbytes。
            您不能使用GB、MB或KB。

         <disk_inode_interval> is:
            An interval of free inodes expressed in either
            G, M, or K for Gbytes, Mbytes, or Kbytes,
            respectively. You cannot use GB, MB, or KB.
            空闲inode的间隔以G、M或K表示，分别对应Gbytes、Mbytes
            或Kbytes。您不能使用GB、MB或KB。

   以下是一些示例：

   ::

      BB_DISKMON_DIRS = "WARN,${SSTATE_DIR},1G,100K"
      BB_DISKMON_WARNINTERVAL = "50M,5K"

   这些变量导致BitBake在\ ``${SSTATE_DIR}``\ 目录中的可用磁盘空间进一步减少50
   Mbytes或空闲inode数量进一步减少5
   Kbytes时，每次发出后续警告。基于间隔的后续警告在达到初始警告（即1
   Gbytes和100 Kbytes）之后的每个相应间隔时发生。

-  BB_ENV_PASSTHROUGH

   指定从外部环境传递到BitBake数据存储的内部变量列表。如果未指定此变量的值（这是默认设置），则使用以下列表：BBPATH,
   BB_PRESERVE_ENV, BB_ENV_PASSTHROUGH, 和
   BB_ENV_PASSTHROUGH_ADDITIONS。

   .. note::

      您必须在外部环境中设置此变量，它才能起作用。

-  BB_ENV_PASSTHROUGH_ADDITIONS

   指定从外部环境传递到BitBake数据存储的额外一组变量。这些变量列表是在BB_ENV_PASSTHROUGH中设置的内部列表之上的。

   .. note::

      您必须在外部环境中设置此变量，它才能起作用。

-  BB_FETCH_PREMIRRORONLY

   当设置为“1”时，使BitBake的获取模块仅在PREMIRRORS中搜索文件。BitBake将不搜索主SRC_URI或MIRRORS。

-  BB_FILENAME

   包含拥有当前正在运行任务的配方的文件名。例如，如果执行的是位于my-recipe.bb中的do_fetch任务，那么BB_FILENAME变量将包含“/foo/path/my-recipe.bb”。

-  BB_GENERATE_MIRROR_TARBALLS

   导致Git仓库的tarballs（包括Git元数据）被放置在DL_DIR目录中。任何希望创建源代码镜像的人都希望启用此变量。

   出于性能原因，通过BitBake创建和放置Git仓库的tarballs不是默认操作。

   ::

      BB_GENERATE_MIRROR_TARBALLS = "1"

-  BB_GENERATE_SHALLOW_TARBALLS

   当BB_GIT_SHALLOW也设置为“1”时，将此变量设置为“1”会导致bitbake在获取git仓库时生成浅层镜像tarballs。浅层镜像tarballs中包含的提交数量由BB_GIT_SHALLOW_DEPTH控制。

   如果同时启用了BB_GIT_SHALLOW和BB_GENERATE_MIRROR_TARBALLS，bitbake将默认为git仓库生成浅层镜像tarballs。这个单独的变量存在，以便在不希望启用普通镜像生成时可以启用浅层tarball生成。

   有关示例用法，请参阅BB_GIT_SHALLOW。

-  BB_GIT_SHALLOW
   将此变量设置为“1”可以启用对浅层git仓库的获取、使用和生成镜像tarballs的支持。外部的git-make-shallow脚本被用于创建浅层镜像tarballs。

   当BB_GIT_SHALLOW被启用时，bitbake将尝试获取一个浅层镜像tarball。如果无法获取浅层镜像tarball，它将尝试获取完整的镜像tarball并使用它。

   当没有可用的镜像tarball时，无论是否设置了这个变量，都会执行完整的git克隆。因为git不直接支持浅层克隆特定的git提交哈希（它只支持从标签或分支引用克隆），所以目前还没有实现对浅层克隆的支持。

   另见BB_GIT_SHALLOW_DEPTH和BB_GENERATE_SHALLOW_TARBALLS。

   示例用法：

   ::

      BB_GIT_SHALLOW ?= "1"

      # Keep only the top commit
      BB_GIT_SHALLOW_DEPTH ?= "1"

      # This defaults to enabled if both BB_GIT_SHALLOW and
      # BB_GENERATE_MIRROR_TARBALLS are enabled
      BB_GENERATE_SHALLOW_TARBALLS ?= "1"

-  BB_GIT_SHALLOW_DEPTH

   当与BB_GENERATE_SHALLOW_TARBALLS一起使用时，此变量设置在生成的浅层镜像tarballs中包含的提交数量。深度为1时，仅包含SRCREV中引用的提交在浅层镜像tarball中。增加深度将包括额外的父提交，回溯提交历史记录。

   如果未设置此变量，bitbake在生成浅层镜像tarballs时将默认深度为1。

   例如用法，请参见BB_GIT_SHALLOW。

-  BB_GLOBAL_PYMODULES

   指定要放置在全局命名空间中的Python模块列表。只有核心层应该设置此变量，它应该是一个很小的列表，通常只有os和sys。预计在第一个addpylib指令之前设置BB_GLOBAL_PYMODULES。另见“扩展Python库代码”。

-  BB_HASH_CODEPARSER_VALS

   指定在填充代码解析器缓存时要使用的变量值。这可以有选择地设置虚拟值，以避免每次解析时代码解析器缓存增长。通常包括的变量是那些对于代码解析器缓存使用的位置不重要的变量（即在计算代码片段的变量依赖关系时）。值是用空格分隔的，不需要引用值，例如：

   ::

      BB_HASH_CODEPARSER_VALS = "T=/ WORKDIR=/ DATE=1234 TIME=1234"

-  BB_HASHCHECK_FUNCTION

   指定在任务执行的“setscene”部分期间调用的函数的名称，以验证任务哈希列表。该函数返回应执行的setscene任务列表。

   在代码执行的这一点，目标是快速验证给定的setscene函数是否可能工作。检查一次setscene函数列表比调用许多单独的任务更容易。返回的列表不需要完全准确。给定的setscene任务仍然可能稍后失败。然而，返回的数据越准确，构建就越高效。

-  BB_HASHCONFIG_IGNORE_VARS

   列出从基本配置校验和中排除的变量，该校验和用于确定是否可以重用缓存。

   BitBake确定是否重新解析主元数据的方法之一是通过基本配置数据的datastore中变量的校验和。有些变量在检查是否重新解析并因此重建缓存时，你通常会想要排除。作为示例，你通常会排除TIME和DATE，因为这些变量总是在变化。如果你不排除它们，BitBake将永远不会重用缓存。

-  BB_HASHSERVE

   指定要使用的Hash Equivalence服务器。

   如果设置为auto，BitBake将自动通过UNIX域套接字启动自己的服务器。一种选项是将此服务器连接到上游服务器，通过设置BB_HASHSERVE_UPSTREAM。

   如果设置为unix://path，BitBake将连接到通过UNIX域套接字提供的现有hash服务器。

   如果设置为host:port，BitBake将连接到指定主机上的远程服务器。这允许多个客户端共享相同的hash等价数据。

   远程服务器可以通过BitBake提供的bin/bitbake-hashserv脚本手动启动，该脚本也支持UNIX域套接字。此脚本还允许以只读模式启动服务器，以避免接受对应于仅在特定客户端上可用的Share
   State缓存的等价性。

-  BB_HASHSERVE_UPSTREAM

   指定上游Hash Equivalence服务器。

   这个可选设置仅在启动本地Hash
   Equivalence服务器时有用（将BB_HASHSERVE设置为auto），并且您希望本地服务器查询上游服务器以获取Hash
   Equivalence数据。

   示例用法：

   ::

      BB_HASHSERVE_UPSTREAM = "hashserv.yocto.io:8687"

-  BB_INVALIDCONF

   与ConfigParsed事件结合使用，用于触发重新解析基础元数据（即所有配方）。ConfigParsed事件可以设置此变量以触发重新解析。使用此功能时必须小心避免递归循环。

-  BB_LOGCONFIG

   指定包含用户日志配置的配置文件的名称。有关更多信息，请参阅\ `日志 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-execution.html#logging>`__\ 记录。

-  BB_LOGFMT

   指定保存到\ ``${T}``\ 中的日志文件的名称。默认情况下，BB_LOGFMT变量未定义，日志文件名采用以下形式创建：

   ::

      log.{task}.{pid}

   如果您希望日志文件采用特定名称，可以在配置文件中设置此变量。

-  BB_MULTI_PROVIDER_ALLOWED

   允许您抑制由构建提供相同输出的两个单独配方引起的BitBake警告。

   BitBake在构建两个提供相同输出的不同配方时通常会发出警告。这种情况通常是用户不希望看到的。然而，在某些情况下，特别是在 `virtual/*` 命名空间中，这是有意义的。您可以使用此变量来抑制BitBake的警告。

   要使用此变量，请列出提供者名称（例如配方名称、virtual/kernel等）。

-  BB_NICE_LEVEL

   允许BitBake以特定优先级（即nice级别）运行。系统权限通常意味着BitBake可以降低其优先级，但不能再次提高。有关额外信息，请参阅\ `BB_TASK_NICE_LEVEL <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_TASK_NICE_LEVEL>`__\ 。

-  BB_NO_NETWORK

   在BitBake
   fetcher模块中禁用网络访问。禁用此访问后，任何尝试访问网络的命令都会成为错误。

   禁用网络访问对于测试源镜像、在未连接到Internet时运行构建以及在某些类型的防火墙环境中操作很有用。

-  BB_NUMBER_PARSE_THREADS

   设置BitBake在解析时使用的线程数。默认情况下，线程数等于系统上的内核数。

-  BB_NUMBER_THREADS

   BitBake在任何时候应并行运行的最大任务数。如果您的主机开发系统支持多核，一个好的经验法则是将此变量设置为内核数的两倍。

-  BB_ORIGENV

   包含BitBake运行的原始外部环境的副本。在任何配置为从外部环境传递到BitBake数据存储的变量值被过滤之前，都会拍摄此副本。

   .. note::

      此变量的内容是可以使用正常数据存储操作查询的数据存储对象。

-  BB_PRESERVE_ENV

   禁用环境过滤，而是允许所有变量从外部环境传递到BitBake的数据存储中。

   .. note::

      您必须在外部环境中设置此变量，它才能起作用。

-  BB_PRESSURE_MAX_CPU

   指定一个最大CPU压力阈值，超过该阈值时，BitBake的调度程序将不会启动新任务（前提是至少有一个活动任务）。如果没有设置值，启动任务时将不监控CPU压力。

   压力数据是基于自4.20版本起的Linux内核在/proc/pressure下公开的内容计算的。阈值表示前一秒“总”压力的差异。最小值是1.0（极其缓慢的构建），最大值是1000000（不太可能达到的压力值）。

   这个阈值可以在conf/local.conf中设置为：

   ::

      BB_PRESSURE_MAX_CPU = "500"

-  BB_PRESSURE_MAX_IO

   指定一个最大I/O压力阈值，超过该阈值时，BitBake的调度程序将不会启动新任务（前提是至少有一个活动任务）。如果没有设置值，启动任务时将不监控I/O压力。

   压力数据是基于自4.20版本起的Linux内核在/proc/pressure下公开的内容计算的。阈值表示前一秒“总”压力的差异。最小值是1.0（极其缓慢的构建），最大值是1000000（不太可能达到的压力值）。

   目前来看，实验表明I/O压力往往是短暂的，仅通过BB_PRESSURE_MAX_CPU调节CPU可以帮助减少它。

-  BB_PRESSURE_MAX_MEMORY

   指定一个最大内存压力阈值，超过该阈值时，BitBake的调度程序将不会启动新任务（前提是至少有一个活动任务）。如果没有设置值，启动任务时将不监控内存压力。

   压力数据是基于自4.20版本起的Linux内核在/proc/pressure下公开的内容计算的。阈值表示前一秒“总”压力的差异。最小值是1.0（极其缓慢的构建），最大值是1000000（不太可能达到的压力值）。

   当时间花在交换、重新错误页面从页缓存或执行直接回收时，会经历内存压力。这就是为什么很少见到内存压力，但是如果您在构建过程中遇到OOM错误，设置这个变量可能作为最后的手段来防止它们发生。

-  BB_RUNFMT

   指定保存到${T}中的可执行脚本文件（即运行文件）的名称。默认情况下，BB_RUNFMT变量未定义，运行文件名采用以下形式创建：

   ::

      run.{func}.{pid}

   如果您希望运行文件采用特定名称，您可以在配置文件中设置此变量。

-  BB_RUNTASK

   包含当前执行任务的名称。该值包括 `do_` 前缀。例如，如果当前正在执行的任务是do_config，则其值为“do_config”。

-  BB_SCHEDULER

   选择用于任务调度的调度程序的名称。有三种选项：

   -  basic —
      所有其他选项都衍生于此基础框架。使用此选项会导致任务在解析时按数字顺序排列。
   -  speed — 首先执行更多依赖项的任务。“speed”选项是默认设置。
   -  completion — 使调度器尝试在构建开始后完成给定的配方。

-  BB_SCHEDULERS

   定义要导入的自定义调度程序。自定义调度程序需要从RunQueueScheduler类派生。

   有关如何选择调度器的信息，请参阅\ `BB_SCHEDULER <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_SCHEDULER>`__\ 变量。

-  BB_SETSCENE_DEPVALID

   指定BitBake调用的函数，用于确定BitBake是否需要满足setscene依赖性。

   当运行setscene任务时，BitBake需要知道该setscene任务的哪些依赖项也需要运行。依赖项是否需要运行在很大程度上取决于元数据。此变量指定的函数根据依赖项是否需要满足返回“True”或“False”。

-  BB_SIGNATURE_EXCLUDE_FLAGS

   列出可以从数据存储中键的校验和和依赖数据中安全排除的varflags（变量标志）。生成数据存储中键的校验和或依赖数据时，通常会将针对该键设置的标志包含在校验和中。

   有关varflags的更多信息，请参阅“\ `变量标志 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#variable-flags>`__\ ”部分。

-  BB_SIGNATURE_HANDLER

   定义BitBake使用的签名处理器的名称。签名处理器定义了创建和处理戳记文件的方式，是否以及如何将签名纳入戳记中，以及如何生成签名本身。

   可以通过将派生自SignatureGenerator类的类注入全局命名空间来添加新的签名处理器。

-  BB_SRCREV_POLICY

   定义与源代码控制系统和动态源版本交互时获取器的行为。在没有网络的情况下工作时，BB_SRCREV_POLICY变量很有用。

   该变量可以使用以下两种策略之一进行设置：

   -  cache — 保留系统先前获得的值，而不是每次都查询源代码控制系统。
   -  clear —
      每次都查询源代码控制系统。使用此策略时，没有缓存。“clear”策略是默认设置。

-  BB_STRICT_CHECKSUM

   为非本地URL设置更严格的校验和机制。设置此变量的值会导致BitBake报告错误，如果它遇到一个没有至少一个指定校验和的非本地URL。

-  BB_TASK_IONICE_LEVEL

   允许调整任务的输入/输出优先级。在Autobuilder测试期间，由于I/O饥饿，任务可能会随机失败。这些故障发生在各种QEMU运行时超时时。您可以使用BB_TASK_IONICE_LEVEL变量调整这些任务的I/O优先级。

   .. note::

      这个变量的工作方式类似于BB_TASK_NICE_LEVEL变量，不同之处在于任务的I/O优先级。

   将变量设置如下：

   ::

      BB_TASK_IONICE_LEVEL = "class.prio"

   对于class，默认值为“2”，这是最佳效果。您可以使用“1”进行实时操作，并使用“3”进行空闲操作。如果您想使用实时操作，您必须具有超级用户特权。

   对于prio，您可以使用从“0”（最高优先级）到“7”（最低优先级）的任何值。默认值是“4”。您不需要任何特殊特权即可使用此优先级范围。

   .. note::

      为了使您的I/O优先级设置生效，您需要为底层块设备选择完全公平排队（CFQ）调度器。要选择调度器，请使用以下命令形式，其中device是设备（例如sda、sdb等）：

      ::

         $ sudo sh -c "echo cfq > /sys/block/device/queu/scheduler"

-  BB_TASK_NICE_LEVEL

   允许特定任务改变它们的优先级（即nice级别）。

   你可以将此变量与任务覆盖结合使用，以提高或降低特定任务的优先级。例如，在Yocto项目自动构建系统上，为了确保图像在加载的系统上不会超时，QEMU仿真在镜像中的优先级比构建任务要高。

-  BB_TASKHASH

   在执行的任务中，此变量保存当前启用的签名生成器返回的任务哈希值。

-  BB_VERBOSE_LOGS

   控制BitBake在构建期间的详细程度。如果设置了，shell脚本会回显命令，shell脚本输出会出现在标准输出（stdout）上。

-  BB_WORKERCONTEXT

   指定当前上下文是否正在执行任务。当任务被执行时，BitBake将此变量设置为“1”。在解析或事件处理期间，如果任务处于服务器上下文中，则不设置该值。

-  BBCLASSEXTEND

   允许你扩展配方，以便构建软件的变体。OpenEmbedded-Core元数据的一些变体示例是“natives”，如quilt-native，它是在构建系统上运行的Quilt的副本；“crosses”如gcc-cross，它是在构建机器上运行但产生在目标MACHINE上运行的二进制文件的编译器；“nativesdk”，它针对的是SDK机器而不是MACHINE；以及“multilibs”的形式为“multilib:multilib_name”。

   要用最少的代码构建配方的不同变体，通常只需将变量添加到你的配方中。以下是两个示例。“native”变体来自OpenEmbedded-Core元数据：

   ::

      BBCLASSEXTEND =+ "native nativesdk"
      BBCLASSEXTEND =+ "multilib:multilib_name"

   .. note::

      在内部，BBCLASSEXTEND机制通过重写变量值和应用如_class-native的覆盖来生成配方变体。例如，要生成配方的native版本，将依赖于“foo”的DEPENDS重写为依赖于“foo-native”的DEPENDS。

      即使使用BBCLASSEXTEND，配方也只解析一次。解析一次增加了一些限制。例如，根据变体包含不同的文件是不可能的，因为include语句是在解析配方时处理的。

-  BBDEBUG

   将BitBake调试输出级别设置为特定值，该值由-D命令行选项递增。

   .. note::

      你必须在外部环境中设置这个变量才能使其工作。

-  BBFILE_COLLECTIONS

   列出配置层的名称。这些名称用于查找其他 `BBFILE_*` 变量。通常，每个层在其conf/layer.conf文件中将其名称追加到这个变量。

-  BBFILE_PATTERN

   展开以匹配特定层中BBFILES的文件的变量。这个变量用在conf/layer.conf文件中，必须用特定层的名称作为后缀（例如BBFILE_PATTERN_emenlow）。

-  BBFILE_PRIORITY

   为每层中的配方文件分配优先级。

   这个变量在相同配方出现在多个层的情况下非常有用。设置这个变量可以让你优先于其他包含相同配方的层，有效地让你控制多个层的优先级。通过这个变量建立的优先级不考虑配方的版本（PV变量）。例如，一个层的配方具有更高的PV值，但BBFILE_PRIORITY被设置为较低的优先级，仍然具有较低的优先级。

   BBFILE_PRIORITY变量的值越大，优先级越高。例如，值6比值5有更高的优先级。如果没有指定，BBFILE_PRIORITY变量基于层依赖关系设置（有关更多信息，请参阅LAYERDEPENDS变量）。如果未指定层的默认优先级，则为最低定义优先级+1（如果没有定义优先级，则为1）。

   .. tip::

      你可以使用命令 `bitbake-layers show-layers` 列出所有配置层及其优先级。

-  BBFILES

   BitBake用于构建软件的配方文件的空格分隔列表。

   在指定配方文件时，你可以使用Python的glob语法进行模式匹配。有关该语法的详细信息，请参阅上述链接的文档。

-  BBFILES_DYNAMIC

   根据已识别层的存在激活内容。你可以通过层定义的集合来标识这些层。

   使用BBFILES_DYNAMIC变量可以避免.bbappend文件，其相应的.bb文件位于试图通过.bbappend修改其他层但不希望对这些其他层引入硬依赖的层中。

   此外，你可以在规则前加上“！”前缀，以在层不存在的情况下添加.bbappend和.bb文件。使用此方法避免对这些其他层产生硬依赖。

   使用以下形式设置BBFILES_DYNAMIC：

   ::

      collection_name:filename_pattern

   以下示例标识了两个集合名称和两个文件名模式：

   ::

      BBFILES_DYNAMIC += "
          clang-layer:${LAYERDIR}/bbappends/meta-clang/*/*/*.bbappend 
          core:${LAYERDIR}/bbappends/openembedded-core/meta/*/*/*.bbappend 
      "

   当集合名称前带有“！”时，如果层不存在，它将添加文件模式：

   ::

      BBFILES_DYNAMIC += "
          !clang-layer:${LAYERDIR}/backfill/meta-clang/*/*/*.bb 
      "

   下面的示例显示了一个错误消息，因为找到了无效的条目，导致解析失败：

   ::

      ERROR: BBFILES_DYNAMIC entries must be of the form {!}<collection name>:<filename pattern>, not:
      /work/my-layer/bbappends/meta-security-isafw/*/*/*.bbappend
      /work/my-layer/bbappends/openembedded-core/meta/*/*/*.bbappend

-  BBINCLUDED

   包含BitBake解析器在当前文件解析期间包含的所有文件的空格分隔列表。

-  BBINCLUDELOGS

   如果设置为一个值，则在报告失败的任务时启用打印任务日志。

-  BBINCLUDELOGS_LINES

   如果设置了BBINCLUDELOGS，则在报告失败的任务时指定从任务日志文件中打印的最大行数。如果你没有设置BBINCLUDELOGS_LINES，将打印整个日志。

-  BBLAYERS

   列出在构建期间要启用的层。这个变量在构建目录中的bblayers.conf配置文件中定义。以下是一个例子：

   ::

      BBLAYERS = " 
          /home/scottrif/poky/meta 
          /home/scottrif/poky/meta-yocto 
          /home/scottrif/poky/meta-yocto-bsp 
          /home/scottrif/poky/meta-mykernel 
      "

   这个例子启用了四个层，其中一个是名为meta-mykernel的自定义用户定义层。

-  BBLAYERS_FETCH_DIR

   设置存储层的基位置。此设置与bitbake-layers
   layerindex-fetch一起使用，并告诉bitbake-layers将获取的层放置在何处。

-  BBMASK

   防止BitBake处理配方和配方附加文件。

   你可以使用BBMASK变量来“隐藏”这些.bb和.bbappend文件。BitBake会忽略与任何表达式匹配的任何配方或配方附加文件。就好像BitBake根本没有看到它们一样。因此，匹配的文件不会被解析或被BitBake使用。

   你提供的值将传递给Python的正则表达式编译器。因此，语法遵循Python的正则表达式(re)语法。表达式与文件的完整路径进行比较。有关完整语法信息，请参阅Python的文档http://docs.python.org/3/library/re.html。

   以下示例使用完整的正则表达式告诉BitBake忽略meta-ti/recipes-misc/目录中的所有配方和配方附加文件：

   ::

      BBMASK = "meta-ti/recipes-misc/"

   如果你想屏蔽多个目录或配方，你可以指定多个正则表达式片段。下面的例子屏蔽了多个目录和单独的配方：

   ::

      BBMASK += "/meta-ti/recipes-misc/ meta-ti/recipes-ti/packagegroup/"
      BBMASK += "/meta-oe/recipes-support/"
      BBMASK += "/meta-foo/.*/openldap"
      BBMASK += "opencv.*\.bbappend"
      BBMASK += "lzma"

   .. note::

      在指定目录名时，使用尾随斜杠字符以确保仅匹配该目录名。

-  BBMULTICONFIG

   启用BitBake执行多个配置构建并列出每个单独的配置（多配置）。你可以使用这个变量来使BitBake构建多个目标，每个目标都有单独的配置。在你的conf/local.conf配置文件中定义BBMULTICONFIG。

   例如，以下行指定了三个多配置，每个都有一个单独的配置文件：

   ::

      BBMULTIFONFIG = "configA configB configC"

   你使用的每个配置文件必须位于构建目录中的名为conf/multiconfig的目录内（例如build_directory/conf/multiconfig/configA.conf）。

   有关如何在支持构建具有多个配置的目标的环境中使用BBMULTICONFIG的信息，请参阅“\ `执行多配置构建 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-intro.html#executing-a-multiple-configuration-build>`__\ ”部分。

-  BBPATH

   BitBake用来定位类（.bbclass）和配置文件（.conf）的冒号分隔列表。这个变量类似于PATH变量。

   如果你从构建目录之外的目录运行BitBake，你必须确保将BBPATH设置为指向构建目录。像设置任何环境变量一样设置变量，然后运行BitBake：

   ::

      $ BBPATH="build_directory"
      $ export BBPATH
      $ bitbake target

-  BBSERVER

   指向运行内存驻留BitBake的服务器。这个变量仅在你使用内存驻留BitBake时使用。

-  BBTARGETS

   允许你使用配置文件来添加到你想要构建的命令行目标配方列表中。

-  BITBAKE_UI

   用于指定运行BitBake时要使用的UI模块。使用这个变量等效于使用-u命令行选项。

   .. note::

      你必须在外部环境中设置这个变量才能使其工作。

-  BUILDNAME

   分配给构建的名称。该名称默认为构建开始时的日期时间戳，但也可以通过元数据定义。

-  BZRDIR

   从Bazaar系统检出的文件存储的目录。

-  CACHE

   指定BitBake用来存储元数据缓存的目录，这样每次启动BitBake时就不需要解析它。

-  CVSDIR

   在CVS系统下检出的文件存储的目录。

-  DEFAULT_PREFERENCE

   为配方选择优先级指定一个弱偏好。

   这个变量最常见的用法是在开发版本的软件配方中将其设置为“-1”。以这种方式使用该变量会导致在没有使用PREFERRED_VERSION来构建开发版本的情况下默认构建配方的稳定版本。

   .. note::

      如果包含同一配方不同版本的两个层之间的BBFILE_PRIORITY变量不同，则DEFAULT_PREFERENCE提供的偏见是弱的，并且会被覆盖。

-  DEPENDS

   列出配方的构建时依赖项（即其他配方文件）。

   考虑两个名为“a”和“b”的配方的简单示例，它们产生类似命名的软件包。在这个示例中，DEPENDS语句出现在“a”配方中：

   ::

      DEPENDS = "b"

   在这里，依赖关系是这样的，配方“a”的do_configure任务依赖于配方“b”的do_populate_sysroot任务。这意味着当配方“a”配置自身时，配方“b”放入sysroot中的任何内容都是可用的。

   有关运行时依赖的信息，请参阅RDEPENDS变量。

-  DESCRIPTION

   配方的详细描述。

-  DL_DIR

   构建过程用来存储下载的中央下载目录。默认情况下，DL_DIR获取适合镜像的文件，除了Git仓库之外的一切。如果你想要Git仓库的tarballs，使用BB_GENERATE_MIRROR_TARBALLS变量。

-  EXCLUDE_FROM_WORLD

   指示BitBake将配方从world构建中排除（即bitbake
   world）。在world构建期间，BitBake定位、解析并构建在bblayers.conf配置文件中暴露的每个层中找到的所有配方。

   要使用此变量将配方从world构建中排除，请在配方中将变量设置为“1”。将其设置为“0”以将其添加回world构建。

   .. note::

      添加到EXCLUDE_FROM_WORLD的配方仍然可能在world构建期间构建，以满足其他配方的依赖项。将配方添加到EXCLUDE_FROM_WORLD只能确保配方不会明确添加到world构建的构建目标列表中。

-  FAKEROOT

   包含在fakeroot环境中运行shell脚本时要使用的命令。FAKEROOT变量已过时，已被其他FAKEROOT*变量替换。请参阅词汇表中的相关条目以获取更多信息。

-  FAKEROOTBASEENV

   列出在执行由FAKEROOTCMD定义的命令时设置的环境变量，该命令在fakeroot环境中启动bitbake-worker进程。

-  FAKEROOTCMD

   包含在fakeroot环境中启动bitbake-worker进程的命令。

-  FAKEROOTDIRS

   列出在fakeroot环境中运行任务前要创建的目录。

-  FAKEROOTENV

   列出在fakeroot环境中运行任务时设置的环境变量。有关环境变量和fakeroot环境的更多信息，请参阅FAKEROOTBASEENV变量。

-  FAKEROOTNOENV

   列出在非fakeroot环境中运行任务时设置的环境变量。有关环境变量和fakeroot环境的更多信息，请参阅FAKEROOTENV变量。

-  FETCHCMD

   定义BitBake
   fetcher模块在执行获取操作时执行的命令。当使用该变量时，需要使用覆盖后缀（例如FETCHCMD_git或FETCHCMD_svn）。

-  FILE

   指向当前文件。BitBake在解析过程中设置此变量，以标识正在解析的文件。BitBake还在执行配方时设置此变量，以标识配方文件。

-  FILE_LAYERNAME

   在解析和任务执行期间，将其设置为包含配方文件的层的名称。代码可以使用它来识别配方来自哪个层。

-  FILESPATH

   指定BitBake在搜索补丁和文件时使用的目录。“local”
   fetcher模块在处理file:// URLs时使用这些目录。该变量的行为类似于shell
   PATH环境变量。值是按从左到右的顺序搜索的目录的冒号分隔列表。

-  GITDIR

   克隆Git仓库时存储本地副本的目录。

-  HGDIR

   存储从Mercurial系统检出的文件的目录。

-  HOMEPAGE

   可以找到有关配方构建的软件的更多信息的网站的网址。

-  INHERIT

   导致全局继承命名的一个或多个类。对于基本配置和每个单独的配方，不会执行类中的匿名函数。OpenEmbedded构建系统忽略单个配方中对INHERIT的更改。

   有关INHERIT的更多信息，请参阅“\ `INHERIT配置指令 <https://docs.yoctoproject.org/bitbake/2.6/bitbake-user-manual/bitbake-user-manual-metadata.html#inherit-configuration-directive>`__\ ”部分。

-  LAYERDEPENDS

   列出此配方依赖的层，用空格分隔。如果需要，您可以通过在层名后面加上冒号来指定依赖项的特定层版本（例如“anotherlayer:3”与LAYERVERSION_anotherlayer进行比较）。如果缺少任何依赖项或版本号不匹配（如果指定），则BitBake会产生错误。

   您在conf/layer.conf文件中使用此变量。您还必须使用特定的层名称作为变量的后缀（例如LAYERDEPENDS_mylayer）。

-  LAYERDIR

   在layer.conf配置文件中使用此变量时，提供当前层的路径。此变量在layer.conf之外不可用，并且在文件解析完成时立即扩展引用。

-  LAYERDIR_RE

   在layer.conf配置文件中使用此变量时，提供当前层的路径，用于正则表达式（BBFILE_PATTERN）中。此变量在layer.conf之外不可用，并且在文件解析完成时立即扩展引用。

-  LAYERSERIES_COMPAT

   列出OpenEmbedded-Core（OE-Core）的版本，这些版本与层兼容。使用LAYERSERIES_COMPAT变量允许层维护者指示哪些层和OE-Core的组合可以预期工作。该变量为系统提供了一种检测层是否未经过新的OE-Core发布测试的方法（例如，层未得到维护）。

   要在您的层的conf/layer.conf配置文件中指定层兼容的OE-Core版本，请使用此变量。对于列表，使用Yocto
   Project发行版名称（例如“kirkstone”，“mickledore”）。要为层指定多个OE-Core版本，请使用空格分隔的列表：

   ::

      LAYERSERIES_COMPAT_layer_root_name = "kirkstone mickledore"

   .. note::

      根据Yocto Project兼容版本2标准，设置LAYERSERIES_COMPAT是必需的。如果在任何给定层中未设置该变量，OpenEmbedded构建系统会产生警告。

-  LAYERVERSION

   可选地以单个数字指定层的版本。您可以在另一个层的LAYERDEPENDS中使用此变量，以便依赖特定版本的层。

   您在conf/layer.conf文件中使用此变量。您还必须使用特定的层名称作为变量的后缀（例如LAYERDEPENDS_mylayer）。

-  LICENSE

   配方的源许可证列表。

-  MIRRORS

   指定BitBake从中获取源代码的其他路径。当构建系统搜索源代码时，它首先尝试本地下载目录。如果该位置失败，构建系统会尝试PREMIRRORS定义的位置、上游源代码，然后按该顺序尝试MIRRORS中指定的位置。

-  OVERRIDES

   BitBake用冒号分隔的列表来控制解析配方和配置文件后要覆盖哪些变量。

   以下是一个简单的示例，根据机器架构使用覆盖列表：OVERRIDES =
   “arm:x86:mips:powerpc”
   您可以在“条件语法（Overrides）”部分中找到有关如何使用OVERRIDES的信息。

-  P4DIR

   当从Perforce仓库获取时，本地副本存储的目录。

-  PACKAGES

   配方创建的软件包列表。

-  PACKAGES_DYNAMIC

   您的配方满足其他配方中发现的可选模块的运行时依赖关系的承诺。PACKAGES_DYNAMIC实际上并不满足依赖关系，它只是声明应该满足它们。例如，如果在构建过程中通过PACKAGES_DYNAMIC变量满足了另一个软件包的硬性运行时依赖关系（RDEPENDS），但实际上从未产生具有模块名称的软件包，那么其他软件包将会损坏。

-  PE

   配方的时代。默认情况下，此变量未设置。该变量用于在版本方案以某种向后不兼容的方式发生变化时使升级成为可能。

-  PERSISTENT_DIR

   指定BitBake用于存储应在构建之间保留的数据的目录。特别是，存储的数据是使用BitBake的持久数据API的数据以及PR服务器和PR服务使用的数据。

-  PF

   指定配方或软件包名称，并包括所有版本和修订号（即eglibc-2.13-r20+svnr15508/和bash-4.2-r1/）。

-  PN

   配方名称。

-  PR

   配方的修订版。

-  PREFERRED_PROVIDER

   确定在多个配方提供相同项目时应优先考虑哪个配方。您应该始终将变量后缀为提供的项目名称，并且您应该将其设置为要优先处理的配方的PN。一些示例：

   ::

      PREFERRED_PROVIDER_virtual/kernel ?= "linux-yocto"
      PREFERRED_PROVIDER_virtual/xserver = "xserver-xf86"
      PREFERRED_PROVIDER_virtual/libgl ?= "mesa"

-  PREFERRED_PROVIDERS

   确定在多个配方提供相同项目时应优先考虑哪个配方。功能上，PREFERRED_PROVIDERS与PREFERRED_PROVIDER相同。然而，PREFERRED_PROVIDERS变量让您可以使用以下形式为多种情况定义偏好：

   ::

      PREFERRED_PROVIDERS = "xxx:yyy aaa:bbb ..."

   这种形式是以下形式的方便替代：

   ::

      PREFERRED_PROVIDER_xxx = "yyy"
      PREFERRED_PROVIDER_aaa = "bbb"

-  PREFERRED_VERSION

   如果有多个版本的配方可用，此变量决定应优先考虑哪个版本。您必须始终将变量后缀为您想要选择的PN，并且您应该相应地设置PV以获得优先权。

   PREFERRED_VERSION变量支持通过“%”字符有限地使用通配符。您可以使用该字符来匹配任何数量的字符，这在指定包含可能更改的长修订号的版本时很有用。以下是两个示例：

   ::

      PREFERRED_VERSION_python = "2.7.3"
      PREFERRED_VERSION_linux-yocto = "4.12%"

   .. note:: 

      “%”字符的使用是有限的，因为它只能在字符串的末尾工作。您不能在字符串的任何其他位置使用通配符字符。

   如果没有指定版本的配方可用，将显示警告消息。如果您希望这是一个错误，请参阅REQUIRED_VERSION。

-  PREMIRRORS

   指定了BitBake获取源代码的额外路径。当构建系统搜索源代码时，它首先尝试本地下载目录。如果该位置失败，构建系统会尝试由PREMIRRORS定义的位置、上游源，然后是MIRRORS指定的顺序。

   通常，您可以通过在配置中添加以下内容，让构建系统在尝试其他服务器之前先尝试特定的服务器：

   ::

      PREMIRRORS:prepend = "\
      git://.*/.* http://downloads.yoctoproject.org/mirror/sources/ \
      ftp://.*/.* http://downloads.yoctoproject.org/mirror/sources/ \
      http://.*/.* http://downloads.yoctoproject.org/mirror/sources/ \
      https://.*/.* http://downloads.yoctoproject.org/mirror/sources/"

   这些更改会导致构建系统拦截Git、FTP、HTTP和HTTPS请求，并将它们重定向到http://源镜像。您还可以使用file://
   URL指向本地目录或网络共享。

-  PROVIDES

   一个特定配方可以通过别名列表来识别。默认情况下，配方自己的PN已经隐含在其PROVIDES列表中。如果一个配方使用了PROVIDES，那么额外的别名就是该配方的同义词，在构建过程中满足其他配方的依赖关系时非常有用，正如DEPENDS所指定的。

   考虑以下来自配方文件libav_0.8.11.bb的PROVIDES语句示例：

   ::

      PROVIDES += "libpostproc"

   PROVIDES语句的结果使得“libav”配方也被称为“libpostproc”。

   除了为配方提供替代名称外，PROVIDES机制还用于实现虚拟目标。虚拟目标是与某些特定功能相对应的名称（例如Linux内核）。提供所讨论功能的配方会在PROVIDES中列出虚拟目标。依赖于该功能的配方可以在DEPENDS中包含虚拟目标，以保留提供者的选择。

   传统上，虚拟目标的名称采用“virtual/function”（例如“virtual/kernel”）的形式。斜杠只是名称的一部分，没有语法意义。

-  PRSERV_HOST

   这是基于网络的PR服务的主机和端口。

   以下是如何设置PRSERV_HOST变量的示例：

   ::

      PRSERV_HOST = "localhost:0"

   如果您想自动启动本地PR服务，则必须设置该变量。您可以将PRSERV_HOST设置为其他值以使用远程PR服务。

-  PV

   这是配方的版本。

-  RDEPENDS

   列出了包的运行时依赖项（即其他包），这些依赖项必须安装才能正确运行构建的包。如果在构建过程中无法找到此列表中的包，您将收到构建错误。

   因为RDEPENDS变量适用于正在构建的包，所以您应该始终使用带有附加包名的变量形式。例如，假设您正在构建一个依赖于perl包的开发包。在这种情况下，您将使用以下RDEPENDS语句：

   ::

      RDEPENDS:${PN}-dev += "perl"

   在此示例中，开发包依赖于perl包。因此，RDEPENDS变量具有${PN}-dev包名作为其一部分。

   BitBake支持指定带版本的依赖项。尽管语法根据打包格式而异，但BitBake会隐藏这些差异。以下是用RDEPENDS变量指定版本的一般语法：

   ::

      RDEPENDS:${PN} = "package (operator version)"

   对于运算符，您可以指定以下内容：

   ::

      =
      <
      >
      <=
      >=

   例如，以下设置了对版本1.2或更高版本的包foo的依赖关系：

   ::

      RDEPENDS:${PN} = "foo (>= 1.2)"

   有关构建时依赖项的信息，请参阅DEPENDS变量。

-  REPODIR

   同步时，存储google-repo目录的本地副本的目录。

-  REQUIRED_VERSION

   如果有多个版本的配方可用，则该变量确定应优先选择哪个版本。REQUIRED_VERSION的工作方式与PREFERRED_VERSION完全相同，只是如果指定的版本不可用，则会显示错误消息并立即使构建失败。

   如果为同一配方设置了REQUIRED_VERSION和PREFERRED_VERSION，则应用REQUIRED_VERSION的值。

-  RPROVIDES

   包也提供的包名别名列表。这些别名对于满足构建期间（如RDEPENDS中指定的）以及目标上的运行时依赖关系非常有用。

   与所有控制包的变量一样，您必须始终将变量与包名覆盖一起使用。以下是一个例子：

   ::

      RPROVIDES:${PN} = "widget-abi-2"

-  RRECOMMENDS

   扩展了正在构建的包的可用性的包列表。正在构建的包不依赖于此列表中的包以成功构建，但需要它们进行扩展的可用性。要指定包的运行时依赖项，请参阅RDEPENDS变量。

   BitBake支持指定带版本的推荐。尽管语法根据打包格式而异，但BitBake会隐藏这些差异。以下是用RRECOMMENDS变量指定版本的一般语法：

   ::

      RRECOMMENDS:${PN} = "package (operator version)"

   对于运算符，您可以指定以下内容：

   ::

      =
      <
      >
      <=
      >=

   例如，以下设置了对版本1.2或更高版本的包foo的推荐：

   ::

      RRECOMMENDS:${PN} = "foo (>= 1.2)"

-  SECTION

   包应被归类在其中的部分。

-  SRC_URI

   源文件列表，可以是本地或远程。这个变量告诉BitBake从哪里获取构建所需的内容以及如何获取它们。例如，如果配方或附加文件需要从互联网获取一个tarball，那么配方或附加文件将使用一个SRC_URI条目来指定该tarball。另一方面，如果配方或附加文件需要获取一个tarball、应用两个补丁并包含一个自定义文件，那么配方或附加文件需要一个SRC_URI变量来指定所有这些来源。

   以下是可用的URI协议列表。URI协议高度依赖于特定的BitBake
   Fetcher子模块。根据BitBake使用的fetcher，会使用各种URL参数。有关支持的Fetchers的详细信息，请参阅Fetchers部分。

   -  az://：使用HTTPS从Azure存储帐户获取文件。
   -  bzr://：从Bazaar版本控制系统仓库获取文件。
   -  ccrc://：从ClearCase仓库获取文件。
   -  cvs://：从CVS版本控制系统仓库获取文件。
   -  file://：从本地机器获取文件，这些文件通常是与元数据一起提供的。路径相对于FILESPATH变量。因此，构建系统按顺序搜索以下目录，这些目录被认为是位于配方文件（.bb）或附加文件（.bbappend）所在的目录的子目录：

      -  ${BPN}：没有特殊后缀或版本号的基本配方名称。
      -  ``${BP} - ${BPN}-${PV}``\ ：基本配方名称和版本，但没有特殊的包名后缀。
      -  files：名为files的目录中的文件，该目录也位于配方或附加文件旁边。

   -  ftp://：使用FTP从互联网获取文件。
   -  git://：从Git版本控制系统仓库获取文件。
   -  gitsm://：从Git版本控制系统仓库获取子模块。
   -  hg://：从Mercurial（hg）版本控制系统仓库获取文件。
   -  http://：使用HTTP从互联网获取文件。
   -  https://：使用HTTPS从互联网获取文件。
   -  npm://：从注册表中获取JavaScript模块。
   -  osc://：从OSC（OpenSUSE Build服务）版本控制系统仓库获取文件。
   -  p4://：从Perforce（p4）版本控制系统仓库获取文件。
   -  repo://：从repo（Git）仓库获取文件。
   -  ssh://：从安全外壳获取文件。
   -  svn://：从Subversion（svn）版本控制系统仓库获取文件。

   这里还有一些值得注意的其他选项：

   -  downloadfilename：指定下载文件时使用的文件名。

   -  name：当在SRC_URI中有多个文件或git仓库时，用于关联SRC_URI校验和或SRCREV的名称。例如：

      ::

         SRC_URI = "git://example.com/foo.git;branch=main;name=first \
                    git://example.com/bar.git;branch=main;name=second \
                    http://example.com/file.tar.gz;name=third"

         SRCREV_first = "f1d2d2f924e986ac86fdf7b36c94bcdf32beec15"
         SRCREV_second = "e242ed3bffccdf271b7fbaf34ed72d089537b42f"
         SRC_URI[third.sha256sum] = "13550350a8681c84c861aac2e5b440161c2b33a3e4f302ac680ca5b686de48de"

   -  subdir：将文件（或提取其内容）放入指定的子目录中。这对于不在其存档中具有子目录的文件的tarball或其他存档非常有用。

   -  subpath：在使用Git fetcher时，限制检出到树的特定子路径。

   -  unpack：控制是否解压缩文件（如果是存档）。默认操作是解压缩文件。

-  SRCDATE

   用于构建包的源代码的日期。仅当从源代码管理器（SCM）获取源时，此变量才适用。

-  SRCREV

   用于构建包的源代码的修订版本。仅在使用Subversion、Git、Mercurial和Bazaar时适用。如果要构建固定修订版本并且希望避免每次BitBake解析配方时都执行对远程仓库的查询，则应指定一个SRCREV，而不仅仅是一个标签。

-  SRCREV_FORMAT

   在SRC_URI中使用多个源代码控制的URL时，帮助构造有效的SRCREV值。

   系统需要在以下情况下帮助构造这些值。SRC_URI中的每个组件都被赋予一个名称，并在SRCREV_FORMAT变量中引用。考虑一个名为“machine”和“meta”的URL示例。在这种情况下，SRCREV_FORMAT可能看起来像“machine_meta”，并且这些名称将被替换到每个位置的SCM版本中。只添加一个AUTOINC占位符（如果需要的话），并将其放在返回字符串的开头。

-  STAMP

   指定创建配方标记文件的基本路径。实际标记文件的路径是通过评估此字符串并附加其他信息来构造的。

-  STAMPCLEAN

   指定创建配方标记文件的基本路径。与STAMP变量不同，STAMPCLEAN可以包含通配符，以匹配清理操作应删除的文件范围。BitBake使用清理操作来删除创建新标记时应删除的任何其他标记。

-  SUMMARY

   配方的简短摘要，不超过72个字符。

-  SVNDIR

   从Subversion系统检出文件的目录。

-  T

   指向BitBake放置临时文件的目录，这些文件主要由任务日志和脚本组成，在构建特定配方时使用。

-  TOPDIR

   指向构建目录。BitBake自动设置此变量。

======================
6 Hello World Example
======================

6.1 BitBake Hello World
========================

通常用来展示任何新的编程语言或工具的最简单例子是“Hello World”示例。本附录以教程形式，在BitBake的背景下演示Hello World。该教程描述了如何创建一个新的项目以及允许BitBake构建它所必需的适用元数据文件。

6.2 获得bitbake
================

请参阅获取BitBake部分，了解如何获取BitBake的信息。一旦您在机器上拥有源代码，BitBake目录如下所示：

::

   $ ls -al
   total 108
   drwxr-xr-x  9 fawkh 10000  4096 feb 24 12:10 .
   drwx------ 36 fawkh 10000  4096 mar  2 17:00 ..
   -rw-r--r--  1 fawkh 10000   365 feb 24 12:10 AUTHORS
   drwxr-xr-x  2 fawkh 10000  4096 feb 24 12:10 bin
   -rw-r--r--  1 fawkh 10000 16501 feb 24 12:10 ChangeLog
   drwxr-xr-x  2 fawkh 10000  4096 feb 24 12:10 classes
   drwxr-xr-x  2 fawkh 10000  4096 feb 24 12:10 conf
   drwxr-xr-x  5 fawkh 10000  4096 feb 24 12:10 contrib
   drwxr-xr-x  6 fawkh 10000  4096 feb 24 12:10 doc
   drwxr-xr-x  8 fawkh 10000  4096 mar  2 16:26 .git
   -rw-r--r--  1 fawkh 10000    31 feb 24 12:10 .gitattributes
   -rw-r--r--  1 fawkh 10000   392 feb 24 12:10 .gitignore
   drwxr-xr-x 13 fawkh 10000  4096 feb 24 12:11 lib
   -rw-r--r--  1 fawkh 10000  1224 feb 24 12:10 LICENSE
   -rw-r--r--  1 fawkh 10000 15394 feb 24 12:10 LICENSE.GPL-2.0-only
   -rw-r--r--  1 fawkh 10000  1286 feb 24 12:10 LICENSE.MIT
   -rw-r--r--  1 fawkh 10000   229 feb 24 12:10 MANIFEST.in
   -rw-r--r--  1 fawkh 10000  2413 feb 24 12:10 README
   -rw-r--r--  1 fawkh 10000    43 feb 24 12:10 toaster-requirements.txt
   -rw-r--r--  1 fawkh 10000  2887 feb 24 12:10 TODO

此时，您应该已经将BitBake克隆到了一个目录，该目录与上述列表匹配，除了日期和用户名。

6.3 设置BitBake环境
====================

首先，您需要确保可以运行BitBake。将您的工作目录设置为本地BitBake文件所在的目录，并运行以下命令：

::

   $ ./bin/bitbake --version
   BitBake Build Tool Core version 2.3.1

控制台输出告诉您正在运行的版本。

推荐从您选择的目录运行BitBake。要能够从任何目录运行BitBake，您需要将可执行二进制文件添加到shell的环境PATH变量中。首先，通过输入以下内容查看当前的PATH变量：

::

   $ echo $PATH

接下来，将BitBake二进制文件的目录位置添加到PATH中。这里有一个示例，它将\ ``/home/scott-lenovo/bitbake/bin``\ 目录添加到PATH变量的前面：

::

   $ export PATH=/home/scott-lenovo/bitbake/bin:$PATH

现在，您应该能够在任何目录下通过命令行输入bitbake命令了。

6.4 Hello World示例
=====================

本练习的总体目标是利用任务和层概念构建一个完整的“Hello
World”示例。由于这是现代项目如OpenEmbedded和Yocto
Project使用BitBake的方式，因此该示例为理解BitBake提供了一个绝佳的起点。

为了帮助您了解如何使用BitBake构建目标，该示例从仅使用bitbake命令开始，这会导致BitBake失败并报告问题。通过逐步添加构建的部分，最终得出一个工作的、最小的“Hello
World”示例。

尽管我们尽力解释在示例期间发生的事情，但描述无法涵盖所有内容。您可以在本手册中找到更多信息。此外，您还可以积极参与https://lists.openembedded.org/g/bitbake-devel关于BitBake构建工具的讨论邮件列表。

.. note::

   这个示例受到 `Mailing List帖子 - The BitBake equivalent of “Hello,World!” <https://www.mail-archive.com/yocto@yoctoproject.org/msg09379.html>`_ 的启发，并从中汲取了很多内容。

如前所述，这个示例的最终目标是编译“Hello
World”。然而，目前尚不清楚BitBake需要什么以及为了实现这一目标您需要提供什么。回想一下，BitBake利用了三种类型的元数据文件：配置文件、类和配方。但它们应该放在哪里？BitBake如何找到它们？BitBake的错误消息有助于您回答这类问题，并更好地理解到底发生了什么。

以下是完整的“Hello World”示例。

1.  创建项目目录：

    首先，为“Hello World”项目设置一个目录。以下是您可以在主目录中执行此操作的方法：

    ::

       $ mkdir -/hello
       $ cd -/hello

    这是BitBake将用来完成所有工作的目录。您可以使用此目录来保存BitBake所需的所有元文件。拥有一个项目目录是隔离项目的好方法。

2. 运行BitBake：

   此时，您只有一个项目目录。运行bitbake命令并查看它的作用：

   ::

      $ bitbake
      ERROR: The BBPATH variable is not set and bitbake did not find a conf/bblayers.conf file in the expected location.
      Maybe you accidentally invoked bitbake from the wrong directory?
      错误：BBPATH变量未设置，且bitbake未在预期位置找到conf/bblayers.conf文件。
      也许您不小心从错误的目录调用了bitbake？
      当您运行BitBake时，它开始寻找元数据文件。BBPATH变量告诉BitBake在哪里查找这些文件。BBPATH未设置，您需要设置它。没有BBPATH，BitBake根本找不到任何配置文件（.conf）或配方文件（.bb）。BitBake也找不到bitbake.conf文件。

3. 设置BBPATH：

   对于本示例，您可以像之前在附录中设置PATH一样设置BBPATH。不过，您应该意识到，在每个项目的配置文件中设置BBPATH变量要更加灵活。

   在您的shell中，输入以下命令来设置并导出BBPATH变量：

   ::

      $ BBPATH="projectdirectory"
      $ export BBPATH

   在命令中使用您实际的项目目录。BitBake使用该目录来查找项目所需的元数据。

   .. note::

      在指定项目目录时，不要使用波浪号（“-”）字符，因为BitBake不会像shell那样扩展该字符。

4. 运行BitBake：

   现在您已经定义了BBPATH，再次运行bitbake命令：

   ::

      $ bitbake
      ERROR: Unable to parse /home/scott-lenovo/bitbake/lib/bb/parse/__init__.py
      Traceback (most recent call last):
      File "/home/scott-lenovo/bitbake/lib/bb/parse/__init__.py", line 127, in resolve_file(fn='conf/bitbake.conf', d=<bb.data_smart.DataSmart object at 0x7f22919a3df0>):
            if not newfn:
      >            raise IOError(errno.ENOENT, "file %s not found in %s" % (fn, bbpath))
            fn = newfn
      FileNotFoundError: [Errno 2] file conf/bitbake.conf not found in <projectdirectory>

   此样本输出显示BitBake未能在项目目录中找到conf/bitbake.conf文件。这个文件是BitBake为了构建目标必须首先找到的。而且，由于本例的项目目录为空，您需要提供一个conf/bitbake.conf文件。

5. 创建conf/bitbake.conf：

   conf/bitbake.conf包含BitBake用于元数据和配方文件的许多配置变量。对于本示例，您需要在项目目录中创建该文件并定义一些关键的BitBake变量。有关bitbake.conf文件的更多信息，请参见https://git.openembedded.org/bitbake/tree/conf/bitbake.conf。

   使用以下命令在项目目录中创建conf目录：

   ::

      $ mkdir conf

   在conf目录下，使用某个编辑器创建bitbake.conf文件，使其包含以下内容：

   ::

      PN  = "${@bb.parse.vars_from_file(d.getVar('FILE', False),d)[0] or 'defaultpkgname'}"

      TMPDIR  = "${TOPDIR}/tmp"
      CACHE   = "${TMPDIR}/cache"
      STAMP   = "${TMPDIR}/${PN}/stamps"
      T       = "${TMPDIR}/${PN}/work"
      B       = "${TMPDIR}/${PN}"

   .. note::

      如果没有为PN设置值，变量STAMP、T和B将阻止多个配方同时工作。您可以通过设置PN的值，使其类似于OpenEmbedded和BitBake在默认bitbake.conf文件中使用的值（参见前面的示例）来解决这个问题。或者，手动更新每个配方以设置PN。您还需要在local.conf文件中将PN作为STAMP、T和B变量定义的一部分。

   TMPDIR变量建立了一个BitBake用于构建输出和中间文件的目录，这些文件不包括Setscene进程使用的缓存信息。在这里，TMPDIR目录被设置为hello/tmp。

   .. note::

      您可以随时安全地删除tmp目录以重新构建BitBake目标。当您运行BitBake时，构建过程会为您创建该目录。

   有关此示例中定义的其他变量的信息，请查看PN、TOPDIR、CACHE、STAMP、T或B，以便在术语表中查找定义。

6. 运行BitBake：

   在确保conf/bitbake.conf文件存在后，您可以再次运行bitbake命令：

   ::

      $ bitbake
      ERROR: Unable to parse /home/scott-lenovo/bitbake/lib/bb/parse/parse_py/BBHandler.py
      Traceback (most recent call last):
      File "/home/scott-lenovo/bitbake/lib/bb/parse/parse_py/BBHandler.py", line 67, in inherit(files=['base'], fn='configuration INHERITs', lineno=0, d=<bb.data_smart.DataSmart object at 0x7fab6815edf0>):
            if not os.path.exists(file):
      >            raise ParseError("Could not inherit file %s" % (file), fn, lineno)

      bb.parse.ParseError: ParseError in configuration INHERITs: Could not inherit file classes/base.bbclass

   在样本输出中，BitBake未能找到classes/base.bbclass文件。您接下来需要创建该文件。

7. 创建classes/base.bbclass：

   BitBake使用类文件来提供通用代码和功能。BitBake最基本的需求类是classes/base.bbclass文件。这个基础类被每个配方隐式继承。BitBake在项目的classes目录中查找该类（例如，在这个例子中的hello/classes）。

   按照以下步骤创建classes目录：

   ::

      $ cd $HOME/hello
      $ mkdir classes

   移动到classes目录，然后通过插入这一行来创建base.bbclass文件：

   ::

      addtask build

   BitBake运行的最基本任务是do_build任务。这就是这个示例为了构建项目所需要的全部。当然，根据BitBake支持的构建环境，base.bbclass可以包含更多内容。

8. 运行BitBake：

   在确保classes/base.bbclass文件存在后，您可以再次运行bitbake命令：

   ::

      $ bitbake
      Nothing to do. Use 'bitbake world' to build everything, or run 'bitbake --help' for usage information.
      没有要做的事情。使用'bitbake world'来构建所有内容，或运行'bitbake --help'获取使用信息。

   BitBake最终没有报告错误。然而，您可以看到它确实没有任何事情要做。您需要创建一个配方，让BitBake有事情可做。

9. 创建层：

   虽然对于这样一个简单的示例来说并不真正必要，但创建一层以将您的代码与BitBake使用的一般元数据分开是一个好习惯。因此，这个示例创建并使用了一个名为“mylayer”的层。

   .. note::

      您可以在“层”部分找到有关层的额外信息。

   至少，您的层中需要一个配方文件和一个层配置文件。配置文件需要位于层内的conf目录中。使用这些命令来设置层和conf目录：

   ::

      $ cd $HOME
      $ mkdir mylayer
      $ cd mylayer
      $ mkdir conf

   移动到conf目录并创建一个包含以下内容的layer.conf文件：

   ::

      BBPATH .= ":${LAYERDIR}"
      BBFILES += "${LAYERDIR}/*.bb"
      BBFILE_COLLECTIONS += "mylayer"
      BBFILE_PATTERN_mylayer := "^${LAYERDIR_RE}/"
      LAYERSERIES_CORENAMES = "hello_world_example"
      LAYERSERIES_COMPAT_mylayer = "hello_world_example"

   有关这些变量的信息，请查看BBFILES、LAYERDIR、BBFILE_COLLECTIONS、BBFILE_PATTERN_mylayer或LAYERSERIES_COMPAT，前往术语表中的定义。

   .. note::

      在这个特定的情况下，我们同时设置了LAYERSERIES_CORENAMES和LAYERSERIES_COMPAT，因为我们在不使用OpenEmbedded的情况下使用bitbake。通常，您只需使用LAYERSERIES_COMPAT来指定您的层与之兼容的OE-Core版本，并将meta-openembedded层添加到您的项目中。

   下一步，您需要创建配方文件。在您的层的顶层目录中，使用编辑器创建一个名为printhello.bb的配方文件，内容如下：

   ::

      DESCRIPTION = "Prints Hello World"
      PN = 'printhello'
      PV = '1'

      python do_build() {
         bb.plain("********************");
         bb.plain("*                  *");
         bb.plain("*  Hello, World!   *");
         bb.plain("*                  *");
         bb.plain("********************");
      }

   配方文件仅提供配方的描述、名称、版本和do_build任务，该任务将“Hello World”打印到控制台。有关DESCRIPTION、PN或PV的更多信息，请按照链接前往术语表。

10. 运行BitBake并提供目标：

   现在存在一个BitBake目标，运行该命令并提供该目标：

   ::

      $ cd $HOME/hello
      $ bitbake printhello
      ERROR: no recipe files to build, check your BBPATH and BBFILES?

      Summary: There was 1 ERROR message shown, returning a non-zero exit code.

   我们已经创建了包含配方和层配置文件的层，但BitBake似乎仍然找不到配方。BitBake需要一个列出项目层的conf/bblayers.conf文件。没有这个文件，BitBake无法找到配方。

11. 创建conf/bblayers.conf：

   BitBake使用conf/bblayers.conf文件来定位项目所需的层。该文件必须位于项目的conf目录中（例如，对于本例来说是hello/conf）。

   将您的工作目录设置为hello/conf目录，然后创建bblayers.conf文件，使其包含以下内容：

   ::

      BBLAYERS ?= " \
         /home/<you>/mylayer \
      "

   您需要为文件中的提供自己的信息。

12. 运行BitBake并提供目标：

   现在您已经提供了bblayers.conf文件，运行bitbake命令并提供目标：

   ::

      $ bitbake printhello
      Loading cache: 100% |
      Loaded 0 entries from dependency cache.
      Parsing recipes: 100% |##################################################################################|
      Parsing of 1 .bb files complete (0 cached, 1 parsed). 1 targets, 0 skipped, 0 masked, 0 errors.
      NOTE: Resolving any missing task queue dependencies
      Initialising tasks: 100% |###############################################################################|
      NOTE: No setscene tasks
      NOTE: Executing Tasks
      ********************
      *                  *
      *  Hello, World!   *
      *                  *
      ********************
      NOTE: Tasks Summary: Attempted 1 tasks of which 0 didn't need to be rerun and all succeeded.

   .. note::

      在第一次执行后，再次运行 `bitbake printhello` 不会导致BitBake运行并打印相同的控制台输出。这是因为printhello.bb配方的do_build任务首次成功执行时，BitBake会为该任务写入一个标记文件。因此，下次您尝试使用相同的bitbake命令运行任务时，BitBake会注意到这个标记，从而确定任务不需要重新运行。如果您删除tmp目录或运行 `bitbake -c clean printhello` 然后重新运行构建，将再次打印“Hello,World!”消息。
