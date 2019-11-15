/******************************************************************************
 * Copyright 2018 Google
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************/
#include "esp32-mqtt.h"
#include <cmath>
#include <string>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID "37f64eb3-c25f-449b-ba34-a5f5387fdb6d"
#define SERVICE_POS_UUID "b6404248-0be4-4c71-930c-9cd697e0919a"
#define CHARACTERISTIC_UUID "560d029d-57a1-4ccc-8868-9e4b4ef41da6"
#define CONNECTED_CHAR "13b5c4de-89af-4231-8ec3-b9fe596c10ea"
#define LAT_CHAR "6c3a0710-c5c7-445b-9a54-c73ef8f1a9d8"
#define LNG_CHAR "43ea571c-bd20-4593-aa2c-b1298780b778"
#define RECEIVER "e012c323-3e07-4a41-acdd-2bd9cc2c4ffa"

#define RED_LED 17
#define YELLOW_LED 18
#define GREEN_LED 21

#define RED_CH 0
#define YELLOW_CH 1
#define GREEN_CH 2


BLECharacteristic *connectionNotifier;
BLECharacteristic *lngChar;
BLECharacteristic *latChar;
BLECharacteristic *receiveChar;
/* 
std::string ssid;
std::string password;
*/
int lastUsed = RED_CH;
bool isOn = false;
std::string lat;
std::string lng;

bool passwordChanged;
bool ssidChanged;
bool bleConnected = false;
bool latChanged = false;
bool lngChanged = false;

bool hasWifi;
bool blinking = false;
bool wasBlinking = false;

//void wifiSetup();
//void InitWifi();
void btSetup();

class MyCallbacks : public BLECharacteristicCallbacks
{
  
  void onWrite(BLECharacteristic *pCharacteristic)
  { //lat
    std::string value = pCharacteristic->getValue();
    std::string a = &(value[1]);
    /* 
    if (value[0] == 'P')
    {
      password = a;
      passwordChanged = true;
    }
    else if (value[0] == 'S')
    {
      ssid = a;
      ssidChanged = true;
    }
    */
    
  }
};

class PosCallbacks : public BLECharacteristicCallbacks
{
  void onWrite(BLECharacteristic *pCharacteristic)
  { //lat
    std::string value = pCharacteristic->getValue();
    Serial.println(value.c_str());
    std::string a = &(value[1]);
    if (value[0] == '0')
    {
      lat = a;
      latChanged = true;
    } else if (value[0] == '1')
    {
      lng = a;
      lngChanged = true;
    }else if (value[0] == 'O'){
      if(value[1] == 'F'){
        ledcWrite(RED_CH, 0);
        ledcWrite(YELLOW_CH, 0);
        ledcWrite(GREEN_CH, 0);
        isOn = false;
        if (blinking){
          wasBlinking = true;
          blinking = false;
        }
      }else if (value[1] == 'N'){
        ledcWrite(lastUsed, 255);
        if (wasBlinking){
          blinking = true;
          wasBlinking = false;
        }
        isOn = true;
      }
    }else if (value[0] == 'C'){
      if (value[1] == 'R'){
        if(isOn){
          ledcWrite(RED_CH, 255);
          ledcWrite(YELLOW_CH, 0);
          ledcWrite(GREEN_CH, 0);
        }
        lastUsed = RED_CH;
      } else if (value[1] == 'G'){
        if(isOn){
          ledcWrite(RED_CH, 0);
          ledcWrite(YELLOW_CH, 0);
          ledcWrite(GREEN_CH, 255);
        }
        lastUsed = GREEN_CH;
      } else if (value[1] == 'Y'){
        if(isOn){
          ledcWrite(RED_CH, 0);
          ledcWrite(YELLOW_CH, 255);
          ledcWrite(GREEN_CH, 0);
        }
        lastUsed = YELLOW_CH;
      }
    }else if(value[0] == 'B'){
      if (value[1] == 'N'){
        if (!isOn && !wasBlinking){
          wasBlinking = true;
        } else if (isOn){
          blinking = true;
        }
      } else if (value[1] == 'F'){
        blinking = false;
        if (wasBlinking){
          wasBlinking = false;
        }
      }
    }
  }
};

