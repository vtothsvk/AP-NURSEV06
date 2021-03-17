
/*  
  AP-NURSE-CARE-WASP-V05 16.02.2021
  POZOR! Pvalue natvrdo nastavena na =1
  Implementovane: Moznost citat senzory
                  Korektne pripojenie na WIFI
                  Poslanie HTTPS frame N01 nekryptovaneho na MESHLIUM 
                  Poslanie HTTPS frame N02 kryptovaneho AES128 16bit heslo na MESHLIUM (kontrola serial id dosky)
                  Frame rozdelene na 2 ks z dovododu maximalnej dlzky HTTP postu
  TO DO: Upratat kod podla aktualnych potrieb
         Najst spravny mod akcelerometra (je am moznost padu)
         Vykuchat procedury z kniznic tak, aby sme znizili pamatove naroky
         Skusit tam vpasovat TCP-IP server na jednoducje menenie tresholdov - Pista dostane za ulohu vykuchat kniznicu
  */
#include <string.h>
#include <WaspSensorEvent_v30.h>   
#include <WaspWIFI_PRO.h>
#include <WaspFrame.h>
#include <BME280.h>
#include <WaspAES.h>

char password[] = "libeliumlibelium"; 
int     Pvalue = 0;
int     Qvalue = 0;
float   temp = 0.0;
float   humd = 0.0;
int     pres = 0;
float   Apres = 0.0;
float  value = 12.0;
int    LPG = 0;
int    AirQ = 0;
float  FLPG = 0.0;
float  FAirQ = 0.0;
uint32_t luxes = 0;
float Vluxes = 2.0;
int     tlak = 0;
float  Ttlak = 0.0;
int aux = 0;
uint8_t valueID=1;
// parameters for MQ135 calibration
float RLoad = 10.0;
float A = 116.6020682;
float B = 2.769034857;
float Rzero = 156.00;
float VCC = 3.1;
float natCO2 = 404.39;
// parameters for MQ5 calibration
float LLoad = 10.0;
float Al = 5.66393139;
float Bl = 0.39942484;
float Lzero = 2.23272148;
float LCC = 3.1;

uint8_t socket = SOCKET0;
uint8_t error;
uint8_t status;
unsigned long previous;
unsigned long modulo;
unsigned long zvysok;
char body[] = "No movement";

char buffer[1024];

// WiFi AP settings 
//char ESSID[] = "fei-iot";
//char PASSW[] = "F+e-i.feb575";
//char ESSID[] = "meshlium6970";
//char PASSW[] = "alsnurse";
char ESSID[] = "Allegro-512";
char PASSW[] = "*youarita@35";

//  URL MESHLIUM HTTPS post (pri HTTP port 80)
//char type[] = "https";
char type[] = "http";
//char host[] = "10.10.10.1";
char host[] = "192.168.1.44";
//char port[] = "443";
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

// Identifikator nodu, prenasa sa do HTTPS postu
char moteID[] = "Test_sen";

void setup() 
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("Start program"));
 
 // Zapnutie akcelerometra - su rodzne mody, tento by mohol stacit
//  ACC.ON();
//   ACC.setMode(ACC_LOW_POWER_5);

// initialized WIFI 
  error = WIFI_PRO.ON(socket);
  if (error == 0)
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }

// connect to local AP - wifi priamo z MESHLIA
  error = WIFI_PRO.setESSID(ESSID);
  if (error == 0)
  {    
    USB.println(F("WiFi set ESSID OK"));
  }
  else
  {
    USB.println(F("WiFi set ESSID ERROR"));
  }

  error = WIFI_PRO.setPassword(WPA2, PASSW);
  if (error == 0)
  {    
    USB.println(F("WiFi set AUTHKEY OK"));
  }
  else
  {
    USB.println(F("WiFi set AUTHKEY ERROR"));
  }
  error = WIFI_PRO.softReset();
  if (error == 0)
  {    
    USB.println(F("WiFi softReset OK"));
  }
  else
  {
    USB.println(F("WiFi softReset ERROR"));
  }

  error = WIFI_PRO.setURL( type, host, port, url );

  // check response
  if (error == 0)
  {
    USB.println(F("2. setURL OK"));
  }
  else
  {
    USB.println(F("2. Error calling 'setURL' function"));
    WIFI_PRO.printErrorCode();
  }

  error = WIFI_PRO.setContentType("application/json");

  if(error){
    USB.println("content type set failed...");
  }

  /*
  //////////////////////////////////////////////////
  // Set Trusted CA
  //////////////////////////////////////////////////
  error = WIFI_PRO.setCA(TRUSTED_CA);

  if (error == 0)
  {
    USB.println(F("2. Trusted CA set OK"));
  }
  else
  {
    USB.println(F("2. Error calling 'setCA' function"));
    WIFI_PRO.printErrorCode();
  }*/

  delay(100);
  PWR.setSensorPower( SENS_5V, SENS_ON); 
