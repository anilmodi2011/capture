 #include <Timer.h>
 #include <stdlib.h>
 #include "Define.h"
 
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

   uses interface CC2420Packet;
   uses interface CC2420Config;
 }
 implementation {
   uint16_t NUM_REPEAT = 100;
   uint16_t POWER = 10;

   enum {
     MODE_NODE = 0,
     MODE_PREPROCESS = 1,
     MODE_WATING1 = 2,
     MODE_SEND_COUNT = 3,
     MODE_WATING2 = 4,
     MODE_PRINT = 5,
     MODE_GET_COUNT=6,
   };

   uint16_t commander = -1;

   uint16_t mode = 0;
   uint16_t mode2 = 0;
   uint8_t nodes[150] = {0, };
   uint8_t quality[150] = {0, };
   uint8_t capture_send = 0;
   uint8_t capture_receive= 0;
   uint16_t rssi[150] = {0, };
   uint16_t nodeCount = 0;
   uint16_t eventCount = 0;
   uint16_t messageCount1 = 0;
   uint16_t messageCount2 = 0;
   uint16_t messageCount3 = 0;
   uint16_t second = 0;
   uint16_t requestCnt = 0;
   uint16_t curRssi = 0;

   bool busy = FALSE;
   bool got_it =FALSE;
   message_t pkt;

   int changeMode = 0;
 
   event void Boot.booted() {
     call SerialControl.start();
     call RadioControl.start();
   }

   event void RadioControl.startDone(error_t err) {
     if (err == SUCCESS) {
       call CC2420Config.setChannel(19);
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
       srand(TOS_NODE_ID);
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
         call Timer1.startPeriodic(TIMER_PERIOD_MILLI);
       }
       else if(mode == MODE_WATING1){
         mode = MODE_GET_COUNT;
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
         call CC2420Packet.setPower(&pkt, POWER);
         call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage));
       }
       // else if(mode == MODE_CALCQUALITY){
       //   CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
       //   btrpkt->type = MSG_TEST_REQUEST;
       //   btrpkt->id1 = nodes[messageCount1];
       //   call CC2420Packet.setPower(&pkt, POWER);
       //   if (call RadioAMSend.send(nodes[messageCount1], &pkt, sizeof(CaptureMessage)) == SUCCESS) {
       //     busy = TRUE;
       //   }
       // }
       else if(mode == MODE_SEND_COUNT){
         CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
         btrpkt->type = MSG_SEND_REQUEST;
         btrpkt->id1 = nodes[messageCount1];
         btrpkt->id2 = nodes[messageCount2];
         call CC2420Packet.setPower(&pkt, POWER);
         if (call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage)) == SUCCESS) {
           busy = TRUE;
         }
       }
       else if(mode == MODE_GET_COUNT){
         CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
         btrpkt->type = MSG_RECEIVE_REQUEST;
         btrpkt->id1 = nodes[messageCount1];
         btrpkt->id2 = nodes[messageCount2];
         call CC2420Packet.setPower(&pkt, POWER);
         if (call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage)) == SUCCESS) {
           busy = TRUE;
         }
       }
       else if(mode == MODE_PRINT){
         SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
         btrpkt->commander = commander;
         btrpkt->nodeid1 = nodes[messageCount2];
         btrpkt->nodeid2 = nodes[messageCount1];
         btrpkt->quality1 = 33333;
         btrpkt->quality2 = 33333;
         btrpkt->duck =capture_send;
         if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
           busy = TRUE;
         }
       }
     }
   }

   event void Timer2.fired() {
     if(busy == FALSE){
       if(mode2 == 0){
         CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
         m->type = MSG_ANNOUNCE_RETURN;
         m->id1 = TOS_NODE_ID;
         call CC2420Packet.setPower(&pkt, POWER);
         call RadioAMSend.send(commander, &pkt, sizeof(CaptureMessage));
         call Leds.set(1);
         call Timer2.stop();
       }
       else if(mode2 == 1){
      	   CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
      	   m->type = MSG_RECEIVE_RETURN;
      	   m->id1 = TOS_NODE_ID;
      	   m->id2 = second;
                 m->rssi = curRssi;
                 m->cnt=capture_send;
                   
                 call CC2420Packet.setPower(&pkt, POWER);
      	   if (call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage)) == SUCCESS) {
      	     busy = TRUE;             
      	   }
               else
                 call Timer2.stop();
             }
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
	   if(messageCount1 >= 1000){
           if(nodeCount == 0){
             SuccessMessage* btrpkt;

             mode = MODE_NODE;
             call Timer1.stop();

             btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
             btrpkt->commander = commander;
	           

             btrpkt->nodeid1 = nodes[messageCount2];
             btrpkt->nodeid2 = nodes[messageCount1];
             btrpkt->quality1 = 33333;
             btrpkt->quality2 = 33333;
             btrpkt->rssi1 = 33333;
             btrpkt->rssi2 = 33333;
             if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
               busy = TRUE;
             }
           }
           else{
             mode = MODE_SEND_COUNT;
             messageCount1 = 1;
             messageCount2 = 0;
           }
	   }
       } else if(mode == MODE_SEND_COUNT){
        ++messageCount3;
                 if(messageCount3 >= NUM_REPEAT){

                   SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
                   btrpkt->commander = commander;
                   btrpkt->nodeid1 = nodes[messageCount2];
                   btrpkt->nodeid2 = nodes[messageCount1];
                   btrpkt->quality1 = 22222;
                   btrpkt->quality2 = 22222;
                   btrpkt->rssi1 = 22222;
                   btrpkt->duck =000000;
                   btrpkt->rssi2 = 22222;
                   if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
                     busy = TRUE;
                   }

                    mode = MODE_WATING1;
                       messageCount1 = 0;
                       messageCount2 = 0;
                       messageCount3 = 0;
                       call Timer1.stop();
                       call Timer0.startPeriodic(5000);
             
                 }
       }
       else if(mode == MODE_GET_COUNT){
              ++messageCount3;
              if(got_it){

                  mode = MODE_WATING2;
                  call Timer1.stop();
                  call Timer0.startPeriodic(5000);

              }
               else  if(messageCount3 >= NUM_REPEAT){

                   SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
                   btrpkt->commander = commander;
                   btrpkt->nodeid1 = nodes[messageCount2];
                   btrpkt->nodeid2 = nodes[messageCount1];
                   btrpkt->quality1 = 44444;
                   btrpkt->quality2 = 44444;
                   btrpkt->rssi1 = 44444;
                   btrpkt->duck =000000;
                   btrpkt->rssi2 = 44444;
                   btrpkt->result1 = 44444;
                   btrpkt->result2 = 44444;
                   if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
                     busy = TRUE;
                   }

                   messageCount1 = 0;
                   messageCount2 = 0;
                   messageCount3 = 0;
                   call Timer1.stop();
                    
                 }

       }


  //      else if(mode == MODE_CALCQUALITY){
  //        ++messageCount2;
  //        if(messageCount2 >= NUM_REPEAT){
  //          SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
  //          btrpkt->commander = commander;
  //          btrpkt->nodeid1 = nodes[messageCount1];
  //          btrpkt->nodeid2 = 11111;
  //          btrpkt->quality1 = 11111;
  //          btrpkt->quality2 = 11111;
  //          btrpkt->rssi1 = 11111;
  // btrpkt->duck =000000;
  //          btrpkt->rssi2 = 11111;
  //          btrpkt->result1 = 11111;
  //          btrpkt->result2 = 11111;
  //          if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
  //            busy = TRUE;
  //          }
  //          messageCount2 = 0;
	 //   ++messageCount1;
	 //   if(messageCount1 >= nodeCount){
  //            mode = MODE_WATING1;
  //            call Timer1.stop();
  //            call Timer0.startPeriodic(5000);
  //          }
  //        }
  //      }
  //      else if(mode == MODE_MAINREQUEST){
  //        ++messageCount3;
  //        if(messageCount3 >= NUM_REPEAT){

  //          SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
  //          btrpkt->commander = commander;
  //          btrpkt->nodeid1 = nodes[messageCount2];
  //          btrpkt->nodeid2 = nodes[messageCount1];
  //          btrpkt->quality1 = 22222;
  //          btrpkt->quality2 = 22222;
  //          btrpkt->rssi1 = 22222;
  // btrpkt->duck =000000;
  //          btrpkt->rssi2 = 22222;
  //          btrpkt->result1 = 22222;
  //          btrpkt->result2 = 22222;
  //          if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
  //            busy = TRUE;
  //          }

  //          messageCount3 = 0;
	 //   ++messageCount1;
  //          if(messageCount1 >= nodeCount){
	 //     ++messageCount2;
  //            messageCount1 = messageCount2 + 1;
	 //     if(messageCount2 >= nodeCount-1){
  //              mode = MODE_WATING2;
  //              messageCount1 = 0;
  //              messageCount2 = 0;
  //              messageCount3 = 0;
  //              call Timer1.stop();
  //              call Timer0.startPeriodic(5000);
	 //     }
  //          }
  //        }
  //      }
     }
   }

   event void SerialAMSend.sendDone(message_t* msg, error_t error) {
     if (&pkt == msg) {
       busy = FALSE;
       if(mode == MODE_PRINT){
             SuccessMessage* btrpkt;
             mode = MODE_NODE;
             call Timer1.stop();
             btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
             btrpkt->commander = commander;
             btrpkt->nodeid1 = nodes[messageCount2];
             btrpkt->nodeid2 = nodes[messageCount1];
             btrpkt->quality1 = 33333;
             btrpkt->quality2 = 33333;
             btrpkt->rssi1 = 33333;
             btrpkt->rssi2 = 33333;
             btrpkt->duck =capture_send;
             if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
               busy = TRUE;
             }
       }
     }
   }

   event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
     if (len == sizeof(CaptureMessage)/* && TOS_NODE_ID != NODE_PRINTER*/) {
       CaptureMessage* btrpkt = (CaptureMessage*)payload;
	   
	   if(btrpkt->type == MSG_ANNOUNCE){
	     commander = btrpkt->id1;
             mode2 = 0;
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


       else if(btrpkt->type == MSG_SEND_REQUEST){
       if(btrpkt->id1 == TOS_NODE_ID || btrpkt->id2 == TOS_NODE_ID){
               uint16_t i;
               int8_t num;
               capture_send++;

       }
     
	   }
      else if(btrpkt->type == MSG_RECEIVE_REQUEST){
       if(btrpkt->id1 == TOS_NODE_ID || btrpkt->id2 == TOS_NODE_ID){
             commander = btrpkt->id1;
             mode2 = 1;
             call Timer2.startPeriodic(rand() % 1000);
       }
     
     }
      else if(btrpkt->type == MSG_RECEIVE_RETURN){
           if(mode==MODE_GET_COUNT){   
            capture_send=btrpkt->cnt;
            got_it=TRUE;     
          }
     }
     
	   // else if(btrpkt->type == MSG_TEST_RETURN){
    //          if(mode == MODE_CALCQUALITY){
	   //     ++quality[btrpkt->id1];
	   //     rssi[btrpkt->id1] += btrpkt->rssi;
    //          }
    //          else if(mode == MODE_MAINREQUEST){
    //            uint16_t i;
    //            uint16_t id1 = 0;
    //            uint16_t id2 = 0;
    //            for(i=0; i<nodeCount; ++i){
    //              if(btrpkt->id1 == nodes[i])
    //                id1 = i;
    //              if(btrpkt->id2 == nodes[i])
    //                id2 = i;
    //            }
               
	   //     ++capture[id1][id2];
    //          }
	   // }
// 
     }
     return msg;
   }

   event message_t* SerialReceive.receive(message_t* msg, void* payload, uint8_t len) {

     int i, j;

     mode = MODE_PREPROCESS;
     commander = TOS_NODE_ID;

     for(i=0; i<130; ++i){
       quality[i] = 0;
       rssi[i] = 0;
     }
     capture_receive=0;

     curRssi = 0;
     nodeCount = 0;
     eventCount = 0;
     messageCount1 = 0;
     messageCount2 = 0;
     messageCount3 = 0;
     capture_send=0;
     call Timer0.startPeriodic(5000);
     call Leds.set(1);
     return msg;
   }
 }
 
