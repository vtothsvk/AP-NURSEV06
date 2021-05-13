#include "waspmote.h"

char moteID[] = "Test_sen";
char password[] = "libeliumlibelium"; 
int     Pvalue = 1;
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
float VCC = 4.7;
float natCO2 = 404.39;
// parameters for MQ5 calibration
float LLoad = 10.0;
float Al = 5.66393139;
float Bl = 0.39942484;
float Lzero = 2.23272148;
float LCC = 4.7;

uint8_t error;
uint8_t status;
unsigned long previous;
unsigned long modulo;
unsigned long zvysok;
char body[] = "No movement";

void initSensors() {
    PWR.setSensorPower( SENS_5V, SENS_ON); 
    BME.ON();
    I2C.begin();
    delay(100);
    I2C.read(I2C_ADDRESS_GASPRO_BME280, BME280_CHIP_ID_REG, &valueID, 1);

    if (BME280_CHIP_ID_REG_CHIP_ID == valueID) {
        logE("I2C for BME initialized correctly");
    } else {
        PRINT_BME(F("BME280.Checking ID..."));
        USB.printHex(BME280_CHIP_ID_REG_CHIP_ID);
        USB.println();
        USB.printHex(valueID);
        USB.println();
    }//if (BME280_CHIP_ID_REG_CHIP_ID == valueID) 

    // aktivizovanie pinov pre jednotlive senzory
    pinMode(ANALOG2, INPUT);// analog2 tlakovy senzor
    pinMode(ANALOG3, INPUT);// analog3 MQ135 air quality sensor
    pinMode(ANALOG4, INPUT);// analog4 senzor hluku
    pinMode(ANALOG6, INPUT);// analog6 MQ5 LPG sensor
    pinMode(ANALOG7, INPUT);// analog7 light sensor
    pinMode(DIGITAL7, INPUT);// digital7 PIR sensor

    //inicializacia plynovych senzorov a zhavenia
    analogWrite(ANALOG6, HIGH);
    analogWrite(ANALOG3, HIGH);
    
    //Check WiFi connection
    isConnected();

    frame.setID(moteID);

    //Check WiFi IP
    wifiGetIp();
    // enable interruptions
    enableInterrupts(PLV_INT);
    RTC.ON();
}//initSensors

