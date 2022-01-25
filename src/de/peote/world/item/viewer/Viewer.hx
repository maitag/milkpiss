package de.peote.world.item.viewer;

import de.peote.world.room.I_Room;
import de.peote.world.I_WorldObject;
import de.peote.world.actor.Actor;
import de.peote.world.item.I_Item;
import de.peote.world.item.viewer.I_Viewer;
import de.peote.world.net.I_ServerLocalView;
import de.peote.world.view.I_View;

import de.peote.world.room.Room;
import de.peote.world.WorldObject;

import de.peote.world.Event.RoomEvent;
import de.peote.world.Event.ControlViewEvent;


/**
 * ...
 * @author semmi
 */

class Viewer extends Item implements I_WorldObject implements I_Viewer implements I_Item
{


	var t_border:Array<I_WorldObject>;
	var b_border:Array<I_WorldObject>;
	var l_border:Array<I_WorldObject>;
	var r_border:Array<I_WorldObject>;
	
	public var t_size:Int = 0;
	public var b_size:Int = 0;
	public var l_size:Int = 0;
	public var r_size:Int = 0;
	
	public var max_t_size:Int = 0;
	public var max_b_size:Int = 0;
	public var max_l_size:Int = 0;
	public var max_r_size:Int = 0;
	
	public var view:I_ServerLocalView;
	public var userNr:Int;
	public var userIsConnected:Bool = true;	
	
	var availableElement:Array<Int>;
	
	public function new(nr:Int, userNr:Int, view:I_ServerLocalView, max_viewer_h_size:Int, max_viewer_v_size:Int) {
		this.userNr = userNr;
		this.view = view;
		
		this.userIsConnected = true;
		
		max_b_size = max_t_size = Math.floor(max_viewer_v_size / 2) - 1;
		max_r_size = max_l_size = Math.floor(max_viewer_h_size / 2) - 1;
		
		availableElement = new Array<Int>(); // 0 is empty element
		// TODO: vorerst nur bei 1 Content pro Room
		var max_avail:Int = Math.floor( Math.min( 0xFFFF,
			2 * (max_b_size + max_t_size + 1) * (max_r_size + max_l_size + 1) + 1));
		for (i in 1...max_avail) availableElement.push(max_avail-i); // TODO: OPTIMIZE
		
		super(nr);
		
		listenEvent(this, ControlViewEvent.INIT,  onEvent);
		listenEvent(this, ControlViewEvent.RESET, onEvent);
		listenEvent(this, ControlViewEvent.RESIZE,onEvent);
	}
	
	function onEvent(event_nr:Int, params:Dynamic):Void
	{
		switch (event_nr) {
            
			case ControlViewEvent.INIT: if (userIsConnected) init();
			case ControlViewEvent.RESET: reset();
			case ControlViewEvent.RESIZE: if (userIsConnected) set_size(params.t, params.b, params.l, params.r);
			// TODO: lieber ControlViewEvent.SROLL_UP usw. events hier ..und nicht unten bei contentLeave() immer scrollen ausloesen ?
			case RoomEvent.ENTER: if (userIsConnected) contentEnter(params.from, params.to, params.obj);
			case RoomEvent.LEAVE: contentLeave(params.from, params.to, params.obj, params.speed);
		}
	}
	
	function init() {
		t_border = new Array();
		b_border = new Array();
		l_border = new Array();
		r_border = new Array();
		
		var root:I_WorldObject = null;
		//if (Type.getClassName(Type.getClass(isin)));
		if ( Std.is(isIn, Room) ) root = isIn;
		else if ( Std.is(isIn, Actor) ) root = isIn.isIn;
		
		//trace(availableElement.length);
		
		t_border.push(root);
		b_border.push(root);
		l_border.push(root);
		r_border.push(root);
		
		add_observe(t_border);
		view.init(userNr, root, max_t_size, max_b_size, max_l_size, max_r_size);
		
	}
	
	function reset() {
		set_size(0, 0, 0, 0);
		del_observe(t_border);
		unlistenAll();
		//trace('reset: ${t_border.length} ${b_border.length} ${l_border.length} ${r_border.length} ');
		//trace(availableElement.length);
		/*t_border = null;
		b_border = null;
		l_border = null;
		r_border = null;*/
		view.onViewerReset(userNr);
	}


	function set_size(t:Int, b:Int, l:Int, r:Int):Void 
	{
		if (t > t_size) for (i in 0...t-t_size) add_top();
		else if (t < t_size) for (i in 0...t_size-t) del_top();
		
		if (b > b_size) for (i in 0...b-b_size) add_bottom();
		else if (b < b_size) for (i in 0...b_size-b) del_bottom();
		
		if (l > l_size) for (i in 0...l-l_size) add_left();
		else if (l < l_size) for (i in 0...l_size-l) del_left();
		
		if (r > r_size) for (i in 0...r-r_size) add_right();
		else if (r < r_size) for (i in 0...r_size-r) del_right();
		
	}
	
