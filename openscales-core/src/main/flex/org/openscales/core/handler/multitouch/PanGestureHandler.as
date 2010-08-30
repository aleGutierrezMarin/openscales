package org.openscales.core.handler.multitouch {
	
	
	import flash.events.GesturePhase;
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Pixel;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.Handler;
	
	/**
	 * Handler use to panthe map based on gesture multitouche events.
	 */
	public class PanGestureHandler extends Handler {
		
		private var _startCenter:Location = null;
		private var _start:Pixel = null;
		
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
					this._start = new Pixel(event.stageX,event.stageY);
					this._startCenter = this.map.center;
					this.map.buttonMode=true;
					this._dragging=true;
					this.map.dispatchEvent(new MapEvent(MapEvent.DRAG_START, this.map));
					if(this.onstart!=null)
						this.onstart(event);
				}
				if (event.phase==GesturePhase.UPDATE) {
					this.map.layerContainer.x += event.offsetX;
					this.map.layerContainer.y += event.offsetY;
					if(this.map.bitmapTransition) {
						this.map.bitmapTransition.x += event.offsetX;
						this.map.bitmapTransition.y += event.offsetY;
					}
				}
				if (event.phase==GesturePhase.END) {
				
					this.map.buttonMode=false;
					this.done(new Pixel(event.stageX, event.stageY));
					// A MapEvent.MOVE_END is emitted by the "set center" called in this.done
					this._dragging=false;
					if (this.oncomplete!=null)
						this.oncomplete(event);
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
		
		/**
		 * This function is used to recenter map after dragging
		 */
		private function done(xy:Pixel):void {
			if (this.dragging) {
				this.panMap(xy);
				this._dragging = false;
			}
		}
		private function panMap(xy:Pixel):void {
			this._dragging = true;
			var oldCenter:Location = this.map.center;
			var deltaX:Number = this._start.x - xy.x;
			var deltaY:Number = this._start.y - xy.y;
			var newPosition:Location = new Location(this._startCenter.lon + deltaX * this.map.resolution,
				this._startCenter.lat - deltaY * this.map.resolution,
				this._startCenter.projection);
			// If the new position equals the old center, stop here
			if (newPosition.equals(oldCenter)) {
				Trace.log("DragHandler.panMap INFO: new center = old center, nothing to do");
				return;
			}
			// Try to set the new position as the center of the map
			this.map.center = newPosition;
			// If the new position is invalid (see Map.setCenter for the
			// conditions), the center of the map is always the old one but the
			// bitmap that represents the map is centered to the new position.
			// We have to reset the bitmap position to the right center.
			if (this.map.center.equals(oldCenter)) {
				Trace.log("DragHandler.panMap INFO: invalid new center submitted, the bitmap of the map is reset");
				this.map.resetCenterLayerContainer();
			}
		}
		
	}
}
