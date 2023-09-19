.. _distributed_softbus:

分布式软总线
#############

特性介绍
**************

**背景**

openEuler秉承着打造“数字化基础设施操作系统”的愿景，为促进与OpenHarmony生态的合作与互通，实现端边领域的互通和协同，首次在嵌入式领域引入分布式软总线技术。

分布式软总线是OpenHarmony社区开源的分布式设备通信基座，为设备之间的互通互联提供统一的分布式协同能力，实现设备无感发现和高效传输。

OpenHarmony主要面向强交互等需求的智能终端、物联网终端和工业终端。openEuler主要面向有高可靠、高性能等需求的服务器、边缘计算、云和嵌入式设备，二者各有侧重。通过以分布式软总线为代表的技术进行生态互通，以期实现“1+1>2”的效果，支撑社区用户开拓更广阔的行业空间。

**架构**

软总线的主要架构如下：

    .. figure:: ../../image/dsoftbus/dsoftbus_architecture.png
        :align: center

软总线主体功能分为发现、组网、连接和传输四个基本模块，实现：

* **即插即用**：快速便捷发现周边设备

* **自由流转**：各设备间自组网，任意建立业务连接，实现自由通信

* **高效传输**：通过WiFi、蓝牙设备下软硬件协同最大化发挥硬件传输性能

软总线南向支持WiFi（22.09新增）和有线以太网通信，同时后续可持续拓展蓝牙等通信方式。并为北向的分布式应用提供统一的API接口，屏蔽底层通信机制。

软总线依赖于设备认证、IPC、日志和系统参数（SN号）等周边模块，嵌入式系统中将这些依赖模块进行了样板性质的替换，以实现软总线基本功能。实际的周边模块功能实现，还需要用户根据实际业务场景进行丰富和替换，以拓展软总线能力。

应用指南
**************

**部署示意**

软总线支持局域网内多设备部署，设备间通过以太网通信。

单设备上分为server和client，二者通过IPC模块进行交互。

单节点上支持多client同时接入单一server。

    .. figure:: ../../image/dsoftbus/dsoftbus_networking.png
        :align: center


**服务端启动**

服务端主程序名为softbus_server_main。

如部署模型，软总线通过独立进程部署的方式对外提供服务，通过执行服务端主程序可拉起软总线进程提供对外服务。

.. code-block:: console

  openeuler ~ # softbus_server_main >log.file &

1.当服务端被拉起时，会主动通过名为ethX/wifiX的网络设备进行coap广播，对对端设备进行自动探测。

2.当探测到对端设备且对端设备为可信设备时，还会自动组网操作，以便后后续客户端进行快速连接和传输。（“添加可信设备”见后续章节）

3.日志模块可通过重定向接管，有条件者还可通过实现和替换软总线依赖的hilog模块，进行更细致的日志管理。

4.服务端依赖于系统参数模块syspara，以获取设备唯一的UDID。openEuler Embedded预留了/etc/SN的文件接口，作为生成UDID的参数。（SN号可为64字节长度内的任意字符串）

.. attention::

    * 用户请参考部署模型，保证单设备节点上有且仅有唯一的softbus_server_main进程。

    * 用户需要在启动softbus_server_main前配置/etc/SN，并保证多设备下SN号的唯一性


**客户端API**

softbus客户端API头文件在嵌入式版本提供的sdk中对外开放，可在客户端代码中引用。

.. code-block:: console

  #include "discovery_service.h"
  #include "softbus_bus_center.h"
  #include "session.h"


其中：

1.discovery_service.h：发现模块头文件，支持应用主动探测和发布的API如下：

+----------------------------+--------------------------------------------------------------------+
| PublishService             | 发布特定服务能力                                                   |
+----------------------------+--------------------------------------------------------------------+
| UnPublishService           | 取消发布特定服务能力                                               |
+----------------------------+--------------------------------------------------------------------+
| StartDiscovery             | 订阅/探测特定服务能力                                              |
+----------------------------+--------------------------------------------------------------------+
| StopDiscovery              | 取消订阅特性服务能力                                               |
+----------------------------+--------------------------------------------------------------------+

.. attention::

    服务能力通过g_capabilityMap数组定义，用户若新增能力需要自定义修改该数组，并重新编译软总线服务端和客户端程序来生效。

2.softbus_bus_center.h：组网模块头文件，支持获取组网内设备信息API如下：

+----------------------------+--------------------------------------------------------------------+
| GetAllNodeDeviceInfo       | 获取当前组网内所有节点信息                                         |
+----------------------------+--------------------------------------------------------------------+
| FreeNodeInfo               | 释放GetAllNodeDeviceInfo返回的节点信息内存                         |
+----------------------------+--------------------------------------------------------------------+

3.session.h：连接/传输模块头文件，支持创建session和数据传输API如下：

