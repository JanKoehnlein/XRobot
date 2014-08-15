package org.xtext.mindstorms.xrobot.net

import java.io.DataInputStream
import java.io.DataOutputStream
import org.xtext.mindstorms.xrobot.Robot

class BrickExecutor {
	
	DataInputStream input
	
	DataOutputStream output
	
	Robot robot
	
	new(DataInputStream input, DataOutputStream output, Robot robot) {
		this.input = input
		this.output = output
		this.robot = robot
	}
	
	def boolean executeNext() {
		val msgType = input.readInt
		println(msgType)
		switch msgType {
			case 0: {
				robot.forward(input.readDouble)
				output.writeBoolean(true)
			}
			case 1: {
				robot.backward(input.readDouble)
				output.writeBoolean(true)
			}
			case 2: {
				robot.travelSpeed = input.readDouble
				output.writeBoolean(true)
			}
			case 3: {
				output.writeDouble(robot.travelSpeed)
			}
			case 4: {
				output.writeDouble(robot.maxTravelSpeed)
			}
			case 5: {
				robot.rotate(input.readDouble)
				output.writeBoolean(true)
			}
			case 6: {
				robot.rotateSpeed = input.readDouble
				output.writeBoolean(true)
			}
			case 7: {
				output.writeDouble(robot.rotateSpeed)
			}
			case 8: {
				output.writeDouble(robot.rotateMaxSpeed)
			}
			case 9: {
				robot.curveForward(input.readDouble, input.readDouble)
				output.writeBoolean(true)
			}
			case 10: {
				robot.curveBackward(input.readDouble, input.readDouble)
				output.writeBoolean(true)
			}
			case 11: {
				robot.curveTo(input.readDouble, input.readDouble)
				output.writeBoolean(true)
			}
			case 12: {
				robot.stop
				output.writeBoolean(true)
			}
			case 17: {
				output.writeBoolean(robot.escapePressed)
			}
			case 18: {
				robot.fireWeapon
				output.writeBoolean(true)
			}
			case 19: {
				output.writeUTF(robot.name)
			}
			case 20: {
				val sample = robot.sample
				sample => [
					output.writeLong(timestamp)
					output.writeDouble(enemyAngle)
					output.writeDouble(enemyDistance)
					output.writeDouble(distance)
					output.writeDouble(groundColor)
					output.writeDouble(contact)
				]
			}
			case -1: {
				output.writeBoolean(true)
				output.flush
				return false
			}
			case -2: {
				output.writeBoolean(true)
			}
		}
		output.flush
		return true
		
	}
}