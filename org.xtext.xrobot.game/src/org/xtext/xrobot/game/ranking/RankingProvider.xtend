package org.xtext.xrobot.game

import com.google.inject.Singleton
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

import static java.lang.Math.*

@Singleton
class HallOfFameProvider {
	
	val index = <String, HallOfFameEntry>newHashMap
	
	def addWin(String name) {
		name.entry.addWin
	}
	
	def addDraw(String name) {
		name.entry.addDraw	
	}
	
	def addDefeat(String name) {
		name.entry.addDefeat	
	}
	
	new() {
		// TODO remove dummy entries
		addWin('Miro')
		addWin('Miro')
		addWin('Miro')
		addWin('Miro')
		addDraw('Miro')
		addDefeat('Miro')
		addWin('Sven')
		addDraw('Jan')
		addDraw('Jan')
		addDraw('Mr Roboto')
		addDefeat('Mr Roboto')
		addDefeat('Mr Roboto')
		addWin('Mr Roboto')
		addDefeat('Mr Roboto')
		addDefeat('Mr Roboto')
		addDraw('Arnold')
		addDraw('C3PO')
		addWin('Cameron')
		addDraw('Cameron')
		addWin('Robie')
		addWin('R2D2')
		addWin('Data')
	}
	
	def getHallOfFame() {
		index.values.sort
	}

	private def getEntry(String name) {
		index.get(name) ?: {
			val newEntry = new HallOfFameEntry(name)
			index.put(name, newEntry)
			newEntry
		}
	}
}

@Accessors(PUBLIC_GETTER)
@FinalFieldsConstructor
class HallOfFameEntry implements Comparable<HallOfFameEntry> {

	/**
	 * Number of games needed to get the full points in score 
	 */
	static val NUMBER_OF_GAMES_WEIGHT = 5
	
	val String name
	int wins
	int draws
	int defeats
	double score 
	
	def addWin() {
		wins++
		updateScore
	}
	
	def addDraw() {
		draws++
		updateScore
	}
	
	def addDefeat() {
		defeats++
		updateScore
	}
	
	def getNumGames() {
		wins + draws + defeats
	}

	private def updateScore() {
		 score = min(1, numGames as double / NUMBER_OF_GAMES_WEIGHT) * (3.0 * wins + draws) / numGames  
	}
	
	override compareTo(HallOfFameEntry other) {
		other.score.compareTo(score)
	}
	
}

