package org.lejos.ev3.ldt.util;

/**
 * leJOS EV3specific exception
 * 
 * @author Matthias Paul Scholz and Lawrie Griffiths
 *
 */
public class LeJOSEV3Exception extends Exception {
	private static final long serialVersionUID = -1070106791861480795L;

	public LeJOSEV3Exception() {
		super();
	}

	public LeJOSEV3Exception(String arg0) {
		super(arg0);
	}

	public LeJOSEV3Exception(Throwable arg0) {
		super(arg0);
	}

	public LeJOSEV3Exception(String arg0, Throwable arg1) {
		super(arg0, arg1);
	}
}