void waspmoteLoop() {

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
    //aux = analogRead(ANALOG4);
    LPG = analogRead(ANALOG6);
    AirQ = analogRead(ANALOG3);
    float Blevel = PWR.getBatteryLevel();

    ///////////////////////////////////////
    // 2. Convert the sensor level
    ///////////////////////////////////////

    // LDR vystup na intenzitu [%]
    Vluxes = (luxes / 1023.0) * 100;

    // Tlak na hmotnost [kg]
    Ttlak = (tlak / 1023.0) * 10;
    // Ttlak = (tlak + 50.0) / 100 * 10000;

    // LPG na intenzitu [%] (nie je overeny rozsah vystupneho napatia)
    // FLPG = (LPG / 1023.0) * 100;
    // LPG na abs. hodnotu [ppm]
    // parametre ziskane z kalibracnej krivky a Lzero odhad pre 0.01ppm na zaklade pomeru
    FLPG = Al * pow((((1023.0 / LPG) * LCC - 1.0) * LLoad)/Lzero, -Bl);
    // disableInterrupts(PLV_INT);
    // USB.printFloat(FLPG, 2);
    // USB.println(F(" ppm"));
    // enableInterrupts(PLV_INT);

    // Airquality na intenzitu [%] (nie je overeny rozsah vystupneho napatia)
    // FAirQ = (AirQ / 1023.0) * 100;
    // AirQ na abs. hodnotu [ppm] odhad koncentracie CO2 na zaklade prirodzeneho obsahu v atmosfere 404.39 ppm
    // Pri zmene akehokolvek parametra v rovnici, treba znova urcit Rzero (VCC, Rload, natCO2, A, B)
    // Rzero = (((1023.0 / AirQ) * VCC - 1.0) * RLoad) * pow(natCO2/A, (1.0/B));
    // POZOR !!!!! PIR ovplyvnuje VCC, treba pockat kym sa ustali
    FAirQ = A * pow((((1023.0 / AirQ) * VCC - 1.0) * RLoad)/Rzero, -B);
    // disableInterrupts(PLV_INT);
    // USB.printFloat(FAirQ, 2);
    // USB.println(F(" ppm"));
    // enableInterrupts(PLV_INT);

    ///////////////////////////////////////
    // 3. Compare threshold
    ///////////////////////////////////////

    if (Pvalue == 1) {        
//        char body[] = "Movement detected";
//        frame.createFrame(ASCII);
//        frame.addSensor(SENSOR_EVENTS_PIR, Pvalue); 
//        frame.addSensor(SENSOR_STR, body);
//        USB.println(F("2. Encrypting Frame"));   
//        frame.encryptFrame( AES_128, password );
//        frame.showFrame();  
        delay(100);

        /**
         * Example ako posielat data cez HTTP POST
         * Pre dokumentaciu jednotlivych funkcii a makier vid 'wifiConfig.h' a 'wifiManager.h'
         * 
         * 1. Pomocou 'createPostPayload' sa vytvori string, ktory cheme poslat 
         * 2. Dany string sa postne pomocou 'postData' ( ERROR_CHECK() je len debug vypis)
         */
        createPostPayload(PIR_FORMAT, Pvalue, Bat_FORMAT, Blevel);
        disableInterrupts(PLV_INT);
        enableInterrupts(PLV_INT);
        ERROR_CHECK(
            postData()
        );

        disableInterrupts(PLV_INT);
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
        USB.print(F("Battery level: "));
        USB.printFloat(Blevel, 2);
        USB.println(F(" %"));
        USB.println("-----------------------------");
        enableInterrupts(PLV_INT);
    // USB.printFloat(value, 2);
    // delay(1000);
    } else {
        disableInterrupts(PLV_INT);
        USB.println(F("Sensor output: Presence not detected"));
        char body[] = "No movement";
        enableInterrupts(PLV_INT);
    }//if (Pvalue == 1)

    ///////////////////////////////////////
    // 4. Prepare frame N01 or message
    ///////////////////////////////////////
    modulo=previous / 30000;
    zvysok=(previous - (modulo * 30000)) / 1000;
    //  delay(5000);
    //  USB.println(modulo);
    //  USB.println(zvysok);
    USB.println(previous);

    if (zvysok < 1 ) {
        previous = millis();
        frame.createFrame(ASCII);
        frame.addSensor(SENSOR_GASES_CO2, FAirQ);
        frame.addSensor(SENSOR_GASES_LPG, FLPG);
        frame.addSensor(SENSOR_AMBIENT_LUM, Vluxes);
        frame.addSensor(SENSOR_EVENTS_WF, Ttlak);
        // frame.addSensor(SENSOR_CITIES_PRO_US, aux);
        // frame.addSensor(SENSOR_ACC, ACC.getX(),ACC.getY(),ACC.getZ());
        //frame.showFrame();

        // sprava HTTP na premostovaci server
        
        /* vytvaras payloady ale neposielas data, po kazdom vytvoreni payloadu treba data odoslat, aby sa buffer uvolnil
        a mohol si vytvorit dalsi payload
        createPostPayload(AirQ_FORMAT, FAirQ);
        createPostPayload(LPG_FORMAT, FLPG);
        createPostPayload(LUX_FORMAT, Vluxes);
        createPostPayload(Tlak_FORMAT, Ttlak);
        

        disableInterrupts(PLV_INT);
        checkPayload();
        enableInterrupts(PLV_INT);  
        */

        ///////////////////////////////////////
        // 5. Skontroluj WiFi a posli frame N01
        ///////////////////////////////////////

        // test internet connection for general AP
        isConnected();

        //  Send Frame to Meshlium
        //USB.println(F("2. Encrypting Frame"));   
        //frame.encryptFrame( AES_128, password );
        //frame.showFrame();  
        delay(100);
        //error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
    
        ///////////////////////////////////////
        // 6. Prepare frame N02 or message
        ///////////////////////////////////////

        frame.createFrame(ASCII);
        frame.addSensor(SENSOR_EVENTS_PIR, Pvalue);
        frame.addSensor(SENSOR_GASES_TC, temp);
        frame.addSensor(SENSOR_GASES_HUM, humd);
        frame.addSensor(SENSOR_GASES_PRES, Apres);

        ///////////////////////////////////////
        // 7. Posli kryptovany frame N02
        ///////////////////////////////////////

        delay(100); // Musi byt inak je nespolahlivy

        // sprava HTTP na premostovaci server
        
        /* rovnaky problem
        createPostPayload(Bat_FORMAT, Blevel);
        createPostPayload(TEMP_FORMAT, temp);
        createPostPayload(HMD_FORMAT, humd);
        createPostPayload(PRESS_FORMAT, Apres);

        ERROR_CHECK(
            postData(payload)
        );

        disableInterrupts(PLV_INT);
        checkPayload();
        enableInterrupts(PLV_INT);
        */

        if ( intFlag & PLV_INT )
        {
            Pvalue = 1;
            disableInterrupts(PLV_INT);
            createPostPayload(PIR_FORMAT, Pvalue);
            disableInterrupts(PLV_INT);
            checkPayload();
            enableInterrupts(PLV_INT);
            ERROR_CHECK(
            postData()
            );
            clearIntFlag();
            PWR.clearInterruptionPin();
            enableInterrupts(PLV_INT);
    
         }

        PWR.setSensorPower( SENS_5V, SENS_ON); 
        BME.ON();
        I2C.begin();
    }//if (zvysok < 1)
}//waspmoteLoop

void initSerialPort() {
    USB.ON();
    logE("Start program");
}//initSerialPort
