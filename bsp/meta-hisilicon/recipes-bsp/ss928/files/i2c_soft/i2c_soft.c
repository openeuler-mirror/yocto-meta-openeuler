#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/gpio.h>
#include <linux/delay.h>
#include <linux/of.h>
#include <linux/mutex.h>
#include <linux/of_gpio.h>
#include <linux/i2c.h>

#define I2C_DEBUG(fmt,...) printk(KERN_INFO "[SOFT I2C]: "fmt,##__VA_ARGS__)
#define I2C_INFO(fmt,...) printk(KERN_INFO "[SOFT I2C]: "fmt,##__VA_ARGS__)

struct soft_i2c_dev {
    struct device *dev;
    struct i2c_adapter adap;

    //gpio 
    int gpio_scl;
    int gpio_sda;

    struct mutex lock;
    unsigned int freq;
    unsigned int T_ns;
};

#define delay_ns(T_ns) ndelay(T_ns);


static void iic_start(struct soft_i2c_dev* i2c_dev)
{
    gpio_direction_output(i2c_dev->gpio_sda,1);
    gpio_direction_output(i2c_dev->gpio_scl,1);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_set_value(i2c_dev->gpio_sda,0); //开始信号
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_set_value(i2c_dev->gpio_scl,0); // 拉低时钟等待开始
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
}

static void iic_stop(struct soft_i2c_dev* i2c_dev)
{
    gpio_direction_output(i2c_dev->gpio_sda,0);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_direction_output(i2c_dev->gpio_scl,1);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_direction_output(i2c_dev->gpio_sda,1);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
}


/**
 * @brief 等待ACK,ACK返回1,NACK返回0
*/
static uint8_t iic_wait_ack(struct soft_i2c_dev* i2c_dev)
{
    uint8_t i = 0;
    uint8_t rack = 0;
#define WAIT_TIMES 5
    unsigned int dt = i2c_dev->T_ns/(WAIT_TIMES*2);

    gpio_direction_input(i2c_dev->gpio_sda); // 主机释放SDA线
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_direction_output(i2c_dev->gpio_scl,1);

    for(i = 0;i < WAIT_TIMES;i++){
        delay_ns(dt);
        if(gpio_get_value(i2c_dev->gpio_sda)==0){
            rack = 1;
            break;
        }
    }

    gpio_direction_output(i2c_dev->gpio_scl,0);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期

    if(rack == 0){ // NOACK stop
        iic_stop(i2c_dev);
    }

    return rack;
}

static void iic_ack(struct soft_i2c_dev* i2c_dev)
{
    gpio_direction_output(i2c_dev->gpio_sda,0);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_direction_output(i2c_dev->gpio_scl,1);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_direction_output(i2c_dev->gpio_scl,0);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_direction_input(i2c_dev->gpio_sda); // 主机释放SDA线
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
}

void iic_nack(struct soft_i2c_dev* i2c_dev)
{
    gpio_direction_output(i2c_dev->gpio_sda,1);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_direction_output(i2c_dev->gpio_scl,1);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    gpio_direction_output(i2c_dev->gpio_scl,0);
    delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
}

/**
 * @brief       IIC发送一个字节
 * @param       data: 要发送的数据
 * @retval      无
 */
uint8_t iic_send_byte(struct soft_i2c_dev* i2c_dev,uint8_t data)
{
    uint8_t t;
    
    for (t = 0; t < 8; t++)
    {
        gpio_direction_output(i2c_dev->gpio_sda,(data & 0x80) >> 7);    /* 高位先发送 */
        delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
        gpio_direction_output(i2c_dev->gpio_scl,1);
        delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
        gpio_direction_output(i2c_dev->gpio_scl,0);
        data <<= 1;     /* 左移1位,用于下一次发送 */
    }
    return iic_wait_ack(i2c_dev);
}

/**
 * @brief       IIC读取一个字节
 * @param       ack:  ack=1时，发送ack; ack=0时，发送nack
 * @retval      接收到的数据
 */
