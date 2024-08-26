#define DEBUG
#define VERBOSE_DEBUG

#undef DEBUG
#undef VERBOSE_DEBUG

#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/tty.h>
#include <linux/serial.h>
#include <linux/tty_driver.h>
#include <linux/tty_flip.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/uaccess.h>
#include <linux/usb.h>
#include <linux/usb/cdc.h>
#include <asm/byteorder.h>
#include <asm/unaligned.h>
#include <linux/idr.h>
#include <linux/list.h>
#include <linux/version.h>

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(4, 11, 0))
#include <linux/sched/signal.h>
#endif

#include "ch343.h"

#define DRIVER_AUTHOR 			"TECH39"
#define DRIVER_DESC 			"USB serial driver for ch342/ch343/ch344/ch9101/ch9102/ch9103, etc."
#define VERSION_DESC 			"V1.1"

#define IOCTL_MAGIC 'W'
#define IOCTL_CMD_GPIOENABLE 	_IOW(IOCTL_MAGIC, 0x80, u16)
#define IOCTL_CMD_GPIOSET		_IOW(IOCTL_MAGIC, 0x81, u16)
#define IOCTL_CMD_GPIOGET		_IOWR(IOCTL_MAGIC, 0x82, u16)
#define IOCTL_CMD_GPIOINFO		_IOWR(IOCTL_MAGIC, 0x83, u16)
#define IOCTL_CMD_GETCHIPTYPE   _IOR(IOCTL_MAGIC, 0x84, u16)

static struct usb_driver ch343_driver;
static struct tty_driver *ch343_tty_driver;

static DEFINE_IDR(ch343_minors);
static DEFINE_MUTEX(ch343_minors_lock);

static void ch343_tty_set_termios(struct tty_struct *tty,
				struct ktermios *termios_old);

/*
 * Look up an ch343 structure by minor. If found and not disconnected, increment
 * its refcount and return it with its mutex held.
 */
static struct ch343 *ch343_get_by_minor(unsigned int minor)
{
	struct ch343 *ch343;

	mutex_lock(&ch343_minors_lock);
	ch343 = idr_find(&ch343_minors, minor);
	if (ch343) {
		mutex_lock(&ch343->mutex);
		if (ch343->disconnected) {
			mutex_unlock(&ch343->mutex);
			ch343 = NULL;
		} else {
			tty_port_get(&ch343->port);
			mutex_unlock(&ch343->mutex);
		}
	}
	mutex_unlock(&ch343_minors_lock);
	return ch343;
}

/*
 * Try to find an available minor number and if found, associate it with 'ch343'.
 */
static int ch343_alloc_minor(struct ch343 *ch343)
{
	int minor;

	mutex_lock(&ch343_minors_lock);
	minor = idr_alloc(&ch343_minors, ch343, 0, CH343_TTY_MINORS, GFP_KERNEL);
	mutex_unlock(&ch343_minors_lock);

	return minor;
}

/* Release the minor number associated with 'ch343'. */
static void ch343_release_minor(struct ch343 *ch343)
{
	mutex_lock(&ch343_minors_lock);
	idr_remove(&ch343_minors, ch343->minor);
	mutex_unlock(&ch343_minors_lock);
}

/*
 * Functions for CH343 control messages.
 */
static int ch343_control_out(struct ch343 *ch343, u8 request,
                u16 value, u16 index)
{
    int retval;

	retval = usb_autopm_get_interface(ch343->control);
	if (retval)
		return retval;

    retval = usb_control_msg(ch343->dev, usb_sndctrlpipe(ch343->dev, 0),
        request, USB_TYPE_VENDOR | USB_RECIP_DEVICE | USB_DIR_OUT,
        value, index, NULL, 0, DEFAULT_TIMEOUT);

    dev_vdbg(&ch343->control->dev,
           "ch343_control_out(%02x,%02x,%04x,%04x)\n",
            USB_DIR_OUT|0x40, request, value, index);

    usb_autopm_put_interface(ch343->control);

	return retval < 0 ? retval : 0;
}

static int ch343_control_in(struct ch343 *ch343,
                u8 request, u16 value, u16 index,
                char *buf, unsigned bufsize)
{
    int retval;
	int i;

	retval = usb_autopm_get_interface(ch343->control);
	if (retval)
		return retval;

	retval = usb_control_msg(ch343->dev, usb_rcvctrlpipe(ch343->dev, 0), request,
        USB_TYPE_VENDOR | USB_RECIP_DEVICE | USB_DIR_IN,
        value, index, buf, bufsize, DEFAULT_TIMEOUT);

    dev_vdbg(&ch343->control->dev,
        "ch343_control_in(%02x,%02x,%04x,%04x,%p,%u)\n",
        USB_DIR_IN | 0x40, (u8)request, (u16)value, (u16)index, buf,
        (int)bufsize);

	dev_vdbg(&ch343->control->dev,
	        "ch343_control_in result:");
	for (i = 0; i < retval; i++) {
	   dev_vdbg(&ch343->control->dev,
	        "0x%.2x ", (u8)buf[i]);
	}

    usb_autopm_put_interface(ch343->control);

	return retval < 0 ? retval : 0;
}

static inline int ch343_set_control(struct ch343 *ch343, int control)
{
	if (ch343->iface <= 1)
    	return ch343_control_out(ch343, CMD_C2 + ch343->iface,
           		~control, 0x0000);
	else if (ch343->iface <= 3)
    	return ch343_control_out(ch343, CMD_C2 + 0x10 + (ch343->iface - 2),
           		~control, 0x0000);
	else
		return -1;
}

static inline int ch343_set_line(struct ch343 *ch343, struct usb_cdc_line_coding *line)
{
	return 0;
}

static int ch343_get_status(struct ch343 *ch343)
{
	char *buffer;
	int retval;
	const unsigned size = 2;
	unsigned long flags;

	buffer = kmalloc(size, GFP_KERNEL);
	if (!buffer)
		return -ENOMEM;

	retval = ch343_control_in(ch343, CMD_R, CMD_C3 + ch343->iface,
				0, buffer, size);
	if (retval <= 0)
		goto out;

	/* setup the private status if available */
	spin_lock_irqsave(&ch343->read_lock, flags);
	ch343->ctrlin = (~(*buffer)) & CH343_CTI_ST;
	spin_unlock_irqrestore(&ch343->read_lock, flags);

out:
    kfree(buffer);
	return retval;
}

/* -------------------------------------------------------------------------- */

static int ch343_configure(struct ch343 *ch343)
{
	char *buffer;
	int r;
	const unsigned size = 2;
	u8 chiptype;

	buffer = kmalloc(size, GFP_KERNEL);
	if (!buffer)
		return -ENOMEM;

	r = ch343_control_in(ch343, CMD_C6, 0, 0, buffer, size);
	if (r < 0)
		goto out;

	chiptype = buffer[1];

	switch (ch343->idProduct) {
	case 0x55D2:
		if (chiptype == 0x48)
			ch343->chiptype = CHIP_CH342F;
		else if (chiptype == 0x41)
			ch343->chiptype = CHIP_CH342GJK;
		break;
	case 0x55D3:
		if (chiptype == 0x08)
			ch343->chiptype = CHIP_CH343GP;
		else if (chiptype == 0x02)
			ch343->chiptype = CHIP_CH343J;
		else if (chiptype == 0x01)
			ch343->chiptype = CHIP_CH343K;
		else if (chiptype == 0x18)
			ch343->chiptype = CHIP_CH343G_AUTOBAUD;
		break;
	case 0x55D4:
		if (chiptype == 0x08)
			ch343->chiptype = CHIP_CH9102F;
		else if (chiptype == 0x09)
			ch343->chiptype = CHIP_CH9102X;
		break;
	case 0x55D5:
		if (chiptype == 0xC0)
			ch343->chiptype = CHIP_CH344L;
		break;
	case 0x55D7:
		if (chiptype == 0x4B)
			ch343->chiptype = CHIP_CH9103M;
		break;
	case 0x55D8:
		if (chiptype == 0x08)
			ch343->chiptype = CHIP_CH9101UH;
		break;
	default:
		break;
	}
	
	if (ch343->chiptype != CHIP_CH344L) {
		r = ch343_get_status(ch343);
		if (r < 0)
			goto out;
	}

	dev_info(&ch343->data->dev,
		"%s - chip hver : 0x%2x, sver : 0x%2x, chip : %d\n",
		__func__, buffer[0], buffer[1], ch343->chiptype);
out:
    kfree(buffer);
	return r < 0 ? r : 0;
}

/*
 * Write buffer management.
 * All of these assume proper locks taken by the caller.
 */
static int ch343_wb_alloc(struct ch343 *ch343)
{
	int i, wbn;
	struct ch343_wb *wb;

	wbn = 0;
	i = 0;
	for (;;) {
		wb = &ch343->wb[wbn];
		if (!wb->use) {
			wb->use = 1;
			return wbn;
		}
		wbn = (wbn + 1) % CH343_NW;
		if (++i >= CH343_NW)
			return -1;
	}
}

static int ch343_wb_is_avail(struct ch343 *ch343)
{
	int i, n;
	unsigned long flags;

	n = CH343_NW;
	spin_lock_irqsave(&ch343->write_lock, flags);
	for (i = 0; i < CH343_NW; i++)
		n -= ch343->wb[i].use;
	spin_unlock_irqrestore(&ch343->write_lock, flags);
	return n;
}

/*
 * Finish write. Caller must hold ch343->write_lock
 */
static void ch343_write_done(struct ch343 *ch343, struct ch343_wb *wb)
{
	wb->use = 0;
	ch343->transmitting--;
	usb_autopm_put_interface_async(ch343->control);
}

/*
 * Poke write.
 *
 * the caller is responsible for locking
 */
