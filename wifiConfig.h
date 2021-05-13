#ifndef WIFI_CONFIG_H_
#define WIFI_CONFIG_H_

/**
 * @brief WiFi configuration
 * 
 * Change the following parameters to suite your network and target host
 */
#define WIFI_SSID   "nicelife"
#define WIFI_PASS   "#nicelife"

#define WIFI_TYPE   "http"
#define WIFI_HOST   "192.168.2.7"
#define WIFI_PORT   "1880"
#define WIFI_URL    "waspmote"

#define DATA_BUFFER_LEN     150
#define REQUEST_BUFFER_LEN  256

/**
 * @brief HTTP POST payload formats
 * 
 * Defines a JSON with the key "PIR" and with a %d flag as its value
 * This allows to pass it an integer value to create a formatted string using the 'createPostPayload' function
 * (for different format flags refer to https://www.lix.polytechnique.fr/~liberti/public/computing/prog/c/C/FUNCTIONS/format.html)
 * 
 * e.g.:
 * @code
 * uint8_t pirValue = 1;
 * char* payload = createPostPayload(PIR_FORMAT, pirValue);
 * @endcode
 * 
 * this example fills the 'payload' with the following JSON string:
 *  {
 *      "PIR" : 1
 *  } 
 */
#define PIR_FORMAT "{ \"PIR\": %d}"
//#define AirQ_FORMAT "{ \"FAirQ\": %.2f}"
//#define LPG_FORMAT "{ \"FLPG\": %.2f}"
//#define LUX_FORMAT "{ \"Vluxes\": %.2f}"
//#define Tlak_FORMAT "{ \"Ttlak\": %.2f}"
//#define TEMP_FORMAT "{ \"temp\": %.2f}"
//#define HMD_FORMAT "{ \"humd\": %.2f}"
//#define PRESS_FORMAT "{ \"Apres\": %.2f}"
#define FALL_FORMAT "{ \"FALL\": %d}"
#define Bat_FORMAT "{ \"Blevel\": %d}"

//feel free to create your HTTP POST payload formats the existing (keep in mind, the payload has to be a JSON -> { "key1": value1, "key2": value2, ...} )  
#define MESSAGE_01 "{ \"FAirQ\": %s, \"FLPG\": %s, \"Vluxes\": %s}"
#define MESSAGE_02 "{ \"Blevel\": %d, \"Ttlak\": %.2f }"
#define MESSAGE_03 "{  \"temp\": %.2f, \"humd\": %.2f, \"Apres\": %.2f }"
#define MESSAGE_04 "{ \"Pvalue\": %d, \"Blevel\": %d }"


/**
 * @brief HTTP POST PREFIX format
 * 
 * Used to feed the HTTP POST payload the devices serial number, deviceID and the rest of the POST paload
 */
#define POST_PREFIX "{ \"SN\": \"%s\", \"kid\": \"%s\", \"devId\": \"%s\", \"data\": %s}"

#endif//WIFI_CONFIG_H_
