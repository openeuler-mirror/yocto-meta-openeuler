.. _command_index_generate:

构建文件生成命令-generate
##############################

该命令用于创建构建目录并生成构建配置文件。oebuild在镜像构建这一块儿的思想是通过一份配置文件来实现对镜像的定制化构建。每一个定制镜像都会创建一个特有的构建目录，在该目录下存放着关于该定制镜像所有有关的构建产物以及其相应的构建相关文件，构建相关文件包含构建配置文件和构建环境文件，前者用于对镜像进行定制，后者用于对构建运行环境进行记录。

该命令参数较多，使用范例如下：

.. code-block:: console

    oebuild generate [options]

其中options为各项参数，以下将详细介绍generate命令参数如何使用及其作用。

.. _b_in:

-b_in: build_in
---------------

该参数用于指定构建方式，oebuild对openEuler Embedded的构建方式有两种，分别是主机端构建和容器端构建，默认采用容器端构建，因为容器内已有openEuler Embedded的构建所需要的所有辅助工具，因此对于容器构建openEuler Embedded来说，不需要额外的准备环境，而对于主机端构建来说，则需要额外指定构建openEuler Embedded所需要的辅助工具。该命令有两个可选参数值，分别是host和docker，对应的表示主机端构建和容器端构建。

选定主机端构建命令如下：

.. code-block:: console

    oebuild generate -b_in host

选定容器端构建命令如下：

.. code-block:: console

    oebuild generate -b_in docker

-l: list
--------

该参数用于列出当前openEuler Embedded版本支持的单板以及特性，用于在生成构建配置文件时对单板名称以及特性并不熟悉的情况下，通过该命令参数获取相关的单板与特性名称，而oebuild对于openEuler Embedded的单板列表与特性列表的识别是从yocto-meta-openeuler的oebuild配置目录下识别出来的，在 `yocto-meta-openeuler/.oebuild/platform` 目录下存放着openEuler Embedded支持的单板配置文件，配置文件的命名以该单板名称为准，因此oebuild列出的单板列表就是该目录下的内容。同样，对于特性列表来说，在 `yocto-meta-openeuler/.oebuild/feature` 目录下也存放着openEuler Embedded支持的特性配置文件，配置文件的命名以该特性名称为准，使用范例如下：

列出openEuler Embedded支持的单板与特性列表：

.. code-block:: console

    oebuild generate -l

值得注意的是，特性的列出会显示每个特性支持的单板，用suport arch来表示，用|来进行分割

-p: platform
------------

该参数用于指定构建的单板名称，每个定制的镜像必须指定单板名称，也可以不指定，不指定时该参数默认为qemu-aarch64，需要注意的是单板是单选参数，使用范例如下：

.. code-block:: console

    oebuild generate -p qemu-aarch64
    oebuild generate -p ok3568
    ...

-f: feature
-----------

该参数用于指定构建的特性名称，该参数没有默认值，如果不指定，则表示的是openEuler Embedded默认的标准镜像，使用范例如下：

.. code-block:: console

    oebuild generate -f clang
    oebuild generate -f openeuler-mcs
    ...

.. note:: 

    需要注意的是，特性指定参数是多值赋值，因此可以指定多个，例如：
    
    .. code-block:: console
        
        oebuild generate -f systemd -f openeuler-qt
     

-s: sstate-mirrors
------------------

该参数用于指定该次编译sstate-cache的应用镜像在哪里。在这里简要介绍一下sstate-cache，在yocto中，sstate-cache是用于加速构建过程的一种机制，它可以缓存已经构建过的软件包，以便在后续的构建过程中可以直接使用这些缓存，而不是重新编译这些软件包。具体来说，sstate-cache会将已经构建过的软件包的二进制文件、头文件、库文件打包存储在一个目录中。当需要重新构建某个软件包时，yocto会首先检查sstate-cache中是否已经存在该软件包的的缓存，如果存在，那直接使用缓存中的文件，而不需要重新编译。这种机制可以大大加快构建过程的速度，特别是在多次构建相同软件包的情况下。同时，sstate-cache还可以跨不同的构建机器共享，从而进一步提高构建效率。sstate-cache的指定有两种方式，一种是远程的web站点方式，一种是本地目录方式，使用方式如下：