static int ch343_start_wb(struct ch343 *ch343, struct ch343_wb *wb)
{
	int rc;

	ch343->transmitting++;

	wb->urb->transfer_buffer = wb->buf;
	wb->urb->transfer_dma = wb->dmah;
	wb->urb->transfer_buffer_length = wb->len;
	wb->urb->dev = ch343->dev;

	rc = usb_submit_urb(wb->urb, GFP_ATOMIC);
	if (rc < 0) {
		dev_err(&ch343->data->dev,
			"%s - usb_submit_urb(write bulk) failed: %d\n",
			__func__, rc);
		ch343_write_done(ch343, wb);
	}
	return rc;
}

static void ch343_update_status(struct ch343 *ch343,
					unsigned char *data, size_t len)
{
	unsigned long flags;
	u8 status;
	u8 difference;
	u8 type = data[0];

	if (len < 4)
		return;

	if (ch343->chiptype == CHIP_CH344L) {
		if (data[0] != 0x00)
			return;
		type = data[1];
	}

	switch (type) {
	case CH343_CTT_M:
		status = ~data[len - 1] & CH343_CTI_ST;
		if (ch343->chiptype == CHIP_CH344L)
			status &= CH343_CTI_C;

		if (!ch343->clocal && (ch343->ctrlin & status & CH343_CTI_DC)) {
			tty_port_tty_hangup(&ch343->port, false);
		}

		spin_lock_irqsave(&ch343->read_lock, flags);
		difference = status ^ ch343->ctrlin;
		ch343->ctrlin = status;
		ch343->oldcount = ch343->iocount;

		if (!difference) {
			spin_unlock_irqrestore(&ch343->read_lock, flags);
			return;
		}
		if (difference & CH343_CTI_C) {
			ch343->iocount.cts++;
		}
		if (difference & CH343_CTI_DS) {
			ch343->iocount.dsr++;
		}
		if (difference & CH343_CTI_R) {
			ch343->iocount.rng++;
		}
		if (difference & CH343_CTI_DC) {
			ch343->iocount.dcd++;
		}
		spin_unlock_irqrestore(&ch343->read_lock, flags);

		wake_up_interruptible(&ch343->wioctl);
		break;
	case CH343_CTT_O:
		spin_lock_irqsave(&ch343->read_lock, flags);
		ch343->oldcount = ch343->iocount;
		ch343->iocount.overrun++;
		spin_unlock_irqrestore(&ch343->read_lock, flags);
		break;
	case CH343_CTT_P:
		spin_lock_irqsave(&ch343->read_lock, flags);
		ch343->oldcount = ch343->iocount;
		ch343->iocount.parity++;
		spin_unlock_irqrestore(&ch343->read_lock, flags);
		break;
	case CH343_CTT_F:
		spin_lock_irqsave(&ch343->read_lock, flags);
		ch343->oldcount = ch343->iocount;
		ch343->iocount.frame++;
		spin_unlock_irqrestore(&ch343->read_lock, flags);
		break;
	default:
		dev_err(&ch343->control->dev,
			"%s - unknown status received:"
			"len:%d, data0:0x%x, data1:0x%x\n",
			__func__,
			(int)len, data[0], data[1]);
		break;
	}
}

/* Reports status changes with "interrupt" transfers */
static void ch343_ctrl_irq(struct urb *urb)
{
	struct ch343 *ch343 = urb->context;
	unsigned char *data = urb->transfer_buffer;
	unsigned int len = urb->actual_length;
	int status = urb->status;
	int retval;

	switch (status) {
	case 0:
		/* success */
		break;
	case -ECONNRESET:
	case -ENOENT:
	case -ESHUTDOWN:
		/* this urb is terminated, clean up */
		dev_dbg(&ch343->control->dev,
				"%s - urb shutting down with status: %d\n",
				__func__, status);
		return;
	default:
		dev_dbg(&ch343->control->dev,
				"%s - nonzero urb status received: %d\n",
				__func__, status);
		goto exit;
	}

	usb_mark_last_busy(ch343->dev);
	//ch343_update_status(ch343, data, len);
exit:
	retval = usb_submit_urb(urb, GFP_ATOMIC);
	if (retval && retval != -EPERM)
		dev_err(&ch343->control->dev, "%s - usb_submit_urb failed: %d\n",
							__func__, retval);
}

static int ch343_submit_read_urb(struct ch343 *ch343, int index, gfp_t mem_flags)
{
	int res;

	if (!test_and_clear_bit(index, &ch343->read_urbs_free))
		return 0;

	dev_vdbg(&ch343->data->dev, "%s - urb %d\n", __func__, index);

	res = usb_submit_urb(ch343->read_urbs[index], mem_flags);
	if (res) {
		if (res != -EPERM) {
			dev_err(&ch343->data->dev,
					"%s - usb_submit_urb failed: %d\n",
					__func__, res);
		}
		set_bit(index, &ch343->read_urbs_free);
		return res;
	}

	return 0;
}

static int ch343_submit_read_urbs(struct ch343 *ch343, gfp_t mem_flags)
{
	int res;
	int i;

	for (i = 0; i < ch343->rx_buflimit; ++i) {
		res = ch343_submit_read_urb(ch343, i, mem_flags);
		if (res)
			return res;
	}

	return 0;
}

static void ch343_process_read_urb(struct ch343 *ch343, struct urb *urb)
{
	if (!urb->actual_length)
		return;

	tty_insert_flip_string(&ch343->port, urb->transfer_buffer,
			urb->actual_length);
	tty_flip_buffer_push(&ch343->port);
}

static void ch343_read_bulk_callback(struct urb *urb)
{
	struct ch343_rb *rb = urb->context;
	struct ch343 *ch343 = rb->instance;
	int status = urb->status;

	dev_vdbg(&ch343->data->dev, "%s - urb %d, len %d\n", __func__,
					rb->index, urb->actual_length);

	if (!ch343->dev) {
		set_bit(rb->index, &ch343->read_urbs_free);
		dev_dbg(&ch343->data->dev, "%s - disconnected\n", __func__);
		return;
	}

	if (status) {
		set_bit(rb->index, &ch343->read_urbs_free);
		dev_dbg(&ch343->data->dev, "%s - non-zero urb status: %d\n",
							__func__, status);
		return;
	}

	usb_mark_last_busy(ch343->dev);
	ch343_process_read_urb(ch343, urb);
	set_bit(rb->index, &ch343->read_urbs_free);
	ch343_submit_read_urb(ch343, rb->index, GFP_ATOMIC);
}

/* data interface wrote those outgoing bytes */
static void ch343_write_bulk(struct urb *urb)
{
	struct ch343_wb *wb = urb->context;
	struct ch343 *ch343 = wb->instance;
	unsigned long flags;
	int status = urb->status;

	dev_vdbg(&ch343->data->dev, "%s, len %d\n", __func__, urb->actual_length);
	if (status || (urb->actual_length != urb->transfer_buffer_length))
		dev_vdbg(&ch343->data->dev, "%s - len %d/%d, status %d\n",
			__func__,
			urb->actual_length,
			urb->transfer_buffer_length,
			status);

	spin_lock_irqsave(&ch343->write_lock, flags);
	ch343_write_done(ch343, wb);
	spin_unlock_irqrestore(&ch343->write_lock, flags);
	schedule_work(&ch343->work);
}

static void ch343_softint(struct work_struct *work)
{
	struct ch343 *ch343 = container_of(work, struct ch343, work);

	dev_dbg(&ch343->data->dev, "%s\n", __func__);

	tty_port_tty_wakeup(&ch343->port);
}

/*
 * TTY handlers
 */
static int ch343_tty_install(struct tty_driver *driver, struct tty_struct *tty)
{
	struct ch343 *ch343;
	int retval;

	dev_dbg(tty->dev, "%s\n", __func__);

	ch343 = ch343_get_by_minor(tty->index);
	if (!ch343)
		return -ENODEV;

	retval = tty_standard_install(driver, tty);
	if (retval)
		goto error_init_termios;

	tty->driver_data = ch343;

	return 0;

error_init_termios:
	tty_port_put(&ch343->port);
	return retval;
}

static int ch343_tty_open(struct tty_struct *tty, struct file *filp)
{
	struct ch343 *ch343 = tty->driver_data;

	dev_dbg(tty->dev, "%s\n", __func__);

	return tty_port_open(&ch343->port, tty, filp);
}

static void ch343_port_dtr_rts(struct tty_port *port, int raise)
{
	struct ch343 *ch343 = container_of(port, struct ch343, port);
	int res;

	dev_dbg(&ch343->data->dev, "%s, raise:%d\n", __func__, raise);

	if (raise)
		ch343->ctrlout |= CH343_CTO_D | CH343_CTO_R;
	else
		ch343->ctrlout &= ~(CH343_CTO_D | CH343_CTO_R);

	res = ch343_set_control(ch343, ch343->ctrlout);
	if (res)
		dev_err(&ch343->control->dev, "failed to set dtr/rts\n");
}

static int ch343_port_activate(struct tty_port *port, struct tty_struct *tty)
{
	struct ch343 *ch343 = container_of(port, struct ch343, port);
	int retval = -ENODEV;

	dev_dbg(&ch343->control->dev, "%s\n", __func__);

	mutex_lock(&ch343->mutex);
	if (ch343->disconnected)
		goto disconnected;

	retval = usb_autopm_get_interface(ch343->control);
	if (retval)
		goto error_get_interface;

	/*
	 * FIXME: Why do we need this? Allocating 64K of physically contiguous
	 * memory is really nasty...
	 */
	set_bit(TTY_NO_WRITE_SPLIT, &tty->flags);
	ch343->control->needs_remote_wakeup = 1;

	retval = ch343_configure(ch343);
	if (retval)
		goto error_configure;

	ch343_tty_set_termios(tty, NULL);

	usb_autopm_put_interface(ch343->control);

	mutex_unlock(&ch343->mutex);

	return 0;

error_configure:
	usb_autopm_put_interface(ch343->control);
error_get_interface:
disconnected:
	mutex_unlock(&ch343->mutex);

	return usb_translate_errors(retval);
}

static void ch343_port_destruct(struct tty_port *port)
{
	struct ch343 *ch343 = container_of(port, struct ch343, port);

	dev_dbg(&ch343->control->dev, "%s\n", __func__);

	ch343_release_minor(ch343);
	usb_put_intf(ch343->control);
	kfree(ch343);
}

