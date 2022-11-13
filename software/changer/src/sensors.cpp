#include "sensors.h"
#include "configuration.h"
#include <Arduino.h>

Vector<Sensor*> g_sensors;

void sensors_loop()
{
  for (unsigned i=0;i<g_sensors.size();i++)
    g_sensors[i]->loop();
}

////////////////////////////////////////////////////////////////////////////////

Sensor::Sensor(const int a_pin, const bool a_invert)
  : m_pin (a_pin)
  , m_invert (a_invert)
  , m_last_value(0)
  , m_index(-1)
  , m_indicator(nullptr)
{
  g_sensors.push_back(this);
}

Sensor::Sensor(const int a_pin, const bool a_invert, const int a_index, base_indicator* a_indicator)
  : m_pin (a_pin)
  , m_invert (a_invert)
  , m_last_value(0)
  , m_index(a_index)
  , m_indicator(a_indicator)
{
  g_sensors.push_back(this);
}


Sensor::~Sensor()
{
}

////////////////////////////////////////////////////////////////////////////////

DigitalSensor::DigitalSensor(const int a_pin, const bool a_invert, const bool a_pullup)
  : Sensor(a_pin, a_invert)
  , m_pullup (a_pullup)
{
}

DigitalSensor::DigitalSensor(const int a_pin, const bool a_invert, const bool a_pullup, const int a_index, base_indicator* a_indicator)
  : Sensor(a_pin, a_invert,a_index, a_indicator)
  , m_pullup (a_pullup)
{
}

DigitalSensor::~DigitalSensor()
{
}

void DigitalSensor::setup()
{
  pinMode(m_pin, m_pullup ? INPUT_PULLUP : INPUT);
  if (m_pullup)
    digitalWrite(m_pin, HIGH);
}

void DigitalSensor::loop(const bool a_immediately)
{
  if (m_pullup)
    digitalWrite(m_pin, HIGH);
  m_last_value = digitalRead(m_pin);
  if (m_indicator!=nullptr)
    m_indicator->set_state(m_index,value());
}

const bool DigitalSensor::value()
{
  bool ret = m_last_value != 0;
  ret = m_invert ? !ret : ret;
  return ret;
}

////////////////////////////////////////////////////////////////////////////////

AnalogSensor::AnalogSensor(const int a_pin, const bool a_invert, const int a_threshold, const float a_k)
  : Sensor(a_pin, a_invert)
  , m_threshold(a_threshold)
  , m_prev_analogRead(0)
  , acc(0.0)
  , k(a_k)
  , c_interval(500)
{
}

AnalogSensor::AnalogSensor(const int a_pin, const bool a_invert, const int a_threshold, const float a_k, const int a_index, base_indicator* a_indicator)
  : Sensor(a_pin, a_invert,a_index, a_indicator)
  , m_threshold(a_threshold)
  , m_prev_analogRead(0)
  , acc(0.0)
  , k(a_k)
  , c_interval(500)
{
}

AnalogSensor::~AnalogSensor()
{
}

void AnalogSensor::setup()
{
  m_last_value = analogRead(m_pin);
  acc=m_last_value;
}

void AnalogSensor::process()
{
  m_last_value = analogRead(m_pin);
  acc=k*acc+(1-k)*m_last_value;
}

void AnalogSensor::loop(const bool a_immediately)
{
  unsigned long current(micros());
  if (m_prev_analogRead>current)
    m_prev_analogRead = current;
  if (a_immediately || (current-m_prev_analogRead > c_interval))
  {
    process();
    m_prev_analogRead = current;

    if (m_indicator!=nullptr)
      m_indicator->set_state(m_index,value(),acc);
  }
}

const bool AnalogSensor::value()
{
  bool ret = acc < threshold();
  ret = m_invert ? !ret : ret;
  return ret;
}

void AnalogSensor::set_threshold (const int a_threshold)
{
  m_threshold = a_threshold;
}

////////////////////////////////////////////////////////////////////////////////
