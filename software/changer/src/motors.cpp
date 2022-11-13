#include "motors.h"
#include "configuration.h"
#include <Arduino.h>
#include "communication.h"

////////////////////////////////////////////////////////////////////////////////

EnableMuxer::EnableMuxer(const int a_pin)
  : m_pin(a_pin)
  , m_count(0)
{
  pinMode(m_pin, OUTPUT);
  for (int i(0); i<3; i++)
    m_enable[i]=false;
}

EnableMuxer::~EnableMuxer()
{
}

int EnableMuxer::register_motor ()
{
  int res = m_count;
  m_count++;
  return res;
}

void EnableMuxer::enable(const int a_index)
{
  m_enable[a_index] = true;
  handle();
}

void EnableMuxer::disable(const int a_index)
{
  m_enable[a_index] = false;
  handle();
}

void EnableMuxer::handle()
{
  uint8_t t_state (DISABLE);
  for (int i(0); i < m_count; i++)
    if (m_enable[i])
    {
      t_state = ENABLE;
      break;
    }
  digitalWrite(m_pin, t_state);
}

#if (pin_enable_mixed != -1)
  EnableMuxer s_enable_muxer (pin_enable_mixed);
  EnableMuxer* enable_muxer = &s_enable_muxer;
#else
  EnableMuxer* enable_muxer = NULL;
#endif

////////////////////////////////////////////////////////////////////////////////

Motor::Motor(const int a_pin_dir
          , const int a_pin_step
          , const int a_pin_enable
          , const int a_step_delay_min
          , const int a_step_delay_max
          , const int a_step_delay_sub
          )
  : m_pin_dir(a_pin_dir)
  , m_pin_step(a_pin_step)
  , m_pin_enable(a_pin_enable)
  , m_step_delay_min (a_step_delay_min)
  , m_step_delay_max (a_step_delay_max)
  , m_step_delay_sub (a_step_delay_sub)
  , m_enablemuxer_index (-1)
{
}

Motor::~Motor()
{
}

void Motor::setup()
{
  pinMode(m_pin_dir, OUTPUT);
	pinMode(m_pin_step, OUTPUT);
  if (m_pin_enable != -1)
    pinMode(m_pin_enable, OUTPUT);
  else
    m_enablemuxer_index = enable_muxer->register_motor();
  disable();
}

bool Motor::init()
{
  return true;
}

void Motor::enable()
{
  if (m_enablemuxer_index != -1)
    enable_muxer->enable(m_enablemuxer_index);
  else
    digitalWrite(m_pin_enable, ENABLE);
}

void Motor::disable()
{
  if (m_enablemuxer_index != -1)
    enable_muxer->disable(m_enablemuxer_index);
  else
    digitalWrite(m_pin_enable, DISABLE);
}

void Motor::dir(const int a_dir)
{
  digitalWrite(m_pin_dir, a_dir);
}

void Motor::enabledir(const int a_dir)
{
    enable();
    dir(a_dir);
}

bool Motor::step(const unsigned long steps
              , const float a_multiplier
              , const unsigned long a_timeout 
              , Sensor* a_sensor
              , const bool a_sensor_invert
              , const bool a_default_result
              , unsigned long& actual_steps
              )
{
  int t_start_delay = m_step_delay_max*a_multiplier;
  int t_end_delay = m_step_delay_min*a_multiplier;
  int t_delay = t_start_delay;
  return step(steps,a_multiplier,a_timeout,a_sensor,a_sensor_invert,a_default_result,actual_steps,t_start_delay,t_end_delay,m_step_delay_sub,t_delay);
}

bool Motor::step(const unsigned long steps
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
              )
{
  const int t_start_delay = start_delay;
  const int t_end_delay = end_delay;
  actual_delay = t_start_delay;
  unsigned long acc(0);
  const float t_fdelta ((float)step_delay_sub / 100000);
  unsigned long t_start (millis());
  actual_steps=0;

  for (unsigned long i = 0; i < steps; i++)
  {
		digitalWrite(m_pin_step, HIGH);
		delayMicroseconds(PINHIGH);
		digitalWrite(m_pin_step, LOW);
	  delayMicroseconds(actual_delay+PINLOW);
    actual_steps++;

    acc += actual_delay + PINLOW + PINHIGH;

    if (a_sensor!=nullptr)
    {
      a_sensor->loop();
    }

    if (i%8==0)
    {
      if (a_timeout>0 && (millis()-t_start)>=a_timeout)
        return false;

      if (a_sensor!=nullptr)
      {
        const bool v=a_sensor->value();
        const bool t_value (a_sensor_invert ? !v : v);
        if (t_value)
        {
          return true;
        }
      }
      if (actual_delay!=t_end_delay)
      {
        int t_delta = t_fdelta * acc;
        actual_delay = t_start_delay - t_delta;
        if (actual_delay < t_end_delay)
          actual_delay = t_end_delay;
      }
    }
	}

  return a_default_result;
}

