package org.xtext.xrobot.game.display

import javafx.scene.layout.Pane

class JavaFxExtensions {
	static def fixSize(Pane it, double width, double height) {
		minWidth = width
		prefWidth = width 
		maxWidth = width
		minHeight = height
		prefHeight = height
		maxHeight = height
	}
}