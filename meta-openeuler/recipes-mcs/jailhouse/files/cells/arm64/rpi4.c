/*
 * Jailhouse, a Linux-based partitioning hypervisor
 *
 * Configuration for Raspberry Pi 4 (quad-core Cortex-A72, 1GB, 2GB, 4GB or 8GB RAM)
 *
 * NOTE: Reservation via device tree: reg = <0 0x10000000 0x10000000> or mem=750M
 */

#include <jailhouse/types.h>
#include <jailhouse/cell-config.h>

struct {
	struct jailhouse_system header;
	__u64 cpus[1];
	struct jailhouse_memory mem_regions[11];
	struct jailhouse_irqchip irqchips[2];
	struct jailhouse_pci_device pci_devices[1];
} __attribute__((packed)) config = {
	.header = {
		.signature = JAILHOUSE_SYSTEM_SIGNATURE,
		.revision = JAILHOUSE_CONFIG_REVISION,
		.flags = JAILHOUSE_SYS_VIRTUAL_DEBUG_CONSOLE,
		.hypervisor_memory = {
			.phys_start = 0x1fc00000,
			.size       = 0x00400000,
		},
		.debug_console = {
			.address = 0xfe215040,
			.size = 0x40,
			.type = JAILHOUSE_CON_TYPE_8250,
			.flags = JAILHOUSE_CON_ACCESS_MMIO |
				 JAILHOUSE_CON_REGDIST_4,
		},
		.platform_info = {
			.pci_mmconfig_base = 0xff900000,
			.pci_mmconfig_end_bus = 0,
			.pci_is_virtual = 1,
			.pci_domain = 1,
			.arm = {
				.gic_version = 2,
				.gicd_base = 0xff841000,
				.gicc_base = 0xff842000,
				.gich_base = 0xff844000,
				.gicv_base = 0xff846000,
				.maintenance_irq = 25,
			},
		},
		.root_cell = {
			.name = "Raspberry-Pi4",

			.cpu_set_size = sizeof(config.cpus),
			.num_memory_regions = ARRAY_SIZE(config.mem_regions),
			.num_irqchips = ARRAY_SIZE(config.irqchips),
			.num_pci_devices = ARRAY_SIZE(config.pci_devices),

			.vpci_irq_base = 128 - 32,
		},
	},

	.cpus = {
		0b1111,
	},

	.mem_regions = {
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
		/* MMIO 1 (permissive) */ {
			.phys_start = 0xfd500000,
			.virt_start = 0xfd500000,
			.size =        0x1b00000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_IO,
		},
		/* MMIO 2 (permissive) */ {
			.phys_start = 0x600000000,
			.virt_start = 0x600000000,
			.size =         0x4000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_IO,
		},
		/* RAM (0M-~506M) */ {
			.phys_start = 0x0,
			.virt_start = 0x0,
			.size = 0x1fa10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE,
		},
		/*
		 * 4M reserved for the hypervisor
		 *
		 * 0x2000 0000 - 0x6fff e000 for root
		 * 0x6fff e000 - 0x700f f000 for uio-ivshmem
		 * 0x700f f000 - 0x8000 0000 for non-root
		 * 0x8000 0000 - 0xfc00 0000 for root
		 */
		{
			.phys_start = 0x20000000,
			.virt_start = 0x20000000,
			.size = 0x4fffe000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE,
		},
		{
			.phys_start = 0x700ff000,
			.virt_start = 0x700ff000,
			.size = 0xff01000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE,
		},
		{
			.phys_start = 0x80000000,
			.virt_start = 0x80000000,
			.size = 0x7c000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE,
		},
		/* RAM (4096M-8192M) */ {
			.phys_start = 0x100000000,
			.virt_start = 0x100000000,
			.size = 0x100000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
				JAILHOUSE_MEM_EXECUTE,
		},
	},

	.irqchips = {
		/* GIC */ {
			.address = 0xff841000,
			.pin_base = 32,
			.pin_bitmap = {
				0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
			},
		},
		/* GIC */ {
			.address = 0xff841000,
			.pin_base = 160,
			.pin_bitmap = {
				0xffffffff, 0xffffffff
			},
		},
	},

	.pci_devices = {
		{
			.type = JAILHOUSE_PCI_TYPE_IVSHMEM,
			.domain = 1,
			/* the bdf must match the one int the client cell*/
			.bdf = 0 << 3,
			.bar_mask = JAILHOUSE_IVSHMEM_BAR_MASK_INTX,
			.shmem_regions_start = 0,
			.shmem_dev_id = 0,
			.shmem_peers = 2,
			/* 0x4001: openeuler class code IVSHMEM virtio-rpmsg */
			.shmem_protocol = 0x4001,
		},
	},
};
