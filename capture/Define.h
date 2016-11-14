#ifndef DEFINE_H
#define DEFINE_H

enum {
	AM_CAPTUREMESSAGE = 6,
	TIMER_PERIOD_MILLI = 10,
	AM_SUCCESSMESSAGE = 0x89
};

enum {
	MSG_SETCOMMANDER = 0,
	MSG_SETCOMMANDER_RETURN = 1,
	MSG_ANNOUNCE = 2,
	MSG_ANNOUNCE_RETURN = 3,
	MSG_SEND_REQUEST = 4,
	MSG_SEND_RETURN = 5,
};

typedef nx_struct CaptureMessage {
	nx_uint16_t type;
	nx_uint16_t id1;
	nx_uint16_t id2;
	nx_uint16_t serialNo;
	nx_uint16_t rssi;
} CaptureMessage;

typedef nx_struct SuccessMessage {
	nx_uint16_t commander;
	nx_uint16_t nodeid1;
	nx_uint16_t nodeid2;
	nx_uint16_t stage;
	nx_uint16_t countcapture1;
	nx_uint16_t countcapture2;
	nx_uint16_t serialno;
	nx_uint16_t capture1;
	nx_uint16_t capture2;
} SuccessMessage;

#endif

