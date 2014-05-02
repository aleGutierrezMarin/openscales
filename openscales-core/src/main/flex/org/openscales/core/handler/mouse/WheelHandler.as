package org.openscales.core.handler.mouse {
	
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.events.MapEvent;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.core.events.DrawingEvent;
	
	/**
	 * Handler use to zoom in and zoom out the map thanks to the mouse wheel.
	 */
	public class WheelHandler extends Handler {
		
		public function WheelHandler(target:Map = null, active:Boolean = true) {
			super(target,active);
		}
		
		override protected function registerListeners():void {
			if (this.map) {
				this.map.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
			}
		}
		
		/**
		 * @private
		 */
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			}
		}
		
		/**
		 * @private
		 */
		private function onMouseWheel(event:MouseEvent):void {
			if(this.map && this.map.mouseNavigationEnabled)
			{
				var mousePx:Pixel = new Pixel(this.map.mouseX, this.map.mouseY);
				if(event.delta > 0) {
					this.map.zoomIn(mousePx);
				}
				else {
					this.map.zoomOut(mousePx);
				}
			}
		}
	}
}