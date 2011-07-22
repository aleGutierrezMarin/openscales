package org.openscales.core.control {

	import org.openscales.core.Map;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * Controls affect the display or behavior of the map.
	 * They allow everything from panning and zooming to displaying a scale indicator.
	 */
	public interface IControl extends IHandler{

		function draw():void;

		function destroy():void;

		function set position(px:Pixel):void;

		function get position():Pixel;

		function get x():Number;

		function set x(value:Number):void;

		function get y():Number;

		function set y(value:Number):void;
		
		function onMapLanguageChange(event:I18NEvent):void;
	}
}