	// TODO: OPTIMIZE: ---> ONLY on BORDERs
	function contentEnter(from:I_WorldObject, to:I_WorldObject, obj:I_WorldObject):Void 
	{	
		var elementNr:Null<Int> = obj.viewerElement.get(userNr);
		
		if (elementNr == null) // new element enters (obj. war vorher noch nicht vom viewer registriert)
		{
			elementNr = availableElement.pop();
			obj.viewerElement.set( userNr, elementNr );
			trace("addNewElement elementNr:" + elementNr +" toElementNr:"+to.viewerElement.get(userNr) );
			if (userIsConnected) view.addElementAt( userNr, obj, elementNr, to.viewerElement.get(userNr) );
		}

	}
	
	function contentLeave(from:I_WorldObject, to:I_WorldObject, obj:I_WorldObject, speed:Int):Void 
	{
		var elementNr:Null<Int> = obj.viewerElement.get(userNr);
		
		
		var toElementNr:Null<Int> = null;
		if (to != null) toElementNr = to.viewerElement.get(userNr);// element geloescht
		if ( toElementNr == null ) // new element leaves viewer (without anim)
		{
			if (elementNr != null)
			{
				availableElement.push( elementNr );
				obj.viewerElement.remove( userNr );
				trace("Delete elementNr=" + elementNr);
				if (userIsConnected) view.deleteElement( userNr, elementNr );
			}
			else
			{
				trace(" ----------Delete elementNr PROBLEM?");
			}
		}
		else
		{
			if (elementNr != null)
			{
				trace("moveElementTo: elementNr:"+elementNr + "  toElementNr:"+ toElementNr );
				if (userIsConnected) view.moveElementTo( userNr, elementNr, toElementNr, speed );
				
				// if viewer.isIn moved (akteur der viewer traegt)
				if (obj == this.isIn) {
					trace("VIEWER MOVES");
					if (from.top == to) {
						b_size++; del_bottom();
						t_size--; add_top();
						if (userIsConnected) view.scroll_top( userNr );
					}
					if (from.bottom == to) {
						t_size++; del_top();
						b_size--; add_bottom();
						if (userIsConnected) view.scroll_bottom( userNr );
					}
					if (from.left == to) {
						r_size++; del_right();
						l_size--; add_left();
						if (userIsConnected) view.scroll_left( userNr );
					}
					if (from.right == to) {
						l_size++; del_left();
						r_size--; add_right();
						if (userIsConnected) view.scroll_right( userNr );
					}
				}
			}
			else
			{
				trace(" ----------moveElementTo PROBLEM?");
			}
		}
	}
	
	// add observing worldobject
	inline function add_observe(border:Array<I_WorldObject>):Void 
	{
		for (i in 0...border.length)
		{	
			if (border[i] != null)
			{
				border[i].viewerElement.set( userNr, availableElement.pop() ); // TODO -> peoteViewNr
				if (border[i].content != null)
				{
					border[i].content.viewerElement.set( userNr, availableElement.pop() ); // TODO (recursive viewer on "inner" elements?)
				}
				
				listenEvent(border[i], RoomEvent.LEAVE, onEvent);
				listenEvent(border[i], RoomEvent.ENTER, onEvent);
			}
		}
	}
	
	inline function del_observe(border:Array<I_WorldObject>):Void 
	{
		for (i in 0...border.length)
		{	
			if (border[i] != null)
			{
				unlistenEvent(border[i], RoomEvent.ENTER, onEvent);
				unlistenEvent(border[i], RoomEvent.LEAVE, onEvent);
				
				availableElement.push(  border[i].viewerElement.get(userNr)  ); // elementNr available again
				border[i].viewerElement.remove( userNr );
				if (border[i].content != null)
				{	var elementNr:Null<Int> = border[i].content.viewerElement.get(userNr);
					if (elementNr != null)
					{	trace("del_observe " + elementNr );
						availableElement.push( elementNr ); // TODO (recursive viewer on "inner" elements?)
						border[i].content.viewerElement.remove( userNr );
					}
					else {
						trace("--del_observe-- Problem:  room not observed anymore -> CHECK");
					}
				}
			}
		}
	}
	
	
	// ---------------- increase ----------------------------------
	inline function add_top():Void 
	{
		if (t_size < max_t_size)
		{
			if (horizontal_link_top(t_border)) horizontal_link_left(t_border);
			l_border.unshift(t_border[0]);
			r_border.unshift(t_border[t_border.length - 1]);
			add_observe(t_border);
			view.add_top(userNr, t_border);
			t_size++;
		}
	}
	inline function add_bottom():Void 
	{
		if (b_size < max_b_size)
		{
			if (horizontal_link_bottom(b_border)) horizontal_link_left(b_border);		
			l_border.push(b_border[0]);
			r_border.push(b_border[b_border.length - 1]);
			add_observe(b_border);
			view.add_bottom(userNr, b_border);
			b_size++;
		}
	}
	inline function add_left():Void 
	{
		if (l_size < max_l_size)
		{
			if (vertical_link_left(l_border)) vertical_link_top(l_border);
			t_border.unshift(l_border[0]);
			b_border.unshift(l_border[l_border.length - 1]);
			add_observe(l_border);
			view.add_left(userNr, l_border);
			l_size++;
		}
	}
	inline function add_right():Void 
	{
		if (r_size < max_r_size)
		{
			if (vertical_link_right(r_border)) vertical_link_top(r_border);
			t_border.push(r_border[0]);
			b_border.push(r_border[r_border.length - 1]);
			add_observe(r_border);
			view.add_right(userNr, r_border);
			r_size++;
		}
	}

