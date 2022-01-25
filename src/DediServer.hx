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

import haxe.Timer;
#if js
#else
import lime.Assets;
#end

import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;
import lime.ui.Touch;
import lime.ui.Window;
import lime.graphics.Renderer;

import de.peote.world.net.Client;
import de.peote.world.net.Server;
import de.peote.world.World;


import de.peote.world.I_WorldObject;

class DediServer extends Application {
	
	public function new () { super (); }
	
	override public function create(config:Config)
	{
		config.windows = [];
		
		super.create(config);
		
		// 5 seconds delay that you see that not lime but irrlicht makes the window
		
		trace("start peote server");
		
		Timer.delay(run, 5000);
	}
	
	public function run() //start Example
	{

		var world:World = new World();
		var lvl:Int = 3;
		var available_actors:Array<I_WorldObject> = world.createExampleWorld(lvl);
		
		var conf:Dynamic = loadServerConfig("assets/peoteServer.conf");
		var server:Server = new Server(available_actors, world.testLevel(lvl)[0].length, world.testLevel(lvl).length);
		server.create( conf.joint, conf.server, conf.port );
		
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

	
}
