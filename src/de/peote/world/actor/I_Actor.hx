package de.peote.world.actor;

/**
 * ...
 * @author semmi
 */

interface I_Actor 
{
	public var canFall:Bool;
	public var isMoving:Bool;
	
	// innere Funktionen (object selber soll was machen)
	public function moveTo(to:I_WorldObject, speed:Int):Bool;
		
}