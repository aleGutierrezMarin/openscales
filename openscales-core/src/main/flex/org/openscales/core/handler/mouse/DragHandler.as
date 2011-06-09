package org.openscales.core.handler.mouse
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * DragHandler allows to drag (pan) the map
	 *
	 * To use this handler, it's  necessary to add it to the map.
	 * It is a pure ActionScript class. Flex wrapper and components can be found
	 * in the openscales-fx module (same name prefixed by Fx).
	 */
	public class DragHandler extends Handler
	{
		/**
		 * @private 
		 */ 
		private var _shiftPressed:Boolean = false;
		
		private var _startCenter:Location = null;
		private var _start:Pixel = null;
		private var _offset:Pixel = null;
		
		private var _firstDrag:Boolean = true;
		
		private var _dragging:Boolean = false;
		
		/**
		 *Callbacks function
		 */
		private var _onStart:Function=null;
		private var _oncomplete:Function=null;
		
		/**
		 * DragHandler constructor
		 *
		 * @param map the DragHandler map
		 * @param active to determinates if the handler is active (default=true)
		 */
		public function DragHandler(map:Map=null,active:Boolean=true)
		{
			super(map,active);
		}
		
		override protected function registerListeners():void{
			if (this.map) {
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				this.map.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
				this.map.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
			}
		}
		
		override protected function unregisterListeners():void{
			if (this.map) {
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				this.map.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
				this.map.removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
			}
		}
		
		/**
		 * The MouseDown Listener
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			if(_shiftPressed) return;
			
			if (_firstDrag) {
				this.map.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
				_firstDrag = false;
			}
			
			this.map.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
			
			this._start = new Pixel(this.map.mouseX,this.map.mouseY);
			this._offset = new Pixel(this.map.mouseX - this.map.layerContainer.x,this.map.mouseY - this.map.layerContainer.y);
			this._startCenter = this.map.center;
			this.map.buttonMode=true;
			this._dragging=true;
			this.map.dispatchEvent(new MapEvent(MapEvent.DRAG_START, this.map));
			if(this.onstart!=null)
				this.onstart(event as MouseEvent);
		}
		
		protected function onMouseMove(event:MouseEvent):void  {
			this.map.layerContainer.x = this.map.layerContainer.parent.mouseX - this._offset.x;
			this.map.layerContainer.y = this.map.layerContainer.parent.mouseY - this._offset.y;
			if(this.map.bitmapTransition) {
				this.map.bitmapTransition.x = this.map.bitmapTransition.parent.mouseX - this._offset.x;
				this.map.bitmapTransition.y = this.map.bitmapTransition.parent.mouseY - this._offset.y;
			}
			
			// Force update regardless of the framerate for smooth drag
			event.updateAfterEvent();
		}
		
		/**
		 *The MouseUp Listener
		 */
		protected function onMouseUp(event:MouseEvent):void {
			
			if(_shiftPressed) return;
			
			if((!this.map) || (!this.map.stage))
				return;
			
			this.map.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
			
			this.map.buttonMode=false;
			this.done(new Pixel(this.map.mouseX, this.map.mouseY));
			// A MapEvent.MOVE_END is emitted by the "set center" called in this.done
			this._dragging=false;
			if (this.oncomplete!=null)
				this.oncomplete(event as MouseEvent);
		}
		
		/**
		 * 
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == 16) _shiftPressed = true;

		}
		
		/**
		 * 
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			if(event.keyCode == 16) _shiftPressed = false;
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
				this._startCenter.projSrsCode);
			// If the new position equals the old center, stop here
			if (newPosition.equals(oldCenter)) {
				var event:MapEvent = new MapEvent(MapEvent.MOVE_NO_MOVE, this.map);
				event.oldCenter = this.map.center;
				event.newCenter = this.map.center;
				event.oldZoom = this.map.zoom;
				event.newZoom = this.map.zoom;
				this.map.dispatchEvent(event);
				//Trace.log("DragHandler.panMap INFO: new center = old center, nothing to do");
				return;
			}
			// Try to set the new position as the center of the map
			this.map.center = newPosition;
			// If the new position is invalid (see Map.setCenter for the
			// conditions), the center of the map is always the old one but the
			// bitmap that represents the map is centered to the new position.
			// We have to reset the bitmap position to the right center.
			if (this.map.center.equals(oldCenter)) {
				//Trace.log("DragHandler.panMap INFO: invalid new center submitted, the bitmap of the map is reset");
				this.map.moveTo(this.map.center);
			}
		}
	}
}

