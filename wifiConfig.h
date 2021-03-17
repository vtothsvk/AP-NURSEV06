#ifndef WIFI_CONFIG_H_
#define WIFI_CONFIG_H_

/**
 * @brief WiFi configuration
 * 
 * Change the following parameters to suite your network and target host
 */
#define WIFI_SSID   "Allegro-512"
#define WIFI_PASS   "*youarita@35"

#define WIFI_TYPE   "http"
#define WIFI_HOST   "raspberrypi.local"
#define WIFI_PORT   "1880"
#define WIFI_URL    "waspmote"

/**
 * @brief HTTP POST payload formats
 * 
 * Defines a JSON with the key "PIR" and with a %d flag as its value
 * This allows to pass it an integer value to create a formatted string using the 'createPostPayload' function
 * 
 * e.g.:
 * @code
 * uint8_t pir = 1;
 * char* payload = createPostPayload(PIR_FORMAT, pirValue);
 * @endcode
 * 
 * this creates fills the 'payload' with the following JSON string:
 *  {
 *      "PIR" : 1
 *  } 
 */
#define PIR_FORMAT"\
{\
    \"PIR\": %d\
}"

#endif
