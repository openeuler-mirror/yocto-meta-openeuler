/*
 * Jailhouse, a Linux-based partitioning hypervisor
 *
 * Configuration for QEMU arm64 virtual target, 2G RAM, 4 cores
 * Support virtio-rpmsg
 *
 * NOTE: Add "mem=780M" to the kernel command line.
 */

#include <jailhouse/types.h>
#include <jailhouse/cell-config.h>

struct {
	struct jailhouse_system header;
	__u64 cpus[1];
	struct jailhouse_memory mem_regions[11];
	struct jailhouse_irqchip irqchips[1];
	struct jailhouse_pci_device pci_devices[2];
} __attribute__((packed)) config = {
	.header = {
		.signature = JAILHOUSE_SYSTEM_SIGNATURE,
		.revision = JAILHOUSE_CONFIG_REVISION,
		.flags = JAILHOUSE_SYS_VIRTUAL_DEBUG_CONSOLE,
		.hypervisor_memory = {
			.phys_start = 0x80000000,	// start at 1024M
			.size =       0x00400000,
		},
		.debug_console = {
			.address = 0x09000000,
			.size = 0x1000,
			.type = JAILHOUSE_CON_TYPE_PL011,
			.flags =  JAILHOUSE_CON_ACCESS_MMIO |
				  JAILHOUSE_CON_REGDIST_4,
		},
		.platform_info = {
			.pci_mmconfig_base = 0x08e00000,
			.pci_mmconfig_end_bus = 0,
			.pci_is_virtual = 1,
			.pci_domain = 1,
			.arm = {
				.gic_version = 3,
				.gicd_base = 0x08000000,
				.gicr_base = 0x080a0000,
				.maintenance_irq = 25,
			},
		},
		.root_cell = {
			.name = "qemu-arm64",

			.cpu_set_size = sizeof(config.cpus),
			.num_memory_regions = ARRAY_SIZE(config.mem_regions),
			.num_irqchips = ARRAY_SIZE(config.irqchips),
			.num_pci_devices = ARRAY_SIZE(config.pci_devices),

			.vpci_irq_base = 128-32,
		},
	},

	.cpus = {
		0x000f,
	},

	.mem_regions = {
		/* IVSHMEM shared memory regions (demo) */
		{
			.phys_start = 0x6fffc000,
			.virt_start = 0x6fffc000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ,
		},
		{
			.phys_start = 0x6fffd000,
			.virt_start = 0x6fffd000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE,
		},
		{ 0 },
		{ 0 },
		/* IVSHMEM shared memory regions for virtio-rpmsg */
		{
			.phys_start = 0x6fffe000,
			.virt_start = 0x6fffe000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ,
		},
		{
			.phys_start = 0x6ffff000,
			.virt_start = 0x6ffff000,
			.size = 0x100000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE,
		},
		{ 0 },
		{ 0 },
		/* MMIO (permissive) */ {
			.phys_start = 0x09000000,
			.virt_start = 0x09000000,
			.size =	      0x37000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_IO,
		},
		/* RAM
		 * 0x4000 0000 - 0x7fa1 0000 for root
		 * 0x7a00 0000 - 0x7f00 0000 for non-root
		 * so we need to use mem=780 (0x70c0 0000) to reserved mem for non-root
		 * Note: mem=xxx must cover ivshmem(0x70103000) for us now (because we need to init the ivshmem as a dma pool)
		 */ {
			.phys_start = 0x40000000,
			.virt_start = 0x40000000,
			.size = 0x3fa10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE,
		},
		/* "physical" PCI ECAM */ {
			.phys_start = 0x4010000000,
			.virt_start = 0x4010000000,
			.size = 0x10000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_IO,
		},
	},

	.irqchips = {
		/* GIC */ {
			.address = 0x08000000,
			.pin_base = 32,
			.pin_bitmap = {
				0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
			},
		},
	},

	.pci_devices = {
		{
			/* IVSHMEM 00:00.0 (demo) */
			.type = JAILHOUSE_PCI_TYPE_IVSHMEM,
			.domain = 1,
			.bdf = 0 << 3,
			.bar_mask = JAILHOUSE_IVSHMEM_BAR_MASK_INTX,
			.shmem_regions_start = 0,
			.shmem_dev_id = 0,
			.shmem_peers = 2,
			.shmem_protocol = JAILHOUSE_SHMEM_PROTO_UNDEFINED,
		},
		{
			/*
			 * IVSHMEM virtio-rpmsg
			 * 7: VIRTIO_ID_RPMSG
			 * 0x4001: our own class code
			 */
			.type = JAILHOUSE_PCI_TYPE_IVSHMEM,
			.domain = 1,
			.bdf = 7 << 3,
			.bar_mask = JAILHOUSE_IVSHMEM_BAR_MASK_INTX,
			.shmem_regions_start = 4,
			.shmem_dev_id = 0,
			.shmem_peers = 2,
			.shmem_protocol = 0x4001,
		},
	},
};
