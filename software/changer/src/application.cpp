#include <Arduino.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include "application.h"

#define FASTADC 1
// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

Application::Application()
	: m_in_quotes(false)
	, m_last_command(0)
	, m_disable_lock(false)
	, m_device(m_settings)
{
	clear_arg();
}

void Application::setup()
{
	#if FASTADC
	// set prescale to 16
	sbi(ADCSRA,ADPS2) ;
	cbi(ADCSRA,ADPS1) ;
	cbi(ADCSRA,ADPS0) ;
	#endif

	comm().setup();
	m_device.setup();
}

void Application::loop()
{
	comm().loop();
	m_device.loop();

	while (comm().available())
	{
		char c=comm().read();
		handle_input(c);
	}

	unsigned long t_current = millis();
	if (!m_disable_lock && ((t_current-m_last_command)>motors_hold_timeout))
	{
		m_device.disable();
		m_disable_lock = true;
	}

	delay(1);
}

void Application::new_command_logic()
{
	m_disable_lock=false;
	m_last_command=millis();
	comm().reset_command_bufer();
}

void Application::new_command(int iarg)
{
	new_command_logic();

	char t_msg[255];
	t_msg[0]=0;
	for (int i(0);i<iarg;i++)
	{
		strcat(t_msg,arg[i].c_str());
		strcat(t_msg," ");
	}
	comm().info (t_msg);
}


void Application::clear_arg()
{
	for (unsigned i(0);i<max_arg;i++)
		arg[i] = "";
	parg=0;
}

void Application::handle_input(char ch)
{
	if (ch==(char)10)
		return;

	if (ch=='"')
		m_in_quotes = !m_in_quotes;
	
	if (!m_in_quotes)
	{
		if (ch==';' || ch=='!' || ch==(char)13)
		{
			if (arg[parg].length()>0)
				parg++;
			handle_command();
			clear_arg();
			return;
		}

		if (ch==' ')
		{
			if (handle_command())
			{
				clear_arg();
				return;
			}
			if (arg[parg].length()>0)
				parg=(parg + 1) % max_arg;
			if (parg==0)
				clear_arg();
			return;
		}
	}

	String s(ch);
	s.toUpperCase();
	arg[parg]+=s;
}

void Application::handle_load_unload_parameters(const unsigned iarg,float& a_position, float& a_tohead_quickly, float& a_push, float& a_push_hair)
{
	a_position=stand_down_position_mm;
	a_tohead_quickly=extruder_tohead_quickly;
	a_push=extruder_push;
	a_push_hair=extruder_push_hair;

	for (unsigned a(iarg);a<parg;a++)
	{
		auto s=arg[a];
		char cc=s.c_str()[0];
		s=s.substring (1,s.length());
		if (cc=='D')
		{
			float t;
			if (toFloat(s,t))
				a_position = t;
		}
		if (cc=='P')
		{
			float t;
			if (toFloat(s,t))
				a_push = t;
		}
		if (cc=='H')
		{
			float t;
			if (toFloat(s,t))
				a_push_hair = t;
		}
		if (cc=='T')
		{
			float t;
			if (toFloat(s,t))
				a_tohead_quickly = t;
		}
	}
}

