package org.lejos.ev3.ldt.launch;

import org.eclipse.debug.core.ILaunchManager;
import org.lejos.ev3.ldt.LeJOSEV3Plugin;
import org.lejos.ev3.ldt.preferences.PreferenceConstants;

public class LaunchConstants
{
	public static final String PREFIX = LeJOSEV3Plugin.ID+".";
	
	public static final String SUFFIX_RUN_AFTER_UPLOAD = ".runAfterUpload";
	public static final String SUFFIX_USE_DEFAULT = ".useDefaults";

	public static final String KEY_TARGET_BRICK_NAME = PREFIX+PreferenceConstants.KEY_TARGET_BRICK_NAME;
	public static final String KEY_TARGET_USE_DEFAULTS = PREFIX+"connectionUseDefaults";
	
	public static final String KEY_NORMAL_RUN_AFTER_UPLOAD = PREFIX+ILaunchManager.RUN_MODE+SUFFIX_RUN_AFTER_UPLOAD;
	
	public static final String KEY_NORMAL_USE_DEFAULTS = PREFIX+ILaunchManager.RUN_MODE+SUFFIX_USE_DEFAULT;

}
