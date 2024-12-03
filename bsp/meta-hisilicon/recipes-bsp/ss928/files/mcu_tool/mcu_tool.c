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
#include <stdint.h>

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
"\t\tversion(ver)\n"
"\t\tled <r/g/o> <on/off/blink/breath/brightness> [time_ms]\n"
"\t\tnearlink(nl) <on/off>\n"
"\t\ttemperature(t)\n"
"\t\tvoltage(v)\n"
"\t\terror\n\n"
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

	struct i2c_msg msgs[2];
	memset(msgs,0,sizeof(struct i2c_msg)*2);
	msgs[0].addr = i2c_addr;
	msgs[1].addr = i2c_addr;
	msgs[1].flags = I2C_M_RD;

	if(
		(!strcmp(argv[ARGS_OPT],"version")) ||
		(!strcmp(argv[ARGS_OPT],"ver"))) {
		char buffer[2] = {0x00,0x00};
		msgs[0].buf = buffer;
		msgs[0].len = 2;
		msgs[1].buf = buffer;
		msgs[1].len = 2;
		if(send_msg(i2c_dev,msgs,2))
			goto error;
		uint16_t * value = (uint16_t*)buffer;
		
		printf("version: %d.%d.%d\n", ((*value) >> 8) & 0x0F, ((*value) >> 4) & 0x0F, (*value) & 0x0F);
	}
	else if(!strcmp(argv[ARGS_OPT],"led")) {
#pragma pack(push, 1)
struct led_cmd {
	uint8_t cmd;
	uint8_t len;
    uint8_t led;
    uint8_t opt;
    uint32_t time_ms;
};
#pragma pack(pop)
		struct led_cmd cmd;
		cmd.cmd = 0x01;
		switch (argv[ARGS_OPT+1][0])
		{
		case 'r': cmd.led = 0x00; break;
		case 'g': cmd.led = 0x01; break;
		case 'o': cmd.led = 0x02; break;
		default:
			printf("error led:%s\n",argv[ARGS_OPT+1]);
			return -1;
			break;
		}

		if(!strcmp(argv[ARGS_OPT+2],"on")) {
			cmd.opt = 0x00;
			cmd.len = 0x02;
		}
		else if (!strcmp(argv[ARGS_OPT+2],"off")) {
			cmd.opt = 0x01;
			cmd.len = 0x02;
		}
		else if (!strcmp(argv[ARGS_OPT+2],"blink")) {
			cmd.opt = 0x02;
			cmd.len = 0x06;
		}
		else if (!strcmp(argv[ARGS_OPT+2],"breath")) {
			cmd.opt = 0x03;
			cmd.len = 0x06;
		}
		else if (!strcmp(argv[ARGS_OPT+2],"brightness")) {
			cmd.opt = 0x04;
			cmd.len = 0x06;
		}

		if(cmd.opt >= 0x02) {
			cmd.time_ms = atoi_auto(argv[ARGS_OPT+3]);
		}
		
		msgs[0].buf = (uint8_t*)&cmd;
		msgs[0].len = cmd.len + 2;
		if(send_msg(i2c_dev,msgs,1))
			goto error;
	}
	else if(
		(!strcmp(argv[ARGS_OPT],"nearlink")) || 
		(!strcmp(argv[ARGS_OPT],"nl"))) {
		
		char buffer[4] = {0x02,0x02,0x01,0x00};
		msgs[0].buf = buffer;
		msgs[0].len = 4;
		if(!strcmp(argv[ARGS_OPT+1],"on"))
			buffer[3] = 0x01;
		if(send_msg(i2c_dev,msgs,1))
			goto error;
	}
	else if(
		(!strcmp(argv[ARGS_OPT],"temperature")) || 
		(!strcmp(argv[ARGS_OPT],"t"))) {
		float temp = 0;
		char buffer[2] = {0x03,0x00};
		msgs[0].buf = buffer;
		msgs[0].len = 2;
		msgs[1].buf = (uint8_t*)&temp;
		msgs[1].len = sizeof(float);
		if(send_msg(i2c_dev,msgs,2))
			goto error;
		printf("%f\n",temp);
	}
	else if(
		(!strcmp(argv[ARGS_OPT],"voltage")) || 
		(!strcmp(argv[ARGS_OPT],"v"))) {
		float temp = 0;
		char buffer[2] = {0x04,0x00};
		msgs[0].buf = buffer;
		msgs[0].len = 2;
		msgs[1].buf = (uint8_t*)&temp;
		msgs[1].len = sizeof(float);
		if(send_msg(i2c_dev,msgs,2))
			goto error;
		printf("%f\n",temp);
	}
	else if(!strcmp(argv[ARGS_OPT],"error")) {
		char buffer[2] = {0x00,0x00};
		msgs[0].buf = buffer;
		msgs[0].len = 2;
		msgs[1].buf = buffer;
		msgs[1].len = 2;
		if(send_msg(i2c_dev,msgs,2))
			goto error;
		uint16_t * value = (uint16_t*)buffer;
		
		printf("error count:%d\n", *value);
	}

	close(i2c_dev);
	return 0;

error:
	printf("ERROR:%d\n",ret);
	close(i2c_dev);
	return -1;
}

