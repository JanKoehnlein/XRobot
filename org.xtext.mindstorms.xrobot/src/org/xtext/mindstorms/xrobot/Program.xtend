package org.xtext.mindstorms.xrobot

import java.util.List

class Program implements IProgram {

	List<ISubProgram> subs = newArrayList

	boolean isRunning = true

	ISubProgram activeSub

	new() {
		addSubProgram(new Program.GameOverSub(this))		
	}
	
	override run(IRobot robot) {
		val conditionLoop = new Thread [|
			while (isRunning) {
				synchronized(Program.this) {
					val highestPrioSub = subs.findFirst[
						checkCondition(robot)
					]
					if(activeSub != highestPrioSub) {
						if(activeSub != null) {
							println(activeSub.name + '.stop()')
							activeSub?.stop(robot)
						}
						activeSub = highestPrioSub
					}
				}
				Thread.yield
			}
		]
		conditionLoop.start
		while (isRunning) {
			var ISubProgram activeSubCopy = null
			synchronized(this) {
				activeSubCopy = activeSub
			}
			if(activeSub != null) {
				println(activeSub.name + ".start()")
				activeSubCopy?.run(robot)
			}
			Thread.yield
		}
	}

	override addSubProgram(ISubProgram sub) {
		for (var i = 0; i < subs.size; i++) {
			if (subs.get(i).priority < sub.priority) {
				subs.add(i, sub)
				return true
			}
		}
		subs += sub
	}
	
	static class GameOverSub implements ISubProgram {
		
		Program program
		
		new(Program program) {
			this.program = program
		}
		
		override getName() {
			'Game Over Detector'
		}
		
		override checkCondition(IRobot robot) {
			// TODO: check ground color
			robot.escapePressed
		}
		
		override getPriority() {
			Integer.MAX_VALUE
		}
		
		override run(IRobot robot) {
			program.isRunning = false
		}
		
		override stop(IRobot robot) {
		}
	}
}
