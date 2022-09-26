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

* **即插即用**:快速便捷发现周边设备

* **自由流转**:各设备间自组网，任意建立业务连接，实现自由通信

* **高效传输**:通过wifi、蓝牙设备下软硬件协同最大化发挥硬件传输性能

软总线南向支持wifi（22.09新增）和有线以太网通信，同时后续可持续拓展蓝牙等通信方式。并为北向的分布式应用提供统一的API接口，屏蔽底层通信机制。

软总线依赖于设备认证、IPC、日志和系统参数（SN号）等周边模块，嵌入式系统中将这些依赖模块进行了样板性质的替换，以实现软总线基本功能。实际的周边模块功能实现，还需要用户根据实际业务场景进行丰富和替换，以拓展软总线能力。

应用指南
**************

此部分内容基于22.09描述，建议使用22.09分支的分布式软总线特性，功能更为完善。

其他历史信息请基于对应分支的yocto-meta-openeuler/docs进行查阅。

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

.. attention::

    用户请参考部署模型，保证单设备节点上有且仅有唯一的softbus_server_main进程。


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

	${CC} -lsoftbus_client.z -lsec_shared.z softbus_client_main.c -o softbus_client_main

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
| createGroup                | 创建新的群组                                                       |
+----------------------------+--------------------------------------------------------------------+
| getGroupInfo               | 查询本地群组信息                                                   |
+----------------------------+--------------------------------------------------------------------+
| addMemberToGroup           | 请求添加成员到群组                                                 |
+----------------------------+--------------------------------------------------------------------+
| unRegCallback              | 解注册群组回调函                                                   |
+----------------------------+--------------------------------------------------------------------+
| deleteGroup                | 删除群组                                                           |
+----------------------------+--------------------------------------------------------------------+
| deleteMemberFromGroup      | 从群组内删除成员                                                   |
+----------------------------+--------------------------------------------------------------------+

更详细的接口说明，请参考hichain模块代码实现。

**客户端编译**

客户端提供动态链接库：libdeviceauth_sdk.z.so

用户使用hichain创建群组和添加可信设备时，需要作为客户端程序显式链接该动态库，即可通过函数调用使用hichain提供的API。

.. code-block:: console

    #: $(CROSS_COMPILE)-ld -ldeviceauth_sdk.z


**使用范例**

1.按照hichain的点对点pin码认证方式，需要一台设备创建群组（host），另一个台设备请求添加成员到该群组（target），实例代码如下：

