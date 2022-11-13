#include "sensors.h"
#include <Arduino.h>

////////////////////////////////////////////////////////////////////////////////

Sensor::Sensor(const int a_pin, const int a_threshold)
  : m_threshold(a_threshold)
  , m_prev_analogRead(0)
  , m_pin (a_pin)
  , m_last_value(0)
  , acc(0.0)
  , k(0.97)
  , c_interval(1000)
{
}

Sensor::~Sensor()
{
}

void Sensor::setup()
{
  m_last_value = analogRead(m_pin);
  acc=m_last_value;
}

void Sensor::process()
{
  m_last_value = analogRead(m_pin);
  acc=k*acc+(1-k)*m_last_value;
}

void Sensor::loop()
{
  unsigned long current(micros());
  if (m_prev_analogRead>current)
    m_prev_analogRead = current;
  if (current-m_prev_analogRead > c_interval)
  {
    process();
    m_prev_analogRead = current;
  }
}

const bool Sensor::value()
{
  bool ret = acc < threshold();
  return ret;
}

void Sensor::set_threshold (const int a_threshold)
{
  m_threshold = a_threshold;
}

////////////////////////////////////////////////////////////////////////////////

FilamentSensor::FilamentSensor()
  : Sensor (A1, 950)
{
}

FilamentSensor::~FilamentSensor()
{
}

////////////////////////////////////////////////////////////////////////////////