static void ch343_port_shutdown(struct tty_port *port)
{
	struct ch343 *ch343 = container_of(port, struct ch343, port);

	dev_dbg(&ch343->control->dev, "%s\n", __func__);

}

static void ch343_tty_cleanup(struct tty_struct *tty)
{
	struct ch343 *ch343 = tty->driver_data;
	dev_dbg(&ch343->control->dev, "%s\n", __func__);
	tty_port_put(&ch343->port);
}

static void ch343_tty_hangup(struct tty_struct *tty)
{
	struct ch343 *ch343 = tty->driver_data;
	dev_dbg(&ch343->control->dev, "%s\n", __func__);
	tty_port_hangup(&ch343->port);
}

static void ch343_tty_close(struct tty_struct *tty, struct file *filp)
{
	struct ch343 *ch343 = tty->driver_data;
	dev_dbg(&ch343->control->dev, "%s\n", __func__);
	tty_port_close(&ch343->port, tty, filp);
}

static int ch343_tty_write(struct tty_struct *tty,
					const unsigned char *buf, int count)
{
	struct ch343 *ch343 = tty->driver_data;
	int stat;
	unsigned long flags;
	int wbn;
	struct ch343_wb *wb;

	if (!count)
		return 0;

	dev_vdbg(&ch343->data->dev, "%s - count %d\n", __func__, count);

	spin_lock_irqsave(&ch343->write_lock, flags);
	wbn = ch343_wb_alloc(ch343);
	if (wbn < 0) {
		spin_unlock_irqrestore(&ch343->write_lock, flags);
		return 0;
	}
	wb = &ch343->wb[wbn];

	if (!ch343->dev) {
		wb->use = 0;
		spin_unlock_irqrestore(&ch343->write_lock, flags);
		return -ENODEV;
	}

	count = (count > ch343->writesize) ? ch343->writesize : count;

	memcpy(wb->buf, buf, count);
	wb->len = count;

	stat = usb_autopm_get_interface_async(ch343->control);
	if (stat) {
		wb->use = 0;
		spin_unlock_irqrestore(&ch343->write_lock, flags);
		return stat;
	}

	if (ch343->susp_count) {
		usb_anchor_urb(wb->urb, &ch343->delayed);
		spin_unlock_irqrestore(&ch343->write_lock, flags);
		return count;
	}

	stat = ch343_start_wb(ch343, wb);
	spin_unlock_irqrestore(&ch343->write_lock, flags);

	if (stat < 0)
		return stat;
	return count;
}

static int ch343_tty_write_room(struct tty_struct *tty)
{
	struct ch343 *ch343 = tty->driver_data;
	/*
	 * Do not let the line discipline to know that we have a reserve,
	 * or it might get too enthusiastic.
	 */
	return ch343_wb_is_avail(ch343) ? ch343->writesize : 0;
}

static int ch343_tty_chars_in_buffer(struct tty_struct *tty)
{
	struct ch343 *ch343 = tty->driver_data;
	/*
	 * if the device was unplugged then any remaining characters fell out
	 * of the connector ;)
	 */
	if (ch343->disconnected)
		return 0;
	/*
	 * This is inaccurate (overcounts), but it works.
	 */
	return (CH343_NW - ch343_wb_is_avail(ch343)) * ch343->writesize;
}

static int ch343_tty_break_ctl(struct tty_struct *tty, int state)
{
	struct ch343 *ch343 = tty->driver_data;
	int retval;
	uint16_t reg_contents;
	uint8_t *regbuf;

	dev_dbg(&ch343->control->dev, "%s\n", __func__);

	regbuf = kmalloc(2, GFP_KERNEL);
	if (!regbuf)
		return -1;

	if (state != 0) {
		regbuf[0] = CH343_N_B;
		regbuf[1] = 0x00;
	} else {
		regbuf[0] = CH343_N_B | CH343_N_AB;
		regbuf[1] = 0x00;
	}
	reg_contents = get_unaligned_le16(regbuf);

	if (ch343->iface)
		retval = ch343_control_out(ch343, CMD_C4, 0x00,
				reg_contents);
	else
		retval = ch343_control_out(ch343, CMD_C4, reg_contents,
				0x00);

	if (retval < 0)
		dev_err(&ch343->control->dev, "%s - USB control write error (%d)\n",
				__func__, retval);

	kfree(regbuf);

	return retval;
}

static int ch343_tty_tiocmget(struct tty_struct *tty)
{
	struct ch343 *ch343 = tty->driver_data;
	unsigned long flags;
	unsigned int result;

	dev_dbg(&ch343->control->dev, "%s\n", __func__);

	spin_lock_irqsave(&ch343->read_lock, flags);
	result = (ch343->ctrlout & CH343_CTO_D ? TIOCM_DTR : 0) |
	       (ch343->ctrlout & CH343_CTO_R ? TIOCM_RTS : 0) |
		   (ch343->ctrlin  & CH343_CTI_C ? TIOCM_CTS : 0) |
	       (ch343->ctrlin  & CH343_CTI_DS ? TIOCM_DSR : 0) |
	       (ch343->ctrlin  & CH343_CTI_R  ? TIOCM_RI  : 0) |
	       (ch343->ctrlin  & CH343_CTI_DC ? TIOCM_CD  : 0);
	spin_unlock_irqrestore(&ch343->read_lock, flags);

	return result;
}

static int ch343_tty_tiocmset(struct tty_struct *tty,
			    unsigned int set, unsigned int clear)
{
	struct ch343 *ch343 = tty->driver_data;
	unsigned int newctrl;

	dev_dbg(&ch343->control->dev, "%s\n", __func__);

	newctrl = ch343->ctrlout;
	set = (set & TIOCM_DTR ? CH343_CTO_D : 0) |
					(set & TIOCM_RTS ? CH343_CTO_R : 0);
	clear = (clear & TIOCM_DTR ? CH343_CTO_D : 0) |
					(clear & TIOCM_RTS ? CH343_CTO_R : 0);

	newctrl = (newctrl & ~clear) | set;

	if (ch343->ctrlout == newctrl)
		return 0;
	return ch343_set_control(ch343, ch343->ctrlout = newctrl);
}

