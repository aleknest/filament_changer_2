#ifndef FILAMENT_ENCODER_H
#define FILAMENT_ENCODER_H

#include "configuration.h"
#include "base.h"

class FilamentEncoder
{
private:
    base_indicator* m_indicator;
public:
    FilamentEncoder();
    FilamentEncoder(base_indicator* a_indicator);
    ~FilamentEncoder();

    void setup();
    void reset();
    const unsigned long value_tick() const;
    const float value() const;
    virtual void loop();
};

#endif
