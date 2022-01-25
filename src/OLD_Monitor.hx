package de.maitag.peote;

import flash.system.System;

/**
 * ...
 * @author Sylvio Sell
 */
class Monitor
{

	public static var viewUpdateTime:Int;
	public static var worldStepTime:Int;
	
	public static var EventListener:Int=0;
	
	public static var mem(get, null):Float;
	public static var memAverage(get, null):Float;
	public static var last_mem:Array<Int> = [];
	

	public static function get_mem():Float 
	{
		return Math.round(System.totalMemory / 1024 / 1024);
	}
	
	public static function get_memAverage():Float 
	{
		if (last_mem.length > 50) last_mem.shift();
		last_mem.push(Math.round(System.totalMemory / 1024 / 1024));
		var summe:Float = 0;
		for (i in last_mem) summe += i;
		return Math.round((summe) / last_mem.length) ;
	}	
	
}