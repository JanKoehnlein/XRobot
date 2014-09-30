package org.xtext.xrobot.game.display

import javafx.scene.effect.InnerShadow
import javafx.scene.layout.Region
import javafx.scene.shape.Rectangle
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.IArena
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.server.IRemoteRobot

import static java.lang.Math.*
import javafx.scene.paint.Color

class DistanceBar extends Region {

	static val CENTER_GAP = 50

	val PlayerBar redBar
	val PlayerBar blueBar
	
	new(PlayerSlot blue, PlayerSlot red) {
		children += blueBar = new PlayerBar(blue, 'blue-light') 
		children += redBar = new PlayerBar(red, 'red-light') 
	}
	
	def setEnergyValue(RobotID robot, double value) {
		switch robot {
			case Red: 
				redBar
			case Blue:
				blueBar
		}.setValue(value)
	}
	
	override protected layoutChildren() {
		val center = width / 2
		val maxBarWidth = (width - CENTER_GAP) / 2 
		blueBar => [
			relocate(center - 0.5 * CENTER_GAP - value * maxBarWidth, 0)
			width = value * maxBarWidth
			println(layoutBounds)
		]
		redBar => [
			relocate(center + 0.5 * CENTER_GAP, 0)
			width = value * maxBarWidth
		]
	}
	
	@Accessors
	private static class PlayerBar extends Rectangle implements PlayerSlot.Listener {
		
		double value = 0.5
		
		new(PlayerSlot slot, String style) {
			styleClass += #['energy-bar', style]
			height = 40
			slot.addChangeListener(this)
			effect = new InnerShadow
		}
		
		override slotChanged() {
		}
		
		override stateRead(IRemoteRobot robot) {
		}
		
		override modeChanged(IRemoteRobot robot, Mode newMode) {
		}
		
		override stateChanged(IRemoteRobot robot) {
			value = max(0, IArena.ARENA_RADIUS - robot.centerDirection.distance)  
		}
		
		override variableChanged(String name, Object value) {
		}
		
		override lineChanged(int line) {
		}
	}
	
}