
package com.jopdesign.sys;

/**
*	native functions in JOP JVM.
*/

public class Native {
//
// Reihenfolge so lassen!!!
// ergibt static funktionsnummern:
//		1 rd
//		2 wr
//		...
//

	public static native int rd(int adr);
	public static native void wr(int val, int adr);
	public static native int rdMem(int adr);
	public static native void wrMem(int val, int adr);
	public static native int rdIntMem(int adr);
	public static native void wrIntMem(int val, int adr);
	public static native int getSP();
	public static native void setSP(int val);
	public static native int getVP();
	public static native void setVP(int val);
	public static native void int2extMem(int intAdr, int[] extAdr, int cnt);
	public static native void ext2intMem(int[] extAdr, int intAdr, int cnt);
	public static native long makeLong(int hWord, int lWord);
	public static native void invoke(int arg, int ptr);

}
