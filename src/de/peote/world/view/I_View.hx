package de.peote.world.view;

/**
 * @author Sylvio Sell
 */

interface I_View 
{
	public function init(max_t_size:Int, max_b_size:Int, max_l_size:Int, max_r_size:Int):Void;
	public function scrollTop():Void;
	public function scrollBottom():Void;
	public function scrollLeft():Void;
	public function scrollRight():Void;
	public function addElement(elementNr:Int, x:Int, y:Int, graphicNr:Int, z:Int):Void;
	public function addElementAt(elementNr:Int, atElementNr:Int, graphicNr:Int, z:Int):Void;
	public function delElement(elementNr:Int):Void;
	public function moveElementTo(elementNr:Int, toElementNr:Int, speed:Int):Void;
	public function updateElement(elementNr:Int, xnew:Int, ynew:Int):Void;
}