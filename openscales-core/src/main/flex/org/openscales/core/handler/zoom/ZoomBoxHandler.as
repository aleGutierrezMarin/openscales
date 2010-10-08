package org.openscales.core.handler.zoom
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Pixel;
	import org.openscales.core.Map;
	import org.openscales.core.events.HandlerEvent;
	import org.openscales.core.events.ZoomBoxEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.HandlerBehaviour;
	import org.openscales.core.handler.mouse.DragHandler;
	
	public class ZoomBoxHandler extends Handler
	{
		
		/**
		 * Coordinates of the top left corner (of the drawing rectangle)
		 */
		private var _startCoordinates:Location = null;
		
		/**
		 * Color of the rectangle
		 */
		private var _fillColor:uint = 0xFF0000
		private var _drawContainer:Sprite = new Sprite();     
		
		public function ZoomBoxHandler(map:Map=null, active:Boolean=false):void{
			// ZoomBoxHandler is a draw handler
			this.behaviour = HandlerBehaviour.MOVE;
			super(map, active, this.behaviour);
		}
		
		override protected function registerListeners():void{
			if (this.map) {
				super.registerListeners();
				this.map.addEventListener(MouseEvent.MOUSE_DOWN,startBox);
				this.map.addEventListener(MouseEvent.MOUSE_UP,endBox);     
			}
		}
		
		override protected function unregisterListeners():void{
			if (this.map) {
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN,startBox);
				this.map.removeEventListener(MouseEvent.MOUSE_UP,endBox);
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,expandArea);
				super.unregisterListeners();
			}
		}
		
		override public function set map(value:Map):void{
			super.map = value;
			if(map!=null){map.addChild(_drawContainer);}
		}
		
		private function startBox(e:MouseEvent) : void {
			this.map.addEventListener(MouseEvent.MOUSE_MOVE,expandArea);
			_drawContainer.graphics.beginFill(_fillColor,0.5);
			_drawContainer.graphics.drawRect(map.mouseX,map.mouseY,1,1);
			_drawContainer.graphics.endFill();
			this._startCoordinates = this.map.getLocationFromMapPx(new Pixel(map.mouseX, map.mouseY));
			
		}
		
		private function endBox(e:MouseEvent) : void {
			this.map.removeEventListener(MouseEvent.MOUSE_MOVE,expandArea);
			this.map.removeEventListener(MouseEvent.MOUSE_DOWN,startBox);
			this.map.removeEventListener(MouseEvent.MOUSE_UP,endBox);
			_drawContainer.graphics.clear();
			var endCoordinates:Location = this.map.getLocationFromMapPx(new Pixel(map.mouseX, map.mouseY));
			if(_startCoordinates != null) {
				if(_startCoordinates.equals(endCoordinates)){
					this.map.moveTo(endCoordinates);
				}else{
					this.map.zoomToExtent(new Bounds(Math.min(_startCoordinates.lon,endCoordinates.lon),
						Math.min(endCoordinates.lat,_startCoordinates.lat),
						Math.max(_startCoordinates.lon,endCoordinates.lon),
						Math.max(endCoordinates.lat,_startCoordinates.lat),
						endCoordinates.projection));
				}
			}
			this._startCoordinates = null;
			this.active = false;
			activeDrag();
			this.map.dispatchEvent(new ZoomBoxEvent(ZoomBoxEvent.END));
		}
		
		private function expandArea(e:MouseEvent) : void {
			var ll:Pixel = map.getMapPxFromLocation(_startCoordinates);
			_drawContainer.graphics.clear();
			_drawContainer.graphics.lineStyle(1,_fillColor);
			_drawContainer.graphics.beginFill(_fillColor,0.25);
			_drawContainer.graphics.drawRect(ll.x,ll.y,map.mouseX - ll.x,map.mouseY - ll.y);
			_drawContainer.graphics.endFill();
		}
		
		/**
		 * Active paning
		 * User can pan the map
		 */
		public function activeDrag():void{
			var handler:Handler;
			for each(handler in this.map.handlers) {
				if (handler is DragHandler) {
					handler.active = true;
				}
			}
		}
		
		/**
		 * Deactive paning
		 * User can't pan map anymore
		 */
		public function deactiveDrag():void{
			var handler:Handler;
			for each(handler in this.map.handlers) {
				if (handler is DragHandler) {
					handler.active = false;
				}
			}
		}
		
		/**
		 * Callback use when another handler is activated
		 */
		override protected function onOtherHandlerActivation(handlerEvent:HandlerEvent):void{
			// Check if it's not the current handler which has just been activated
			if(handlerEvent != null) {
				if(handlerEvent.handler != this) {
					if(handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.MOVE) {
						// A move handler has been activated
						// Do nothing, we leave the handler in its state
					} else if (handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.SELECT) {
						// A select handler has been activated
						this.active = false;
					} else if (handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.DRAW) {
						// A draw handler has been activated
						this.active = false;
					} else {
						// Do nothing
					}
				}
			}
		}
	}
}