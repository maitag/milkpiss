package de.peote.world.actor;

import de.peote.world.I_WorldObject;

/**
 * ...
 * @author semmi
 */

class Stone extends Actor implements I_Actor implements I_WorldObject
{

	public function new(nr:Int) 
	{
		super(nr);
		canFall = true;
		isMoving = false;
	}
	
}