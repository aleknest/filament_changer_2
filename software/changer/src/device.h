#ifndef DEVICE_H
#define DEVICE_H

#include "configuration.h"
#include "settings.h"
#include "communication.h"
#include "sensors.h"
#include "hardware.h"
#include "filament_encoder.h"
#include <Arduino.h>

class Device
{
private:
    bool            m_loaded,m_unloaded;
    #ifdef OLED
    int             m_oled_sensors_count;
    #endif

	Settings&		m_settings;

	//AnalogSensor    m_stand_filament_sensor;
	DigitalSensor	m_stand_filament_sensor;
	ExtruderMotor   m_extruder_motor;

	DigitalSensor	m_selector_endstop;
	DigitalSensor	m_selector_flag_endstop;
	SelectorMotor	m_selector_motor;

	DigitalSensor	m_stand_endstop;
	StandMotor	    m_stand_motor;

	DigitalSensor	m_frontier_endstop;
    FrontierMotor   m_frontier_motor;

	DigitalSensor	m_cutter_endstop;
	CutterMotor 	m_cutter_motor;

    FilamentEncoder m_filament_encoder;
public:
    Device(Settings& a_settings);

	Sensor& cutter_endstop()
    {
        return m_cutter_endstop;
    }	
	Sensor& stand_filament_sensor()
    {
        return m_stand_filament_sensor;
    }
    Sensor& selector_flag_endstop()
    {
        return m_selector_flag_endstop;
    }
	Sensor& selector_endstop()
    {
        return m_selector_endstop;
    }	
	SelectorMotor& selector_motor()
    {
        return m_selector_motor;
    }
	Sensor&	stand_endstop()
    {
        return m_stand_endstop;
    }
	StandMotor& stand_motor()
    {
        return m_stand_motor;
    }
    FrontierMotor& frontier_motor() 
    {
        return m_frontier_motor;
    }
	DigitalSensor& frontier_endstop()
    {
        return m_frontier_endstop;
    }

    FilamentEncoder& filament_encoder()
    {
        return m_filament_encoder;
    }

    const bool loaded() const
    {
        return m_loaded;
    }
    const bool unloaded() const
    {
        return m_unloaded;
    }

    const int carriage_request() const;
    void set_carriage_request(int a_value);

	void setup();
	void loop();

    bool verify_filament();

    bool disable();
    bool cut();
    bool feed(const float length_mm);
    bool feed(const float length_mm, Sensor* a_sensor, const bool a_sensor_invert);
    bool stand_up();
    bool stand_down(const float a_position);
    bool frontier();
    bool trash();
    bool trash_out();

    bool e_cut(String& a_error,const float a_push,const float a_push_hair);

    bool e_load_stand(String& a_error, const float a_stand_down_position);
    bool e_load_head(String& a_error, const float a_stand_down_position, const float a_tohead_quickly);
    bool e_unload_head(String& a_error);
    bool e_unload_stand(String& a_error);

    bool select(String& a_error, const int a_carriage_number);
    bool load(String& a_error, const float a_stand_down_position, const float a_tohead_quickly);
    bool unload(String& a_error, const float a_stand_down_position,const float a_push,const float a_push_hair);
};

#endif
