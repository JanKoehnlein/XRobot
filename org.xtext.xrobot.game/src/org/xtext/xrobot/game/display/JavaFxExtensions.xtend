package org.xtext.xrobot.game.display

import javafx.scene.layout.Region

class JavaFxExtensions {
	static def fixSize(Region it, double width, double height) {
		minWidth = width
		prefWidth = width 
		maxWidth = width
		minHeight = height
		prefHeight = height
		maxHeight = height
	}
}