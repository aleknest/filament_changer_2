#include "device.h"

////////////////////////////////////////////////////////////////////////////////////

constexpr int t_pins_extruder_motor[3] = pins_extruder_motor;
ExtruderMotor::ExtruderMotor()
    : LinearMotor (t_pins_extruder_motor[0],t_pins_extruder_motor[1],t_pins_extruder_motor[2]
				, extruder_motor_delay_min, extruder_motor_delay_max, extruder_motor_delay_sub
                , extruder_steps_permm)
{ 
}

ExtruderMotor::~ExtruderMotor()
{
}

bool ExtruderMotor::feed(const float length_mm, const bool slow)
{
    enabledir (length_mm > 0 ? CCW : CW);
    unsigned long t_steps = m_steps_permm*abs(length_mm);
    unsigned long actual_steps;
    int t_start_delay = extruder_motor_delay_max;
    int t_end_delay = slow?extruder_motor_delay_min:extruder_motor_delay_speed;
    int t_delay = extruder_motor_delay_max;

    step (t_steps,1.0,0,nullptr,false,true,actual_steps,t_start_delay,t_end_delay,step_delay_sub(),t_delay);
    return true;
}

bool ExtruderMotor::feed(const float length_mm, Sensor* a_sensor, const bool a_sensor_invert)
{
	enabledir (length_mm > 0 ? CCW : CW);
    unsigned long t_steps = m_steps_permm*abs(length_mm);
    unsigned long cur(0);
    int t_start_delay = step_delay_max();
    int t_end_delay = step_delay_min();
    int t_delay = t_start_delay;

    while (cur < t_steps)
    {
        if (a_sensor!=nullptr)
        {
            a_sensor->loop();
            bool t_value (a_sensor_invert ? !a_sensor->value() : a_sensor->value());
            if (t_value)
                return true;
        }

        unsigned long p = cur+m_steps_permm < t_steps ? m_steps_permm : t_steps - cur;
        unsigned long actual_steps;
        step (p,1.0,0,nullptr,false,true,actual_steps,t_start_delay,t_end_delay,step_delay_sub(),t_delay);
        t_start_delay=t_delay;
        cur = cur + p;
    }
    return false;
}

////////////////////////////////////////////////////////////////////////////////////

constexpr int t_pins_selector_motor[3] = pins_selector_motor;
SelectorMotor::SelectorMotor(Sensor& a_sensor, Sensor& a_flag_sensor)
    :EndstopMotor (t_pins_selector_motor[0],t_pins_selector_motor[1],t_pins_selector_motor[2]
                , selector_motor_delay_min, selector_motor_delay_max, selector_motor_delay_sub
                , selector_steps_permm, selector_limit_mm
                , selector_home_position_mm
                , selector_motor_sensor_timeout, a_sensor
                , selector_motor_bump, selector_motor_bump_move
                )
    , m_flag_sensor(a_flag_sensor)
    , m_carriage_number (0)
{
}

SelectorMotor::~SelectorMotor()
{
}

bool SelectorMotor::init()
{
    m_carriage_number = 0;
    return EndstopMotor::init();
}

void SelectorMotor::disable()
{
    EndstopMotor::disable();
    m_carriage_number = 0;
}

bool SelectorMotor::select(const int a_carriage_number)
{
    if (!m_inited)
        return false;
    if (a_carriage_number == m_carriage_number)
        return true;

    const float t_target_distance = m_limit_mm;
    const float t_flag_distance = 40;
    float t_multiplier = a_carriage_number > m_carriage_number ? 1 : -1;
    int t_skip = abs(a_carriage_number - m_carriage_number) - 1;
    
    // skip current carriage
    if (!move(add_distance(t_flag_distance*t_multiplier), 1.0, &m_flag_sensor, true, false))
        return false;

    // skip carriage
    m_carriage_number = 0;
    for (int i(0);i<t_skip;i++)
    {
        if (!move(add_distance(t_target_distance*t_multiplier), 1.0, &m_flag_sensor, false, false))
            return false;
        if (!move(add_distance(t_flag_distance*t_multiplier), 1.0, &m_flag_sensor, true, false))
            return false;
    }

    float acc=0;
    for (int i=0;i<selector_probe_max;i++)
    {
        int imul=((i%2)==0)?1:-1;
        if (!move(add_distance(t_target_distance*t_multiplier*imul), 1.0, &m_flag_sensor, false, false))
              return false;
        acc += position();

        if (!move(add_distance(t_flag_distance*t_multiplier*imul), 1.0, &m_flag_sensor, true, false))
             return false;
        acc += position();
    }
    float pos=acc/(selector_probe_max*2)+selector_probe_offsetmm;

    // return to center of target carriage flag
    if (!move(pos))
         return false;

    m_carriage_number = a_carriage_number;
    return true;   
}

