#include <Arduino.h>
#include "application.h"
#include "settings.h"

#include "oled/gfx.h"
#include "oled/dspl1306.h"

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
Adafruit_SSD1306 dspl(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

#include "GyverEncoder.h"
Encoder enc1(3, 2);
int count(0);

Settings g_settings;

int g_counter(0);
 
#define FASTADC 1

// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

Application::Application()
	: m_counter(-1)
	, m_prev(0)
	, m_repaint_needed(true)
	, m_threshold(-1)
	, m_last_value(-1)
{
	m_filament_sensor.set_threshold(g_settings.settings.threshold);
	m_value = m_filament_sensor.value();
}

void Application::setup()
{
	pinMode(out_pin, OUTPUT);
 	m_filament_sensor.setup();

	dspl.begin(SSD1306_SWITCHCAPVCC,0x3C);
	dspl.setTextColor(WHITE);

	pinMode (2,INPUT);
	pinMode (3,INPUT);

	#if FASTADC
	// set prescale to 16
	sbi(ADCSRA,ADPS2) ;
	cbi(ADCSRA,ADPS1) ;
	cbi(ADCSRA,ADPS0) ;
	#endif

	/*
	int start ;
	int i ;
	Serial.begin(9600) ;
	Serial.print("ADCTEST: ") ;
	start = millis() ;
	for (i = 0 ; i < 30000 ; i++)
	analogRead(0) ;
	Serial.print(float(millis() - start)/30000*1000) ;
	*/
}

void Application::loop()
{
	enc1.tick();
 	if (enc1.isRight()) 
	  count++;
  	if (enc1.isLeft()) 
	  count--;

	int cnt(0);
	const int gr(4);
	if (count==gr)
	{
		cnt=1;
		count=0;
	}
	if (count==-gr)
	{
		cnt=-1;
		count=0;
	}

	if (cnt != 0)
	{
		int i=m_filament_sensor.threshold()+cnt;
		if (i<0)
			i=0;
		if (i>1023)
			i=1023;
		m_filament_sensor.set_threshold(i);
		g_settings.settings.threshold = i;
		g_settings.save();
	}

	m_filament_sensor.loop();
	unsigned long m(millis());
	bool t_value(m_filament_sensor.value());
	int t_last_value(m_filament_sensor.last_value());
	int t_threshold(m_filament_sensor.threshold());

	digitalWrite(out_pin, t_value?HIGH:LOW);

	if (t_value!=m_value)
	{
	    if (t_value)
			g_counter++;
		m_value = t_value;
	}

	m_repaint_needed = m_repaint_needed || t_threshold!=m_threshold || t_last_value!=m_last_value || t_value!=m_value || m_counter!=g_counter;

	if (m_repaint_needed && ((m-m_prev)>500))
	{
		dspl.clearDisplay();

		dspl.setTextSize(1);
		dspl.setCursor(4,1);
		dspl.print(g_counter);

		dspl.setTextSize(2);
		dspl.setCursor(78,1);
		dspl.print(t_threshold);
		//dspl.print(8888);

		const int x=6;
		const int y=21;
		dspl.setTextSize(5);
		dspl.setCursor(x,y);
		dspl.print(t_last_value);
		//dspl.print(8888);
		if (t_value)
			dspl.fillRect(0, 0, dspl.width() , dspl.height(), SSD1306_INVERSE);

		dspl.display();

		m_counter = g_counter;
		m_threshold = t_threshold;
		m_last_value = t_last_value;
		m_repaint_needed = false;
		m_prev = m;
	}
}
