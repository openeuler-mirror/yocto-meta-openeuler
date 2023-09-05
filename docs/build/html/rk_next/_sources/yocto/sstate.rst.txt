.. _yocto_sstate:

share state 机制
====================

简要介绍share state（简写为sstate）原理与使用。

sstate 原理
###################

yocto默认继承了sstate类，sstate机制将SSTATETASKS定义的任务指定的文件目录生成压缩包（缓存）以供后续复用。构建时存在sstate缓存且任务校验和没有发生改变，则会执行对应的task_setscene任务解压压缩包得到输出文件；如果相关任务校验和改变了，则需要重新获取源码进行编译。

校验和：每一个执行的任务都会存在一个校验和用于判断是否需要重新构建。基础hash（直接输入到任务的内容信息）与依赖任务的hash生成总的校验和，根据该值变化决定是否复用缓存。可以通过查看SSTATE_DIR目录下的siginfo文件名来查看校验和。

相关字节：

.. code-block::

    SSTATE_DIR：指向共享缓存所在目录，默认为"${TOPDIR}/sstate-cache"；
    SSTATE_MIRRORS：共享缓存镜像机制，可以从镜像指定位置实时获取缓存；
    BB_HASHEXCLUDE_COMMON：一些不被计算到hash值的公共变量，参与组成其他字节；
    BB_BASEHASH_IGNORE_VARS：列出从校验和和相关性数据中排除的变量；由BB_HASHEXCLUDE_COMMON和其他值组成；
    BB_HASHCONFIG_WHITELIST：列出从基本配置校验和中排除的变量；由BB_HASHEXCLUDE_COMMON和其他值组成；
    BB_SIGNATURE_EXCLUDE_FLAGS：一些不被计算到hash值的公共变量标志，如果是任务标志，则 prefuncs、postfuncs、exports 等会对hash值有影响；具体要分析底层python脚本。
    vardepsexclude与vardeps标志：使字节或任务计算校验和时不依赖或依赖对应变量。

BB_HASHEXCLUDE_COMMON是BB_BASEHASH_IGNORE_VARS和BB_HASHCONFIG_WHITELIST的公共组成部分，因此可以修改BB_HASHEXCLUDE_COMMON对两者同时产生影响。



sstate 缓存复用机制
###########################

缓存指sstate-cache目录下的*.tgz文件，构建时存在对应的tgz文件且校验和不变时则执行对应的task_setsecne任务；sstate-cache目录下还存在*.siginfo文件，目前测试来看该文件只是提供了一种检测校验和的手段，即使不存在也不会使缓存不能使用；每个执行任务都存在一个siginfo文件。

.. note::

    do_build任务不存在siginfo文件。

构建linux-openeuler(arm-std)，总共执行了59个任务。通过查看日志信息，只执行了54个任务；查看SSTATE_DIR目录，存在54份siginfo文件；其余5个任务应该是每个依赖包的do_build任务，不存在相应的siginfo文件。

.. code-block::

    $ bitbake linux-openeuler -g  //生成linux-openeuler依赖信息
    $ cat pn-buildlist //查看依赖的包

以下是linux-openeuler（arm-std）及其所有依赖包的任务数与siginfo文件数：

.. code-block::

    linux-openeuler：22任务与siginfo文件；
    pseudo-native：9任务与siginfo文件；
    binutils：7任务与siginfo文件；
    gcc-cross-arm：7任务与siginfo文件；
    depmodwrapper：9任务与siginfo文件；

任务数与siginfo文件数一致且对应，符合每个执行任务都有一份对应的siginfo文件提供校验信息。



开发者自定义 sstate 任务方式
##################################

举例说明如何定义sstate任务。

.. code-block::

    SSTATETASKS += "do_test_sstate"  //声明为sstate任务
    do_test_sstate () {
        // 开发者可自定义此测试任务
        touch a.txt
        ln -s ./a.txt ./b.txt
        echo ${D}${includedir} >> b.txt
    }

    do_test_sstate[dirs] = "${WORKDIR}/test_in" //工作目录
    do_test_sstate[sstate-inputdirs] = "${WORKDIR}/test_in"  //缓存输入目录
    do_test_sstate[sstate-outputdirs] = "${WORKDIR}/test_out"  //拷贝缓存输入内容到此目录
    # do_test_sstate[sstate-plaindirs] = "${WORKDIR}/test_in" //上述两目录相同时定义方式

    addtask do_test_sstate after do_fetch before do_patch  //声明任务执行顺序

    python do_test_sstate_setscene () {
        sstate_setscene(d)  //复用缓存
    }
    addtask do_test_sstate_setscene  //定义缓存复用任务，以task + _setscene命名

开发者可在poky查看更多sstate任务例子。



sstate 使用方法
##############################

此处推荐3种使用方法，如下：

1、拷贝上一次构建成功的sstate-cache目录到当前构建目录下；

.. code-block::

    $ cp -r buildA/sstate-cache buildB/sstate-cache //buildA为已成功构建的目录，buildB为刚刚完成初始化的构建目录
    $ cd buildB
    $ bitbake package_name  //构建所需包

利用sstate_mirrors机制，可以做到根据需求获取缓存，首先把已成功构建的缓存放在公共服务器上。