////////////////////////////////////////////////////////////////////////////////

LinearMotor::LinearMotor(const int a_pin_dir, const int a_pin_step, const int a_pin_enable, const int a_step_delay_min, const int a_step_delay_max, const int a_step_delay_sub
            , const unsigned long a_steps_permm)
  : Motor (a_pin_dir, a_pin_step, a_pin_enable,a_step_delay_min, a_step_delay_max, a_step_delay_sub)
  , m_steps_permm(a_steps_permm)
{
}

LinearMotor::~LinearMotor()
{
}

////////////////////////////////////////////////////////////////////////////////

EndstopMotor::EndstopMotor(const int a_pin_dir, const int a_pin_step, const int a_pin_enable
            , const int a_step_delay_min, const int a_step_delay_max, const int a_step_delay_sub
            , const unsigned long a_steps_permm, const float a_limit_mm
            , const unsigned long a_home_position_mm
            , unsigned a_motor_timeout, Sensor& a_sensor
            , const float a_bump_multiplier, const float a_bump_move
            )
  : LinearMotor(a_pin_dir, a_pin_step, a_pin_enable
            , a_step_delay_min, a_step_delay_max, a_step_delay_sub
            , a_steps_permm)
    , m_sensor (a_sensor)
    , m_inited(false)
    , current_steps(0)
    , m_limit_mm(a_limit_mm)
    , m_home_position_mm(a_home_position_mm)
    , m_motor_timeout(a_motor_timeout)
    , m_bump (a_bump_multiplier!=1.0)
    , m_bump_multiplier (a_bump_multiplier)
    , m_bump_move (a_bump_move)
    , m_dirty_move(false)
{
}

EndstopMotor::~EndstopMotor()
{
}

void EndstopMotor::disable()
{
  LinearMotor::disable();
  m_inited = false;
}

const float EndstopMotor::position() const
{
  return (float)current_steps/m_steps_permm;
}

float EndstopMotor::add_distance (float a_value)
{
    auto pos = position() + a_value;
    if (pos < 0) 
        pos = 0;
    if (pos>m_limit_mm)
        pos=m_limit_mm;
    return pos;
}

bool EndstopMotor::move(const float distance, const float a_multiplier, Sensor* a_sensor, const bool a_sensor_invert, const bool a_default_result)
{
  if (!m_inited && !m_dirty_move)
  {
    return false;
  }

  long new_steps (distance*m_steps_permm);
  int t_dir;
  long t_steps;
  if (new_steps>current_steps)
  {
    t_dir = CCW;
    t_steps = new_steps-current_steps;
  }
  else
  {
    t_dir = CW;
    t_steps = current_steps-new_steps;
  }
  
  enabledir (t_dir);
	delayMicroseconds(1500);
  unsigned long actual_steps;
  bool res = step (t_steps, a_multiplier, 0, a_sensor, a_sensor_invert, a_default_result,actual_steps);

  //current_steps = new_steps;
  current_steps = new_steps>current_steps ? current_steps+actual_steps:current_steps-actual_steps;

  return res;
}

bool EndstopMotor::move(const float distance, const float a_multiplier)
{
  return move(distance, a_multiplier, nullptr, false, true);
}

bool EndstopMotor::move(const float distance)
{
  return move(distance, 1.0);
}

bool EndstopMotor::initmove(unsigned long steps, int direction, const bool a_sensor_invert, const float a_multiplier)
{
  enable();
  dir(direction == CW ? LOW : HIGH);
	delayMicroseconds(1500);
  
  unsigned long actual_steps;
  return step(steps, a_multiplier, m_motor_timeout, &m_sensor, a_sensor_invert,false,actual_steps);
}

bool EndstopMotor::dirtymove(const float distance)
{
  m_dirty_move=true;
  auto res = move(distance, 1.0);
  m_dirty_move=false;
  return res;
}

bool EndstopMotor::init(const bool a_bump)
{
  current_steps = 0;

  enable();
  delay(1);
  long t_max = m_steps_permm * m_limit_mm;

  if (!initmove(t_max, CW, false, 1.0))
    return false;
  if (!initmove(t_max, CCW, true, 1.0))
    return false;

  const float t_multiplier ((m_bump && a_bump)?m_bump_multiplier:1.0);
  m_dirty_move = true;
  if (m_bump)
  {
    //comm().info(String(m_bump_multiplier).c_str());
    if (!move(m_bump_move, t_multiplier))
      goto m1;
      
    if (!initmove(t_max, CW, false, t_multiplier))
      goto m1;
  }

  current_steps = m_home_position_mm*m_steps_permm;
  if (!move(0, t_multiplier))
    goto m1;
  
  m_dirty_move = false;
  m_inited = true;
  current_steps = 0;
  return true;
m1:
  m_dirty_move = false;
  return false;
}

////////////////////////////////////////////////////////////////////////////////

