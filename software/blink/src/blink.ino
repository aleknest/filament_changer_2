#include "filament_encoder.h"

#define pin1 LED_BUILTIN

void setup(void) 
{
  pinMode(pin1, OUTPUT);
  //Serial.begin (9600);
}

bool prev(true);
void loop(void) 
{
  digitalWrite(pin1, prev?HIGH:LOW);
  delay(1000);
  prev=!prev;                   

  //Serial.println(analogRead(A2));
}