指定远程站点的sstate-cache：

.. code-block:: console

    oebuild generate -s https://someserver.tld/share/sstate

指定本地目录的sstate-cache：

.. code-block:: console

    oebuild generate -s /some/local/dir/sstate

.. note::

    需要注意的是指定本地目录的sstate-cache在以容器端构建时会将该目录自动挂载到启动的容器下面，映射的容器目录地址为 `/usr1/openeuler/sstate-cache` 。

-s_dir: sstate_dir
------------------

该参数用于指定生成的sstate-cache存放目录，默认该参数是当前构建目录，但是一般在使用主机环境进行构建时才有效，主机环境构建设置该参数可以实时重复利用，如果在容器构建环境中设置该参数，则会将产生的sstate-cache存放在容器环境中，如果后期容器销毁，则该sstate-cache也会一并销毁。该命令参数使用方式如下：

.. code-block:: console

    oebuild generate -s_dir /some/local/dir/sstate

-m: tmp_dir
-----------------

该参数用于指定yocto中tmp_dir变量，在这里简要介绍一下tmp_dir，在yocto中，tmp_dir目录是一个临时目录，用于存储构建过程中生成的临时文件和中间文件。这个目录在构建过程中非常重要，因为它包含了构建过程中生成的所有文件，包括编译器、库、二进制文件、配置文件等等。在构建过程中，yocto会将所有的源代码、配置文件等文件复制到tmp_dir目录中，并在这个目录中执行编译、链接等操作，这样做的好处是可以避免对原始代码的修改，同时也可以保证构建过程的可重复性。tmp_dir默认的目录是在当下构建目录下，在构建完成后，tmp_dir目录可以被删除，因为它只包含了构建过程中生成的临时文件和中间文件，不会对系统的正常运行产生影响。该命令参数使用方式如下：

.. code-block:: console

    oebuild generate -m /some/local/tmp_dir

-t: toolchain_dir
-----------------

该参数用于指定gcc编译链目录，对于openEuler Embedded的构建来说，openEuler Embedded有自己的编译链，如果在外部进行构建需要使用指定的编译链，则可以使用该参数指定，但是需要注意的是，在使用主机端进行构建时该参数一定要指定，因为主机端并没有编译openEuler Embedded一切所需的辅助工具。该命令参数使用方式如下：

.. code-block:: console

    oebuild generate -t /some/local/aarch64le

.. note::

    需要注意的是指定本地编译链在以容器端构建时会将该目录自动挂载到启动的容器下面，映射的容器目录地址为`/usr1/openeuler/native_gcc`。

-n: nativesdk_dir
-----------------

该参数用于指定构建sdk目录，对于openEuler Embedded的构建来说，除了需要交叉编译链，还需要一些辅助工具，这些工具会在执行所有yocto构建任务过程中使用到，可以浅显的举个例子，在构建过程中，需要使用压缩工具unzip，因为涉及到源码的压缩格式为zip的情况下，在yocto的构建过程中需要调用unzip命令来对源码进行解压，但是unzip并不会进入到构建的镜像或产物当中，仅仅是充当构建过程中临时用到的工具而已。如果想要使用自己指定的构建sdk，则可以通过该参数进行指定。该命令参数使用方式如下：

.. code-block:: console

    oebuild generate -n /some/local/nativesdk_dir

.. note::

    需要注意的是，构建sdk的指定一定是要在主机端构建时才会生效，如果是在容器端进行构建，即使指定了该参数仍然是无效的，这是因为sdk一般是比较稳定的，所涉及的仅仅是中间的一些工具，而主机端构建则因为没有构建openEuler Embedded的一切辅助工具，因此需要指定nativesdk_dir，如果使用容器端进行构建，则不再需要，因为构建容器已经内置了构建openEuler Embedded所需的所有环境。关于如何使用主机端进行构建，请参考 :ref:`b_in` 参数。

-d: directory
-------------

