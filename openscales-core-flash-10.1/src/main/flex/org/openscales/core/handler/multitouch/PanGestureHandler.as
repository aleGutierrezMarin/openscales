package org.openscales.core.handler.multitouch {
	
	
	import flash.events.GesturePhase;
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * Handler use to panthe map based on gesture multitouche events.
	 */
	public class PanGestureHandler extends Handler {
		
		private var _last:Pixel = null;
		
		private var _firstDrag:Boolean = true;
		
		private var _dragging:Boolean = false;
		
		/**
		 *Callbacks function
		 */
		private var _onStart:Function=null;
		private var _oncomplete:Function=null;
		
		
		public function PanGestureHandler(target:Map = null, active:Boolean = true) {
			super(target,active);
		}
		
		override protected function registerListeners():void {
			if (this.map) {
				if(Multitouch.inputMode != MultitouchInputMode.GESTURE)
					Multitouch.inputMode = MultitouchInputMode.GESTURE;
				this.map.addEventListener(TransformGestureEvent.GESTURE_PAN,this.onPanZoom);
			}
		}
		
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(TransformGestureEvent.GESTURE_PAN,this.onPanZoom);
			}
		}
		
		private function onPanZoom(event:TransformGestureEvent):void {
			if (this.map) {
				if (event.phase==GesturePhase.BEGIN) {
					this._last = new Pixel(event.stageX,event.stageY);
					this.map.buttonMode=true;
					this._dragging=true;
					this.map.dispatchEvent(new MapEvent(MapEvent.DRAG_START, this.map));
					if(this.onstart!=null)
						this.onstart(event);
				}
				if (event.phase==GesturePhase.UPDATE) {
					if(!this._last)
						return;
					
					var _dX:Number = this._last.x-event.stageX;
					var _dY:Number = this._last.y-event.stageY;
					this._last = new Pixel(event.stageX,event.stageY);
					
					var _centerPx:Pixel = this.map.getMapPxFromLocation(this.map.center);
					this.map.center = this.map.getLocationFromMapPx(_centerPx.add(_dX,_dY));
					event.updateAfterEvent();
				}
				if (event.phase==GesturePhase.END) {
				
					this.map.buttonMode=false;
					this._dragging=false;
					if (this.oncomplete!=null)
						this.oncomplete(event);
					this._last = null;
				}
			}
		}
		
		// Getters & setters as3
		/**
		 * To know if the map is dragging
		 */
		public function get dragging():Boolean
		{
			return this._dragging;
		}
		public function set dragging(dragging:Boolean):void
		{
			this._dragging=dragging;
		}
		/**
		 * Start's callback this function is call when the drag starts
		 */
		public function set onstart(onstart:Function):void
		{
			this._onStart=onstart;
		}
		public function get onstart():Function
		{
			return this._onStart;
		}
		/**
		 * Stop's callback this function is call when the drag ends
		 */
		public function set oncomplete(oncomplete:Function):void
		{
			this._oncomplete=oncomplete;
		}
		public function get oncomplete():Function
		{
			return this._oncomplete;
		}
	}
}