//  PWR.setSensorPower(SENS_3V3, SENS_ON); 
  BME.ON();
//  BME.readCalibration();
//  BME.showCalibration();
//  PRINT_BME(F("BME280.Checking ID..."));
  I2C.begin();
  delay(100);
  I2C.read(I2C_ADDRESS_GASPRO_BME280, BME280_CHIP_ID_REG, &valueID, 1);
//  USB.printHex(BME280_CHIP_ID_REG_CHIP_ID);
//  USB.println();
//  USB.printHex(valueID);
//  USB.println();
//  USB.println(BME280_DEBUG);
//
// chceck if I2C is activated and communicate with BME
  if( BME280_CHIP_ID_REG_CHIP_ID == valueID )
  {
    USB.println(F("I2C for BME initialized correctly"));
  }
  else
  {
    PRINT_BME(F("BME280.Checking ID..."));
    USB.printHex(BME280_CHIP_ID_REG_CHIP_ID);
    USB.println();
    USB.printHex(valueID);
    USB.println();
  }
// aktivizovanie pinov pre jednotlive senzory
// analog2 tlakovy senzor
  pinMode(ANALOG2, INPUT);
// analog3 MQ135 air quality sensor
  pinMode(ANALOG3, INPUT);
// analog4 senzor hluku
  pinMode(ANALOG4, INPUT);
// analog6 MQ5 LPG sensor
  pinMode(ANALOG6, INPUT);
// analog7 light sensor
  pinMode(ANALOG7, INPUT);
// digital7 PIR sensor
  pinMode(DIGITAL7, INPUT);
// inicializacia plynovych senzorov a zhavenia
  analogWrite(ANALOG6, HIGH);
  analogWrite(ANALOG3, HIGH);
  //delay(60000);

// Check if module is connected
  if (WIFI_PRO.isConnected() == true)
  {    
    USB.println(F("WiFi is connected OK"));
  }
  else
  {
    USB.println(F("WiFi is connected ERROR"));  
  }
  // set the Waspmote ID
  frame.setID(moteID); 
  // Vypytaj si IP

    error = WIFI_PRO.getIP();

    if (error == 0)
    {    
      USB.print(F("IP address: "));
      USB.println(WIFI_PRO._ip);   
    }
    else
    {
      USB.println(F("getIP error"));
    }  
}


