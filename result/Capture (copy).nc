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
   uint16_t POWER = 10;
   uint16_t HALFNOISE = 1;
   uint16_t time_send = 100;
   uint16_t time_send_max = 7000;
   uint16_t time_send_accum = 0;
   bool latency = FALSE;
   bool enable = TRUE;
   uint16_t latencyCnt = 0;

   uint16_t parent = 0;
   uint16_t currentChannel = 0;

#define MAX_CHANNEL 3
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
       uint16_t num = 50;

       parent = 11111;

       for(i=0; i<150; ++i)
         c[i] = 100; // set unreachable channel



if(TOS_NODE_ID == 1){parent = 0; c[37] = 0; c[20] = 0; c[3] = 0; c[6] = 0; c[80] = 0; c[2] = 0; c[35] = 0; c[22] = 0; c[13] = 0; c[17] = 0; c[18] = 0; c[75] = 0; c[16] = 0; c[33] = 0; c[12] = 0; }
else if(TOS_NODE_ID == 2){parent = 1; c[1] = 0; c[3] = 0; c[6] = 0; c[80] = 0; c[17] = 0; c[75] = 0; c[10] = 0; c[12] = 0; c[66] = 0; }
else if(TOS_NODE_ID == 3){parent = 1; c[1] = 0; c[6] = 0; c[2] = 0; c[17] = 0; c[18] = 0; c[75] = 0; c[10] = 0; c[12] = 0; }
else if(TOS_NODE_ID == 4){parent = 7; c[7] = 0; c[6] = 0; c[13] = 0; c[19] = 0; c[8] = 0; c[67] = 0; }
else if(TOS_NODE_ID == 5){parent = 7; c[7] = 0; c[13] = 0; c[8] = 0; c[57] = 0; c[38] = 0; c[39] = 0; c[77] = 0; }
else if(TOS_NODE_ID == 6){parent = 1; c[1] = 0; c[37] = 0; c[20] = 0; c[7] = 0; c[3] = 0; c[80] = 0; c[2] = 0; c[35] = 0; c[22] = 0; c[13] = 0; c[18] = 0; c[16] = 0; c[33] = 0; c[12] = 0; c[4] = 0; c[15] = 0; }
else if(TOS_NODE_ID == 7){parent = 6; c[37] = 0; c[6] = 0; c[13] = 0; c[4] = 0; c[19] = 0; c[8] = 0; c[5] = 0; c[39] = 0; c[77] = 0; c[26] = 0; c[36] = 0; }
else if(TOS_NODE_ID == 8){parent = 7; c[7] = 0; c[13] = 0; c[4] = 0; c[5] = 0; }
else if(TOS_NODE_ID == 10){parent = 3; c[3] = 0; c[2] = 0; c[22] = 0; c[17] = 0; c[18] = 0; c[75] = 0; c[12] = 0; c[73] = 0; }
else if(TOS_NODE_ID == 12){parent = 3; c[1] = 0; c[3] = 0; c[6] = 0; c[2] = 0; c[22] = 0; c[17] = 0; c[18] = 0; c[75] = 0; c[10] = 0; c[21] = 0; }
else if(TOS_NODE_ID == 13){parent = 1; c[1] = 0; c[37] = 0; c[7] = 0; c[6] = 0; c[80] = 0; c[35] = 0; c[22] = 0; c[18] = 0; c[33] = 0; c[4] = 0; c[19] = 0; c[8] = 0; c[5] = 0; c[36] = 0; }
else if(TOS_NODE_ID == 14){parent = 20; c[20] = 0; c[18] = 0; c[16] = 0; c[15] = 0; c[21] = 0; }
else if(TOS_NODE_ID == 15){parent = 20; c[20] = 0; c[6] = 0; c[18] = 0; c[16] = 0; c[21] = 0; c[14] = 0; }
else if(TOS_NODE_ID == 16){parent = 1; c[1] = 0; c[20] = 0; c[6] = 0; c[80] = 0; c[18] = 0; c[15] = 0; c[21] = 0; c[14] = 0; }
else if(TOS_NODE_ID == 17){parent = 3; c[1] = 0; c[3] = 0; c[2] = 0; c[22] = 0; c[18] = 0; c[10] = 0; c[12] = 0; }
else if(TOS_NODE_ID == 18){parent = 1; c[1] = 0; c[3] = 0; c[6] = 0; c[80] = 0; c[35] = 0; c[22] = 0; c[13] = 0; c[17] = 0; c[16] = 0; c[10] = 0; c[12] = 0; c[15] = 0; c[21] = 0; c[14] = 0; }
else if(TOS_NODE_ID == 19){parent = 7; c[7] = 0; c[13] = 0; c[4] = 0; }
else if(TOS_NODE_ID == 20){parent = 1; c[1] = 0; c[6] = 0; c[16] = 0; c[15] = 0; c[21] = 0; c[14] = 0; }
else if(TOS_NODE_ID == 21){parent = 20; c[20] = 0; c[22] = 0; c[18] = 0; c[16] = 0; c[12] = 0; c[15] = 0; c[14] = 0; }
else if(TOS_NODE_ID == 22){parent = 1; c[1] = 0; c[6] = 0; c[80] = 0; c[35] = 0; c[13] = 0; c[17] = 0; c[18] = 0; c[10] = 0; c[12] = 0; c[21] = 0; }
else if(TOS_NODE_ID == 24){parent = 31; c[27] = 0; c[31] = 0; c[54] = 0; }
else if(TOS_NODE_ID == 25){parent = 35; c[35] = 0; c[38] = 0; c[36] = 0; c[31] = 0; c[28] = 0; c[44] = 0; c[53] = 0; c[58] = 0; }
else if(TOS_NODE_ID == 26){parent = 37; c[37] = 0; c[7] = 0; c[57] = 0; c[39] = 0; c[36] = 0; }
else if(TOS_NODE_ID == 27){parent = 24; c[37] = 0; c[38] = 0; c[24] = 0; c[31] = 0; c[52] = 0; c[42] = 0; c[30] = 0; c[46] = 0; c[40] = 0; c[45] = 0; }
else if(TOS_NODE_ID == 28){parent = 35; c[37] = 0; c[35] = 0; c[38] = 0; c[25] = 0; c[44] = 0; c[58] = 0; }
else if(TOS_NODE_ID == 30){parent = 38; c[38] = 0; c[39] = 0; c[27] = 0; c[42] = 0; c[55] = 0; c[43] = 0; c[78] = 0; c[48] = 0; }
else if(TOS_NODE_ID == 31){parent = 25; c[24] = 0; c[27] = 0; c[54] = 0; c[25] = 0; c[53] = 0; c[58] = 0; c[60] = 0; c[50] = 0; c[32] = 0; c[59] = 0; }
else if(TOS_NODE_ID == 32){parent = 31; c[33] = 0; c[31] = 0; c[54] = 0; c[60] = 0; c[50] = 0; c[34] = 0; }
else if(TOS_NODE_ID == 33){parent = 1; c[1] = 0; c[37] = 0; c[6] = 0; c[35] = 0; c[13] = 0; c[36] = 0; c[60] = 0; c[32] = 0; }
else if(TOS_NODE_ID == 34){parent = 54; c[54] = 0; c[60] = 0; c[50] = 0; c[32] = 0; }
else if(TOS_NODE_ID == 35){parent = 1; c[1] = 0; c[37] = 0; c[6] = 0; c[22] = 0; c[13] = 0; c[18] = 0; c[33] = 0; c[38] = 0; c[39] = 0; c[36] = 0; c[25] = 0; c[28] = 0; c[60] = 0; c[59] = 0; }
else if(TOS_NODE_ID == 36){parent = 37; c[37] = 0; c[7] = 0; c[35] = 0; c[13] = 0; c[33] = 0; c[38] = 0; c[39] = 0; c[26] = 0; c[25] = 0; c[58] = 0; }
else if(TOS_NODE_ID == 37){parent = 1; c[1] = 0; c[7] = 0; c[6] = 0; c[35] = 0; c[13] = 0; c[33] = 0; c[38] = 0; c[39] = 0; c[26] = 0; c[36] = 0; c[27] = 0; c[28] = 0; c[58] = 0; c[59] = 0; }
else if(TOS_NODE_ID == 38){parent = 37; c[37] = 0; c[35] = 0; c[5] = 0; c[39] = 0; c[36] = 0; c[27] = 0; c[25] = 0; c[28] = 0; c[44] = 0; c[30] = 0; c[58] = 0; c[43] = 0; c[48] = 0; }
else if(TOS_NODE_ID == 39){parent = 37; c[37] = 0; c[7] = 0; c[35] = 0; c[5] = 0; c[57] = 0; c[38] = 0; c[26] = 0; c[36] = 0; c[30] = 0; }
else if(TOS_NODE_ID == 40){parent = 54; c[27] = 0; c[54] = 0; c[44] = 0; c[52] = 0; c[42] = 0; c[46] = 0; c[45] = 0; c[55] = 0; c[43] = 0; c[78] = 0; c[48] = 0; c[60] = 0; c[59] = 0; c[47] = 0; c[69] = 0; }
else if(TOS_NODE_ID == 42){parent = 27; c[27] = 0; c[44] = 0; c[52] = 0; c[30] = 0; c[46] = 0; c[40] = 0; c[45] = 0; c[55] = 0; c[43] = 0; c[78] = 0; c[48] = 0; c[50] = 0; c[47] = 0; c[69] = 0; c[83] = 0; c[84] = 0; }
else if(TOS_NODE_ID == 43){parent = 38; c[38] = 0; c[77] = 0; c[54] = 0; c[44] = 0; c[52] = 0; c[42] = 0; c[30] = 0; c[46] = 0; c[40] = 0; c[45] = 0; c[55] = 0; c[78] = 0; c[48] = 0; c[50] = 0; c[69] = 0; }
else if(TOS_NODE_ID == 44){parent = 38; c[38] = 0; c[54] = 0; c[25] = 0; c[28] = 0; c[52] = 0; c[42] = 0; c[40] = 0; c[45] = 0; c[43] = 0; }
else if(TOS_NODE_ID == 45){parent = 27; c[27] = 0; c[54] = 0; c[44] = 0; c[52] = 0; c[42] = 0; c[46] = 0; c[40] = 0; c[55] = 0; c[43] = 0; c[78] = 0; c[48] = 0; c[60] = 0; c[50] = 0; c[47] = 0; c[69] = 0; }
else if(TOS_NODE_ID == 46){parent = 52; c[27] = 0; c[54] = 0; c[52] = 0; c[42] = 0; c[40] = 0; c[45] = 0; c[43] = 0; c[60] = 0; c[50] = 0; c[47] = 0; }
else if(TOS_NODE_ID == 47){parent = 54; c[54] = 0; c[52] = 0; c[42] = 0; c[46] = 0; c[40] = 0; c[45] = 0; c[50] = 0; }
else if(TOS_NODE_ID == 48){parent = 57; c[57] = 0; c[38] = 0; c[42] = 0; c[30] = 0; c[40] = 0; c[45] = 0; c[55] = 0; c[43] = 0; c[78] = 0; c[69] = 0; c[83] = 0; }
else if(TOS_NODE_ID == 50){parent = 31; c[31] = 0; c[54] = 0; c[52] = 0; c[42] = 0; c[46] = 0; c[45] = 0; c[43] = 0; c[60] = 0; c[32] = 0; c[59] = 0; c[34] = 0; c[47] = 0; }
else if(TOS_NODE_ID == 52){parent = 27; c[27] = 0; c[54] = 0; c[44] = 0; c[42] = 0; c[46] = 0; c[40] = 0; c[45] = 0; c[55] = 0; c[43] = 0; c[60] = 0; c[50] = 0; c[59] = 0; c[47] = 0; c[69] = 0; c[83] = 0; }
else if(TOS_NODE_ID == 53){parent = 31; c[31] = 0; c[25] = 0; c[58] = 0; c[60] = 0; c[59] = 0; }
else if(TOS_NODE_ID == 54){parent = 31; c[24] = 0; c[31] = 0; c[44] = 0; c[52] = 0; c[46] = 0; c[40] = 0; c[45] = 0; c[43] = 0; c[60] = 0; c[50] = 0; c[32] = 0; c[59] = 0; c[34] = 0; c[47] = 0; }
else if(TOS_NODE_ID == 55){parent = 57; c[57] = 0; c[77] = 0; c[52] = 0; c[42] = 0; c[30] = 0; c[40] = 0; c[45] = 0; c[43] = 0; c[78] = 0; c[48] = 0; c[69] = 0; c[83] = 0; c[63] = 0; }
else if(TOS_NODE_ID == 57){parent = 39; c[5] = 0; c[39] = 0; c[26] = 0; c[55] = 0; c[48] = 0; }
else if(TOS_NODE_ID == 58){parent = 38; c[37] = 0; c[38] = 0; c[36] = 0; c[31] = 0; c[25] = 0; c[28] = 0; c[53] = 0; }
else if(TOS_NODE_ID == 59){parent = 37; c[37] = 0; c[80] = 0; c[35] = 0; c[31] = 0; c[54] = 0; c[53] = 0; c[52] = 0; c[40] = 0; c[60] = 0; c[50] = 0; }
else if(TOS_NODE_ID == 60){parent = 35; c[35] = 0; c[33] = 0; c[31] = 0; c[54] = 0; c[53] = 0; c[52] = 0; c[46] = 0; c[40] = 0; c[45] = 0; c[50] = 0; c[32] = 0; c[59] = 0; c[34] = 0; }
else if(TOS_NODE_ID == 63){parent = 67; c[67] = 0; c[73] = 0; c[55] = 0; c[69] = 0; c[83] = 0; c[135] = 0; c[84] = 0; c[65] = 0; c[68] = 0; c[82] = 0; }
else if(TOS_NODE_ID == 65){parent = 66; c[66] = 0; c[67] = 0; c[73] = 0; c[69] = 0; c[83] = 0; c[63] = 0; c[84] = 0; c[68] = 0; c[123] = 0; c[126] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[82] = 0; }
else if(TOS_NODE_ID == 66){parent = 2; c[2] = 0; c[75] = 0; c[73] = 0; c[83] = 0; c[84] = 0; c[65] = 0; c[82] = 0; c[117] = 0; c[119] = 0; }
else if(TOS_NODE_ID == 67){parent = 80; c[80] = 0; c[75] = 0; c[4] = 0; c[63] = 0; c[65] = 0; c[123] = 0; c[133] = 0; c[82] = 0; }
else if(TOS_NODE_ID == 68){parent = 69; c[69] = 0; c[83] = 0; c[63] = 0; c[135] = 0; c[84] = 0; c[65] = 0; c[82] = 0; c[136] = 0; }
else if(TOS_NODE_ID == 69){parent = 77; c[77] = 0; c[73] = 0; c[52] = 0; c[42] = 0; c[40] = 0; c[45] = 0; c[55] = 0; c[43] = 0; c[78] = 0; c[48] = 0; c[83] = 0; c[63] = 0; c[84] = 0; c[65] = 0; c[68] = 0; c[82] = 0; }
else if(TOS_NODE_ID == 70){parent = 76; c[74] = 0; c[71] = 0; c[85] = 0; c[76] = 0; }
else if(TOS_NODE_ID == 71){parent = 73; c[73] = 0; c[84] = 0; c[82] = 0; c[70] = 0; c[74] = 0; c[85] = 0; c[72] = 0; }
else if(TOS_NODE_ID == 72){parent = 71; c[73] = 0; c[84] = 0; c[71] = 0; c[79] = 0; }
else if(TOS_NODE_ID == 73){parent = 80; c[80] = 0; c[75] = 0; c[10] = 0; c[66] = 0; c[69] = 0; c[83] = 0; c[63] = 0; c[84] = 0; c[65] = 0; c[71] = 0; c[85] = 0; c[72] = 0; c[79] = 0; }
else if(TOS_NODE_ID == 74){parent = 76; c[70] = 0; c[71] = 0; c[85] = 0; c[76] = 0; c[124] = 0; }
else if(TOS_NODE_ID == 75){parent = 1; c[1] = 0; c[3] = 0; c[2] = 0; c[10] = 0; c[12] = 0; c[66] = 0; c[67] = 0; c[73] = 0; c[84] = 0; }
else if(TOS_NODE_ID == 76){parent = 85; c[70] = 0; c[74] = 0; c[85] = 0; }
else if(TOS_NODE_ID == 77){parent = 7; c[7] = 0; c[5] = 0; c[55] = 0; c[43] = 0; c[69] = 0; }
else if(TOS_NODE_ID == 78){parent = 42; c[42] = 0; c[30] = 0; c[40] = 0; c[45] = 0; c[55] = 0; c[43] = 0; c[48] = 0; c[69] = 0; }
else if(TOS_NODE_ID == 79){parent = 72; c[73] = 0; c[72] = 0; }
else if(TOS_NODE_ID == 80){parent = 1; c[1] = 0; c[6] = 0; c[2] = 0; c[22] = 0; c[13] = 0; c[18] = 0; c[16] = 0; c[67] = 0; c[73] = 0; c[59] = 0; c[120] = 0; c[137] = 0; }
else if(TOS_NODE_ID == 82){parent = 66; c[66] = 0; c[67] = 0; c[69] = 0; c[83] = 0; c[63] = 0; c[84] = 0; c[65] = 0; c[68] = 0; c[123] = 0; c[129] = 0; c[116] = 0; c[71] = 0; }
else if(TOS_NODE_ID == 83){parent = 66; c[66] = 0; c[73] = 0; c[52] = 0; c[42] = 0; c[55] = 0; c[48] = 0; c[69] = 0; c[63] = 0; c[84] = 0; c[65] = 0; c[68] = 0; c[82] = 0; }
else if(TOS_NODE_ID == 84){parent = 66; c[75] = 0; c[66] = 0; c[73] = 0; c[42] = 0; c[69] = 0; c[83] = 0; c[63] = 0; c[65] = 0; c[68] = 0; c[82] = 0; c[117] = 0; c[119] = 0; c[71] = 0; c[72] = 0; }
else if(TOS_NODE_ID == 85){parent = 71; c[73] = 0; c[70] = 0; c[74] = 0; c[71] = 0; c[76] = 0; }
else if(TOS_NODE_ID == 115){parent = 132; c[123] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[119] = 0; c[120] = 0; c[137] = 0; c[121] = 0; c[138] = 0; c[118] = 0; c[132] = 0; }
else if(TOS_NODE_ID == 116){parent = 128; c[135] = 0; c[65] = 0; c[123] = 0; c[126] = 0; c[133] = 0; c[129] = 0; c[82] = 0; c[117] = 0; c[119] = 0; c[115] = 0; c[121] = 0; c[138] = 0; c[118] = 0; c[132] = 0; c[122] = 0; c[128] = 0; }
else if(TOS_NODE_ID == 117){parent = 132; c[66] = 0; c[84] = 0; c[123] = 0; c[126] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[119] = 0; c[120] = 0; c[115] = 0; c[121] = 0; c[138] = 0; c[118] = 0; c[132] = 0; c[122] = 0; c[128] = 0; }
else if(TOS_NODE_ID == 118){parent = 132; c[123] = 0; c[126] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[119] = 0; c[120] = 0; c[137] = 0; c[115] = 0; c[121] = 0; c[138] = 0; c[132] = 0; c[128] = 0; }
else if(TOS_NODE_ID == 119){parent = 132; c[66] = 0; c[84] = 0; c[123] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[120] = 0; c[115] = 0; c[121] = 0; c[138] = 0; c[118] = 0; c[132] = 0; c[122] = 0; c[128] = 0; c[130] = 0; }
else if(TOS_NODE_ID == 120){parent = 80; c[80] = 0; c[117] = 0; c[119] = 0; c[137] = 0; c[115] = 0; c[121] = 0; c[118] = 0; c[132] = 0; c[130] = 0; }
else if(TOS_NODE_ID == 121){parent = 118; c[133] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[119] = 0; c[120] = 0; c[115] = 0; c[118] = 0; c[132] = 0; }
else if(TOS_NODE_ID == 122){parent = 127; c[135] = 0; c[116] = 0; c[117] = 0; c[119] = 0; c[136] = 0; c[124] = 0; c[128] = 0; c[127] = 0; }
else if(TOS_NODE_ID == 123){parent = 67; c[67] = 0; c[65] = 0; c[126] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[82] = 0; c[117] = 0; c[119] = 0; c[115] = 0; c[138] = 0; c[118] = 0; c[132] = 0; c[128] = 0; c[130] = 0; }
else if(TOS_NODE_ID == 124){parent = 74; c[135] = 0; c[136] = 0; c[74] = 0; c[122] = 0; c[127] = 0; c[131] = 0; }
else if(TOS_NODE_ID == 126){parent = 130; c[65] = 0; c[123] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[138] = 0; c[118] = 0; c[130] = 0; }
else if(TOS_NODE_ID == 127){parent = 124; c[135] = 0; c[136] = 0; c[124] = 0; c[122] = 0; c[128] = 0; }
else if(TOS_NODE_ID == 128){parent = 122; c[135] = 0; c[123] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[119] = 0; c[136] = 0; c[118] = 0; c[122] = 0; c[127] = 0; }
else if(TOS_NODE_ID == 129){parent = 118; c[135] = 0; c[65] = 0; c[123] = 0; c[126] = 0; c[133] = 0; c[116] = 0; c[82] = 0; c[117] = 0; c[119] = 0; c[115] = 0; c[121] = 0; c[138] = 0; c[118] = 0; c[132] = 0; c[128] = 0; c[131] = 0; }
else if(TOS_NODE_ID == 130){parent = 120; c[123] = 0; c[126] = 0; c[119] = 0; c[120] = 0; c[137] = 0; c[138] = 0; c[132] = 0; }
else if(TOS_NODE_ID == 131){parent = 124; c[135] = 0; c[129] = 0; c[136] = 0; c[124] = 0; }
else if(TOS_NODE_ID == 132){parent = 130; c[123] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[119] = 0; c[120] = 0; c[137] = 0; c[115] = 0; c[121] = 0; c[138] = 0; c[118] = 0; c[130] = 0; }
else if(TOS_NODE_ID == 133){parent = 67; c[67] = 0; c[65] = 0; c[123] = 0; c[126] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[119] = 0; c[137] = 0; c[115] = 0; c[121] = 0; c[138] = 0; c[118] = 0; c[132] = 0; }
else if(TOS_NODE_ID == 135){parent = 63; c[63] = 0; c[68] = 0; c[129] = 0; c[116] = 0; c[136] = 0; c[124] = 0; c[122] = 0; c[128] = 0; c[127] = 0; c[131] = 0; }
else if(TOS_NODE_ID == 136){parent = 131; c[135] = 0; c[68] = 0; c[124] = 0; c[122] = 0; c[128] = 0; c[127] = 0; c[131] = 0; }
else if(TOS_NODE_ID == 137){parent = 130; c[80] = 0; c[133] = 0; c[120] = 0; c[115] = 0; c[138] = 0; c[118] = 0; c[132] = 0; c[130] = 0; }
else if(TOS_NODE_ID == 138){parent = 130; c[123] = 0; c[126] = 0; c[133] = 0; c[129] = 0; c[116] = 0; c[117] = 0; c[119] = 0; c[137] = 0; c[115] = 0; c[118] = 0; c[132] = 0; c[130] = 0; }


