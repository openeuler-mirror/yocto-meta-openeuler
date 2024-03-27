/**
 *  Copyright (c) 2024 Ebaina
 *  hieuler u-boot is licensed under Mulan PSL v2.
 *  You can use this software according to the terms and conditions of the Mulan PSL v2.
 *  You may obtain a copy of Mulan PSL v2 at:
 *           http://license.coscl.org.cn/MulanPSL2
 *  THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR
 *  FIT FOR A PARTICULAR PURPOSE.
 *  See the Mulan PSL v2 for more details.
 */
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <string.h>
#include <sys/ioctl.h>

enum gpio_type{
    GPIO_SYS_RSTN_IN,
    GPIO_NEARLINK_EN,
    GPIO_LED,
    GPIO_CFG1,
    GPIO_CFG2, 
    GPIO_CFG3,

    GPIO_TYPE_NUM,
};

void show_msg(struct i2c_msg* msg)
{
	printf("\tADDR:0x%02x\n",msg->addr);
	printf("\tRW:%c\n",(msg->flags==0)?'W':'R');
	printf("\tLEN:0x%x\n",msg->len);
	printf("\tDATA:");
	for(int i=0;i<msg->len;i++){
		printf("%02x ",msg->buf[i]);
	}
	printf("\n");
}
void show_msg_list(struct i2c_msg* msg,int len)
{
	for(int i=0;i<len;i++){
		printf("MSG[%d]:\n",i);
		show_msg(msg + i);
	}
}

#define FLAG_OCT 1
#define FLAG_DEC 2
#define FLAG_HEX 3

unsigned long atoi(char* value,int odh)
{
    unsigned long data = 0;
    int i;

    const int times[4] = {
        [FLAG_OCT] = 8,
        [FLAG_DEC] = 10,
        [FLAG_HEX] = 16,
    };

    for(i=0;value[i];i++){
        data *= times[odh];

        if(value[i]>='0'&&value[i]<='7') 
            { data += value[i] - '0'; continue; }
        
        if((odh==FLAG_DEC||odh==FLAG_HEX)&&value[i]>='8'&&value[i]<='9') 
            { data += value[i] - '0'; continue; }
        
        if((odh==FLAG_HEX)&&value[i]>='a'&&value[i]<='f') 
            { data += value[i] - 'a' + 10; continue; }
        
        if((odh==FLAG_HEX)&&value[i]>='A'&&value[i]<='F') 
            { data += value[i] - 'A' + 10; continue; }

        break;
    }

    if(value[i])
        data /= times[odh];
    
    return data;
}

unsigned long atoi_auto(char* value)
{
    unsigned long data = 0;

    if(value==NULL)
        return 0;

    if(value[0]=='0'){
        if(value[1]=='x')
            data = atoi(value+2,FLAG_HEX);
        else
            data = atoi(value+1,FLAG_OCT);
    }
    else if(value[0]>='0'&&value[0]<='9'){
        data = atoi(value,FLAG_DEC);
    }

    return data;
}

void show_help()
{
	printf(
"\tmcu <dev> <addr> <opt> [args]\n"
"\n"
"\t<opt>:\n"
"\t\tled <on/off>\n"
"\t\tnearlink(nl) <on/off>\n"
"\t\temperature(t)\n"
"\t\tvoltage(v)\n\n"
	);
}

enum ARGS {
	ARGS_SELF,
	ARGS_I2C_DEV,
	ARGS_I2C_ADDR,
	ARGS_OPT,
};

int send_msg(int i2c_dev,struct i2c_msg* msgs,int msg_num)
{
	struct i2c_rdwr_ioctl_data ioctl_data;
	ioctl_data.msgs = msgs;
	ioctl_data.nmsgs = msg_num;

	return ioctl(i2c_dev, I2C_RDWR, &ioctl_data) < 0;
}

int main(int argc,char*argv[])
{
	if(argc<=3){
		show_help();
		return 0;
	}
	int i2c_addr = atoi_auto(argv[ARGS_I2C_ADDR]);
	int ret;

	struct i2c_rdwr_ioctl_data ioctl_data;
	int i2c_dev = open(argv[ARGS_I2C_DEV], O_RDWR);
    if (i2c_dev < 0) {
        printf("Failed to open I2C device:<%s>",argv[ARGS_I2C_DEV]);
        return 1;
    }

	if(!strcmp(argv[ARGS_OPT],"led")) {
		struct i2c_msg msg;
		char buffer[4] = {0x03,0x00,0x02,0x01};
		msg.buf = buffer;
		msg.addr = i2c_addr;
		msg.flags = 0;
		msg.len = 4;
		if(!strcmp(argv[ARGS_OPT+1],"off"))
			buffer[3] = 0x00;
		if(send_msg(i2c_dev,&msg,1))
			goto error;
	}
	else if(
		(!strcmp(argv[ARGS_OPT],"nearlink")) || 
		(!strcmp(argv[ARGS_OPT],"nl"))) {
		struct i2c_msg msg;
		char buffer[4] = {0x03,0x00,0x01,0x01};
		msg.buf = buffer;
		msg.addr = i2c_addr;
		msg.flags = 0;
		msg.len = 4;
		if(!strcmp(argv[ARGS_OPT+1],"off"))
			buffer[3] = 0x00;
		if(send_msg(i2c_dev,&msg,1))
			goto error;
	}
	else if(
		(!strcmp(argv[ARGS_OPT],"temperature")) || 
		(!strcmp(argv[ARGS_OPT],"t"))) {
		char buffer[6] = {0x01,0x01};
		struct i2c_msg msgs[2];
		msgs[0].addr = i2c_addr;
		msgs[0].buf = buffer;
		msgs[0].flags = 0;
		msgs[0].len = 2;
		msgs[1].addr = i2c_addr;
		msgs[1].buf = buffer + 2;
		msgs[1].flags = I2C_M_RD;
		msgs[1].len = 4;
		if(send_msg(i2c_dev,msgs,2))
			goto error;
		float* data = (float*)(msgs[1].buf);
		printf("%f\n",*data);
	}
	else if(
		(!strcmp(argv[ARGS_OPT],"voltage")) || 
		(!strcmp(argv[ARGS_OPT],"v"))) {
		char buffer[6] = {0x01,0x02};
		struct i2c_msg msgs[2];
		msgs[0].addr = i2c_addr;
		msgs[0].buf = buffer;
		msgs[0].flags = 0;
		msgs[0].len = 2;
		msgs[1].addr = i2c_addr;
		msgs[1].buf = buffer + 2;
		msgs[1].flags = I2C_M_RD;
		msgs[1].len = 4;
		if(send_msg(i2c_dev,msgs,2))
			goto error;
		float* data = (float*)(msgs[1].buf);
		printf("%f\n",*data);
	}

	close(i2c_dev);
	return 0;

error:
	printf("ERROR:%d\n",ret);
	close(i2c_dev);
	return -1;
}