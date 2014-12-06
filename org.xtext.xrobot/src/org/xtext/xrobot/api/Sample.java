/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.api;

/**
 * Definition of pre-defined audio samples that can be played by robots.
 * 
 * <ul>
 *   <li>{@link #ARNOLD}</li>
 *   <li>{@link #BORG}</li>
 *   <li>{@link #C3PO}</li>
 *   <li>{@link #DALEK}</li>
 *   <li>{@link #HOMER}</li>
 *   <li>{@link #R2D2}</li>
 *   <li>{@link #FOREST}</li>
 *   <li>{@link #DARTHVADER}</li>
 *   <li>{@link #BEBACK}</li>
 *   <li>{@link #CHEWY}</li>
 * </ul>
 */
public enum Sample {
	ARNOLD("Hasta la vista, baby!"), 
	BORG("Resistance is futile."), 
	C3PO("Oh, I am terribly sorry!"), 
	DALEK("Exterminate!"), 
	HOMER("Doh!"), 
	R2D2("Bleeep!"),
	FOREST("Run Forest run!"),
	DARTHVADER("I am your father!"),
	BEBACK("I'll be back!"),
	CHEWY("Chewbacca Growl!");
	
	private String text;
	
	Sample(String text) {
		this.text = text;
	}
	
	public String getText() {
		return text;
	}
}
