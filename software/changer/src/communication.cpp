#include "communication.h"
#include <Wire.h>
#include <SoftwareSerial.h>

////////////////////////////////////////////////////////////////////////////////////

char			  cmd_buf[CMD_BUF_SIZE];
volatile unsigned cmd_buf_w = 0;
volatile unsigned cmd_buf_r = 0;

#if (I2C_CLIENT > 0)
    char			  answer_buf[ANSWER_BUF_SIZE];
    volatile unsigned answer_buf_w = 0;
    volatile unsigned answer_buf_r = 0;
#endif

char m_answer[64];
unsigned long m_answer_time;
int m_answer_count;

#ifdef UART_COMMUNICATION
    #ifdef FCSERIAL
        #define COMM_SERIAL FCSERIAL
    #else
        SoftwareSerial software_serial1(FCSERIAL_SOFTWARE_RX, FCSERIAL_SOFTWARE_TX);
        #define COMM_SERIAL software_serial1
    #endif
#endif

#ifdef UART_INFO
    #ifdef INFOSERIAL
        #define INFO_SERIAL INFOSERIAL
    #else
        SoftwareSerial software_serial2(INFOSERIAL_SOFTWARE_RX, INFOSERIAL_SOFTWARE_TX);
        #define INFO_SERIAL software_serial2
    #endif
#endif

void pgm_read_string (const __FlashStringHelper *ifsh, char* a_value)
{
  PGM_P p = reinterpret_cast<PGM_P>(ifsh);
  while (1) 
  {
    unsigned char c = pgm_read_byte(p++);
    if (c == 0) 
		break;
	*a_value = c;
	a_value++;
	*a_value = 0;
  }
}

Communicator::Communicator()
{
}

void Communicator::setup()
{
    #ifdef UART_COMMUNICATION
        COMM_SERIAL.begin(FCSERIAL_BAUD_RATE);
    #endif
    #ifdef UART_INFO
        INFO_SERIAL.begin(INFOSERIAL_BAUD_RATE);
    #endif

    #ifdef UART_INFO
    while (INFO_SERIAL.available())
        INFO_SERIAL.read ();
    #endif

    #ifdef OLED
    m_display.setup();
    m_display.print("Started...");
    #endif
    write(S_OK);
}

void Communicator::char_received (char c)
{
    #ifdef UART_INFO
    if (c!=0)
       INFO_SERIAL.print(c);
    #endif
}

void Communicator::loop()
{
    char c(0);
    #ifdef UART_COMMUNICATION
    while (COMM_SERIAL.available())
    {
        c = COMM_SERIAL.read ();
    	cmd_buf[cmd_buf_w] = c;
		cmd_buf_w = (cmd_buf_w + 1) % CMD_BUF_SIZE;
        char_received (c);
    }
    #endif
    #ifdef UART_INFO
    while (INFO_SERIAL.available())
    {
        c = INFO_SERIAL.read ();
    	cmd_buf[cmd_buf_w] = c;
		cmd_buf_w = (cmd_buf_w + 1) % CMD_BUF_SIZE;
        char_received (c);
    }
    #endif

    respond ();

    #ifdef OLED
    m_display.loop();
    #endif
}

const bool Communicator::available() const
{
    return cmd_buf_w != cmd_buf_r;
}

const char Communicator::read()
{
    if (!available())
        return 0;

    char ret = cmd_buf[cmd_buf_r];
	cmd_buf_r = (cmd_buf_r + 1) % CMD_BUF_SIZE;
    return ret;
}

void Communicator::reset_command_bufer()
{
    cmd_buf_w = 0;
    cmd_buf_r = 0;
}

void Communicator::reset_answer()
{
    m_answer[0] = 0;
    m_answer_time=0;
    m_answer_count=0;
}

void Communicator::write (const bool a_value)
{
    if (a_value)
		write (S_OK);
	else
		write (S_FAIL);
}

void Communicator::write (const char* a_value)
{
    if (a_value[0]!=0)
    {
        strcpy(m_answer,a_value);
        m_answer_time = -1;
        m_answer_count = 1;
        respond ();
    }
}

void Communicator::error (const char* a_value)
{
    #ifdef OLED
    m_display.error(a_value);
    #endif
}
void Communicator::info (const char* a_value)
{
    #ifdef UART_INFO
    INFO_SERIAL.println(a_value);
    INFO_SERIAL.flush();
    #endif
    #ifdef OLED
    m_display.print(a_value);
    #endif
}

void Communicator::respond ()
{
    if (m_answer[0]!=0)
    {
        unsigned long t_time (millis());
        if ((t_time-m_answer_time > REPEAT_ANSWER_INTERVAL) && (m_answer_count<REPEAT_ANSWER_COUNT))
        {
            m_answer_count++;
            m_answer_time = t_time;
            #ifdef UART_COMMUNICATION
            COMM_SERIAL.print(m_answer);
            COMM_SERIAL.flush();
            #endif
            info (m_answer);
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////

void Communicator::send_ci(const __FlashStringHelper *ifsh, const int i)
{
	char t_msg[ANSWER_BUF_SIZE];
	pgm_read_string (ifsh,t_msg);
	itoa(i,&t_msg[strlen(t_msg)],10);
	comm().write (t_msg);
}

void Communicator::send_ci2(const __FlashStringHelper *ifsh, const int i1, const int i2)
{
	int t_len;
	char t_msg[ANSWER_BUF_SIZE];
	pgm_read_string (ifsh,t_msg);
	t_len=strlen(t_msg);
	itoa(i1,&t_msg[t_len],10);
	t_len=strlen(t_msg);t_msg[t_len++] = ',';t_msg[t_len] = 0;
	itoa(i2,&t_msg[t_len],10);
	comm().write (t_msg);
}

void Communicator::send_ci3(const __FlashStringHelper *ifsh, const int i1, const int i2, const int i3)
{
	int t_len;
	char t_msg[ANSWER_BUF_SIZE];
	pgm_read_string (ifsh,t_msg);
	t_len=strlen(t_msg);
	itoa(i1,&t_msg[t_len],10);
	t_len=strlen(t_msg);t_msg[t_len++] = ',';t_msg[t_len] = 0;
	itoa(i2,&t_msg[t_len],10);
	t_len=strlen(t_msg);
	t_len=strlen(t_msg);t_msg[t_len++] = ',';t_msg[t_len] = 0;
	itoa(i3,&t_msg[t_len],10);
	comm().write (t_msg);
}

void Communicator::send_cul(const __FlashStringHelper *ifsh, const unsigned long i)
{
	char t_msg[ANSWER_BUF_SIZE];
	pgm_read_string (ifsh,t_msg);
	itoa(i,&t_msg[strlen(t_msg)],10);
	comm().write (t_msg);
}

void Communicator::send_cf(const __FlashStringHelper *ifsh, const float i)
{
	char t_msg[ANSWER_BUF_SIZE];
	pgm_read_string (ifsh,t_msg);
	const int decimalPlaces (2);
	dtostrf(i, (decimalPlaces + 2), decimalPlaces, &t_msg[strlen(t_msg)]);
	comm().write (t_msg);
}

void Communicator::send_c(const char* a_value)
{
	comm().write (a_value);
}

void Communicator::send_c(const __FlashStringHelper *ifsh)
{
	char t_msg[ANSWER_BUF_SIZE];
	pgm_read_string (ifsh,t_msg);
	comm().write (t_msg);
}

////////////////////////////////////////////////////////////////////////////////////

Communicator g_communicator;
Communicator& comm()
{
    return g_communicator;
}

////////////////////////////////////////////////////////////////////////////////////

