#ifndef MOTORS_H
#define MOTORS_H

#include "sensors.h"

class EnableMuxer
{
private:
  const int       m_pin;
  bool            m_enable[3];
  int             m_count;

  void handle();
public:
  explicit EnableMuxer(const int a_pin);
  ~EnableMuxer();

  int register_motor ();
  void enable(const int a_index);
  void disable(const int a_index);
};

class Motor
{
private:
  const int       m_pin_dir;
  const int       m_pin_step;
  const int       m_pin_enable;
  int             m_step_delay_min;
  int             m_step_delay_max;
  int             m_step_delay_sub;
  int             m_enablemuxer_index;
protected:
  bool step(const unsigned long steps
          , const float a_multiplier
          , const unsigned long a_timeout
          , Sensor* a_sensor
          , const bool a_sensor_invert
          , const bool a_default_result
          , unsigned long& actual_steps
          );
  bool step(const unsigned long steps
          , const float a_multiplier
          , const unsigned long a_timeout
          , Sensor* a_sensor
          , const bool a_sensor_invert
          , const bool a_default_result
          , unsigned long& actual_steps
          , int& start_delay
          , int& end_delay
          , int  step_delay_sub
          , int& actual_delay
          );
  void enable();
  void dir(const int a_dir);
  void enabledir(const int a_dir);
public:
  Motor(const int a_pin_dir, const int a_pin_step, const int a_pin_enable, const int a_step_delay_min, const int a_step_delay_max, const int a_step_delay_sub);
  ~Motor();

  virtual bool init();
  virtual void setup();
  virtual void disable();
  
  const int step_delay_min() const
  {
    return m_step_delay_min;    
  }
  const int step_delay_max() const
  {
    return m_step_delay_max;    
  }
  const int step_delay_sub() const
  {
    return m_step_delay_sub;    
  }
};

class LinearMotor: public Motor
{
protected:
  const unsigned long     m_steps_permm;
public:
  LinearMotor(const int a_pin_dir, const int a_pin_step, const int a_pin_enable
            , const int a_step_delay_min, const int a_step_delay_max, const int a_step_delay_sub
            , const unsigned long a_steps_permm);
  ~LinearMotor();
};

class EndstopMotor: public LinearMotor
{
protected:
  Sensor&             m_sensor;

  bool                m_inited;
  long                current_steps;

  const float         m_limit_mm;
  const unsigned long m_home_position_mm;
  const unsigned      m_motor_timeout;

  const bool    m_bump;
  const float   m_bump_multiplier;
  const float   m_bump_move;
  bool          m_dirty_move;
  
  float add_distance (float a_value);
public:
  EndstopMotor(const int a_pin_dir, const int a_pin_step, const int a_pin_enable
            , const int a_step_delay_min, const int a_step_delay_max, const int a_step_delay_sub
            , const unsigned long a_steps_permm, const float a_limit_mm
            , const unsigned long a_home_position_mm
            , unsigned a_motor_timeout, Sensor& a_sensor
            , const float a_bump_multiplier, const float a_bump_move
            );
  ~EndstopMotor();
  virtual void disable() override;

  const float position() const;

  virtual bool init(const bool a_bump=true); 
  const bool inited() const
  {
    return m_inited;
  }
  
  bool initmove(unsigned long steps, int direction, const bool a_sensor_invert, const float a_multiplier);
  bool move(const float distance, const float a_multiplier, Sensor* a_sensor, const bool a_sensor_invert, const bool a_default_result);
  bool move(const float distance, const float a_multiplier);
  bool move(const float distance);
  bool dirtymove(const float distance);
};

#endif
