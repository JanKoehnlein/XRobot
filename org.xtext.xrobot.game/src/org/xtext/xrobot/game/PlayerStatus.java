/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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