	// ---------------- decrease ----------------------------------	
	public inline function del_top():Void
	{
		if (t_size > 0)
		{
			view.del_top(userNr, t_border);
			del_observe(t_border);
			if (horizontal_link_bottom(t_border)) horizontal_link_left(t_border);
			l_border.shift();
			r_border.shift();
			t_border[0] = l_border[0];
			t_border[t_border.length-1] = r_border[0];
			t_size--;
		}
	}
	
	inline function del_bottom():Void 
	{
		if (b_size > 0)
		{
			view.del_bottom(userNr, b_border);
			del_observe(b_border);
			if (horizontal_link_top(b_border)) horizontal_link_left(b_border);
			l_border.pop();
			r_border.pop();
			b_border[0] = l_border[l_border.length-1];
			b_border[b_border.length-1] = r_border[r_border.length-1];
			b_size--;
		}
	}	
	inline function del_left():Void 
	{
		if (l_size > 0)
		{
			view.del_left(userNr, l_border);
			del_observe(l_border);
			if (vertical_link_right(l_border)) vertical_link_top(l_border);
			t_border.shift();
			b_border.shift();
			l_border[0] = t_border[0];
			l_border[l_border.length - 1] = b_border[0];
			l_size--;
		}
	}
	inline function del_right():Void 
	{
		if (r_size > 0)
		{
			view.del_right(userNr, r_border);
			del_observe(r_border);
			if (vertical_link_left(r_border)) vertical_link_top(r_border);
			t_border.pop();
			b_border.pop();
			r_border[0] = t_border[t_border.length-1];
			r_border[r_border.length - 1] = b_border[b_border.length - 1];
			r_size--;
		}
	}
	/*
	public function decrease():Void 
	{
		del_top();
		del_bottom();
		del_left();
		del_right();
	}
	*/
	// -----------------------------------------------------------------------
	// -----------------------------------------------------------------------
	// -----------------------------------------------------------------------
	
	inline function horizontal_link_left(border:Array<I_WorldObject>):Void 
	{
		for (j in 0...border.length-1)
		{
			var i = border.length - 1 - j;
			if (border[i-1] == null && border[i] != null)
				if (border[i].left != null)
					border[i-1] = border[i].left;
		}

	}
	inline function horizontal_link_top(border:Array<I_WorldObject>):Bool 
	{
		var not_all:Bool = false;
		for (i in 0...border.length)
		{	
			if (border[i] != null)
			{	if (border[i].top != null)
					border[i] = border[i].top;
				else border[i] = null;
			}
			
			if (border[i] == null)
			{	if (i>0 && border[i-1] != null)
				{	if (border[i-1].right != null)
						border[i] = border[i - 1].right;
					else not_all = true;
				} else not_all = true;
			}
		}
		return(not_all);
	}
	inline function horizontal_link_bottom(border:Array<I_WorldObject>):Bool 
	{
		var not_all:Bool = false;
		for (i in 0...border.length)
		{	
			if (border[i] != null)
			{	if (border[i].bottom != null)
					border[i] = border[i].bottom;
				else border[i] = null;
			}
			
			if (border[i] == null)
			{	if (i>0 && border[i-1] != null)
				{	if (border[i-1].right != null)
						border[i] = border[i - 1].right;
					else not_all = true;
				} else not_all = true;
			}
		}
		return(not_all);
	}

	// -----------------------------------------------------------------------

	inline function vertical_link_top(border:Array<I_WorldObject>):Void 
	{
		for (j in 0...border.length-1)
		{
			var i = border.length - 1 - j;
			if (border[i-1] == null && border[i] != null)
				if (border[i].top != null)
					border[i-1] = border[i].top;
		}
	}
	inline function vertical_link_left(border:Array<I_WorldObject>):Bool 
	{
		var not_all:Bool = false;
		for (i in 0...border.length)
		{	
			if (border[i] != null)
			{	if (border[i].left != null)
					border[i] = border[i].left;
				else border[i] = null;
			}
			
			if (border[i] == null)
			{	if (i>0 && border[i-1] != null)
				{
					if (border[i-1].bottom != null)
						border[i] = border[i - 1].bottom;
					else not_all = true;
				} else not_all = true;
			}
		}
		return(not_all);		
	}
	inline function vertical_link_right(border:Array<I_WorldObject>):Bool 
	{
		var not_all:Bool = false;
		for (i in 0...border.length)
		{	
			if (border[i] != null)
			{	if (border[i].right != null)
					border[i] = border[i].right;
				else border[i] = null;
			}
			
			if (border[i] == null)
			{	if (i>0 && border[i-1] != null)
				{
					if (border[i-1].bottom != null)
						border[i] = border[i - 1].bottom;
					else not_all = true;
				} else not_all = true;
			}
		}
		return(not_all);		
	}


	
}


