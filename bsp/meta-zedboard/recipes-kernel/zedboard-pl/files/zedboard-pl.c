// SPDX-License-Identifier: GPL-2.0
/*
 * zedboard-pl.c - program the PL bitstream through the FPGA manager
 *
 * Linux 5.10 has no /sys/class/fpga_manager/fpgaX/firmware interface, so a
 * small platform driver is used instead: it takes the manager from the
 * "fpga-mgr" phandle, requests the firmware image and feeds it through the
 * exported fpga_mgr_load() API.
 */

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/firmware.h>
#include <linux/fpga/fpga-mgr.h>

#define DRIVER_NAME "zedboard-pl"

static int zedboard_pl_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct device_node *mgr_np;
	struct fpga_manager *mgr;
	struct fpga_image_info *info;
	const char *fw_name = "system.bit.bin";
	int ret;

	of_property_read_string(dev->of_node, "firmware-name", &fw_name);

	mgr_np = of_parse_phandle(dev->of_node, "fpga-mgr", 0);
	if (!mgr_np) {
		dev_err(dev, "missing fpga-mgr phandle\n");
		return -EINVAL;
	}

	mgr = of_fpga_mgr_get(mgr_np);
	of_node_put(mgr_np);
	if (IS_ERR(mgr))
		return dev_err_probe(dev, PTR_ERR(mgr),
				     "failed to get FPGA manager\n");

	info = fpga_image_info_alloc(dev);
	if (!info) {
		fpga_mgr_put(mgr);
		return -ENOMEM;
	}
	info->firmware_name = fw_name;

	ret = fpga_mgr_lock(mgr);
	if (!ret) {
		ret = fpga_mgr_load(mgr, info);
		fpga_mgr_unlock(mgr);
	}
	if (ret)
		dev_err(dev, "failed to load %s: %d\n", fw_name, ret);
	else
		dev_info(dev, "PL bitstream %s programmed\n", fw_name);

	/* info is devres-managed and freed automatically on remove */
	fpga_mgr_put(mgr);

	return ret;
}

static const struct of_device_id zedboard_pl_of_match[] = {
	{ .compatible = "oe,zedboard-pl" },
	{ }
};
MODULE_DEVICE_TABLE(of, zedboard_pl_of_match);

static struct platform_driver zedboard_pl_driver = {
	.probe	= zedboard_pl_probe,
	.driver	= {
		.name		= DRIVER_NAME,
		.of_match_table	= zedboard_pl_of_match,
	},
};
module_platform_driver(zedboard_pl_driver);

MODULE_AUTHOR("openEuler Embedded");
MODULE_DESCRIPTION("ZedBoard PL bitstream loader");
MODULE_LICENSE("GPL v2");