package org.openscales.core.handler.multitouch {
	
	
	import flash.events.GestureEvent;
	import flash.events.GesturePhase;
	import flash.events.MouseEvent;
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
				this.map.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP,this.onTwoFingerTap);
				this.map.addEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
			}
		}
		
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(TransformGestureEvent.GESTURE_ZOOM,this.onGestureZoom);
				this.map.removeEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP,this.onTwoFingerTap);
				this.map.removeEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
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
				
				this.map.layerContainer.scaleX *= event.scaleX;
				this.map.layerContainer.scaleY *= event.scaleY;
				
			} if (event.phase==GesturePhase.END) {
				
				this.map.layerContainer.scaleX = 1;
				this.map.layerContainer.scaleY = 1;
				
				if(cummulativeScaleX*cummulativeScaleY > 1)
				{
					this.map.moveTo(this.map.center, this.map.zoom + 1, false, true);
					
				}
					
				else
				{
					this.map.moveTo(this.map.center, this.map.zoom - 1, false, true);
				}
					
			}
		}
		
		private function onTwoFingerTap(event:GestureEvent):void {
			this.map.moveTo(this.map.center, this.map.zoom + 1, false, true);
		}
		
		private function onDoubleClick(event:MouseEvent):void {
			this.map.moveTo(this.map.center, this.map.zoom + 1, false, true);
		}
		
	}
}
