package org.xtext.xrobot.api

/**
 * Specification of the geometry of the arena. The arena is bounded by a black circle.
 * As soon as a robot passes the black line it loses.
 */
interface IArena {
	
	/**
	 * The radius of the outer edge of the boundary of the arena.
	 */
	val ARENA_OUTER_RADIUS = 60.0
	
	/**
	 * The radius of the inner edge of the boundary of the arena. Make sure you don't cross
	 * this edge, or you risk losing the game!
	 */
	val ARENA_INNER_RADIUS = 55.0
	
}