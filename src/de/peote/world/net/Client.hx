package de.peote.world.net;

import de.peote.io.PeoteBytes;
import de.peote.io.PeoteBytesInput;
import de.peote.io.PeoteBytesOutput;
import de.peote.world.I_WorldObject;
import de.peote.net.PeoteClient;

import de.peote.world.view.I_View;

/**
 * ...
 * @author semmi
 */

class Client extends WorldObject implements I_WorldObject // TODO: really inside World?
{
	public var peoteClient:PeoteClient;
	
	public var t_size:Int = 0;
	public var b_size:Int = 0;
	public var l_size:Int = 0;
	public var r_size:Int = 0;
	public var max_t_size:Int = 0;
	public var max_b_size:Int = 0;
	public var max_l_size:Int = 0;
	public var max_r_size:Int = 0;
	
	var controlElement:Int;
	
	var inputBuffer:PeoteBytesInput; // stores not fully readed chunk
	var chunk_size:Int = 0;
	var read_chunk_size:Bool = false;
	var onDataChunk:PeoteBytesInput->Void;
	
	// TODO: many View to many Server
	var view:I_View; // DUMMY
	
	public function new (view:I_View ) {
		
		this.view = view;
		inputBuffer = new PeoteBytesInput();
		
		super(0);
		
		peoteClient = new PeoteClient({
				onEnterJoint: onEnterJoint,
				onEnterJointError: onEnterJointError,
				onDisconnect: onDisconnect,
				onData: onData
			});
			
		
	}
	
	public function enter(name:String, server:String="localhost", port:Int = 7680):Void
	{			
		peoteClient.enterJoint(server, port, name);
	}
	
	function onEnterJoint(jointNr:Int):Void 
	{
		trace("onEnterJoint: jointNr=" + jointNr);		
		// 1) send simple name (auth later)
	}
	
	function onEnterJointError(errorNr:Int):Void 
	{
		trace("onEnterJointError:"+errorNr);
	}
	
	function onDisconnect(jointNr:Int, reason:Int):Void 
	{
		trace("onDisconnect: jointNr="+jointNr+", reason="+reason);
	}
	
	public inline function onData(jointNr:Int, peoteBytes:PeoteBytes):Void 
	{
		//trace('onData: ${peoteBytes.length} ${peoteBytes} ');
		
		inputBuffer.append( peoteBytes );
		
		if (chunk_size == 0)
		{
			var command:Int = inputBuffer.readByte();
			switch (command)
			{
				//case Command.ONE_BYTE: do_atomic_command();
				case Command.INIT: onDataChunk = init; chunk_size = 17;
					
				case Command.ADD_TOP:    onDataChunk = add_top;    chunk_size = 2; read_chunk_size=true;
				case Command.ADD_BOTTOM: onDataChunk = add_bottom; chunk_size = 2; read_chunk_size=true;
				case Command.ADD_LEFT:   onDataChunk = add_left;   chunk_size = 2; read_chunk_size=true;
				case Command.ADD_RIGHT:  onDataChunk = add_right;  chunk_size = 2; read_chunk_size=true;
				
				case Command.DEL_TOP:    onDataChunk = del_top;    chunk_size = 2; read_chunk_size=true;
				case Command.DEL_BOTTOM: onDataChunk = del_bottom; chunk_size = 2; read_chunk_size=true;
				case Command.DEL_LEFT:   onDataChunk = del_left;   chunk_size = 2; read_chunk_size=true;
				case Command.DEL_RIGHT:  onDataChunk = del_right;  chunk_size = 2; read_chunk_size=true;
				
				case Command.SCROLL_TOP:    scroll_top(); 
				case Command.SCROLL_BOTTOM: scroll_bottom();
				case Command.SCROLL_LEFT:   scroll_left();
				case Command.SCROLL_RIGHT:  scroll_right();
				
				case Command.ADD_ELEMENT:  onDataChunk = add_element;  chunk_size = 6;
				case Command.DEL_ELEMENT:  onDataChunk = del_element;  chunk_size = 2;
				case Command.MOVE_ELEMENT: onDataChunk = move_element; chunk_size = 6;
				
				default: trace("ERROR: NO VALID COMMAND");
			}
		}
		
		if ( chunk_size != 0 && inputBuffer.bytesLeft() >= chunk_size )
		{
			if (read_chunk_size) {
				chunk_size = inputBuffer.readUInt16(); //trace("chunksize:"+chunk_size);
				read_chunk_size = false;
				if (inputBuffer.bytesLeft() >= chunk_size) {
					onDataChunk( inputBuffer );
					chunk_size = 0;
				}
			}
			else
			{	onDataChunk( inputBuffer );
				chunk_size = 0;
			}
		}


	}
	
	// ---------------------------------------------------------------
	// --------------------- Recieve Commands from Server ------------
	// ---------------------------------------------------------------

	public function init(input:PeoteBytesInput):Void 
	{
		trace("Command.INIT");
		max_t_size = input.readUInt16();
		max_b_size = input.readUInt16();
		max_l_size = input.readUInt16();
		max_r_size = input.readUInt16();
		
		view.init( max_t_size, max_b_size, max_l_size, max_r_size );
		
		// start room
		//read_added(input);
		view.addElement(input.readUInt16(), 0, 0, input.readUInt16() , 0);
		input.readByte();
		controlElement = input.readUInt16();
		view.addElement(controlElement, 0, 0, input.readUInt16() , 1);
		
		// SEND BACK initial data
		resize();
	}
	
