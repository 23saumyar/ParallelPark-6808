#include "ArduinoBLE.h"

BLEService ledService("713D0000-503E-4C75-BA94-3148F18D941D"); // BLE LED Service
 
// BLE LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEStringCharacteristic switchCharacteristic("713D0002-503E-4C75-BA94-3148F18D941E", BLERead | BLENotify, 20);

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
 
  // begin initialization:
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (true);
  }
 
  // set advertised local name and service UUID:
  BLE.setLocalName("back");
  BLE.setDeviceName("back");
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
  
  switchCharacteristic.writeValue("BD"+dist+"D");
  
  delay(500);      

}
