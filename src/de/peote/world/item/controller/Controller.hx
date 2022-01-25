package de.peote.world.item.controller;


/**
 * ...
 * @author semmi
 */

class Controller extends WorldObject implements I_Item implements I_WorldObject
{
/*	
	public var viewer:I_Viewer;
	
	public function new(nr:Int, world:World, viewer:I_Viewer) 
	{
		super(nr, world);
		this.viewer = viewer;
	}
	// TODO: der keyboard-input des users kann auch durchs netzwerk kommen!!!
	
	// Logik Prototype TODO: refactoring
	public inline function step():Void
	{
		// den Akteur bewegen der den Controller enthaelt
		var akteur:I_WorldObject = isIn;
		var room:I_WorldObject = akteur.isIn,I_WorldObject;
		var speed = 2;
		
		if ( ! cast(akteur, I_Akteur).isMoving )
		{
			if (InputKeyboard.hasInput() || !InputKeyboard.keySet.isEmpty())
			{
				
				// gucken was gerade gedrueckt ist
				
				if (InputKeyboard.keySet.has(InputKeyboard.LEFT))
				{
					if (akteur.moveTo(room.left, speed)) viewer.viewRoom(room.left);
				}
				else if (InputKeyboard.keySet.has(InputKeyboard.RIGHT))
				{
					if (akteur.moveTo(room.right, speed)) viewer.viewRoom(room.right);
				}
				else if (InputKeyboard.keySet.has(InputKeyboard.UP))
				{
					if (akteur.moveTo(room.top, speed)) viewer.viewRoom(room.top);
				}
				else if (InputKeyboard.keySet.has(InputKeyboard.DOWN))
				{
					if (akteur.moveTo(room.bottom, speed)) viewer.viewRoom(room.bottom);
				}
			}
		}
	}

*/	
	
	
}