static int ch343_tty_ioctl(struct tty_struct *tty,
					unsigned int cmd, unsigned long arg)
{
	struct ch343 *ch343 = tty->driver_data;
	int rv = 0;

	unsigned long arg1;
	unsigned long arg2;
	unsigned long arg3;
	u32 inarg;
	u16 inargH, inargL;
	u32 __user *argval = (u32 __user *)arg;

	u8 gbit1, gbit2, gbit3;
	u8 gen1, gd1, gen2, gd2, gen3, gd3;
	u8 gv1, gv2, gv3;

	u16 gev, gdv, gv;
	u16 value, index;
	u8 *buffer;

	dev_dbg(&ch343->control->dev, "%s\n", __func__);

	buffer = kmalloc(8, GFP_KERNEL);
	if (!buffer)
		return -ENOMEM;

	switch (cmd) {
	case TIOCGSERIAL: /* gets serial port data */
		break;
	case TIOCSSERIAL:
		break;
	case TIOCMIWAIT:
		break;
	case TIOCGICOUNT:
		break;
	case IOCTL_CMD_GETCHIPTYPE:
		if (put_user(ch343->chiptype, argval)) {
			rv = -EFAULT;
			goto out;
		}
		break;
	case IOCTL_CMD_GPIOINFO:
		get_user(arg1, (long __user *)arg);
		get_user(arg2, ((long __user *)arg + 1));
		get_user(arg3, ((long __user *)arg + 2));

		rv = ch343_control_in(ch343, CMD_C11, 0x00,
					0x00, buffer, 0x08);
		if (rv < 0)
			goto out;

		gen1 = buffer[0];
		gen2 = buffer[1];
		gen3 = buffer[2];
		rv = ch343_control_in(ch343, CMD_C10, 0x00,
					0x00, buffer, 0x08);
		if (rv < 0)
			goto out;

		gd1 = buffer[0];
		gd2 = buffer[1];
		gd3 = buffer[2];
		gv1 = buffer[3];
		gv2 = buffer[4];
		gv3 = buffer[5];
		gev = gdv = gv = 0x00;

		if (ch343->chiptype == CHIP_CH9102X) {
			if (gen2 & BIT(3))
				gev |= BIT(0);
			if (gen2 & BIT(5))
				gev |= BIT(1);
			if (gen2 & BIT(1))
				gev |= BIT(2);
			if (gen2 & BIT(7))
				gev |= BIT(3);
			if (gen3 & BIT(0))
				gev |= BIT(5);
			if (gen2 & BIT(2))
				gev |= BIT(6);

			if (gd2 & BIT(3))
				gdv |= BIT(0);
			if (gd2 & BIT(5))
				gdv |= BIT(1);
			if (gd2 & BIT(1))
				gdv |= BIT(2);
			if (gd2 & BIT(7))
				gdv |= BIT(3);
			if (gd3 & BIT(0))
				gdv |= BIT(5);
			if (gd2 & BIT(2))
				gdv |= BIT(6);

			if (gv2 & BIT(3))
				gv |= BIT(0);
			if (gv2 & BIT(5))
				gv |= BIT(1);
			if (gv2 & BIT(1))
				gv |= BIT(2);
			if (gv2 & BIT(7))
				gv |= BIT(3);
			if (gv3 & BIT(0))
				gv |= BIT(5);
			if (gv2 & BIT(2))
				gv |= BIT(6);
		} else if (ch343->chiptype == CHIP_CH9102F) {
			if (gen2 & BIT(1))
				gev |= BIT(0);
			if (gen2 & BIT(7))
				gev |= BIT(1);
			if (gen2 & BIT(4))
				gev |= BIT(2);
			if (gen2 & BIT(6))
				gev |= BIT(3);
			if (gen2 & BIT(3))
				gev |= BIT(4);

			if (gd2 & BIT(1))
				gdv |= BIT(0);
			if (gd2 & BIT(7))
				gdv |= BIT(1);
			if (gd2 & BIT(4))
				gdv |= BIT(2);
			if (gd2 & BIT(6))
				gdv |= BIT(3);
			if (gd2 & BIT(3))
				gdv |= BIT(4);

			if (gv2 & BIT(1))
				gv |= BIT(0);
			if (gv2 & BIT(7))
				gv |= BIT(1);
			if (gv2 & BIT(4))
				gv |= BIT(2);
			if (gv2 & BIT(6))
				gv |= BIT(3);
			if (gv2 & BIT(3))
				gv |= BIT(4);
		} else if (ch343->chiptype == CHIP_CH9103M) {
			if (gen1 & BIT(3))
				gev |= BIT(0);
			if (gen1 & BIT(2))
				gev |= BIT(1);
			if (gen3 & BIT(2))
				gev |= BIT(2);
			if (gen2 & BIT(6))
				gev |= BIT(3);
			if (gen1 & BIT(0))
				gev |= BIT(4);
			if (gen1 & BIT(6))
				gev |= BIT(5);
			if (gen2 & BIT(3))
				gev |= BIT(6);
			if (gen2 & BIT(5))
				gev |= BIT(7);
			if (gen3 & BIT(0))
				gev |= BIT(8);
			if (gen2 & BIT(2))
				gev |= BIT(9);
			if (gen1 & BIT(5))
				gev |= BIT(10);
			if (gen2 & BIT(4))
				gev |= BIT(11);

			if (gd1 & BIT(3))
				gdv |= BIT(0);
			if (gd1 & BIT(2))
				gdv |= BIT(1);
			if (gd3 & BIT(2))
				gdv |= BIT(2);
			if (gd2 & BIT(6))
				gdv |= BIT(3);
			if (gd1 & BIT(0))
				gdv |= BIT(4);
			if (gd1 & BIT(6))
				gdv |= BIT(5);
			if (gd2 & BIT(3))
				gdv |= BIT(6);
			if (gd2 & BIT(5))
				gdv |= BIT(7);
			if (gd3 & BIT(0))
				gdv |= BIT(8);
			if (gd2 & BIT(2))
				gdv |= BIT(9);
			if (gd1 & BIT(5))
				gdv |= BIT(10);
			if (gd2 & BIT(4))
				gdv |= BIT(11);

			if (gv1 & BIT(3))
				gv |= BIT(0);
			if (gv1 & BIT(2))
				gv |= BIT(1);
			if (gv3 & BIT(2))
				gv |= BIT(2);
			if (gv2 & BIT(6))
				gv |= BIT(3);
			if (gv1 & BIT(0))
				gv |= BIT(4);
			if (gv1 & BIT(6))
				gv |= BIT(5);
			if (gv2 & BIT(3))
				gv |= BIT(6);
			if (gv2 & BIT(5))
				gv |= BIT(7);
			if (gv3 & BIT(0))
				gv |= BIT(8);
			if (gv2 & BIT(2))
				gv |= BIT(9);
			if (gv1 & BIT(5))
				gv |= BIT(10);
			if (gv2 & BIT(4))
				gv |= BIT(11);
		} else if (ch343->chiptype == CHIP_CH9101UH) {

		}

		put_user(gev, (u16 __user *)arg1);
		put_user(gdv, (u16 __user *)arg2);
		put_user(gv, (u16 __user *)arg3);

		break;
	case IOCTL_CMD_GPIOENABLE:
		if (get_user(inarg, argval)) {
			rv = -EFAULT;
			goto out;
		}
		rv = ch343_control_in(ch343, CMD_C11, 0x00,
					0x00, buffer, 0x08);
		if (rv < 0)
			goto out;

		gen1 = buffer[0];
		gen2 = buffer[1];
		gen3 = buffer[2];

		rv = ch343_control_in(ch343, CMD_C10, 0x00,
					0x00, buffer, 0x08);
		if (rv < 0)
			goto out;

		gd1 = buffer[0];
		gd2 = buffer[1];
		gd3 = buffer[2];
		gv1 = buffer[3];
		gv2 = buffer[4];
		gv3 = buffer[5];

		inargH = inarg >> 16;
		inargL = inarg;

		if (ch343->chiptype == CHIP_CH9102X) {
			if (inargH & BIT(0)) {
				gen2 |= BIT(3);
				if (inargL & BIT(0))
					gd2 |= BIT(3);
				else
					gd2 &= ~BIT(3);
			} else {
				gen2 &= ~BIT(3);
			}
			if (inargH & BIT(1)) {
				gen2 |= BIT(5);
				if (inargL & BIT(1))
					gd2 |= BIT(5);
				else
					gd2 &= ~BIT(5);
			} else
				gen2 &= ~BIT(5);
			if (inargH & BIT(2)) {
				gen2 |= BIT(1);
				if (inargL & BIT(2))
					gd2 |= BIT(1);
				else
					gd2 &= ~BIT(1);
			} else
				gen2 &= ~BIT(1);
			if (inargH & BIT(3)) {
				gen2 |= BIT(7);
				if (inargL & BIT(3))
					gd2 |= BIT(7);
				else
					gd2 &= ~BIT(7);
			} else
				gen2 &= ~BIT(7);
			if (inargH & BIT(5)) {
				gen3 |= BIT(0);
				if (inargL & BIT(5))
					gd3 |= BIT(0);
				else
					gd3 &= ~BIT(0);
			} else
				gen2 &= ~BIT(7);
			if (inargH & BIT(6)) {
				gen2 |= BIT(2);
				if (inargL & BIT(6))
					gd2 |= BIT(2);
				else
					gd2 &= ~BIT(2);
			} else
				gen2 &= ~BIT(2);
		} else if (ch343->chiptype == CHIP_CH9102F) {
			if (inargH & BIT(0)) {
				gen2 |= BIT(1);
				if (inargL & BIT(0))
					gd2 |= BIT(1);
				else
					gd2 &= ~BIT(1);
			} else
				gen2 &= ~BIT(1);
			if (inargH & BIT(1)) {
				gen2 |= BIT(7);
				if (inargL & BIT(1))
					gd2 |= BIT(7);
				else
					gd2 &= ~BIT(7);
			} else
				gen2 &= ~BIT(7);
			if (inargH & BIT(2)) {
				gen2 |= BIT(4);
				if (inargL & BIT(2))
					gd2 |= BIT(4);
				else
					gd2 &= ~BIT(4);
			} else
				gen2 &= ~BIT(4);
			if (inargH & BIT(3)) {
				gen2 |= BIT(6);
				if (inargL & BIT(3))
					gd2 |= BIT(6);
				else
					gd2 &= ~BIT(6);
			} else
				gen2 &= ~BIT(6);
			if (inargH & BIT(4)) {
				gen2 |= BIT(3);
				if (inargL & BIT(4))
					gd2 |= BIT(3);
				else
					gd2 &= ~BIT(3);
			} else
				gen2 &= ~BIT(3);
		} else if (ch343->chiptype == CHIP_CH9103M) {
			if (inargH & BIT(0)) {
				gen1 |= BIT(3);
				if (inargL & BIT(0))
					gd1 |= BIT(3);
				else
					gd1 &= ~BIT(3);
			} else
				gen1 &= ~BIT(3);
			if (inargH & BIT(1)) {
				gen1 |= BIT(2);
				if (inargL & BIT(1))
					gd1 |= BIT(2);
				else
					gd1 &= ~BIT(2);
			} else
				gen1 &= ~BIT(2);
			if (inargH & BIT(2)) {
				gen3 |= BIT(2);
				if (inargL & BIT(2))
					gd3 |= BIT(2);
				else
					gd3 &= ~BIT(2);
			} else
				gen3 &= ~BIT(2);
			if (inargH & BIT(3)) {
				gen2 |= BIT(6);
				if (inargL & BIT(3))
					gd2 |= BIT(6);
				else
					gd2 &= ~BIT(6);
			} else
				gen2 &= ~BIT(6);
			if (inargH & BIT(4)) {
				gen1 |= BIT(0);
				if (inargL & BIT(4))
					gd1 |= BIT(0);
				else
					gd1 &= ~BIT(0);
			} else
				gen1 &= ~BIT(0);
			if (inargH & BIT(5)) {
				gen1 |= BIT(6);
				if (inargL & BIT(5))
					gd1 |= BIT(6);
				else
					gd1 &= ~BIT(6);
			} else
				gen1 &= ~BIT(6);
			if (inargH & BIT(6)) {
				gen2 |= BIT(3);
				if (inargL & BIT(6))
					gd2 |= BIT(3);
				else
					gd2 &= ~BIT(3);
			} else
				gen2 &= ~BIT(3);
			if (inargH & BIT(7)) {
				gen2 |= BIT(5);
				if (inargL & BIT(7))
					gd2 |= BIT(5);
				else
					gd2 &= ~BIT(5);
			} else
				gen2 &= ~BIT(5);
			if (inargH & BIT(8)) {
				gen3 |= BIT(0);
				if (inargL & BIT(8))
					gd3 |= BIT(0);
				else
					gd3 &= ~BIT(0);
			} else
				gen3 &= ~BIT(0);
			if (inargH & BIT(9)) {
				gen2 |= BIT(2);
				if (inargL & BIT(9))
					gd2 |= BIT(2);
				else
					gd2 &= ~BIT(2);
			} else
				gen2 &= ~BIT(2);
			if (inargH & BIT(10)) {
				gen1 |= BIT(5);
				if (inargL & BIT(10))
					gd1 |= BIT(5);
				else
					gd1 &= ~BIT(5);
			} else
				gen1 &= ~BIT(5);
			if (inargH & BIT(11)) {
				gen2 |= BIT(4);
				if (inargL & BIT(11))
					gd2 |= BIT(4);
				else
					gd2 &= ~BIT(4);
			} else
				gen2 &= ~BIT(4);
		} else if (ch343->chiptype == CHIP_CH9101UH) {
			if (inargH & BIT(0)) {
				gen2 |= BIT(6);
				if (inargL & BIT(0))
					gd2 |= BIT(6);
				else
					gd2 &= ~BIT(6);
			} else
				gen2 &= ~BIT(6);
			if (inargH & BIT(1)) {
				gen2 |= BIT(0);
				if (inargL & BIT(1))
					gd2 |= BIT(0);
				else
					gd2 &= ~BIT(0);
			} else
				gen2 &= ~BIT(0);
			if (inargH & BIT(2)) {
				gen1 |= BIT(2);
				if (inargL & BIT(2))
					gd1 |= BIT(2);
				else
					gd1 &= ~BIT(2);
			} else
				gen1 &= ~BIT(2);
			if (inargH & BIT(3)) {
				gen2 |= BIT(2);
				if (inargL & BIT(3))
					gd2 |= BIT(2);
				else
					gd2 &= ~BIT(2);
			} else
				gen2 &= ~BIT(2);
			if (inargH & BIT(4)) {
				gen1 |= BIT(5);
				if (inargL & BIT(4))
					gd1 |= BIT(5);
				else
					gd1 &= ~BIT(5);
			} else
				gen1 &= ~BIT(5);
			if (inargH & BIT(5)) {
				gen1 |= BIT(4);
				if (inargL & BIT(5))
					gd1 |= BIT(4);
				else
					gd1 &= ~BIT(4);
			} else
				gen1 &= ~BIT(4);
			if (inargH & BIT(6)) {
				gen2 |= BIT(4);
				if (inargL & BIT(6))
					gd2 |= BIT(4);
				else
					gd2 &= ~BIT(4);
			} else
				gen2 &= ~BIT(4);
		}
		value = gen1 + ((u16)gd1 << 8);
		index = gen2 + ((u16)gd2 << 8);
		rv = ch343_control_out(ch343, CMD_C7, value, index);
		if (rv < 0)
			goto out;
		value = gd3 + ((u16)gv3 << 8);
		index = gen3;
		rv = ch343_control_out(ch343, CMD_C8, value, index);
		if (rv < 0)
			goto out;

		break;
	case IOCTL_CMD_GPIOSET:
		if (get_user(inarg, argval)) {
			rv = -EFAULT;
			goto out;
		}

		rv = ch343_control_in(ch343, CMD_C11, 0x00,
					0x00, buffer, 0x08);
		if (rv < 0)
			goto out;

		gen1 = buffer[0];
		gen2 = buffer[1];
		gen3 = buffer[2];

		rv = ch343_control_in(ch343, CMD_C10, 0x00,
					0x00, buffer, 0x08);
		if (rv < 0)
			goto out;

		gd1 = buffer[0];
		gd2 = buffer[1];
		gd3 = buffer[2];
		gv1 = buffer[3];
		gv2 = buffer[4];
		gv3 = buffer[5];

		inargH = inarg >> 16;
		inargL = inarg;

		gbit1 = gbit2 = gbit3 = 0x00;

		if (ch343->chiptype == CHIP_CH9102X) {
			if ((inargH & BIT(0)) && (gen2 & BIT(3)) && (gd2 & BIT(3))) {
				gbit2 |= BIT(3);
				if (inargL & BIT(0))
					gv2 |= BIT(3);
				else
					gv2 &= ~BIT(3);
			}
			if ((inargH & BIT(1)) && (gen2 & BIT(5)) && (gd2 & BIT(5))) {
				gbit2 |= BIT(5);
				if (inargL & BIT(1))
					gv2 |= BIT(5);
				else
					gv2 &= ~BIT(5);
			}
			if ((inargH & BIT(2)) && (gen2 & BIT(1)) && (gd2 & BIT(1))) {
				gbit2 |= BIT(1);
				if (inargL & BIT(2))
					gv2 |= BIT(1);
				else
					gv2 &= ~BIT(1);
			}
			if ((inargH & BIT(3)) && (gen2 & BIT(7)) && (gd2 & BIT(7))) {
				gbit2 |= BIT(7);
				if (inargL & BIT(3))
					gv2 |= BIT(7);
				else
					gv2 &= ~BIT(7);
			}
			if ((inargH & BIT(5)) && (gen3 & BIT(0)) && (gd3 & BIT(0))) {
				gbit3 |= BIT(0);
				if (inargL & BIT(5))
					gv3 |= BIT(0);
				else
					gv3 &= ~BIT(0);
			}
			if ((inargH & BIT(6)) && (gen2 & BIT(2)) && (gd2 & BIT(2))) {
				gbit2 |= BIT(2);
				if (inargL & BIT(6))
					gv2 |= BIT(2);
				else
					gv2 &= ~BIT(2);
			}
		} else if (ch343->chiptype == CHIP_CH9102F) {
			if ((inargH & BIT(0)) && (gen2 & BIT(1)) && (gd2 & BIT(1))) {
				gbit2 |= BIT(1);
				if (inargL & BIT(0))
					gv2 |= BIT(1);
				else
					gv2 &= ~BIT(1);
			}
			if ((inargH & BIT(1)) && (gen2 & BIT(7)) && (gd2 & BIT(7))) {
				gbit2 |= BIT(7);
				if (inargL & BIT(1))
					gv2 |= BIT(7);
				else
					gv2 &= ~BIT(7);
			}
			if ((inargH & BIT(2)) && (gen2 & BIT(4)) && (gd2 & BIT(4))) {
				gbit2 |= BIT(4);
				if (inargL & BIT(2))
					gv2 |= BIT(4);
				else
					gv2 &= ~BIT(4);
			}
			if ((inargH & BIT(3)) && (gen2 & BIT(6)) && (gd2 & BIT(6))) {
				gbit2 |= BIT(6);
				if (inargL & BIT(3))
					gv2 |= BIT(6);
				else
					gv2 &= ~BIT(6);
			}
			if ((inargH & BIT(4)) && (gen2 & BIT(3)) && (gd2 & BIT(3))) {
				gbit2 |= BIT(3);
				if (inargL & BIT(4))
					gv2 |= BIT(3);
				else
					gv2 &= ~BIT(3);
			}
		} else if (ch343->chiptype == CHIP_CH9103M) {
			if ((inargH & BIT(0)) && (gen1 & BIT(3)) && (gd1 & BIT(3))) {
				gbit1 |= BIT(3);
				if (inargL & BIT(0))
					gv1 |= BIT(3);
				else
					gv1 &= ~BIT(3);
			}
			if ((inargH & BIT(1)) && (gen1 & BIT(2)) && (gd1 & BIT(2))) {
				gbit1 |= BIT(2);
				if (inargL & BIT(1))
					gv1 |= BIT(2);
				else
					gv1 &= ~BIT(2);
			}
			if ((inargH & BIT(2)) && (gen3 & BIT(2)) && (gd3 & BIT(2))) {
				gbit3 |= BIT(2);
				if (inargL & BIT(2))
					gv3 |= BIT(2);
				else
					gv3 &= ~BIT(2);
			}
			if ((inargH & BIT(3)) && (gen2 & BIT(6)) && (gd2 & BIT(6))) {
				gbit2 |= BIT(6);
				if (inargL & BIT(3))
					gv2 |= BIT(6);
				else
					gv2 &= ~BIT(6);
			}
			if ((inargH & BIT(4)) && (gen1 & BIT(0)) && (gd1 & BIT(0))) {
				gbit1 |= BIT(0);
				if (inargL & BIT(4))
					gv1 |= BIT(0);
				else
					gv1 &= ~BIT(0);
			}
			if ((inargH & BIT(5)) && (gen1 & BIT(6)) && (gd1 & BIT(6))) {
				gbit1 |= BIT(6);
				if (inargL & BIT(5))
					gv1 |= BIT(6);
				else
					gv1 &= ~BIT(6);
			}
			if ((inargH & BIT(6)) && (gen2 & BIT(3)) && (gd2 & BIT(3))) {
				gbit2 |= BIT(3);
				if (inargL & BIT(6))
					gv2 |= BIT(3);
				else
					gv2 &= ~BIT(3);
			}
			if ((inargH & BIT(7)) && (gen2 & BIT(5)) && (gd2 & BIT(5))) {
				gbit2 |= BIT(5);
				if (inargL & BIT(7))
					gv2 |= BIT(5);
				else
					gv2 &= ~BIT(5);
			}
			if ((inargH & BIT(8)) && (gen3 & BIT(0)) && (gd3 & BIT(0))) {
				gbit3 |= BIT(0);
				if (inargL & BIT(8))
					gv3 |= BIT(0);
				else
					gv3 &= ~BIT(0);
			}
			if ((inargH & BIT(9)) && (gen2 & BIT(2)) && (gd2 & BIT(2))) {
				gbit2 |= BIT(2);
				if (inargL & BIT(9))
					gv2 |= BIT(2);
				else
					gv2 &= ~BIT(2);
			}
			if ((inargH & BIT(10)) && (gen1 & BIT(5)) && (gd1 & BIT(5))) {
				gbit1 |= BIT(5);
				if (inargL & BIT(10))
					gv1 |= BIT(5);
				else
					gv1 &= ~BIT(5);
			}
			if ((inargH & BIT(11)) && (gen2 & BIT(4)) && (gd2 & BIT(4))) {
				gbit2 |= BIT(4);
				if (inargL & BIT(11))
					gv2 |= BIT(4);
				else
					gv2 &= ~BIT(4);
			}
		} else if (ch343->chiptype == CHIP_CH9101UH) {
			if ((inargH & BIT(0)) && (gen2 & BIT(6)) && (gd2 & BIT(6))) {
				gbit2 |= BIT(6);
				if (inargL & BIT(0))
					gv2 |= BIT(6);
				else
					gv2 &= ~BIT(6);
			}
			if ((inargH & BIT(1)) && (gen2 & BIT(0)) && (gd2 & BIT(0))) {
				gbit2 |= BIT(0);
				if (inargL & BIT(1))
					gv2 |= BIT(0);
				else
					gv2 &= ~BIT(0);
			}
			if ((inargH & BIT(2)) && (gen1 & BIT(2)) && (gd1 & BIT(2))) {
				gbit1 |= BIT(2);
				if (inargL & BIT(2))
					gv1 |= BIT(2);
				else
					gv1 &= ~BIT(2);
			}
			if ((inargH & BIT(3)) && (gen2 & BIT(2)) && (gd2 & BIT(2))) {
				gbit2 |= BIT(2);
				if (inargL & BIT(3))
					gv2 |= BIT(2);
				else
					gv2 &= ~BIT(2);
			}
			if ((inargH & BIT(4)) && (gen1 & BIT(5)) && (gd1 & BIT(5))) {
				gbit1 |= BIT(5);
				if (inargL & BIT(4))
					gv1 |= BIT(5);
				else
					gv1 &= ~BIT(5);
			}
			if ((inargH & BIT(5)) && (gen1 & BIT(4)) && (gd1 & BIT(4))) {
				gbit1 |= BIT(4);
				if (inargL & BIT(5))
					gv1 |= BIT(4);
				else
					gv1 &= ~BIT(4);
			}
			if ((inargH & BIT(6)) && (gen2 & BIT(4)) && (gd2 & BIT(4))) {
				gbit2 |= BIT(4);
				if (inargL & BIT(6))
					gv2 |= BIT(4);
				else
					gv2 &= ~BIT(4);
			}

		}

		value = gbit1 + ((u16)gv1 << 8);
		index = gbit2 + ((u16)gv2 << 8);
		rv = ch343_control_out(ch343, CMD_C9, value, index);
		if (rv < 0)
			goto out;

		value = gd3 + ((u16)gv3 << 8);
		index = gen3;
		rv = ch343_control_out(ch343, CMD_C8, value, index);
		if (rv < 0)
			goto out;

		break;
	case IOCTL_CMD_GPIOGET:
		if (get_user(inarg, argval)) {
			rv = -EFAULT;
			goto out;
		}

		rv = ch343_control_in(ch343, CMD_C10, 0x00,
					0x00, buffer, 0x08);
		if (rv < 0)
			goto out;

		gd1 = buffer[0];
		gd2 = buffer[1];
		gd3 = buffer[2];
		gv1 = buffer[3];
		gv2 = buffer[4];
		gv3 = buffer[5];

		if (ch343->chiptype == CHIP_CH9102X) {
			if (gv2 & BIT(3))
				gv |= BIT(0);
			if (gv2 & BIT(5))
				gv |= BIT(1);
			if (gv2 & BIT(1))
				gv |= BIT(2);
			if (gv2 & BIT(7))
				gv |= BIT(3);
			if (gv3 & BIT(0))
				gv |= BIT(5);
			if (gv2 & BIT(2))
				gv |= BIT(6);
		} else if (ch343->chiptype == CHIP_CH9102F) {
			if (gv2 & BIT(1))
				gv |= BIT(0);
			if (gv2 & BIT(7))
				gv |= BIT(1);
			if (gv2 & BIT(4))
				gv |= BIT(2);
			if (gv2 & BIT(6))
				gv |= BIT(3);
			if (gv2 & BIT(3))
				gv |= BIT(4);
		} else if (ch343->chiptype == CHIP_CH9103M) {
			if (gv1 & BIT(3))
				gv |= BIT(0);
			if (gv1 & BIT(2))
				gv |= BIT(1);
			if (gv3 & BIT(2))
				gv |= BIT(2);
			if (gv2 & BIT(6))
				gv |= BIT(3);
			if (gv1 & BIT(0))
				gv |= BIT(4);
			if (gv1 & BIT(6))
				gv |= BIT(5);
			if (gv2 & BIT(3))
				gv |= BIT(6);
			if (gv2 & BIT(5))
				gv |= BIT(7);
			if (gv3 & BIT(0))
				gv |= BIT(8);
			if (gv2 & BIT(2))
				gv |= BIT(9);
			if (gv1 & BIT(5))
				gv |= BIT(10);
			if (gv2 & BIT(4))
				gv |= BIT(11);
		} else if (ch343->chiptype == CHIP_CH9101UH) {
			if (gv2 & BIT(6))
				gv |= BIT(0);
			if (gv2 & BIT(0))
				gv |= BIT(1);
			if (gv1 & BIT(2))
				gv |= BIT(2);
			if (gv2 & BIT(2))
				gv |= BIT(3);
			if (gv1 & BIT(5))
				gv |= BIT(4);
			if (gv1 & BIT(4))
				gv |= BIT(5);
			if (gv2 & BIT(4))
				gv |= BIT(6);
		}

		if (put_user(gv, argval)) {
			rv = -EFAULT;
			goto out;
		}
		break;
	default:
		rv = -ENOIOCTLCMD;
		break;
	}

out:
	kfree(buffer);
	return rv;
}

