KERNEL_DIR := $(KERNEL_SRC)
PWD       := $(shell pwd)
obj-m := ch343.o

default:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
