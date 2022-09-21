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
| SendBytes                  | 根据建好的连接ID，进行数据传输。                                   |
+----------------------------+--------------------------------------------------------------------+

各API参数详见头文件描述。

**客户端编译**

客户端提供动态链接库：libsoftbus_client.z.so

用户使用软总线时，需要作为客户端程序显式链接该动态库，即可通过函数调用使用软总线提供的API。

.. code-block:: console

    #: $(CROSS_COMPILE)-ld -lsoftbus_client.z

**应用示例**

使用qemu部署分布式软总线，编写客户端程序，使其能够列出所有发现的设备信息。

1. 编写客户端程序

    编写客户端程序依托于embedded版本发布的SDK，请参考 :ref:`getting_started` 章节进行SDK环境使用准备

    创建一个 :file:`main.c` 文件，源码如下：

    .. code-block:: c

        #include "dsoftbus/softbus_bus_center.h"
        #include <stdio.h>
        #include <stdlib.h>
        int main(void)
        {
            int32_t infoNum = 10;
            NodeBasicInfo **testInfo = malloc(sizeof(NodeBasicInfo *) * infoNum);
            int ret = GetAllNodeDeviceInfo("testClient", testInfo, &infoNum);
            if (ret != 0) {
                printf("Get node device info fail.\n");
                return 0;
            }
            printf("Get node num: %d\n", infoNum);
            for (int i = 0; i < infoNum; i++) {
                printf("\t networkId: %s, deviceName: %s, deviceTypeId: %d\n",
                testInfo[i]->networkId,
                testInfo[i]->deviceName,
                testInfo[i]->deviceTypeId);
            }
            for (int i = 0; i < infoNum; i++) {
                FreeNodeInfo(testInfo[i]);
            }
            free(testInfo);
            testInfo = NULL;

            return 0;
        }


    创建一个 :file:`CMakeLists.txt` 文件，源码如下：

    .. code-block:: cmake

        project(dsoftbus_hello C)
        add_executable(dsoftbus_hello main.c)
        target_link_libraries(dsoftbus_hello dsoftbus_bus_center_service_sdk.z)

    编译客户端

    .. code-block:: console

        mkdir build
        cd build
        cmake ..
        make


    编译完成后会得到dsoftbus_hello

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

        scp dsoftbus_hello root@192.168.10.2:/
        scp dsoftbus_hello root@192.168.10.3:/

    分别在qemu1和qemu2的根目录下运行dsoftbus_hello，将得到如下输出

    qemu1

    .. code-block:: console

        [LNN]NodeStateCbCount is 10
        [LNN]BusCenterClientInit init OK!
        [DISC]Init success
        [TRAN]init tcp direct channel success.
        [TRAN]init succ
        [COMM]softbus server register service success!

        [COMM]softbus sdk frame init success.
        Get node num: 1
                networkId: 714373d691265f9a736442c01459ba39236642c743a71750bb63eb73cde24f5f, deviceName: UNKNOWN, deviceTypeId: 0

    qemu2

    .. code-block:: console

        [LNN]NodeStateCbCount is 10
        [LNN]BusCenterClientInit init OK!
        [DISC]Init success
        [TRAN]init tcp direct channel success.
        [TRAN]init succ
        [COMM]softbus server register service success!

        [COMM]softbus sdk frame init success.
        Get node num: 1
                networkId: eaf591f64bab3c20304ed3d3ff4fe1d878a0fd60bf8c85c96e8a8430d81e4076, deviceName: UNKNOWN, deviceTypeId: 0

    qemu1和qemu2分别输出了发现的对方设备的基础信息。


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
