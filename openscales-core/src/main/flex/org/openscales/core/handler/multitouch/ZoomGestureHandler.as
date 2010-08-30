package org.openscales.core.handler.multitouch {
	
	
	import flash.events.GesturePhase;
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.handler.Handler;
	
	/**
	 * Handler use to zoom in and zoom out the map based on zoom gesture events.
	 */
	public class ZoomGestureHandler extends Handler {
		
		protected var cummulativeScaleX:Number;
		protected var cummulativeScaleY:Number;
		
		public function ZoomGestureHandler(target:Map = null, active:Boolean = true) {
			super(target,active);
		}
		
		override protected function registerListeners():void {
			if (this.map) {
				if(Multitouch.inputMode != MultitouchInputMode.GESTURE)
					Multitouch.inputMode = MultitouchInputMode.GESTURE;
				this.map.addEventListener(TransformGestureEvent.GESTURE_ZOOM,this.onGestureZoom);
			}
		}
		
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(TransformGestureEvent.GESTURE_ZOOM,this.onGestureZoom);
			}
		}
		
		private function onGestureZoom(event:TransformGestureEvent):void {
			Trace.debug("ScaleX " + event.scaleX + " ScaleY " + event.scaleY);
			if (event.phase==GesturePhase.BEGIN) {
				this.cummulativeScaleX = 1;
				this.cummulativeScaleY = 1;
			} else if (event.phase==GesturePhase.UPDATE) {
				this.cummulativeScaleX = this.cummulativeScaleX * event.scaleX;
				this.cummulativeScaleY = this.cummulativeScaleY * event.scaleY;
			} if (event.phase==GesturePhase.END) {
				
				if(cummulativeScaleX*cummulativeScaleY > 1)
					this.map.zoom = this.map.zoom + 1;
				else
					this.map.zoom = this.map.zoom - 1;
			}
		}
		
	}
}
