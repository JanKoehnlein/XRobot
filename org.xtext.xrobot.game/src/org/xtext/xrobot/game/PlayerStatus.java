package org.xtext.xrobot.game;

public enum PlayerStatus {
	AVAILABLE("Available", ""), 
	PREPARING("Preparing...", "light"), 
	BATTERY_EXHAUSTED("Batteries empty", "error"), 
	NOT_AT_HOME("Place manually", "error"), 
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