	// ------ borders: room + content ------------------
	public function add_top(input:PeoteBytesInput):Void {
		trace("Command.ADD_TOP");
		t_size++;
		read_added(input, -l_size, -t_size, l_size+r_size);
	}
	public function add_bottom(input:PeoteBytesInput):Void {
		trace("Command.ADD_BOTTOM");
		b_size++;
		read_added(input, -l_size, b_size, l_size+r_size);
	}		
	public function add_left(input:PeoteBytesInput):Void {
		trace("Command.ADD_LEFT");
		l_size++;
		read_added(input, -l_size, -t_size, t_size+b_size, 1);
	}		
	public function add_right(input:PeoteBytesInput):Void {
		trace("Command.ADD_RIGHT");
		r_size++;
		read_added(input, r_size, -t_size, t_size+b_size, 1);
	}			

	public function del_top(input:PeoteBytesInput):Void {
		trace("Command.DEL_TOP");
		read_deleted(input, -l_size, -t_size, l_size+r_size);
		t_size--;
	}
	public function del_bottom(input:PeoteBytesInput):Void {
		trace("Command.DEL_BOTTOM");
		read_deleted(input, -l_size, b_size, l_size+r_size);
		b_size--;
	}		
	public function del_left(input:PeoteBytesInput):Void {
		trace("Command.DEL_LEFT");
		read_deleted(input, -l_size, -t_size, t_size+b_size, 1);
		l_size--;
	}		
	public function del_right(input:PeoteBytesInput):Void {
		trace("Command.DEL_RIGHT");
		read_deleted(input, r_size, -t_size, t_size+b_size, 1);
		r_size--;
	}			

	// read data
	public inline function read_added(input:PeoteBytesInput, x_start:Int=0, y_start:Int=0, amount:Int=0, is_leftright:Int=0):Void
	{
		var dx:Int = 1-is_leftright;
		var dy:Int = is_leftright;
		for ( i in 0...1 + amount ) // TODO: "holes" in Border? (0)
		{
			var elementNr:Int = input.readUInt16();
			if (elementNr != 0) // only if content
			{
				view.addElement(elementNr, (dx * i + x_start), (dy * i + y_start), input.readUInt16() , 0);
			
				if (input.readByte() > 0)
				{
					//trace("add content: " );
					view.addElement(input.readUInt16(), (dx * i + x_start), (dy * i + y_start), input.readUInt16() , 1);
				}
			}
		}
	}
	public inline function read_deleted(input:PeoteBytesInput, x_start:Int=0, y_start:Int=0, amount:Int=0, is_leftright:Int=0):Void
	{
		var dx:Int = 1-is_leftright;
		var dy:Int = is_leftright;
		for ( i in 0...1 + amount ) // TODO: "holes" in Border? (0)
		{
			var elementNr:Int = input.readUInt16();
			
			if (elementNr != 0) // only if content
			{	trace("delete room:" + elementNr);
				view.delElement( elementNr );
				if (input.readByte() > 0)
				{
					trace("del content " );
					view.delElement( input.readUInt16() );
				}
			}
		}
	}
	
	// move controlled element (scroll)
	public function scroll_top():Void {
		trace("Command.SCROLL_TOP");
		t_size--; b_size++;
		view.scrollTop();
	}
	public function scroll_bottom():Void {
		trace("Command.SCROLL_BOTTOM");
		b_size--; t_size++;
		view.scrollBottom();
	}
	public function scroll_left():Void {
		trace("Command.SCROLL_LEFT");
		l_size--; r_size++;
		view.scrollLeft();
	}
	public function scroll_right():Void {
		trace("Command.SCROLL_RIGHT");
		r_size--; l_size++;
		view.scrollRight();
	}
	
		
	// ------ room content elements ------------------
	public function add_element(input:PeoteBytesInput):Void {
		trace("Command.ADD_ELEMENT");
		var newElementNr:Int = input.readUInt16();
		var graphicNr:Int = input.readUInt16();
		var atElementNr:Int = input.readUInt16();
		view.addElementAt( newElementNr, atElementNr, graphicNr, 1 );
	}		
	public function del_element(input:PeoteBytesInput):Void {
		trace("Command.DEL_ELEMENT");
		var elementNr:Int = input.readUInt16();
		view.delElement( elementNr );
	}		
	public function move_element(input:PeoteBytesInput):Void {
		trace("Command.MOVE_ELEMENT");
		var elementNr:Int = input.readUInt16();
		var toElementNr:Int = input.readUInt16();
		var speed:Int = input.readUInt16();
		view.moveElementTo (elementNr, toElementNr, speed );
	}			

	
	// ---------------------------------------------------------------
	// --------------------- Send Commands to Server -----------------
	// ---------------------------------------------------------------
	
	public inline function resize():Void {
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte(Command.INIT);
		output.writeString("semmi");
		peoteClient.send( output.getBytes() ); // send username
		
		// send RESIZE COMMAND
		output = new PeoteBytesOutput();
		output.writeByte(Command.RESIZE);
		output.writeUInt16(max_t_size);
		output.writeUInt16(max_b_size);
		output.writeUInt16(max_l_size);
		output.writeUInt16(max_r_size);
		peoteClient.send( output.getBytes() ); // send new size

	}
	public inline function moveUp():Void {
		trace("moveUp");
		//view.moveElementUp(controlElement,10);

		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte(Command.MOVE_UP);
		peoteClient.send( output.getBytes() );
	}
	public inline function moveDown():Void {
		trace("moveDown");
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte(Command.MOVE_DOWN);
		peoteClient.send( output.getBytes() );
	}
	public inline function moveLeft():Void {
		trace("moveLeft");
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte(Command.MOVE_LEFT);
		peoteClient.send( output.getBytes() );
	}
	public inline function moveRight():Void {
		trace("moveRight");
		var output:PeoteBytesOutput = new PeoteBytesOutput();
		output.writeByte(Command.MOVE_RIGHT);
		peoteClient.send( output.getBytes() );
	}

}


