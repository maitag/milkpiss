package de.peote.world.net;

/**
 * @author Sylvio Sell
 */

interface I_ServerLocalView 
{
	public function init( userNr:Int, root:I_WorldObject, max_t_size:Int, max_b_size:Int, max_l_size:Int, max_r_size:Int ):Void;
	public function onViewerReset(userNr:Int):Void;
	public function add_top( userNr:Int, border:Array<I_WorldObject> ):Void;
	public function add_bottom( userNr:Int, border:Array<I_WorldObject> ):Void;
	public function add_left( userNr:Int, border:Array<I_WorldObject> ):Void;
	public function add_right( userNr:Int, border:Array<I_WorldObject> ):Void;
	public function del_top(userNr:Int, border:Array<I_WorldObject>):Void;
	public function del_bottom(userNr:Int, border:Array<I_WorldObject>):Void;
	public function del_left(userNr:Int, border:Array<I_WorldObject>):Void;
	public function del_right(userNr:Int, border:Array<I_WorldObject>):Void;
	public function scroll_top(userNr:Int):Void;
	public function scroll_bottom(userNr:Int):Void;
	public function scroll_left(userNr:Int):Void;
	public function scroll_right(userNr:Int):Void;
	public function addElementAt( userNr:Int, obj:I_WorldObject, newElementNr:Int, atElementNr:Int ):Void;
	public function moveElementTo( userNr:Int, elementNr:Int, toElementNr:Int, speed:Int ):Void;
	public function deleteElement( userNr:Int, elementNr:Int ):Void;
}