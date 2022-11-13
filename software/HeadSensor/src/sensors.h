#ifndef SENSORS_H
#define SENSORS_H

class Sensor
{
private:
  int                 m_threshold;
  unsigned long       m_prev_analogRead;
protected:
  const int           m_pin;
  int                 m_last_value;
  float               acc;
  const               float k;
  const unsigned int  c_interval;
  void process();
public:
  Sensor(const int a_pin, const int a_threshold);
  ~Sensor();

  virtual void setup();
  virtual void loop();
  virtual const bool value();
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

class FilamentSensor: public  Sensor
{
public:
  explicit FilamentSensor();
  ~FilamentSensor();
};

#endif
