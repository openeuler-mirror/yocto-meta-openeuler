// SPDX-License-Identifier: GPL-2.0
/*
 * pmodoled-gpio.c - ZedBoard on-board OLED driver
 *
 * Originally derived from Digilent's drivers/staging/pmods/pmodoled-gpio.c
 * (Copyright (c) 2012 Digilent, GPL-2.0). Reworked for the 5.10 kernel:
 * the display is driven by bit-banging the SPI lines through PS EMIO GPIOs
 * instead of registering a spi_gpio bus at runtime.
 *
 * The 128x32 SSD1306-style panel is wired to EMIO GPIOs:
 *   vbat, vdd, reset, dc, sclk, sdin
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/of_gpio.h>
#include <linux/gpio.h>
#include <linux/miscdevice.h>
#include <linux/mutex.h>
#include <linux/fs.h>
#include <linux/delay.h>
#include <linux/slab.h>
#include <linux/uaccess.h>

#define DRIVER_NAME	"pmodoled-gpio"

#define DISPLAY_BUF_SZ		512	/* 128 x 32 monochrome bits */
#define OLED_MAX_PG_CNT		4
#define OLED_CONTROLLER_PG_SZ	128
#define OLED_CONTROLLER_CMD	0
#define OLED_CONTROLLER_DATA	1

#define OLED_SET_PG_ADDR	0x22
#define OLED_DISPLAY_OFF	0xAE
#define OLED_DISPLAY_ON		0xAF
#define OLED_CONTRAST_CTRL	0x81
#define OLED_SET_PRECHARGE_PERIOD	0xD9
#define OLED_SET_SEGMENT_REMAP	0xA1
#define OLED_SET_COM_DIR	0xC8
#define OLED_SET_COM_PINS	0xDA

struct zed_oled {
	struct miscdevice mdev;
	struct mutex lock;
	struct device *dev;
	u8 *buf;
	int gpio_vbat;
	int gpio_vdd;
	int gpio_res;
	int gpio_dc;
	int gpio_sclk;
	int gpio_sdin;
	int delay_us;
};

static void oled_set_dc(struct zed_oled *oled, int data)
{
	gpio_set_value(oled->gpio_dc, data ? OLED_CONTROLLER_DATA
					   : OLED_CONTROLLER_CMD);
}

/* SPI mode 0, MSB first: data is sampled by the panel on the rising edge */
static void oled_spi_write(struct zed_oled *oled, const u8 *buf, size_t len)
{
	size_t i;
	int bit;

	for (i = 0; i < len; i++) {
		for (bit = 7; bit >= 0; bit--) {
			gpio_set_value(oled->gpio_sdin, (buf[i] >> bit) & 1);
			udelay(oled->delay_us);
			gpio_set_value(oled->gpio_sclk, 1);
			udelay(oled->delay_us);
			gpio_set_value(oled->gpio_sclk, 0);
			udelay(oled->delay_us);
		}
	}
}

static void oled_send_cmd(struct zed_oled *oled, const u8 *cmd, size_t len)
{
	oled_set_dc(oled, 0);
	oled_spi_write(oled, cmd, len);
}

static void oled_push_frame(struct zed_oled *oled)
{
	u8 cmd[4];
	int pg;

	for (pg = 0; pg < OLED_MAX_PG_CNT; pg++) {
		cmd[0] = OLED_SET_PG_ADDR;
		cmd[1] = pg;
		cmd[2] = 0x00;	/* lower start column */
		cmd[3] = 0x10;	/* upper start column */
		oled_send_cmd(oled, cmd, sizeof(cmd));

		oled_set_dc(oled, 1);
		oled_spi_write(oled, oled->buf + pg * OLED_CONTROLLER_PG_SZ,
			       OLED_CONTROLLER_PG_SZ);
	}
}

static void oled_panel_init(struct zed_oled *oled)
{
	static const u8 oled_display_off = OLED_DISPLAY_OFF;
	const u8 init_seq[] = {
		0x8D, 0x14,			/* charge pump enable */
		OLED_SET_PRECHARGE_PERIOD, 0xF1,
		OLED_CONTRAST_CTRL, 0xCF,
		OLED_SET_SEGMENT_REMAP,		/* remap columns */
		OLED_SET_COM_DIR,		/* remap rows */
		OLED_SET_COM_PINS, 0x00,
		0xC0,
		0x20, 0x00,			/* horizontal addressing */
		OLED_DISPLAY_ON,
	};

	oled_set_dc(oled, 0);

	/*
	 * Both rails are active low. At boot the panel is powered up right
	 * after the PL has been configured, so give the rails time to settle
	 * before resetting and initialising the controller; a too-eager init
	 * leaves the panel dark until the next driver reload.
	 */
	gpio_set_value(oled->gpio_vdd, 0);
	gpio_set_value(oled->gpio_vbat, 0);
	msleep(300);

	gpio_set_value(oled->gpio_res, 0);
	msleep(50);
	gpio_set_value(oled->gpio_res, 1);
	msleep(100);

	oled_send_cmd(oled, &oled_display_off, 1);
	oled_send_cmd(oled, init_seq, sizeof(init_seq));
	msleep(50);
	/* run it twice: the charge pump needs time to settle after power-up */
	oled_send_cmd(oled, &oled_display_off, 1);
	oled_send_cmd(oled, init_seq, sizeof(init_seq));
	msleep(50);

	memset(oled->buf, 0, DISPLAY_BUF_SZ);
	oled_push_frame(oled);
}

static int zed_oled_open(struct inode *inode, struct file *file)
{
	file->private_data = container_of(file->private_data,
					  struct zed_oled, mdev);
	return 0;
}

