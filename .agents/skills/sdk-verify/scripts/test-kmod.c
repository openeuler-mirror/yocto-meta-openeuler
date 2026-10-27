#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

static int __init hello_mod_init(void)
{
    printk(KERN_INFO "hello_mod: loaded by SDK-built kernel module\n");
    return 0;
}

static void __exit hello_mod_exit(void)
{
    printk(KERN_INFO "hello_mod: unloaded\n");
}

module_init(hello_mod_init);
module_exit(hello_mod_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("SDK verification kernel module");
