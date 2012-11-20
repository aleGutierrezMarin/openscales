package org.openscales.core.style.graphic
{
	import flash.display.DisplayObject;
	
	import org.openscales.core.feature.Feature;

	public interface IGraphic
	{
		function get sld():String;
		function set sld(value:String):void;
		function getDisplayObject(feature:Feature, size:Number):DisplayObject;
		function clone():IGraphic;
	}
}