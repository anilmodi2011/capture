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
#define NOISE_NONE 0
#define NOISE_HALF 1
#define NOISE_ALL 2

   uint16_t POWER = 10;
   uint16_t time_send = 100;
   uint16_t time_send_max = 7000;
   uint16_t time_send_accum = 0;
   bool latency = FALSE;
   uint16_t noise = NOISE_ALL;
   uint16_t latencyCnt = 0;

   uint16_t parent = 0;
   uint16_t currentChannel = 0;
   uint16_t parentChannel = 0;

#define MAX_CHANNEL 11
   uint16_t channels[15] = {26,21,25,22,15,20,23,24,17,12,19,16,14,11,13};
   bool channelEnable[15] = {FALSE, };
   uint16_t buf[4000] = {0, };
   uint16_t bufCount = 0;
   uint16_t receiveCount = 0;
   uint16_t sender = 0;
   uint16_t c[150] = {0, };

   bool busy1 = FALSE;
   bool busy2 = FALSE;
   message_t pkt1;
   message_t pkt2;
 
   event void Boot.booted() {
     call SerialControl.start();
     call RadioControl.start();
   }

   void addBuf(uint16_t node)
   {
     buf[bufCount++] = node;
   }

   event void RadioControl.startDone(error_t err) {
     if (err == SUCCESS) {
       uint16_t i;
       uint16_t num = 100;

       parent = 11111;

       for(i=0; i<150; ++i)
         c[i] = 100; // set unreachable channel

if(TOS_NODE_ID == 1){parent = 0; c[9] = 1; c[10] = 5; c[14] = 10; c[8] = 5; c[64] = 0; c[4] = 7; c[18] = 7; c[3] = 0; c[11] = 9; c[66] = 6; c[67] = 2; c[13] = 6; }
else if(TOS_NODE_ID == 2){parent = 5; parentChannel = 7; c[19] = 1; c[80] = 0; c[12] = 0; c[5] = 7; c[18] = 5; c[26] = 2; c[17] = 3; }
else if(TOS_NODE_ID == 3){parent = 18; parentChannel = 5; c[1] = 0; c[14] = 10; c[19] = 9; c[5] = 1; c[18] = 5; c[7] = 10; c[11] = 0; c[15] = 7; c[16] = 9; c[20] = 9; c[66] = 7; c[6] = 3; c[13] = 7; }
else if(TOS_NODE_ID == 4){parent = 9; parentChannel = 2; c[1] = 7; c[9] = 2; c[10] = 8; c[14] = 6; c[8] = 9; c[64] = 6; c[11] = 8; c[67] = 8; c[13] = 0; }
else if(TOS_NODE_ID == 5){parent = 18; parentChannel = 6; c[14] = 7; c[2] = 7; c[19] = 4; c[12] = 10; c[18] = 6; c[3] = 1; c[11] = 2; c[66] = 4; c[35] = 0; c[37] = 3; c[26] = 0; c[36] = 4; c[13] = 1; c[17] = 4; c[33] = 3; }
else if(TOS_NODE_ID == 6){parent = 20; parentChannel = 8; c[3] = 3; c[7] = 4; c[11] = 9; c[15] = 10; c[16] = 4; c[20] = 8; c[13] = 7; }
else if(TOS_NODE_ID == 7){parent = 18; parentChannel = 2; c[14] = 8; c[18] = 2; c[3] = 10; c[15] = 4; c[16] = 2; c[20] = 6; c[6] = 4; }
else if(TOS_NODE_ID == 8){parent = 1; parentChannel = 5; c[1] = 5; c[9] = 4; c[10] = 10; c[14] = 10; c[64] = 4; c[4] = 9; c[18] = 0; c[11] = 8; c[66] = 5; c[67] = 4; c[13] = 4; c[63] = 6; c[72] = 3; }
else if(TOS_NODE_ID == 9){parent = 1; parentChannel = 1; c[1] = 1; c[10] = 3; c[14] = 3; c[8] = 4; c[64] = 8; c[4] = 2; c[11] = 6; c[67] = 0; c[13] = 8; c[72] = 5; }
else if(TOS_NODE_ID == 10){parent = 9; parentChannel = 3; c[1] = 5; c[9] = 3; c[14] = 3; c[8] = 10; c[4] = 8; c[11] = 1; c[67] = 9; c[13] = 7; }
else if(TOS_NODE_ID == 11){parent = 9; parentChannel = 6; c[1] = 9; c[9] = 6; c[10] = 1; c[14] = 9; c[8] = 8; c[4] = 8; c[5] = 2; c[18] = 5; c[3] = 0; c[15] = 8; c[16] = 3; c[20] = 10; c[66] = 5; c[6] = 9; c[13] = 5; }
else if(TOS_NODE_ID == 12){parent = 19; parentChannel = 3; c[2] = 0; c[19] = 3; c[5] = 10; }
else if(TOS_NODE_ID == 13){parent = 11; parentChannel = 5; c[1] = 6; c[9] = 8; c[10] = 7; c[14] = 8; c[8] = 4; c[4] = 0; c[5] = 1; c[18] = 1; c[3] = 7; c[11] = 5; c[16] = 5; c[20] = 2; c[66] = 6; c[35] = 4; c[37] = 10; c[6] = 7; }
else if(TOS_NODE_ID == 14){parent = 1; parentChannel = 10; c[1] = 10; c[9] = 3; c[10] = 3; c[8] = 10; c[64] = 6; c[4] = 6; c[19] = 10; c[5] = 7; c[18] = 6; c[3] = 10; c[7] = 8; c[11] = 9; c[15] = 2; c[16] = 8; c[66] = 1; c[35] = 6; c[37] = 7; c[36] = 3; c[13] = 8; c[33] = 5; }
else if(TOS_NODE_ID == 15){parent = 7; parentChannel = 4; c[14] = 2; c[19] = 8; c[18] = 7; c[3] = 7; c[7] = 4; c[11] = 8; c[16] = 6; c[20] = 1; c[66] = 3; c[6] = 10; }
else if(TOS_NODE_ID == 16){parent = 3; parentChannel = 9; c[14] = 8; c[18] = 2; c[3] = 9; c[7] = 2; c[11] = 3; c[15] = 6; c[20] = 3; c[66] = 0; c[6] = 4; c[13] = 5; }
else if(TOS_NODE_ID == 17){parent = 39; parentChannel = 3; c[2] = 3; c[19] = 5; c[5] = 4; c[37] = 3; c[83] = 7; c[39] = 3; c[38] = 1; }
else if(TOS_NODE_ID == 18){parent = 14; parentChannel = 6; c[1] = 7; c[14] = 6; c[8] = 0; c[2] = 5; c[19] = 7; c[5] = 6; c[3] = 5; c[7] = 2; c[11] = 5; c[15] = 7; c[16] = 2; c[66] = 8; c[35] = 6; c[37] = 1; c[13] = 1; c[33] = 5; }
else if(TOS_NODE_ID == 19){parent = 2; parentChannel = 1; c[14] = 10; c[2] = 1; c[12] = 3; c[5] = 4; c[18] = 7; c[3] = 9; c[15] = 8; c[37] = 10; c[26] = 5; c[17] = 5; c[83] = 9; }
else if(TOS_NODE_ID == 20){parent = 11; parentChannel = 10; c[3] = 9; c[7] = 6; c[11] = 10; c[15] = 1; c[16] = 3; c[6] = 8; c[13] = 2; }
else if(TOS_NODE_ID == 24){parent = 27; parentChannel = 4; c[31] = 2; c[27] = 4; c[48] = 9; }
else if(TOS_NODE_ID == 25){parent = 35; parentChannel = 1; c[35] = 1; c[37] = 10; c[36] = 8; c[31] = 8; c[28] = 6; c[38] = 10; }
else if(TOS_NODE_ID == 26){parent = 19; parentChannel = 5; c[2] = 2; c[19] = 5; c[5] = 0; c[35] = 0; c[37] = 8; c[36] = 8; c[39] = 4; }
else if(TOS_NODE_ID == 27){parent = 54; parentChannel = 4; c[24] = 4; c[31] = 1; c[48] = 2; c[38] = 2; c[58] = 0; c[56] = 2; c[51] = 8; c[55] = 7; c[54] = 4; c[47] = 10; c[30] = 0; c[45] = 8; }
else if(TOS_NODE_ID == 28){parent = 25; parentChannel = 6; c[35] = 7; c[37] = 10; c[36] = 5; c[31] = 1; c[25] = 6; c[38] = 10; }
else if(TOS_NODE_ID == 30){parent = 57; parentChannel = 1; c[37] = 6; c[36] = 10; c[39] = 5; c[27] = 0; c[38] = 2; c[56] = 0; c[51] = 2; c[53] = 2; c[46] = 6; c[57] = 1; }
else if(TOS_NODE_ID == 31){parent = 24; parentChannel = 2; c[24] = 2; c[27] = 1; c[48] = 6; c[25] = 8; c[28] = 1; c[60] = 0; c[32] = 2; c[45] = 2; c[33] = 10; }
else if(TOS_NODE_ID == 32){parent = 34; parentChannel = 5; c[31] = 2; c[48] = 6; c[60] = 3; c[45] = 2; c[34] = 5; c[33] = 1; }
else if(TOS_NODE_ID == 33){parent = 60; parentChannel = 9; c[14] = 5; c[5] = 3; c[18] = 5; c[35] = 3; c[37] = 10; c[36] = 7; c[31] = 10; c[48] = 10; c[60] = 9; c[32] = 1; c[45] = 1; }
else if(TOS_NODE_ID == 34){parent = 45; parentChannel = 4; c[48] = 3; c[32] = 5; c[45] = 4; }
else if(TOS_NODE_ID == 35){parent = 14; parentChannel = 6; c[14] = 6; c[5] = 0; c[18] = 6; c[37] = 5; c[26] = 0; c[36] = 4; c[13] = 4; c[48] = 9; c[25] = 1; c[28] = 7; c[38] = 4; c[60] = 1; c[33] = 3; }
else if(TOS_NODE_ID == 36){parent = 37; parentChannel = 3; c[14] = 3; c[5] = 4; c[35] = 4; c[37] = 3; c[26] = 8; c[39] = 0; c[25] = 8; c[28] = 5; c[38] = 5; c[30] = 10; c[33] = 7; }
else if(TOS_NODE_ID == 37){parent = 5; parentChannel = 3; c[14] = 7; c[19] = 10; c[5] = 3; c[18] = 1; c[35] = 5; c[26] = 8; c[36] = 3; c[13] = 10; c[17] = 3; c[39] = 6; c[25] = 10; c[28] = 10; c[38] = 9; c[51] = 9; c[30] = 6; c[60] = 6; c[33] = 10; }
else if(TOS_NODE_ID == 38){parent = 37; parentChannel = 9; c[35] = 4; c[37] = 9; c[36] = 5; c[17] = 1; c[39] = 8; c[27] = 2; c[25] = 10; c[28] = 10; c[51] = 3; c[30] = 2; c[53] = 9; c[60] = 9; }
else if(TOS_NODE_ID == 39){parent = 38; parentChannel = 8; c[37] = 6; c[26] = 4; c[36] = 0; c[17] = 3; c[38] = 8; c[30] = 5; }
else if(TOS_NODE_ID == 45){parent = 54; parentChannel = 1; c[31] = 2; c[27] = 8; c[48] = 3; c[58] = 4; c[56] = 10; c[51] = 7; c[55] = 3; c[54] = 1; c[47] = 5; c[60] = 5; c[32] = 2; c[34] = 4; c[33] = 1; c[57] = 2; c[59] = 1; }
else if(TOS_NODE_ID == 46){parent = 57; parentChannel = 0; c[56] = 3; c[51] = 3; c[30] = 6; c[53] = 9; c[57] = 0; c[84] = 6; }
else if(TOS_NODE_ID == 47){parent = 54; parentChannel = 2; c[27] = 10; c[48] = 4; c[58] = 0; c[56] = 6; c[51] = 3; c[55] = 2; c[54] = 2; c[53] = 6; c[60] = 2; c[45] = 5; c[57] = 8; c[59] = 10; }
else if(TOS_NODE_ID == 48){parent = 54; parentChannel = 0; c[35] = 9; c[24] = 9; c[31] = 6; c[27] = 2; c[58] = 5; c[55] = 3; c[54] = 0; c[47] = 4; c[60] = 6; c[32] = 6; c[45] = 3; c[34] = 3; c[33] = 10; }
else if(TOS_NODE_ID == 51){parent = 53; parentChannel = 8; c[37] = 9; c[27] = 8; c[38] = 3; c[58] = 4; c[56] = 7; c[55] = 1; c[54] = 3; c[47] = 3; c[30] = 2; c[53] = 8; c[46] = 3; c[45] = 7; c[57] = 8; c[59] = 9; c[77] = 5; c[84] = 1; c[68] = 0; c[78] = 8; c[75] = 7; }
else if(TOS_NODE_ID == 53){parent = 68; parentChannel = 1; c[38] = 9; c[58] = 4; c[56] = 9; c[51] = 8; c[55] = 9; c[54] = 9; c[47] = 6; c[30] = 2; c[46] = 9; c[57] = 1; c[77] = 10; c[84] = 10; c[68] = 1; c[78] = 7; }
else if(TOS_NODE_ID == 54){parent = 56; parentChannel = 3; c[27] = 4; c[48] = 0; c[58] = 9; c[56] = 3; c[51] = 3; c[55] = 2; c[47] = 2; c[53] = 9; c[45] = 1; c[57] = 10; c[59] = 9; c[84] = 0; c[68] = 0; }
else if(TOS_NODE_ID == 55){parent = 47; parentChannel = 2; c[27] = 7; c[48] = 3; c[58] = 4; c[56] = 3; c[51] = 1; c[54] = 2; c[47] = 2; c[53] = 9; c[45] = 3; c[57] = 10; c[59] = 2; }
else if(TOS_NODE_ID == 56){parent = 51; parentChannel = 7; c[27] = 2; c[58] = 5; c[51] = 7; c[55] = 3; c[54] = 3; c[47] = 6; c[30] = 0; c[53] = 9; c[46] = 3; c[45] = 10; c[57] = 9; c[59] = 4; c[77] = 6; c[84] = 1; c[68] = 6; }
else if(TOS_NODE_ID == 57){parent = 53; parentChannel = 1; c[83] = 1; c[56] = 9; c[51] = 8; c[55] = 10; c[54] = 10; c[47] = 8; c[30] = 1; c[53] = 1; c[46] = 0; c[45] = 2; c[77] = 0; c[84] = 8; c[68] = 0; }
else if(TOS_NODE_ID == 58){parent = 47; parentChannel = 0; c[27] = 0; c[48] = 5; c[56] = 5; c[51] = 4; c[55] = 4; c[54] = 9; c[47] = 0; c[53] = 4; c[45] = 4; c[59] = 3; }
else if(TOS_NODE_ID == 59){parent = 58; parentChannel = 3; c[58] = 3; c[56] = 4; c[51] = 9; c[55] = 2; c[54] = 9; c[47] = 10; c[45] = 1; }
else if(TOS_NODE_ID == 60){parent = 66; parentChannel = 4; c[66] = 4; c[35] = 1; c[37] = 6; c[31] = 0; c[48] = 6; c[38] = 9; c[47] = 2; c[32] = 3; c[45] = 5; c[33] = 9; }
else if(TOS_NODE_ID == 63){parent = 64; parentChannel = 4; c[8] = 6; c[64] = 4; c[77] = 8; c[68] = 3; c[78] = 7; c[69] = 3; c[72] = 4; c[76] = 10; }
else if(TOS_NODE_ID == 64){parent = 1; parentChannel = 0; c[1] = 0; c[9] = 8; c[14] = 6; c[8] = 4; c[4] = 6; c[80] = 4; c[66] = 2; c[63] = 4; }
else if(TOS_NODE_ID == 65){parent = 73; parentChannel = 7; c[73] = 7; c[82] = 6; }
else if(TOS_NODE_ID == 66){parent = 16; parentChannel = 0; c[1] = 6; c[14] = 1; c[8] = 5; c[64] = 2; c[80] = 1; c[5] = 4; c[18] = 8; c[3] = 7; c[11] = 5; c[15] = 3; c[16] = 0; c[67] = 0; c[13] = 6; c[60] = 4; c[72] = 4; c[117] = 1; c[130] = 7; }
else if(TOS_NODE_ID == 67){parent = 9; parentChannel = 0; c[1] = 2; c[9] = 0; c[10] = 9; c[8] = 4; c[4] = 8; c[66] = 0; c[72] = 7; c[70] = 3; c[71] = 9; }
else if(TOS_NODE_ID == 68){parent = 76; parentChannel = 1; c[63] = 3; c[56] = 6; c[51] = 0; c[54] = 0; c[53] = 1; c[57] = 0; c[77] = 1; c[78] = 6; c[69] = 6; c[72] = 10; c[76] = 1; c[75] = 0; c[79] = 8; }
else if(TOS_NODE_ID == 69){parent = 80; parentChannel = 2; c[80] = 2; c[63] = 3; c[77] = 2; c[68] = 6; c[78] = 7; c[72] = 9; c[70] = 2; c[76] = 0; c[75] = 10; c[79] = 10; c[132] = 8; c[123] = 7; c[118] = 6; c[136] = 2; }
else if(TOS_NODE_ID == 70){parent = 78; parentChannel = 0; c[67] = 3; c[77] = 0; c[78] = 0; c[69] = 2; c[72] = 7; c[71] = 9; c[73] = 9; c[82] = 7; }
else if(TOS_NODE_ID == 71){parent = 72; parentChannel = 2; c[67] = 9; c[78] = 9; c[72] = 2; c[70] = 9; c[74] = 1; }
else if(TOS_NODE_ID == 72){parent = 70; parentChannel = 7; c[9] = 5; c[8] = 3; c[66] = 4; c[67] = 7; c[63] = 4; c[77] = 9; c[68] = 10; c[78] = 9; c[69] = 9; c[70] = 7; c[76] = 8; c[75] = 10; c[71] = 2; c[74] = 10; }
else if(TOS_NODE_ID == 73){parent = 119; parentChannel = 4; c[70] = 9; c[133] = 6; c[82] = 0; c[119] = 4; c[65] = 7; }
else if(TOS_NODE_ID == 74){parent = 71; parentChannel = 1; c[72] = 10; c[71] = 1; }
else if(TOS_NODE_ID == 75){parent = 68; parentChannel = 0; c[80] = 7; c[51] = 7; c[77] = 7; c[68] = 0; c[78] = 10; c[69] = 10; c[72] = 10; c[76] = 9; c[79] = 6; c[135] = 1; }
else if(TOS_NODE_ID == 76){parent = 69; parentChannel = 0; c[80] = 0; c[63] = 10; c[77] = 9; c[68] = 1; c[78] = 2; c[69] = 0; c[72] = 8; c[75] = 9; c[79] = 8; c[132] = 9; c[123] = 2; }
else if(TOS_NODE_ID == 77){parent = 75; parentChannel = 7; c[63] = 8; c[56] = 6; c[51] = 5; c[53] = 10; c[57] = 0; c[68] = 1; c[78] = 0; c[69] = 2; c[72] = 9; c[70] = 0; c[76] = 9; c[75] = 7; c[79] = 1; }
else if(TOS_NODE_ID == 78){parent = 68; parentChannel = 6; c[63] = 7; c[51] = 8; c[53] = 7; c[77] = 0; c[68] = 6; c[69] = 7; c[72] = 9; c[70] = 0; c[76] = 2; c[75] = 10; c[79] = 1; c[71] = 9; }
else if(TOS_NODE_ID == 79){parent = 75; parentChannel = 6; c[77] = 1; c[84] = 7; c[68] = 8; c[78] = 1; c[69] = 10; c[76] = 8; c[75] = 6; c[138] = 9; c[139] = 10; }
else if(TOS_NODE_ID == 80){parent = 2; parentChannel = 0; c[64] = 4; c[2] = 0; c[66] = 1; c[69] = 2; c[76] = 0; c[75] = 7; c[132] = 7; c[118] = 7; c[120] = 8; }
else if(TOS_NODE_ID == 82){parent = 65; parentChannel = 6; c[70] = 7; c[73] = 0; c[65] = 6; }
else if(TOS_NODE_ID == 83){parent = 17; parentChannel = 7; c[19] = 9; c[17] = 7; c[57] = 1; c[136] = 5; }
else if(TOS_NODE_ID == 84){parent = 57; parentChannel = 8; c[56] = 1; c[51] = 1; c[54] = 0; c[53] = 10; c[46] = 6; c[57] = 8; c[79] = 7; }
else if(TOS_NODE_ID == 117){parent = 128; parentChannel = 0; c[66] = 1; c[132] = 5; c[123] = 8; c[118] = 10; c[130] = 8; c[126] = 7; c[124] = 4; c[128] = 0; c[122] = 7; }
else if(TOS_NODE_ID == 118){parent = 132; parentChannel = 5; c[80] = 7; c[69] = 6; c[117] = 10; c[132] = 5; c[123] = 0; c[136] = 6; c[126] = 6; c[124] = 4; c[122] = 1; c[120] = 5; }
else if(TOS_NODE_ID == 119){parent = 137; parentChannel = 5; c[73] = 4; c[133] = 6; c[138] = 8; c[139] = 10; c[137] = 5; c[131] = 4; }
else if(TOS_NODE_ID == 120){parent = 118; parentChannel = 5; c[80] = 8; c[132] = 6; c[123] = 1; c[118] = 5; c[136] = 4; c[126] = 3; c[124] = 5; }
else if(TOS_NODE_ID == 122){parent = 131; parentChannel = 1; c[117] = 7; c[132] = 8; c[123] = 3; c[138] = 7; c[118] = 1; c[136] = 9; c[139] = 6; c[137] = 2; c[131] = 1; c[135] = 4; }
else if(TOS_NODE_ID == 123){parent = 135; parentChannel = 5; c[69] = 7; c[117] = 8; c[76] = 2; c[132] = 6; c[138] = 1; c[118] = 0; c[136] = 8; c[126] = 7; c[124] = 0; c[122] = 3; c[120] = 1; c[135] = 5; }
else if(TOS_NODE_ID == 124){parent = 126; parentChannel = 3; c[117] = 4; c[132] = 8; c[123] = 0; c[118] = 4; c[136] = 9; c[130] = 7; c[126] = 3; c[128] = 5; c[120] = 5; }
else if(TOS_NODE_ID == 126){parent = 118; parentChannel = 6; c[117] = 7; c[132] = 2; c[123] = 7; c[118] = 6; c[136] = 8; c[130] = 10; c[124] = 3; c[128] = 1; c[120] = 3; }
else if(TOS_NODE_ID == 128){parent = 130; parentChannel = 9; c[117] = 0; c[130] = 9; c[126] = 1; c[124] = 5; }
else if(TOS_NODE_ID == 130){parent = 126; parentChannel = 10; c[66] = 7; c[117] = 8; c[126] = 10; c[124] = 7; c[128] = 9; }
else if(TOS_NODE_ID == 131){parent = 139; parentChannel = 0; c[133] = 7; c[119] = 4; c[138] = 9; c[122] = 1; c[139] = 0; c[137] = 9; c[135] = 7; }
else if(TOS_NODE_ID == 132){parent = 123; parentChannel = 6; c[80] = 7; c[69] = 8; c[117] = 5; c[76] = 9; c[123] = 6; c[138] = 5; c[118] = 5; c[136] = 5; c[126] = 2; c[124] = 8; c[122] = 8; c[120] = 6; c[135] = 4; }
else if(TOS_NODE_ID == 133){parent = 119; parentChannel = 6; c[73] = 6; c[119] = 6; c[138] = 5; c[139] = 10; c[137] = 2; c[131] = 7; }
else if(TOS_NODE_ID == 135){parent = 131; parentChannel = 7; c[75] = 1; c[132] = 4; c[123] = 5; c[138] = 4; c[136] = 3; c[122] = 4; c[139] = 0; c[131] = 7; }
else if(TOS_NODE_ID == 136){parent = 120; parentChannel = 4; c[83] = 5; c[69] = 2; c[132] = 5; c[123] = 8; c[118] = 6; c[126] = 8; c[124] = 9; c[122] = 9; c[120] = 4; c[135] = 3; }
else if(TOS_NODE_ID == 137){parent = 139; parentChannel = 1; c[133] = 2; c[119] = 5; c[138] = 3; c[122] = 2; c[139] = 1; c[131] = 9; }
else if(TOS_NODE_ID == 138){parent = 79; parentChannel = 9; c[79] = 9; c[132] = 5; c[123] = 1; c[133] = 5; c[119] = 8; c[122] = 7; c[139] = 0; c[137] = 3; c[131] = 9; c[135] = 4; }
else if(TOS_NODE_ID == 139){parent = 138; parentChannel = 0; c[79] = 10; c[133] = 10; c[119] = 10; c[138] = 0; c[122] = 6; c[137] = 1; c[131] = 0; c[135] = 0; }

       for(i=0; i<num; ++i)
         addBuf(TOS_NODE_ID);

       srand(TOS_NODE_ID);
       currentChannel = parentChannel;
       call CC2420Config.setChannel(channels[parentChannel]);
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
     }
     else {
       call CC2420Config.sync();
     }
   }

   void respond()
   {
     if(busy1 == TRUE)
       return;

     if(parent == sender){
       if(bufCount > 0){
         CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt1, sizeof (CaptureMessage)));
         btrpkt->type = MSG_RETURN;
         btrpkt->id = buf[bufCount-1];
         btrpkt->channel = c[parent];
         call CC2420Packet.setPower(&pkt1, POWER);
         if (call RadioAMSend.send(parent, &pkt1, sizeof(CaptureMessage)) == SUCCESS) {
           --bufCount;
           busy1 = TRUE;
         }
       }
     }
     else if(noise == NOISE_ALL || (noise == NOISE_HALF && rand() % 2 == 0)){
       CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt1, sizeof (CaptureMessage)));
       btrpkt->type = 11111;
       btrpkt->id = TOS_NODE_ID;
       btrpkt->channel = c[parent];
       call CC2420Packet.setPower(&pkt1, POWER);
       if (call RadioAMSend.send(sender, &pkt1, sizeof(CaptureMessage)) == SUCCESS) {
         busy1 = TRUE;
       }
     }
     sender = 0;
   }

   event void Timer0.fired() {
     respond();
     call Timer0.stop();
   }

   event void Timer1.fired() {
     if(latency == FALSE){
       if (!busy1) {
         CaptureMessage* btrpkt = (CaptureMessage*)(call RadioPacket.getPayload(&pkt1, sizeof (CaptureMessage)));
         btrpkt->type = MSG_REQUEST;
         btrpkt->id = TOS_NODE_ID;
         btrpkt->channel = currentChannel;
         call CC2420Packet.setPower(&pkt1, POWER);
         if (call RadioAMSend.send(AM_BROADCAST_ADDR, &pkt1, sizeof(CaptureMessage)) == SUCCESS) {
           busy1 = TRUE;
         }
       }
     }
     else if (!busy2){
       if(latencyCnt >= bufCount+700){
         SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt2, sizeof (SuccessMessage)));
         btrpkt->id = 33333;
         btrpkt->cnt = 33333;
         if(call SerialAMSend.send(126, &pkt2, sizeof(SuccessMessage)) == SUCCESS) {
           busy2 = TRUE;
         }

         latency = FALSE;
         latencyCnt = 0;
         call Timer1.stop();
       }
       else if(latencyCnt >= bufCount)
         ++latencyCnt;
       else{
         SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt2, sizeof (SuccessMessage)));
         btrpkt->id = buf[latencyCnt];
         btrpkt->cnt = 0;
         ++latencyCnt;
         if(call SerialAMSend.send(126, &pkt2, sizeof(SuccessMessage)) == SUCCESS) {
           busy2 = TRUE;
         }
       }
     }
   }

   event void Timer2.fired() {

     if(time_send_accum < time_send_max){
       time_send_accum += time_send;
       return;
     }

     time_send_accum = 0;

     while(1){
       uint16_t bExit = 0;
       uint16_t i = 0;

       ++currentChannel;
       if(currentChannel > MAX_CHANNEL){
         SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt2, sizeof (SuccessMessage)));
         btrpkt->id = TOS_NODE_ID;
         btrpkt->cnt = receiveCount;
         if(call SerialAMSend.send(126, &pkt2, sizeof(SuccessMessage)) == SUCCESS) {
           busy2 = TRUE;
         }

         currentChannel = parentChannel;

         if(TOS_NODE_ID == 1){
           latency = TRUE;
           latencyCnt = 0;
         }
         else
           call Timer1.stop();

         call Timer2.stop();

         bExit = 1;
       }
       
       for(i=1; i<=139; ++i){
         if(currentChannel == c[i]){
           bExit = 1;
           break;
         }
       }

       if(bExit == 1)
         break;
     }

     call CC2420Config.setChannel(channels[currentChannel]);
     call CC2420Config.sync();
   }

   event void RadioControl.stopDone(error_t err) {
   }

   event void SerialControl.stopDone(error_t err) {
   }

   event void RadioAMSend.sendDone(message_t* msg, error_t error) {
     if (&pkt1 == msg) {
       busy1 = FALSE;
     }
   }

   event void SerialAMSend.sendDone(message_t* msg, error_t error) {
     if (&pkt2 == msg) {
       busy2 = FALSE;
     }
   }

   event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
     if (len == sizeof(CaptureMessage)/* && TOS_NODE_ID != NODE_PRINTER*/) {
       CaptureMessage* btrpkt = (CaptureMessage*)payload;

       if(btrpkt->type == MSG_REQUEST && c[btrpkt->id] == btrpkt->channel){
         sender = btrpkt->id;
         if(!(btrpkt->id == parent && bufCount == 0)){
           uint16_t i;
           for(i=0; i<rand() % 40; ++i)
             ; // do nothing

           //respond();
           call Timer0.startPeriodic(0);
         }
       }
       else if(btrpkt->type == MSG_RETURN){
         ++receiveCount;
         time_send_accum = 0;
         addBuf(btrpkt->id);
       }
     }
     return msg;
   }

   event message_t* SerialReceive.receive(message_t* msg, void* payload, uint8_t len) {
     time_send_accum = 0;

     currentChannel = 0;
     call CC2420Config.setChannel(channels[0]);
     call CC2420Config.sync();

     call Timer1.startPeriodic(TIMER_PERIOD_MILLI);
     call Timer2.startPeriodic(time_send);
     return msg;
   }
 }
 
