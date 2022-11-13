#ifndef FILAMENT_ENCODER_H
#define FILAMENT_ENCODER_H

#define filamentencoder_pin         2 // must be interrupt pin
#define filamentencoder_steps_permm 14.4

class FilamentEncoder
{
public:
    FilamentEncoder();
    ~FilamentEncoder();

    void setup();
    void reset();
    const unsigned long value_tick() const;
    const float value() const;
};

#endif
