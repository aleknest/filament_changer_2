#include <Arduino.h>

void setup(void) 
{
  Serial.begin(9600);
//  pinMode(2,INPUT_PULLUP);
//  pinMode(13,OUTPUT);
  pinMode(13,OUTPUT);
  pinMode(8,OUTPUT);
}

//bool prev(true);
void loop(void) 
{
//  int t = digitalRead(2)==LOW ? HIGH : LOW;
//  digitalWrite(13,t);
  digitalWrite(8,HIGH);
  delay(1);
}