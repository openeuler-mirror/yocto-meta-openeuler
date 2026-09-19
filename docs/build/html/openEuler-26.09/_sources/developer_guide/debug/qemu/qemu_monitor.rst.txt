.. _qemu_monitor:

QEMU控制台
##########

QEMU控制台，即QEMU monitor，是在QEMU模拟器运行时为其提供各种有用功能模块的工具，可以在比如调试时得到意想不到的帮助。在QEMU模拟器启动后，通过ctrl +a + c的操作序列进入。

.. code-block:: console

   (qemu)

在操作后即为如图所示的样子，会显示(QEMU)的字样。在这个时候，有各种命令可以使用。使用help命令，即可以看到所有支持的命令(下面的图只是示例，并不包含全部内容)

.. code-block:: console

   acl_add aclname match allow|deny [index] -- add a match rule to the access control list
   acl_policy aclname allow|deny -- set default access control list policy
   acl:remove aclname match -- remove a match rule from the access control list
   acl_reset aclname -- reset the access control list
   acl_show aclname -- list rules in the access control list
   announce_self [interfaces] [id] -- Trigger GARP/RARP announcements
   balloon target -- request VM to change its memory allocation (in MB)
   block_job_cancel [-f] device -- stop an active background block operation (use -f
            if you want to abort the operation immediately
            instead of keep running until data is in sync)
   block_job_complete device -- stop an active background block operation
   block_job_pause device -- pause an active background block operation
   block_job_resume device -- resume a paused background block operation
   block_job_set_speed device speed -- set maximum speed for a background block operation
   block_passwd block_passwd device password -- set the password of encrypted block devices
   block_resize device size -- resize a block image
   block_set_io_throttle device bps bps_rd bps_wr iops iops_rd iops_wr -- change I/O throttle limits for a block drive
   block_stream device [speed [base]] -- copy data from a backing file into a block device
   boot_set bootdevice -- define new values for the boot device list
   change device filename [format [read-only-mode]] -- change a removable medium, optional format
   chardev-add args -- add chardev
   chardev-change id args -- change chardev
   chardev-remove id -- remove chardev
   chardev-send-break id -- send a break on chardev
   client_migrate_info protocol hostname port tls-port cert-subject -- set migration information for remote display
   closefd closefd name -- close a file descriptor previously passed via SCM rights
   commit device|all -- commit changes to the disk images (if -snapshot is used) or backing files
   cpu index -- set the default CPU
   cpu-add id -- add cpu (deprecated, use device_add instead)
   c|cont  -- resume emulation
   delvm tag -- delete a VM snapshot from its tag
   device_add driver[,prop=value][,...] -- add device, like -device on the command line
   device_del device -- remove device
   drive_add [-n] [[<domain>:]<bus>:]<slot>
   [file=file][,if=type][,bus=n]
   [,unit=m][,media=d][,index=i]
   [,snapshot=on|off][,cache=on|off]
   [,readonly=on|off][,copy-on-read=on|off] -- add drive to PCI storage controller
   drive_backup [-n] [-f] [-c] device target [format] -- initiates a point-in-time
            copy for a device. The device's contents are
            copied to the new image file, excluding data that
            is written after the command is started.
            The -n flag requests QEMU to reuse the image found
            in new-image-file, instead of recreating it from scratch.
            The -f flag requests QEMU to copy the whole disk,
            so that the result does not need a backing file.
            The -c flag requests QEMU to compress backup data
            (if the target format supports it).

   drive_del device -- remove host block device
   ...

使用help [命令]的方式，可以看到某个具体命令的使用说明。

本篇文章会介绍几个调试过程中相对较为常用的控制台命令，希望对开发、定位问题能有所帮助。

1、Info
********

Info顾名思义，是查看这个启动的虚拟机相关的各项信息的一个命令。它本身又是一套命令的合集，可以查看虚拟机相关的很多方面。使用help info，可以看到如下图所示的所有可用的info命令(下面的图只是示例，并不包含info的全部内容)。

