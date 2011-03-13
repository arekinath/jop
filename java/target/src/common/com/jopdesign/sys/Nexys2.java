/*
  Customised LED & switch interface for Nexys2 board
*/

package com.jopdesign.sys;

import com.jopdesign.sys.Const;
import com.jopdesign.sys.JVMHelp;
import com.jopdesign.sys.Native;

public class Nexys2 {
  public static void setLed(int i, boolean on) {
    int cval = Native.rd(Const.NX_LEDS);
    if (on)
      cval = cval | (1 << i);
    else
      cval = cval & ~(1 << i);
    Native.wr(cval, Const.NX_LEDS);
  }
  
  public static boolean getLed(int i) {
    int cval = Native.rd(Const.NX_LEDS);
    if ((cval & (1 << i)) != 0)
      return true;
    else
      return false;
  }
  
  public static boolean getSwitch(int i) {
    int sval = Native.rd(Const.NX_SWS);
    if ((sval & (1 << i)) != 0)
      return true;
    else
      return false;
  }
  
  public static int getSevenSeg() {
    int ssval = Native.rd(Const.NX_SSEG);
    return ssval;
  }
  
  public static void setSevenSeg(int val) {
    Native.wr(val, Const.NX_SSEG);
  }
}
