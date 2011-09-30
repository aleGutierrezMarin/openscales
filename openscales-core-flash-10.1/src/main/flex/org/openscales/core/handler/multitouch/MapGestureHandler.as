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
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.filter.ElseFilter;
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
		private var _positionBeforeDrag:Pixel =null;
		
		private var _mouseOffsetLayerContainerCenter:Pixel = new Pixel();	
		private var _firstDrag:Boolean = true;	
		private var _dragging:Boolean = false;
		
		private var _originalMatrix:Matrix = null;
		
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
			}
		}
		
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(TransformGestureEvent.GESTURE_ZOOM,this.onGestureZoom);
				//			this.map.removeEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP,this.onTwoFingerTap);
				this.map.removeEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				
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
				
				_touchPoint = this.map.getLocationFromMapPx(new Pixel(event.stageX, event.stageY));
				/*
				var scaleX:Number = this.map.layerContainer.scaleX;
				var scaleY:Number = this.map.layerContainer.scaleY;
				
				if(scaleX != 1 || scaleY !=1)
				{
					var initMatrix:Matrix = this.map.layerContainer.transform.matrix;
					var centerPoint:Point =
						initMatrix.transformPoint(
							new Point(this.map.width/2, this.map.height/2));
					initMatrix.translate(-centerPoint.x, -centerPoint.y);
					initMatrix.scale(1/scaleX, 1/scaleY);
					initMatrix.translate(centerPoint.x, centerPoint.y);
					this.map.layerContainer.transform.matrix = initMatrix;
				}
				
				
				this._originalMatrix = this.map.layerContainer.transform.matrix;
				*/
				
				
			} else if (event.phase==GesturePhase.UPDATE) {
				
				this.cummulativeScaleX = this.cummulativeScaleX * event.scaleX;
				this.cummulativeScaleY = this.cummulativeScaleY * event.scaleY;
				
				this.map.zoom(1/(this.cummulativeScaleX*this.cummulativeScaleY),new Pixel(event.stageX, event.stageY));
				//Trace.debug("CUMULATIVE SCALE : " + 1/(this.cummulativeScaleX*this.cummulativeScaleY));
				this.cummulativeScaleX = 1;
				this.cummulativeScaleY = 1;
				
			} if (event.phase==GesturePhase.END) {
				
				const px:Pixel = new Pixel(event.stageX, event.stageY);
				
				sign = cummulativeScaleX*cummulativeScaleY
				if(sign > 1) 
				{
					this.map.zoomIn(px);
				} else {
					/*
					sign = -1;
					
					zoom = Math.log(cummulativeScaleX) / Math.log(1/2);
					zoom = Math.round(zoom);
					
					if(this.map.zoom-zoom < this.map.baseLayer.minZoomLevel)
						zoom = this.map.baseLayer.maxZoomLevel - this.map.zoom;
					*/
					this.map.zoomOut(px);
				}
								
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				
			}
		}
		
		
		private function onDoubleClick(event:MouseEvent):void {
			this.map.zoomIn(new Pixel(event.stageX, event.stageY));
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
			
			var deltaX:Number = this.map.stage.mouseX - this._positionBeforeDrag.x;
			var deltaY:Number = this.map.stage.mouseY - this._positionBeforeDrag.y;

			this.map.pan(-deltaX, -deltaY);
			this._positionBeforeDrag.x = this.map.stage.mouseX;
			this._positionBeforeDrag.y = this.map.stage.mouseY;
			
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
			this._positionBeforeDrag = new Pixel(this.map.stage.mouseX, this.map.stage.mouseY);
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