+----------------------------+--------------------------------------------------------------------+
| CreateSessionServer        | 创建session服务端                                                  |
+----------------------------+--------------------------------------------------------------------+
| RemoveSessionServer        | 移除session服务端                                                  |
+----------------------------+--------------------------------------------------------------------+
| OpenSession                | 创建到对端的传输连接（同时依赖于本端和对端提前创建的SessionServer）|
+----------------------------+--------------------------------------------------------------------+
| CloseSession               | 断开传输连接                                                       |
+----------------------------+--------------------------------------------------------------------+
| SendBytes                  | 根据建好的连接ID，进行字节流数据传输                               |
+----------------------------+--------------------------------------------------------------------+
| SendMessage                | 根据建好的连接ID，进行消息数据传输                                 |
+----------------------------+--------------------------------------------------------------------+
| SendStream                 | 根据建好的连接ID，进行流式数据传输                                 |
+----------------------------+--------------------------------------------------------------------+
| SendFile                   | 根据建好的连接ID，进行文件传输                                     |
+----------------------------+--------------------------------------------------------------------+
| SetFileSendListener        | 设置文件传输发送过程中的回调函数                                   |
+----------------------------+--------------------------------------------------------------------+
| SetFileReceiveListener     | 设置文件传输接收过程中的回调函数                                   |
+----------------------------+--------------------------------------------------------------------+

各API参数详见头文件描述。

**客户端使用**

客户端提供动态链接库：
	* libsoftbus_client.z.so，

以及对应的头文件:

	* 发现：discovery_service.h

	* 组网：softbus_bus_center.h

	* 连接/组网：session.h

用户使用软总线时，需要作为客户端程序显式链接libsoftbus_client.z.so动态库，即可通过函数调用使用软总线提供的API。

链接动态库方式参见下一章节（应用示例）


**应用示例**

使用qemu部署分布式软总线，编写客户端程序，使其能够列出所有发现的设备信息。

