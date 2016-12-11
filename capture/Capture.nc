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
uint16_t NUM_MESSAGE = 100;

enum {
    MODE_NODE = 0,
    MODE_PREPROCESS = 1,
    MODE_WATING1 = 2,
    MODE_SENDREQUEST = 3,
    MODE_WATING2 = 4,
    MODE_PRINT = 5,
    // MODE_MAINREQUEST = 4,
    // MODE_PRINT = 6,
};

enum {
    MODE2_NODE = 0,
    MODE2_PREPROCESS = 1,
    MODE2_SENDRETURN = 2,
    // MODE_MAINREQUEST = 4,
    // MODE_WATING2 = 5,
};

uint16_t commander = -1;

uint16_t mode = MODE_NODE;
uint16_t mode2 = MODE2_NODE;
uint16_t nodes[150] = {0, };
uint16_t capture1[100] = {0,};
uint16_t capture2[100] = {0,};
uint16_t capture_r1[100] = {0,};
uint16_t capture_r2[100] = {0,};
uint16_t capture_rec[100] = {0,};
uint16_t nodeCount = 0;
uint16_t eventCount = 0;
uint16_t messageCount1 = 0;
uint16_t messageCount2 = 0;
uint16_t messageCount3 = 0;
uint16_t second = 0;
uint16_t requestCnt = 0;
uint16_t serialNo = 0;

bool busy = FALSE;
bool received = FALSE;
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
    } else {
        call RadioControl.start();
    }
}

event void SerialControl.startDone(error_t err) {
    if (err == SUCCESS) {
    } else {
        call RadioControl.start();
    }
}

event void CC2420Config.syncDone( error_t err ) {
    if (err == SUCCESS) {
        srand(TOS_NODE_ID);
    } else {
        call CC2420Config.sync();
    }
}

event void Timer0.fired() {
    if(mode == MODE_PREPROCESS){
        messageCount1 = 0;
        messageCount2 = 0;
        call Timer0.stop();
        call Timer1.startPeriodic(TIMER_PERIOD_MILLI);
    } else if(mode == MODE_WATING1){
        mode = MODE_SENDREQUEST;
        messageCount1 = 2;
        messageCount2 = 1;
        messageCount3 = 0;
        call Timer0.stop();
        call Timer1.startPeriodic(TIMER_PERIOD_MILLI);
    } else if(mode == MODE_WATING2){
        mode = MODE_PRINT;
        messageCount1 = 2;
        messageCount2 = 1;
        messageCount3 = 0;
        call Timer0.stop();
        call Timer1.startPeriodic(TIMER_PERIOD_MILLI);
    } /*else if(mode == MODE_WATING2){
        mode = MODE_PRINT;
        messageCount1 = 1;
        messageCount2 = 0;
        messageCount3 = 0;
        call Timer0.stop();
        call Timer1.startPeriodic(100);
    }*/
}

event void Timer1.fired() {
    if (!busy) {
        if(mode == MODE_PREPROCESS){
            CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
            m->type = MSG_ANNOUNCE;
            m->id1 = TOS_NODE_ID;
            call CC2420Packet.setPower(&pkt, POWER);
            call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage));
        } /*else if(mode == MODE_CALCQUALITY){
            CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
            btrpkt->type = MSG_TEST_REQUEST;
            btrpkt->id1 = nodes[messageCount1];
            call CC2420Packet.setPower(&pkt, POWER);
            if (call RadioAMSend.send(nodes[messageCount1], &pkt, sizeof(CaptureMessage)) == SUCCESS) {
                busy = TRUE;
            }
        }*/ else if(mode == MODE_SENDREQUEST){
            CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
            btrpkt->type = MSG_SEND_REQUEST;
            btrpkt->id1 = nodes[messageCount1];
            btrpkt->id2 = nodes[messageCount2];
            btrpkt->serialNo = serialNo;
            call CC2420Packet.setPower(&pkt, POWER);
            if (call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CaptureMessage)) == SUCCESS) {
                busy = TRUE;
            }
        } else if(mode == MODE_PRINT){
            SuccessMessage* btrpkt;

            btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
            btrpkt->commander = commander;
            btrpkt->nodeid1 = nodes[messageCount1];
            btrpkt->nodeid2 = nodes[messageCount2];
            btrpkt->stage = MODE_PRINT;
            btrpkt->countcapture1 = 0;
            btrpkt->countcapture2 = 0;
            btrpkt->serialno = messageCount3;
            btrpkt->capture1 = capture1[messageCount3];
            btrpkt->capture2 = capture2[messageCount3];
            if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
                busy = TRUE;
            }
        }
    }
}

