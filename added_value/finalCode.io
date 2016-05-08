#include "SevSeg.h"
SevSeg sevseg;
// *******************************
// Cameron Fisher
// Yamuna Rajasekhar
// ECE 387
// May 8 2015
// ********************************

const int buttonPin = A5;
const int infraredPin = A0;
const int xpin = A1; // x-axis of the accelerometer
const int ypin = A2; // y-axis
const int zpin = A3; //z-axis
const int ledPin = A4;

const int numReadings = 10;
const int numReadings2 = 10;

int readings[numReadings2];      // the readings from the analog input
int readIndex = 0;              // the index of the current reading
float total = 0;                  // the running total
float average = 0;                // the average

float zero_G = 512.0; //ADC is 0~1023 the zero g output equal to Vs/2
float scale = 102.3; //ADXL335330 Sensitivity is 330mv/g

int IRReadings [numReadings];      // the IRReadings from the analog input
int IRReadIndex = 0;              // the index of the current reading
float IRTotal = 0;                  // the running IRTotal
float IRAverage = 0;                // the average
float dist = 0;

float angle1;
float angle2;
float dist1;
float dist2;
int height;

int button;
int buttonTime;

int infraredRead = 0;

boolean firstRead = false;
boolean buttonReleased = false;
boolean buttonReleased2 = false;
boolean secondRead = false;
boolean pointMode = true;
boolean counting = false;

void setup() {
  // set up SevSeg library
  byte numDigits = 4;
  byte digitPins[] = {13, 12, 11, 10};
  byte segmentPins[] = {2, 3, 4, 5, 6, 7, 8, 9};

  sevseg.begin(COMMON_CATHODE, numDigits, digitPins, segmentPins);
  Serial.begin(9600);

  for (int thisReading = 0; thisReading < numReadings2; thisReading++) {
    readings[thisReading] = 0;
  }
  for (int n = 0; n < numReadings; n++) {
    IRReadings[n] = 0;
  }

}

void loop() {
  // Logic for overall application ****************************************************************
  button = digitalRead(buttonPin); // read in button state
    Serial.println(dist1);
    
    
    // Choose mode 1 or 2
    if (button && !counting) {
      buttonTime = millis();
      counting = true;
    } else if (button && millis() - buttonTime > 3000 ) {
      pointMode = !pointMode;
      counting = false;
    } 
    if (!button) {
     counting = false;
    } 
      
  // collect first measurments
  if (button && !firstRead) {
    dist1 = dist + 69.0;
    angle1 = average;
    firstRead = true;
//    Serial.println(angle1);
//    Serial.println(dist1);
  }
  if (!button && firstRead) {
    buttonReleased = true;
  }
  // collect second measurments
  if (button && buttonReleased && !secondRead) {
    dist2 = dist + 69.0;
    angle2 = average;
    secondRead = true;
//    Serial.println(angle2);
//    Serial.println(dist2);

  }
  if (!button && secondRead) {
      firstRead = false;
      buttonReleased = false;
      secondRead = false;
    }
    // 2-point measurment
    if (pointMode) {
     height = (sqrt(pow(dist2, 2) + pow(dist1, 2) - (2.0 * dist2 * 
     dist1 * cos(abs(angle2 - angle1) *PI/180.0))));
    }
    // real-time measuring
    else {
      height = (sqrt(pow(dist + 69.0, 2) + pow(dist1, 2) - (2.0 * (dist + 69.0) * 
     dist1 * cos(abs(average - angle1) *PI/180.0))));
    }

  sevseg.setNumber((int) height, 0);
  sevseg.refreshDisplay();
  
    if (dist > 200) {
    digitalWrite(ledPin,HIGH);
  } else {
    digitalWrite(ledPin,LOW);
  }
  
  // Code for reading angle from accelerometer *******************************************

  // read in accelerometer voltages and convert to g's
  int x = -(((float) analogRead(xpin) - 331.5) / 65 * 9.8); //read from xpin
  delay(1);
  int y = -(((float) analogRead(ypin) - 329.5) / 68.5 * 9.8); //read ypin
  delay(1);
  int z = -(((float) analogRead(zpin) - 340) / 68 * 9.8); //read zpin
  delay(1);

  // convert g's to pitch angle
  float pitch = atan(x / sqrt(pow(y, 2) + pow(z, 2)));
  pitch = pitch * (180.0 / PI);

  // Smoothing
  total = total - readings[readIndex];
  readings[readIndex] = pitch;
  total = total + readings[readIndex];
  readIndex = readIndex + 1;

  if (readIndex >= numReadings2) {
    readIndex = 0;
  }
  average = total / numReadings2;
  
  // Code for reading distance **************************************

  infraredRead = analogRead(infraredPin);
  delay(1);

  // subtract the last reading:
  IRTotal = IRTotal - IRReadings[IRReadIndex];
  // read from the sensor:
  IRReadings[IRReadIndex] = infraredRead;
  // add the reading to the IRTotal:
  IRTotal = IRTotal + IRReadings[IRReadIndex];
  IRReadIndex++;

  // reset index when end is reached
  if (IRReadIndex >= numReadings) {
    IRReadIndex = 0;
  }

  // calculate the average:
  IRAverage = IRTotal / numReadings;

  // calculate the distance from 5th degree polynomial equation
  dist = (int) (-0.0000000000499644004577343 * pow(IRAverage, 5) +
                0.0000000883929170684851 * pow(IRAverage, 4) -
                0.0000616233272648481 * pow(IRAverage, 3) +
                0.0214014628902673 * pow(IRAverage, 2) - 3.86975356164851 *
                IRAverage + 342.929478720489);


}
//int getDistance() {
//
//
//
//
//  }
//  return dist;
//}
//int getAngle() {
//
//
//
//  for (int i = 0; i < 25; i++) {
//
//    return average;
//  }
