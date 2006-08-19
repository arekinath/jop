/*
 * Created on 30.07.2005
 *
 */
package jvm;

import jvm.math.*;
import jvm.obj.*;

/**
 * @author Martin Schoeberl (martin@jopdesign.com)
 *
 */
public class DoAll {

	public static void main(String[] args) {
		
		TestCase tc[] = {
				new Basic(),
				new Basic2(),
				new TypeMix(),
				new Static(),
				new Array(),
				new Clinit(),
//				new Float(),
				new Imul(),
				new jvm.math.Long(),
				new LongField(),
				new MultiArray(),
				new Switch(),
//				new Except(),
				new SystemCopy(),
		};
		
		for (int i=0; i<tc.length; ++i) {
			System.out.print(tc[i].getName());
			if (tc[i].test()) {
				System.out.println(" ok");
			} else {
				System.out.println(" failed!");
			}
		}
		
//		jbe.DoAll.main(args);
	}
}
