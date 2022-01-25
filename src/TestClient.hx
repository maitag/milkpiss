/*
 *        o-o    o-o  o-o-o  o-o     
 *       o   o  o        o      o    
 *      o-o-o  o-o   o    o    o-o   
 *     o      o     (_)    o      o  
 *    o      o-o    / \     o    o-o 
 * 
 * PEOTE - haxe Game Engine
 * Copyright (c) 2014 Sylvio Sell, http://maitag.de
 */

package;

import de.peote.world.Event.ControlViewEvent;
import de.peote.world.input.InputControl;
import de.peote.world.net.Client;
import de.peote.world.net.Server;
import de.peote.world.view.View;
import de.peote.world.World;
import haxe.Timer;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;
import lime.ui.Touch;
import lime.ui.Window;
import lime.graphics.Renderer;

import de.peote.view.PeoteView;
import de.peote.view.displaylist.DType;

class TestClient extends Application {
	
    public var width: Int;
    public var height: Int;
    public var mouse_x: Int = 0;
    public var mouse_y: Int = 0;
    public var xOffset: Int = 0;
    public var yOffset: Int = 0;
    public var zoom: Int = 1;
	
	var peoteView:PeoteView;
	var startTime:Float;
	
	var inputControl:InputControl;
	
	public function new () { super (); }
	//public override function create (config:Config):Void [ super.create (config) };

	public override function onWindowCreate (window:Window):Void
	{
		switch (window.renderer.context) {
			case OPENGL (gl):
				width = window.width;
				height = window.height;
				//run(); // start Example Code (override by child example classes)				
			default:
				trace("only opengl supported");
		}
	}
	
	public function run()
	{
		
		startTime = Timer.stamp();
		peoteView = new PeoteView(10, 1000); // max_displaylists, max_programs (for all displaylists)
		
		peoteView.setImage(0, "assets/img/tileset.png", 512, 512);
				
		var view:View = new View(peoteView, startTime); // TODO: avail Views and View to LocalView
		
		var conf:Dynamic = loadServerConfig("assets/peoteServer.conf");
		var client:Client = new Client(view); // TODO: multiple Views to many Servers
		//Timer.delay(function() {client.enter(conf.joint, conf.server, conf.port);}, 3000);
		//client.enter(conf.joint, conf.server, conf.port);
		client.enter("localtest");
		
		inputControl = new InputControl(client);
		
	}
	
	public function loadServerConfig(name:String):Dynamic
	{
		// load config from json file
		var regex = new EReg("//.*?$","gm");
		#if js
		var req = js.Browser.createXMLHttpRequest();
		req.open('GET', name, false);
		req.send();
		return haxe.Json.parse( "{"+ regex.replace(req.responseText, "") +"}");
		#else
		return haxe.Json.parse( "{"+ regex.replace(Assets.getText(name), "") +"}"); // TODO: problem with getText (.txt ??)
		#end
	}
	
	// ------------------------------------------------------------
	// ------------------------------------------------------------
	
	// ----------- Render Loop ------------------------------------
	public override function render(renderer:Renderer):Void
	{
		peoteView.render(Timer.stamp() - startTime, width, height, mouse_x, mouse_y, zoom, xOffset, yOffset);
	}

	
	// ------------------------------------------------------------
	// ----------- EVENT HANDLER ----------------------------------
	public override function onWindowResize (window:Window, width:Int, height:Int):Void
	{
		trace("onWindowResize:"+ window.width+','+ window.height);
		this.width = window.width;
		this.height = window.height;
	}
	
	public override function onMouseMove (window:Window, x:Float, y:Float):Void
	{
		//trace("onMouseMove: " + x + "," + y );
		mouse_x = Std.int(x);
		mouse_y = Std.int(y);
		setOffsets();
	}
	
	public override function onTouchMove (touch:Touch):Void
	{
		trace("onTouchMove: " + touch.x + "," + touch.y );
		mouse_x = Std.int(touch.x); //* window.width;
		mouse_y = Std.int(touch.y);
		setOffsets();
	}
	
	public override function onMouseDown (window:Window, x:Float, y:Float, button:Int):Void
	{	
		trace("onMouseDown: x=" + x + " y="+ y);
		if ( button == 0) zoom++;
		else if (button == 1 && zoom > 1) zoom--;
		setOffsets();
	}
	
	public override function onMouseUp (window:Window, x:Float, y:Float, button:Int):Void
	{	
		trace("onmouseup: "+button+" x=" + x + " y="+ y);
	}
	
	public override function onMouseWheel (window:Window, deltaX:Float, deltaY:Float):Void
	{	
		trace("onmousewheel: " + deltaX + ',' + deltaY );
		if ( deltaY>0 ) zoom++;
		else if (zoom > 1) zoom--;
		setOffsets();
	}

	public override function onRenderContextLost (renderer:Renderer):Void {
		trace(" --------- ERROR :  LOST RENDERCONTEXT ----------- ");		
	}
	public override function onRenderContextRestored (renderer:Renderer, context:RenderContext):Void {
		trace(" --------- onRenderContextRestored ----------- ");		
	}
	public override function onPreloadProgress (loaded:Int, total:Int):Void {
		
		trace(" --------- onPreloadProgress ----------- ");		
	}
	public override function onPreloadComplete ():Void {
		
		trace(" --------- onPreload Complete ----------- ");
		run();
	}
	public override function onKeyDown (window:Window, keyCode:KeyCode, modifier:KeyModifier):Void
	{
		/*switch (keyCode) {
			case KeyCode.F:
				window.fullscreen = !window.fullscreen;
			default:
		}*/
		inputControl.onKeyDown(window, keyCode, modifier);
	}
	
	// end Event Handler ------------------------------
	// ------------------------------------------------------------
	
	public function setOffsets():Void {
		xOffset = Std.int( - width*(zoom-1)/zoom * mouse_x/width);
		yOffset = Std.int( - height*(zoom-1)/zoom * mouse_y/height);
	}

	
}
