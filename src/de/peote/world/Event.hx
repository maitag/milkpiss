package de.peote.world;

/**
 * ...
 * @author semmi
 */
class Event
{
}

class RoomEvent
{

	public static inline var ENTER      :Int = 0;
	public static inline var LEAVE      :Int = 1;
	public static inline var CHECK_FALL :Int = 2;	
}

class ActorEvent
{
	public static inline var MOVE_TO    :Int = 0;
}

class NetEvent 
{

	public static inline var CONNECT    :Int = 256 + 0;
	public static inline var CLOSE      :Int = 256 + 1;
	public static inline var ERROR      :Int = 256 + 2;
	public static inline var ENTER      :Int = 256 + 3;
	public static inline var DISCONNECT :Int = 256 + 4;
}                                             
                                              
class ControlViewEvent                        
{                                             
                                              
	public static inline var INIT         :Int = 512 + 0;
	public static inline var RESET        :Int = 512 + 1;
	public static inline var RESIZE       :Int = 512 + 2;
	public static inline var SCROLL_UP    :Int = 512 + 3;
	public static inline var SCROLL_DOWN  :Int = 512 + 5;
	public static inline var SCROLL_LEFT  :Int = 512 + 6;
	public static inline var SCROLL_RIGHT :Int = 512 + 7;

}