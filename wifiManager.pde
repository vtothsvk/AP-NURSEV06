#include "wifiManager.h"

// WiFi AP settings 
//char ESSID[] = "fei-iot";
//char PASSW[] = "F+e-i.feb575";
//char ESSID[] = "meshlium6970";
//char PASSW[] = "alsnurse";
char ESSID[] = "Allegro-512";
char PASSW[] = "*youarita@35";

uint8_t socket = SOCKET0;
char type[] = "http";
char host[] = "192.168.1.44";
char port[] = "1880";
char url[]  = "waspmote";

// CA Certifikat konrektneho kusu MESHLIA
char TRUSTED_CA[] =
"-----BEGIN CERTIFICATE-----\r"\
"MIIDxTCCAq2gAwIBAgIJALzp3i3uMeiOMA0GCSqGSIb3DQEBCwUAMHgxCzAJBgNV\r"\
"BAYTAkVTMQ8wDQYDVQQIDAZBcmFnb24xETAPBgNVBAcMCFphcmFnb3phMTIwMAYD\r"\
"VQQKDClMaWJlbGl1bSBDb211bmljYWNpb25lcyBEaXN0cmlidWlkYXMgUy5MLjER\r"\
"MA8GA1UEAwwIbWVzaGxpdW0wIBcNMjAwOTE2MTIwNzM5WhgPMjEyMDA4MjMxMjA3\r"\
"MzlaMHgxCzAJBgNVBAYTAkVTMQ8wDQYDVQQIDAZBcmFnb24xETAPBgNVBAcMCFph\r"\
"cmFnb3phMTIwMAYDVQQKDClMaWJlbGl1bSBDb211bmljYWNpb25lcyBEaXN0cmli\r"\
"dWlkYXMgUy5MLjERMA8GA1UEAwwIbWVzaGxpdW0wggEiMA0GCSqGSIb3DQEBAQUA\r"\
"A4IBDwAwggEKAoIBAQDFPpzKyQ/tSTpZUv9fWHt9JfIXyDbc5nZnOclaNwTUN9qi\r"\
"ULWIQuPsZS7cCqVg/se8MPRGkIqTMs7QCxnJ9XYFfRvC7PYZlp56ecjmlunNZnzk\r"\
"QQ6Xy6s8HyRLE06GgXRbX3Gj2fc/6TmRRn6716Q0T3SdRHj1+gE4WE0765VxMnAB\r"\
"T3Gsp4fDkpnG/SuAF/GjsmqRU7hdF2QE0aIsKRm2sXxBrgk2t0K7enGAdcyYPijF\r"\
"CO096oMYYdpyVzd5hisEsmjWNVKhV8GlN0syDh6HPKfM2b2tPGB/59m714o1HazP\r"\
"1vmbuPz70sGRCPV52a0VcjG4gMZhpau/Ho8Or/Z1AgMBAAGjUDBOMB0GA1UdDgQW\r"\
"BBQgqRLAmoguG1biM7C2qOMz1+hlWjAfBgNVHSMEGDAWgBQgqRLAmoguG1biM7C2\r"\
"qOMz1+hlWjAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQC1psOYyNBy\r"\
"HqwLu75RGnWrqH5z0m7wp82cRuzQ9jovUIZpoaVKuM4QqOmhpLbHHVy6q36nzCwd\r"\
"yuqf/347El/Lfyw7jfPYZIQIgHX9TQKnAg6DMhqKDm8DDDRKWOE65QkOJmLBPwL0\r"\
"gxxlZXsWUMdvjcmmFzrTjxwl98jcTl34lZqHgTfOEkCcx0112Fgh5ldLxxLUCBT9\r"\
"4vcAQLfNRneNL6NxN1qAaDxs1WjB9KuBY2De2gBLojH5lOextOU+5wwxrmqSZwWp\r"\
"ZG9pnN4dRhrOeI31Pp320vec1dx1aDfvrfQAZWZLorgExeKcDj0aWCALuvra174h\r"\
"NqPiNZOqk/OF\r"\
"-----END CERTIFICATE-----";

wifi_error_t startWifiManager() {
    uint8_t ret = WIFI_PRO.ON(socket);
    if (ret) return WIFI_ON_FAIL;

    ret = WIFI_PRO.setESSID(ESSID);
    if (ret) return WIFI_SSID_FAIL;

    ret = WIFI_PRO.setPassword(WPA2, PASSW);
    if (ret) return WIFI_PASS_FAIL;

    ret = WIFI_PRO.softReset();
    if (ret) return WIFI_SOFTR_FAIL;

    ret = WIFI_PRO.setURL(type, host, port, url);
    if (ret) return WIFI_URL_FAIL;

    ret = WIFI_PRO.setContentType("application/json");
    if (ret) return WIFI_TYPE_FAIL;

    delay(100);
    
    return WIFI_OK;
}//wifiRun

void ERROR_CHECK(wifi_error_t error) {
    switch (error) {
        case WIFI_ON_FAIL :
            logE("WiFi ON error");
        break;

        case WIFI_SSID_FAIL :
            logE("WiFi SSID error");
        break;

        case WIFI_PASS_FAIL :
            logE("WiFi PASS error");
        break;

        case WIFI_SOFTR_FAIL :
            logE("WiFi softReset error");
        break;

        case WIFI_URL_FAIL :
            logE("WiFi URL error");
        break;

        case WIFI_TYPE_FAIL :
            logE("WiFi ContentType error");
        break;

        case WIFI_POST_FAIL :
            logE("WiFi POST error");
        break;

        default :
            logE("WiFi OK");
        break;
    }//switch (error)
}//ERROR_CHECK

void isConnected() {
    if (WIFI_PRO.isConnected()) {
        logE("WiFi Connection OK");
    } else {
        logE("WiFi Connection error");
    }//if (WIFI_PRO.isConnected())
}//isConnected

void wifiGetIp() {
    if (WIFI_PRO.getIP()) {
        logE("WiFi IP error");
    } else {
        log("WIFI IP: ");
        logE(WIFI_PRO._ip);
    }//if (WIFI_PRO.getIP()) 
}//wifiGetIp

wifi_error_t postData(char* payload) {
    return WIFI_OK;
}//advertiseData