void ledSetup(){
  ledcSetup(RED_CH, 5000, 8);
  ledcSetup(YELLOW_CH, 5000, 8);
  ledcSetup(GREEN_CH, 5000, 8);
  ledcAttachPin(RED_LED, RED_CH);
  ledcAttachPin(YELLOW_LED, YELLOW_CH);
  ledcAttachPin(GREEN_LED, GREEN_CH);
}

void btSetup()
{
  Serial.println("init BLE");
  BLEDevice::init("ESP32_DogLed");
  BLEServer *pServer = BLEDevice::createServer();

  BLEService *pService = pServer->createService(SERVICE_UUID);

  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID,
      BLECharacteristic::PROPERTY_WRITE);
  connectionNotifier = pService->createCharacteristic(
      CONNECTED_CHAR,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY);

  latChar = pService->createCharacteristic(
      LAT_CHAR,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY);

  lngChar = pService->createCharacteristic(
      LNG_CHAR,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY);

  receiveChar = pService->createCharacteristic(
      RECEIVER,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY);
  pCharacteristic->setCallbacks(new PosCallbacks());
  pService->start();
  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  pAdvertising->start();
  lat = "-19.885121";
  lng = "-44.418271";
  passwordChanged = false;
  ssidChanged = false;
  bleConnected = true;
  return;
}
/* 
void sendLatLng()
{
  latChar->setValue(lat);
  latChar->notify();
  delay(50);
  lngChar->setValue(lng);
  lngChar->notify();
}
*/
/*
void InitWifi()
{
  Serial.println(ssid.c_str());
  Serial.println(password.c_str());
  if (hasWifi)
  {
    WiFi.disconnect();
    digitalWrite(LED_BUILTIN, LOW);
    hasWifi = false;
  }

  WiFi.begin(ssid.c_str(), password.c_str());
  int i = 0;
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    i++;
    if (i > 30)
      break;
  }
  digitalWrite(LED_BUILTIN, LOW);
  if (WiFi.status() == WL_CONNECTED)
  {
    hasWifi = true;
    digitalWrite(LED_BUILTIN, HIGH);
  }
  else
  {
    Serial.println("não foi possível se conectar à rede! ssid ou senha estão errados");
  }
  passwordChanged = false;
  ssidChanged = false;
}

void wifiSetup()
{
  hasWifi = false;
}
*/
void setup()
{
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT); 
  setupCloudIoT();
  ledSetup();
}


unsigned long lastMillis = 0;
void loop()
{
  /* if (passwordChanged && ssidChanged)
  {
    InitWifi();
  }
  */
  mqttClient->loop();
  delay(10);  // <- fixes some issues with WiFi stability

  if (!mqttClient->connected()) {
    connect();
  } else if (!bleConnected){
    btSetup();
  }
  // publish a message roughly every second.
  if (millis() - lastMillis > 10000 && (latChanged && lngChanged)) {
    latChanged = false;
    lngChanged = false;
    lastMillis = millis();
    Serial.println(String(lat.c_str())+String(", ")+String(lng.c_str()));
    publishTelemetry(String(lat.c_str())+String(", ")+String(lng.c_str()));
    //
  }
  if (blinking){
    ledcWrite(lastUsed, 100);
    delay(150);
    ledcWrite(lastUsed, 255);
    delay(150);
    ledcWrite(lastUsed, 100);
    delay(150);
    ledcWrite(lastUsed, 0);
  }
  if (!blinking && isOn){
    delay(50);
    ledcWrite(lastUsed, 255);
  } else if (!isOn){
    ledcWrite(lastUsed, 0);
  }
}