static int ch343_get(unsigned int bval,
		unsigned char *fct, unsigned char *dvs)
{
	unsigned char a;
	unsigned char b;
	unsigned long c;

	switch (bval) {
	case 6000000:
	case 4000000:
	case 2400000:
	case 921600:
	case 307200:
	case 256000:
		b = 7;
		c = 12000000;
		break;
	default:
		if (bval > 6000000/255) {
			b = 3;
			c = 6000000;
		} else if (bval > 750000/255) {
			b = 2;
			c = 750000;
		} else if (bval > 93750/255) {
			b = 1;
			c = 93750;
		} else {
			b = 0;
			c = 11719;
		}
		break;
	}
	a = (unsigned char)(c / bval);
	if (a == 0 || a == 0xFF)
		return -EINVAL;
	if ((c / a - bval) > (bval - c / (a + 1)))
		a ++;
	a = 256 - a;

	*fct = a;
	*dvs = b;

	return 0;
}

static void ch343_tty_set_termios(struct tty_struct *tty,
						struct ktermios *termios_old)
{
	struct ch343 *ch343 = tty->driver_data;
	struct ktermios *termios = &tty->termios;
	struct usb_ch343_line_coding newline;
	int newctrl = ch343->ctrlout;

	unsigned char dvs = 0;
	unsigned char reg_count = 0;
	unsigned char fct = 0;
	unsigned char reg_value = 0;
	unsigned short value = 0;
	unsigned short index = 0;