.. code-block:: console

   info migrate  -- show migration status
   info migrate_cache_size  -- show current migration xbzrle cache size
   info migrate_capabilities  -- show current migration capabilities
   info migrate_parameters  -- show current migration parameters
   info mtree [-f][-d][-o] -- show memory tree (-f: dump flat view for address spaces;-d: dump dispatch tree, valid with -f only);-o: dump region owners/parents
   info name  -- show the current VM name
   info network  -- show the network state
   info numa  -- show NUMA information
   info opcount  -- show dynamic compiler opcode counters
   info pci  -- show PCI info
   info pic  -- show PIC state
   info profile  -- show profiling information
   info qdm  -- show qdev device model list
   info qom-tree [path] -- show QOM composition tree
   info qtree  -- show device tree
   info ramblock  -- Display system ramblock information
   info rdma  -- show RDMA state
   info registers [-a] -- show the cpu registers (-a: all - show register info for all cpus)
   info rocker name -- Show rocker switch
   info rocker-of-dpa-flows name [tbl_id] -- Show rocker OF-DPA flow tables
   info rocker-of-dpa-groups name [type] -- Show rocker OF-DPA groups
   info rocker-ports name -- Show rocker ports
   info roms  -- show roms
   info snapshots  -- show the currently saved VM snapshots
   info status  -- show the current VM status (running|paused)
   info sync-profile [-m] [-n] [max] -- show synchronization profiling info, up to max entries (default: 10), sorted by total wait time. (-m: sort by mean wait time; -n: do not coalesce objects with the same call site)
   info tpm  -- show the TPM device
   info trace-events [name] [vcpu] -- show available trace-events & their state (name: event name pattern; vcpu: vCPU to query, default is any)
   info usb  -- show guest USB devices
   info usbhost  -- show host USB devices
   info usernet  -- show user network stack connection states
   info uuid  -- show the current VM UUID
   info version  -- show the version of QEMU
   info vm-generation-id  -- Show Virtual Machine Generation ID
   info vnc  -- show the vnc server status

这里比较常用的，如

- （1）可以查看物理地址空间结构的info mtree。任何一次QEMU模拟器的system级运行都可以理解为QEMU构建了一块完整的虚拟单板，而通过info mtree，可以看到这块虚拟单板的物理地址空间布局。

.. code-block:: console

   0000000000000000-ffffffffffffffff (prio 0, i/o): system
   0000000000000000-0000000003ffffff (prio 0, romd): virt.flash0
   0000000004000000-0000000007ffffff (prio 0, romd): virt.flash1
   0000000008000000-0000000008000fff (prio 0, i/o): gic_dist
   0000000008010000-0000000008011fff (prio 0, i/o): gic_cpu
   0000000008020000-0000000008020fff (prio 0, i/o): gicv2m
   0000000009000000-0000000009000fff (prio 0, i/o): pl011
   0000000009010000-0000000009010fff (prio 0, i/o): pl031
   0000000009020000-0000000009020007 (prio 0, i/o): fwcfg.data
   0000000009020008-0000000009020009 (prio 0, i/o): fwcfg.ctl
   0000000009020010-0000000009020017 (prio 0, i/o): fwcfg.dma
   0000000009030000-0000000009030fff (prio 0, i/o): pl061
   000000000a000000-000000000a0001ff (prio 0, i/o): virtio-mmio
   000000000a000200-000000000a0003ff (prio 0, i/o): virtio-mmio
   000000000a000400-000000000a0005ff (prio 0, i/o): virtio-mmio
   000000000a000600-000000000a0007ff (prio 0, i/o): virtio-mmio
   000000000a000800-000000000a0009ff (prio 0, i/o): virtio-mmio
   000000000a000a00-000000000a000bff (prio 0, i/o): virtio-mmio

- （2）可以查看物理地址空间所有外设相关信息的info qtree。比起info mtree重点放在地址空间布局上，info qtree更注重每个外设本身的一些信息，如有多少mmio空间、数据位宽、中断个数等

.. code-block:: console

   bus: main-system-bus
   type System
   dev: platform-bus-device, id "platform-bus-device"
      gpio-out "sysbus-irq" 64
      num_irqs = 64 (0x40)
      mmio_size = 33554432 (0x2000000)
      mmio ffffffffffffffff/0000000002000000
   dev: fw_cfg_mem, id ""
      data_width = 8 (0x8)
      dma_enabled = true
      x-file-slots = 32 (0x20)
      mmio 0000000009020008/0000000000000002
      mmio 0000000009020000/0000000000000008
      mmio 0000000009020010/0000000000000008
   dev: virtio-mmio, id ""
      gpio-out "sysbus-irq" 1
      format_transport_address = true
      force-legacy = true
      mmio 000000000a003e00/0000000000000200
      bus: virtio-mmio-bus.31
         type virtio-mmio-bus

