package org.xtext.xrobot.api;

public enum Sample {
	ARNOLD("Hasta la vista, baby!"), 
	BORG("Resistance is futile."), 
	C3PO("Oh, I am terribly sorry!"), 
	DALEK("Exterminate!"), 
	HOMER("Doh!"), 
	R2D2("Bleeep!");
	
	private String text;
	
	Sample(String text) {
		this.text = text;
	}
	
	public String getText() {
		return text;
	}
}