static ssize_t zed_oled_write(struct file *file, const char __user *ubuf,
			      size_t len, loff_t *off)
{
	struct zed_oled *oled = file->private_data;
	size_t cnt = min(len, (size_t)DISPLAY_BUF_SZ);

	if (mutex_lock_interruptible(&oled->lock))
		return -ERESTARTSYS;

	if (copy_from_user(oled->buf, ubuf, cnt)) {
		mutex_unlock(&oled->lock);
		return -EFAULT;
	}

	oled_push_frame(oled);
	mutex_unlock(&oled->lock);

	return cnt;
}

static ssize_t zed_oled_read(struct file *file, char __user *ubuf,
			     size_t len, loff_t *off)
{
	struct zed_oled *oled = file->private_data;
	size_t cnt;
	int ret;

	if (*off >= DISPLAY_BUF_SZ)
		return 0;

	cnt = min(len, (size_t)DISPLAY_BUF_SZ - (size_t)*off);

	if (mutex_lock_interruptible(&oled->lock))
		return -ERESTARTSYS;

	ret = copy_to_user(ubuf, oled->buf + *off, cnt) ? -EFAULT : (int)cnt;
	mutex_unlock(&oled->lock);

	if (ret > 0)
		*off += cnt;

	return ret;
}

static const struct file_operations zed_oled_fops = {
	.owner		= THIS_MODULE,
	.open		= zed_oled_open,
	.write		= zed_oled_write,
	.read		= zed_oled_read,
	.llseek		= no_llseek,
};

static int zed_oled_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct device_node *np = dev->of_node;
	struct zed_oled *oled;
	u32 speed = 0;
	int ret;

	oled = devm_kzalloc(dev, sizeof(*oled), GFP_KERNEL);
	if (!oled)
		return -ENOMEM;

	oled->dev = dev;
	mutex_init(&oled->lock);

	oled->buf = devm_kzalloc(dev, DISPLAY_BUF_SZ, GFP_KERNEL);
	if (!oled->buf)
		return -ENOMEM;

	oled->gpio_vbat = of_get_named_gpio(np, "vbat-gpio", 0);
	oled->gpio_vdd = of_get_named_gpio(np, "vdd-gpio", 0);
	oled->gpio_res = of_get_named_gpio(np, "res-gpio", 0);
	oled->gpio_dc = of_get_named_gpio(np, "dc-gpio", 0);
	oled->gpio_sclk = of_get_named_gpio(np, "spi-sclk-gpio", 0);
	oled->gpio_sdin = of_get_named_gpio(np, "spi-sdin-gpio", 0);

	if (!gpio_is_valid(oled->gpio_vbat) || !gpio_is_valid(oled->gpio_vdd) ||
	    !gpio_is_valid(oled->gpio_res) || !gpio_is_valid(oled->gpio_dc) ||
	    !gpio_is_valid(oled->gpio_sclk) || !gpio_is_valid(oled->gpio_sdin)) {
		dev_err(dev, "missing OLED GPIOs in device tree\n");
		return -EINVAL;
	}

	ret = devm_gpio_request_one(dev, oled->gpio_vbat, GPIOF_OUT_INIT_HIGH,
				    "OLED_VBAT");
	if (ret)
		return ret;
	ret = devm_gpio_request_one(dev, oled->gpio_vdd, GPIOF_OUT_INIT_HIGH,
				    "OLED_VDD");
	if (ret)
		return ret;
	ret = devm_gpio_request_one(dev, oled->gpio_res, GPIOF_OUT_INIT_HIGH,
				    "OLED_RES");
	if (ret)
		return ret;
	ret = devm_gpio_request_one(dev, oled->gpio_dc, GPIOF_OUT_INIT_HIGH,
				    "OLED_DC");
	if (ret)
		return ret;
	ret = devm_gpio_request_one(dev, oled->gpio_sclk, GPIOF_OUT_INIT_LOW,
				    "OLED_SCLK");
	if (ret)
		return ret;
	ret = devm_gpio_request_one(dev, oled->gpio_sdin, GPIOF_OUT_INIT_LOW,
				    "OLED_SDIN");
	if (ret)
		return ret;

	if (!of_property_read_u32(np, "spi-speed-hz", &speed) && speed)
		oled->delay_us = max(3, 500000 / (int)speed);
	else
		oled->delay_us = 3;

	oled_panel_init(oled);

	oled->mdev.minor = MISC_DYNAMIC_MINOR;
	oled->mdev.name = "zed_oled";
	oled->mdev.fops = &zed_oled_fops;
	oled->mdev.parent = dev;

	ret = misc_register(&oled->mdev);
	if (ret) {
		dev_err(dev, "failed to register misc device: %d\n", ret);
		return ret;
	}

	platform_set_drvdata(pdev, oled);
	dev_info(dev, "ZedBoard OLED ready (/dev/zed_oled)\n");

	return 0;
}

static int zed_oled_remove(struct platform_device *pdev)
{
	struct zed_oled *oled = platform_get_drvdata(pdev);

	misc_deregister(&oled->mdev);
	return 0;
}

static const struct of_device_id zed_oled_of_match[] = {
	{ .compatible = "dglnt,pmodoled-gpio" },
	{ }
};
MODULE_DEVICE_TABLE(of, zed_oled_of_match);

static struct platform_driver zed_oled_driver = {
	.probe	= zed_oled_probe,
	.remove	= zed_oled_remove,
	.driver	= {
		.name		= DRIVER_NAME,
		.of_match_table	= zed_oled_of_match,
	},
};
module_platform_driver(zed_oled_driver);

MODULE_AUTHOR("Digilent");
MODULE_DESCRIPTION("ZedBoard on-board OLED driver (GPIO bit-banged SPI)");
MODULE_LICENSE("GPL v2");