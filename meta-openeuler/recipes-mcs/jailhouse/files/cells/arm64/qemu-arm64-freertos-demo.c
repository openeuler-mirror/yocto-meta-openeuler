/*
 * Jailhouse, a Linux-based partitioning hypervisor
 * Guest cell configuration for freertos
 * Created by resource-tool
 */

#include <jailhouse/types.h>
#include <jailhouse/cell-config.h>

struct {
    struct jailhouse_cell_desc cell;
    __u64 cpus[1];
    struct jailhouse_memory mem_regions[7];
    struct jailhouse_irqchip irqchips[1];
    struct jailhouse_pci_device pci_devices[1];
} __attribute__((packed)) config = {
    .cell = {
        .signature = JAILHOUSE_CELL_DESC_SIGNATURE,
        .revision = JAILHOUSE_CONFIG_REVISION,
        .name = "freertos",
        .flags = JAILHOUSE_CELL_PASSIVE_COMMREG|JAILHOUSE_CELL_VIRTUAL_CONSOLE_PERMITTED,
        .cpu_reset_address = 0x0,
        .cpu_set_size = sizeof(config.cpus),
        .num_memory_regions = ARRAY_SIZE(config.mem_regions),
        .num_irqchips = ARRAY_SIZE(config.irqchips),
        .num_pci_devices = ARRAY_SIZE(config.pci_devices),
        .vpci_irq_base = 101,
        .console = {
            .address = 0x9000000,
            .size = 0x1000,
            .type = JAILHOUSE_CON_TYPE_PL011,
            .flags = JAILHOUSE_CON_ACCESS_MMIO | JAILHOUSE_CON_REGDIST_4,
        },
    },
    .cpus = {
        // CPU: [1]
        0x2
    },
    .irqchips = {
        {
            .address = 0x8000000,
            .pin_base = 32,
            .pin_bitmap = {
                0x00000000,  // uart0(1)
                0x00000000,
                0x00000000,
                0x00000020,  // vpci(101)
            },
        },
    },
    .mem_regions = {
        /* IVSHMEM regions */
        {
            .phys_start = 0x81000000,
            .virt_start = 0x31000000,
            .size       = 0x1000,  // 4.0 KB
            .flags      = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_ROOTSHARED,
        },
        {
            .phys_start = 0x81001000,
            .virt_start = 0x31001000,
            .size       = 0x1000,  // 4.0 KB
            .flags      = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_ROOTSHARED,
        },
        {
            .phys_start = 0x81002000,
            .virt_start = 0x31002000,
            .size       = 0x100000,  // 1024.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_ROOTSHARED,
        },
        {
            .phys_start = 0x81102000,
            .virt_start = 0x31102000,
            .size       = 0x100000,  // 1024.0 KB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_ROOTSHARED,
        },

        /****************/
        /* System memory
         ****************/
        {
            .phys_start = 0x85000000,
            .virt_start = 0x0,
            .size = 0x4000000,  // 64.0 MB
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_EXECUTE | JAILHOUSE_MEM_LOADABLE | JAILHOUSE_MEM_DMA,
        },

        /*************/
        /* Memory map
         *************/

        /* uart0 */
        {
            .phys_start = 0x9000000,
            .virt_start = 0x9000000,
            .size       = 0x1000,
            .flags      = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO |JAILHOUSE_MEM_ROOTSHARED,
        },

        /* communication region */
        {
            .virt_start = 0x80000000,
            .size = 0x00001000,
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_COMM_REGION,
        },
    },

    .pci_devices = {
        /* ivshmem */
        {
            .type = JAILHOUSE_PCI_TYPE_IVSHMEM,
            .domain = 1,
            .bdf = 0 << 3,
            .bar_mask = JAILHOUSE_IVSHMEM_BAR_MASK_INTX,
            .shmem_regions_start = 0,
            .shmem_dev_id = 1,
            .shmem_peers = 2,
            .shmem_protocol = JAILHOUSE_SHMEM_PROTO_UNDEFINED,
        },

        /* host pci deivce */
    },
};
