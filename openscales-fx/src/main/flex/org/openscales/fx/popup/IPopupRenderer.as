package org.openscales.fx.popup
{
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	/**
	 * This  is the interface for popup renderers
	 * 
	 * */
	public interface IPopupRenderer
	{
		function draw():void;
		function destroy():void;
		function get fxpopup():FxPopup;
		function set fxpopup(value:FxPopup):void;
		function get content():String;
		function set content(value:String):void;
	}
}