- （3）可以查看有多少个cpu的info cpus。前面有*标志的cpu表示当前的cpu。使用cpu [cpu号]的命令，可以切换到某个其他的cpu上面。当前cpu表示正在观察的cpu，如info registers操作（后面会讲），如果不使用info registers -a，默认只会打印当前cpu的寄存器信息。

.. code-block:: console

   * CPU #0: thread_id=3639
     CPU #1: thread_id=3640
     CPU #2: thread_id=3641
     CPU #3: thread_id=3642

- （4）可以查看每个模拟cpu的寄存器信息的info registers

.. code-block:: console

   PC=ffffffc0104d16c0 X00=0000000000000000 X01=ffffffc010730000
   X02=ffffffc01075e340 X03=0000000000048600 X04=ffffff8007f82508
   X05=0000000000000000 X06=ffffff8007f82370 X07=0000000000000004
   X08=ffffffc01075ed30 X09=ffffffc010753e20 X10=0000000000000990
   X11=0000000000000000 X12=0000000000000000 X13=0000000000000000
   X14=0000000000000000 X15=0000000000000000 X16=0000000000000000
   X17=0000000000000000 X18=0000000000000000 X19=ffffffc010730000
   X20=ffffffc010758000 X21=0000000000000000 X22=ffffffc010758740
   X23=0000000000000001 X24=ffffffc0107587c0 X25=ffffffc01073fe40
   X26=ffffffc010720004 X27=00000000400800f0 X28=00000000406e0018
   X29=ffffffc010753ea0 X30=ffffffc0104d16d8  SP=ffffffc010753ea0
   PSTATE=40000085 -Z-- EL1h     FPCR=00000000 FPSR=00000000
   Q00=0000000000000000:0000000000000000 Q01=00000073252f7325:0000000000732520
   Q02=20746e697270206f:742064656c696146 Q03=ffffff0000000000:ffffffffff000000
   Q04=0000000000000000:0000000000000000 Q05=4010040040000001:4010040140000400
   Q06=0000000000000000:0000000000000000 Q07=4010040140100401:4010040140100401
   Q08=0000000000000000:41cdcd6500000000 Q09=0000000000000000:0000000000000000
   Q10=0000000000000000:0000000000000000 Q11=0000000000000000:0000000000000000
   Q12=0000000000000000:0000000000000000 Q13=0000000000000000:0000000000000000
   Q14=0000000000000000:0000000000000000 Q15=0000000000000000:0000000000000000
   Q16=0000000054415544:0000000054415544 Q17=0000000000000000:00000000a8000000
   Q18=0000000000000000:0000000000000000 Q19=0000000000000000:0000000000000000
   Q20=0000000000000000:0000000000000000 Q21=0000000000000000:0000000000000000
   Q22=0000000000000000:0000000000000000 Q23=0000000000000000:0000000000000000
   Q24=0000000000000000:0000000000000000 Q25=0000000000000000:0000000000000000
   Q26=0000000000000000:0000000000000000 Q27=0000000000000000:0000000000000000
   Q28=0000000000000000:0000000000000000 Q29=0000000000000000:0000000000000000
   Q30=0000000000000000:0000000000000000 Q31=0000000000000000:0000000000000000

Info还有许许多多功能，这里不再一一列举了，大家可以直接在QEMU monitor中使用help info查看全部命令。

2、x/xp命令
********************

QEMU monitor控制台很多时候可用于调试，所以有时需要打印各种地址上的内容。x和xp的功能相辅相成，一个可以通过物理地址打印内容，一个可以通过虚拟地址打印内容。用法和gdb中的x命令是相同的，但是gdb并不能看到某个进程使用了哪些物理地址，所以没有能够打印物理地址中内容的xp功能。

x/xp命令结合前面可以切换cpu的命令，可以打印在任何虚拟核心角度的，任意的地址里面的内容。

