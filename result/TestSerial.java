/*									tab:4
 * Copyright (c) 2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * Java-side application for testing serial port communication.
 * 
 *
 * @author Phil Levis <pal@cs.berkeley.edu>
 * @date August 12 2005
 */

import java.io.IOException;
import java.io.*;
import java.util.*;
import java.lang.Thread;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class TestSerial implements MessageListener {

  private MoteIF moteIF;
  private int [] arr;
  private int index = 0;
  
  public TestSerial() {
    arr = new int[]{

128, 130, 126, 120, 118, 65, 132, 73, 123, 24,  // 0
34, 58, 119, 135, 27, 45, 47, 137, 131, 54,  // 10
71, 139, 56, 72, 138, 51, 57, 70, 79, 53,  // 20
78, 75, 68, 17, 76, 60, 39, 69, 66, 38,  // 30
80, 19, 16, 37, 2, 25, 7, 3, 5, 20,  // 40
35, 18, 11, 64, 14, 9, 1, 

};
    create(arr[index]);
  }

  public void create(int port){
    PhoenixSource phoenix = BuildSource.makePhoenix("sf@localhost:" + (10000+port), PrintStreamMessenger.err);
    MoteIF moteIF = new MoteIF(phoenix);
    moteIF.registerListener(new TestSerialMsg(), this);

    TestSerialMsg payload = new TestSerialMsg();

    try {
      moteIF.send(0, payload);
    }
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }
  }

  boolean latency = false;
  int msgCnt[] = new int[150];

  public void messageReceived(int to, Message message) {
    TestSerialMsg msg = (TestSerialMsg)message;

    if(msg.get_id() == 33333){
      /*try {
        BufferedWriter out = new BufferedWriter(new FileWriter("out10.txt", true));

        for(int i=2; i<150; ++i){
          if(msgCnt[i] > 0){
            String s = "" + i + "\t" + msgCnt[i];
            System.out.println(s);
            out.write(s); out.newLine();
          } 
        }

        out.close();
      }catch (IOException e) {
        System.err.println(e); // 에러가 있다면 메시지 출력
        System.exit(1);
      }*/
      return;
    }

    if(latency){
      ++msgCnt[msg.get_id()];
      return;
    }


    String s = "" + msg.get_id() + "\t" + msg.get_cnt();


    try {
      ////////////////////////////////////////////////////////////////
      System.out.println(s);

      BufferedWriter out = new BufferedWriter(new FileWriter("out.txt", true));
      out.write(s); out.newLine();
      out.close();
      ////////////////////////////////////////////////////////////////
    } catch (IOException e) {
        System.err.println(e); // 에러가 있다면 메시지 출력
        System.exit(1);
    }

    if(msg.get_id() == 1)
      latency = true;
    else{
      ++index;
      create(arr[index]);
    }
  }

  public static void main(String[] args) throws Exception {
    TestSerial t = new TestSerial();

// t.o(1); 
// t.o(3); t.o(6); t.o(16); t.o(20); t.o(80); 
// t.o(2); t.o(14); t.o(15); t.o(18); t.o(35); t.o(67); 
// t.o(21); t.o(22); t.o(28); t.o(33); t.o(38); t.o(53); t.o(60); t.o(66); t.o(73); 
// t.o(12); t.o(13); t.o(17); t.o(37); t.o(46); t.o(82); 
// t.o(10); t.o(19); t.o(25); t.o(30); t.o(36); t.o(47); t.o(59); t.o(71); t.o(75); 
// t.o(4); t.o(5); t.o(7); t.o(40); t.o(45); t.o(54); t.o(58); t.o(76); 
// t.o(26); t.o(69); t.o(77); 
// t.o(57); t.o(68); 
// t.o(83); t.o(136); 
// t.o(41); t.o(43); t.o(48); t.o(52); t.o(55); t.o(78); t.o(122); 
// t.o(27); t.o(34); t.o(44); t.o(50); t.o(115); t.o(116); t.o(117); t.o(124); t.o(128); t.o(131); t.o(135); 
// t.o(24); t.o(32); t.o(63); t.o(74); t.o(121); t.o(127); t.o(129); t.o(137); 
// t.o(31); t.o(70); t.o(85); t.o(120); t.o(130); t.o(133); 
// t.o(118); t.o(119); t.o(123); t.o(126); t.o(132); t.o(138); 
// t.o(65); t.o(72); 
// t.o(8); t.o(42); t.o(79); t.o(84); 
  }
}
