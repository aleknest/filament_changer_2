#include "configuration.h"
#include <Arduino.h>
#ifdef OLED
#include "oled.h"
#endif

#ifndef DEBUG_H
#define DEBUG_H

void pgm_read_string (const __FlashStringHelper *ifsh, char* a_value);

class Communicator
{
private:
    #ifdef OLED
    oled m_display;
    #endif
    void respond();
    void char_received (char c);
public:
    Communicator();
    void setup();
    void loop();

    void reset_command_bufer();
    void reset_answer();

    const bool available() const;
    void write (const char* a_value);
    void write (const bool a_value);
    const char read();

    void info (const char* a_value);
    void error (const char* a_value);

	void send_c(const char* a_value);
	void send_c(const __FlashStringHelper *ifsh);
    void send_ci(const __FlashStringHelper *ifsh, const int i);
	void send_ci2(const __FlashStringHelper *ifsh, const int i1, const int i2);
	void send_ci3(const __FlashStringHelper *ifsh, const int i1, const int i2, const int i3);
	void send_cul(const __FlashStringHelper *ifsh, const unsigned long i);
	void send_cf(const __FlashStringHelper *ifsh, const float i);

    #ifdef OLED
    oled* display()
    {
        return &m_display;
    }
    #endif

};

Communicator& comm();

#endif