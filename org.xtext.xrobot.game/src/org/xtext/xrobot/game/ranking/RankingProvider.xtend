package org.xtext.xrobot.game.ranking

import com.google.gson.Gson
import com.google.inject.Singleton
import java.io.File
import java.io.FileReader
import java.io.FileWriter
import java.io.Reader
import java.io.Writer
import java.util.List
import org.xtext.xrobot.dsl.xRobotDSL.Program

@Singleton
class RankingProvider {
	
	static val FILE_NAME = 'rankings.json'
	
	val index = <String, PlayerRanking>newHashMap
		
	new() {
		load		
	}
	
	def getHallOfFame() {
		index.values.sort
	}
	
	def save() {
		val gson = new Gson
		var Writer writer = null 
		try {
			writer = new FileWriter(new File(FILE_NAME))
			gson.toJson(index.values, writer)
			
		} finally {
			writer?.close
		}
	}

	def load() {
		val gson = new Gson
		val file = new File(FILE_NAME)
		if(file.exists) {
			var Reader reader = null
			try {
				reader = new FileReader(file)
				val List<PlayerRanking> values = gson.fromJson(reader, typeof(PlayerRanking[]))
				values.forEach[index.put(name, it)]
			} finally {
				reader?.close
			}
		}
	}
	
	def clear() {
		index.clear	
	}

	def getRanking(Program program) {
		index.get(program.ID) ?: {
			val newEntry = new PlayerRanking(program.ID, program.name)
			index.put(program.ID, newEntry)
			newEntry
		}
	}
	
	private def getID(Program it) {
		eResource.URI.trimFileExtension.lastSegment.toString
	}
}

