#ifndef APPLICATION_H
#define APPLICATION_H

#include <sensors.h>
#include <Arduino.h>

#define out_pin 10

class Application
{
private:
	FilamentSensor			m_filament_sensor;
	int						m_counter;
	unsigned long 			m_prev;
	bool					m_repaint_needed;
	int						m_threshold;
	int						m_last_value;
	bool					m_value;
public:
	Application();

	void setup();
	void loop();
};

#endif
