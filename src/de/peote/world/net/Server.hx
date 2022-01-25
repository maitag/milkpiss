package de.peote.world.net;

import de.peote.io.PeoteBytes;
import de.peote.io.PeoteBytesInput;
import de.peote.io.PeoteBytesOutput;
import de.peote.world.actor.Actor;

import de.peote.net.PeoteServer;

import de.peote.world.I_WorldObject;
import de.peote.world.actor.I_Actor;
import de.peote.world.item.viewer.I_Viewer;
import de.peote.world.item.viewer.Viewer;
import de.peote.world.net.I_ServerLocalView;

import haxe.ds.IntMap;

import de.peote.world.Event.ControlViewEvent;

/**
 * ...
 * @author semmi
 */

class Server extends WorldObject implements I_WorldObject implements I_ServerLocalView  // TODO: really inside World?
{
	var peoteServer:PeoteServer;
	var available_actors:Array<I_WorldObject>;
	var active_actors:IntMap<I_WorldObject>;
	var active_viewer:IntMap<I_Viewer>;
	
	var max_viewer_h_size:Int = 0;
	var max_viewer_v_size:Int = 0;
	
	public function new(available_actors:Array<I_WorldObject>, max_viewer_h_size:Int, max_viewer_v_size:Int) 
	{
		this.available_actors = available_actors;
		this.max_viewer_h_size = max_viewer_h_size;
		this.max_viewer_v_size = max_viewer_v_size;
		active_actors = new IntMap();
		active_viewer = new IntMap();
		
		super(0);
		peoteServer = new PeoteServer({
				onCreateJoint:      onCreateJoint,
				onCreateJointError: onCreateJointError,
				onUserConnect:      onUserConnect,
				onUserDisconnect:   onUserDisconnect,
				onData: onData
			});
	}
	
	public function create(name:String, server:String="localhost", port:Int = 7680):Void
	{
		peoteServer.createJoint(server, port, name);
	}
	
	function onCreateJoint(jointNr:Int):Void 
	{
		trace("onCreateJoint:"+jointNr);
	}
	
	function onCreateJointError(errorNr:Int):Void 
	{
		trace("onCreateJointError:"+errorNr);
	}
	
	function onUserConnect(jointNr:Int, userNr:Int):Void 
	{
		// trace("onUserConnect: jointNr=" + jointNr + ", userNr=" + userNr);
		
		// 1) auth
		// 2) acteur + viewer erzeugen
		
		var actor:I_WorldObject = available_actors.pop();
		if (actor != null) // actor available
		{
			active_actors.set(userNr, actor);
			// create viewer
			
			var viewer:Viewer = new Viewer(0, userNr, this, max_viewer_h_size, max_viewer_v_size);
			actor.content = cast( viewer, I_WorldObject);
			//trace("  --actor.content = cast( viewer, I_WorldObject)");
			active_viewer.set(userNr, viewer);
			//trace("  --active_viewer.set(userNr, viewer)");
			
			viewer.sendTimeEvent(ControlViewEvent.INIT);

			//var controller = new Controller(0, viewer);

			// TODO: send minimal needed client version

		}
		else
		{
			trace("error, no actor available");
			// TODO : PeoteNet erweitern um user zu disconnecten
			//peoteServer.disconnectUser(userNr); 
		}
	}
	
	function onUserDisconnect(jointNr:Int, userNr:Int, reason:Int):Void
	{
		//trace("onUserDisconnect: jointNr=" + jointNr + ", userNr=" + userNr + ", reason=" + reason);
		
		
		var viewer:Viewer = cast( active_viewer.get(userNr), Viewer);
		viewer.userIsConnected = false;
		
		viewer.sendTimeEvent(ControlViewEvent.RESET);
	}
	
	public function onViewerReset(userNr:Int):Void
	{
		var actor:I_WorldObject = active_actors.get(userNr);
		actor.content = null;
		active_actors.remove(userNr);
		active_viewer.remove(userNr);
		available_actors.unshift( actor );
		//trace("-------------RESET--------------------");
	}

