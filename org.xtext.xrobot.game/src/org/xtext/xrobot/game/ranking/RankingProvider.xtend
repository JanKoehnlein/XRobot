/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.ranking

import com.google.gson.Gson
import com.google.inject.Singleton
import java.io.File
import java.io.FileReader
import java.io.FileWriter
import java.io.Reader
import java.io.Writer
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.dsl.xRobotDSL.Program

@Singleton
class RankingProvider {
	
	static val FILE_NAME = 'rankings.json'
	
	val index = <String, PlayerRanking>newHashMap
	
	new() {
		load
	}
	
	@Accessors(PUBLIC_GETTER)
	PlayerRanking red

	@Accessors(PUBLIC_GETTER)
	PlayerRanking blue
	
	def setBlueAndRed(Program blue, Program red) {
		blue = blue?.ranking
		red = red ?.ranking
	}
	
	def getHallOfFame() {
		index.values.sort
	}
	
	def save() {
		val gson = new Gson
		var Writer writer = null 
		try {
			writer = new FileWriter(FILE_NAME)
			gson.toJson(index.values.toArray(<PlayerRanking>newArrayOfSize(index.size)), writer)
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
				val values = gson.fromJson(reader, typeof(PlayerRanking[]))
				values.forEach[index.put(id, it)]
			} finally {
				reader?.close
			}
		}
	}
	
	def clear() {
		index.clear	
	}

	def getRanking(Program program) {
		val ranking = index.get(program.ID) ?: {
			new PlayerRanking(program.ID, program.name, program.author) => [ newEntry |
				index.put(program.ID, newEntry)
			]
		}
		if (ranking.name != program.name) {
			// The user has changed his program name
			ranking.name = program.name
		}
		if (ranking.author != program.author) {
			// The user has changed his author name
			ranking.author = program.author
		}
		return ranking
	}
	
	private def getID(Program it) {
		eResource.URI.trimFileExtension.lastSegment.toString
	}
}

