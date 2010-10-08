package org.openscales.core.handler.mouse
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Pixel;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.handler.Handler;
	
	public class DoubleClickHandler extends ClickHandler
	{
		public function DoubleClickHandler(map:Map=null, active:Boolean=true)
		{
			super(map, active);
			this.doubleClick = this.doubleclickhandler;
		}
		
		private function doubleclickhandler(px:Pixel):void {
			if(this.map.zoom > this.map.baseLayer.maxZoomLevel) {
				Trace.log("double click");
				var loc:Location = this.map.getLocationFromMapPx(px);
				this.map.moveTo(loc,this.map.zoom++);
			}
		}
	}
}