该参数是用于指定构建目录，oebuild对openEuler Embedded的构建的原则是每一个特性镜像会有一个特有的构建目录，对于该目录的命名则通过该参数来确定。该命令参数使用方式如下：

.. code-block:: console

    oebuild generate -d build_dir

构建目录如果不指定时oebuild会默认使用platform来命名，例如如下的命令在执行后会自动创建qemu-aarch64构建目录：

.. code-block:: console

    oebuild generate -p qemu-aarch64

.. note::

    如果构建目录已经存在，则会将该目录下的compile.yaml进行覆盖，而不会提示该构建目录已存在。

-dt: datetime
-------------

该参数用于指定版本时间戳，用于设置在local.conf配置文件中的DATETIME变量，在这里简要介绍一下yocto中的DATETIME，在yocto中，local.conf是一个配置文件，用于设置构建系统的各种参数和选项。DATETIME变量是local.conf的一个变量，用于设置构建系统的日期和时间。具体来说，DATETIME变量用于指定构建系统的当前日期和时间，这个变量的值可以是一个固定的日期和时间，也可以是一个自动生成的日期和时间，如果DATETIME变量没有被设置，yocto将使用系统的当前日期和时间作为构建系统的日期和时间。为什么要设置该值呢，因为在构建系统中，DATETIME变量的值通常用于生成版本号和时间戳等信息，这些信息可以追踪软件的版本和构建时间，以及在调试和故障排除时提供有用的信息。该参数使用方法如下：

.. code-block:: console

    oebuild generate -dt 20240524075049

.. note::

    需要注意的是，该参数是为在同一构建目录下反复多次构建镜像时不再生成新的版本镜像。

-nf: no_fetch
--------------------

该参数用于确定在构建过程中是否禁止运行openeuler_fetch功能。在这里简要介绍一下openEuler Embedded中openeuler_fetch功能，openeuler_fetch是openEuler Embedded实现的在构建过程中对上游源码自动下载的功能，该功能会与manifest结合使用，即在构建某个软件包时，会先获取manifest中该包的git信息，然后使用该信息来进行对软件包的下载，如果用户已经下载好上游源码，想要离线编译，那么可以通过该参数来禁止openeuler_fetch功能的运行。该参数使用方法如下：

.. code-block:: console

    oebuild generate -nf

-ny: no_layer
--------------------

该参数用于在启动构建环境时是否更新layer层的代码仓，在构建由yocto执行任务的环境中，是需要提前准备好相关layer层的，否则会报错，oebuild在启动yocto构建环境时是会先更新依赖的layer层代码，如果在开发时并不需要更新layer层代码可以通过该参数进行屏蔽。

.. code-block:: console

    oebuild generate -ny

-y: yes
-----------

该参数表示接下来所有一切的交互都默认输入y，在这里主要应用在创建编译目录是存在同名目录时是否直接覆盖。

.. code-block:: console

    oebuild generate -y

--nativesdk
---------------------

该参数表示本次配置文件仅用于编译nativesdk

.. code-block:: console

    oebuild generate --nativesdk

--gcc
------

该参数表示本次配置文件仅用户编译gcc交叉编译链

.. code-block:: console

    oebuild generate --gcc

--gcc_name
-------------

该参数表示编译gcc编译链时选定的编译链类型，可以多选，但该参数必须是在选定--gcc时才有效。

.. code-block:: console

    oebuild generate --gcc --gcc_name aarch64 --gcc_name arm

--llvm
--------

该参数表示本次配置文件仅用户编译llvm交叉编译链

.. code-block:: console

    oebuild generate --llvm

--llvm_lib
-------------

该参数表示编译llvm编译链时其所依赖的gcc编译链地址，但该参数必须是在选定--llvm时才有效。

.. code-block:: console

    oebuild generate --llvm --llvm_lib /path/gcc/aarch64

--auto_build
---------------

该参数表示是否自动构建，该参数仅限于构建交叉编译链与nativesdk才有效。

.. code-block:: console

    oebuild generate --auto_build

当不输入任何参数时，会进入命令行菜单选择界面。

.. code-block:: console

    oebuild generate

具体界面如下图所示:

.. image:: ../../../_static/images/generate/oebuild-generate-select.png