////////////////////////////////////////////////////////////////////////////////////

constexpr int t_pins_cariage_motor[3] = pins_stand_motor;
StandMotor::StandMotor(Sensor& a_sensor)
    :EndstopMotor (t_pins_cariage_motor[0],t_pins_cariage_motor[1],t_pins_cariage_motor[2]
                , stand_motor_delay_min, stand_motor_delay_max, stand_motor_delay_sub
                , stand_steps_permm, stand_limit_mm
                , stand_home_position_mm
                , stand_motor_sensor_timeout, a_sensor
                , stand_motor_bump, stand_motor_bump_move
                )
    ,m_position(-1)
{
}

StandMotor::~StandMotor()
{
}

bool StandMotor::init()
{
    m_position = -1;
    return EndstopMotor::init();
}

void StandMotor::disable()
{
    EndstopMotor::disable();
    m_position = -1;
}

bool StandMotor::up()
{
    if (!inited())
    {
        if (!init())
            return false;
    }
    m_position = -1;
    if (!move(stand_up_position_mm))
          return false;

    disable();
    m_position = -1;

    return true;
}

bool StandMotor::down(const float a_position)
{
    if (m_position!=a_position)
    {
        disable();
        if (!init())
            return false;
    }
    m_position = -1;
    if (!move(a_position))
          return false;
    m_position = a_position;
    return true;
}

////////////////////////////////////////////////////////////////////////////////////

constexpr int t_pins_cutter_motor[3] = pins_cutter_motor;
CutterMotor::CutterMotor(Sensor& a_sensor)
    :EndstopMotor (t_pins_cutter_motor[0],t_pins_cutter_motor[1],t_pins_cutter_motor[2]
                , cutter_motor_delay_min, cutter_motor_delay_max, cutter_motor_delay_sub
                , cutter_steps_per, cutter_max_angle
                , cutter_home_position
                , cutter_motor_sensor_timeout, a_sensor
                , cutter_motor_bump, cutter_motor_bump_move
                )
{

}

CutterMotor::~CutterMotor()
{
}

bool CutterMotor::cut()
{
    m_inited = false;
    if (!init())
        return false;

    if (!move(cutter_return_angle))
       return false;

    disable();

    return true;
}

////////////////////////////////////////////////////////////////////////////////////

constexpr int t_pins_frontier_motor[3] = pins_frontier_motor;
FrontierMotor::FrontierMotor(Sensor& a_sensor)
    :EndstopMotor (t_pins_frontier_motor[0],t_pins_frontier_motor[1],t_pins_frontier_motor[2]
                , frontier_motor_delay_min, frontier_motor_delay_max, frontier_motor_delay_sub
                , frontier_steps_permm, frontier_limit_mm
                , frontier_home_position_mm
                , frontier_motor_sensor_timeout, a_sensor
                , frontier_motor_bump, frontier_motor_bump_move
                )
{
}

FrontierMotor::~FrontierMotor()
{
}

bool FrontierMotor::frontier()
{
    if (!m_inited)
        return false;
    if (!move(frontier_frontier_position_mm))
          return false;
    return true;
}

bool FrontierMotor::thrash()
{
    if (!m_inited)
        return false;
    if (!move(frontier_thrash_position_mm))
          return false;
    return true;
}

bool FrontierMotor::thrash_out()
{
    if (!m_inited)
        return false;
    if (!move(frontier_thrashout_position_mm))
          return false;
    return true;
}

////////////////////////////////////////////////////////////////////////////////////