	public inline function onData(jointNr:Int, userNr:Int, peoteBytes:PeoteBytes ):Void 
	{
		if (active_actors.get(userNr) != null) // todo: optimize valid-userNr-CHECK
		{
		
			//trace("onData: jointNr="+jointNr+", userNr="+userNr);

			// TODO: CHUNKS!!!!! ---------!!          DONT FORGET!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! <<< --- TODOTODOTODO
			
			var input:PeoteBytesInput = new PeoteBytesInput(peoteBytes);
			var command:Int = input.readByte();
			switch (command)
			{
				case Command.INIT:
					//trace("Command.INIT: "+input.readString());
					
				case Command.RESIZE:
					//trace("Command.RESIZE");
					var param:Dynamic = {t:0,b:0,l:0,r:0};
					param.t = input.readUInt16();
					param.b = input.readUInt16();
					param.l = input.readUInt16();
					param.r = input.readUInt16();
					var viewer:Viewer = cast( active_viewer.get(userNr), Viewer);
					viewer.sendTimeEvent(ControlViewEvent.RESIZE, param);
					
				case Command.MOVE_UP: trace("Command.MOVE_UP");
					var actor:Actor = cast( active_actors.get(userNr), Actor);
					actor.moveUp();
					// todo: lieber hier scroll_up controlview event ausloesen ?
				case Command.MOVE_DOWN: trace("Command.MOVE_DOWN");
					var actor:Actor = cast( active_actors.get(userNr), Actor);
					actor.moveDown();
				case Command.MOVE_LEFT: trace("Command.MOVE_LEFT");
					var actor:Actor = cast( active_actors.get(userNr), Actor);
					actor.moveLeft();
				case Command.MOVE_RIGHT: trace("Command.MOVE_RIGHT");
					var actor:Actor = cast( active_actors.get(userNr), Actor);
					actor.moveRight();
			}
		}

	}
	// ---------------------------------------------------------------
	// --------------------- Recieve Commands from Client ------------
	// ---------------------------------------------------------------


	// ---------------------------------------------------------------
	// --------------------- Send Commands to Client -----------------
	// ---------------------------------------------------------------

	// I_VIEW INTERFACE to VIEW !!!
	
	public function init(userNr:Int, root:I_WorldObject, max_t_size:Int, max_b_size:Int, max_l_size:Int, max_r_size:Int):Void
	{
		trace("send INIT");
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte(Command.INIT);
		output.writeUInt16(max_t_size);
		output.writeUInt16(max_b_size);
		output.writeUInt16(max_l_size);
		output.writeUInt16(max_r_size);
		
		// start room
		trace("add "+ root.viewerElement.get(userNr) );
		output.writeUInt16(root.viewerElement.get(userNr)); // peote-view ElementNr
		output.writeUInt16(root.nr); // graphic type
		// content of Room
		// TODO: ebtter recursive viewer?
		if (root.content != null)
			{
				trace("add "+ root.content.viewerElement.get(userNr) );
				output.writeByte(1); // how many objects Room contains
				output.writeUInt16(root.content.viewerElement.get(userNr));
				output.writeUInt16(root.content.nr); // graphic type
			}
		else output.writeByte(0); // no content

		
		peoteServer.send(userNr, output.getBytes()); // send chunk
	}
	// add border
	public function add_top(userNr:Int, border:Array<I_WorldObject>):Void
	{
		send_added(userNr, Command.ADD_TOP, border);
	}
	public function add_bottom(userNr:Int, border:Array<I_WorldObject>):Void
	{
		send_added(userNr, Command.ADD_BOTTOM, border);
	}
	public function add_left(userNr:Int, border:Array<I_WorldObject>):Void
	{
		send_added(userNr, Command.ADD_LEFT, border);
	}
	public function add_right(userNr:Int, border:Array<I_WorldObject>):Void
	{
		send_added(userNr, Command.ADD_RIGHT, border);
	}
	// del border
	public function del_top(userNr:Int, border:Array<I_WorldObject>):Void
	{
		send_deleted(userNr, Command.DEL_TOP, border);
	}
	public function del_bottom(userNr:Int, border:Array<I_WorldObject>):Void
	{
		send_deleted(userNr, Command.DEL_BOTTOM, border);
	}
	public function del_left(userNr:Int, border:Array<I_WorldObject>):Void
	{
		send_deleted(userNr, Command.DEL_LEFT, border);
	}
	public function del_right(userNr:Int, border:Array<I_WorldObject>):Void
	{
		send_deleted(userNr, Command.DEL_RIGHT, border);
	}
	
