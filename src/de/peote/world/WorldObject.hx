package de.peote.world;

import de.peote.world.I_WorldObject;
import de.peote.events.PeoteEvent.Observe;
import de.peote.events.PeoteEvent.ObservedBy;
import de.peote.events.PeoteTimeslicer;
import de.peote.events.PeoteDLL;
import de.peote.events.PeoteDLLNode;
import de.peote.events.PeoteEventDLL;
import de.peote.events.PeoteEventNode;
import haxe.ds.IntMap;
/**
 * ...
 * @author semmi
 */
//typedef ObservedBy<PARAM> = PeoteEventDLL<PARAM>;
//typedef Observe<PARAM> = PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>;

class WorldObject implements I_WorldObject
{
	// I_WorldObject
	public var nr:Int;
	public var viewerElement:IntMap<Int>; // viewer-userNr -> peote-view elementNr

	public var isIn(default, null):I_WorldObject;
	public var content(default, set):I_WorldObject;

	private function set_content(obj:I_WorldObject):I_WorldObject
	{
		if (obj != null)
		{
			obj.isIn = this;
		}
		return content = obj;
	}
	
	// verknuepfungen
	public var left:I_WorldObject;
	public var right:I_WorldObject;
	public var top:I_WorldObject;
	public var bottom:I_WorldObject;
	

	public function new(nr:Int) 
	{
		this.nr = nr;
		viewerElement = new IntMap();
		initEvents();
	}
	
	public function connectLeft(node:I_WorldObject):Void
	{
		left = node;
		node.right = this;
	}
	
	public function connectRight(node:I_WorldObject):Void
	{
		right = node;
		node.left = this;
	}
	public function connectTop(node:I_WorldObject):Void
	{
		top = node;
		node.bottom = this;
	}
	public function connectBottom(node:I_WorldObject):Void
	{
		bottom = node;
		node.top = this;
	}


	
	
	// INNERE FUNKTIONEN ---------------------------------------
	// das worldobject guckt wo es DRINNE ist, und ruft dann die entsprechenden Funktionen des "Ausesseren" Objectes auf
	public function moveTo(to:I_WorldObject, speed:Int):Bool 
	{
		return isIn.moveContentTo(to, speed);
	}

	// ist dies zu kompliziert und noch SINNVOLL ????
	
	// AUESSERE FUNKTIONEN --------------------------------------- Regeln fuer innere Objecte
	public function moveContentTo(to:I_WorldObject, speed:Int):Bool 
	{
		if (to != null)
		{
			to.content = this.content; this.content = null;
			return true;
		}
		return false;
		
	}
	
	
	// ------------------ neues EVENT-SYSTEM -----------------------------
	// -------------------------------------------------------------------
	public var observed_by:ObservedBy<Dynamic>;
	public var observe:Observe<Dynamic>;
	
	public function initEvents()
	{
		observed_by = new ObservedBy();
		observe      = new Observe();
	}
	
	public function sendTimeEvent(event_nr:Int, send_params:Dynamic = null, delay:Int=0):Void {
		
		World.timeslicer.push(delay/100, observed_by, event_nr, send_params);
	}
	
	public function sendEvent(event_nr:Int, send_params:Dynamic = null) {
		observed_by.send(event_nr, send_params);
	}
	
	public function listenEvent(obj:I_WorldObject, event_nr:Int , callback:Int->Dynamic->Void = null):Void {
		obj.observed_by.listen(observe, event_nr, callback);
	}
	
	public function unlistenEvent(obj:I_WorldObject, event_nr:Int, callback:Int->Dynamic->Void = null):Void {
		obj.observed_by.unlisten(observe, event_nr, callback);
	}
	
	public function unlistenObj(obj:I_WorldObject):Void {
		obj.observed_by.unlistenObj(observe);
	}
	
	public function unlistenAll():Void {
		observed_by.unlistenAll(observe); // mit observed_by wird nix gemacht, koennte auch statisch sein!!!
	}

	public function removeListener(obj:I_WorldObject):Void {
		observed_by.unlistenObj(obj.observe);
	}

	public function removeAllListener():Void {
		observed_by.removeAllListener();
	}


	
	// SERILISATION
	/*
	function hxSerialize( s : haxe.Serializer ) {
		s.serialize(nr);
    }
    function hxUnserialize( s : haxe.Unserializer ) {
        nr = s.unserialize();
    }
	*/

}



