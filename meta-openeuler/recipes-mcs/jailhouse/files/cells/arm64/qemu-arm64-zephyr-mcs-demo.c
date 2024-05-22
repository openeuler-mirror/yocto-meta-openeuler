/*
 * Jailhouse, a Linux-based partitioning hypervisor
 *
 * Configuration for zephyr-mcs-demo inmate on QEMU arm64
 *
 */

#include <jailhouse/types.h>
#include <jailhouse/cell-config.h>

struct {
	struct jailhouse_cell_desc cell;
	__u64 cpus[1];
	struct jailhouse_memory mem_regions[8];
	struct jailhouse_irqchip irqchips[1];
	struct jailhouse_pci_device pci_devices[1];
} __attribute__((packed)) config = {
	.cell = {
		.signature = JAILHOUSE_CELL_DESC_SIGNATURE,
		.revision = JAILHOUSE_CONFIG_REVISION,
		.name = "qemu-arm64-zephyr-demo",
		.flags = JAILHOUSE_CELL_PASSIVE_COMMREG |
			JAILHOUSE_CELL_VIRTUAL_CONSOLE_PERMITTED,

		.cpu_set_size = sizeof(config.cpus),
		.num_memory_regions = ARRAY_SIZE(config.mem_regions),
		.num_irqchips = ARRAY_SIZE(config.irqchips),
		.num_pci_devices = ARRAY_SIZE(config.pci_devices),
		/* virt pci irq base */
		.vpci_irq_base = 140-32,
		/* zephyr reset address*/
		.cpu_reset_address = 0x7a000000,

		.console = {
			.address = 0x09000000,
			.type = JAILHOUSE_CON_TYPE_PL011,
			.flags = JAILHOUSE_CON_ACCESS_MMIO |
				 JAILHOUSE_CON_REGDIST_4,
		},
	},
	/* cpus allocated to zephyr cell */
	.cpus = {
		0x2,
	},

	.mem_regions = {
		/* IVSHMEM shared memory regions for virtio-rpmsg */
		{
			.phys_start = 0x6fffe000,
			.virt_start = 0x6fffe000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_ROOTSHARED,
		},
		{
			.phys_start = 0x6ffff000,
			.virt_start = 0x6ffff000,
			.size = 0x100000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_ROOTSHARED,
		},
		/* output region for peer 0, no used, so set to 0 */
		{ 0 },
		/* output region for peer 0, no used, so set to 1 */
		{ 0 },
		/* UART */ {
			.phys_start = 0x09000000,
			.virt_start = 0x09000000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_IO | JAILHOUSE_MEM_ROOTSHARED,
		},
		/* RAM */ {
			.phys_start = 0x7f900000,
			.virt_start = 0,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE | JAILHOUSE_MEM_LOADABLE,
		},
		/* RAM: 0x7a000000 - 0x7f000000 */ {
			.phys_start = 0x7a000000,
			.virt_start = 0x7a000000,
			.size = 0x5000000,
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
			.address = 0x08000000,
			.pin_base = 32,
			.pin_bitmap = {
				1 << (33 - 32),  /* uart@9000000 's interrupt */
				0,
				0,
				/* virt pci interrupts:140 -143  map to zephyr
				 * 140: pin1, 141: pin2, 142: pin3, 143: pin4
				 */
				(0xf << (140 - 128))
			},
		},
	},

	.pci_devices = {
		{
			/*
			 * IVSHMEM virtio-rpmsg
			 * 0x4001: class code for openeuler embedded mcs
			 */
			.type = JAILHOUSE_PCI_TYPE_IVSHMEM,
			.domain = 1,
			/* bus:dev:fn = 0:0:0 , use device numer to generate int line info
			 * int line = device number + 1
			*/
			.bdf = 0 << 3,
			.bar_mask = JAILHOUSE_IVSHMEM_BAR_MASK_INTX,
			.shmem_regions_start = 0,
			.shmem_dev_id = 1,
			.shmem_peers = 2,
			.shmem_protocol = 0x4001,
		},
	},
};
