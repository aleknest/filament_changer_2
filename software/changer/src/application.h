#ifndef APPLICATION_H
#define APPLICATION_H

#include "configuration.h"
#include "settings.h"
#include "communication.h"
#include "device.h"

#define max_arg 5

class Application
{
private:
	String	 		arg[max_arg];
	unsigned 		parg;
	bool			m_in_quotes;
	unsigned long	m_last_command;
	bool			m_disable_lock;

	Settings		m_settings;
	Device			m_device;

	void new_command_logic();
	void new_command(int iarg);
	void clear_arg();
	void handle_load_unload_parameters(const unsigned iarg,float& a_position, float& a_tohead_quickly, float& a_push, float& a_push_hair);
	bool handle_command();
	void handle_input(char ch);

	void disable_all();
public:
	Application();

	void setup();
	void loop();
};

#endif
