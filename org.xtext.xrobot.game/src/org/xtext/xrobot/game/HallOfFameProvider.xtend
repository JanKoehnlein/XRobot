package org.xtext.xrobot.game

import com.google.inject.Singleton
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

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
		addWin('Sven')
		addDraw('Jan')
		addDraw('Jan')
		addDraw('Mr Roboto')
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
	val String name
	int wins
	int draws
	int defeats
	int points
	
	def addWin() {
		wins++
		points += 3
	}
	
	def addDraw() {
		draws++
		points += 1
	}
	
	def addDefeat() {
		defeats++
	}
	
	def getNumGames() {
		wins + draws + defeats
	}
	
	override compareTo(HallOfFameEntry other) {
		other.points - points
	}
	
}

