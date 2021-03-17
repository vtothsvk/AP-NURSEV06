#ifndef WIFIMANAGER_H_
#define WIFIMANAGER_H_

#include "main.h"

typedef enum wifi_error_codes{
    WIFI_OK = 0,
    WIFI_ON_FAIL = 1,
    WIFI_SSID_FAIL = 2,
    WIFI_PASS_FAIL = 3,
    WIFI_SOFTR_FAIL = 4,
    WIFI_URL_FAIL = 5,
    WIFI_TYPE_FAIL = 6,
    WIFI_POST_FAIL = 7
}wifi_error_t;

wifi_error_t startWifiManager();
void ERROR_CHECK(wifi_error_t error);
void isConnected(void);
void wifiGetIp(void);
wifi_error_t postData(char* payload);

#endif//WIFIMANAGER_H_
