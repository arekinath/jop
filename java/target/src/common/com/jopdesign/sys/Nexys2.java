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

package com.jopdesign.sys;

import com.jopdesign.sys.Const;
import com.jopdesign.sys.JVMHelp;
import com.jopdesign.sys.Native;
import com.jopdesign.io.GPIO;

public class Nexys2 {
  private GPIO bio;
  
  private static int BIO_PTR;
	private static int BIO_MTAB;

  Nexys2() {
    bio = (GPIO) makeHWObject(new GPIO(), Const.GPIO_BASE, 0);
  }
  
  private static Object makeHWObject(Object o, int address, int idx) {
		int cp = Native.rdIntMem(Const.RAM_CP);
		return JVMHelp.makeHWObject(o, address, idx, cp);
	}
	
	private static Nexys2 single = new Nexys2();
	
	public static Nexys2 getInstance() {
	  return single;
	}
	
	public GPIO getGPIO() {
	  return bio;
	}
	
	public static GPIO io() {
	  return single.getGPIO();
	}
}