	// scroll viewer
	public function scroll_top(userNr:Int):Void
	{
		send_scroll(userNr, Command.SCROLL_TOP);
	}
	public function scroll_bottom(userNr:Int):Void
	{
		send_scroll(userNr, Command.SCROLL_BOTTOM);
	}
	public function scroll_left(userNr:Int):Void
	{
		send_scroll(userNr, Command.SCROLL_LEFT);
	}
	public function scroll_right(userNr:Int):Void
	{
		send_scroll(userNr, Command.SCROLL_RIGHT);
	}
	// ----------------------------------------------------------
	// ------------ send to client ------------------------------

	inline function send_added(userNr:Int, command:Int, border:Array<I_WorldObject>):Void
	{	//trace("command:" + command);
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		
		for (i in 0...border.length)
		{
			if (border[i] != null)
			{	trace("add "+ border[i].viewerElement.get(userNr) );
				output.writeUInt16(border[i].viewerElement.get(userNr)); // peote-view ElementNr
				output.writeUInt16(border[i].nr); // graphic type
				// content of Room
				if (border[i].content != null)
				{	
					var elementNr:Null<Int> = border[i].content.viewerElement.get(userNr);
					if (elementNr != null)
					{	trace("add content "+ elementNr );
						output.writeByte(1); // how many objects Room contains
						output.writeUInt16(elementNr);
						output.writeUInt16(border[i].content.nr); // graphic type
					}
					else {
						output.writeByte(0); // no content
						trace("---- Problem:  room not observed anymore -> CHECK");
					}
				}
				else output.writeByte(0); // no content
			}
			else output.writeByte(0); // no element
			
		}
		sendChunk(userNr, command, output); // send chunk
	}
	inline function send_deleted(userNr:Int, command:Int, border:Array<I_WorldObject>):Void
	{	//trace("command:" + command);
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		
		for (i in 0...border.length)
		{
			if (border[i] != null)
			{	trace("del "+ border[i].viewerElement.get(userNr) );
				output.writeUInt16(border[i].viewerElement.get(userNr)); // peote-view ElementNr
				// content of Room
				if (border[i].content != null)
				{	
					var elementNr:Null<Int> = border[i].content.viewerElement.get(userNr);
					if (elementNr != null)
					{	trace("del content "+ elementNr );
						output.writeByte(1); // how many objects Room contains
						output.writeUInt16(elementNr);
					}
					else {
						output.writeByte(0); // no content
						trace("---- Problem:  room not observed anymore -> CHECK");
					}
				}
				else output.writeByte(0); // no content
			}
			else output.writeByte(0); // no element
			
		}
		sendChunk(userNr, command, output); // send chunk
	}
	inline function send_scroll(userNr:Int, command:Int):Void
	{	trace("send_scroll command:" + command);
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte(command);
		peoteServer.send(userNr, output.getBytes() );
	}
	
	public function sendChunk(userNr:Int, command:Int, output:PeoteBytesOutput):Void
	{	
		var command_chunksize:PeoteBytesOutput = new PeoteBytesOutput();
		command_chunksize.writeByte(command);
		command_chunksize.writeUInt16(output.length);
		//trace("chunksize:"+output.length);
		peoteServer.send(userNr, command_chunksize.getBytes() );
		peoteServer.send(userNr, output.getBytes() );
	}
	
	
	public function addElementAt( userNr:Int, obj:I_WorldObject, newElementNr:Int, atElementNr:Int ):Void
	{
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte( Command.ADD_ELEMENT);
		output.writeUInt16(newElementNr);
		output.writeUInt16(obj.nr); // graphicNr
		output.writeUInt16(atElementNr); // position (room-elemNr)
		peoteServer.send(userNr, output.getBytes()); // send chunk
	}
	
	public function deleteElement( userNr:Int, elementNr:Int ):Void
	{
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte( Command.DEL_ELEMENT);
		output.writeUInt16(elementNr);
		peoteServer.send(userNr, output.getBytes()); // send chunk		
	}
	
	public function moveElementTo( userNr:Int, elementNr:Int, toElementNr:Int, speed:Int ):Void
	{
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte( Command.MOVE_ELEMENT);
		output.writeUInt16(elementNr);
		output.writeUInt16(toElementNr);
		output.writeUInt16(speed);
		peoteServer.send(userNr, output.getBytes()); // send chunk
	}
	
}


