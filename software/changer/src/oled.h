#ifndef OLED_H
#define OLED_H

#include "U8glib.h"
#include "base.h"

struct sindicator
{
  bool digital_value;
  int analog_value;
  bool is_analog;
};

class oled: public base_indicator
{
private:
  U8GLIB_SH1106_128X64 u8g;
  bool repaint_needed;
  #define s_msg 4
  struct struct_msg{
    char      val[64];
    char      additional[64];
    unsigned  count;
    char      result[8];  
  } msg[s_msg];
  unsigned p_msg;
  char m_error[128];

  char m_ok[2];
  char m_fail[2];
  char m_true[2];
  char m_false[2];

  #define indicators_y 65
  #define s_indicators 16
  #define s_indicators_filament 1
  sindicator  m_indicators[s_indicators];

  float m_distance;

  unsigned long m_last_redraw;
  void redraw();
protected:
  virtual void draw_error();
  virtual void draw_indicators();
  virtual void draw_frame();
  virtual void draw_messages();
  virtual void draw() override;
public:
  oled();
  ~oled();

  virtual void set_state(const int a_index, const bool a_value) override;
  virtual void set_state(const int a_index, const bool a_value, const float a_analog) override;
  virtual void set_distance(const float a_value)  override;

  void setup();
  void loop();

  void print(const char* val);
  void print_additional(const char* a_add);
  void error(const char* val);
};

#endif