uint8_t iic_read_byte(struct soft_i2c_dev* i2c_dev)
{
    uint8_t i, receive = 0;

    gpio_direction_input(i2c_dev->gpio_sda);
    for (i = 0; i < 8; i++ )    /* 接收1个字节数据 */
    {
        receive <<= 1;  /* 高位先输出,所以先收到的数据位要左移 */
        gpio_direction_output(i2c_dev->gpio_scl,1);
        delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期

        if (gpio_get_value(i2c_dev->gpio_sda))
            receive++;
        
        gpio_direction_output(i2c_dev->gpio_scl,0);
        delay_ns(i2c_dev->T_ns/2);// 等待半个时钟周期
    }

    return receive;
}

static void iic_release(struct soft_i2c_dev* i2c_dev)
{
    gpio_direction_input(i2c_dev->gpio_scl);
    gpio_direction_input(i2c_dev->gpio_sda);
}


static u32 soft_i2c_func(struct i2c_adapter *adap)
{
    return I2C_FUNC_I2C;
}

static int _soft_i2c_transfer(struct soft_i2c_dev* i2c_dev,struct i2c_msg *msgs)
{
    int i = 0;
    uint16_t flag_support = I2C_M_RD;

    // 检查flag有效性
    if((msgs->flags&(~flag_support))){
        printk("unsupport falg 0x%04x",msgs->flags&(~flag_support));
        //return -1;//包含不支持的标识
    }
    
    //发送设备地址
    iic_start(i2c_dev);
    if(iic_send_byte(i2c_dev,msgs->addr<<1|(msgs->flags&I2C_M_RD?1:0))==0){
        iic_release(i2c_dev);
        return -1;
    }
    if(msgs->flags&I2C_M_RD){//读模式
        for(i=0;i<msgs->len;i++){
            msgs->buf[i] = iic_read_byte(i2c_dev);
            if(i != (msgs->len-1))
                iic_ack(i2c_dev);
        }
        iic_nack(i2c_dev);
    }
    else{ // 写模式
        for(i=0;i<msgs->len;i++){
            if(iic_send_byte(i2c_dev,msgs->buf[i])==0){
                iic_release(i2c_dev);
                return -1;
            }
        }
    }

    iic_stop(i2c_dev);
    return 0;
}

// static void _showMsg(struct i2c_msg *msg)
// {
//     int i;
//     printk(
//         "\taddr:0x%02x\n"
//         "\tflag:0x%04x\n"
//         "\t len:%u\n"
//         "\t buf:",
//         msg->addr,
//         msg->flags,
//         msg->len
//     );
//     for(i = 0;i<msg->len;i++){
//         printk("%02x ",msg->buf[i]);
//     }
//     printk("\n");
// }

static int soft_i2c_xfer(struct i2c_adapter *adap,struct i2c_msg *msgs, int num)
{
    struct soft_i2c_dev *i2c = i2c_get_adapdata(adap);
    int i;
    int status = -EINVAL;

    //printk("soft_i2c_xfer\n");
    if (msgs == NULL || (num <= 0)) {
        dev_err(i2c->dev, "msgs == NULL || num <= 0, Invalid argument!\n");
        return -EINVAL;
    }
    
    // for(i=0;i<num;i++){
    //     printk("Msg %d:\n",i);
    //     _showMsg(msgs+i);
    // }

    mutex_lock(&i2c->lock);

    // printk("Msg Get Mutex\n");
    for(i = 0;i < num;i++){
        status = _soft_i2c_transfer(i2c,msgs+i);
        if(status){
            mutex_unlock(&i2c->lock);
            return -1;
        }
    }

    mutex_unlock(&i2c->lock);
    return i;
}
//Algorithm
static const struct i2c_algorithm soft_i2c_algo = {
        .master_xfer            = soft_i2c_xfer,
        .functionality          = soft_i2c_func,
};

