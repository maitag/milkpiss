package de.peote.world.net;

/**
 * ...
 * @author Sylvio Sell
 */
class Command
{
	// (send to client) ---------------

	public static inline var INIT        :Int = 0;
	//public static inline var UPDATE      :Int = 1;

	public static inline var RESIZE      :Int = 2;
	
	public static inline var ADD_ELEMENT :Int = 10;
	public static inline var DEL_ELEMENT :Int = 11;
	public static inline var MOVE_ELEMENT:Int = 12;

	public static inline var ADD_TOP     :Int = 20;
	public static inline var ADD_BOTTOM  :Int = 21;
	public static inline var ADD_LEFT    :Int = 22;
	public static inline var ADD_RIGHT   :Int = 23;
		
	public static inline var DEL_TOP     :Int = 24;
	public static inline var DEL_BOTTOM  :Int = 25;
	public static inline var DEL_LEFT    :Int = 26;
	public static inline var DEL_RIGHT   :Int = 27;
	
	public static inline var SCROLL_TOP     :Int = 30;
	public static inline var SCROLL_BOTTOM  :Int = 31;
	public static inline var SCROLL_LEFT    :Int = 32;
	public static inline var SCROLL_RIGHT   :Int = 33;
	
	// ----------------------------
	
	// client movement (send to server)
	public static inline var MOVE_UP     :Int = 40;
	public static inline var MOVE_DOWN   :Int = 41;
	public static inline var MOVE_LEFT   :Int = 42;
	public static inline var MOVE_RIGHT  :Int = 43;
	
	
}