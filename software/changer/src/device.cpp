#include "device.h"

////////////////////////////////////////////////////////////////////////////////////

Device::Device(Settings& a_settings)
    : m_loaded(false)
    , m_unloaded(false)
      #ifdef OLED
	, m_oled_sensors_count(0)
      #endif
    , m_settings(a_settings)

  	, m_stand_filament_sensor (pin_stand_filament_sensor, true , true
      #ifdef OLED
      , m_oled_sensors_count++, comm().display()
      #endif
      )
	, m_extruder_motor()

	, m_selector_endstop (pin_selector_endstop,false,false
        #ifdef OLED
        , m_oled_sensors_count++, comm().display()
        #endif
        )
	, m_selector_flag_endstop(pin_selector_marker_endstop,false,false
        #ifdef OLED
        , m_oled_sensors_count++, comm().display()
        #endif
    )
    , m_selector_motor (m_selector_endstop,m_selector_flag_endstop)

	, m_stand_endstop (pin_stand_endstop,true,true
        #ifdef OLED
        , m_oled_sensors_count++, comm().display()
        #endif
        )
    , m_stand_motor (m_stand_endstop)

	, m_frontier_endstop (pin_frontier_endstop,false,false
        #ifdef OLED
        , m_oled_sensors_count++, comm().display()
        #endif
    )
    , m_frontier_motor (m_frontier_endstop)
	, m_cutter_endstop (pin_cutter_endstop,true,true 
      #ifdef OLED
      , m_oled_sensors_count++, comm().display() 
      #endif
      )
    , m_cutter_motor (m_cutter_endstop)

    , m_filament_encoder(
      #ifdef OLED
      comm().display() 
      #endif
    )
{
}

void Device::setup()
{
	m_cutter_endstop.setup();
	m_cutter_motor.setup();

	m_stand_filament_sensor.setup();
	m_extruder_motor.setup();

    m_selector_flag_endstop.setup();
	m_selector_endstop.setup();
    m_selector_motor.setup();

    m_stand_endstop.setup();
    m_stand_motor.setup();

	m_frontier_endstop.setup();
    m_frontier_motor.setup();

    m_filament_encoder.setup();

    m_stand_motor.init();
    disable();
}

void Device::loop()
{
	sensors_loop();
    m_filament_encoder.loop();
}

const int Device::carriage_request() const
{
    return m_settings.settings.m_carriage_request;
}

void Device::set_carriage_request(int a_value)
{
    m_settings.settings.m_carriage_request = a_value;
    m_settings.save();
}

bool Device::disable()
{
 	m_cutter_motor.disable();
	m_extruder_motor.disable();
    m_selector_motor.disable();
    m_stand_motor.disable();
    m_frontier_motor.disable();
    return true;
}

bool Device::cut()
{
    if (m_cutter_endstop.value())
        return false;
    return m_cutter_motor.cut();
}

bool Device::feed(const float length_mm)
{
    return m_extruder_motor.feed(length_mm);
}

bool Device::feed(const float length_mm, Sensor* a_sensor, const bool a_sensor_invert)
{
    return m_extruder_motor.feed (length_mm, a_sensor, a_sensor_invert);
}

bool Device::stand_up()
{
    m_extruder_motor.disable();
    return m_stand_motor.up();
}

bool Device::stand_down(const float a_position)
{
    return m_stand_motor.down(a_position);
}

bool Device::frontier()
{
    if (!m_frontier_motor.inited())
    {
        if (!m_frontier_motor.init())
            return false;
    }
    return m_frontier_motor.frontier();
}

bool Device::trash()
{
    if (!m_frontier_motor.inited())
    {
        if (!m_frontier_motor.init())
            return false;
    }
    return m_frontier_motor.thrash();
}

bool Device::trash_out()
{
    if (!m_frontier_motor.inited())
    {
        if (!m_frontier_motor.init())
            return false;
    }
    return m_frontier_motor.thrash_out();
}

bool Device::e_load_stand(String& a_error, const float a_stand_down_position)
{
    if (!stand_down(a_stand_down_position))
    {
        a_error = F("Can't stand down");
        return false;
    }
    
    /*
    const int imax(2);
    bool res(false);
    for (unsigned i(0);i<imax;i++)
    {
        if (m_extruder_motor.feed(extruder_tostand, &m_stand_filament_sensor, false))
        {
            res=true;
            break;
        }
        if (i!=imax-1)
        {
            if (!stand_up())
            {
                a_error = F("Can't stand up");
                return false;
            }
            if (!stand_down(a_stand_down_position))
            {
                a_error = F("Can't stand down");
                return false;
            }
        }
    }
    if (!res)
    {
        a_error = F("Feed to stand failed");
        return false;
    }
    */

    
    if (!m_extruder_motor.feed(extruder_tostand, &m_stand_filament_sensor, false))
    {
        if (!stand_up())
        {
            a_error = F("Can't stand up");
            return false;
        }
        if (!stand_down(a_stand_down_position))
        {
            a_error = F("Can't stand down");
            return false;
        }
        if (!m_extruder_motor.feed(extruder_tostand, &m_stand_filament_sensor, false))
        {
            a_error = F("Feed to stand failed");
            return false;
        }
    }
    
    return true;
}

bool Device::e_load_head(String& a_error, const float a_stand_down_position,const float a_tohead_quickly)
{
    if (!frontier())
        return false;
    if (!m_extruder_motor.feed(extruder_tofrontier, true))
    {
        a_error = F("Feed to frontier failed");
        return false;
    }
    if (!m_extruder_motor.feed(a_tohead_quickly))
    {
        a_error = F("Quick feed to head failed");
        return false;
    }
    if (!m_extruder_motor.feed(extruder_tohead, true))
    {
        a_error = F("Feed to head(sensor) failed");
        return false;
    }
    if (!m_extruder_motor.feed(extruder_fromhead_togear))
    {
        a_error = F("Feed to gear failed");
        return false;
    }
    return true;
}

