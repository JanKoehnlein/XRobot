package org.xtext.xrobot;

public enum RobotID {
	
	Blue(0, "10.10.1.5"),
	Red(1, "10.10.1.6");
	
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
