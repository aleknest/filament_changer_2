#include "settings.h"
#include <EEPROM.h>
#include <Arduino.h>

unsigned long crc32b(const char *buf, const unsigned sz) 
{
   unsigned long crc = 0xFFFFFFFF;
   for (unsigned i(0);i<sz;i++)
   {
      unsigned long b = buf[i];            
      crc = crc ^ b;
      for (int j = 7; j >= 0; j--) 
      {    
         unsigned long mask = -(crc & 1);
         crc = (crc >> 1) ^ (0xEDB88320 & mask);
      }
   }
   return ~crc;
}

////////////////////////////////////////////////////////////////////////////////////

Settings::Settings()
{
  load();
}

void Settings::load()
{
  SSettings temp;
  byte* p ((byte*)&temp);
  int addr(0);
  for (unsigned i = 0; i < sizeof(SSettings); i++)
  {
    *p = EEPROM.read(addr);
    p++;addr++;
  }

  unsigned long crc_loaded (0);
  crc_loaded = crc_loaded | (unsigned long)EEPROM.read(addr++);
  crc_loaded = crc_loaded | (unsigned long)EEPROM.read(addr++) << 8;
  crc_loaded = crc_loaded | (unsigned long)EEPROM.read(addr++) << 16;
  crc_loaded = crc_loaded | (unsigned long)EEPROM.read(addr++) << 24;

  unsigned long crc_calculated (crc32b((const char*)&temp, sizeof(SSettings)));

  if (crc_loaded == crc_calculated)
  {
    settings = temp;
  }
  else
  {
    set_default();
  }
}

void Settings::save()
{
  byte* p ((byte*)&settings);
  int addr (0);
  for (unsigned i = 0; i < sizeof(SSettings); i++)
  {
    EEPROM.write(addr, *p);
    p++;
    addr++;
  }

  unsigned long crc_calculated (crc32b((const char*)&settings, sizeof(SSettings)));
  for (unsigned i(0); i<=3; i++)
  {
    EEPROM.write(addr, uint8_t(crc_calculated & 0xff));
    crc_calculated = crc_calculated >> 8;
    addr++;
  }
}

void Settings::set_default()
{
  settings.threshold = 960;
}

////////////////////////////////////////////////////////////////////////////////////
