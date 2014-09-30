package org.xtext.xrobot.game.display

import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.value.ChangeListener
import javafx.scene.Node
import javafx.scene.layout.Region
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors(PUBLIC_GETTER)
class TopPane extends Region {

	ObjectProperty<Node> leftProperty = new SimpleObjectProperty
	ObjectProperty<Node> centerProperty = new SimpleObjectProperty
	ObjectProperty<Node> rightProperty = new SimpleObjectProperty
	
	new() {
		val ChangeListener<Node> listener = [p,o,n | 
			if(o != null) 
				children -= o
			if(n != null) 
				children += n
					
		] 
		leftProperty.addListener(listener)
		centerProperty.addListener(listener)
		rightProperty.addListener(listener)
	}
	
	def getLeft() {
		leftProperty.get
	}

	def getCenter() {
		centerProperty.get
	}
	
	def getRight() {
		rightProperty.get
	}
	
	def setLeft(Node left) {
		leftProperty.set(left)
	}
	
	def setCenter(Node center) {
		centerProperty.set(center)
	}
	
	def setRight(Node right) {
		rightProperty.set(right)
	}
	
	override protected layoutChildren() {
		val bounds = scene
		val boxWidth = (bounds.width - bounds.height) / 2 
		left => [
			relocate(0,0)
			resize(boxWidth, bounds.height)
		]
		center => [
			relocate(boxWidth, 0)
			resize(bounds.height, bounds.height)
		]
		right => [
			relocate(boxWidth + bounds.height, 0)
			resize(boxWidth, bounds.height)
		]
	}
	
}