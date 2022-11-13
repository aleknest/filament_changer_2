// проверь запоминание номера каретки
// verify filament в unload
#include "pins.h"
#include "global.h"

#ifndef CONFIGURATION_H
#define CONFIGURATION_H

#define BOARD BOARD_RAMPS

//*************************************************************************************************
// BOARDS
//*************************************************************************************************

#if (BOARD == BOARD_RAMPS)
  #define UART_COMMUNICATION
  #define UART_INFO

  #define pin_enable_mixed              -1

  #define _FCSERIAL_SOFTWARE_TX         16
  #define _FCSERIAL_SOFTWARE_RX         17

  #define _INFOSERIAL_SOFTWARE_TX       16
  #define _INFOSERIAL_SOFTWARE_RX       17

  #define pin_cutter_endstop            52
  #define pins_cutter_motor             RAMPS_E0_AXIS

  #define pin_stand_filament_sensor     RAMPS_ENDSTOP_X_MIN//AUX1_A3
  
  #define pins_extruder_motor           RAMPS_X_AXIS

  #define pin_selector_endstop          RAMPS_ENDSTOP_Y_MIN
  #define pin_selector_marker_endstop   RAMPS_ENDSTOP_X_MAX
  #define pins_selector_motor           RAMPS_Z_AXIS

  #define pin_stand_endstop             RAMPS_ENDSTOP_Y_MAX
  #define pins_stand_motor              RAMPS_Y_AXIS

  #define pins_frontier_motor           RAMPS_E1_AXIS
  #define pin_frontier_endstop          RAMPS_ENDSTOP_Z_MAX

  #define filamentencoder_pin           RAMPS_ENDSTOP_Z_MIN // must be interrupt pin

  #define OLED
#endif

#define CMD_BUF_SIZE 32
#define ANSWER_BUF_SIZE 128

//*************************************************************************************************
// GLOBAL
//*************************************************************************************************

#define motors_hold_timeout (unsigned long)1000*60*60*12

//*************************************************************************************************
// Communications
//*************************************************************************************************
#define REPEAT_ANSWER_INTERVAL 2000
#define REPEAT_ANSWER_COUNT 10

#ifdef UART_COMMUNICATION
  #define FCSERIAL_BAUD_RATE  2400
  #define FCSERIAL            Serial2
  #ifndef FCSERIAL
    #define FCSERIAL_SOFTWARE_TX  _FCSERIAL_SOFTWARE_TX
    #define FCSERIAL_SOFTWARE_RX  _FCSERIAL_SOFTWARE_RX
  #endif
#endif

#ifdef UART_INFO
  #define INFOSERIAL_BAUD_RATE  9600
  #define SOFTINFOSERIAL        false
  #if SOFTINFOSERIAL
    #define INFOSERIAL_SOFTWARE_TX  _INFOSERIAL_SOFTWARE_TX
    #define INFOSERIAL_SOFTWARE_RX  _INFOSERIAL_SOFTWARE_RX
  #else
    #ifndef INFOSERIAL
      #define INFOSERIAL            Serial
    #endif
  #endif
#endif


//*************************************************************************************************
// Cutter
//*************************************************************************************************
#define cutter_motor_delay_min 100//100
#define cutter_motor_delay_max 100//200
#define cutter_motor_delay_sub 20
#define cutter_step_size THIRTYTWO_STEP
#define cutter_steps_per 1*3
#define cutter_motor_sensor_timeout (unsigned long)20000
#define cutter_max_angle (unsigned long)900*cutter_step_size
#define cutter_return_angle (unsigned long)430*cutter_step_size
#define cutter_fail_angle cutter_max_angle/5
#define cutter_home_position 10*cutter_step_size
#define cutter_motor_bump 1.0//0.5
#define cutter_motor_bump_move 200*cutter_step_size

//*************************************************************************************************
// Extruder
//*************************************************************************************************

#define extruder_step_size SIXTEENTH_STEP
#define extruder_steps_permm  1900/extruder_step_size
#define extruder_motor_delay_speed 150
#define extruder_motor_delay_min  400
#define extruder_motor_delay_max  400
#define extruder_motor_delay_sub  40

#define extruder_tostand 100
#define extruder_tocutter 30
#define extruder_cutdistance 23//20,25
#define extruder_push 65.0
#define extruder_push_hair 150
#define extruder_tofrontier 80

#define extruder_tohead_quickly 240
#define extruder_tohead 80
#define extruder_fromhead_togear 10
#define extruder_fromhead_quickly 280

#define extruder_frontier_in 200
#define extruder_fromfrontier 200
#define extruder_fromcutter_tostandsensor 16//50
#define extruder_fromtostandsensor_tostandout 26

//*************************************************************************************************
// Selector
//*************************************************************************************************
#define selector_motor_delay_min 150//200
#define selector_motor_delay_max 350//400
#define selector_motor_delay_sub 60
#define selector_motor_bump   1
#define selector_motor_bump_move 6
#define selector_step_size SIXTEENTH_STEP
#define selector_steps_permm (unsigned long)5*selector_step_size
#define selector_limit_mm 320
#define selector_home_position_mm 10
#define selector_motor_sensor_timeout (unsigned long)20000

#define selector_probe_max 2
#define selector_probe_offsetmm 0//0.8

//*************************************************************************************************
// Stand
//*************************************************************************************************
#define stand_motor_delay_min 100
#define stand_motor_delay_max 60
#define stand_motor_delay_sub 10
#define stand_motor_bump   1
#define stand_motor_bump_move 3
#define stand_step_size SIXTEENTH_STEP
#define stand_steps_permm (unsigned long)25*selector_step_size

#define stand_limit_mm 25
#define stand_home_position_mm 0
#define stand_motor_sensor_timeout (unsigned long)20000

#define stand_up_position_mm 0
#define stand_down_position_mm 15.1//15.3

//*************************************************************************************************
// Frontier
//*************************************************************************************************
#define frontier_motor_delay_min 80
#define frontier_motor_delay_max 80
#define frontier_motor_delay_sub 40
#define frontier_motor_bump   1
#define frontier_motor_bump_move 3
#define frontier_step_size THIRTYTWO_STEP
#define frontier_steps_permm (unsigned long)25*frontier_step_size

#define frontier_limit_mm 100
#define frontier_home_position_mm 0
#define frontier_motor_sensor_timeout (unsigned long)10000

#define frontier_frontier_position_mm 45+frontier_home_position_mm
#define frontier_thrash_position_mm 22+frontier_home_position_mm
#define frontier_frontiermax_position_mm 65+frontier_home_position_mm
#define frontier_thrashout_position_mm 0

//*************************************************************************************************
// Filament encoder
//*************************************************************************************************

#define filamentencoder_steps_permm 1.57
//4.33,628 - 400mm
//(360/1.8*16)/(7*3.14) = 145

#define filamentencoder_extruder_tohead 50
#define filamentencoder_N1 15

//*************************************************************************************************

#endif

