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

    printf("\nInput Node num to communication:");
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