if(TOS_NODE_ID == 1) num = 0;
else if(TOS_NODE_ID == 2) num = 17;
else if(TOS_NODE_ID == 3) num = 1;
else if(TOS_NODE_ID == 4) num = 50;
else if(TOS_NODE_ID == 5) num = 50;
else if(TOS_NODE_ID == 6) num = 18;
else if(TOS_NODE_ID == 7) num = 0;
else if(TOS_NODE_ID == 8) num = 50;
else if(TOS_NODE_ID == 10) num = 34;
else if(TOS_NODE_ID == 12) num = 43;
else if(TOS_NODE_ID == 13) num = 40;
else if(TOS_NODE_ID == 14) num = 50;
else if(TOS_NODE_ID == 15) num = 50;
else if(TOS_NODE_ID == 16) num = 46;
else if(TOS_NODE_ID == 17) num = 41;
else if(TOS_NODE_ID == 18) num = 42;
else if(TOS_NODE_ID == 19) num = 49;
else if(TOS_NODE_ID == 20) num = 1;
else if(TOS_NODE_ID == 21) num = 50;
else if(TOS_NODE_ID == 22) num = 41;
else if(TOS_NODE_ID == 24) num = 0;
else if(TOS_NODE_ID == 25) num = 31;
else if(TOS_NODE_ID == 26) num = 50;
else if(TOS_NODE_ID == 27) num = 0;
else if(TOS_NODE_ID == 28) num = 49;
else if(TOS_NODE_ID == 30) num = 50;
else if(TOS_NODE_ID == 31) num = 0;
else if(TOS_NODE_ID == 32) num = 50;
else if(TOS_NODE_ID == 33) num = 49;
else if(TOS_NODE_ID == 34) num = 50;
else if(TOS_NODE_ID == 35) num = 0;
else if(TOS_NODE_ID == 36) num = 50;
else if(TOS_NODE_ID == 37) num = 9;
else if(TOS_NODE_ID == 38) num = 37;
else if(TOS_NODE_ID == 39) num = 19;
else if(TOS_NODE_ID == 40) num = 50;
else if(TOS_NODE_ID == 42) num = 50;
else if(TOS_NODE_ID == 43) num = 50;
else if(TOS_NODE_ID == 44) num = 50;
else if(TOS_NODE_ID == 45) num = 50;
else if(TOS_NODE_ID == 46) num = 50;
else if(TOS_NODE_ID == 47) num = 50;
else if(TOS_NODE_ID == 48) num = 50;
else if(TOS_NODE_ID == 50) num = 50;
else if(TOS_NODE_ID == 52) num = 19;
else if(TOS_NODE_ID == 53) num = 50;
else if(TOS_NODE_ID == 54) num = 41;
else if(TOS_NODE_ID == 55) num = 50;
else if(TOS_NODE_ID == 57) num = 2;
else if(TOS_NODE_ID == 58) num = 50;
else if(TOS_NODE_ID == 59) num = 49;
else if(TOS_NODE_ID == 60) num = 50;
else if(TOS_NODE_ID == 63) num = 46;
else if(TOS_NODE_ID == 65) num = 50;
else if(TOS_NODE_ID == 66) num = 14;
else if(TOS_NODE_ID == 67) num = 45;
else if(TOS_NODE_ID == 68) num = 50;
else if(TOS_NODE_ID == 69) num = 47;
else if(TOS_NODE_ID == 70) num = 50;
else if(TOS_NODE_ID == 71) num = 4;
else if(TOS_NODE_ID == 72) num = 14;
else if(TOS_NODE_ID == 73) num = 0;
else if(TOS_NODE_ID == 74) num = 9;
else if(TOS_NODE_ID == 75) num = 49;
else if(TOS_NODE_ID == 76) num = 0;
else if(TOS_NODE_ID == 77) num = 26;
else if(TOS_NODE_ID == 78) num = 50;
else if(TOS_NODE_ID == 79) num = 50;
else if(TOS_NODE_ID == 80) num = 28;
else if(TOS_NODE_ID == 82) num = 50;
else if(TOS_NODE_ID == 83) num = 50;
else if(TOS_NODE_ID == 84) num = 50;
else if(TOS_NODE_ID == 85) num = 0;
else if(TOS_NODE_ID == 115) num = 50;
else if(TOS_NODE_ID == 116) num = 50;
else if(TOS_NODE_ID == 117) num = 50;
else if(TOS_NODE_ID == 118) num = 37;
else if(TOS_NODE_ID == 119) num = 50;
else if(TOS_NODE_ID == 120) num = 0;
else if(TOS_NODE_ID == 121) num = 50;
else if(TOS_NODE_ID == 122) num = 17;
else if(TOS_NODE_ID == 123) num = 50;
else if(TOS_NODE_ID == 124) num = 0;
else if(TOS_NODE_ID == 126) num = 50;
else if(TOS_NODE_ID == 127) num = 25;
else if(TOS_NODE_ID == 128) num = 26;
else if(TOS_NODE_ID == 129) num = 50;
else if(TOS_NODE_ID == 130) num = 0;
else if(TOS_NODE_ID == 131) num = 25;
else if(TOS_NODE_ID == 132) num = 31;
else if(TOS_NODE_ID == 133) num = 50;
else if(TOS_NODE_ID == 135) num = 50;
else if(TOS_NODE_ID == 136) num = 50;
else if(TOS_NODE_ID == 137) num = 50;
else if(TOS_NODE_ID == 138) num = 50;