1. 编写客户端程序

    编写客户端程序依托于embedded版本发布的SDK，请参考 :ref:`getting_started` 章节进行SDK环境使用准备

    该示例代码中同时实现了两个设备间的发现和消息收发功能。用户可以作为API调用参考，并根据应用场景进行裁减和扩展。

    创建一个 :file:`softbus_client_main.c` 文件，源码如下：

    .. code-block:: c

        #include <stdio.h>
        #include <unistd.h>
        #include <string.h>
        #include "securec.h"
        #include "discovery_service.h"
        #include "softbus_bus_center.h"
        #include "session.h"
        
        #define PACKAGE_NAME "softbus_sample"
        #define LOCAL_SESSION_NAME "session_test"
        #define TARGET_SESSION_NAME "session_test"
        #define DEFAULT_CAPABILITY "osdCapability"
        #define DEFAULT_SESSION_GROUP "group_test"
        #define DEFAULT_PUBLISH_ID 123
        
        static int g_sessionId;
        
        static void PublishSuccess(int publishId)
        {
        	printf("<PublishSuccess>CB: publish %d done\n", publishId);
        }
        
        static void PublishFailed(int publishId, PublishFailReason reason)
        {
        	printf("<PublishFailed>CB: publish %d failed, reason=%d\n", publishId, (int)reason);
        }
        
        static int PublishServiceInterface()
        {
        	PublishInfo info = {
        		.publishId = DEFAULT_PUBLISH_ID,
        		.mode = DISCOVER_MODE_PASSIVE,
        		.medium = COAP,
        		.freq = LOW,
        		.capability = DEFAULT_CAPABILITY,
        		.capabilityData = NULL,
        		.dataLen = 0,
        	};
        	IPublishCallback cb = {
        		.OnPublishSuccess = PublishSuccess,
        		.OnPublishFail = PublishFailed,
        	};
        	return PublishService(PACKAGE_NAME, &info, &cb);
        }
        
        static void UnPublishServiceInterface(void)
        {
        	int ret = UnPublishService(PACKAGE_NAME, DEFAULT_PUBLISH_ID);
        	if (ret != 0) {
        		printf("UnPublishService fail:%d\n", ret);
        	}
        }
        
        static void DeviceFound(const DeviceInfo *device)
        {
        	unsigned int i;
        	printf("<DeviceFound>CB: Device has found\n");
        	printf("\tdevId=%s\n", device->devId);
        	printf("\tdevName=%s\n", device->devName);
        	printf("\tdevType=%d\n", device->devType);
        	printf("\taddrNum=%d\n", device->addrNum);
        	for (i = 0; i < device->addrNum; i++) {
        		printf("\t\taddr%d:type=%d,", i + 1, device->addr[i].type);
        		switch (device->addr[i].type) { 
        		case CONNECTION_ADDR_WLAN:
        		case CONNECTION_ADDR_ETH:
        			printf("ip=%s,port=%d,", device->addr[i].info.ip.ip, device->addr[i].info.ip.port);
        			break;
        		default:
        			break;
        		}
        		printf("peerUid=%s\n", device->addr[i].peerUid);
        	}
        	printf("\tcapabilityBitmapNum=%d\n", device->capabilityBitmapNum);
        	for (i = 0; i < device->addrNum; i++) {
        		printf("\t\tcapabilityBitmap[%d]=0x%x\n", i + 1, device->capabilityBitmap[i]);
        	}
        	printf("\tcustData=%s\n", device->custData);
        }
        
        static void DiscoverySuccess(int subscribeId)
        {
        	printf("<DiscoverySuccess>CB: discover subscribeId=%d\n", subscribeId);
        }
        
        static void DiscoveryFailed(int subscribeId, DiscoveryFailReason reason)
        {
        	printf("<DiscoveryFailed>CB: discover subscribeId=%d failed, reason=%d\n", subscribeId, (int)reason);
        }
        
        static int DiscoveryInterface(void)
        {
        	SubscribeInfo info = {
        		.subscribeId = DEFAULT_PUBLISH_ID,
        		.mode = DISCOVER_MODE_ACTIVE,
        		.medium = COAP,
        		.freq = LOW,
        		.isSameAccount = false,
        		.isWakeRemote = false,
        		.capability = DEFAULT_CAPABILITY,
        		.capabilityData = NULL,
        		.dataLen = 0,
        	};
        	IDiscoveryCallback cb = {
        		.OnDeviceFound = DeviceFound,
        		.OnDiscoverFailed = DiscoveryFailed,
        		.OnDiscoverySuccess = DiscoverySuccess,
        	};
        	return StartDiscovery(PACKAGE_NAME, &info, &cb);
        }
        
        static void StopDiscoveryInterface(void)
        {
        	int ret = StopDiscovery(PACKAGE_NAME, DEFAULT_PUBLISH_ID);
        	if (ret) {
        		printf("StopDiscovery fail:%d\n", ret);
        	}
        }
        
        static int SessionOpened(int sessionId, int result)
        {
        	printf("<SessionOpened>CB: session %d open fail:%d\n", sessionId, result);
        	if (result == 0) {
        		g_sessionId = sessionId;
        	}
        
        	return result;
        }
        
        static void SessionClosed(int sessionId)
        {
        	printf("<SessionClosed>CB: session %d closed\n", sessionId);
        }
        
        static void ByteRecived(int sessionId, const void *data, unsigned int dataLen)
        {
        	printf("<ByteRecived>CB: session %d received %u bytes data=%s\n", sessionId, dataLen, (const char *)data);
        }
        
        static void MessageReceived(int sessionId, const void *data, unsigned int dataLen)
        {
        	printf("<MessageReceived>CB: session %d received %u bytes message=%s\n", sessionId, dataLen, (const char *)data);
        }
        
        static int CreateSessionServerInterface(void)
        {
        	const ISessionListener sessionCB = {
        		.OnSessionOpened = SessionOpened,
        		.OnSessionClosed = SessionClosed,
        		.OnBytesReceived = ByteRecived,
        		.OnMessageReceived = MessageReceived,
        	};
        
        	return CreateSessionServer(PACKAGE_NAME, LOCAL_SESSION_NAME, &sessionCB);
        }
        
        static void RemoveSessionServerInterface(void)
        {
        	int ret = RemoveSessionServer(PACKAGE_NAME, LOCAL_SESSION_NAME);
        	if (ret) {
        		printf("RemoveSessionServer fail:%d\n", ret);
        	}
        }
        
        static int OpenSessionInterface(const char *peerNetworkId)
        {
        	SessionAttribute attr = {
        		.dataType = TYPE_BYTES,
        		.linkTypeNum = 1,
        		.linkType[0] = LINK_TYPE_WIFI_WLAN_2G,
        		.attr = {RAW_STREAM},
        	};
        
        	return OpenSession(LOCAL_SESSION_NAME, TARGET_SESSION_NAME, peerNetworkId, DEFAULT_SESSION_GROUP, &attr);
        }
        
        static void CloseSessionInterface(int sessionId)
        {
        	CloseSession(sessionId);
        }
        
        static int GetAllNodeDeviceInfoInterface(NodeBasicInfo **dev)
        {
        	int ret, num;
        
        	ret = GetAllNodeDeviceInfo(PACKAGE_NAME, dev, &num);
        	if (ret) {
        		printf("GetAllNodeDeviceInfo fail:%d\n", ret);
        		return -1;
        	}
        
        	printf("<GetAllNodeDeviceInfo>return %d Node\n", num);
        	for (int i = 0; i < num; i++) {
        		printf("<num %d>deviceName=%s\n", i + 1, dev[i]->deviceName);
        		printf("\tnetworkId=%s\n", dev[i]->networkId);
        		printf("\tType=%d\n", dev[i]->deviceTypeId);
        	}
        
        	return num;
        }
        
        static void FreeNodeInfoInterface(NodeBasicInfo *dev)
        {
        	FreeNodeInfo(dev);
        }
        
        static void commnunicate(void)
        {
        	NodeBasicInfo *dev = NULL;
        	char cData[] = "hello world test";
        	int dev_num, sessionId, input, ret;
        	int timeout = 5;
        
        	dev_num = GetAllNodeDeviceInfoInterface(&dev);
        	if (dev_num <= 0) {
        		return;
        	}
        
        	printf("\nInput Node num to commnunication:");
        	scanf_s("%d", &input);
        	if (input <= 0 || input > dev_num) {
        		printf("error input num\n");
        		goto err_input;
        	}
        
        	g_sessionId = -1;
        	sessionId = OpenSessionInterface(dev[input - 1].networkId);
        	if (sessionId < 0) {
        		printf("OpenSessionInterface fail, ret=%d\n", sessionId);
        		goto err_OpenSessionInterface;
        	}
        
        	while (timeout) {
        		if (g_sessionId == sessionId) {
        			ret = SendBytes(sessionId, cData, strlen(cData) + 1);
        			if (ret) {
        				printf("SendBytes fail:%d\n", ret);
        			}
        			break;
        		}
        		timeout--;
        		sleep(1);
        	}
        
        	CloseSessionInterface(sessionId);
        err_OpenSessionInterface:
        err_input:
        	FreeNodeInfoInterface(dev);
        }
        
        int main(int argc, char **argv)
        {
        	bool loop = true;
        	int ret;
        
        	ret = CreateSessionServerInterface();
        	if (ret) {
        		printf("CreateSessionServer fail, ret=%d\n", ret);
        		return ret;
        	}
        
        	ret = PublishServiceInterface();
        	if (ret) {
        		printf("PublishService fail, ret=%d\n", ret);
        		goto err_PublishServiceInterface;
        	}
        
        	ret = DiscoveryInterface();
        	if (ret) {
        		printf("DiscoveryInterface fail, ret=%d\n", ret);
        		goto err_DiscoveryInterface;
        	}
        
        	while (loop) {
        		printf("\nInput c to commnuication, Input s to stop:");
        		char op = getchar();
        		switch(op) {
        		case 'c':
        			commnunicate();
        			continue;
        		case 's':
        			loop = false;
        			break;
        		case '\n':
        			break;
        		default:
        			continue;
        		}
        	}
        
        	StopDiscoveryInterface();
        err_DiscoveryInterface:
        	UnPublishServiceInterface();
        err_PublishServiceInterface:
        	RemoveSessionServerInterface();
        	return 0;
        }

    在配置好SDK环境 编译客户端主程序如下：

    .. code-block:: console

	${CC} -lsoftbus_client.z -lboundscheck softbus_client_main.c -o softbus_client_main

    编译完成后会得到dsoftbus_client_main程序

