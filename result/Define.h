 #ifndef DEFINE_H
 #define DEFINE_H
 
 enum {
   AM_CAPTUREMESSAGE = 6,
   TIMER_PERIOD_MILLI = 10,
   AM_SUCCESSMESSAGE = 0x89
 };

 enum {
	 MSG_REQUEST = 0,
	 MSG_RETURN = 1,
 };

 typedef nx_struct CaptureMessage {
	 nx_uint16_t type;
         nx_uint16_t id;
         nx_uint16_t channel;
 } CaptureMessage;

 typedef nx_struct SuccessMessage {
	 nx_uint16_t id;
	 nx_uint16_t cnt;
 } SuccessMessage;

 #endif
 
