package org.openscales.core.handler.mouse
{
	import fl.transitions.*;
	import fl.transitions.easing.*;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openscales.core.Map;
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
		private var _firstDrag:Boolean = true;
		private var _dragging:Boolean = false;
		private var _previousMapPosition:Pixel = new Pixel(0,0);
		private var _startDragPosition:Pixel;
		private var _tweenerX:Tween;
		private var _tweenerY:Tween;
		private var _previousX:Number = 0;
		private var _previousY:Number = 0;
		private var _timer:Timer;
		private var _previousCenter:Pixel = new Pixel(0,0);
		private var _deltaDistanceInTimerTimeX:Number;
		private var _deltaDistanceInTimerTimeY:Number;
		
		private var _activateTweenEffect:Boolean = false;
		
		/**
		 * Used to store the center when we reach the limit of the max extend.
		 */
		private var _lastValidCenter:Location = null;
		
		/**
		 * Callbacks function
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
			this._timer = new Timer(50,1);
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimerEnd);
		}
		
		public function onTimerEnd(event:TimerEvent):void
		{
			this._deltaDistanceInTimerTimeX = this.map.stage.mouseX - this._previousCenter.x;
			this._deltaDistanceInTimerTimeY = this.map.stage.mouseY - this._previousCenter.y;
			this._previousCenter = new Pixel(this.map.stage.mouseX, this.map.stage.mouseY);
			this._timer.reset();
			this._timer.start();
		}
		
		override protected function registerListeners():void
		{
			if(this.map)
			{
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.addEventListener(MapEvent.LAYERCONTAINER_IS_VISIBLE, this.onLayerContainerVisible);
				if(this.map.stage)
					this.map.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			}
		}
		
		override protected function unregisterListeners():void
		{
			if(this.map)
			{
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.removeEventListener(MapEvent.LAYERCONTAINER_IS_VISIBLE, this.onLayerContainerVisible);
				if(this.map.stage)
					this.map.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			}
		}
		
		/**
		 * The MouseDown Listener
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			if (this._tweenerX)
			{
				this._tweenerX.removeEventListener(TweenEvent.MOTION_FINISH, onTweenFinish);
				this._tweenerX.stop();
			}
			if (this._tweenerY)
				this._tweenerY.stop();
			
			this.dragging=false;
			if(event.shiftKey) return;
			if(!this.map.mouseNavigationEnabled) return;
			
			this._previousX = 0;
			this._previousY = 0;
			this.startDrag();
			if (_activateTweenEffect)
			{
				this._timer.start();
				this._timer.addEventListener(TimerEvent.TIMER, this.onTimerEnd);
				this._previousCenter = new Pixel(this.map.stage.mouseX, this.map.stage.mouseY)
				this._previousMapPosition.x = this.map.stage.mouseX;
				this._previousMapPosition.y = this.map.stage.mouseY;
			}
			if(this.onstart != null && event)
				this.onstart(event as MouseEvent);
		}
		
		protected function onMouseMove(event:MouseEvent):void  {
			if(!this.map.mouseNavigationEnabled) return;
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
			this._timer.removeEventListener(TimerEvent.TIMER, this.onTimerEnd);
			this._timer.reset();
			
			this.map.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
			this.map.dispatchEvent(new MapEvent(MapEvent.DRAG_END, this.map));
			this.map.buttonMode=false;
			
			
			if (_activateTweenEffect)
			{
				var vX:Number = Math.abs(this._deltaDistanceInTimerTimeX/0.1);
				var vY:Number = Math.abs(this._deltaDistanceInTimerTimeY/0.1);
				
				var deltaX:Number = (this.map.stage.mouseX - this._startDragPosition.x)*(Math.min(vX, 900)/900);
				var deltaY:Number = (this.map.stage.mouseY - this._startDragPosition.y)*(Math.min(vY, 900)/900);
				
	
				this._tweenerX =new Tween(this, "mapX", Regular.easeOut, 0, -deltaX, 0.5, true);
				this._tweenerY =new Tween(this, "mapY", Regular.easeOut, 0, -deltaY, 0.5, true);
				this._tweenerX.addEventListener(TweenEvent.MOTION_FINISH,onTweenFinish);
			}
		}
		
		public function onTweenFinish(event:TweenEvent):void
		{
			this.dragging=false;
		}
		
		public function set mapX(value:Number):void
		{
			var delta:Number = value - this._previousX;
			this._previousX = value;
			this.map.pan(delta, 0);
		}
		
		public function set mapY(value:Number):void
		{
			var delta:Number = value - this._previousY;
			this._previousY = value;
			this.map.pan(0, delta);
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
			this._startDragPosition = new Pixel(this.map.stage.mouseX, this.map.stage.mouseY);
			
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
		 * Activate or not the tween effect while moving
		 * defualt to true
		 */
		public function set activateTweenEffect(value:Boolean):void
		{
			this._activateTweenEffect = value;
		}
		public function get activateTweenEffect():Boolean
		{
			return this._activateTweenEffect;
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
		
		public function panMap(xy:Pixel):void {
			this.dragging = true;
			var oldCenter:Location = this.map.center;
			var deltaX:Number = this._start.x - xy.x;
			var deltaY:Number = this._start.y - xy.y;
			var newPosition:Location = new Location(this._startCenter.lon + deltaX * this.map.resolution.value,
				this._startCenter.lat - deltaY * this.map.resolution.value,
				this._startCenter.projection);
			// If the new position equals the old center, stop here
			if (newPosition.equals(oldCenter)) {
				var event:MapEvent = new MapEvent(MapEvent.MOVE_NO_MOVE, this.map);
				event.oldCenter = this.map.center;
				event.newCenter = this.map.center;
				event.oldResolution = this.map.resolution;
				event.newResolution = this.map.resolution;
				this.map.dispatchEvent(event);
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