2. 构建qemu组网环境

    在host中创建网桥br0

    .. code-block:: console

        brctl addbr br0

    启动qemu1

    .. code-block:: console

        qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic -kernel zImage -initrd <openeuler-image-qemu-xxx.cpio.gz> -device virtio-net-device,netdev=tap0,mac=52:54:00:12:34:56 -netdev bridge,id=tap0

    .. attention::
        首次运行如果出现如下错误提示，

        .. code-block:: console

            failed to parse default acl file `/usr/local/libexec/../etc/qemu/bridge.conf'
            qemu-system-aarch64: bridge helper failed

        则需要向指示的文件添加"allow br0"

        .. code-block:: console

            echo "allow br0" > /usr/local/libexec/../etc/qemu/bridge.conf

    启动qemu2

    .. code-block:: console

        qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic -kernel zImage -initrd openeuler-image-qemu-aarch64-20220331025547.rootfs.cpio.gz  -device virtio-net-device,netdev=tap1,mac=52:54:00:12:34:78 -netdev bridge,id=tap1

    .. attention::

        qemu1与qemu2的mac地址需要配置为不同的值


    配置IP

    配置host的网桥地址

    .. code-block:: console

        ifconfig br0 192.168.10.1 up

    配置qemu1的网络地址

    .. code-block:: console

        ifconfig eth0 192.168.10.2

    配置qemu2的网络地址

    .. code-block:: console

        ifconfig eth0 192.168.10.3

    分别在host、qemu1、qemu2使用ping进行测试，确保qemu1可以ping通qemu2。

3. 启动分布式软总线

   在qemu1和qemu2中启动分布式软总线的服务端

    .. code-block:: console

        softbus_server_main >log.file &

    将编译好的客户端分发到qemu1和qemu2的根目录中

    .. code-block:: console

        scp softbus_client_main root@192.168.10.2:/
        scp softbus_client_main root@192.168.10.3:/

    分别在qemu1和qemu2的根目录下运行softbus_client_main，双方均会发现对端设备并输出设备信息：

    .. code-block:: console

	<DeviceFound>CB: Device has found
	devId=6B86B273FF34FCE19D6B804EFF5A3F5747ADA4EAA22F1D49C01E52DDB7875B4B
	devName=openEuler
	devType=175
	addrNum=1
		addr1:type=3,ip=192.168.10.3,port=44749,peerUid=
	capabilityBitmapNum=1
		capabilityBitmap[1]=0xc0
	custData=

    将一端作为发送方，输出字符'c'后，会显示在同一个本地神经网络中的其他设备信息

    .. code-block:: console

        Input c to commnuication, Input s to stop:c
        <GetAllNodeDeviceInfo>return 1 Node
        <num 1>deviceName=openEuler
        	networkId=15a5e255f24073630c04a52f83679677b817df008fc11a22711cb3038de9d9b1
        	Type=0

    继续输入节点序号后，将尝试创建与对应节点的连接并传输测试数据

    .. code-block:: console

        Input Node num to commnunication:1

    若传输成功，则在对端设备上会显示传输数据的结果

    .. code-block:: console

        <ByteRecived>CB: session 2 received 17 bytes data=hello world test

    测试结束后，输入字符's'退出双端程序

可信设备添加
**************

**背景**

软总线在创建连接的过程中，会调用hichain模块的认证接口，与对端的设备进行认证操作。hichain模块为OpenHarmony提供设备认证能力，支持通过点对点认证方式创建可信群组。

若仅为openEuler之间的软总线连接，可以通过绕过hichain认证或者自定义认证实现。但如果openEuler和OpenHarmony设备之间要互连互通，则需要在openEuler上支持hichain的点对点认证和可信群组创建能力。

**应用说明**

hichain模块与软总线一样，分为服务端和客户端:

* **服务端**:在openEuler上，实现了hichain和softbus的服务端共进程，即用户仅需拉起softbus服务端，无需额外操作hichain服务端。

* **客户端**:通过hichain的客户端提供的API，可以创建群组，并请求添加群组成员，从而将多个设备添加到可信群组。

hichain的客户端为动态链接库，用户可以单独链接hichain的客户端进行可信群组创建。在可信群组创建后，软总线会自动触发组网，支持后续软总线客户端的连接和传输。


**客户端API**

hichain的客户端API头文件在嵌入式版本提供的sdk中对外开放，可在客户端代码中引用。

.. code-block:: console

  #include "device_auth.h"

1.直接调用接口

+----------------------------+--------------------------------------------------------------------+
| InitDeviceAuthService      | 初始化hichain客户端                                                |
+----------------------------+--------------------------------------------------------------------+
| GetGmInstance              | 获取客户端群组管理的操作函数组                                     |
+----------------------------+--------------------------------------------------------------------+
| DestroyDeviceAuthService   | 注销hichain客户端                                                  |
+----------------------------+--------------------------------------------------------------------+

2.GetGmInstance返回的操作函数组

+----------------------------+--------------------------------------------------------------------+
| regCallback                | 注册群组创建和请求回调函数                                         |
+----------------------------+--------------------------------------------------------------------+
| unRegCallback              | 解注册群组回调函                                                   |
+----------------------------+--------------------------------------------------------------------+
| createGroup                | 创建新的群组                                                       |
+----------------------------+--------------------------------------------------------------------+
| getGroupInfo               | 查询本地群组信息                                                   |
+----------------------------+--------------------------------------------------------------------+
| destroyInfo                | 释放通过getGroupInfo申请的内存                                     |
+----------------------------+--------------------------------------------------------------------+
| addMemberToGroup           | 请求添加成员到群组                                                 |
+----------------------------+--------------------------------------------------------------------+
| isDeviceInGroup            | 查询某个设备是否在群组中                                           |
+----------------------------+--------------------------------------------------------------------+

更详细的接口说明，请参考社区hichain模块代码实现。

**客户端编译**

客户端提供动态链接库：libdeviceauth_sdk.z.so

用户使用hichain创建群组和添加可信设备时，需要作为客户端程序显式链接该动态库，即可通过函数调用使用hichain提供的API。

.. code-block:: console

    #: ${CROSS_COMPILE}ld -ldeviceauth_sdk.z -lcjson


**使用范例**

1.按照hichain的点对点pin码认证方式，需要通过设备创建群组（host），另一个台设备请求添加成员到该群组（target），实例代码如下：

.. code-block:: console

    #include <stdio.h>
    #include <cjson/cJSON.h>
    #include <securec.h>
    #include <softbus_common.h>
    #include <device_auth.h>
    #include <parameter.h>
    
    #define APP_ID "hichain_test"
    #define DEFAULT_GROUP_NAME "dsoftbus"
    #define DEFAULT_PIN_CODE "123456"
    #define MAX_UDID_LEN 65
    #define MAX_GROUP_LEN 65
    
    #define FIELD_ETH_IP "ETH_IP"
    #define FIELD_ETH_PORT "ETH_PORT"
    #define FIELD_WLAN_IP "WIFI_IP"
    #define FIELD_WLAN_PORT "WIFI_PORT"
    
    static const DeviceGroupManager *g_hichainGmInstance = NULL;
    static char g_udid[MAX_UDID_LEN];
    static char g_groupId[MAX_GROUP_LEN];
    static int64_t g_requestId = 1;
    
    static const char *GetStringFromJson(const cJSON *obj, const char *key)
    {
    	cJSON *item;
    
    	if (obj == NULL || key == NULL)
    		return NULL;
    
    	item = cJSON_GetObjectItemCaseSensitive(obj, key);
    	if (item != NULL && cJSON_IsString(item)) {
    		return cJSON_GetStringValue(item);
    	} else {
    		int len = cJSON_GetArraySize(obj);
    		for (int i = 0; i < len; i++) {
    			item = cJSON_GetArrayItem(obj, i);
    			if (cJSON_IsObject(item)) {
    				const char *value = GetStringFromJson(item, key);
    				if (value != NULL)
    					return value;
    			}
    		}
    	}
    	return NULL;
    }
    
    static int HichainSaveGroupID(const char *param)
    {
    	cJSON *msg = cJSON_Parse(param);
    	const char *value = NULL;
    
    	if (msg == NULL) {
    		printf("HichainSaveGroupID: cJSON_Parse fail\n");
    		return -1;
    	}
    
    	value = GetStringFromJson(msg, FIELD_GROUP_ID);
    	if (value == NULL) {
    		printf("HichainSaveGroupID:GetStringFromJson fail\n");
    		cJSON_Delete(msg);
    		return -1;
    	}
    
    	memcpy_s(g_groupId, MAX_GROUP_LEN, value, strlen(value));
    	printf("HichainSaveGroupID:groupID=%s\n", g_groupId);
    
    	cJSON_Delete(msg);
    	return 0;
    }
    
    static void HiChainGmOnFinish(int64_t requestId, int operationCode, const char *returnData)
    {
    	if (operationCode == GROUP_CREATE && returnData != NULL) {
    		printf("create new group finish:requestId=%lld, returnData=%s\n", requestId, returnData);
    		HichainSaveGroupID(returnData);
    	} else if (operationCode == MEMBER_JOIN) {
    		printf("member join finish:requestId=%lld, returnData=%s\n", requestId, returnData);
    
    	} else {
    		printf("<HiChainGmOnFinish>CB:requestId=%lld, operationCode=%d, returnData=%s\n", requestId, operationCode, returnData);
    	}
    }
    
    static void HiChainGmOnError(int64_t requestId, int operationCode, int errorCode, const char *errorReturn)
    {
    	printf("<HiChainGmOnError>CB:requestId=%lld, operationCode=%d, errorCode=%d, errorReturn=%s\n", requestId, operationCode, errorCode, errorReturn);
    }
    
    static char *HiChainGmOnRuest(int64_t requestId, int operationCode, const char *reqParams)
    {
    	cJSON *msg = cJSON_CreateObject();
    	char *param = NULL;
    
    	printf("<HiChainGmOnRuest>CB:requestId=%lld, operationCode=%d, reqParams=%s", requestId, operationCode, reqParams);
    
    	if (operationCode != MEMBER_JOIN) {
    		return NULL;
    	}
    
    	if (msg == NULL) {
    		printf("HiChainGmOnRuest: cJSON_CreateObject fail\n");
    	}
    
    	if (cJSON_AddNumberToObject(msg, FIELD_CONFIRMATION, REQUEST_ACCEPTED) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_PIN_CODE, DEFAULT_PIN_CODE) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_DEVICE_ID, g_udid) == NULL) {
    		printf("HiChainGmOnRuest: cJSON_AddToObject fail\n");
    		cJSON_Delete(msg);
    		return NULL;
    	}
    
    	param = cJSON_PrintUnformatted(msg);
    	cJSON_Delete(msg);
    	return param;
    }
    
    static const DeviceAuthCallback g_groupManagerCallback = {
    	.onRequest = HiChainGmOnRuest,
    	.onError = HiChainGmOnError,
    	.onFinish = HiChainGmOnFinish,
    };
    
    int HichainGmRegCallback(void)
    {
    	return g_hichainGmInstance->regCallback(APP_ID, &g_groupManagerCallback);
    }
    
    void HichainGmUnRegCallback(void)
    {
    	g_hichainGmInstance->unRegCallback(APP_ID);
    }
    
    int HichainGmGetGroupInfo(char **groupVec, uint32_t *num)
    {
    	cJSON *msg = cJSON_CreateObject();
    	char *param = NULL;
    	int ret = -1;
    
    	if (msg == NULL) {
    		printf("HichainGmGetGroupInfo: cJSON_CreateObject fail\n");
    		return -1;
    	}
    
    	if (cJSON_AddNumberToObject(msg, FIELD_GROUP_TYPE, PEER_TO_PEER_GROUP) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_GROUP_NAME, DEFAULT_GROUP_NAME) == NULL ||
    		cJSON_AddNumberToObject(msg, FIELD_GROUP_VISIBILITY, GROUP_VISIBILITY_PUBLIC) == NULL) {
    		printf("HichainGmGetGroupInfo: cJSON_AddToObject fail\n");
    		goto err_cJSON_Delete;
    	}
    	param = cJSON_PrintUnformatted(msg);
    	if (param == NULL) {
    		printf("HichainGmGetGroupInfo: cJSON_PrintUnformatted fail\n");
    		goto err_cJSON_Delete;
    	}
    
    	ret = g_hichainGmInstance->getGroupInfo(ANY_OS_ACCOUNT, APP_ID, param, groupVec, num);
    	if (ret != 0) {
    		printf("getGroupInfo fail:%d", ret);
    		goto err_getGroupInfo;
    	}
    
    err_getGroupInfo:
    	cJSON_free(param);
    err_cJSON_Delete:
    	cJSON_Delete(msg);
    	return ret;
    }
    
    void HichainGmDestroyGroupInfo(char **groupVec)
    {
    	g_hichainGmInstance->destroyInfo(groupVec);
    }
    
    int HichainGmCreatGroup(void)
    {
    	cJSON *msg = cJSON_CreateObject();
    	char *param = NULL;
    	int ret;
    
    	if (msg == NULL)
    		return -1;
    
    	if (cJSON_AddNumberToObject(msg, FIELD_GROUP_TYPE, PEER_TO_PEER_GROUP) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_DEVICE_ID, g_udid) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_GROUP_NAME, DEFAULT_GROUP_NAME) == NULL ||
    		cJSON_AddNumberToObject(msg, FIELD_USER_TYPE, 0) == NULL ||
    		cJSON_AddNumberToObject(msg, FIELD_GROUP_VISIBILITY, GROUP_VISIBILITY_PUBLIC) == NULL ||
    		cJSON_AddNumberToObject(msg, FIELD_EXPIRE_TIME, EXPIRE_TIME_MAX) == NULL) {
    		printf("HichainGmCreatGroup: cJSON_AddToObject fail\n");
    		cJSON_Delete(msg);
    		return -1;
    	}
    	param = cJSON_PrintUnformatted(msg);
    	if (param == NULL) {
    		printf("HichainGmCreatGroup: cJSON_PrintUnformatted fail\n");
    		cJSON_Delete(msg);
    		return -1;
    	}
    
    	ret = g_hichainGmInstance->createGroup(ANY_OS_ACCOUNT, g_requestId++, APP_ID, param);
    
    	cJSON_free(param);
    	cJSON_Delete(msg);
    	return ret;
    }
    
    bool HichainIsDeviceInGroup(const char *groupId, const char *devId)
    {
    	return g_hichainGmInstance->isDeviceInGroup(ANY_OS_ACCOUNT, APP_ID, groupId, devId);
    }
    
    int HichainGmAddMemberToGroup(const DeviceInfo *device, const char *groupId)
    {
    	cJSON *msg = cJSON_CreateObject();
    	cJSON *addr = NULL;
    	char *param = NULL;
    	int ret = -1;
    
    	if (msg == NULL) {
    		printf("HichainGmAddMemberToGroup: cJSON_CreateObject1 fail\n");
    		return -1;
    	}
    
    	addr = cJSON_CreateObject();
    	if (addr == NULL) {
    		printf("HichainGmAddMemberToGroup: cJSON_CreateObject2 fail\n");
    		goto err_cJSON_CreateObject;
    	}
    
    	for (unsigned int i = 0; i < device->addrNum; i++) {
    		if (device->addr[i].type == CONNECTION_ADDR_ETH) {
    			if (cJSON_AddStringToObject(addr, FIELD_ETH_IP, device->addr[i].info.ip.ip) == NULL ||
    					cJSON_AddNumberToObject(addr, FIELD_ETH_PORT, device->addr[i].info.ip.port) == NULL) {
    				printf("HichainGmAddMemberToGroup: cJSON_AddToObject1 fail\n");
    				goto err_cJSON_AddToObject;
    			}
    		} else if (device->addr[i].type == CONNECTION_ADDR_WLAN) {
    			if (cJSON_AddStringToObject(addr, FIELD_WLAN_IP, device->addr[i].info.ip.ip) == NULL ||
    					cJSON_AddNumberToObject(addr, FIELD_WLAN_PORT, device->addr[i].info.ip.port) == NULL) {
    				printf("HichainGmAddMemberToGroup: cJSON_AddToObject2 fail\n");
    				goto err_cJSON_AddToObject;
    			}
    		} else {
    			printf("unsupport connection type:%d\n", device->addr[i].type);
    			goto err_cJSON_AddToObject;
    		}
    	}
    
    	param = cJSON_PrintUnformatted(addr);
    	if (param == NULL) {
    		printf("HichainGmAddMemberToGroup: cJSON_PrintUnformatted1 fail\n");
    		goto err_cJSON_AddToObject;
    	}
    
    	if (cJSON_AddStringToObject(msg, FIELD_GROUP_ID, groupId) == NULL ||
    		cJSON_AddNumberToObject(msg, FIELD_GROUP_TYPE, PEER_TO_PEER_GROUP) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_PIN_CODE, DEFAULT_PIN_CODE) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_DEVICE_ID, g_udid) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_GROUP_NAME, DEFAULT_GROUP_NAME) == NULL ||
    		cJSON_AddBoolToObject(msg, FIELD_IS_ADMIN, false) == NULL ||
    		cJSON_AddStringToObject(msg, FIELD_CONNECT_PARAMS, param) == NULL) {
    		printf("HichainGmAddMemberToGroup: cJSON_AddToObject4 fail\n");
    		goto err_cJSON_AddToObject1;
    	}
    
    	cJSON_free(param);
    	param = cJSON_PrintUnformatted(msg);
    	if (param == NULL) {
    		printf("HichainGmAddMemberToGroup: cJSON_PrintUnformatted fail\n");
    		goto err_cJSON_CreateObject;
    	}
    
    	ret = g_hichainGmInstance->addMemberToGroup(ANY_OS_ACCOUNT, g_requestId++, APP_ID, param);
    	if (ret != 0) {
    		printf("addMemberToGroup fail:%d\n", ret);
    	}
    
    err_cJSON_AddToObject1:
    	cJSON_free(param);
    err_cJSON_AddToObject:
    	cJSON_Delete(addr);
    err_cJSON_CreateObject:
    	cJSON_Delete(msg);
    	return ret;
    }
    
    int HichainInit(void)
    {
    	char *groupVec = NULL;
    	uint32_t num;
    	int ret;
    
    	ret = GetDevUdid(g_udid, MAX_UDID_LEN);
    	if (ret) {
    		printf("GetDevUdid fail:%d\n", ret);
    		return ret;
    	}
    
    	ret = InitDeviceAuthService();
    	if (ret != 0) {
    		printf("InitDeviceAuthService fail:%d\n", ret);
    		return ret;
    	}
    
    	g_hichainGmInstance = GetGmInstance();
    	if (g_hichainGmInstance == NULL) {
    		printf("GetGmInstance fail\n");
    		ret = -1;
    		goto err_GetGmInstance;
    	}
    
    	ret = HichainGmRegCallback();
    	if (ret != 0) {
    		printf("HichainGmregCallback fail.:%d\n", ret);
    		goto err_HichainGmRegCallback;
    	}
    
    	ret = HichainGmGetGroupInfo(&groupVec, &num);
    	if (ret != 0) {
    		printf("HichainGmGetGroupInfo fail:%d\n", ret);
    		goto err_HichainGmGetGroupInfo;
    	}
    
    	if (num == 0) {
    		ret = HichainGmCreatGroup();
    		if (ret) {
    			printf("HichainGmCreatGroup fail:%d\n", ret);
    			goto err_HichainGmCreatGroup;
    		}
    	} else {
    		printf("HichainGmGetGroupInfo:num=%u\n", num);
    		HichainSaveGroupID(groupVec);
    		HichainGmDestroyGroupInfo(&groupVec);
    	}
    
    	return 0;
    
    err_HichainGmCreatGroup:
    err_HichainGmGetGroupInfo:
    	HichainGmUnRegCallback();
    err_HichainGmRegCallback:
    err_GetGmInstance:
    	DestroyDeviceAuthService();
    	return ret;
    }

.. note::

    * 在HichainInit完成后，可以在任意一端调用HichainGmAddMemberToGroup申请将本端设备添加到对端的群组中。

    * 认证中使用的pin码，分别在两端设备中通过addMemberToGroup函数和HiChainGmOnRuest回调函数接口传入，实际应用中可由用户随机生成。

    * HichainGmAddMemberToGroup认证过程中需要交互的对端信息，如deviceInfo，groupID等，实际应用中可通过软总线的发现能力和认证通道进行数据交互。

2.与OpenHarmony互联时，可通过上述方式创建双方信任的可信群组和成员，也可使用分布式硬件中的device manger模块进行更便捷的可信群组创建，该模块兼容OpenHarmony的pin码弹窗等功能，但需要openEuler额外支持。


全量编译指导
**************

当用户有需求自定义修改软总线功能模块时，可使用全量编译方式构建软总线的各个子模块。

嵌入式版本提供的dsoftbus代码已集成于yocto构建系统，作为一个package存在，编译参照 :ref:`openeuler_embedded_oebuild` 章节。

用户也可按照镜像编译指导完成环境准备后按如下命令单独进行编译（和单独编译package方法一致）

.. code-block:: console

    bitbake dsoftbus

编译过程和结果遵循yocto构建策略，日志和生成物参考yocto bb文件和默认工作目录。


限制约束
**************

1.支持wifi和有限的标准以太局域网下的coap设备发现和传输。蓝牙目前仅支持ble发现，ble发现需要开启蓝牙，参照 :ref:`bluetooth_config` ，br连接和通信功能在后续版本中持续支持。

FAQ
****

1. 执行softbus_client程序输入c后没有可传输的node节点？

  1）确认两个设备网络是否连通
    如果没有DeviceFound的回调，说明此时无法发现设备，设备之间网络不通。
    如果使用qemu来测试，同时HOST机器上安装了docker，此时启动两个两个设备并用bridge来连接时会导致两个qemu设备之间网络不通，原因应该是docker改了默认的bridge防火墙转发配置导致的，可用如下命令解决:

    .. code-block:: console

      echo 0 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

    如果不是qemu，其他设备请务必保证设备之间网络连通。

  2）确保已经完成设备认证
    如果设备之间网络已经连通，并且有DeviceFound的回调，那么有可能是未完成设备认证，出于安全考虑，22.09之后版本均需要完成设备认证后，才能组网成功和传输，因此执行softbus_client程序前应该先做设备认证，设备认证demo可参考 `hichain_main.c <https://gitee.com/liheavy/softbus_client_app/blob/master/hichain_sample/hichain_main.c>`_ 。

