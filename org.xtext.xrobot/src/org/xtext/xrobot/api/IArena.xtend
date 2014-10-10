package org.xtext.xrobot.api

/**
 * Specification of the geometry of the arena. The arena is bounded by a black circle.
 * As soon as a robot passes the black line it loses.
 */
interface IArena {
	
	/**
	 * The radius of the outer edge of the boundary of the arena in centimeters.
	 * Value is 60cm.
	 */
	val ARENA_OUTER_RADIUS = 60.0
	
	/**
	 * The radius of the inner edge of the boundary of the arena in centimeters. 
	 * Make sure you don't cross this edge, or you risk losing the game!
	 * Value is 55cm
	 */
	val ARENA_INNER_RADIUS = 55.0
	
}