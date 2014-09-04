package org.lejos.ev3.ldt.ant;

import java.io.File;

import org.eclipse.ant.core.IAntPropertyValueProvider;
import org.lejos.ev3.ldt.util.LeJOSEV3Exception;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;

public class EV3HomeProvider implements IAntPropertyValueProvider {

	public String getAntPropertyValue(String antPropertyName)
	{
		File ev3Home;
		try {
			ev3Home = LeJOSEV3Util.getEV3Home();
		} catch (LeJOSEV3Exception e) {
			LeJOSEV3Util.log(e);
			return null;
		}
		
		return ev3Home.getAbsolutePath();
	}

}
