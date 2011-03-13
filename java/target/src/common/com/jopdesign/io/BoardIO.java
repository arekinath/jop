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

package com.jopdesign.io;

public final class BoardIO extends HardwareObject {
  private volatile int leds;
  private volatile int sws;
  private volatile int sseg;
  
  final public boolean led(int i) {
    return ((leds & (1 << i)) != 0);
  }
  
  final public void setLed(int i, boolean on) {
    if (on)
      leds = leds | (1 << i);
    else
      leds = leds & ~(1 << i);
  }
  
  final public boolean slider(int i) {
    return ((sws & (1 << i)) != 0);
  }
  
  final public int sevenSeg() {
    return sseg;
  }
  
  final public void setSevenSeg(int value) {
    sseg = value;
  }
}