	dev_dbg(tty->dev, "%s\n", __func__);

	if (termios_old &&
		!tty_termios_hw_change(&tty->termios, termios_old)) {
		return;
	}

	newline.dwDTERate = tty_get_baud_rate(tty);

	if (newline.dwDTERate == 0)
			newline.dwDTERate = 9600;
    ch343_get(newline.dwDTERate, &fct, &dvs);

	newline.bCharFormat = termios->c_cflag & CSTOPB ? 2 : 1;
	if (newline.bCharFormat == 2)
	    reg_value |= CH343_L_SB;

	newline.bParityType = termios->c_cflag & PARENB ?
				(termios->c_cflag & PARODD ? 1 : 2) +
				(termios->c_cflag & CMSPAR ? 2 : 0) : 0;

	switch (newline.bParityType) {
    case 0x01:
        reg_value |= CH343_L_P_O;
        break;
    case 0x02:
		reg_value |= CH343_L_P_E;
        break;
    case 0x03:
		reg_value |= CH343_L_P_M;
        break;
    case 0x04:
		reg_value |= CH343_L_P_S;
        break;
    default:
        break;
	}

	switch (termios->c_cflag & CSIZE) {
	case CS5:
		newline.bDataBits = 5;
		reg_value |= CH343_L_C5;
		break;
	case CS6:
		newline.bDataBits = 6;
		reg_value |= CH343_L_C6;
		break;
	case CS7:
		newline.bDataBits = 7;
		reg_value |= CH343_L_C7;
		break;
	case CS8:
	default:
		newline.bDataBits = 8;
		reg_value |= CH343_L_C8;
		break;
	}

	/* FIXME: Needs to clear unsupported bits in the termios */
	ch343->clocal = ((termios->c_cflag & CLOCAL) != 0);

	if (C_BAUD(tty) == B0) {
		newline.dwDTERate = ch343->line.dwDTERate;
		newctrl &= ~CH343_CTO_D;
	} else if (termios_old && (termios_old->c_cflag & CBAUD) == B0) {
		newctrl |= CH343_CTO_D;
	}

	reg_value |= CH343_L_E_R | CH343_L_E_T;
	reg_count |= CH343_L_R_CT | CH343_L_R_CL | CH343_L_R_T;

	value |= reg_count;
	value |= (unsigned short)reg_value << 8;

	index |= 0x00 | dvs;
	index |= (unsigned short)fct << 8;
	if (ch343->iface <= 1)
		ch343_control_out(ch343, CMD_C1 + ch343->iface, value, index);
	else if (ch343->iface <= 3)
		ch343_control_out(ch343, CMD_C1 + 0x10 + (ch343->iface - 2), value, index);

	if (memcmp(&ch343->line, &newline, sizeof newline)) {
		memcpy(&ch343->line, &newline, sizeof newline);
		dev_dbg(&ch343->control->dev, "%s - set line: %d %d %d %d\n",
			__func__,
			newline.dwDTERate,
			newline.bCharFormat, newline.bParityType,
			newline.bDataBits);
	}

	if (C_CRTSCTS(tty)) {
		newctrl |= CH343_CTO_A | CH343_CTO_R;
	} else
		newctrl &= ~CH343_CTO_A;

	if (newctrl != ch343->ctrlout)
		ch343_set_control(ch343, ch343->ctrlout = newctrl);
}

static const struct tty_port_operations ch343_port_ops = {
	.dtr_rts = ch343_port_dtr_rts,
	.shutdown = ch343_port_shutdown,
	.activate = ch343_port_activate,
	.destruct = ch343_port_destruct,
};

/* Little helpers: write/read buffers free */
static void ch343_write_buffers_free(struct ch343 *ch343)
{
	int i;
	struct ch343_wb *wb;
	struct usb_device *usb_dev = interface_to_usbdev(ch343->control);

	for (wb = &ch343->wb[0], i = 0; i < CH343_NW; i++, wb++)
		usb_free_coherent(usb_dev, ch343->writesize, wb->buf, wb->dmah);
}

