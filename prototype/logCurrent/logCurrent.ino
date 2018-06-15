#include <SPI.h>
#include <SD.h>

const int chipSelect = 4;

float sensorValue[4];        // value read from the pot
// A0: ACS7812 Sensor, A1-A4: USB voltage inputs, A5: Raspberry Pi voltage input
float sensorPin[4] = {A1, A2, A3, A4};
int num = 100;

void setup() {
  Serial.begin(115200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  Serial.print("Initializing SD card...");

  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    // don't do anything more:
    return;
  }
  Serial.println("card initialized.");

  //we are using Adafruit Adalogger M0 wirh a SAM D21 board.
  //It has a ADC resolution of 12 bits. Use the highest available resolution
  analogReadResolution(12);
}

void loop() {
  // make a string for assembling the data to log:
  String dataString = "";

  getData(dataString);

  // open the file. note that only one file can be open at a time,
  // so you have to close this one before opening another.
  File dataFile = SD.open("datalog.txt", FILE_WRITE);

  // if the file is available, write to it:
  if (dataFile) {
    dataFile.println(dataString);
    dataFile.close();
    // print to the serial port too:
    Serial.println(dataString);
  }
  // if the file isn't open, pop up an error:
  else {
    Serial.println("error opening datalog.txt");
  }
}

// changes dataString to have data in the following format:
// num1, num2, num3, num4, num5
// num1: time elapsed in milli seconds 
// num2-num5: current through corresponding USB port in milliAmps

void getData(String &dataString) {
  dataString = String(millis());
  dataString += ", ";

  // zero all readings
  for (int i = 0; i < 4; i++) {
    sensorValue[i] = 0;
  }

  // read and average analog inputs
  for (int j = 0; j < num; j++) {
    for (int i = 0; i<4; i++) {
      sensorValue[i] += analogRead(sensorPin[i]) * 3300 / 4096;
      //wait for ADC to stabilise
      delay(2);
    }
  }
  for (int i = 0; i < 4; i++) {
    sensorValue[i] /= num;
  }

  // add data to string
  for (int i = 0; i < 3; i++) {
      dataString += String(sensorValue[i]);
      dataString += ", ";
  }
  dataString += String(sensorValue[3]);
  
  //  Serial.println(dataString);
}
