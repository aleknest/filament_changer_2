#include <Arduino.h>
#include "filament_encoder.h"

volatile unsigned long counter = 0;

void encoderTick()
{
  counter++;
}

FilamentEncoder::FilamentEncoder()
    : m_indicator(nullptr)
{
    reset();
}

FilamentEncoder::FilamentEncoder(base_indicator* a_indicator)
    : m_indicator(a_indicator)
{
    reset();
}

FilamentEncoder::~FilamentEncoder()
{  
}

void FilamentEncoder::setup()
{
    pinMode(filamentencoder_pin, INPUT);
    attachInterrupt(digitalPinToInterrupt(filamentencoder_pin), encoderTick, FALLING);
    
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

void FilamentEncoder::loop()
{
    if (m_indicator!=nullptr)    
        m_indicator->set_distance(value());
}
