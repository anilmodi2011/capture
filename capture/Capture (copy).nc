 #include <Timer.h>
 #include <stdlib.h>
 #include "../Define.h"
 
 module Capture {
   uses interface Boot;
   uses interface Leds;
   uses interface Timer<TMilli> as Timer0;
   uses interface Timer<TMilli> as Timer1;
   uses interface Timer<TMilli> as Timer2;

   uses interface Packet as RadioPacket;
   uses interface AMPacket as RadioAMPacket;
   uses interface AMSend as RadioAMSend;
   uses interface Receive as RadioReceive;
   uses interface SplitControl as RadioControl;

   uses interface Packet as SerialPacket;
   uses interface AMPacket as SerialAMPacket;
   uses interface AMSend as SerialAMSend;
   uses interface Receive as SerialReceive;
   uses interface SplitControl as SerialControl;

   uses interface CC2420Config;
 }
 implementation {
   uint16_t NUM_REPEAT = 100;
   uint16_t NODE_START = 9;
   uint16_t NODE_END = 37;

   enum {
     MODE_NODE = 0,
     MODE_PREPROCESS = 1,
     MODE_CALCQUALITY = 2,
     MODE_WATING1 = 3,
     MODE_MAINREQUEST = 4,
     MODE_WATING2 = 5,
     MODE_PRINT = 6,
   };

   uint16_t commander = -1;

   uint16_t mode = 0;
   uint16_t nodes[150] = {0, };
   uint8_t quality[150] = {0, };
   uint8_t capture[90][90] = {{0,}, };
   uint16_t nodeCount = 0;
   uint16_t eventCount = 0;
   uint16_t messageCount1 = 0;
   uint16_t messageCount2 = 0;
   uint16_t messageCount3 = 0;

   bool busy = FALSE;
   message_t pkt;
 
   event void Boot.booted() {
     call SerialControl.start();
     call RadioControl.start();
   }

   event void RadioControl.startDone(error_t err) {
     if (err == SUCCESS) {
       call CC2420Config.setChannel(20);
       call CC2420Config.sync();
     }
     else {
       call RadioControl.start();
     }
   }

   event void SerialControl.startDone(error_t err) {
     if (err == SUCCESS) {
     }
     else {
       call RadioControl.start();
     }
   }

   event void CC2420Config.syncDone( error_t err ) {
     if (err == SUCCESS) {
       if(TOS_NODE_ID == NODE_START){
         mode = MODE_PREPROCESS;
         commander = NODE_START;

         call Timer0.startPeriodic(5000);
         call Leds.set(1);
       }
     }
     else {
       call CC2420Config.sync();
     }
   }
 
   event void Timer0.fired() {
       if(mode == MODE_PREPROCESS){
         messageCount1 = 0;
         messageCount2 = 0;
         call Timer0.stop();
         call Timer1.startPeriodic(30);
       }
       else if(mode == MODE_WATING1){
         mode = MODE_MAINREQUEST;
         messageCount1 = 1;
         messageCount2 = 0;
         messageCount3 = 0;
         call Timer0.stop();
         call Timer1.startPeriodic(TIMER_PERIOD_MILLI);
       }
       else if(mode == MODE_WATING2){
         mode = MODE_PRINT;
         messageCount1 = 1;
         messageCount2 = 0;
         messageCount3 = 0;
         call Timer0.stop();
         call Timer1.startPeriodic(100);
       }
   }

   event void Timer1.fired() {
     if (!busy) {
       if(mode == MODE_PREPROCESS){
         CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
         m->type = MSG_ANNOUNCE;
         m->id1 = TOS_NODE_ID;
         call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage));
       }
       else if(mode == MODE_CALCQUALITY){
         CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
         btrpkt->type = MSG_TEST_REQUEST;
         btrpkt->id1 = nodes[messageCount1];
         if (call RadioAMSend.send(nodes[messageCount1], &pkt, sizeof(CaptureMessage)) == SUCCESS) {
           busy = TRUE;
         }
       }
       else if(mode == MODE_MAINREQUEST){
         CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
         btrpkt->type = MSG_TEST_REQUEST;
         btrpkt->id1 = nodes[messageCount1];
         btrpkt->id2 = nodes[messageCount2];
         if (call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage)) == SUCCESS) {
           busy = TRUE;
         }
       }
       else if(mode == MODE_PRINT){
         SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
         btrpkt->commander = commander;
         btrpkt->nodeid1 = nodes[messageCount2];
         btrpkt->nodeid2 = nodes[messageCount1];
         btrpkt->quality1 = quality[nodes[messageCount2]];
         btrpkt->quality2 = quality[nodes[messageCount1]];
         btrpkt->result1 = capture[nodes[messageCount2]][nodes[messageCount1]];
         btrpkt->result2 = capture[nodes[messageCount1]][nodes[messageCount2]];

         if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
           busy = TRUE;
         }
       }
     }
   }

   event void Timer2.fired() {
     if(busy == FALSE){
       CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
       m->type = MSG_ANNOUNCE_RETURN;
       m->id1 = TOS_NODE_ID;
       call RadioAMSend.send(commander, &pkt, sizeof(CaptureMessage));
       call Leds.set(1);
       call Timer2.stop();
     }
   }

   event void RadioControl.stopDone(error_t err) {
   }

   event void SerialControl.stopDone(error_t err) {
   }

   event void RadioAMSend.sendDone(message_t* msg, error_t error) {
     if (&pkt == msg) {
       busy = FALSE;
         
       if(mode == MODE_PREPROCESS){
	 ++messageCount1;
	 if(messageCount1 >= 300){
           mode = MODE_CALCQUALITY;
           messageCount1 = 0;
           messageCount2 = 0;
	 }
       }
       else if(mode == MODE_CALCQUALITY){
         ++messageCount2;
         if(messageCount2 >= NUM_REPEAT){
           SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
           btrpkt->nodeid1 = nodes[messageCount1];
           btrpkt->nodeid2 = nodes[messageCount2];
           btrpkt->quality1 = 0xbbbb;
           btrpkt->quality2 = 0xaaaa;
           btrpkt->result1 = 0xaaaa;
           btrpkt->result2 = 0xaaaa;
           if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
             busy = TRUE;
           }
           messageCount2 = 0;
	   ++messageCount1;
	   if(messageCount1 >= nodeCount){
             mode = MODE_WATING1;
             call Timer1.stop();
             call Timer0.startPeriodic(5000);
           }
         }
       }
       else if(mode == MODE_MAINREQUEST){
         ++messageCount3;
         if(messageCount3 >= NUM_REPEAT){

           SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
           btrpkt->nodeid1 = nodes[messageCount1];
           btrpkt->nodeid2 = nodes[messageCount2];
           btrpkt->quality1 = 0xaaaa;
           btrpkt->quality2 = 0xaaaa;
           btrpkt->result1 = 0xaaaa;
           btrpkt->result2 = 0xaaaa;
           if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
             busy = TRUE;
           }

           messageCount3 = 0;
	   ++messageCount1;
           if(messageCount1 >= nodeCount){
	     ++messageCount2;
             messageCount1 = messageCount2 + 1;
	     if(messageCount2 >= nodeCount-1){
               mode = MODE_WATING2;
               messageCount1 = 0;
               messageCount2 = 0;
               messageCount3 = 0;
               call Timer1.stop();
               call Timer0.startPeriodic(5000);
	     }
           }
         }
       }
     }
   }

   event void SerialAMSend.sendDone(message_t* msg, error_t error) {
     if (&pkt == msg) {
       busy = FALSE;
       if(mode == MODE_PRINT){
         ++messageCount1;
         if(messageCount1 >= nodeCount){
	   ++messageCount2;
	   messageCount1 = messageCount2 + 1;
	   if(messageCount2 >= nodeCount - 1)
	   {
	     if(TOS_NODE_ID < NODE_END){
               CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
               m->type = MSG_INITIALIZE;
               m->id1 = TOS_NODE_ID + 1;
               call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage));

	       commander = TOS_NODE_ID + 1;
	     }

             mode = MODE_NODE;
             call Timer1.stop();
	   }
         }
       }
     }
   }

   event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
     if (len == sizeof(CaptureMessage)/* && TOS_NODE_ID != NODE_PRINTER*/) {
       CaptureMessage* btrpkt = (CaptureMessage*)payload;
	   
	   if(btrpkt->type == MSG_INITIALIZE){
             if(btrpkt->id1 > commander){
               CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
               m->type = MSG_INITIALIZE;
               m->id1 = btrpkt->id1;
               call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage));

	       commander = btrpkt->id1;
	       if(btrpkt->id1 == TOS_NODE_ID){
                 mode = MODE_PREPROCESS;
                 call Timer0.startPeriodic(5000);
                 call Leds.set(1);
	       }
	     }
	   }
	   else if(btrpkt->type == MSG_ANNOUNCE){
	     commander = btrpkt->id1;
             call Timer2.startPeriodic(rand() % 1000);
	   }
	   else if(btrpkt->type == MSG_ANNOUNCE_RETURN){
	     int exist = 0;
	     int i;
	     for(i=0; i<nodeCount; ++i){
	       if(nodes[i] == btrpkt->id1){
		 exist = 1;
		 break;
	       }
	     }
	     if(exist == 0)
  	       nodes[nodeCount++] = btrpkt->id1;
	   }
	   else if(btrpkt->type == MSG_TEST_REQUEST){
	     if(btrpkt->id1 == TOS_NODE_ID || btrpkt->id2 == TOS_NODE_ID){
	       CaptureMessage* m;
	       uint16_t second;
	       if(btrpkt->id1 == TOS_NODE_ID)
	         second = btrpkt->id2;
	       else
	         second = btrpkt->id1;

	       m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
	       m->type = MSG_TEST_RETURN;
	       m->id1 = TOS_NODE_ID;
	       m->id2 = second;
             
               //call CC2420Packet.setPower(&pkt, 10);
	       if (call RadioAMSend.send(commander, &pkt, sizeof(CaptureMessage)) == SUCCESS) {
	         //busy = TRUE;
	       }

                call Leds.set(2);
	     }
	   }
	   else if(btrpkt->type == MSG_TEST_RETURN){
             if(mode == MODE_CALCQUALITY)
	       ++quality[btrpkt->id1];
             else if(mode == MODE_MAINREQUEST)
	       ++capture[btrpkt->id1][btrpkt->id2];
             call Leds.set(2);
	   }

     }
     return msg;
   }

   event message_t* SerialReceive.receive(message_t* msg, void* payload, uint8_t len) {
     return msg;
   }
 }
 
