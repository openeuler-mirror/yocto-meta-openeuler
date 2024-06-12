/*
 * Jailhouse, a Linux-based partitioning hypervisor
 *
 * Configuration for linux-demo inmate on Raspberry Pi 4:
 * 2 CPUs
 */
#include <jailhouse/types.h>
#include <jailhouse/cell-config.h>

struct {
	struct jailhouse_cell_desc cell;
	__u64 cpus[1];
	struct jailhouse_memory mem_regions[8];
	struct jailhouse_irqchip irqchips[2];
} __attribute__((packed)) config = {
	.cell = {
		.signature = JAILHOUSE_CELL_DESC_SIGNATURE,
		.revision = JAILHOUSE_CONFIG_REVISION,
		.name = "rpi4-linux",
		.flags = JAILHOUSE_CELL_PASSIVE_COMMREG |
			JAILHOUSE_CELL_VIRTUAL_CONSOLE_PERMITTED,

		.cpu_set_size = sizeof(config.cpus),
		.num_memory_regions = ARRAY_SIZE(config.mem_regions),
		.num_irqchips = ARRAY_SIZE(config.irqchips),
		.num_pci_devices = 0,

		.vpci_irq_base = 131 - 32,
	},

	.cpus = {
		0b1100,
	},

	.mem_regions = {
                /* MMIO 1 (permissive) */ {
                        .phys_start = 0xfd500000,
                        .virt_start = 0xfd500000,
                        .size =        0x1b00000,
                        .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
                                JAILHOUSE_MEM_IO | JAILHOUSE_MEM_IO_8 |
                                JAILHOUSE_MEM_IO_32| JAILHOUSE_MEM_ROOTSHARED,
                },
                /* MMIO 2 (permissive) */ {
                        .phys_start = 0x600000000,
                        .virt_start = 0x600000000,
                        .size =         0x4000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
                                JAILHOUSE_MEM_IO | JAILHOUSE_MEM_IO_8 |
                                JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_ROOTSHARED,
                },
		/* RAM */ {
			.phys_start = 0x10000000,
			.virt_start = 0,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE | JAILHOUSE_MEM_LOADABLE,
		},
                /* RAM */
		{
                        .phys_start = 0x10010000,
                        .virt_start = 0x10010000,
			.size = 0xfbf0000,
                        .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
                                JAILHOUSE_MEM_EXECUTE | JAILHOUSE_MEM_DMA |
                                JAILHOUSE_MEM_LOADABLE,
                },
		/* 0x3000 0000 - 0x4000 0000 for root linux cell */
		{
                        .phys_start = 0x40000000,
                        .virt_start = 0x40000000,
                        .size = 0x2fffe000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
                                JAILHOUSE_MEM_EXECUTE | JAILHOUSE_MEM_DMA |
                                JAILHOUSE_MEM_LOADABLE,
                },
		/* 0x6fff e000 - 0x8000 0000 for zephyr cell */
		{
                        .phys_start = 0x80000000,
                        .virt_start = 0x80000000,
                        .size = 0x76000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
                                JAILHOUSE_MEM_EXECUTE | JAILHOUSE_MEM_DMA |
                                JAILHOUSE_MEM_LOADABLE,
                },
		/* RAM (4096M-8192M) */ {
			.phys_start = 0x100000000,
			.virt_start = 0x100000000,
			.size = 0x100000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE | JAILHOUSE_MEM_DMA |
                                JAILHOUSE_MEM_LOADABLE,
		},
		/* communication region */ {
			.virt_start = 0x80000000,
			.size = 0x00001000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_COMM_REGION,
		},
	},

	.irqchips = {
		/* GIC */ {
			.address = 0xff841000,
			.pin_base = 32,
			.pin_bitmap = {
				0xffffffff,
				0xffffffff,
				/* uart0 interrupt:125 for root cell */
				(0xffffffff & (~(1<<29)) ),
				/*
				 * uio interrupt: 128 (vpci_irq_base of root cell)
				 * virt pci interrupts:140 -143 map to zephyr
				 * 140: pin1, 141: pin2, 142: pin3, 143: pin4
				 */
				(0xffffffff & (~1) & (~( 0xf<<(140-128) )) )
			},
		},
		/* GIC */ {
			.address = 0xff841000,
			.pin_base = 160,
			.pin_bitmap = {
				/* eth0: 189, 190 */
				(0xffffffff & (~(1<<29)) & (~(1<<30)) ), 0xffffffff
			},
		},
	},
};
