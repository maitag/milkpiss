package de.peote.world.input;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import de.peote.world.net.Client;
/**
 * ...
 * @author Sylvio Sell
 */
class InputControl
{

	var client:Client;
	
	public function new(client:Client) 
	{
		this.client = client;
	}
	public function onKeyDown (window:Window, keyCode:KeyCode, modifier:KeyModifier):Void
	{	
		switch (keyCode)
		{
			case KeyCode.W|KeyCode.UP:    client.moveUp();
			case KeyCode.A|KeyCode.LEFT:  client.moveLeft();
			case KeyCode.S|KeyCode.DOWN:  client.moveDown();
			case KeyCode.D|KeyCode.RIGHT: client.moveRight();
			default:
		}
	}
	
}