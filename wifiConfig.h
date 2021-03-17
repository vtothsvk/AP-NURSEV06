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
 * (for different format flags refer to https://www.lix.polytechnique.fr/~liberti/public/computing/prog/c/C/FUNCTIONS/format.html)
 * 
 * e.g.:
 * @code
 * uint8_t pir = 1;
 * char* payload = createPostPayload(PIR_FORMAT, pirValue);
 * @endcode
 * 
 * this fills the 'payload' with the following JSON string:
 *  {
 *      "PIR" : 1
 *  } 
 */
#define PIR_FORMAT "\
{\
    \"PIR\": %d\
}"

//feel free to create your HTTP POST payload formats (keep in mind, the payload has to be a JSON -> { "key1": value1, "key2": value2, ...} )
#define MY_FORMAT2 "..."
#define MY_FORMAT3 "..."


/**
 * @brief HTTP POST PREFIX format
 * 
 * Used to feed the HTTP POST payload the devices serial number, deviceID and the rest of the POST paload
 */
#define POST_PREFIX "{ \"SN\": \"%s\", \"ID\": \"%s\", \"data\": %s}"

#endif
