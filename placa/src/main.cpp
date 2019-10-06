#include <cmath>
#include <string>
#include <Arduino.h>
#include <WiFi.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID "37f64eb3-c25f-449b-ba34-a5f5387fdb6d"
#define CHARACTERISTIC_UUID "560d029d-57a1-4ccc-8868-9e4b4ef41da6"
#define CONNECTED_CHAR "13b5c4de-89af-4231-8ec3-b9fe596c10ea"

BLECharacteristic *connectionNotifier;

std::string ssid;
std::string password;
std::string lat;
std::string lng;

bool passwordChanged;
bool ssidChanged;

bool hasWifi;
int LED_BUILTIN;

const int wifiConnected = 67;
const int wifiDisconnected = 68;

void wifiSetup();
void InitWifi();
void btSetup();

class MyCallbacks : public BLECharacteristicCallbacks
{
  void onWrite(BLECharacteristic *pCharacteristic)
  { //lat
    std::string value = pCharacteristic->getValue();
    std::string a = &(value[1]);
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
    else if (value[0] == '1')
    {
      lng = a;
    }
    else if (value[0] == '0')
    {
      lat = a;
    }
  }
};

void btSetup()
{
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

  pCharacteristic->setCallbacks(new MyCallbacks());
  pService->start();
  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  pAdvertising->start();

  ssid = "";
  password = "";
  lat = "";
  lng = "";
  passwordChanged = false;
  ssidChanged = false;
  return;
}

void InitWifi()
{
  Serial.print(ssid.c_str());
  Serial.print(password.c_str());
  digitalWrite(LED_BUILTIN, HIGH);

  WiFi.begin(ssid.c_str(), password.c_str());
  int i = 0;
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    i = i + 1;
    if (i > 30)
    {
      break;
    }
  }
  digitalWrite(LED_BUILTIN, LOW);
  if (WiFi.status() == WL_CONNECTED)
  {
    hasWifi = true;
  }
  passwordChanged = false;
  ssidChanged = false;
}

void wifiSetup()
{
  LED_BUILTIN = 2;
  pinMode(LED_BUILTIN, OUTPUT);
  hasWifi = false;
}


void setup()
{
  Serial.begin(9600);
  wifiSetup();
  btSetup();
}

void loop()
{
  if (!hasWifi && passwordChanged && ssidChanged)
  {
    InitWifi();
  }
  delay(500);
}