#include <Arduino.h>
#include "filament_encoder.h"

volatile unsigned long counter = 0;

void encoderTick()
{
  counter++;
}

FilamentEncoder::FilamentEncoder()
{
    reset();
}

FilamentEncoder::~FilamentEncoder()
{  
}

void FilamentEncoder::setup()
{
    pinMode(filamentencoder_pin, INPUT);
    attachInterrupt(0, encoderTick, FALLING);
}

void FilamentEncoder::reset()
{
    counter = 0;
}

const unsigned long FilamentEncoder::value_tick() const
{
    return counter;
}

const float FilamentEncoder::value() const
{
    return (float)counter/filamentencoder_steps_permm;
}
