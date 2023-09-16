/*
 * Jailhouse, a Linux-based partitioning hypervisor
 *
 * Configuration for demo inmate on OK3568 arm64 target, 2G RAM, 4 cores
 *
 * Copyright (c) NCTI, 2023
 *
 * Authors:
 *  Hu Yongqiang <huyongqiang@ncti-gba.cn>
 *
 * This work is licensed under the terms of the GNU GPL, version 2.  See
 * the COPYING file in the top-level directory.
 */

#include <jailhouse/types.h>
#include <jailhouse/cell-config.h>

struct {
	struct jailhouse_cell_desc cell;
	__u64 cpus[1];
	struct jailhouse_memory mem_regions[8];
	struct jailhouse_irqchip irqchips[1];
} __attribute__((packed)) config = {
	.cell = {
		.signature = JAILHOUSE_CELL_DESC_SIGNATURE,
		.revision = JAILHOUSE_CONFIG_REVISION,
		.architecture = JAILHOUSE_ARM64,
		.name = "rk3568-rtt",
		.flags = JAILHOUSE_CELL_PASSIVE_COMMREG,

		.cpu_set_size = sizeof(config.cpus),
		.num_memory_regions = ARRAY_SIZE(config.mem_regions),
		.num_irqchips = ARRAY_SIZE(config.irqchips),
		.cpu_reset_address = 0x7a000000,

		.console = {
			.address = 0xfe660000,
			.type = JAILHOUSE_CON_TYPE_8250,
			.flags = JAILHOUSE_CON_ACCESS_MMIO |
				 JAILHOUSE_CON_REGDIST_4,
		},
	},

	.cpus = {
		0b1100,
	},

	.mem_regions = {
		{
			.phys_start = 0x0,
			.virt_start = 0x0,
			.size = 0x100000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
					 JAILHOUSE_MEM_IO,
		},
		/* UART */ {
			.phys_start = 0xfe680000,
			.virt_start = 0xfe680000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				 | JAILHOUSE_MEM_IO_8 | JAILHOUSE_MEM_IO_16
                     		 | JAILHOUSE_MEM_IO_32 |  JAILHOUSE_MEM_IO_UNALIGNED
		},
		{
			.phys_start = 0xfd400000,
			.virt_start = 0xfd400000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
					 JAILHOUSE_MEM_IO | JAILHOUSE_MEM_ROOTSHARED
		},
		{
			.phys_start = 0xfd460000,
			.virt_start = 0xfd460000,
			.size = 0xc0000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
					 JAILHOUSE_MEM_IO | JAILHOUSE_MEM_ROOTSHARED
		},
		{
			.phys_start = 0xfdc60000,
			.virt_start = 0xfdc60000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
					 JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfdd20000,
			.virt_start = 0xfdd20000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
					 JAILHOUSE_MEM_IO | JAILHOUSE_MEM_ROOTSHARED
		},
		/* RAM */ {
                        .phys_start = 0x60000000,
                        .virt_start = 0x60000000,
                        .size = 0x20000000,
                        .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |
                                JAILHOUSE_MEM_EXECUTE | JAILHOUSE_MEM_LOADABLE
                },

	},

	.irqchips = {
		/* GIC */ {
			.address = 0xfd400000,
			.pin_base = 32,
			.pin_bitmap = {
				0,
				0,
				0,
				0
				//(1 << (152 - 128))
			},
		},
	},
};

