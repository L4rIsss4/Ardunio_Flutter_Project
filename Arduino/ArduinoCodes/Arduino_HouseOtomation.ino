#include<SoftwareSerial.h>
#include "DHT.h"

int sensorPin = A5; // select the input pin for the LDR
int sensorValue = 0; // variable to store the value coming from the sensor
#include "DHT.h"
#define DHTTYPE DHT11 
#define DHTPIN 8
#define echoPin 11 // attach pin D2 Arduino to pin Echo of HC-SR04
#define trigPin 12

int led = 7; // Output pin for LED
int rxPin=1; 
int txPin=0;
long duration;
int distance;
SoftwareSerial hc06(rxPin,txPin);
DHT dht(DHTPIN, DHTTYPE); 

void setup() {


pinMode(led, OUTPUT);
pinMode(trigPin, OUTPUT); // Sets the trigPin as an OUTPUT
pinMode(echoPin, INPUT); 
Serial.begin(9600);
hc06.begin(9600);
dht.begin(9600);
}

void loop()

{
float humidity = dht.readHumidity();
float temperature = dht.readTemperature();
sensorValue = analogRead(sensorPin);



if (sensorValue < 100)

{
Serial.println("Yangın VAR!");
hc06.println("Yangın Var!");
digitalWrite(led,HIGH);
delay(1000);
}

digitalWrite(led,LOW);
delay(sensorValue);

if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Sensör okuması başarısız oldu!");
    hc06.println("Sensör okuması başarısız oldu!");
    return;
  }
else 
{
  Serial.print("Nem: ");
  Serial.print(humidity);
  Serial.print(" %\t");
  Serial.print("Sıcaklık: ");
  Serial.print(temperature);
  Serial.println(" *C");
  hc06.print("Nem: ");
  hc06.print(humidity);
  hc06.print(" %\t");
  hc06.print("Sıcaklık: ");
  hc06.print(temperature);
  hc06.println(" *C");   
}
digitalWrite(trigPin, LOW);
delayMicroseconds(2);
// Sets the trigPin on HIGH state for 10 micro seconds
digitalWrite(trigPin, HIGH);
delayMicroseconds(10);
digitalWrite(trigPin, LOW);
// Reads the echoPin, returns the sound wave travel time in microseconds
duration = pulseIn(echoPin, HIGH);
// Calculating the distance
distance = duration * 0.034 / 2;
// Prints the distance on the Serial Monitor
Serial.print("Uzaklık: ");
Serial.println(distance);
hc06.print("Uzaklık: ");
hc06.println(distance);
}
