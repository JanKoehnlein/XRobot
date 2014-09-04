package org.lejos.ev3.ldt.preferences;

import org.eclipse.debug.core.ILaunchManager;
import org.lejos.ev3.ldt.launch.LaunchConstants;

/**
 * Constant definitions for plug-in preferences
 * 
 * @author Matthias Paul Scholz and Lawrie Griffiths
 * 
 */
public class PreferenceConstants {

	public static final String KEY_EV3_HOME = "ev3Home";
	public static final String KEY_SEPARATE_JVM = "useSeparateJVM";
	public static final String KEY_SSH_SCP = "useSshScp";
	
	public static final String KEY_TARGET_CONNECT_BY_NAME = "ConnectToName";
	public static final String KEY_TARGET_BRICK_NAME = "ConnectionName";

	public static final String KEY_NORMAL_RUN_AFTER_UPLOAD = ILaunchManager.RUN_MODE+LaunchConstants.SUFFIX_RUN_AFTER_UPLOAD;
	
}
