.. _openeuler_src_uri_remove:


OPENEULER_SRC_URI_REMOVE
========================

在我们开发过程中，在添加新包时总是需要替换成openEuler源的包，并且在manifest.yaml基线文件中添加该包的基线信息，openEuler Embedded的包下载方式是预先下载然后以本地文件方式引入，即在do_fetch前将包下载好，然后在SRC_URI中以 `file://` 方式将源码包引入，此时我们就需要将上游原bb文件中指向远程地址的链接去除，本文即为介绍如何快速去除上游原远程链接。

OPENEULER_SRC_URI_REMOVE的使用
******************************

该变量应用在bb/bbappend文件中，如果需要移除某些远程链接，只需要将远程链接的协议在该变量中设置即可。以下是一个范例：

上游audit.bb文件的SRC_URI是这样的

.. code:: 

    SRC_URI = "git://github.com/linux-audit/${BPN}-userspace.git;branch=master;protocol=https \
           file://Fixed-swig-host-contamination-issue.patch \
           file://0001-Replace-__attribute_malloc__-with-__attribute__-__ma.patch \
           file://auditd \
           file://auditd.service \
           file://audit-volatile.conf \
    "

那么在audit.bbappend文件中SRC_URI是这样设置的

.. code:: 

    OPENEULER_SRC_URI_REMOVE = "git"

    SRC_URI += " \
        file://audit-${PV}.tar.gz \
        file://bugfix-audit-support-armv7b.patch \
        file://bugfix-audit-userspace-missing-syscalls-for-aarm64.patch \
        file://bugfix-audit-reload-coredump.patch \
        file://audit-Add-sw64-architecture.patch \
        file://auditd.conf \
        file://audit.rules \
        file://backport-auditswig.i-avoid-setter-generation-for-audit_rule_d.patch \
        "

从以上的改动可以看到，即使将 `git://github.com/linux-audit/${BPN}-userspace.git;branch=master;protocol=https`改为 `file://audit-${PV}.tar.gz`
并没有使用

.. code:: 

    SRC_URI:remove += "git://github.com/linux-audit/${BPN}-userspace.git;branch=master;protocol=https"

而是直接用 `OPENEULER_SRC_URI_REMOVE = "git"`，这也是我们推荐的做法。

.. note:: 

    一旦设置了那么针对该协议的远程链接都将不再生效，意思是如果SRC_URI中有两个远程链接都是以https开头，如果希望某个远程链接生效，那么还是需要用remove来移除指定的远程链接，这样就不会影响其他的远程链接。

该变量的处理是在openeuler.bbclass中以匿名函数进行的，因此在解析阶段会将SRC_URI的值处理好，因此其作用域是构建全流程的，以下是其处理代码，打开yocto-meta-openeuler/meta-openeuler/classes/openeuler.classes

.. code:: 

    # src_uri_set is used to remove some URLs from SRC_URI through
    # OPENEULER_SRC_URI_REMOVE, because we don't want to download from
    # these URLs
    python () {
        if d.getVar('OPENEULER_SRC_URI_REMOVE'):
            REMOVELIST = d.getVar('OPENEULER_SRC_URI_REMOVE').split(' ')
            URI = []
            for line in d.getVar('SRC_URI').split(' '):
                URI.append(line)
                for removeItem in REMOVELIST:
                    if line.strip().startswith(removeItem.strip()):
                        URI.pop()
                        break
            URI = ' '.join(URI)
            d.setVar('SRC_URI', URI)
    }
