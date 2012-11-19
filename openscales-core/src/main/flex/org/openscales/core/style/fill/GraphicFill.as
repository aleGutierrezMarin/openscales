package org.openscales.core.style.fill
{
	import flash.display.Graphics;
	
	import org.openscales.core.feature.Feature;
	
	public class GraphicFill implements Fill
	{
		
		public function GraphicFill()
		{
		}
		
		public function configureGraphics(graphics:Graphics, feature:Feature):void
		{
		}
		
		public function clone():Fill
		{
			return null;
		}
		
		public function get sld():String
		{
			return null;
		}
		
		public function set sld(sld:String):void
		{
		}
	}
}