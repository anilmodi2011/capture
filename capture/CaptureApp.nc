 #include <Timer.h>
 #include "Define.h"
 
 configuration CaptureApp {
 }
 implementation {
   components MainC;
   components LedsC;
   components Capture as App;
   components new TimerMilliC() as Timer0;
   components new TimerMilliC() as Timer1;
   components new TimerMilliC() as Timer2;
   components ActiveMessageC;
   components new AMSenderC(AM_CAPTUREMESSAGE);
   components new AMReceiverC(AM_CAPTUREMESSAGE);
   components CC2420ActiveMessageC;
   components CC2420ControlC;

   components SerialActiveMessageC as Radio;
   
   App.Boot -> MainC;
   App.Leds -> LedsC;
   App.Timer0 -> Timer0;
   App.Timer1 -> Timer1;
   App.Timer2 -> Timer2;
   App.RadioPacket -> AMSenderC;
   App.RadioAMPacket -> AMSenderC;
   App.RadioAMSend -> AMSenderC;
   App.RadioControl -> ActiveMessageC;
   App.RadioReceive -> AMReceiverC;
   App.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;
   App.CC2420Config -> CC2420ControlC;

   App.SerialReceive -> Radio.Receive[AM_SUCCESSMESSAGE];
   App.SerialAMSend -> Radio.AMSend[AM_SUCCESSMESSAGE];
   App.SerialControl -> Radio;
   App.SerialPacket -> Radio;
 }
 
