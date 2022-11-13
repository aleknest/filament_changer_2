#include <Arduino.h>

#define in_pins_size 5
constexpr int in_pins[in_pins_size] = {2,3,4,5,6};
uint8_t in_state (0);
uint8_t in_prev(0);
uint8_t in_mask(B11111111);

uint8_t out_mask(B00110000);//D12,D13
uint8_t out_state(out_mask);

void setup(void) 
{
  DDRB = out_mask; 
  PORTB = out_state;

  for (unsigned i(0);i<in_pins_size;i++)
    in_mask ^= 1 << in_pins[i];
  DDRD = in_mask;
}

void loop(void) 
{
  in_prev = in_state;
  in_state = PIND;
  if (in_prev!=in_state)
  {
    out_state=out_state==0?out_mask:0;
    PORTB = out_state;
  }
}