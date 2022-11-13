#ifndef PINS_H
#define PINS_H

#define BOARD_RAMPS              1
#define BOARD_CNC_SHIELD_NANO    2
#define BOARD_CNC_SHIELD_UNO     3
#define BOARD_MEGA_LCD           4
#define BOARD_CNC_SHIELD_NANO168 5

/////////// RAMPS 1.4 ///////////////
#define RAMPS_ENDSTOP_X_MIN 3
#define RAMPS_ENDSTOP_X_MAX 2
#define RAMPS_ENDSTOP_Y_MIN 14
#define RAMPS_ENDSTOP_Y_MAX 15
#define RAMPS_ENDSTOP_Z_MIN 18
#define RAMPS_ENDSTOP_Z_MAX 19
// dir, step, enable
#define RAMPS_X_AXIS  {A1, A0, 38}
#define RAMPS_Y_AXIS  {A7, A6, A2}
#define RAMPS_Z_AXIS  {48, 46, A8}
#define RAMPS_E0_AXIS {28, 26, 24}
#define RAMPS_E1_AXIS {34, 36, 30}

#define I2C_SCL 21
#define I2C_SDA 20

#define AUX1_D0 0
#define AUX1_D1 1
#define AUX1_A3 A3
#define AUX1_A4 A4
/*
///////// CNC SHIELD NANO ////////////
#define CNCSHIELD_NANO_ENDSTOP_X    9
#define CNCSHIELD_NANO_ENDSTOP_Y    10
#define CNCSHIELD_NANO_ENDSTOP_Z    11
#define CNCSHIELD_NANO_ENDSTOP_D12  12
#define CNCSHIELD_NANO_ENDSTOP_D13  13
#define CNCSHIELD_NANO_CoolEn       A3
#define CNCSHIELD_NANO_Resume       A2
#define CNCSHIELD_NANO_Hold         A1
#define CNCSHIELD_NANO_Abort        A0
#define CNCSHIELD_NANO_SDA          A4
#define CNCSHIELD_NANO_SCL          A5
#define CNCSHIELD_NANO_ANALOG_1     A7
// dir, step, enable
#define CNCSHIELD_NANO_X_AXIS {2, 5, -1}
#define CNCSHIELD_NANO_Y_AXIS {3, 6, -1}
#define CNCSHIELD_NANO_Z_AXIS {4, 7, -1}
#define CNCSHIELD_NANO_ENABLE_PIN   8

///////// CNC SHIELD UNO ////////////
#define CNCSHIELD_UNO_ENDSTOP_X    9
#define CNCSHIELD_UNO_ENDSTOP_Y    10
#define CNCSHIELD_UNO_ENDSTOP_Z    11
#define CNCSHIELD_UNO_ENDSTOP_D12  12
#define CNCSHIELD_UNO_ENDSTOP_D13  13
#define CNCSHIELD_UNO_Abort        A0
#define CNCSHIELD_UNO_Hold         A1
#define CNCSHIELD_UNO_Resume       A2
#define CNCSHIELD_UNO_CoolEn       A3
// dir, step, enable
#define CNCSHIELD_UNO_X_AXIS {5, 2, -1}
#define CNCSHIELD_UNO_Y_AXIS {6, 3, -1}
#define CNCSHIELD_UNO_Z_AXIS {7, 4, -1}
#define CNCSHIELD_UNO_ENABLE_PIN   8
*/

#endif