package org.openscales.core.handler.mouse
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.events.ZoomBoxEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.core.events.DrawingEvent;
	
	/**
	 * This handler allows user to zoom the map by drawing a rectangle with the mouse
	 * 
	 * The handler has to mode: 
	 * <ul>
	 * 	<li>Shift key need to be pressed and hold in order to draw the rectangle</li>
	 * 	<li>No keys are required</li>
	 * </ul>
	 */ 
	public class ZoomBoxHandler extends Handler
	{
		
		private var _shiftMode:Boolean = true;
		
		/**
		 * @private
		 * boolean saying if the map is currently dragged
		 */ 
		private var _dragging:Boolean = false;
		
		/**
		 * @private
		 * 
		 * Coordinates of the top left corner (of the drawing rectangle)
		 */
		private var _startCoordinates:Location = null;
		
		/**
		 * @private 
		 * 
		 * Color of the rectangle
		 */
		private var _fillColor:uint = 0xFF0000;
		
		/**
		 * @private
		 * 
		 * Is the rectangle is drawn
		 */
		private var _drawing:Boolean = false
			
		private var _drawContainer:Sprite = new Sprite();     
		
		/**
		 * Constructor
		 * 
		 * @param shiftMode Boolean specifying whether to active shift mode or not
		 * @param map The Map that will be concerned by event handling
		 * @param active Boolean defining if the handler is active or not (default=true)
		 */ 
		public function ZoomBoxHandler(shiftMode:Boolean=true, map:Map=null, active:Boolean=true):void{
			if (!shiftMode) {
				// Désactiver mouse navigation sur la map
				//map.mouseNavigationEnabled = false;
			}
			super(map, active);
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function registerListeners():void{
			if (this.map){
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, startBox);
				if (this.map.stage){
					this.registerMouseUp();
				}
				this.map.addEventListener(MapEvent.DRAG_START, dragStart);
				this.map.addEventListener(MapEvent.DRAG_END, dragEnd);
			}
		}
		
		/**
		 * @private
		 */
		private function registerMouseUp():void{
			this.map.stage.addEventListener(MouseEvent.MOUSE_UP,endBox);
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function unregisterListeners():void{
			if (this.map){
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, startBox);
				if(this.map.stage){
					this.map.stage.removeEventListener(MouseEvent.MOUSE_UP, endBox);
					this.map.stage.removeEventListener(MouseEvent.MOUSE_MOVE, expandArea);
				}
				if (shiftMode) {
					this.map.removeEventListener(MapEvent.DRAG_START, dragStart);
					this.map.removeEventListener(MapEvent.DRAG_END, dragEnd);
				}
			}
		}
		
		/**
		 * Map setter
		 */ 
		override public function set map(value:Map):void{
			super.map = value;
			if(map!=null){map.addChild(_drawContainer);}
		}
		
		/**
		 * @private
		 * 
		 * Method called on MOUSE_DOWN event
		 *  It create a selection recantgle and add MOUSE_MOVE event handling to the map
		 */ 
		private function startBox(e:MouseEvent) : void {
			
			if(!_shiftMode || !e.shiftKey || _dragging || !this.map.mouseNavigationEnabled) return;
			
			//this.map.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
			this.registerMouseUp();
			this.map.stage.addEventListener(MouseEvent.MOUSE_MOVE,expandArea);
			this._drawing = true;
			_drawContainer.graphics.beginFill(_fillColor,0.5);
			_drawContainer.graphics.drawRect(map.mouseX,map.mouseY,1,1);
			_drawContainer.graphics.endFill();
			this._startCoordinates = this.map.getLocationFromMapPx(new Pixel(map.mouseX, map.mouseY));
			
		}
		
		/**
		 * @private
		 * Method called on MOUSE_UP event. 
		 * It calculates the bounds that matches the selection rectangle and zoom the map accordingly. 
		 * <p>If the user has not drawn a rectangle, the map is center to the mouse location</p>
		 */ 
		private function endBox(e:MouseEvent) : void {
			
			if (this._drawing){
				this.map.stage.removeEventListener(MouseEvent.MOUSE_MOVE,expandArea);
				this._drawing = false;
				//this.map.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
				_drawContainer.graphics.clear();
				if(!e)
					return;
				var endCoordinates:Location = this.map.getLocationFromMapPx(new Pixel(map.mouseX, map.mouseY));
				if(_startCoordinates != null && this.map.hitTestPoint(e.stageX, e.stageY)) {
					if(!_startCoordinates.equals(endCoordinates)){
						this.map.zoomToExtent(new Bounds(Math.min(_startCoordinates.lon,endCoordinates.lon),
							Math.min(endCoordinates.lat,_startCoordinates.lat),
							Math.max(_startCoordinates.lon,endCoordinates.lon),
							Math.max(endCoordinates.lat,_startCoordinates.lat),
							endCoordinates.projection));
					}
				}
				this._startCoordinates = null;
				this.map.dispatchEvent(new ZoomBoxEvent(ZoomBoxEvent.END));
				this.map.stage.focus = this.map; // Giving focus back to the map
			}
		}
		
		/**
		 * @private 
		 * Method called on MOUSE_MOVE event. It redraws the selection relcantgle
		 */ 
		private function expandArea(e:MouseEvent) : void {
			
			if (! this.map.hitTestPoint(e.stageX, e.stageY)){
				this.endBox(e);
			}else{
				var ll:Pixel = map.getMapPxFromLocation(_startCoordinates);
				_drawContainer.graphics.clear();
				_drawContainer.graphics.lineStyle(1,_fillColor);
				_drawContainer.graphics.beginFill(_fillColor,0.25);
				_drawContainer.graphics.drawRect(ll.x,ll.y,map.mouseX - ll.x,map.mouseY - ll.y);
				_drawContainer.graphics.endFill();
			}
		}
		
		/**
		 * Boolean specifying whether the shift mode is active or not
		 */
		public function get shiftMode():Boolean
		{
			return _shiftMode;
		}

		/**
		 * @private
		 */
		public function set shiftMode(value:Boolean):void
		{
			if (!value) {
				// Désactiver mouse navigation sur la map
			}
			_shiftMode = value;
		}
		
		/**
		 * @private
		 * Callback of the MapEvent.DRAG_START event to set the dragging boolean;
		 */
		private function dragStart(event:MapEvent):void{
			this._dragging = true;
		}
		
		/**
		 * @private
		 * Callback of the MapEvent.DRAG_END event to set the dragging boolean;
		 */
		private function dragEnd(event:MapEvent):void{
			this._dragging = false;
		}
		
		private function  onMouseOut(event:MouseEvent):void{
			if(event.target!=this.map)
				return;
			this.endBox(null);
		}


	}
}