2. 设备认证过程中失败？

  hichain_main认证的流程中有两步，第一步创建群组，第二步将设备加入群组。并且这两步操作均是异步的，即hichain_main(hichain客户端)中直接调用接口成功并不代表hichain服务端也调用处理成功，需要等待hichain服务端的回调成功，才能保证操作是成功的。

  因此在使用hichain_main的过程中务必保证先创建群组操作成功后再进行设备加入群组操作，如未按流程操作导致认证过程失败，可将 ``/data/data`` 目录下数据清空后，重启分布式软总线服务，再次尝试设备认证流程。

3. 分布式软总线服务端日志出现 ``GetNetworkIfIp ifName:eth0 fail``

  当前分布式软总线通过 ``eth0`` 这个有线网卡名来获取网卡绑定的ip及其他信息，如果当前系统的网卡没有 ``eth0`` 的网卡，则会获取ip失败，导致整个分布式软总线不可用，无线网卡名称同理，默认使用的是 ``wlan0`` 。
  解决方案：
  1）修改分布式软总线源码，将使用 ``eth0`` 和 ``wlan0`` 的部分代码替换为系统中实际可用的网卡名称。
  2）修改系统的网卡名称为 ``eth0`` 或者 ``wlan0`` 。

4. 当系统中同时存在有线网卡和无线网卡时，优先级问题

  当前分布式软总线对有线网卡和无线网卡同时支持时，采用的是有线网卡优先级会大于无线网卡。
  可以通过修改 ``BindToDevice`` 函数中以下代码片段来进行调整：

  .. code-block:: c

    /* strategy: ethernet have higher priority */
    if (memcmp(buf[i].ifr_name, ETH_DEV_NAME_PRE, ethNameLen) == 0) {
        ifBinding = &buf[i];
        break;
    } else if (memcmp(buf[i].ifr_name, WLAN_DEV_NAME_PRE, wlanNameLen) == 0) {
        ifBinding = &buf[i];
    }

如果以上没有解决你的问题，可以记录下分布式软总线的服务端日志和客户端日志，在 `分布式软总官方仓库 <https://gitee.com/openeuler/dsoftbus_standard>`_ 提相关的issue，请尽量详细描述清楚你的操作步骤，包括自己所做的一些尝试。
