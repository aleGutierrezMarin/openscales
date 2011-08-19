package org.openscales.core.handler.multitouch {
	
	
	import flash.events.GestureEvent;
	import flash.events.GesturePhase;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	import spark.components.Label;
	
	/**
	 * Handler use to pan and zoom the map using multitouch.
	 * Pan can be done with one or sevral finger (on touch and drag)
	 * Zoom in on double tap or zoom mlore and less using zoom Gesture
	 * 
	 * Pan and zoom can occur silmutaneously and both are applied to the map
	 * 
	 * Each action can be active / desactive by default they are all set to true
	 * 
	 */
	public class MapGestureHandler extends Handler {
		
		protected var _zoomOnDoubleTap:Boolean = true;
		protected var _zoomWithZoomGesture:Boolean = true;
		protected var _panOnDrag:Boolean = true;
		
		protected var _zoomHandler:ZoomGestureHandler;
		protected var _dragHandler:DragHandler;
		
		protected var cummulativeScaleX:Number;
		protected var cummulativeScaleY:Number;
		
		private var _startCenter:Location = null;
		private var _start:Pixel = null;
		private var _offset:Pixel = null;
		private var _layerContainerPositionBeforeDrag:Pixel =null;
		
		private var _mouseOffsetLayerContainerCenter:Pixel = new Pixel();	
		private var _firstDrag:Boolean = true;	
		private var _dragging:Boolean = false;
		
		/**
		 * Used to store the center when we reach the limit of the max extend.
		 */
		private var _lastValidCenter:Location = null;
		
		/**
		 *Callbacks function
		 */
		private var _onStart:Function=null;
		private var _oncomplete:Function=null;
		
		protected var _currentCenter:Pixel;
		
		public function MapGestureHandler(target:Map = null, active:Boolean = true) {
			super(target,active);
		}
		
		override protected function registerListeners():void {
			if (this.map) {
				if(Multitouch.inputMode != MultitouchInputMode.GESTURE)
					Multitouch.inputMode = MultitouchInputMode.GESTURE;
				this.map.addEventListener(TransformGestureEvent.GESTURE_ZOOM, this.onGestureZoom);
				//			this.map.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP,this.onTwoFingerTap);
				this.map.addEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);			
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				this.map.addEventListener(MapEvent.LAYERCONTAINER_IS_VISIBLE, this.onLayerContainerVisible);
			}
		}
		
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(TransformGestureEvent.GESTURE_ZOOM,this.onGestureZoom);
				//			this.map.removeEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP,this.onTwoFingerTap);
				this.map.removeEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				this.map.removeEventListener(MapEvent.LAYERCONTAINER_IS_VISIBLE, this.onLayerContainerVisible);
				
			}
		}
		
		private var _touchPoint:Location;
		
		private function onGestureZoom(event:TransformGestureEvent):void {
			
			var zoom:int = 0;
			// Zoom in or out (according to the sign of the cummulativeX and Y dot)
			var sign:int = 1;
			
			if (event.phase==GesturePhase.BEGIN) {
				
				this._startCenter = this.map.center;
				
				this.cummulativeScaleX = 1;
				this.cummulativeScaleY = 1;
				
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
				
				_touchPoint = this.map.baseLayer.getLocationFromMapPx(new Pixel(event.stageX, event.stageY));
				
				Trace.debug("touch x: "+_touchPoint.lon+" y:"+_touchPoint.lat);
				
			} else if (event.phase==GesturePhase.UPDATE) {
				
				this.cummulativeScaleX = this.cummulativeScaleX * event.scaleX;
				this.cummulativeScaleY = this.cummulativeScaleY * event.scaleY;
				
				var pinchMatrix:Matrix = this.map.layerContainer.transform.matrix;
				var pinchPoint:Point =
					pinchMatrix.transformPoint(
						new Point(event.stageX, event.stageY));
				pinchMatrix.translate(-pinchPoint.x, -pinchPoint.y);
				pinchMatrix.scale(event.scaleX, event.scaleY);
				pinchMatrix.translate(pinchPoint.x, pinchPoint.y);
				this.map.layerContainer.transform.matrix = pinchMatrix;
				
				
			} if (event.phase==GesturePhase.END) {
				
				sign = cummulativeScaleX*cummulativeScaleY
				if(sign > 1) 
				{
					sign = 1;
					zoom = Math.round(cummulativeScaleX);
					zoom = Math.log(cummulativeScaleX) / Math.log(2);
					zoom = Math.round(zoom);
					
					if(zoom+this.map.zoom > this.map.baseLayer.maxZoomLevel)
						zoom = this.map.baseLayer.maxZoomLevel - this.map.zoom;
				}
					
				else
				{
					sign = -1;
					
					zoom = Math.log(cummulativeScaleX) / Math.log(1/2);
					zoom = Math.round(zoom);
					
					if(this.map.zoom-zoom < this.map.baseLayer.minZoomLevel)
						zoom = this.map.baseLayer.maxZoomLevel - this.map.zoom;
				}
				
				
				const px:Pixel = new Pixel(event.stageX, event.stageY);
				const centerPx:Pixel = new Pixel(this.map.width/2, this.map.height/2);
				
				var origin:Pixel = new Pixel(this.map.layerContainer.x, this.map.layerContainer.y);
				
				
				var deltaPx:Pixel = new Pixel();
				
				deltaPx.x = centerPx.x-px.x;
				deltaPx.y = centerPx.y-px.y;
				
				var idZoom:int = (this.map.zoom +(sign*zoom));
				
				var newPosition:Location = new Location(
					this._touchPoint.lon + deltaPx.x * this.map.baseLayer.resolutions[idZoom],
					this._touchPoint.lat - deltaPx.y * this.map.baseLayer.resolutions[idZoom],
					this._touchPoint.projSrsCode);
				
				if(zoom!=0 && this.map.maxExtent.containsLocation(newPosition))
				{
					this.map.layerContainer.transform.matrix = pinchMatrix;
					
					this.map.layerContainer.scaleX = 1;
					this.map.layerContainer.scaleY = 1;
					
					this.map.moveTo(newPosition, (this.map.zoom +(sign*zoom)), false, true);
				}	
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			}
		}
		
		private function onTwoFingerTap(event:GestureEvent):void {
			this.map.moveTo(this.map.center, this.map.zoom + 1, false, true);
		}
		
		private function onDoubleClick(event:MouseEvent):void {
			this.map.moveTo(this.map.getLocationFromMapPx(new Pixel(event.stageX, event.stageY)), this.map.zoom + 1, false, true);
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
			
			var dx:int=this.map.layerContainer.x-(this.map.layerContainer.parent.mouseX - this._offset.x);
			var dy:int=this.map.layerContainer.y-(this.map.layerContainer.parent.mouseY - this._offset.y);
			
			var deltaX:Number = this._start.x - this.map.mouseX;
			var deltaY:Number = this._start.y - this.map.mouseY;
			var newPosition:Location = new Location(this._startCenter.lon + deltaX * this.map.resolution,
				this._startCenter.lat - deltaY * this.map.resolution,
				this._startCenter.projSrsCode);
			
			
			//	Trace.debug(this._offset.x +" "+this._offset.y);
			if(this.map.maxExtent.containsLocation(newPosition))
			{
				_lastValidCenter = newPosition;
				
				var pinchMatrix:Matrix = this.map.layerContainer.transform.matrix;
				pinchMatrix.translate(-dx, -dy);
				this.map.layerContainer.transform.matrix = pinchMatrix;
			}
			
			// Force update regardless of the framerate for smooth drag
			event.updateAfterEvent();
		}
		
		/**
		 *The MouseUp Listener
		 */
		protected function onMouseUp(event:MouseEvent):void {
			
			this.stopDrag();
			
			if (this.oncomplete!=null && event)
				this.oncomplete(event as MouseEvent);
		}
		
		/**
		 * Stop the drag (call the map map center update with a moveTo)
		 */
		public function stopDrag():void
		{
			if(!this.dragging) return;
			
			if((!this.map) || (!this.map.stage))
				return;
			
			this.map.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
			this.map.dispatchEvent(new MapEvent(MapEvent.DRAG_END, this.map));
			this.map.buttonMode=false;
			this.done(new Pixel(this.map.mouseX, this.map.mouseY));
			// A MapEvent.MOVE_END is emitted by the "set center" called in this.done
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
			this.map.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
			
			this._start = new Pixel(this.map.mouseX,this.map.mouseY);
			
			this._offset = new Pixel(this.map.mouseX - this.map.layerContainer.x,this.map.mouseY - this.map.layerContainer.y);
			this._startCenter = this.map.center;
			this.map.buttonMode=true;
			this._layerContainerPositionBeforeDrag = new Pixel(this.map.layerContainer.x, this.map.layerContainer.y);
			this.dragging=true;
		}
		
		/**
		 * If the layerContainer become visible during a drag the offset value has to be updated
		 * 
		 * @param event The MapEvent
		 */
		public function onLayerContainerVisible(event:MapEvent):void
		{
			if(this.dragging)
			{
				this._offset = new Pixel(this.map.mouseX - this.map.layerContainer.x,this.map.mouseY - this.map.layerContainer.y);
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
			if(!this.map.maxExtent.containsLocation(newPosition))
			{
				newPosition = _lastValidCenter;
			}
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
		
		/* Getter / Setter */
		/**
		 * Indicates if the zoom on double tap is active
		 * @default true
		 */
		public function get zoomOnDoubleTap():Boolean
		{
			return _zoomOnDoubleTap;
		}
		
		/**
		 * @private
		 */
		public function set zoomOnDoubleTap(value:Boolean):void
		{
			_zoomOnDoubleTap = value;
		}
		
		/**
		 * Indicates if the zoom with multitouch gesture is active (zoom with two fingers)
		 * @default true
		 */
		public function get zoomWithZoomGesture():Boolean
		{
			return _zoomWithZoomGesture;
		}
		
		/**
		 * @private
		 */
		public function set zoomWithZoomGesture(value:Boolean):void
		{
			_zoomWithZoomGesture = value;
		}
		
		/**
		 * Indicates if the pan on finger touch is active
		 * @default true
		 */
		public function get panOnDrag():Boolean
		{
			return _panOnDrag;
		}
		
		/**
		 * @private
		 */
		public function set panOnDrag(value:Boolean):void
		{
			_panOnDrag = value;
		}
	}
}
