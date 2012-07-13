package org.openscales.core.handler.feature.draw
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAWING_END
	 */ 
	[Event(name="org.openscales.feature.drawingend", type="org.openscales.core.events.FeatureEvent")]
	
	/**
	 * Handler to draw points.
	 */
	public class DrawRectangleHandler extends AbstractDrawHandler
	{
		/**
		 * 
		 */
		private var _style:Style = Style.getDefaultPolygonStyle();
		
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
		 * Is the rectangle is drawn
		 */
		private var _drawing:Boolean = false
		
		private var _drawContainer:Sprite = new Sprite();
		
		
		public function DrawRectangleHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
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
			}
		}
		
		/**
		 * @private
		 * 
		 * Method called on MOUSE_DOWN event
		 *  It create a selection recantgle and add MOUSE_MOVE event handling to the map
		 */ 
		private function startBox(e:MouseEvent) : void {
			
			this.registerMouseUp();
			this.map.stage.addEventListener(MouseEvent.MOUSE_MOVE,expandArea);
			this._drawing = true;
			_drawContainer.graphics.beginFill(this.fillColor,this.fillOpacity);
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
				_drawContainer.graphics.clear();
				if(!e)
					return;
				var endCoordinates:Location = this.map.getLocationFromMapPx(new Pixel(map.mouseX, map.mouseY));
				if(_startCoordinates != null && this.map.hitTestPoint(e.stageX, e.stageY)) {
					if(!_startCoordinates.equals(endCoordinates)){
						var coords:Vector.<Number> = new Vector.<Number>(8);
						var bound:Bounds = new Bounds(Math.min(_startCoordinates.lon,endCoordinates.lon),
							Math.min(endCoordinates.lat,_startCoordinates.lat),
							Math.max(_startCoordinates.lon,endCoordinates.lon),
							Math.max(endCoordinates.lat,_startCoordinates.lat),
							endCoordinates.projection).reprojectTo("EPSG:4326");
						coords[0] = bound.left;
						coords[1] = bound.bottom;
						coords[2] = bound.left;
						coords[3] = bound.top;
						coords[4] = bound.right;
						coords[5] = bound.top;
						coords[6] = bound.right;
						coords[7] = bound.bottom;
						var geoms:Vector.<Geometry> = new Vector.<Geometry>(1);
						geoms[0] = new LinearRing(coords,bound.projection);
						if(this.drawLayer)
							this.drawLayer.addFeature(new PolygonFeature(new Polygon(geoms,bound.projection),null,this._style));
					}
				}
				this._startCoordinates = null;
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
				_drawContainer.graphics.lineStyle(1,this.fillColor);
				_drawContainer.graphics.beginFill(this.fillColor,this.fillOpacity);
				_drawContainer.graphics.drawRect(ll.x,ll.y,map.mouseX - ll.x,map.mouseY - ll.y);
				_drawContainer.graphics.endFill();
			}
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
		
		/**
		 * Color of the rectangle
		 */
		public function get fillColor():uint
		{
			return 0x0F6BFF;
		}
		/**
		 * Opacity of the rectangle
		 */
		public function get fillOpacity():uint
		{
			return 0.4;
		}
		
		/**
		 * The style of the point
		 */
		public function get style():Style{
			
			return this._style;
		}
		public function set style(value:Style):void{
			
			this._style = value;
		}
		
		/**
		 * Map setter
		 */ 
		override public function set map(value:Map):void{
			super.map = value;
			if(map!=null){map.addChild(_drawContainer);}
		}
	}
}

