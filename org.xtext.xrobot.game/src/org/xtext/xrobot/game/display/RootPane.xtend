package org.xtext.xrobot.game.display

import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.value.ChangeListener
import javafx.scene.Node
import javafx.scene.layout.Region
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors(PUBLIC_GETTER)
class RootPane extends Region {

	ObjectProperty<Node> leftProperty = new SimpleObjectProperty
	ObjectProperty<Node> bottomLeftProperty = new SimpleObjectProperty
	ObjectProperty<Node> centerProperty = new SimpleObjectProperty
	ObjectProperty<Node> rightProperty = new SimpleObjectProperty
	ObjectProperty<Node> bottomRightProperty = new SimpleObjectProperty
	ObjectProperty<Node> overlayProperty = new SimpleObjectProperty
	
	new() {
		styleClass.setAll('root-pane')
		val ChangeListener<Node> listener = [p,o,n | 
			if(o != null) 
				children -= o
			if(n != null) 
				children += n
		] 
		leftProperty.addListener(listener)
		bottomLeftProperty.addListener(listener)
		centerProperty.addListener(listener)
		rightProperty.addListener(listener)
		bottomRightProperty.addListener(listener)
		overlayProperty.addListener(listener)
	}

	def getLeft() {
		leftProperty.get
	}

	def getBottomLeft() {
		bottomLeftProperty.get
	}

	def getCenter() {
		centerProperty.get
	}
	
	def getRight() {
		rightProperty.get
	}

	def getBottomRight() {
		bottomRightProperty.get
	}

	def getOverlay() {
		overlayProperty.get
	}

	def setLeft(Node left) {
		leftProperty.set(left)
	}
	
	def setBottomLeft(Node left) {
		bottomLeftProperty.set(left)
	}
	
	def setCenter(Node center) {
		centerProperty.set(center)
	}
	
	def setRight(Node right) {
		rightProperty.set(right)
	}
	
	def setBottomRight(Node right) {
		bottomRightProperty.set(right)
	}
	
	def setOverlay(Node right) {
		overlayProperty.set(right)
	}
	
	override protected layoutChildren() {
		super.layoutChildren
		val bounds = scene
		val boxWidth = (bounds.width - bounds.height) / 2
		val topHeight = bounds.height * 0.75
		left => [
			relocate(padding.left, padding.top)
			resize(boxWidth - padding.left - padding.right, topHeight - padding.top - padding.bottom)
		]
		bottomLeft => [
			relocate(padding.left, topHeight)
			resize(boxWidth - padding.left - padding.right, bounds.height - topHeight - padding.bottom)
		]
		center => [
			relocate(boxWidth + padding.left, padding.top)
			resize(bounds.height - padding.left - padding.right, bounds.height - padding.top - padding.bottom)
		]
		right => [
			relocate(boxWidth + bounds.height + padding.left, padding.top)
			resize(boxWidth - padding.left - padding.right, topHeight - padding.top - padding.bottom)
		]
		bottomRight => [
			relocate(boxWidth + bounds.height + padding.left, topHeight)
			resize(boxWidth - padding.left - padding.right, bounds.height - topHeight - padding.bottom)
		]
		overlay => [
			relocate(bounds.width / 2, bounds.height / 2)
		]
	}
}