.. code-block:: console

    #include "bus_center_adapter.h"
    #define DEFAULT_GROUP_ID "54E8637468D7518EF4AACA71A958313A5FAACFC899DD1207AAB60568B20FF876"
    #define APP_ID "test"
    #define DEFAULT_REQ_ID 1000000000
    #define DEFAULT_PIN_CODE "123456"
    #define MAX_LEN 65

    static char DEFAULT_UDID_NAME[MAX_LEN];
    static int DEFAULT_PORT;
    static DeviceAuthCallback g_GroupManagerCallback;

    void HichainGetGroupID(const char *param, bool isArray)
    {
        char groupID[MAX_LEN];
        cJSON *msg = cJSON_Parse(param);
        if (isArray) {
             cJSON *Item = cJSON_GetArrayItem(msg, 0);
             GetJsonObjectStringItem(Item, FIELD_GROUP_ID, groupID, MAX_LEN);
        } else {
             GetJsonObjectStringItem(msg, FIELD_GROUP_ID, groupID, MAX_LEN);
        }
        cJSON_Delete(msg);
        SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_INFO, "HichainSaveGroupID:groupID=%s", groupID);
    }

    void HiChainGmOnFinish(int64_t requestId, int operationCode, const char *returnData)
    {
        if (requestId == DEFAULT_REQ_ID && operationCode == GROUP_CREATE && returnData != NULL) {
            SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_INFO, "HiChainGmOnFinish returnData=%s", returnData);
            HichainGetGroupID(returnData, false);
        }
    }

    void HiChainGmOnError(int64_t requestId, int operationCode, int errorCode, const char *errorReturn)
    {
        SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_INFO, "HiChainGmOnError:requestId=%ld, operationCode=%d, errorCode=%d, errorReturn=%s", requestId, operationCode, errorCode, errorReturn);
    }

    char *HiChainGmOnRuest(int64_t requestId, int operationCode, const char *reqParams)
    {
        cJSON *msg = cJSON_CreateObject();

        SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_INFO, "HiChainGmOnRuest:requestId=%ld, operationCode=%d, reqParams=%s", requestId, operationCode, reqParams);

        AddNumberToJsonObject(msg, FIELD_CONFIRMATION, REQUEST_ACCEPTED);
        AddStringToJsonObject(msg, FIELD_PIN_CODE, DEFAULT_PIN_CODE);
        AddStringToJsonObject(msg, FIELD_DEVICE_ID, DEFAULT_UDID_NAME);
        char *param = cJSON_PrintUnformatted(msg);
        char *buf = strdup(param);
        cJSON_free(param);
        cJSON_Delete(msg);
        return buf;
    }

    static int32_t HichainGmRegCallback(void)
    {
        int32_t ret;

        g_GroupManagerCallback.onRequest = HiChainGmOnRuest;
        g_GroupManagerCallback.onError = HiChainGmOnError;
        g_GroupManagerCallback.onFinish = HiChainGmOnFinish;
        ret = g_hichainGmInstance->regCallback(APP_ID, &g_GroupManagerCallback);
        return ret;
    }

    int32_t HichainGmAddMemberToGroup(void)
    {
        cJSON *msg = cJSON_CreateObject();
        cJSON *addr = cJSON_CreateObject();
        char *param = NULL;
        int32_t ret;

        AddStringToJsonObject(msg, FIELD_GROUP_ID, DEFAULT_GROUP_ID);
        AddNumberToJsonObject(msg, FIELD_GROUP_TYPE, PEER_TO_PEER_GROUP);
        AddStringToJsonObject(msg, FIELD_PIN_CODE, DEFAULT_PIN_CODE);
        cJSON_AddBoolToObject(msg, FIELD_IS_ADMIN, false);
        AddStringToJsonObject(msg, FIELD_DEVICE_ID, DEFAULT_UDID_NAME);
        AddStringToJsonObject(msg, FIELD_GROUP_NAME, "dsoftbus");
        AddNumberToJsonObject(msg, FIELD_IS_ADMIN, false);

        AddStringToJsonObject(addr, "ETH_IP", "192.168.1.3");
        AddNumberToJsonObject(addr, "ETH_PORT", DEFAULT_PORT);
        param = cJSON_PrintUnformatted(addr);
        AddStringToJsonObject(msg, FIELD_CONNECT_PARAMS, param);
        printf("addr string:%s\n", param);
        cJSON_free(param);

        param = cJSON_PrintUnformatted(msg);
        printf("member string:%s\n", param);

        ret = g_hichainGmInstance->addMemberToGroup(ANY_OS_ACCOUNT, DEFAULT_REQ_ID, APP_ID, param);

        cJSON_free(param);
        cJSON_Delete(msg);
        return ret ;
    }

    int32_t HichainGmCreatGroup(void)
    {
        cJSON *msg = cJSON_CreateObject();
        char *param = NULL;
        int32_t ret;

        AddNumberToJsonObject(msg, FIELD_GROUP_TYPE, PEER_TO_PEER_GROUP);
        AddStringToJsonObject(msg, FIELD_DEVICE_ID, DEFAULT_UDID_NAME);
        AddStringToJsonObject(msg, FIELD_GROUP_NAME, "dsoftbus");
        AddNumberToJsonObject(msg, FIELD_USER_TYPE, 0);
        AddNumberToJsonObject(msg, FIELD_GROUP_VISIBILITY, GROUP_VISIBILITY_PUBLIC);
        AddNumberToJsonObject(msg, FIELD_EXPIRE_TIME, EXPIRE_TIME_MAX);
        param = cJSON_PrintUnformatted(msg);

        ret = g_hichainGmInstance->createGroup(ANY_OS_ACCOUNT, DEFAULT_REQ_ID, APP_ID, param);

        cJSON_free(param);
        cJSON_Delete(msg);
        return ret;
    }

    static int32_t HichainGmGetGroupInfo(uint32_t *num)
    {
        cJSON *msg = cJSON_CreateObject();
        char *param = NULL;
        char *groupVec = NULL;
        int32_t ret;

        AddNumberToJsonObject(msg, FIELD_GROUP_TYPE, PEER_TO_PEER_GROUP);
        AddStringToJsonObject(msg, FIELD_GROUP_NAME, "dsoftbus");
        AddNumberToJsonObject(msg, FIELD_GROUP_VISIBILITY, GROUP_VISIBILITY_PUBLIC);
        param = cJSON_PrintUnformatted(msg);

        ret = g_hichainGmInstance->getGroupInfo(ANY_OS_ACCOUNT, APP_ID, param, &groupVec, num);
        if (*num) {
            SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_INFO, "HichainGmGetGroupInfo:groupVec=%s", groupVec);
            HichainGetGroupID(groupVec, true);
        }

        cJSON_free(param);
        cJSON_Delete(msg);
        return ret;
    }

    int32_t HichainGmInit(void)
    {
        uint32_t num = 0;
        int32_t ret;

        ret = GetCommonDevInfo(COMM_DEVICE_KEY_UDID, DEFAULT_UDID_NAME, MAX_LEN);
        printf("ret=%d, UDID=%s\n", ret, DEFAULT_UDID_NAME);

        ret = HichainGmRegCallback();
        if (ret != SOFTBUS_OK) {
            SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_ERROR, "HichainGmregCallback failed\n");
            goto err_HichainGmRegCallback;
        }

        ret = HichainGmGetGroupInfo(&num);
        if (ret != SOFTBUS_OK) {
            SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_ERROR, "HichainGmGetGroupInfo failed\n");
            goto err_HichainGmGetGroupInfo;
        }

    #if host
        if (num == 0) {
            ret = HichainGmCreatGroup();
            if (ret) {
                SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_ERROR, "HichainGmCreatGroup failed\n");
                return ret;
            }
        }
    #else
        ret = scanf("%d", &DEFAULT_PORT);
        if (ret < 0) {
             printf("scanf error\n");
        }
        printf("port is:%d\n", DEFAULT_PORT);
        ret = HichainGmAddMemberToGroup();
        if (ret) {
            SoftBusLog(SOFTBUS_LOG_AUTH, SOFTBUS_LOG_ERROR, "HichainGmAddMemberToGroup failed\n");
            return ret;
        }
    #endif
        return ret;

    err_HichainGmGetGroupInfo:
    err_HichainGmRegCallback:
        return ret;
    }

