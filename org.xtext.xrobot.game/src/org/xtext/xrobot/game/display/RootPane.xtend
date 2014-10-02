package org.xtext.xrobot.game.display

import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.value.ChangeListener
import javafx.scene.Node
import javafx.scene.layout.Region
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors(PUBLIC_GETTER)
class RootPane extends Region {

	ObjectProperty<Node> topProperty = new SimpleObjectProperty
	ObjectProperty<Node> leftProperty = new SimpleObjectProperty
	ObjectProperty<Node> centerProperty = new SimpleObjectProperty
	ObjectProperty<Node> rightProperty = new SimpleObjectProperty
	ObjectProperty<Node> overlayProperty = new SimpleObjectProperty
	
	new() {
		styleClass.setAll('root-pane')
		val ChangeListener<Node> listener = [p,o,n | 
			if(o != null) 
				children -= o
			if(n != null) 
				children += n
		] 
		topProperty.addListener(listener)
		leftProperty.addListener(listener)
		centerProperty.addListener(listener)
		rightProperty.addListener(listener)
		overlayProperty.addListener(listener)
	}

	def getTop() {
		topProperty.get
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

	def getOverlay() {
		overlayProperty.get
	}

	def setTop(Node top) {
		topProperty.set(top)
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
	
	def setOverlay(Node right) {
		overlayProperty.set(right)
	}
	
	override protected layoutChildren() {
		val bounds = scene
		val boxWidth = (bounds.width - bounds.height) / 2
		val topHeight = bounds.height * 0.10
		top => [
			relocate(padding.left, padding.top)
			resize(bounds.width - padding.left - padding.right, topHeight - padding.top - padding.bottom)
		]
		left => [
			relocate(padding.left, topHeight + padding.top)
			resize(boxWidth - padding.left - padding.right, bounds.height - topHeight - padding.top - padding.bottom)
		]
		center => [
			relocate(boxWidth + padding.left, padding.top)
			resize(bounds.height - padding.left - padding.right, bounds.height - padding.top - padding.bottom)
		]
		right => [
			relocate(boxWidth + bounds.height + padding.left, topHeight + padding.top)
			resize(boxWidth - padding.left - padding.right, bounds.height - topHeight - padding.top - padding.bottom)
		]
		overlay => [
			relocate(bounds.width / 2, bounds.height / 2)
		]
	}
	
}