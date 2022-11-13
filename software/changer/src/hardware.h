#ifndef HARDWARE_H
#define HARDWARE_H

#include "configuration.h"
#include "settings.h"
#include "communication.h"
#include "sensors.h"
#include "motors.h"
#include <Arduino.h>

class ExtruderMotor: public LinearMotor
{
protected:
public:
  ExtruderMotor();
  ~ExtruderMotor();

  bool feed(const float length_mm, const bool slow=false);
  bool feed(const float length_mm, Sensor* a_sensor, const bool a_sensor_invert);
};

class SelectorMotor: public EndstopMotor
{
private:
    Sensor&     m_flag_sensor;
    int         m_carriage_number;
public:
  SelectorMotor(Sensor& a_sensor, Sensor& a_flag_sensor);
  ~SelectorMotor();

  virtual bool init();
  virtual void disable() override;
  bool select(const int a_carriage_number);

  const int carriage_number() const
  {
    return m_carriage_number;
  }
};

class StandMotor: public EndstopMotor
{
private:
  float m_position;
public:
  StandMotor(Sensor& a_sensor);
  ~StandMotor();

  virtual bool init();
  virtual void disable() override;
  bool up();
  bool down(const float a_position);
};

class CutterMotor: public EndstopMotor
{
public:
  CutterMotor(Sensor& a_sensor);
  ~CutterMotor();

  bool cut();
};

class FrontierMotor: public EndstopMotor
{
public:
  FrontierMotor(Sensor& a_sensor);
  ~FrontierMotor();

  bool frontier();
  bool thrash();
  bool thrash_out();
};

#endif
