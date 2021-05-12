#include "ArduinoBLE.h"
#include <Adafruit_ICM20X.h>
#include <Adafruit_ICM20948.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

Adafruit_ICM20948 icm;
uint16_t measurement_delay_us = 65535; // Delay between measurements for testing
// For SPI mode, we need a CS pin
#define ICM_CS 10
// For software-SPI mode we need SCK/MOSI/MISO pins
#define ICM_SCK 13
#define ICM_MISO 12
#define ICM_MOSI 11

BLEService ledService("713D0000-503E-4C75-BA94-3148F18D941C"); // BLE LED Service
 
// BLE LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEStringCharacteristic switchCharacteristic("713D0002-503E-4C75-BA94-3148F18D941C", BLERead | BLENotify, 20);

#define TRIGGER_PIN   7
#define ECHO_PIN      8

int echoTime;             //time in us
float distance;           //distance in mms

void setup() {
  // initialize serial and wait for serial monitor to be opened:
  Serial.begin(9600);
  // while (!Serial);
 
  // set LED pin to output mode:
  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(TRIGGER_PIN, LOW);     //set trigger pin LOW - idle state

  // Try to initialize!
  if (!icm.begin_I2C()) {
    // if (!icm.begin_SPI(ICM_CS)) {
    // if (!icm.begin_SPI(ICM_CS, ICM_SCK, ICM_MISO, ICM_MOSI)) {

    Serial.println("Failed to find ICM20948 chip");
    while (1) {
      delay(10);
    }
  }
  
  // begin initialization:
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (true);
  }
 
  // set advertised local name and service UUID:
  BLE.setLocalName("side");
  BLE.setDeviceName("side");
  BLE.setAdvertisedService(ledService);
 
  // add the characteristic to the service
  ledService.addCharacteristic(switchCharacteristic);
 
  // add service:
  BLE.addService(ledService);
 
  // set the initial value for the characteristic:
  // switchCharacteristic.writeValue(0);
 
  // start advertising
  BLE.advertise();
 
  Serial.println("BLE LED Peripheral");
}

void loop() {
  // listen for BLE peripherals to connect:
  // BLEDevice central = BLE.central();

  BLE.poll();  

  digitalWrite(TRIGGER_PIN, HIGH);    //send trigger pulse
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN, LOW);

  echoTime = pulseIn(ECHO_PIN, HIGH); //capture the echo signal and determine duration of pulse when HIGH

  distance = (echoTime*0.034*10)/2;    //obtain distance (in mm), from time

  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" mm"); 
  
  String dist = String(distance, 2);
 
  sensors_event_t accel;
  sensors_event_t gyro;
  sensors_event_t mag;
  sensors_event_t temp;
  icm.getEvent(&accel, &gyro, &temp, &mag);

  String ax = String(accel.acceleration.x, 2);
  String ay = String(accel.acceleration.y, 2);
  String az = String(accel.acceleration.z, 2);

  String mx = String(mag.magnetic.x, 2);
  String my = String(mag.magnetic.y, 2);
  String mz = String(mag.magnetic.z, 2);

  String gx = String(gyro.gyro.x, 2);
  String gy = String(gyro.gyro.y, 2);
  String gz = String(gyro.gyro.z, 2);
  
  switchCharacteristic.writeValue("DD"+dist+"D");
  switchCharacteristic.writeValue("AX"+ax+"D");
  switchCharacteristic.writeValue("AY"+ay+"D");
  switchCharacteristic.writeValue("AZ"+az+"D");
  switchCharacteristic.writeValue("MX"+mx+"D");
  switchCharacteristic.writeValue("MY"+my+"D");
  switchCharacteristic.writeValue("MZ"+mz+"D");
  switchCharacteristic.writeValue("GX"+gx+"D");
  switchCharacteristic.writeValue("GY"+gy+"D");
  switchCharacteristic.writeValue("GZ"+gz+"D");
  
  delay(500);      

}
