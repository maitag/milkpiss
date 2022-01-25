package de.peote.world.item;

import de.peote.world.I_WorldObject;
import de.peote.world.World;
import de.peote.world.WorldObject;

/**
 * ...
 * @author semmi
 */

class Item extends WorldObject implements I_Item implements I_WorldObject
{
	
	
	// TODO: auch items die andere WorldObjects enthalten koennen
	// public var content:I_Item;
	
	public function new(nr:Int) 
	{
		super(nr);
	}
	
}