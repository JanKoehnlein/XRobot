package org.xtext.xrobot.game;

public enum PlayerStatus {
	AVAILABLE("Available", ""),
	PREPARING("Preparing...", "light"),
	BATTERY_EXHAUSTED("Batteries Empty", "error"),
	NOT_AT_HOME("Place Manually", "error"),
	NO_CAMERA("No Camera Signal", "error"),
	NO_CONNECTION("Connection Failed", "error"),
	READY("Ready", "light"),
	FIGHTING("Fighting", "light"),
	WINNER("Winner", ""),
	LOSER("Loser", ""),
	DRAW("Draw", "");
	
	private String label;
	private String style;
	
	PlayerStatus(String label, String style) {
		this.label = label;
		this.style = style;
	}
	
	public String getLabel() {
		return label;
	}
	
	public String getStyle() {
		return style;
	}
	
}

