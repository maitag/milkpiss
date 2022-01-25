package de.peote.world.actor;

import de.peote.world.I_WorldObject;
import de.peote.world.Event.ActorEvent;
/**
 * ...
 * @author semmi
 */

class Actor extends WorldObject implements I_WorldObject implements I_Actor
{
	// I_Akteur

	public var canFall:Bool = false;
	public var isMoving:Bool = false;

	public var speed:Int = 10;
	
	public function new(nr:Int) 
	{
		super(nr);	
		listenEvent(this, ActorEvent.MOVE_TO, onEvent);
	}
	
	public function onEvent(event_nr:Int, params:Dynamic):Void
	{
		
		switch (event_nr) {
				
				case ActorEvent.MOVE_TO: if ( ! isMoving) moveTo(params.to, speed);
		}
	}
	
	
	
	
	public function moveUp()
	{
		if ( ! isMoving) this.sendTimeEvent( ActorEvent.MOVE_TO,  {"to":isIn.top } );
	}
	public function moveDown()
	{
		if ( ! isMoving) this.sendTimeEvent( ActorEvent.MOVE_TO,  {"to":isIn.bottom } );
	}
	public function moveLeft()
	{
		if ( ! isMoving) this.sendTimeEvent( ActorEvent.MOVE_TO,  {"to":isIn.left } );
	}
	public function moveRight()
	{
		if ( ! isMoving) this.sendTimeEvent( ActorEvent.MOVE_TO,  {"to":isIn.right } );
	}
	
	// INNERE FUNKTIONEN ---------------------------------------
	// ---------------------------------------------------------
	// das worldobject guckt wo es DRINNE ist, und ruft dann die entsprechenden Funktionen des "Ausesseren" Objectes auf
	
	
}