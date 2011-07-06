package org.openscales.core.handler.mouse
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.charts.chartClasses.BoundedValue;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.geometry.basetypes.Bounds;
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

       private var _newBounds:Bounds = null;
		
		private var _w_deg:Number = 0.0;
		private var _h_deg:Number = 0.0;
		
		
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
				this.map.addEventListener(MapEvent.LAYERCONTAINER_IS_VISIBLE, this.onLayerContainerVisible);
			}
		}
		
		override protected function unregisterListeners():void{
			if (this.map) {
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				this.map.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
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

			this.done();
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
			var resol:Number = this.map.resolution;
			this._w_deg = this.map.size.w * resol;
			this._h_deg = this.map.size.h * resol;
			

			Trace.log("before => map extend" + this.map.extent.toString());
			this._newBounds =  this.map.extent.clone();
            this.map.buttonMode=true;
			this.dragging=true;
		}
		
		protected function testLon(maxExtend:Bounds,extent:Bounds):Boolean{
			
			
			var inTop:Boolean;
			
			var inBottom:Boolean;
			
			inTop = (maxExtend.top > extent.bottom) && (maxExtend.top < extent.top);
			inBottom = (maxExtend.bottom > extent.bottom) && (maxExtend.bottom < extent.top);
			return (inTop && inBottom);
			
		}
		
		protected function testLat(maxExtend:Bounds,extent:Bounds):Boolean{
			var inRight:Boolean;
			var inLeft:Boolean;
			inLeft = (maxExtend.left > extent.left) && (maxExtend.left < extent.right);
			inRight= (maxExtend.right > extent.left) && (maxExtend.right < extent.right);
			return (inLeft && inRight);
		}
		
		protected function onMouseMove(event:MouseEvent):void  {
			
			//take new center
			var resol:Number = this.map.resolution;
			//calcul new position
			var deltaX:Number = this._start.x - this.map.mouseX;
			var deltaY:Number = this._start.y - this.map.mouseY;
			var newPosition:Location = new Location(this._startCenter.lon + deltaX * resol,
				this._startCenter.lat - deltaY * resol,
				this._startCenter.projSrsCode);
			
			var extent:Bounds = new Bounds(newPosition.lon - this._w_deg / 2,
				newPosition.lat - this._h_deg / 2,
				newPosition.lon + this._w_deg / 2,
				newPosition.lat + this._h_deg / 2,
				newPosition.projSrsCode);
			Trace.log("maxextend" + this.map.maxExtent.toString());
			Trace.log("current extend" + extent.toString());
			
			var maxExtent:Bounds = this.map.maxExtent;
			
			if(testLat(extent,maxExtent)){
			  this.map.layerContainer.x = this.map.layerContainer.parent.mouseX - this._offset.x;
			  this._newBounds.left = extent.left;
			  this._newBounds.right = extent.right;
			
			}
			if(testLon(extent,maxExtent)){
			  this.map.layerContainer.y =  this.map.layerContainer.parent.mouseY - this._offset.y;
			  this._newBounds.top = extent.top;
			  this._newBounds.bottom = extent.bottom;
			}
			if(this.map.bitmapTransition) {
				if(testLat(maxExtent,extent))
					this.map.bitmapTransition.x = this.map.bitmapTransition.parent.mouseX - this._offset.x;
				if(testLon(maxExtent,extent))
					this.map.bitmapTransition.y =  this.map.bitmapTransition.parent.mouseY - this._offset.y;
			}
			event.updateAfterEvent();
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
		private function done():void {
			if (this.dragging) {
				this.panMap();
				this.dragging = false;
			}
		}
		
		public function panMap():void {
			this.dragging = true;
			if(this._newBounds == null) return;
			// If the new position equals the old center, stop here
			var oldCenter:Location = this.map.center;
			if (this._newBounds.center.equals(oldCenter)) {
				var event:MapEvent = new MapEvent(MapEvent.MOVE_NO_MOVE, this.map);
				event.oldCenter = this.map.center;
				event.newCenter = this.map.center;
				event.oldZoom = this.map.zoom;
				event.newZoom = this.map.zoom;
				this.map.dispatchEvent(event);
				//Trace.log("DragHandler.panMap INFO: new center = old center, nothing to do");
				return;
			}
			var extent:Bounds = _newBounds.clone();
			if(!this.map.maxExtent.containsBounds(extent)) return;
			this.map.center = this._newBounds.center.clone();

		}
	}
}

