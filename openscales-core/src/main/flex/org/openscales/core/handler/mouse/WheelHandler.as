package org.openscales.core.handler.mouse {
	
	import flash.events.MouseEvent;
	
	import org.openscales.basetypes.Pixel;
	import org.openscales.core.Map;
	import org.openscales.core.events.HandlerEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.HandlerBehaviour;
	
	/**
	 * Handler use to zoom in and zoom out the map thanks to the mouse wheel.
	 */
	public class WheelHandler extends Handler {
		
		
		public function WheelHandler(target:Map = null, active:Boolean = true) {
			// WheelHandler is a move handler
			//this.behaviour = HandlerBehaviour.MOVE;
			super(target,active, this.behaviour);
		}
		
		override protected function registerListeners():void {
			if (this.map) {
				super.registerListeners();
				this.map.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
			}
		}
		
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
				super.unregisterListeners();
			}
		}
		
		private function onMouseWheel(event:MouseEvent):void {
			if (this.map && this.map.baseLayer) {
				const px:Pixel = new Pixel(this.map.mouseX, this.map.mouseY);
				const centerPx:Pixel = new Pixel(this.map.width/2, this.map.height/2);
				var newCenterPx:Pixel;
				var zoom:Number = this.map.zoom;
				if(event.delta > 0) {
					zoom++;
					if(zoom > this.map.baseLayer.maxZoomLevel)
						return;
					newCenterPx = new Pixel((px.x+centerPx.x)/2, (px.y+centerPx.y)/2);
					
				} else {
					zoom--;
					if(zoom < this.map.baseLayer.minZoomLevel)
						return;
					newCenterPx = new Pixel(2*centerPx.x-px.x, 2*centerPx.y-px.y);
				}
				this.map.moveTo(this.map.getLocationFromMapPx(newCenterPx), zoom, false, true);

			}
		}
		
		/**
		 * Callback use when another handler is activated
		 */
		override protected function onOtherHandlerActivation(handlerEvent:HandlerEvent):void{
			// Check if it's not the current handler which has just been activated
			if(handlerEvent != null) {
				if(handlerEvent.handler != this) {
					if(handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.MOVE) {
						// A move handler has been activated
						// Do nothing, we leave the handler in its state
					} else if (handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.SELECT) {
						// A select handler has been activated
						this.active = false;
					} else if (handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.DRAW) {
						// A draw handler has been activated
						this.active = false;
					} else {
						// Do nothing
					}
				}
			}
		}
		
	}
}