.. code-block:: console

   (qemu) x/32wx 0xffffffc0104d16c0
   ffffffc0104d16c0: 0xd50323bf 0xd65f03c0 0xd503233f 0xa9bf7bfd
   ffffffc0104d16d0: 0x910003fd 0x97fffff8 0xa8c17bfd 0xd50323bf
   ffffffc0104d16e0: 0xd65f03c0 0xd503233f 0xa9bf7bfd 0x910003fd
   ffffffc0104d16f0: 0x97fffff6 0xd2801c00 0xd50342ff 0xa8c17bfd
   ffffffc0104d1700: 0xd50323bf 0xd65f03c0 0xd5184600 0xd503233f
   ffffffc0104d1710: 0xa9bc7bfd 0xd5384101 0x910003fd 0xa90153f3
   ffffffc0104d1720: 0xaa0003f4 0xa9025bf5 0xa90363f7 0xb9401020
   ffffffc0104d1730: 0xf9401035 0x11000400 0xb9001020 0xf00012e2
   (qemu) xp/32wx 0x404d2780
   00000000404d2780: 0xd503233f 0xa9bd7bfd 0x910003fd 0xa90153f3
   00000000404d2790: 0x90001873 0xa9025bf5 0x913b2273 0x90000136
   00000000404d27a0: 0x90001875 0x911782d6 0x913a02b5 0xd2800014
   00000000404d27b0: 0x94000792 0xd1012260 0xf8747ac1 0xf900301f
   00000000404d27c0: 0x91000694 0xf9000275 0xf9001a61 0x29087e7f
   00000000404d27d0: 0xb9044a7f 0x940007ab 0x91160273 0xf100129f
   00000000404d27e0: 0x54fffea1 0xa94153f3 0xa9425bf5 0xa8c37bfd
   00000000404d27f0: 0xd50323bf 0xd65f03c0 0xd503233f 0xa9be7bfd

3、savevm/loadvm命令
********************

savevm和loadvm两个命令可以当QEMU模拟器运行到某个状态时，将当前的整个内存中的镜像的状态保存和恢复到一个磁盘文件中。类似于大部分现代操作系统自带的hibernate和恢复的功能。savevm是保存镜像到磁盘文件，loadvm是从磁盘文件中加载一个之前保存过得磁盘镜像恢复出来。savevm的用法如下：
  - 首先在QEMU运行之前，通过qemu-img 的create命令，创建一个磁盘文件，磁盘文件必须是qcow2格式而不能是raw格式，因为raw格式的镜像不支持savevm/loadvm功能。如下面的命令，即创建了一个2G大小的，格式为qcow2，名为imagedisk的磁盘文件。

   .. code-block:: console

      qemu-img create -f qcow2 imagedisk 2G


  - 在QEMU启动参数中，加上-hda [磁盘文件名]，如-hda imagedisk。以此告知QEMU模拟器使用hda参数指明的磁盘文件来保存磁盘镜像。

   .. code-block:: console

      ./qemu-4.2.1/aarch64-softmmu/qemu-system-aarch64 \
        -M virt-4.0 \
        -cpu cortex-a57 \
        -smp 4 \
        -nographic \
        -kernel $KERNEL \
        -initrd $INITRD \
        -hda imagedisk

  - 这样一来，当QEMU运行的时候，就可以随时将当前状态通过savevm [tag]命令保存到imagedisk磁盘文件中了。[tag]可以自己决定，只是为镜像起一个名字，如savevm img0。在保存后，使用info snapshots命令即可以看到所有保存的磁盘镜像。

   .. code-block:: console

      (qemu) info snapshots
      List of snapshots present on all disks:
      ID        TAG                     VM SIZE                DATE       VM CLOCK
      --        img0                   57.3 MiB 2022-03-16 01:50:22   00:00:26.950

   - 在保存镜像至磁盘文件后，只要后面启动的时候在参数-hda后面带上这个磁盘文件，即可以通过loadvm [tag]的方式恢复保存的镜像，并回到保存时的机器状态进行使用了。

4、gva2gpa/gpa2hpa/gpa2hva
***************************

在调试裸机程序或者内核的时候，可能经常需要知道某块虚拟内存对应的物理地址，从而进行操作，在QEMU中，模拟器中guest的虚拟地址叫做gva，物理地址叫做gpa。而gva和gpa之间的转换关系在有些时候是很利于调试的。QEMU的monitor控制台提供了gva2gpa这个功能，让我们能把一个gva转换为对应的gpa。同时，还提供了gpa2hpa，gpa2hva两个功能，让我们可以将gpa转换为物理机眼中的物理地址或者虚拟地址，在需要的时候可以使用。

.. code-block:: console

   (qemu) gva2gpa 0xffffffc0104d16c0
   gpa: 0x404d16c0