void (* resetFunc) (void) = 0;
bool Application::handle_command()
{
	if (arg[0]=="RESET")
	{
		new_command(1);
		comm().info ("Reset");

		m_settings.set_default();
		m_settings.save();

		delay (100);
		resetFunc();
		delay (100);

		comm().write (S_FAIL);
		return true;
	}
	if (arg[0]=="DISABLE")
	{
		if (parg < 1)
			return false;

		new_command(1);
		if (m_device.disable())
		{
			comm().write (S_OK);
		}
		else
		{
			comm().write (S_FAIL);
			m_device.disable();
		}
		return true;
	}
	if (arg[0]=="STAT")
	{	
		new_command(1);

		comm().send_c(F("Status:"));
		const char compile_date[] = __DATE__ " " __TIME__;
		comm().send_c(compile_date);

		comm().send_c(S_OK);
		comm().reset_answer();
		return true;
	}
	if (arg[0]=="T0" || arg[0]=="T1" || arg[0]=="T2" || arg[0]=="T3" || arg[0]=="T4" || arg[0]=="T5" || arg[0]=="T6" || arg[0]=="T7" || arg[0]=="T8")
	{
		int t_carriage_request;
		if (!toInt(arg[0].substring(1),t_carriage_request))
			return false;
		t_carriage_request++;

		new_command(1);

		m_device.set_carriage_request(t_carriage_request);

		return true;
	}
	if (arg[0]=="CUT")
	{
		if (parg < 1)
			return false;

		new_command(1);
		if (m_device.cut())
		{
			comm().write (S_OK);
		}
		else
		{
			comm().write (S_FAIL);
			m_device.disable();
		}
		return true;
	}
	if (arg[0]=="FEED")
	{
		if (parg < 2)
			return false;
		unsigned iarg(1);

		float t_length_mm;
		if (!toFloat(arg[iarg++],t_length_mm))
			return false;
		new_command(iarg);

		if (m_device.feed(t_length_mm))
		{
			comm().write (S_OK);
		}
		else
		{
			comm().write (S_FAIL);
			m_device.disable();
		}
		return true;
	}
	if (arg[0]=="FRONTIER")
	{
		if (parg < 1)
			return false;
		new_command(1);
		if (m_device.frontier())
		{
			comm().write (S_OK);
		}
		else
		{
			comm().write (S_FAIL);
			m_device.disable();
		}
		return true;
	}
	if (arg[0]=="TRASH")
	{
		if (parg < 1)
			return false;
		new_command(1);
		if (m_device.trash())
		{
			comm().write (S_OK);
		}
		else
		{
			comm().write (S_FAIL);
			m_device.disable();
		}
		return true;
	}
	if (arg[0]=="TRASHOUT")
	{
		if (parg < 1)
			return false;
		new_command(1);
		if (m_device.trash_out())
		{
			comm().write (S_OK);
		}
		else
		{
			comm().write (S_FAIL);
			m_device.disable();
		}
		return true;
	}
	if (arg[0]=="STAND")
	{
		if (parg < 2)
			return false;
		unsigned iarg(1);

		int t_position;
		if (!toInt(arg[iarg++],t_position))
			return false;
		new_command(iarg);
		bool res = t_position==0?m_device.stand_up():m_device.stand_down(stand_down_position_mm);
		if (res)
		{
			comm().write (S_OK);
		}
		else
		{
			comm().write (S_FAIL);
			m_device.disable();
		}
		return true;
	}
	if (arg[0]=="SELECT")
	{
		if (parg < 2)
			return false;
		unsigned iarg(1);

		int t_carriage_number;
		if (!toInt(arg[iarg++],t_carriage_number))
			return false;
		new_command(iarg);
		String t_error(F(ERROR_UNKNOWN));
		comm().write (m_device.select(t_error, t_carriage_number));
		comm().error (t_error.c_str());
		return true;
	}
	if (arg[0]=="LOAD")
	{
		if (parg < 1)
			return false;

		unsigned iarg(1);
		float t_position,t_tohead_quickly,t_push,t_push_hair;
		handle_load_unload_parameters(iarg,t_position,t_tohead_quickly, t_push,t_push_hair);

		if (m_device.loaded())
		{
			new_command_logic();
			comm().write (S_OK);
			return true;
		}

		new_command(1);
		String t_error(F(ERROR_UNKNOWN));
		comm().write (m_device.load(t_error, t_position, t_tohead_quickly));
		comm().error (t_error.c_str());
		return true;
	}
	if (arg[0]=="UNLOAD")
	{
		if (parg < 1)
			return false;

		unsigned iarg(1);
		float t_position,t_tohead_quickly,t_push,t_push_hair;
		handle_load_unload_parameters(iarg,t_position,t_tohead_quickly, t_push, t_push_hair);

		if (m_device.unloaded())
		{
			new_command_logic();
			comm().write (S_OK);
			return true;
		}

		new_command(1);
		String t_error(F(ERROR_UNKNOWN));
		comm().write (m_device.unload(t_error, t_position,t_push,t_push_hair));
		comm().error (t_error.c_str());
		return true;
	}
	if (arg[0]=="MOTION_CHECK")
	{
		if (parg < 2)
			return false;
		unsigned iarg(1);

		float t_length_mm;
		if (arg[iarg]=="N1")
		{
			t_length_mm = filamentencoder_N1;
			arg[iarg++];
		}
		else
		{
			if (!toFloat(arg[iarg++],t_length_mm))
				return false;
		}
		
		new_command(iarg);

		if (m_device.filament_encoder().value()>=t_length_mm)
		{
			comm().write (S_OK);
		}
		else
		{
			comm().write (S_FAIL);
			m_device.disable();
		}
		return true;
	}
	if (arg[0]=="MOTION_RESET")
	{
		if (parg < 1)
			return false;

		new_command(1);
		m_device.filament_encoder().reset();
		comm().write (S_OK);
		return true;
	}
	if (arg[0]=="MOTION_VALUE")
	{
		if (parg < 1)
			return false;

		new_command(1);
		comm().info (String(String(m_device.filament_encoder().value())+"mm ("+String(m_device.filament_encoder().value_tick())+" steps)").c_str());
		comm().write (S_OK);
		return true;
	}
	if (arg[0]=="VERIFY")
	{
		if (parg < 1)
			return false;

		new_command(1);
		if (m_device.verify_filament())
			comm().write (S_OK);
		else
		{
			m_device.disable();
			comm().write (S_FAIL);
		}
		return true;
	}

	return false;
}
