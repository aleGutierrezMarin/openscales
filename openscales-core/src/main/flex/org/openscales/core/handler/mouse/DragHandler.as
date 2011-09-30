package org.openscales.core.handler.mouse
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.events.DrawingEvent;
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
		
		private var _startCenter:Location = null;
		private var _start:Pixel = null;
		private var _offset:Pixel = null;
		private var _layerContainerPositionBeforeDrag:Pixel =null;
		
		private var _mouseOffsetLayerContainerCenter:Pixel = new Pixel();
		
		private var _firstDrag:Boolean = true;
		
		private var _dragging:Boolean = false;
		
		private var _previousMapPosition:Pixel = new Pixel(0, 0);
		
		/**
		 * Used to store the center when we reach the limit of the max extend.
		 */
		private var _lastValidCenter:Location = null;
		
		/**
		 *Callbacks function
		 */
		private var _onStart:Function=null;
		private var _oncomplete:Function=null;
		
		private var _drawingEventSensitive:Boolean = true;
		
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
				//this.map.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				if(this.map.stage)
					this.map.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				this.map.addEventListener(MapEvent.LAYERCONTAINER_IS_VISIBLE, this.onLayerContainerVisible);
				if (this._drawingEventSensitive) {
					this.map.addEventListener(DrawingEvent.DRAW_HANDLER_ACTIVATED, disactivateHandler);
					this.map.addEventListener(DrawingEvent.EDIT_HANDLER_ACTIVATED, disactivateHandler);
					this.map.addEventListener(DrawingEvent.MOVE_HANDLER_ACTIVATED, disactivateHandler);
					this.map.addEventListener(DrawingEvent.SELECT_HANDLER_ACTIVATED, activateHandler);
					this.map.addEventListener(DrawingEvent.CHANGE_ACTIVE_LAYER, activateHandler);
				}
			}
		}
		
		public function set drawingEventSensitive(value:Boolean):void{
			this._drawingEventSensitive = value;
		}
		private function disactivateHandler(event:DrawingEvent):void{
			this.active = false;
		}
		private function activateHandler(event:DrawingEvent):void{
			this.active = true;
		}
		
		override protected function unregisterListeners():void{
			if (this.map) {
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				//this.map.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				this.map.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				this.map.removeEventListener(MapEvent.LAYERCONTAINER_IS_VISIBLE, this.onLayerContainerVisible);
			}
		}
		
		/**
		 * The MouseDown Listener
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			if(event.shiftKey) return;
			
			this.startDrag();
			
			if(this.onstart!=null && event)
				this.onstart(event as MouseEvent);
		}
		
		protected function onMouseMove(event:MouseEvent):void  {
			var deltaX:Number = this.map.stage.mouseX - this._previousMapPosition.x;
			var deltaY:Number = this.map.stage.mouseY - this._previousMapPosition.y;
			this._previousMapPosition.x = this.map.stage.mouseX;
			this._previousMapPosition.y = this.map.stage.mouseY;
			this.map.pan(-deltaX, -deltaY);
		}
		
		/**
		 *The MouseUp Listener
		 */
		protected function onMouseUp(event:MouseEvent):void {
			this.stopDrag();
		}
		
		/**
		 * Stop the drag (call the map map center update with a moveTo)
		 */
		public function stopDrag():void
		{
			if(!this.dragging) return;
			
			if((!this.map) || (!this.map.stage))
				return;
			
			this.map.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
			this.map.dispatchEvent(new MapEvent(MapEvent.DRAG_END, this.map));
			this.map.buttonMode=false;
			this.dragging=false;
		}
		
		/**
		 * Start the drag action
		 */
		public function startDrag():void
		{
			if (_firstDrag) {
				this.map.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
				_firstDrag = false;
			}
			this.map.dispatchEvent(new MapEvent(MapEvent.DRAG_START, this.map));
			this.map.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
			
			this.dragging=true;
			this._previousMapPosition = new Pixel(this.map.stage.mouseX, this.map.stage.mouseY);
			
		}
			
		/**
		 * If the layerContainer become visible during a drag the offset value has to be updated
		 * 
		 * @param event The MapEvent
		 */
		public function onLayerContainerVisible(event:MapEvent):void
		{
			if(this.dragging)
				this._offset = new Pixel(this.map.mouseX - this.map.x,this.map.mouseY - this.map.y);
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
			this.map.dragging = this._dragging;
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
				this.dragging = false;
			}
		}
		public function panMap(xy:Pixel):void {
			this.dragging = true;
			var oldCenter:Location = this.map.center;
			var deltaX:Number = this._start.x - xy.x;
			var deltaY:Number = this._start.y - xy.y;
			var newPosition:Location = new Location(this._startCenter.lon + deltaX * this.map.resolution.value,
				this._startCenter.lat - deltaY * this.map.resolution.value,
				this._startCenter.projSrsCode);
			// If the new position equals the old center, stop here
			if (newPosition.equals(oldCenter)) {
				var event:MapEvent = new MapEvent(MapEvent.MOVE_NO_MOVE, this.map);
				event.oldCenter = this.map.center;
				event.newCenter = this.map.center;
				event.oldResolution = this.map.resolution;
				event.newResolution = this.map.resolution;
				this.map.dispatchEvent(event);
				//Trace.log("DragHandler.panMap INFO: new center = old center, nothing to do");
				return;
			}
			// Try to set the new position as the center of the map
			if(!this.map.maxExtent.containsLocation(newPosition))
			{
				newPosition = _lastValidCenter;
			}
			this.map.center = newPosition;
		}
	}
}

