/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.display

import com.google.inject.Inject
import javafx.animation.FadeTransition
import javafx.animation.Interpolator
import javafx.animation.ParallelTransition
import javafx.animation.RotateTransition
import javafx.animation.ScaleTransition
import javafx.animation.SequentialTransition
import javafx.geometry.Point3D
import javafx.scene.control.Label
import javafx.scene.control.OverrunStyle
import javafx.scene.effect.InnerShadow
import javafx.scene.layout.StackPane
import javafx.scene.paint.Color

import static extension javafx.util.Duration.*

class IdleProgram extends StackPane {

	@Inject HallOfFameTable hallOfFameTable

	Label logo = new Label('XRobots')

	SequentialTransition animation

	def init() {
		if (children.empty) {
			children += hallOfFameTable
			children += logo => [
				setMaxSize(USE_PREF_SIZE, USE_PREF_SIZE)
				styleClass += #['logo', 'logo-big']
				textOverrun = OverrunStyle.CLIP
				opacity = 0
				effect = new InnerShadow => [
					color = Color.RED
					width = 20
					height = 20
				]
			]
		}
	}

	def start() {
		logo.scaleX = 0
		logo.scaleY = 0
		visible = true
		hallOfFameTable.update
		animation = createAnimation
		animation.play
	}

	def stop() {
		animation.stop
		hallOfFameTable.hide
		logo.opacity = 0
		visible = false
	}

	private def createAnimation() {
		new SequentialTransition => [
			children += hallOfFameTable.animation
			children += new ParallelTransition => [
				children += new RotateTransition => [
					axis = new Point3D(1, 1, 1)
					fromAngle = 0
					toAngle = 720
					node = logo
					interpolator = Interpolator.EASE_OUT
					duration = 600.millis
				]
				children += new ScaleTransition => [
					fromX = 0
					toX = 0.8
					fromY = 0
					toY = 1
					node = logo
					interpolator = Interpolator.EASE_OUT
					duration = 1000.millis
				]
			]
			children += new FadeTransition => [
				fromValue = 1
				toValue = 0
				node = logo
				delay = 5.seconds
				duration = 100.millis
			]
			cycleCount = -1
		]
	}

}