void loop() 
{

    
// Vypytak si Gateway (nie je treba)
/*
    error = WIFI_PRO.getGateway();

    if (error == 0)
    {    
      USB.print(F("GW address: "));    
      USB.println(WIFI_PRO._gw);
    }
    else
    {
      USB.println(F("getGateway error"));     
    }
*/

// Vypytaj si Netmask 
/*
    error = WIFI_PRO.getNetmask();

    if (error == 0)
    {    
//      USB.print(F("Netmask address: "));
//      USB.println(WIFI_PRO._netmask);
    }
    else
    {
      USB.println(F("getNetmask error"));
    }
*/
// Vypytaj si DNS (nie je treba)
/*
    error = WIFI_PRO.getDNS(1);

    if (error == 0)
    {    
      USB.print(F("DNS 1 address: "));
      USB.println(WIFI_PRO._dns1);
    }
    else
    {
      USB.println(F("getDNS error"));
    }
  */  
 
  ///////////////////////////////////////
  // 1. Read the sensor level
  ///////////////////////////////////////
  previous = millis();
  Pvalue = digitalRead(DIGITAL7);
  temp = BME.getTemperature(BME280_OVERSAMP_1X, 0);
  humd = BME.getHumidity(BME280_OVERSAMP_2X);
  Apres = BME.getPressure(BME280_OVERSAMP_2X, 0);
  luxes = analogRead(ANALOG7);
  tlak = analogRead(ANALOG2);
  aux = analogRead(ANALOG4);
  LPG = analogRead(ANALOG6);
  AirQ = analogRead(ANALOG3);

  ///////////////////////////////////////
  // 2. Convert the sensor level
  ///////////////////////////////////////

// LDR vystup na intenzitu [%]
  Vluxes = (luxes / 1023.0) * 100;

// Tlak na hmotnost [kg]
  Ttlak = (tlak / 1023.0) * 10;
// Ttlak = (tlak + 50.0) / 100 * 10000;

// LPG na intenzitu [%] (nie je overeny rozsah vystupneho napatia)
//  FLPG = (LPG / 1023.0) * 100;
// LPG na abs. hodnotu [ppm]
// parametre ziskane z kalibracnej krivky a Lzero odhad pre 0.01ppm na zaklade pomeru
  FLPG = Al * pow((((1023.0 / LPG) * LCC - 1.0) * LLoad)/Lzero, -Bl);
//  USB.printFloat(FLPG, 2);
//  USB.println(F(" ppm"));

// Airquality na intenzitu [%] (nie je overeny rozsah vystupneho napatia)
//  FAirQ = (AirQ / 1023.0) * 100;
// AirQ na abs. hodnotu [ppm] odhad koncentracie CO2 na zaklade prirodzeneho obsahu v atmosfere 404.39 ppm
// Pri zmene akehokolvek parametra v rovnici, treba znova urcit Rzero (VCC, Rload, natCO2, A, B)
//  Rzero = (((1023.0 / AirQ) * VCC - 1.0) * RLoad) * pow(natCO2/A, (1.0/B));
// POZOR !!!!! PIR ovplyvnuje VCC, treba pockat kym sa ustali
  FAirQ = A * pow((((1023.0 / AirQ) * VCC - 1.0) * RLoad)/Rzero, -B);
//  USB.printFloat(FAirQ, 2);
//  USB.println(F(" ppm"));
  ///////////////////////////////////////
  // 3. Compare threshold
  ///////////////////////////////////////

  if (Pvalue == 1) 
  {
    if (WIFI_PRO.isConnected() == true)
    {    
      USB.println(F("WiFi is connected OK"));
    }
    else
    {
      USB.println(F("WiFi is connected ERROR"));  
    }
    char body[] = "Movement detected";
    frame.createFrame(ASCII);
    frame.addSensor(SENSOR_EVENTS_PIR, Pvalue); 
    frame.addSensor(SENSOR_STR, body);
    USB.println(F("2. Encrypting Frame"));   
    //frame.encryptFrame( AES_128, password );
    frame.showFrame();  
    delay(100);

    /*
     frame.addSensor(SENSOR_GASES_CO2, FAirQ);
    frame.addSensor(SENSOR_GASES_LPG, FLPG);
    frame.addSensor(SENSOR_AMBIENT_LUM, Vluxes);
    frame.addSensor(SENSOR_EVENTS_WF, Ttlak);
     */
    char l_s[20];
    Utils.float2String(Vluxes, l_s, 2);
    sprintf(&buffer[0], "{\
    \"Light\": %s,\
    \"Pir\": %d\
    }", l_s, Pvalue);
    USB.println(buffer);
    error = WIFI_PRO.post(buffer); 
    if (error == 0)
    {
      USB.print(F("3.1. HTTP POST OK. "));
      USB.print(F("HTTP Time from OFF state (ms):"));
      USB.println(millis()-previous);
      
      USB.print(F("\nServer answer:"));
      USB.println(WIFI_PRO._buffer, WIFI_PRO._length);
    }
    else
    {
      USB.println(F("3.1. Error calling 'post' function"));
      WIFI_PRO.printErrorCode();
    }


//    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);


      ///////////////////////////////////////
      // Print sensor Values to usb
      ///////////////////////////////////////
      USB.println("-----------------------------");
      USB.print("Temperature: ");
      USB.printFloat(temp, 2);
      USB.println(F(" Celsius"));
      USB.print("Humidity: ");
      USB.printFloat(humd, 1); 
      USB.println(F(" %")); 
      USB.print("Pressure: ");
      USB.printFloat(Apres, 2); 
      USB.println(F(" Pa")); 
      USB.print(F("Light: "));
      USB.printFloat(Vluxes, 2);
      USB.println(F(" %"));
      USB.print(F("Tlak: "));
      USB.printFloat(Ttlak, 2);
      USB.println(F(" kg"));
      USB.print(F("Hluk: "));
      USB.print(aux);
      USB.println(F(" hlk"));
      USB.print(F("LPG: "));
      USB.printFloat(FLPG, 2);
      USB.println(F(" %"));
      USB.print(F("Air Quality: "));
      USB.printFloat(FAirQ, 2);
      USB.println(F(" ppm"));
      USB.println("-----------------------------");
//      USB.printFloat(value, 2);
//      delay(1000);
  } 
  else 
  {
    USB.println(F("Sensor output: Presence not detected"));
    char body[] = "No movement";
  }

  ///////////////////////////////////////
  // 4. Prepare frame N01 or message
  ///////////////////////////////////////
  modulo=previous / 30000;
  zvysok=(previous - (modulo * 30000)) / 1000;
//  delay(5000);
//  USB.println(modulo);
//  USB.println(zvysok);
//  USB.println(previous);
  if (zvysok < 1 )
  {
    previous = millis();
    frame.createFrame(ASCII);
    frame.addSensor(SENSOR_GASES_CO2, FAirQ);
    frame.addSensor(SENSOR_GASES_LPG, FLPG);
    frame.addSensor(SENSOR_AMBIENT_LUM, Vluxes);
    frame.addSensor(SENSOR_EVENTS_WF, Ttlak);
//    frame.addSensor(SENSOR_CITIES_PRO_US, aux);
//    frame.addSensor(SENSOR_ACC, ACC.getX(),ACC.getY(),ACC.getZ());
    frame.showFrame();  

    ///////////////////////////////////////
    // 5. Skontroluj WiFi a posli frame N01
    ///////////////////////////////////////

// test internet connection for general AP
    if (WIFI_PRO.isConnected() == true)
    {    
      USB.println(F("WiFi is connected OK"));
    }
    else
    {
      USB.println(F("WiFi is connected ERROR"));  
    }

    //  Send Frame to Meshlium
    USB.println(F("2. Encrypting Frame"));   
    frame.encryptFrame( AES_128, password );
    frame.showFrame();  
    delay(100);
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
   
    ///////////////////////////////////////
    // 6. Prepare frame N02 or message
    ///////////////////////////////////////

    frame.createFrame(ASCII);
    frame.addSensor(SENSOR_EVENTS_PIR, Pvalue);
    frame.addSensor(SENSOR_GASES_TC, temp);
    frame.addSensor(SENSOR_GASES_HUM, humd);
    frame.addSensor(SENSOR_GASES_PRES, Apres);
//    frame.addSensor(SENSOR_STR, body);
    frame.showFrame();  

    ////////////////////////////////////////////////
    // Encrypt Waspmote Frame
    ////////////////////////////////////////////////  
    USB.println(F("2. Encrypting Frame"));   
    frame.encryptFrame( AES_128, password );
    frame.showFrame();

    ///////////////////////////////////////
    // 7. Posli kryptovany frame N02
    ///////////////////////////////////////

    delay(100); // Musi byt inak je nespolahlivy

//  Send Frame to Meshlium
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);

    USB.println(millis()-previous);
    // check response
    if (error == 0)
    {
      USB.println(F("HTTP2 OK"));          
      USB.print(F("HTTP2 Time from OFF state (ms):"));    
   //   USB.println(millis()-previous);
    }
    else
    {
      USB.println(F("Error HTTP2 send"));
      WIFI_PRO.printErrorCode();
    }
    PWR.setSensorPower( SENS_5V, SENS_ON); 
    BME.ON();
    I2C.begin();
  }
 
}

