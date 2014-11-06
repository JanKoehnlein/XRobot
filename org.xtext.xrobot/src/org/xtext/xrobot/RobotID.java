package org.xtext.xrobot;

public enum RobotID {
	
	Blue(0, RobotIpConfig.WIFI_IP_BLUE),
	Red(1, RobotIpConfig.WIFI_IP_RED);

	@SuppressWarnings("unused")
	private static final class RobotIpConfig {
		static final String WIFI_IP_BLUE = "10.10.1.5";
		static final String WIFI_IP_RED = "10.10.1.6";
		static final String BT_IP_BLUE = "10.0.1.1";
		static final String BT_IP_RED = "10.0.1.2";
	}
	
	private int fiducialID;
	private String ipAddress;
	
	RobotID(int fiducialID, String ipAddress) {
		this.fiducialID = fiducialID;
		this.ipAddress = ipAddress;
	}
	
	public int getFiducialID() {
		return fiducialID;
	}

	public String getIpAddress() {
		return ipAddress;
	}

	public RobotID getOpponent() {
		switch (this) {
		case Blue: return Red;
		case Red: return Blue;
		default:
			throw new AssertionError("Missing switch case.");
		}
	}
	
	public static RobotID forFiducialID(int id) {
		RobotID[] values = RobotID.values();
		for (int i = 0; i < values.length; i++) {
			if (values[i].fiducialID == id) {
				return values[i];
			}
		}
		return null;
	}
}