if(num <= 0)
  enable = FALSE;

       if(num >= 1){
         for(i=1; i<=num; ++i)
           addBuf(TOS_NODE_ID);
       }


       srand(TOS_NODE_ID);
       currentChannel = 0;
       call CC2420Config.setChannel(channels[currentChannel]);
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
     else if((HALFNOISE == 0 || rand() % 2 == 0) && enable == TRUE){
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

     ++currentChannel;
     if(currentChannel >= MAX_CHANNEL){
       SuccessMessage* btrpkt = (SuccessMessage*)(call RadioPacket.getPayload(&pkt2, sizeof (SuccessMessage)));
       btrpkt->id = TOS_NODE_ID;
       btrpkt->cnt = receiveCount;
       if(call SerialAMSend.send(126, &pkt2, sizeof(SuccessMessage)) == SUCCESS) {
         busy2 = TRUE;
       }

       currentChannel = 0;

       if(TOS_NODE_ID == 1){
         latency = TRUE;
         latencyCnt = 0;
       }
       else
         call Timer1.stop();

       call Timer2.stop();
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
     currentChannel = 0;
     time_send_accum = 0;
     call Timer1.startPeriodic(TIMER_PERIOD_MILLI);
     call Timer2.startPeriodic(time_send);
     return msg;
   }
 }
 