static void ch343_read_buffers_free(struct ch343 *ch343)
{
	struct usb_device *usb_dev = interface_to_usbdev(ch343->control);
	int i;

	for (i = 0; i < ch343->rx_buflimit; i++)
		usb_free_coherent(usb_dev, ch343->readsize,
			  ch343->read_buffers[i].base, ch343->read_buffers[i].dma);
}

/* Little helper: write buffers allocate */
static int ch343_write_buffers_alloc(struct ch343 *ch343)
{
	int i;
	struct ch343_wb *wb;

	for (wb = &ch343->wb[0], i = 0; i < CH343_NW; i++, wb++) {
		wb->buf = usb_alloc_coherent(ch343->dev, ch343->writesize, GFP_KERNEL,
		    &wb->dmah);
		if (!wb->buf) {
			while (i != 0) {
				--i;
				--wb;
				usb_free_coherent(ch343->dev, ch343->writesize,
				    wb->buf, wb->dmah);
			}
			return -ENOMEM;
		}
	}
	return 0;
}

/*
 * USB probe and disconnect routines.
 */
static int ch343_probe(struct usb_interface *intf,
		     const struct usb_device_id *id)
{
 	struct usb_cdc_union_desc *union_header = NULL;
	unsigned char *buffer = intf->altsetting->extra;
	int buflen = intf->altsetting->extralen;
	struct usb_interface *control_interface;
	struct usb_interface *data_interface;
	struct usb_endpoint_descriptor *epctrl = NULL;
	struct usb_endpoint_descriptor *epread = NULL;
	struct usb_endpoint_descriptor *epwrite = NULL;
	struct usb_device *usb_dev = interface_to_usbdev(intf);
	struct ch343 *ch343;
	int minor;
	int ctrlsize, readsize;
	u8 *buf;
	unsigned long quirks;
	int num_rx_buf = CH343_NR;
	int i;
	unsigned int elength = 0;
	struct device *tty_dev;
	int rv = -ENOMEM;

	/* normal quirks */
	quirks = (unsigned long)id->driver_info;
	if (!buffer) {
		dev_err(&intf->dev, "Weird descriptor references\n");
		return -EINVAL;
	}

	while (buflen > 0) {
		elength = buffer[0];
		if (!elength) {
			dev_err(&intf->dev, "skipping garbage byte\n");
			elength = 1;
			goto next_desc;
		}
		if (buffer[1] != USB_DT_CS_INTERFACE) {
			dev_err(&intf->dev, "skipping garbage\n");
			goto next_desc;
		}

		switch (buffer[2]) {
		case USB_CDC_UNION_TYPE: /* we've found it */
			if (elength < sizeof(struct usb_cdc_union_desc))
				goto next_desc;
			if (union_header) {
				dev_err(&intf->dev, "More than one "
					"union descriptor, skipping ...\n");
				goto next_desc;
			}
			union_header = (struct usb_cdc_union_desc *)buffer;
			break;
		default:
			/*
			 * there are LOTS more CDC descriptors that
			 * could legitimately be found here.
			 */
			break;
		}
next_desc:
		buflen -= elength;
		buffer += elength;
	}

	control_interface = usb_ifnum_to_if(usb_dev, union_header->bMasterInterface0);
	data_interface = usb_ifnum_to_if(usb_dev, union_header->bSlaveInterface0);

	if (intf != control_interface)
		return -ENODEV;

	if (usb_interface_claimed(data_interface)) {
		dev_dbg(&intf->dev, "The data interface isn't available\n");
		return -EBUSY;
	}

	if (data_interface->cur_altsetting->desc.bNumEndpoints < 2 ||
	    control_interface->cur_altsetting->desc.bNumEndpoints == 0)
		return -EINVAL;

	epctrl = &control_interface->cur_altsetting->endpoint[0].desc;
	epwrite = &data_interface->cur_altsetting->endpoint[0].desc;
	epread = &data_interface->cur_altsetting->endpoint[1].desc;

	/* workaround for switched endpoints */
	if (!usb_endpoint_dir_in(epread)) {
		/* descriptors are swapped */
		dev_dbg(&intf->dev,
			"The data interface has switched endpoints\n");
		swap(epread, epwrite);
	}

	ch343 = kzalloc(sizeof(struct ch343), GFP_KERNEL);
	if (ch343 == NULL)
		goto alloc_fail;

	ch343->idVendor = id->idVendor;
	ch343->idProduct = id->idProduct;
	ch343->iface = control_interface->cur_altsetting->desc.bInterfaceNumber / 2;

	dev_dbg(&intf->dev, "interface %d is valid\n", ch343->iface);

	minor = ch343_alloc_minor(ch343);
	if (minor < 0) {
		dev_err(&intf->dev, "no more free ch343 devices\n");
		kfree(ch343);
		return -ENODEV;
	}

	ctrlsize = usb_endpoint_maxp(epctrl);
	readsize = usb_endpoint_maxp(epread) *
				(quirks == SINGLE_RX_URB ? 1 : 2);
	ch343->writesize = usb_endpoint_maxp(epwrite) * 20;
	ch343->control = control_interface;
	ch343->data = data_interface;
	ch343->minor = minor;
	ch343->dev = usb_dev;
	ch343->ctrlsize = ctrlsize;
	ch343->readsize = readsize;
	ch343->rx_buflimit = num_rx_buf;

	dev_dbg(&intf->dev, "ep%d ctrl: %d, ep%d read: %d, ep%d write: %d\n",
		usb_endpoint_num(epctrl), usb_endpoint_maxp(epctrl),
		usb_endpoint_num(epread), usb_endpoint_maxp(epread),
		usb_endpoint_num(epwrite), usb_endpoint_maxp(epwrite));

	INIT_WORK(&ch343->work, ch343_softint);
	init_waitqueue_head(&ch343->wioctl);
	spin_lock_init(&ch343->write_lock);
	spin_lock_init(&ch343->read_lock);
	mutex_init(&ch343->mutex);
	ch343->rx_endpoint = usb_rcvbulkpipe(usb_dev, epread->bEndpointAddress);
	tty_port_init(&ch343->port);
	ch343->port.ops = &ch343_port_ops;
	init_usb_anchor(&ch343->delayed);
	ch343->quirks = quirks;

	buf = usb_alloc_coherent(usb_dev, ctrlsize, GFP_KERNEL, &ch343->ctrl_dma);
	if (!buf)
		goto alloc_fail2;
	ch343->ctrl_buffer = buf;

	if (ch343_write_buffers_alloc(ch343) < 0)
		goto alloc_fail4;

	ch343->ctrlurb = usb_alloc_urb(0, GFP_KERNEL);
	if (!ch343->ctrlurb)
		goto alloc_fail5;

	for (i = 0; i < num_rx_buf; i++) {
		struct ch343_rb *rb = &(ch343->read_buffers[i]);
		struct urb *urb;

		rb->base = usb_alloc_coherent(ch343->dev, readsize, GFP_KERNEL,
								&rb->dma);
		if (!rb->base)
			goto alloc_fail6;
		rb->index = i;
		rb->instance = ch343;

		urb = usb_alloc_urb(0, GFP_KERNEL);
		if (!urb)
			goto alloc_fail6;

		urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
		urb->transfer_dma = rb->dma;
		usb_fill_bulk_urb(urb, ch343->dev,
			ch343->rx_endpoint,
			rb->base,
			ch343->readsize,
			ch343_read_bulk_callback, rb);

		ch343->read_urbs[i] = urb;
		__set_bit(i, &ch343->read_urbs_free);
	}
	for (i = 0; i < CH343_NW; i++) {
		struct ch343_wb *snd = &(ch343->wb[i]);

		snd->urb = usb_alloc_urb(0, GFP_KERNEL);
		if (snd->urb == NULL)
			goto alloc_fail7;

		usb_fill_bulk_urb(snd->urb, usb_dev,
			usb_sndbulkpipe(usb_dev, epwrite->bEndpointAddress),
			NULL, ch343->writesize, ch343_write_bulk, snd);
		snd->urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
		snd->instance = ch343;
	}

	usb_set_intfdata(intf, ch343);

	usb_fill_int_urb(ch343->ctrlurb, usb_dev,
			 usb_rcvintpipe(usb_dev, epctrl->bEndpointAddress),
			 ch343->ctrl_buffer, ctrlsize, ch343_ctrl_irq, ch343,
			 epctrl->bInterval ? epctrl->bInterval : 16);
	ch343->ctrlurb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
	ch343->ctrlurb->transfer_dma = ch343->ctrl_dma;

	dev_info(&intf->dev, "ttyCH343USB%d: usb to uart device\n", minor);

	usb_driver_claim_interface(&ch343_driver, data_interface, ch343);
	usb_set_intfdata(data_interface, ch343);

	usb_get_intf(control_interface);
	tty_dev = tty_port_register_device(&ch343->port, ch343_tty_driver, minor,
			&control_interface->dev);
	if (IS_ERR(tty_dev)) {
		rv = PTR_ERR(tty_dev);
		goto alloc_fail7;
	}

	if (quirks & CLEAR_HALT_CONDITIONS) {
		usb_clear_halt(usb_dev, usb_rcvbulkpipe(usb_dev, epread->bEndpointAddress));
		usb_clear_halt(usb_dev, usb_sndbulkpipe(usb_dev, epwrite->bEndpointAddress));
	}

    /* deal with urb when usb plugged in */
	rv = usb_submit_urb(ch343->ctrlurb, GFP_KERNEL);
	if (rv) {
		dev_err(&ch343->control->dev,
			"%s - usb_submit_urb(ctrl cmd) failed\n", __func__);
		goto error_submit_urb;
	}

	rv = ch343_submit_read_urbs(ch343, GFP_KERNEL);
	if (rv)
		goto error_submit_read_urbs;

	dev_dbg(&intf->dev, "ch343_probe finished!\n");

	return 0;

error_submit_read_urbs:
	for (i = 0; i < ch343->rx_buflimit; i++)
		usb_kill_urb(ch343->read_urbs[i]);
error_submit_urb:
	usb_kill_urb(ch343->ctrlurb);
alloc_fail7:
	usb_set_intfdata(intf, NULL);
	for (i = 0; i < CH343_NW; i++)
		usb_free_urb(ch343->wb[i].urb);
alloc_fail6:
	for (i = 0; i < num_rx_buf; i++)
		usb_free_urb(ch343->read_urbs[i]);
	ch343_read_buffers_free(ch343);
	usb_free_urb(ch343->ctrlurb);
alloc_fail5:
	ch343_write_buffers_free(ch343);
alloc_fail4:
	usb_free_coherent(usb_dev, ctrlsize, ch343->ctrl_buffer, ch343->ctrl_dma);
alloc_fail2:
	ch343_release_minor(ch343);
	kfree(ch343);
alloc_fail:
	return rv;
}

