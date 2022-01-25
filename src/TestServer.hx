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

import de.peote.world.net.Client;
import de.peote.world.net.Server;
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
import lime.Assets;

import de.peote.view.PeoteView;
import de.peote.view.displaylist.DType;

import de.peote.world.I_WorldObject;

class TestServer extends Application {
	
    public var width: Int;
    public var height: Int;
    public var mouse_x: Int = 0;
    public var mouse_y: Int = 0;
    public var xOffset: Int = 0;
    public var yOffset: Int = 0;
    public var zoom: Int = 1;
	
	private var peoteView:PeoteView;
	private var startTime:Float;
	
	public function new () { super (); }
	//public override function create (config:Config):Void [ super.create (config) };

	public override function onWindowCreate (window:Window):Void
	{	
		trace("onWindowCreate");
		switch (window.renderer.context) {
			case OPENGL (gl):
				width = window.width;
				height = window.height;
				run(); // start Example Code (override by child example classes)				
			default:
				trace("only opengl supported");
		}
	}
	
	public function run()
	{
		startTime = Timer.stamp();
		peoteView = new PeoteView(10, 1000); // max_displaylists, max_programs (for all displaylists)
		
		// -----------------------------------------------------
		// ---------------- PROGRAM SHADER ---------------------
		// -----------------------------------------------------
		//peoteView.setProgram(0, "assets/lyapunov_01.frag");
		
		// -----------------------------------------------------
		// ------------------- IMAGES --------------------------
		// -----------------------------------------------------
		peoteView.setImage(0, "assets/img/tileset.png", 512, 512);
		
		
		// -----------------------------------------------------
		// ---------------- DISPLAYLISTS -----------------------
		// -----------------------------------------------------
		peoteView.setDisplaylist( { displaylist:0, type:DType.ANIM|DType.ZINDEX,
			elements:1000, programs:10, segments:10,
			//x:100, y:70,
			//w:350, h:150,
			z:0,
			blend:0,
			renderBackground:true,
			r:0.1,g:0.5,b:0.8, a:0.8,
			enable:true
		});
		
		// -----------------------------------------------------
		// ---------------- ELEMENTS ---------------------------
		// -----------------------------------------------------
		
		//peoteView.setElementDefaults({ displaylist:0, z:1, image:1, tile:2 });
		
		peoteView.setElement( { element:0, displaylist:0,
			x:0, y:0, z:0,
			//end:{x:100, time: Timer.stamp() - startTime +10},
			w:100, h:100,
			image:0,
			tile:3
		});
		
		peoteView.setElement( { element:1, displaylist:0,
			x:0, y:30, z:1,
			//end:{x:100, time: Timer.stamp() - startTime +10},
			w:100, h:100,
			image:0,
			tile:2
		});
		
		peoteView.setElement( { element:2, displaylist:0,
			x:100, y:0, z:0,
			//end:{x:100, time: Timer.stamp() - startTime +10},
			w:100, h:100,
			image:0,
			tile:3
		});
		
		
		peoteView.setElement( { element:1, displaylist:0,
			end:{x:100, time: Timer.stamp() - startTime +10}
		});
		
	}
	
	public function run_world()
	{
		var world:World = new World();
		var lvl:Int = 3;
		var available_actors:Array<I_WorldObject> = world.createExampleWorld(lvl);
		
		var conf:Dynamic = loadServerConfig("assets/peoteServer.conf");
		var server:Server = new Server(available_actors, world.testLevel(lvl)[0].length, world.testLevel(lvl).length);
		//server.create(conf.joint, conf.server, conf.port);
		server.create('localtest');
		
		world.start();
		
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
	{	peoteView.render(Timer.stamp() - startTime, width, height, mouse_x, mouse_y, zoom, xOffset, yOffset);
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
		run_world();
	}
	public override function onKeyDown (window:Window, keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.F:
				window.fullscreen = !window.fullscreen;
			default:
		}
	}
	
	// end Event Handler ------------------------------
	// ------------------------------------------------------------
	
	public function setOffsets():Void {
		xOffset = Std.int( - width*(zoom-1)/zoom * mouse_x/width);
		yOffset = Std.int( - height*(zoom-1)/zoom * mouse_y/height);
	}

	
}
