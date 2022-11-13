#ifndef SENSORS_H
#define SENSORS_H

#include "led.h"
#include "utils.h"
#include "base.h"

class Sensor
{
protected:
  const int         m_pin;
  const bool        m_invert;
  int               m_last_value;

  const int         m_index;
  base_indicator*   m_indicator;
public:
  Sensor(const int a_pin, const bool a_invert);
  Sensor(const int a_pin, const bool a_invert, const int a_index, base_indicator* a_indicator);
  ~Sensor();

  virtual void loop(const bool a_immediately=false) = 0;
  virtual const bool value() = 0;
  const int last_value() const
  {
    return m_last_value;
  }
};

class DigitalSensor: public Sensor
{
private:
  const bool        m_pullup;
public:
  DigitalSensor(const int a_pin, const bool a_invert, const bool a_pullup);
  DigitalSensor(const int a_pin, const bool a_invert, const bool a_pullup, const int a_index, base_indicator* a_indicator);
  ~DigitalSensor();

  virtual void setup();
  virtual void loop(const bool a_immediately=false) override;

  virtual const bool value() override;
};

class AnalogSensor: public Sensor
{
private:
  int                 m_threshold;
  unsigned long       m_prev_analogRead;
protected:
  float               acc;
  const               float k;
  const unsigned int  c_interval;
  void process();
public:
  AnalogSensor(const int a_pin, const bool a_invert, const int a_threshold, const float a_k);
  AnalogSensor(const int a_pin, const bool a_invert, const int a_threshold, const float a_k, const int a_index, base_indicator* a_indicator);
  ~AnalogSensor();

  virtual void setup();
  virtual void loop(const bool a_immediately=false) override;
  virtual const bool value() override;
  const int threshold() const
  {
    return m_threshold;
  }
  const int last_value() const
  {
    return m_last_value;
  }
  void set_threshold (const int a_threshold);
};

void sensors_loop();

#endif
