/*
 * Jailhouse, a Linux-based partitioning hypervisor
 *
 * Configuration for OK3568 arm64 target, 2G RAM, 4 cores
 *
 * Copyright (c) NCTI, 2023
 *
 *  Authors:
 *  Hu Yongqiang <huyongqiang@ncti-gba.cn>
 *
 * This work is licensed under the terms of the GNU GPL, version 2.  See
 * the COPYING file in the top-level directory.
 *
 */

#include <jailhouse/types.h>
#include <jailhouse/cell-config.h>

struct {
	struct jailhouse_system header;
	__u64 cpus[1];
	struct jailhouse_memory mem_regions[94];
	struct jailhouse_irqchip irqchips[2];
} __attribute__((packed)) config = {
	.header = {
		.signature = JAILHOUSE_SYSTEM_SIGNATURE,
		.revision = JAILHOUSE_CONFIG_REVISION,
		.architecture = JAILHOUSE_ARM64,
		.flags = JAILHOUSE_SYS_VIRTUAL_DEBUG_CONSOLE,
		.hypervisor_memory = {
			.phys_start = 0x60000000,
			.size =       0x8000000
		},
		.debug_console = {
			.address = 0xfe660000,
			.size = 0x100,
			.type = JAILHOUSE_CON_TYPE_8250, /* choose the 8250 driver */
        		.flags = JAILHOUSE_CON_ACCESS_MMIO | JAILHOUSE_CON_REGDIST_4
		},

		.platform_info = {
			.arm = {
				.gic_version = 3,
				.gicd_base = 0xfd400000,
				.gicr_base = 0xfd460000,
				.maintenance_irq = 25
			},
		},
		.root_cell = {
			.name = "rk3568-openeuler",
			.cpu_set_size = sizeof(config.cpus),
			.num_memory_regions = ARRAY_SIZE(config.mem_regions),
			.num_irqchips = ARRAY_SIZE(config.irqchips),
		},
	},

	.cpus = {
		0xf,
	},

	.mem_regions = {
		/* RAM */ 
		{
			.phys_start = 0x0,
			.virt_start = 0x0,
			.size = 0x50000000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_EXECUTE
		},
        {
            .phys_start = 0x7a000000,
            .virt_start = 0x7a000000,
            .size = 0x400000,
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_EXECUTE
        },	
		/* ITS */
		{
            .phys_start = 0xfd440000,
            .virt_start = 0xfd440000,
            .size = 0x20000,
            .flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
                
		},
		/* USB */
		{
			.phys_start = 0xfd800000,
			.virt_start = 0xfd800000,
			.size = 0x100000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				| JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		{
			.phys_start = 0xfdca0000,
			.virt_start = 0xfdca0000,
			.size = 0x8000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		{
			.phys_start = 0xfdca8000,
			.virt_start = 0xfdca8000,
			.size = 0x8000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* SRAM fdcc0000-fdccafff */
		{
			.phys_start = 0xfdcc0000,
			.virt_start = 0xfdcc0000,
			.size = 0xb000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_EXECUTE
		},
		/* PMUCRU */
		{
			.phys_start = 0xfdd00000,
			.virt_start = 0xfdd00000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* CRU*/
		{
			.phys_start = 0xfdd20000,
			.virt_start = 0xfdd20000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* I2C fdd40000-fdd40fff */
		{
			.phys_start = 0xfdd40000,
			.virt_start = 0xfdd40000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},

		/* UART fdd50000-fdd50ff */
		{
			.phys_start = 0xfdd50000,
			.virt_start = 0xfdd50000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},

		/* GPIO fdd60000-fdd600ff */
		{
			.phys_start = 0xfdd60000,
			.virt_start = 0xfdd60000,
			.size =	0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* PWM0 */
		{
			.phys_start = 0xfdd70000,
			.virt_start = 0xfdd70000,
			.size =	0x10,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* PWM1 */
		{
			.phys_start = 0xfdd70010,
			.virt_start = 0xfdd70010,
			.size =	0x10,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* PWM2 */
		{
			.phys_start = 0xfdd70020,
			.virt_start = 0xfdd70020,
			.size =	0x10,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},

		/* PWM3 fdd70030-fdd7003f : fdd70030.pwm pwm@fdd70030 */
		{
			.phys_start = 0xfdd70030,
			.virt_start = 0xfdd70030,
			.size = 0x10,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* PMU */
		{
			.phys_start = 0xfdd90000,
			.virt_start = 0xfdd90000,
			.size =	0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},

		/* PVTM fde00000-fde000ff */
		{
			.phys_start = 0xfde00000,
			.virt_start = 0xfde00000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* NPU */
		{
			.phys_start = 0xfde40000,
			.virt_start = 0xfde40000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* GPU fde60000-fde63fff */
		{
			.phys_start = 0xfde60000,
			.virt_start = 0xfde60000,
			.size = 0x4000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* PVTM fde80000-fde800ff*/
		{
			.phys_start = 0xfde80000,
			.virt_start = 0xfde80000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* PVTM fde90000-fde900ff */
		{
			.phys_start = 0xfde90000,
			.virt_start = 0xfde90000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* IOMMU fdea0800-fdea083f */
		{
			.phys_start = 0xfdea0800,
			.virt_start = 0xfdea0800,
			.size = 0x40,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* RK_RGA fdeb0000-fdeb0fff */
		{
			.phys_start = 0xfdeb0000,
			.virt_start = 0xfdeb0000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* jpegd_mmu */
		{
			.phys_start = 0xfded0480,
			.virt_start = 0xfded0480,
			.size = 0x40,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE	
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* vepu _mmu*/
		{
			.phys_start = 0xfdee0800,
			.virt_start = 0xfdee0800,
			.size = 0x40,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* iep_mmu fdef0800-fdef08ff */
		{
			.phys_start = 0xfdef0800,
			.virt_start = 0xfdef0800,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* IOMMU fdf40f00-fdf40f3f */
		{
			.phys_start = 0xfdf40f00,
			.virt_start = 0xfdf40f00,
			.size = 0x40,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* IOMMU fdf40f40-fdf40f7f */
		{
			.phys_start = 0xfdf40f40,
			.virt_start = 0xfdf40f40,
			.size = 0x40,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* IOMMU fdf80800-fdf8083f */
		{
			.phys_start = 0xfdf80800,
			.virt_start = 0xfdf80800,
			.size = 0x40,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* IOMMU fdf80840-fdf8087f */
		{
			.phys_start = 0xfdf80840,
			.virt_start = 0xfdf80840,
			.size = 0x40,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* IOMMU fdff1a00-fdff1aff */
		{
			.phys_start = 0xfdff1a00,
			.virt_start = 0xfdff1a00,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* DWMMC fe000000-fe003fff */
		{
			.phys_start = 0xfe000000,
			.virt_start = 0xfe000000,
			.size = 0x4000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* ETHERNET fe010000-fe01ffff */
		{
			.phys_start = 0xfe010000,
			.virt_start = 0xfe010000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* VOP fe040000-fe042fff */		
		{
			.phys_start = 0xfe040000,
			.virt_start = 0xfe040000,
			.size = 0x3000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* IOMMU fe043e00-fe043eff */
		{
			.phys_start = 0xfe043e00,
			.virt_start = 0xfe043e00,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED

		},
		/* IOMMU fe043f00-fe043fff */
		{
			.phys_start = 0xfe043f00,
			.virt_start = 0xfe043f00,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* VOP */		
		{
			.phys_start = 0xfe044000,
			.virt_start = 0xfe044000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* IOMMU fe043e00-fe043eff */
		{
			.phys_start = 0xfe043e00,
			.virt_start = 0xfe043e00,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* IOMMU fe043f00-fe043fff */
		{
			.phys_start = 0xfe043f00,
			.virt_start = 0xfe043f00,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* VOP fe044000-fe044fff*/
		{
			.phys_start = 0xfe044000,
			.virt_start = 0xfe044000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* HDMI fe0a0000-fe0bffff */
		{
			.phys_start = 0xfe0a0000,
			.virt_start = 0xfe0a0000,
			.size = 0x20000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* ETHERNET fe2a0000-fe2affff */
		{
			.phys_start = 0xfe2a0000,
			.virt_start = 0xfe2a0000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* DWMMC fe2b0000-fe2b3fff */
		{
			.phys_start = 0xfe2b0000,
			.virt_start = 0xfe2b0000,
			.size = 0x4000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* SDHCI fe310000-fe31ffff */
		{
			.phys_start = 0xfe310000,
			.virt_start = 0xfe310000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* DMAC fe530000-fe533fff*/
		{
			.phys_start = 0xfe530000,
			.virt_start = 0xfe530000,
			.size = 0x4000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* DMAC fe550000-fe553fff */
		{
			.phys_start = 0xfe550000,
			.virt_start = 0xfe550000,
			.size = 0x4000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* I2C fe5b0000-fe5b0fff */
		{
			.phys_start = 0xfe5b0000,
			.virt_start = 0xfe5b0000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* I2C fe5c0000-fe5c0fff */
		{
			.phys_start = 0xfe5c0000,
			.virt_start = 0xfe5c0000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* RK TIMER fe5f0000*/
		{
			.phys_start = 0xfe5f0000,
			.virt_start = 0xfe5f0000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* WATCHDOG fe600000-fe6000ff */
		{
			.phys_start = 0xfe600000,
			.virt_start = 0xfe600000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* SPI fe630000-fe630fff */
		{
			.phys_start = 0xfe630000,
			.virt_start = 0xfe630000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* SERIAL fe660000-fe66001f */
		{
			.phys_start = 0xfe660000,
			.virt_start = 0xfe660000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE 
				 | JAILHOUSE_MEM_IO_8 | JAILHOUSE_MEM_IO_16
				 | JAILHOUSE_MEM_IO_32 |  JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* SERIAL fe670000-fe67001f */
		{
			.phys_start = 0xfe670000,
			.virt_start = 0xfe670000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				     | JAILHOUSE_MEM_IO_8 | JAILHOUSE_MEM_IO_16
                     | JAILHOUSE_MEM_IO_32 |  JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* SERIAL fe680000-fe68001f
		{
			.phys_start = 0xfe680000,
			.virt_start = 0xfe680000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				     | JAILHOUSE_MEM_IO_8 | JAILHOUSE_MEM_IO_16
                     | JAILHOUSE_MEM_IO_32 |  JAILHOUSE_MEM_IO_UNALIGNED
		},*/
		/* SERIAL fe690000-fe69001f */
		{
			.phys_start = 0xfe690000,
			.virt_start = 0xfe690000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				     | JAILHOUSE_MEM_IO_8 | JAILHOUSE_MEM_IO_16
                     | JAILHOUSE_MEM_IO_32 |  JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* SERIAL fe6c0000-fe6c001f */
		{
			.phys_start = 0xfe6c0000,
			.virt_start = 0xfe6c0000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_8 | JAILHOUSE_MEM_IO_16
                     | JAILHOUSE_MEM_IO_32 |  JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* PWM fe6e0010-fe6e001f */
		{
			.phys_start = 0xfe6e0010,
			.virt_start = 0xfe6e0010,
			.size = 0x10,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* PWM fe700020-fe70002f */
		{
			.phys_start = 0xfe700020,
			.virt_start = 0xfe700020,
			.size = 0x10,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				     | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* TSADC fe710000-fe7100ff */
		{
			.phys_start = 0xfe710000,
			.virt_start = 0xfe710000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* SARADC fe720000-fe7200ff */
		{
			.phys_start = 0xfe720000,
			.virt_start = 0xfe720000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* GPIO fe740000-fe7400ff */
		{
			.phys_start = 0xfe740000,
			.virt_start = 0xfe740000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
				     | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* GPIO fe750000-fe7500ff */
		{
			.phys_start = 0xfe750000,
			.virt_start = 0xfe750000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* GPIO fe760000-fe7600ff */
		{
			.phys_start = 0xfe760000,
			.virt_start = 0xfe760000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* GPIO fe770000-fe7700ff */
		{
			.phys_start = 0xfe770000,
			.virt_start = 0xfe770000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE
					 | JAILHOUSE_MEM_IO_32 | JAILHOUSE_MEM_IO_UNALIGNED
		},
		/* USB2-PHY fe8a0000-fe8affff */
		{
			.phys_start = 0xfe8a0000,
			.virt_start = 0xfe8a0000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* USB2-PHY fe8b0000-fe8bffff */
		{
			.phys_start = 0xfe8b0000,
			.virt_start = 0xfe8b0000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		/* PHY fe8c0000-fe8dffff */
		{
			.phys_start = 0xfe8c0000,
			.virt_start = 0xfe8c0000,
			.size = 0x20000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfdc20000,
			.virt_start = 0xfdc20000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfe230000,
			.virt_start = 0xfe230000,
			.size = 0x400,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe388000,
			.virt_start = 0xfe388000,
			.size = 0x2000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfe102000,
			.virt_start = 0xfe102000,
			.size = 0x100,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfd90c000,
			.virt_start = 0xfd90c000,
			.size = 0x4000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfdc50000,
			.virt_start = 0xfdc50000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfdc60000,
			.virt_start = 0xfdc60000,
			.size = 0x10000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfdc70000,
			.virt_start = 0xfdc70000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfdc80000,
			.virt_start = 0xfdc80000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfdc90000,
			.virt_start = 0xfdc90000,
			.size = 0x1000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0x110000,
			.virt_start = 0x110000,
			.size = 0xf0000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE | JAILHOUSE_MEM_IO
		},
		{
			.phys_start = 0xfe102100,
			.virt_start = 0xfe102100,
			.size = 0x300,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe38c000,
			.virt_start = 0xfe38c000,
			.size = 0x4000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe190000,
			.virt_start = 0xfe190000,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe190080,
			.virt_start = 0xfe190080,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe190100,
			.virt_start = 0xfe190100,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe190200,
			.virt_start = 0xfe190200,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe190280,
			.virt_start = 0xfe190280,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe190300,
			.virt_start = 0xfe190300,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe190380,
			.virt_start = 0xfe190380,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe190400,
			.virt_start = 0xfe190400,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe198000,
			.virt_start = 0xfe198000,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe1a8000,
			.virt_start = 0xfe1a8000,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe1a8080,
			.virt_start = 0xfe1a8080,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfe1a8100,
			.virt_start = 0xfe1a8100,
			.size = 0x20,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfcc00000,
			.virt_start = 0xfcc00000,
			.size = 0x400000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		},
		{
			.phys_start = 0xfd000000,
			.virt_start = 0xfd000000,
			.size = 0x400000,
			.flags = JAILHOUSE_MEM_READ | JAILHOUSE_MEM_WRITE |JAILHOUSE_MEM_IO_8|JAILHOUSE_MEM_IO_16|JAILHOUSE_MEM_IO_32|JAILHOUSE_MEM_IO_64
		}
	},

	.irqchips = {
		/* GIC */ {
			.address = 0xfd400000,
			.pin_base = 32,
			.pin_bitmap = {
				0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
			},
		},
		{
            .address = 0xfd400000,
            .pin_base = 160,
            .pin_bitmap = {
                0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
            },
		},
	},
};


