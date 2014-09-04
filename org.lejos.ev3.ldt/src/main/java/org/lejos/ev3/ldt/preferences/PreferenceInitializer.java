package org.lejos.ev3.ldt.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.core.runtime.preferences.DefaultScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.lejos.ev3.ldt.LeJOSEV3Plugin;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;

/**
 * Class used to initialize default preference values.
 * 
 * @author Matthias Paul Scholz
 * 
 */
public class PreferenceInitializer extends AbstractPreferenceInitializer {

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer#initializeDefaultPreferences()
	 */
	@Override
	public void initializeDefaultPreferences() {
		// new DefaultScope() is the preferred way for Eclipse 3.6, deprecated since Eclipse 3.7
		IEclipsePreferences store = new DefaultScope().getNode(LeJOSEV3Plugin.ID);
		store.putBoolean(PreferenceConstants.KEY_TARGET_CONNECT_BY_NAME, false);
		
		store.putBoolean(PreferenceConstants.KEY_NORMAL_RUN_AFTER_UPLOAD, true);
		// use value of EV3_HOME by default
		String ev3Home = System.getenv("EV3_HOME");
		if (ev3Home != null)
			store.put(PreferenceConstants.KEY_EV3_HOME, ev3Home);
		
		store.putBoolean(PreferenceConstants.KEY_SEPARATE_JVM, LeJOSEV3Util.isWindows()
				|| LeJOSEV3Util.isOSX());
	}

}
