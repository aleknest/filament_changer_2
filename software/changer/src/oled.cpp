#include "oled.h"
#include "global.h"
#include <Arduino.h>

oled::oled()
  : base_indicator()
  , u8g(U8G_I2C_OPT_NONE)	// I2C / TWI 
  , repaint_needed(false)
  , p_msg(s_msg-1)
  , m_distance(0.0)
  , m_last_redraw(0)
{
  for (unsigned i(0);i<s_msg;i++)
  {
    msg[i].val[0]=0;
    msg[i].additional[0]=0;
    msg[i].result[0]=0;
  }
  m_ok[0]=163;
  m_ok[1]=0;
  m_fail[0]=162;
  m_fail[1]=0;
  m_true[0]=201;
  m_true[1]=0;
  m_false[0]=203;
  m_false[1]=0;

  for (unsigned i(0);i<s_indicators;i++)
  {
    m_indicators[i].digital_value=false;
    m_indicators[i].analog_value = 0;
    m_indicators[i].is_analog=false;
  }

  m_error[0]=0;
}

oled::~oled()
{
}

void oled::setup()
{
  //u8g.setRot180();
  if ( u8g.getMode() == U8G_MODE_R3G3B2 ) 
    u8g.setColorIndex(255);     // white
  else if ( u8g.getMode() == U8G_MODE_GRAY2BIT )
    u8g.setColorIndex(3);         // max intensity
  else if ( u8g.getMode() == U8G_MODE_BW )
    u8g.setColorIndex(1);         // pixel on
  else if ( u8g.getMode() == U8G_MODE_HICOLOR )
    u8g.setHiColorByRGB(255,255,255);
  repaint_needed=true;
}

void oled::loop()
{
  if (repaint_needed)
  {
    u8g.firstPage();  
    do 
    {
      draw();
    } while( u8g.nextPage() );
    repaint_needed=false;
  }
}

void oled::redraw()
{
  repaint_needed=true;
  loop();
}

const int gr1=57;
const int gr2=42;

void oled::draw_frame()
{
  u8g.setColorIndex(1);
  u8g.drawFrame(0, 0, 128, gr1);
  u8g.drawFrame(0, gr2, 128, gr1);
  u8g.drawBox(0, gr1, 128, 64);
}

void oled::draw_error()
{
  u8g.setColorIndex(1);
  u8g.setFont(u8g_font_chikita);
  u8g.drawStr( 4, gr2+10, m_error);
}

void oled::draw_messages()
{
  const int ystart=10;
  const int ydiff=10;
  const int xx_message(4);
  const int xx_count(108);
  const int xx_result(114);

  u8g.setColorIndex(1);
  u8g.setFont(u8g_font_chikita);
  for (int y=0;y<s_msg;y++)
  {
    auto p=(p_msg+y+1)%s_msg;
    int yy=ystart+y*ydiff;
    String val(msg[p].val);
    if (msg[p].additional[0]!=0)
    {
      val+="(";
      val+=msg[p].additional;
      val+=")";
    }
    val.toUpperCase();

    u8g.drawStr( xx_message, yy, val.c_str());

    if (msg[p].count>1)
    {
      String count = msg[p].count>9?"*":String(msg[p].count);
      u8g.drawStr( xx_count, yy, count.c_str());
    }
  }

  u8g.setColorIndex(1);
  u8g.setFont(u8g_font_10x20_67_75);
  for (int y=0;y<s_msg;y++)
  {
    auto p=(p_msg+y+1)%s_msg;
    int yy=ystart+y*ydiff+1;

    if ((strcmp(msg[p].result,S_OK)==0))
      u8g.drawStr( xx_result, yy, m_ok);
    if ((strcmp(msg[p].result,S_FAIL)==0))
      u8g.drawStr( xx_result, yy, m_fail);    
  }
}

void oled::draw_indicators()
{

  int xx;
  const int letters_diff(-3);
  const int num_diff(-3);

  xx=2;

  u8g.setColorIndex(0);
  for (unsigned i(0);i<s_indicators_filament;i++)
  {
    u8g.setFont(u8g_font_10x20_67_75);
    if (m_indicators[i].digital_value)
      u8g.drawStr(xx, indicators_y, m_true);
    else
      u8g.drawStr(xx, indicators_y, m_false);
    xx+=10;

    if (m_indicators[i].is_analog)
    {
      xx+=1;
      u8g.setFont(u8g_font_chikita);
      String s(String(m_indicators[i].analog_value));
      u8g.drawStr(xx, indicators_y+num_diff, s.c_str());
      xx+=20;
    }
  }
  xx=32;
  u8g.setFont(u8g_font_10x20_67_75);
  for (int i(s_indicators_filament);i<s_indicators_filament+5;i++)
  {
    if (m_indicators[i].digital_value)
      u8g.drawStr(xx, indicators_y, m_true);
    else
      u8g.drawStr(xx, indicators_y, m_false);
    xx+=9;
  }

  xx=80;
  u8g.setFont(u8g_font_chikita);
  String d(m_distance);
  u8g.drawStr( xx, indicators_y+letters_diff, d.c_str());
}

void oled::draw() 
{
  draw_frame();
  draw_messages();
  draw_error();
  draw_indicators();
  m_last_redraw=millis();
}

void oled::error(const char* val)
{
  strcpy (m_error,val);
  redraw();
}

void oled::print_additional(const char* a_add)
{
  char t_add[64];
  strcpy (t_add,a_add);
  for (int i(strlen(t_add)-1);i!=0;i--)
    if ((t_add[i]==13)||(t_add[i]==10))
      t_add[i]=0;
    else
      break;

  strcpy(msg[p_msg].additional,t_add);
  redraw();
}

void oled::print(const char* val)
{   
  char t_val[64];
  strcpy (t_val,val);
  for (int i(strlen(t_val)-1);i!=0;i--)
    if ((t_val[i]==13)||(t_val[i]==10))
      t_val[i]=0;
    else
      break;

  char* prev;
  if ((strcmp(t_val,S_OK)==0)||(strcmp(t_val,S_FAIL)==0))
  {
    prev=msg[p_msg].result;
  }
  else
  {
    if (strcmp(msg[p_msg].val,t_val)==0)
    {
      msg[p_msg].result[0]=0;
      msg[p_msg].additional[0]=0;
      msg[p_msg].count++;
      prev = msg[p_msg].val;
    }
    else
    {
      p_msg=(p_msg+1)% s_msg;
      prev = msg[p_msg].val;
      msg[p_msg].result[0]=0;
      msg[p_msg].additional[0]=0;
      msg[p_msg].count=1;
    }
  }
  strcpy(prev,t_val);

  redraw();
}

void oled::set_state(const int a_index, const bool a_value)
{
  if (m_indicators[a_index].digital_value==a_value)
    return;

  m_indicators[a_index].digital_value=a_value;
  m_indicators[a_index].analog_value = 0;
  m_indicators[a_index].is_analog=false;

  redraw();
}

void oled::set_state(const int a_index, const bool a_value, const float a_analog)
{
  int a=round(a_analog);
  bool strong=m_indicators[a_index].digital_value!=a_value;
  if ((!strong)&&(m_indicators[a_index].analog_value==a))
    return;

  m_indicators[a_index].digital_value=a_value;
  m_indicators[a_index].analog_value = a;
  m_indicators[a_index].is_analog=true;

  if (strong)
    redraw();
  else
    repaint_needed=true;
}

void oled::set_distance(const float a_value)
{
  if (m_distance==a_value)
    return;
  m_distance=a_value;
  redraw();
}
