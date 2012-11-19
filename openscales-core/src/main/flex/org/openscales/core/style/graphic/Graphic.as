package org.openscales.core.style.graphic
{

	public interface Graphic
	{
		function get sld():String;
		function set sld(value:String):void;
		function get size():Object;
		function set size(value:Object):void;
		function clone():Graphic;
	}
}