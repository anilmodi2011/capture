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
 * @author Phil Levis <pal@c57s.berkeley.edu>
 * @date August 12 2005
 */

import java.io.IOException;
import java.io.*;
import java.util.*;
import java.util.Timer;
import java.util.TimerTask;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class TestSerial implements MessageListener {

  static private int [] arr;
  static private int index = 42;
  static public MoteIF moteIF;
  static public boolean received;
  static public Timer timer;
  static public TimerTask task;
  
  public TestSerial() {
    arr = new int[]{

1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
24, 25, 26, 27, 28, 30, 31, 32, 33, 34, 
35, 36, 37, 38, 39, 40, 45, 46, 47, 48, 
51, 53, 54, 55, 56, 57, 58, 59, 60, 63, 
64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 
84, 85, 117, 118, 119, 120, 122, 123, 124, 126, 
128, 130, 131, 132, 133, 135, 136, 137, 138, 139

};

    create();
  }

  public static void sendMessage()
  {
    if(received)
      return;

    TestSerialMsg payload = new TestSerialMsg();

    try {
      moteIF.send(0, payload);
    }
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }

    timer = new Timer();
    task = new TimerTask(){
      @Override
      public void run(){
        TestSerial.sendMessage();
      }
    };
    timer.schedule(task, 20000);
  }

  public void create(){
    PhoenixSource phoenix = BuildSource.makePhoenix("sf@localhost:" + (10000+arr[index]), PrintStreamMessenger.err);
    moteIF = new MoteIF(phoenix);
    moteIF.registerListener(new TestSerialMsg(), this);

    received = false;
    sendMessage();
  }

  public void messageReceived(int to, Message message) {
    TestSerialMsg msg = (TestSerialMsg)message;

    received = true;

    if(msg.get_stage() == 0){
      ++index;
      if(index <= 90)
        create();

      return;
    }

    String s = "" + msg.get_commander() + "\t" + 
                    msg.get_nodeid1() + "\t" + 
                    msg.get_nodeid2() + "\t" + 
                    msg.get_stage() + "\t" + 
                    msg.get_countcapture1() + "\t" + 
                    msg.get_countcapture2() + "\t" + 
                    msg.get_serialno() + "\t" + 
                    msg.get_capture1() + "\t" + 
                    msg.get_nbr1capture()[0] + "\t" + 
                    msg.get_nbr1capture()[1] + "\t" + 
                    msg.get_capture2();


    try {
      ////////////////////////////////////////////////////////////////
      if(msg.get_stage() == 5 || msg.get_stage() == 3){
        BufferedWriter out = new BufferedWriter(new FileWriter("data.txt", true));
        out.write(s); out.newLine();
        out.close();
      }
      System.out.println(s);
      ////////////////////////////////////////////////////////////////
    } catch (IOException e) {
        System.err.println(e); // 에러가 있다면 메시지 출력
        System.exit(1);
    }
  }
  
  public static void main(String[] args) throws Exception {
    TestSerial serial = new TestSerial();
  }


}
