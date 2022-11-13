#ifndef LED_H
#define LED_H

class Led
{
private:
    int  m_pin;
    bool m_value;
public:
    Led(int a_pin);
    ~Led();

    void setup();
    void setValue (const bool a_value);
};

class BuiltinLed: public Led
{
public:
    BuiltinLed();
    ~BuiltinLed();
};

#endif