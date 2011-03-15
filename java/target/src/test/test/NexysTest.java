/*
  This file is part of arekinath's Nexys2 JOP
    see <http://github.com/arekinath/jop>

  Copyright (C) 2011, Alex Wilson (alex@cooperi.net)

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package test;

import util.Timer;
import joprt.RtThread;
import com.jopdesign.sys.Nexys2;
import com.jopdesign.io.GPIO;

public class NexysTest {
  public static void main(String[] args) {
    System.out.println("Hello from JOP!");
    
    GPIO gpio = Nexys2.io();
    System.out.print("GPIO with ");
    System.out.print(gpio.ledCount());
    System.out.print(" LEDs, ");
    System.out.print(gpio.switchCount());
    System.out.print(" switches, ");
    System.out.print(gpio.buttonCount());
    System.out.println(" buttons.");
    if (gpio.hasSevenSeg()) {
      System.out.print("Seven segment display with ");
      System.out.print(gpio.sevenSegDigitCount());
      if (gpio.isSevenSegHex())
        System.out.print(" hex");
      System.out.println(" digits.");
    } else {
      System.out.println("Seven segment display not present.");
    }
  
    new RtThread(5, 100000) {
      private int led = 0;
      private int dirn = -1;
      
      public void run() {
        for (;;) {
          GPIO io = Nexys2.io();
        
          io.setLed(led, false);
          
          if (led == 5 || led == 0)
            dirn = dirn * -1;
            
          led += dirn;
          io.setLed(led, true);
          
          waitForNextPeriod();
        }
      }
    };
    
    new RtThread(10, 1000000) {
      private int n = 0;
      private int step = 1;
      
      public void run() {
        for (;;) {
          GPIO io = Nexys2.io();
          
          if (io.checkAndClearButton(0)) {
            step *= -1;
          }
          
          n += step;
          io.setSevenSegValue(n);
          
          System.out.print("Time: ");
          System.out.println(n);
          
          waitForNextPeriod();
        }
      }
    };
  
    RtThread.startMission();
  }
  
  

}