.. note::

    * 通过host宏定义区分host和target设备：在host上创建群组，target上申请添加成员。

    * 认证中使用的pin码，可由用户随机生成并传入。

    * 认证过程中需要交互部分对端信息，如groupID等，实际应用中需要借助软总线的发现能力和认证通道进行数据交互。

2.与OpenHarmony互联时，可通过上述方式创建双方信任的可信群组和成员，也可使用分布式硬件中的device manger模块进行更便捷的可信群组创建，该模块兼容OpenHarmony的pin码弹窗等功能，但需要openEuler额外支持。


全量编译指导
**************

当用户有需求自定义修改软总线功能模块时，可使用全量编译方式构建软总线的各个子模块。

嵌入式版本提供的dsoftbus代码已集成于yocto构建系统，作为一个package存在，编译依托于embedded版本发布的容器镜像进行，搭建容器构建环境请参考 :ref:`container_build` 章节。

用户也可按照镜像编译指导完成环境准备后按如下命令单独进行编译（和单独编译package方法一致）

.. code-block:: console

    bitbake dsoftbus

编译过程和结果遵循yocto构建策略，日志和生成物参考yocto bb文件和默认工作目录。


限制约束
**************

1.支持wifi和有限的标准以太局域网下的coap设备发现和传输。ble等南向协议拓展功能在后续版本中持续支持。
