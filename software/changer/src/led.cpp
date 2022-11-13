#include "led.h"
#include <Arduino.h>

////////////////////////////////////////////////////////////////////////////////

Led::Led(int a_pin)
    : m_pin(a_pin)
    , m_value(false)
{
}

Led::~Led()
{

}

void Led::setup()
{
    pinMode(m_pin, OUTPUT);
    digitalWrite(m_pin, m_value ? HIGH : LOW);
}

void Led::setValue (const bool a_value)
{
    if (m_value==a_value)
        return;
    m_value = a_value;
    digitalWrite(m_pin, m_value ? HIGH : LOW);
}

////////////////////////////////////////////////////////////////////////////////

BuiltinLed::BuiltinLed()
    : Led(LED_BUILTIN)
{
}

BuiltinLed::~BuiltinLed()
{
}

////////////////////////////////////////////////////////////////////////////////