2、开发者使用网络在线获取缓存；会受到网络因素影响，可能会出现随机性的错误，当前暂不使用；需在local.conf脚本添加如下内容：

.. code-block::
    
    # 服务器链接地址
    SSTATE_MIRRORS ?= "file://.* http://someserver.tld/share/sstate/PATH;downloadfilename=PATH"

3、开发者下载缓存到本地路径；缺点是当开发者只需要某一部分缓存时也会把全部的缓存下载下来，造成资源浪费；需在local.conf脚本添加如下内容：

.. code-block::
    
    # 本地绝对路径
    SSTATE_MIRRORS ?= "file://.* file:///some/local/dir/sstate/PATH"

| 方案1与方案3的差异是什么？
| **a:** 方案1的做法是拷贝缓存到当前构建目录，当再次构建时会对该缓存产生影响；方案3的做法不会对下载缓存产生影响，只是在构建时会去检查下载缓存目录是否存在所需的缓存，如果存在则拷贝到当前构建缓存目录，不存在则重新构建。



sstate 使用效果
########################

这里举几个简单例子说明缓存的效果，开发者可自行测试。

例1：使用 -c clean 将任务的输出文件删除，但不删除缓存；再重新构建，这个过程会特别迅速，这就是因为存在缓存。

.. code-block::

    $ bitbake pseudo-native  //构建pseudo-native成功
    $ bitbake pseudo-native -c clean
    $ bitbake pseudo-native

例2：使用 -c cleansstate 会在 clean 的基础上把缓存也删掉。

.. code-block::

    $ bitbake pseudo-native  //构建pseudo-native成功
    $ bitbake pseudo-native -c cleansstate
    $ bitbake pseudo-native

例3： 使用 --no-setscene 选项不使用缓存构建。

.. code-block::

    $ bitbake pseudo-native  //构建pseudo-native成功
    $ bitbake pseudo-native -c clean
    $ bitbake pseudo-native --no-setscene  //不使用缓存构建



sstate应用过程中解决的疑难问题
#################################

在初步复用sstate的过程中，总是频繁触发重新构建，最初定位是工具链缓存复用的问题，通过使用bitbake-diffsigs工具具体定位到是工具链gcc-runtime-external包构建时的do_install任务在postfuncs标志下的do_install:appended任务的校验和会随着构建目录改变而改变。
根因是gcc-runtime-external的一个匿名函数使用replace函数修改了do_install:appended的内容导致校验和会随构建目录改变而改变，当前只能让do_install任务的校验和不受do_install:appended影响以复用缓存。



开发者可能关心的问题
#################################

| 1、构建目录改变是否会重新构建？yocto仓源码目录改变是否会重新构建？工具链目录改变是否会重新构建？
| **a:** 前两种情况下校验和不会改变，因此不会触发重新构建；工具链目录改变会触发重新构建，工具链sysroot的文件一般是一些wrapper脚本，指向工具链目录下的文件，因此当工具链目录改变了需要重新生成wrapper脚本。

| 2、缓存是否能在不同类型的构建主机复用？如openeuler主机构建时生成的缓存能否在ubuntu主机复用？
| **a:** 暂不支持复用；poky使用了uninative机制让生成的缓存与构建环境无关，构建时首先会下载uninative包到本地，从而做到native包构建与构建机器无关。

| 3、单任务执行是否会重新构建？
| **a:** 分情况，

.. code-block::

    bitbake zlib -c configure
    bitbake zlib -c populate_sysroot

这两个任务的差异是populate_sysroot为sstate任务，存在缓存，而configure任务非sstate任务，只存在siginfo文件；因此populate_sysroot任务不会重新构建，而configure会重新构建。

| 4、只存在指定软件包的缓存是否可用？
| **a:** 不可用，经验证发现会重新执行部分流程，包括compile任务；以下是只存在libpcre2的缓存情况下的任务执行顺序：

.. code-block::

    $ bitbake libpcre2 
    $ cd WORKDIR_of_libpcre2/temp //日志所在目录
    $ cat log.task_order
    do_package_qa_setscene (3924912): log.do_package_qa_setscene.3924912
    do_populate_lic_setscene (3924914): log.do_populate_lic_setscene.3924914
    do_package_write_rpm_setscene (3924913): log.do_package_write_rpm_setscene.3924913
    do_populate_sysroot_setscene (3924915): log.do_populate_sysroot_setscene.3924915
    do_packagedata_setscene (3925129): log.do_packagedata_setscene.3925129
    do_deploy_source_date_epoch_setscene (3925173): log.do_deploy_source_date_epoch_setscene.3925173
    do_fetch (3925748): log.do_fetch.3925748
    do_unpack (3926514): log.do_unpack.3926514
    do_patch (3927219): log.do_patch.3927219
    do_prepare_recipe_sysroot (3970565): log.do_prepare_recipe_sysroot.3970565
    do_configure (3970676): log.do_configure.3970676
    do_compile (3979602): log.do_compile.3979602
    do_install (3989915): log.do_install.3989915
    do_package (3990522): log.do_package.3990522

结论是某些任务使用了缓存，但是package任务没有使用缓存，导致重新编译；经过一些测试发现需要依赖任务的populate_sysroot任务执行结束，再执行构建才不会重新构建。
