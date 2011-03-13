package test;

import util.Timer;
import joprt.RtThread;
import com.jopdesign.sys.Nexys2;

public class NexysTest {
  public static void main(String[] args) {
    System.out.println("Hello from JOP!");
  
    new RtThread(5, 100000) {
      private int led = 0;
      private int dirn = -1;
      
      public void run() {
        for (;;) {
          Nexys2.setLed(led, false);
          
          if (led == 5 || led == 0)
            dirn = dirn * -1;
            
          led += dirn;
          Nexys2.setLed(led, true);
          
          waitForNextPeriod();
        }
      }
    };
    
    new RtThread(10, 1000000) {
      private int n = 0;
      
      public void run() {
        for (;;) {
          Nexys2.setSevenSeg(++n);
          System.out.print("Time: ");
          System.out.println(n);
          waitForNextPeriod();
        }
      }
    };
  
    RtThread.startMission();
  }
  
  

}