static void stop_data_traffic(struct ch343 *ch343)
{
	int i;
	struct urb *urb;
	struct ch343_wb *wb;

	dev_dbg(&ch343->control->dev, "%s\n", __func__);

	usb_autopm_get_interface_no_resume(ch343->control);
	ch343->control->needs_remote_wakeup = 0;
	usb_autopm_put_interface(ch343->control);

	for (;;) {
		urb = usb_get_from_anchor(&ch343->delayed);
		if (!urb)
			break;
		wb = urb->context;
		wb->use = 0;
		usb_autopm_put_interface_async(ch343->control);
	}

	usb_kill_urb(ch343->ctrlurb);
	for (i = 0; i < CH343_NW; i++)
		usb_kill_urb(ch343->wb[i].urb);
	for (i = 0; i < ch343->rx_buflimit; i++)
		usb_kill_urb(ch343->read_urbs[i]);
	cancel_work_sync(&ch343->work);
}

static void ch343_disconnect(struct usb_interface *intf)
{
	struct ch343 *ch343 = usb_get_intfdata(intf);
	struct usb_device *usb_dev = interface_to_usbdev(intf);
	struct tty_struct *tty;
	int i;

	dev_dbg(&intf->dev, "%s\n", __func__);

	/* sibling interface is already cleaning up */
	if (!ch343)
		return;

	mutex_lock(&ch343->mutex);
	ch343->disconnected = true;
	wake_up_all(&ch343->wioctl);
	usb_set_intfdata(ch343->control, NULL);
	usb_set_intfdata(ch343->data, NULL);
	mutex_unlock(&ch343->mutex);

	tty = tty_port_tty_get(&ch343->port);
	if (tty) {
		tty_vhangup(tty);
		tty_kref_put(tty);
	}

	stop_data_traffic(ch343);

	tty_unregister_device(ch343_tty_driver, ch343->minor);

	usb_free_urb(ch343->ctrlurb);
	for (i = 0; i < CH343_NW; i++)
		usb_free_urb(ch343->wb[i].urb);
	for (i = 0; i < ch343->rx_buflimit; i++)
		usb_free_urb(ch343->read_urbs[i]);
	ch343_write_buffers_free(ch343);
	usb_free_coherent(usb_dev, ch343->ctrlsize, ch343->ctrl_buffer, ch343->ctrl_dma);
	ch343_read_buffers_free(ch343);

	usb_driver_release_interface(&ch343_driver, intf == ch343->control ?
				ch343->data : ch343->control);

	tty_port_put(&ch343->port);
	dev_info(&intf->dev, "%s\n", "ch343 usb device disconnect.");
}

#ifdef CONFIG_PM
static int ch343_suspend(struct usb_interface *intf, pm_message_t message)
{
	struct ch343 *ch343 = usb_get_intfdata(intf);
	int cnt;

	dev_dbg(&intf->dev, "%s\n", __func__);
	spin_lock_irq(&ch343->write_lock);
	if (PMSG_IS_AUTO(message)) {
		if (ch343->transmitting) {
			spin_unlock_irq(&ch343->write_lock);
			return -EBUSY;
		}
	}
	cnt = ch343->susp_count++;
	spin_unlock_irq(&ch343->write_lock);

	if (cnt)
		return 0;

	stop_data_traffic(ch343);

	return 0;
}

static int ch343_resume(struct usb_interface *intf)
{
	struct ch343 *ch343 = usb_get_intfdata(intf);
	struct urb *urb;
	int rv = 0;

	dev_dbg(&intf->dev, "%s\n", __func__);
	spin_lock_irq(&ch343->write_lock);

	if (--ch343->susp_count)
		goto out;

	if (test_bit(ASYNCB_INITIALIZED, &ch343->port.flags)) {
		rv = usb_submit_urb(ch343->ctrlurb, GFP_ATOMIC);

		for (;;) {
			urb = usb_get_from_anchor(&ch343->delayed);
			if (!urb)
				break;

			ch343_start_wb(ch343, urb->context);
		}

		/*
		 * delayed error checking because we must
		 * do the write path at all cost
		 */
		if (rv < 0)
			goto out;

		rv = ch343_submit_read_urbs(ch343, GFP_ATOMIC);
	}
out:
	spin_unlock_irq(&ch343->write_lock);

	return rv;
}

static int ch343_reset_resume(struct usb_interface *intf)
{
	struct ch343 *ch343 = usb_get_intfdata(intf);

	dev_dbg(&intf->dev, "%s\n", __func__);
	if (test_bit(ASYNCB_INITIALIZED, &ch343->port.flags))
		tty_port_tty_hangup(&ch343->port, false);

	return ch343_resume(intf);
}

#endif /* CONFIG_PM */

/*
 * USB driver structure.
 */

static const struct usb_device_id ch343_ids[] = {
	{ USB_DEVICE_INTERFACE_PROTOCOL(0x1a86, 0x55D2,    /* ch342 chip */
	  	USB_CDC_ACM_PROTO_AT_V25TER) },

	{ USB_DEVICE_INTERFACE_PROTOCOL(0x1a86, 0x55D3,    /* ch343 chip */
	  	USB_CDC_ACM_PROTO_AT_V25TER) },

	{ USB_DEVICE_INTERFACE_PROTOCOL(0x1a86, 0x55D5,    /* ch344 chip */
	  	USB_CDC_ACM_PROTO_AT_V25TER) },

	{ USB_DEVICE_INTERFACE_PROTOCOL(0x1a86, 0x55D8,    /* ch9101 chip */
	  	USB_CDC_ACM_PROTO_AT_V25TER) },

	{ USB_DEVICE_INTERFACE_PROTOCOL(0x1a86, 0x55D4,    /* ch9102 chip */
	  	USB_CDC_ACM_PROTO_AT_V25TER) },

	{ USB_DEVICE_INTERFACE_PROTOCOL(0x1a86, 0x55D7,    /* ch9103 chip */
	  	USB_CDC_ACM_PROTO_AT_V25TER) },

	{ }
};

MODULE_DEVICE_TABLE(usb, ch343_ids);

static struct usb_driver ch343_driver = {
	.name =		"usb_ch343",
	.probe =	ch343_probe,
	.disconnect =	ch343_disconnect,
#ifdef CONFIG_PM
	.suspend =	ch343_suspend,
	.resume =	ch343_resume,
	.reset_resume =	ch343_reset_resume,
#endif
	.id_table =	ch343_ids,
#ifdef CONFIG_PM
	.supports_autosuspend = 1,
#endif
	.disable_hub_initiated_lpm = 1,
};

/*
 * TTY driver structures.
 */
static const struct tty_operations ch343_ops = {
	.install =		ch343_tty_install,
	.open =			ch343_tty_open,
	.close =		ch343_tty_close,
	.cleanup =		ch343_tty_cleanup,
	.hangup =		ch343_tty_hangup,
	.write =		ch343_tty_write,
	.write_room =		ch343_tty_write_room,
	.ioctl =		ch343_tty_ioctl,
	.chars_in_buffer =	ch343_tty_chars_in_buffer,
	.break_ctl =		ch343_tty_break_ctl,
	.set_termios =		ch343_tty_set_termios,
	.tiocmget =		ch343_tty_tiocmget,
	.tiocmset =		ch343_tty_tiocmset,
};

/*
 * Init / exit.
 */
static int __init ch343_init(void)
{
	int retval;
	ch343_tty_driver = alloc_tty_driver(CH343_TTY_MINORS);
	if (!ch343_tty_driver)
		return -ENOMEM;
	ch343_tty_driver->driver_name = "usbch343",
	ch343_tty_driver->name = "ttyCH343USB",
	ch343_tty_driver->major = CH343_TTY_MAJOR,
	ch343_tty_driver->minor_start = 0,
	ch343_tty_driver->type = TTY_DRIVER_TYPE_SERIAL,
	ch343_tty_driver->subtype = SERIAL_TYPE_NORMAL,
	ch343_tty_driver->flags = TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
	ch343_tty_driver->init_termios = tty_std_termios;
	ch343_tty_driver->init_termios.c_cflag = B9600 | CS8 | CREAD |
								HUPCL | CLOCAL;
	tty_set_operations(ch343_tty_driver, &ch343_ops);

	retval = tty_register_driver(ch343_tty_driver);
	if (retval) {
		put_tty_driver(ch343_tty_driver);
		return retval;
	}

	retval = usb_register(&ch343_driver);
	if (retval) {
		tty_unregister_driver(ch343_tty_driver);
		put_tty_driver(ch343_tty_driver);
		return retval;
	}

	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
	printk(KERN_INFO KBUILD_MODNAME ": " VERSION_DESC "\n");

	return 0;
}

static void __exit ch343_exit(void)
{
	usb_deregister(&ch343_driver);
	tty_unregister_driver(ch343_tty_driver);
	put_tty_driver(ch343_tty_driver);
	idr_destroy(&ch343_minors);
	printk(KERN_INFO KBUILD_MODNAME ": " "ch343 driver exit.\n");
}

module_init(ch343_init);
module_exit(ch343_exit);

MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESC);
MODULE_LICENSE("GPL");
MODULE_ALIAS_CHARDEV_MAJOR(CH343_TTY_MAJOR);
