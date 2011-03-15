/*
  This file is part of JOP, the Java Optimized Processor
    see <http://www.jopdesign.com/>

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

package com.jopdesign.io;

public final class GPIO extends HardwareObject {
  private volatile int caps;
  private volatile int leds;
  private volatile int sws;
  private volatile int btns;
  private volatile int sseg;
  private volatile int misc;
  
  final public int ledCount() {
    return (caps & 31);
  }
  
  final public int switchCount() {
    return ((caps >>> 5) & 31);
  }
  
  final public int buttonCount() {
    return ((caps >>> 10) & 31);
  }
  
  final public boolean hasSevenSeg() {
    return ((caps >>> 15) & 31) > 0;
  }
  
  final public int sevenSegDigitCount() {
    return ((caps >>> 15) & 15);
  }
  
  final public boolean isSevenSegHex() {
    return ((caps >>> 15) & 16) != 0;
  }
  
  final public int miscCount() {
    return ((caps >>> 20) & 31);
  }
  
  final public boolean isLedOn(int n) {
    return ((leds & (1 << n)) != 0);
  }
  
  final public void setLed(int n, boolean on) {
    if (on)
      leds = leds | (1 << n);
    else
      leds = leds & ~(1 << n);
  }
  
  final public boolean isSwitchOn(int n) {
    return ((sws & (1 << n)) != 0);
  }
  
  final public int sevenSegValue() {
    return sseg;
  }
  
  final public void setSevenSegValue(int value) {
    sseg = value;
  }
  
  final public boolean checkAndClearButton(int n) {
    boolean v = ((btns & (1 << n)) != 0);
    btns = (1 << n);
    return v;
  }
  
  final public int getMisc() {
    return misc;
  }
  
  final public void setMisc(int value) {
    misc = value;
  }
}
