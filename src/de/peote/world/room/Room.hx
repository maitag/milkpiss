package de.peote.world.room;

import de.peote.world.actor.I_Actor;
import de.peote.world.Event.RoomEvent;
import de.peote.world.room.I_Room;
/**
 * ...
 * @author semmi
 */

class Room extends WorldObject implements I_WorldObject implements I_Room
{	
	
	public function new(nr:Int)
	{	super(nr);
		listenEvent(this, RoomEvent.LEAVE, onEvent);
		listenEvent(this, RoomEvent.ENTER, onEvent);
	}

	public function onEvent(event_nr:Int, params:Dynamic):Void
	{
		var fallSpeed = 50;
		//var fallSpeed = 4 + Math.floor(Math.random()*2);
		
		switch (event_nr) {
            
			case RoomEvent.LEAVE:
				//trace("RoomEvent.LEAVE");
				if (canFall(top))
				{
					if (canFallDown(top) && cast(top.content, I_Actor).isMoving == false)
					{
						//cast(top.content, I_Akteur).isMoving = true;
						top.moveContentTo(this, fallSpeed);
						return;
					}
				}
				if (canFallSideDown(top))
				{	
					if (canFall(top.right) && cast(top.right.content, I_Actor).isMoving == false)
					{
						// TODO: wenn sich etwas rechts runterbewegt, dann erst im next step: if (right != cast(params.to, I_WorldObject))
						//cast(top.right.content, I_Akteur).isMoving = true;
						top.right.moveContentTo(top, fallSpeed-10);
						return;
					}
					else if (canFall(top.left) && cast(top.left.content, I_Actor).isMoving == false)
					{
						// TODO: wenn sich etwas links runterbewegt, dann erst im next step: if (left != cast(params.to, I_WorldObject))
						//cast(top.left.content, I_Akteur).isMoving = true;
						top.left.moveContentTo(top, fallSpeed-10);
						return;
					}
				}
				if (canFallSideDown(this))
				{ 
					if (canFall(right) && right != cast(params.to, I_WorldObject) && cast(right.content, I_Actor).isMoving == false)
					{
						//cast(right.content, I_Akteur).isMoving = true;
						right.moveContentTo(this, fallSpeed-10);
						return;
					}
					else if (canFall(left) && left != cast(params.to, I_WorldObject) && cast(left.content, I_Actor).isMoving == false)
					{
						//cast(left.content, I_Akteur).isMoving = true;
						left.moveContentTo(this, fallSpeed-10);
						return;
					}
				}
				
            case RoomEvent.ENTER:
				
				//trace("RoomEvent.ENTER");
				
				if (canFall(this))
				{
					if (canFallDown(this))
					{
						//params.obj.isMoving = true;
						if (moveContentTo(this.bottom, fallSpeed)) return;
					}
					else if (canFallSideDown(this.right))
					{
						//params.obj.isMoving = true;
						if (moveContentTo(this.right, fallSpeed-10)) return;
					}
					else if (canFallSideDown(this.left))
					{
						//params.obj.isMoving = true;
						if (moveContentTo(this.left, fallSpeed-10)) return;
					}
					//else params.obj.isMoving = false;
				}
				
				params.obj.isMoving = false;
				
        }
		
    }
	
	public inline function canFall(room:I_WorldObject):Bool 
	{
		if (room.content != null)
		{	if (cast(room.content, I_Actor).canFall)
			{	return true;
			}
			else return false;
		}
		else return false;
	}

	public inline function canFallDown(room:I_WorldObject):Bool 
	{
		if (room.bottom != null)
		{	if (room.bottom.content != null)
			{	if (room.bottom.content.nr == 0) // TODO: nummern durch properties der objekte ersetzen
				{	return true;
				}
				else return false;
			}
			else return true;
		}
		else return false;
	}
	
	public inline function canFallSideDown(side_room:I_WorldObject):Bool 
	{
		if (side_room != null)
		{	if (side_room.content != null) 
			{	if (side_room.content.nr == 0) // TODO: nummern durch properties der objekte ersetzen
				{	return canFallDown(side_room);
				}
				else return false;
			}
			else return canFallDown(side_room);
		}
		else return false;
	}
	
	
	// INNERE FUNKTIONEN ---------------------------------------
	// ---------------------------------------------------------
	// Hier die Funktionen wenn die INNEREN ihre move Funktion aufrufen
	// (dann bestimmt diese class wie MOVE speziell aussehen soll!!!!
	
	// WELT (Regeln innerhalb der room links rechts oben unten verknuepfungen)
	// die Rooms bestimmen ihre Welt-REGELN
	
	
	// AUESSERE FUNKTIONEN ---------------------------------------
	// -----------------------------------------------------------
	override public function moveContentTo(to:I_WorldObject, speed:Int):Bool 
	{	
		//trace("room:moveContentTo");
		if (to != null)
		{
			//if (cast(content, I_Akteur).isMoving) return false;
			if (to.content != null)
			{   // TODO: GRUPPEN bilden und RULES (wer darf wen bewegen?)
				if (to.content.nr == 0 || (this.content.nr == 5 && to.content.nr == 1)) 
				{	
					// delete element (TODO!)
					if (to.content.nr == 1) to.sendTimeEvent( RoomEvent.LEAVE, { "from":to, "to":null, "obj":to.content } );
					
					cast(content, I_Actor).isMoving = true;
					super.moveContentTo(to, speed);
					// Events im next Step ausloesen
					
					// LEAVE-Event kommt gleich -> klappt nicht!
					//this.onEvent(RoomEvent.LEAVE, { "from":this, "to":to, "obj":to.content } );
					this.sendTimeEvent( RoomEvent.LEAVE, { "from":this, "to":to, "obj":to.content, "speed":speed } );
					to.sendTimeEvent( RoomEvent.ENTER, { "from":this, "to":to, "obj":to.content }, speed );
					
					return true;
				}
			}
			else
			{	
				cast(content, I_Actor).isMoving = true;
				super.moveContentTo(to, speed);
				// Events im next Step ausloesen
				
				// LEAVE-Event kommt gleich -> klappt nicht!
				//this.onEvent(RoomEvent.LEAVE, { "from":this, "to":to, "obj":to.content } );
				this.sendTimeEvent( RoomEvent.LEAVE, { "from":this, "to":to, "obj":to.content, "speed":speed } );
				to.sendTimeEvent( RoomEvent.ENTER, { "from":this, "to":to, "obj":to.content }, speed);
				
				return true;
			}
		}
		return false;
	}
	
	


}