package org.openscales.core.handler.mouse
{
	import flash.events.MouseEvent;
	
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Pixel;
	import org.openscales.core.Map;
	import org.openscales.core.handler.Handler;
	
	public class DoubleClickHandler extends Handler
	{
		public function DoubleClickHandler(map:Map=null, active:Boolean=false)
		{
			super(map, active);
		}
		
		override protected function registerListeners():void {
			// Listeners of the super class
			super.registerListeners();
			// Listeners of the internal timer
			if (this.map) {
				this.map.addEventListener(MouseEvent.DOUBLE_CLICK,this.doubleclick);
			}
		}
		
		override protected function unregisterListeners():void {
			// Listeners of the associated map
			if (this.map) {
				this.map.removeEventListener(MouseEvent.DOUBLE_CLICK,this.doubleclick);
			}
			// Listeners of the super class
			super.unregisterListeners();
		}
		
		private function doubleclick(e:MouseEvent):void {
			if(this.map.zoom > this.map.baseLayer.maxZoomLevel) {
				var px:Pixel = new Pixel(this.map.mouseX,
										 this.map.mouseY);
				var loc:Location = this.map.getLocationFromMapPx(px);
				this.map.moveTo(loc,this.map.zoom++);
			}
		}
	}
}