static int soft_i2c_init_adap(struct i2c_adapter* const adap, struct soft_i2c_dev* const i2c,
                               struct platform_device* const pdev)
{
        int status;

        i2c_set_adapdata(adap, i2c);
        adap->owner = THIS_MODULE;
        strlcpy(adap->name, "soft-i2c", sizeof(adap->name));
        adap->dev.parent = &pdev->dev;
        adap->dev.of_node = pdev->dev.of_node;
        adap->algo = &soft_i2c_algo;

        /* Add the i2c adapter */
        status = i2c_add_adapter(adap);
        if (status)
                dev_err(i2c->dev, "failed to add bus to i2c core\n");

        return status;
}

int soft_i2c_probe(struct platform_device *pdev)
{
    int ret = 0;
    int status;
    struct i2c_adapter *adap = NULL;
    struct soft_i2c_dev *i2c;

    i2c = devm_kzalloc(&pdev->dev, sizeof(*i2c), GFP_KERNEL);
    if (i2c == NULL){
        I2C_INFO("nomem\n");
        ret = -ENOMEM;
        goto ERR_NOMEM;
    }
    
    platform_set_drvdata(pdev, i2c);
    i2c->dev = &pdev->dev;
    mutex_init(&i2c->lock);

    i2c->gpio_scl = of_get_named_gpio(pdev->dev.of_node,"gpio-scl",0);
    if (!gpio_is_valid(i2c->gpio_scl)) {
        I2C_INFO("not found gpio-scl\n");
        ret = -ENODEV;
        goto ERR_NOCLK;
    }
    if (gpio_request(i2c->gpio_scl, "soft_scl") != 0) {
        I2C_INFO("gpio-scl busy\n");
        ret = -ENODEV;
        goto ERR_NOCLK;
    }
    gpio_direction_input(i2c->gpio_scl);

    i2c->gpio_sda = of_get_named_gpio(pdev->dev.of_node,"gpio-sda",0);
    if (!gpio_is_valid(i2c->gpio_sda)) {
        I2C_INFO("not found gpio-sda\n");
        ret = -ENODEV;
        goto ERR_NOSDA;
    }
    if (gpio_request(i2c->gpio_sda, "soft_sda") != 0) {
        I2C_INFO("gpio-sda busy\n");
        ret = -ENODEV;
        goto ERR_NOSDA;
    }
    gpio_direction_input(i2c->gpio_sda);

    if (of_property_read_u32(pdev->dev.of_node, "clock-frequency", &i2c->freq)) {
        dev_warn(&pdev->dev, "Failed to read custom property\n");
        i2c->freq = 1000000; //default 1M
    }
    dev_info(&pdev->dev,"freq:%u",i2c->freq);

    i2c->T_ns = 1000000000 / i2c->freq;

    adap = &i2c->adap;
    status = soft_i2c_init_adap(adap, i2c, pdev);
    if(status!=0){
        ret = status;
        goto ERR_INITADAP;
    }

    return 0;

ERR_INITADAP:
    gpio_free(i2c->gpio_sda);
ERR_NOSDA:
    gpio_free(i2c->gpio_scl);
ERR_NOCLK:
ERR_NOMEM:
    return ret;
}

int soft_i2c_remove(struct platform_device *pdev)
{
    struct soft_i2c_dev *i2c = platform_get_drvdata(pdev);

    mutex_destroy(&i2c->lock);
    gpio_free(i2c->gpio_sda);
    gpio_free(i2c->gpio_scl);
    i2c_del_adapter(&i2c->adap);

    return 0;
}

static const struct of_device_id soft_i2c_match[] = {
        { .compatible = "i2c,soft" },
        {},
};
static struct platform_driver soft_i2c_driver = {
    .driver = {
        .name = "soft-i2c",
        .of_match_table = soft_i2c_match,
    },
    .probe = soft_i2c_probe,
    .remove = soft_i2c_remove,
};

module_platform_driver(soft_i2c_driver);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("soft i2c driver");