bool Device::e_unload_head(String& a_error)
{
    float dist(m_filament_encoder.value());
    if (!m_extruder_motor.feed(-extruder_tohead, true))
        return false;
    float t_length_mm = m_filament_encoder.value()-dist;
    if (t_length_mm<filamentencoder_extruder_tohead)
    {
        a_error = F("Filament not moved");
        return false;
    }
    sensors_loop();
    if (!m_extruder_motor.feed(-extruder_fromhead_quickly))
    {
        a_error = F("Quick feed from head failed");
        return false;
    }
    if (!m_extruder_motor.feed(-(extruder_fromfrontier+extruder_frontier_in), &m_stand_filament_sensor, true))
    {
      a_error = F("Feed to stand sensor failed");
      return false;
    }
    return true;
}

bool Device::e_cut(String& a_error, const float a_push,const float a_push_hair)
{
    if (!m_extruder_motor.feed(-extruder_tostand, &m_stand_filament_sensor, true))
    {
        a_error = F("Feed to stand sensor failed");
        return false;
    }
    if (!m_extruder_motor.feed(-extruder_tocutter))
    {
        a_error = F("Feed from stand sensor failed");
        return false;
    }

    if (!trash_out())
    {
        a_error = F("Select thrash out failed");
        return false;
    }

    if (!m_extruder_motor.feed(extruder_tocutter))
    {
        a_error = F("Feed to cutter failed");
        return false;
    }
    if (!m_extruder_motor.feed(a_push_hair))
    {
        a_error = F("Move out hair failed");
        return false;
    }
    if (!m_extruder_motor.feed(-a_push_hair))
    {
        a_error = F("Move in hair failed");
        return false;
    }
    if (!m_extruder_motor.feed(-extruder_tostand, &m_stand_filament_sensor, true))
    {
        a_error = F("Feed to stand sensor failed");
        return false;
    }

    if (!trash())
    {
        a_error = F("Select thrash failed");
        return false;
    }

    if (!m_extruder_motor.feed(extruder_cutdistance))
    {
        a_error = F("Feed for cutting failed");
        return false;
    }
    if (!cut())
    {
        a_error = F("Cut failed");
        return false;
    }
    if (!m_extruder_motor.feed(a_push))
    {
        a_error = F("Push cutted part failed");
        return false;
    }

    if (!m_extruder_motor.feed(-a_push))
    {
        a_error = F("Feed after push failed");
        return false;
    }
    auto t_prev=filament_encoder().value();
    bool res = m_extruder_motor.feed(-extruder_fromcutter_tostandsensor, &m_stand_filament_sensor, true);
    auto t_cur=filament_encoder().value()-t_prev;
    String d(t_cur);
    d+="mm";
    if (comm().display())
        comm().display()->print_additional(d.c_str());
    if (!res)
    {
        a_error = F("Feed to stand sensor failed");
        return false;
    }

    if (!frontier())
    {
        a_error = F("Select frontier failed");
        return false;
    }
    return true;
}

bool Device::e_unload_stand(String& a_error)
{
     if (!m_extruder_motor.feed(-extruder_fromtostandsensor_tostandout))
    {
      a_error = F("Feed to carriage failed");
      return false;
    }
    return true;
}

bool Device::select(String& a_error, const int a_carriage_number)
{
    if (m_selector_motor.carriage_number()==a_carriage_number)
        return true;
    if (!stand_up())
        goto m1;
    if (m_stand_filament_sensor.value())
    {
        a_error = F("Filament in stand");
        goto m1;
    }
    if (!m_selector_motor.inited())
    {
        if (!m_selector_motor.init())
        {
            a_error = F("Can't init selector");
            goto m1;
        }
    }
    if (!m_selector_motor.select (a_carriage_number))
    {
        a_error = F("Can't select carriage");
        goto m1;
    }

    set_carriage_request(a_carriage_number);
    return true;
m1:
    disable();
    return false;
}

bool Device::load(String& a_error, const float a_stand_down_position, const float a_tohead_quickly)
{
    if (m_loaded)
    {
        a_error = F("Already loaded");
        return true;
    }
    if (carriage_request()<0)
    {
        a_error = F("Carriage not defined");
        return false;
    }

    m_loaded=true;
    m_unloaded=false;

    if (!select(a_error, carriage_request()))
        goto m1;
    if (!e_load_stand(a_error, a_stand_down_position))
        goto m1;
    if (!e_load_head(a_error, a_stand_down_position, a_tohead_quickly))
        goto m1;

    m_extruder_motor.disable();
    return true;
m1:
    stand_up();
    disable();
    return false;
}

bool Device::unload(String& a_error, const float a_stand_down_position,const float a_push,const float a_push_hair)
{
   if (m_unloaded)
   {
        a_error = F("Already unloaded");
        return true;
   }
   m_loaded=false;
   m_unloaded=true;
   set_carriage_request(-1);

    if (!stand_down(a_stand_down_position))
    {
        a_error = F("Can't stand down");
        goto m1;
    }
    if (!e_unload_head(a_error))
        goto m1;
    if (!e_cut(a_error,a_push, a_push_hair))
        goto m1;
    if (!e_unload_stand(a_error))
        goto m1;
    if (!stand_up())
    {
        a_error = F("Can't stand up");
        goto m1;
    }
    m_extruder_motor.disable();
    return true;
m1:
    stand_up();
    disable();
    return false;
}

bool Device::verify_filament()
{
    return !m_stand_filament_sensor.value();
}

////////////////////////////////////////////////////////////////////////////////////
