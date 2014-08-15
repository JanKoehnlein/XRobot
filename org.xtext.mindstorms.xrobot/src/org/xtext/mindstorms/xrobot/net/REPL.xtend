package org.xtext.mindstorms.xrobot.net

import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.Iterator

import static extension java.lang.Double.*

class REPL {

	def static void main(String[] args) {
		new REPL().run()
	}

	RemoteRobotServer server

	RemoteRobotProxy _currentRobot

	def run() {
		server = new RemoteRobotServer()
		server.start
		val reader = new BufferedReader(new InputStreamReader(System.in))
		var continue = true
		while (continue) {
			print(
				if (currentRobot == null) {
					'(unconnected) > '
				} else {
					currentRobot?.name + ' > '
				})
			val line = reader.readLine
			val tokens = line.split('\\s').map[trim].filter[!empty]
			continue = execute(tokens.iterator)
		}
		println('Exiting REPL...')
		server.shutdown
		server.join
		println('...finished')
	}
	
	def execute(Iterator<String> it) {
		while (hasNext) {
			try {
				val command = next
				switch command {
					case 'forward',
					case 'f':
						currentRobot.forward(next.parseDouble)
					case 'backward',
					case 'b':
						currentRobot.backward(next.parseDouble)
					case 'speed',
					case 's':
						currentRobot.travelSpeed = next.parseDouble
					case 'rotate',
					case 'r':
						currentRobot.rotate(next.parseDouble)
					case 'rotateSpeed',
					case 'rs':
						currentRobot.travelSpeed = next.parseDouble
					case 'curveForward',
					case 'cf':
						currentRobot.curveForward(next.parseDouble, next.parseDouble)
					case 'curveBackward',
					case 'cb':
						currentRobot.curveBackward(next.parseDouble, next.parseDouble)
					case 'stop', 
					case 'x':
						currentRobot.stop
					case 'liftUp', 
					    case 'l':
						currentRobot.fireWeapon
					case 'sample': {
						println(currentRobot.sample)
					}
					case 'shutdown': {
						currentRobot.shutdown
						_currentRobot = null
					}
					case 'list':
						println('Available robots: ' + server.robotNames.join(', '))
					case 'robot':
						_currentRobot = server.getRobot(next)
					case 'help',
					case '?':
						println(
							'''
								Available commands:
								forward|f <double>                  move forward
								backward|b <double>                 move backward
								speed|s <double>                    set speed
								rotate|r <double>                   rotate by the given angle
								rotateSpeed|rs <double>             set rotation speed
								curveForward|cf <double> <double>   move a in a curve with given radius and angle
								curveBackward|cb <double> <double>  move in a backward curve with given radius and angle
								liftUp|l                            move the shovel up
								stop|x                              stop the robot
								shutdown                            exits the robot's client program
								list                                list available robots
								robot <string>                      choose robot with given name
								quit|q                              quit REPL and server (robots will keep running)
								help|?                              show this message
								
							''')
					case 'quit',
					case 'q': {
						return false
					}
				}
			} catch (Exception exc) {
				System.err.println("Error: " + exc.message)
			}
		}
		return true
	}

	def getCurrentRobot() {
		_currentRobot ?: (_currentRobot = server.getRobot(server.robotNames.sort.head))
	}

}