event void Timer2.fired() {
    if(busy == FALSE){
        if(mode2 == MODE2_PREPROCESS){
            CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
            m->type = MSG_ANNOUNCE_RETURN;
            m->id1 = TOS_NODE_ID;
            call CC2420Packet.setPower(&pkt, POWER);
            call RadioAMSend.send(commander, &pkt, sizeof(CaptureMessage));
            call Leds.set(1);
            call Timer2.stop();
        } else if(mode2 == MODE2_SENDRETURN){
            CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
            m->type = MSG_SEND_RETURN;
            m->id1 = TOS_NODE_ID;
            m->id2 = second;
            m->serialNo = serialNo;

            call CC2420Packet.setPower(&pkt, POWER);
            if (call RadioAMSend.send(commander, &pkt, sizeof(CaptureMessage)) == SUCCESS) {
                busy = TRUE;
            }

            call Timer2.stop();
            /*if(requestCnt > 0){
                CaptureMessage* m = (CaptureMessage*)(call RadioPacket.getPayload(&pkt, sizeof (CaptureMessage)));
                m->type = MSG_TEST_RETURN;
                m->id1 = TOS_NODE_ID;
                m->id2 = second;
                m->rssi = curRssi;

                call CC2420Packet.setPower(&pkt, POWER);
                if (call RadioAMSend.send(commander, &pkt, sizeof(CaptureMessage)) == SUCCESS) {
                    busy = TRUE;
                    --requestCnt;
                }
            } else {
                call Timer2.stop();
            }*/
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
                    btrpkt->nodeid1 = 0;
                    btrpkt->nodeid2 = 0;
                    btrpkt->stage = MODE_NODE;
                    btrpkt->countcapture1 = 0;
                    btrpkt->countcapture2 = 0;
                    btrpkt->serialno = 0;
                    btrpkt->capture1 = 0;
                    btrpkt->capture2 = 0;
                    if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
                        busy = TRUE;
                    }
                } else{
                    SuccessMessage* btrpkt;

                    mode = MODE_WATING1;
                    call Timer1.stop();
                    call Timer0.startPeriodic(5000);

                    btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
                    btrpkt->commander = commander;
                    btrpkt->nodeid1 = 0;
                    btrpkt->nodeid2 = 0;
                    btrpkt->stage = MODE_PREPROCESS;
                    btrpkt->countcapture1 = 0;
                    btrpkt->countcapture2 = 0;
                    btrpkt->serialno = 0;
                    btrpkt->capture1 = 0;
                    btrpkt->capture2 = 0;
                    if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
                        busy = TRUE;
                    }
                }
            }
        } /*else if(mode == MODE_CALCQUALITY){
            ++messageCount2;
            if(messageCount2 >= NUM_REPEAT){
                SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
                btrpkt->commander = commander;
                btrpkt->nodeid1 = nodes[messageCount1];
                btrpkt->nodeid2 = 11111;
                btrpkt->quality1 = 11111;
                btrpkt->quality2 = 11111;
                btrpkt->rssi1 = 11111;
                btrpkt->rssi2 = 11111;
                btrpkt->result1 = 11111;
                btrpkt->result2 = 11111;
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
        }*/ else if(mode == MODE_SENDREQUEST){
            serialNo++;
            ++messageCount3;
            if(messageCount3 >= NUM_REPEAT){

                uint8_t cnt1 = 0;
                uint8_t cnt2 = 0;
                uint8_t i;
                SuccessMessage* btrpkt;

                mode = MODE_WATING2;
                messageCount3 = 0;
                call Timer1.stop();
                call Timer0.startPeriodic(5000);

                for(i=0;i<NUM_MESSAGE;++i) {
                    cnt1=cnt1+capture1[i];
                    cnt2=cnt2+capture2[i];
                }

                btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
                btrpkt->commander = commander;
                btrpkt->nodeid1 = nodes[messageCount1];
                btrpkt->nodeid2 = nodes[messageCount2];
                btrpkt->stage = MODE_SENDREQUEST;
                btrpkt->countcapture1 = cnt1;
                btrpkt->countcapture2 = cnt2;
                btrpkt->serialno = 0;
                btrpkt->capture1 = 0;
                btrpkt->capture2 = 0;
                if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
                    busy = TRUE;
                }
                /*++messageCount1;
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
                }*/
            }
        }
    }
}

