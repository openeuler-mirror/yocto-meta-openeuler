/*
 * Jailhouse, a Linux-based partitioning hypervisor
 * Root cell configuration for qemu
 * Created by resource-tool
 */

#include <jailhouse/types.h>
#include <jailhouse/cell-config.h>

struct {
    struct jailhouse_system header;
    __u64 cpus[1];
    struct jailhouse_memory mem_regions[17];
    struct jailhouse_irqchip irqchips[1];
    struct jailhouse_pci_device pci_devices[1];
} __attribute__((packed)) config = {
    .header = {
        .signature = JAILHOUSE_SYSTEM_SIGNATURE,
        .revision = JAILHOUSE_CONFIG_REVISION,
        .flags = JAILHOUSE_SYS_VIRTUAL_DEBUG_CONSOLE,
        .hypervisor_memory = {
            .phys_start = 0x80000000,
            .size =       0x1000000,
        },
        .debug_console = {
            .address = 0x9000000,
            .size = 0x1000,
            /* TODO */
            .type = JAILHOUSE_CON_TYPE_PL011,
            .flags = JAILHOUSE_CON_ACCESS_MMIO | JAILHOUSE_CON_REGDIST_4,
        },
        .platform_info = {
            .pci_mmconfig_base = 0x10000000,
            .pci_mmconfig_end_bus = 0x0,
            .pci_is_virtual = 1,
            .pci_domain = 1,

            .arm = {
                .gic_version = 3,
                .gicd_base = 0x8000000,
                .gicr_base = 0x80a0000,
                .gicc_base = 0x8100000,
                .gich_base = 0x8030000,
                .gicv_base = 0x8040000,
                .maintenance_irq = 25,
            },
        },
        .root_cell = {
            .name = "qemu",

            .cpu_set_size = sizeof(config.cpus),
            .num_memory_regions = ARRAY_SIZE(config.mem_regions),
            .num_irqchips = ARRAY_SIZE(config.irqchips),
            .num_pci_devices = ARRAY_SIZE(config.pci_devices),

            .vpci_irq_base = 100,
        },
    },

    .cpus = {
        // CPU count: cpu['count']
        0x000000000000000f
    },

    .mem_regions = {
        /* IVSHMEM regions */
        {
            .phys_start = 0x81000000,
            .virt_start = 0x81000000,
            .size       = 0x1000,  // 4.0 KB
            .flags      = JAILHOUSE_MEM_READ,
        },
        {
            .phys_start = 0x81001000,
            .virt_start = 0x81001000,
            .size       = 0x1000,  // 4.0 KB
            .flags      = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE,
        },
        {
            .phys_start = 0x81002000,
            .virt_start = 0x81002000,
            .size       = 0x100000,  // 1024.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE,
        },
        {
            .phys_start = 0x81102000,
            .virt_start = 0x81102000,
            .size       = 0x100000,  // 1024.0 KB
            .flags = JAILHOUSE_MEM_READ,
        },

        /* system memory */
        {
            .phys_start = 0x40000000,
            .virt_start = 0x40000000,
            .size       = 0x80000000, // 2048.0 MB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_EXECUTE,
        },

        /*****************/
        /* Devices
         *****************/
        /* uart0 */
        {
            .phys_start = 0x9000000,
            .virt_start = 0x9000000,
            .size       = 0x1000, // 4.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* rtc */
        {
            .phys_start = 0x9010000,
            .virt_start = 0x9010000,
            .size       = 0x1000, // 4.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* fwcfg */
        {
            .phys_start = 0x9020000,
            .virt_start = 0x9020000,
            .size       = 0x1000, // 4.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* gpio */
        {
            .phys_start = 0x9030000,
            .virt_start = 0x9030000,
            .size       = 0x1000, // 4.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* suart */
        {
            .phys_start = 0x9040000,
            .virt_start = 0x9040000,
            .size       = 0x1000, // 4.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* pci */
        {
            .phys_start = 0x10000000,
            .virt_start = 0x10000000,
            .size       = 0x30000000,
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },

        /*****************/
        /* Regions
         *****************/
        /* smmu */
        {
            .phys_start = 0x9050000,
            .virt_start = 0x9050000,
            .size       = 0x20000, // 128.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* mmio */
        {
            .phys_start = 0xa000000,
            .virt_start = 0xa000000,
            .size       = 0x10000,
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* pci_mmio */
        {
            .phys_start = 0x10000000,
            .virt_start = 0x10000000,
            .size       = 0x2eff0000, // 769984.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* pci_pio */
        {
            .phys_start = 0x3ef0000,
            .virt_start = 0x3ef0000,
            .size       = 0x10000, // 64.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* pci ecam */
        {
            .phys_start = 0x4010000000,
            .virt_start = 0x4010000000,
            .size       = 0x10000000,
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
        /* pci_mem64 */
        {
            .phys_start = 0x8000000000,
            .virt_start = 0x8000000000,
            .size       = 0x100000000, // 4194304.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO,
        },
    },

    .irqchips = {
        /* GIC */
        {
            .address = 0x8000000,
            .pin_base = 32,
            .pin_bitmap = {
                0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
            },
        },
    },

    .pci_devices = {
        {
            .type = JAILHOUSE_PCI_TYPE_IVSHMEM,
            .domain = 1,
            .bdf = 0 << 3,
            .bar_mask = JAILHOUSE_IVSHMEM_BAR_MASK_INTX,
            .shmem_regions_start = 0,
            .shmem_dev_id = 0,
            .shmem_peers = 2,
            .shmem_protocol = JAILHOUSE_SHMEM_PROTO_UNDEFINED,
        },
    },
};
