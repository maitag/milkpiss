package de.peote.world;

import de.peote.events.PeoteEvent.Observe;
import de.peote.events.PeoteEvent.ObservedBy;
import haxe.ds.IntMap;


/**
 * ...
 * @author semmi
 */

interface I_WorldObject 
{

	public var nr:Int;
	public var viewerElement:IntMap<Int>;
	
	public var isIn(default, null):I_WorldObject; // isIn kann nicht gesetzt werden, sondern man muss wo.content=... machen (siehe setter unten)
	
	public var content(default, set):I_WorldObject;
	private function set_content(wo:I_WorldObject):I_WorldObject; // setter, damit isIn immer gleichzeitig gesetzt wird

	// events beim next step -> ist nun in commandset
	//public var nextEvent:Int;
	//public var nextEventParams:Dynamic;

	// erweiterte Verknuepfungen
	public var left:I_WorldObject;
	public var right:I_WorldObject;
	public var top:I_WorldObject;
	public var bottom:I_WorldObject;

	
	public function connectLeft(node:I_WorldObject):Void;
	public function connectRight(node:I_WorldObject):Void;
	public function connectTop(node:I_WorldObject):Void;
	public function connectBottom(node:I_WorldObject):Void;


	// innere Funktionen (object selber soll was machen)
	public function moveTo(to:I_WorldObject, speed:Int):Bool;
	
	// auessere Funktionen (mache was mit content)
	public function moveContentTo(to:I_WorldObject, speed:Int):Bool;
		
	// ------------------------------------------------------------------------------------
	// --------------------------- PeoteEvent ---------------------------------------------
	// ------------------------------------------------------------------------------------
	public var observed_by:ObservedBy<Dynamic>;
	public var observe:Observe<Dynamic>;
	
	// IObservable nochmal um cast zu vermeiden
	public function sendTimeEvent(event_nr:Int, send_params:Dynamic = null, delay:Int = 0):Void;
	public function sendEvent(event_nr:Int, send_params:Dynamic = null):Void;
	public function listenEvent(obj:I_WorldObject, event_nr:Int, fkt:Int->Dynamic->Void = null):Void;
	public function unlistenEvent(obj:I_WorldObject, event_nr:Int, fkt:Int->Dynamic->Void = null):Void;

	
}