event void SerialAMSend.sendDone(message_t* msg, error_t error) {
    if (&pkt == msg) {
        busy = FALSE;
        if(mode == MODE_PRINT){
            ++messageCount3;
            if(messageCount3 >= NUM_MESSAGE){
                SuccessMessage* btrpkt;

                mode = MODE_NODE;
                call Timer1.stop();

                btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt, sizeof (SuccessMessage)));
                btrpkt->commander = commander;
                btrpkt->nodeid1 = 0;
                btrpkt->nodeid2 = 0;
                btrpkt->stage = MODE_NODE;
                btrpkt->countcapture1 = 0;
                btrpkt->countcapture2 = 0;
                btrpkt->serialno = 0;
                btrpkt->capture1 = 0;
                btrpkt->capture2 = 0;
                if (call SerialAMSend.send(126, &pkt, sizeof(SuccessMessage)) == SUCCESS) {
                    busy = TRUE;
                }
            }
        }
    }
}

event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len == sizeof(CaptureMessage)/* && TOS_NODE_ID != NODE_PRINTER*/) {
        CaptureMessage* btrpkt = (CaptureMessage*)payload;

        if(btrpkt->type == MSG_ANNOUNCE){
            commander = btrpkt->id1;
            mode2 = MODE2_PREPROCESS;
            call Timer2.startPeriodic(rand() % 1000);
        } else if(btrpkt->type == MSG_ANNOUNCE_RETURN){
            int exist = 0;
            int i;
            for(i=0; i<nodeCount; ++i){
                if(nodes[i] == btrpkt->id1){
                    exist = 1;
                    break;
                }
            }
            if(exist == 0) {
                nodes[nodeCount++] = btrpkt->id1;
            }
        } else if(btrpkt->type == MSG_SEND_REQUEST){
            if(btrpkt->id1 == TOS_NODE_ID || btrpkt->id2 == TOS_NODE_ID){
                uint16_t i;
                // int8_t num;

                if(btrpkt->id1 == TOS_NODE_ID) {
                    second = btrpkt->id2;
                } else {
                    second = btrpkt->id1;
                }

                serialNo = btrpkt->serialNo;
                capture_rec[serialNo] = 1;

                mode2 = MODE2_SENDRETURN;

                // num = call CC2420Packet.getRssi(msg);
                // num *= -1;
                // curRssi = (uint16_t)num;
                // ++requestCnt;
                //if(requestCnt == 1)

                for(i=0; i<rand() % 40; ++i) {
                    // do nothing
                }

                call Timer2.startPeriodic(0);
            }
        } else if(btrpkt->type == MSG_SEND_RETURN){
            uint16_t i;
            uint16_t id1 = 0;
            uint16_t id2 = 0;
            for(i=0; i<nodeCount; ++i){
                if(btrpkt->id1 == nodes[i]) {
                    id1 = i;
                }
                if(btrpkt->id2 == nodes[i]) {
                    id2 = i;
                }
            }

            if(id1==messageCount1) {
                capture1[btrpkt->serialNo]=1;
            } else if(id1==messageCount2) {
                capture2[btrpkt->serialNo]=1;
            }
            received = TRUE;
        }

    }
    return msg;
}

event message_t* SerialReceive.receive(message_t* msg, void* payload, uint8_t len) {
    uint16_t i;

    mode = MODE_PREPROCESS;
    commander = TOS_NODE_ID;

    for(i=0; i<NUM_MESSAGE; ++i){
        capture1[i]=0;
        capture2[i]=0;
        capture_r1[i]=0;
        capture_r2[i]=0;
        capture_rec[i]=0;
    }

    for(i=0; i<150; ++i) {
        nodes[i]=0;
    }

    mode2 = MODE2_NODE;
    nodeCount = 0;
    eventCount = 0;
    messageCount1 = 0;
    messageCount2 = 0;
    messageCount3 = 0;
    second = 0;
    requestCnt = 0;
    serialNo = 0;

    busy = FALSE;
    received = FALSE;

    call Timer0.startPeriodic(5000);
    call Leds.set(1);
    return msg;
}
}

