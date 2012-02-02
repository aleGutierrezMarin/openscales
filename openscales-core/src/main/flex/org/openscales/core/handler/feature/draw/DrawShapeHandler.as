package org.openscales.core.handler.feature.draw
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.State;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAWING_END
	 */ 
	[Event(name="org.openscales.feature.drawingend", type="org.openscales.core.events.FeatureEvent")]
	
	/**
	 * This handler manage the function draw of the LineString (path).
	 * Active this handler to draw a path.
	 */
	public class DrawShapeHandler extends AbstractDrawHandler
	{		
		/**
		 * Single id of the path
		 */ 
		private var _id:Number = 0;
		
		/**
		 * The lineString which contains all points
		 * use for draw MultiLine for example
		 */
		private var _lineString:LineString=null;
		
		/**
		 * The LineStringfeature currently drawn
		 * */
		protected var _currentLineStringFeature:LineStringFeature=null;
		
		/**
		 * The last point of the lineString. 
		 */
		private var _lastPoint:Point = null; 
		
		/**
		 * To know if we create a new feature, or if some points are already added
		 */
		private var _newFeature:Boolean = true;
		
		/**
		 * The container of the temporary line
		 */
		private var _drawContainer:Sprite = new Sprite();
		
		/**
		 * The start point of the temporary line
		 */
		private var _startPoint:Pixel=new Pixel();
		
		/**
		 * 
		 */
		private var _style:Style = Style.getDefaultLineStyle();
		
		/**
		 * Handler which manage the doubleClick, to finalize the lineString
		 */
		private var _dblClickHandler:ClickHandler = new ClickHandler();
		
		/**
		 * DrawPathHandler constructor
		 *
		 * @param map
		 * @param active
		 * @param drawLayer The layer on which we'll draw
		 */
		public function DrawShapeHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
		override protected function registerListeners():void{
			this._dblClickHandler.active = true;
			this._dblClickHandler.doubleClick = this.mouseDblClick;
			if (this.map) {
				this.map.addEventListener(MouseEvent.CLICK, this.initShape);
				this.map.addEventListener(MapEvent.MOVE_END, this.updateZoom);
			} 
		}
		
		override protected function unregisterListeners():void{
			this._dblClickHandler.active = false;
			if (this.map) {
				this.map.removeEventListener(MouseEvent.CLICK, this.initShape);
				this.map.removeEventListener(MapEvent.MOVE_END, this.updateZoom);
			}
		}
		
		public function initShape(event:MouseEvent=null):void{
			//Init shape
			if(newFeature) {
				newFeature = false;
				
				drawLayer.scaleX=1;
				drawLayer.scaleY=1;
				//we determine the point where the user clicked
				//var pixel:Pixel = new Pixel(drawLayer.mouseX,drawLayer.mouseY );
				var pixel:Pixel = new Pixel(this.map.mouseX,this.map.mouseY );
				var lonlat:Location = this.map.getLocationFromMapPx(pixel); //this.map.getLocationFromLayerPx(pixel);
				//manage the case where the layer projection is different from the map projection
				var point:Point = new Point(lonlat.lon,lonlat.lat);
				//initialize the temporary line
				_startPoint = this.map.getMapPxFromLocation(lonlat);
				
				_lineString = new LineString(new <Number>[point.x,point.y]);
				_lineString.projection = this.map.projection;
				lastPoint = point;
				//the current drawn linestringfeature
				this._currentLineStringFeature= new LineStringFeature(_lineString,null, Style.getDrawLineStyle(),true);
				this._currentLineStringFeature.name = "path." + drawLayer.idPath.toString();
				drawLayer.idPath++;
				drawLayer.addFeature(_currentLineStringFeature);
				
				//draw the shape, update each time the mouse moves		
				this.map.addEventListener(MouseEvent.MOUSE_MOVE,drawShape);	
			}
		}
		
		/**
		 * This function occured when a double click occured
		 * during the drawing operation
		 * @param Lastpx: The position of the double click pixel
		 * */
		public function mouseDblClick(Lastpx:Pixel=null):void {
			this.endShape();
		} 
		
		public function endShape():void{
			
			//If we are actually drawing
			if(newFeature == false) {
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawShape);
				
				if(this._currentLineStringFeature!=null){
					//this._currentLineStringFeature.style=Style.getDefaultLineStyle();
					this._currentLineStringFeature.style=this._style;
					this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,this._currentLineStringFeature));
					drawLayer.redraw(true);
				}
				
				newFeature = true;
			}
		}
		
		/**
		 * Draw the shape while moving mouse
		 */
		public function drawShape(evt:MouseEvent):void{
			//we determine the point where the user clicked
			//var pixel:Pixel = new Pixel(drawLayer.mouseX,drawLayer.mouseY );
			var pixel:Pixel = new Pixel(this.map.mouseX,this.map.mouseY );
			var lonlat:Location = this.map.getLocationFromMapPx(pixel); //this.map.getLocationFromLayerPx(pixel);
			//manage the case where the layer projection is different from the map projection
			var point:Point = new Point(lonlat.lon,lonlat.lat);
			
			if(!point.equals(lastPoint)){
				_lineString.addPoint(point.x,point.y);
				this._currentLineStringFeature.geometry = _lineString;
				drawLayer.redraw(true);
				lastPoint = point;
			}
		}
		
		/**
		 * @inherited
		 */
		override public function set map(value:Map):void{
			super.map = value;
			this._dblClickHandler.map = value;
			if(map != null){
				map.addChild(_drawContainer);
			}
		}
		
		protected function updateZoom(evt:MapEvent):void{
			
			if(evt.zoomChanged) {
				//_drawContainer.graphics.clear();
				//we update the pixel of the last point which has changed
				var tempPoint:Point = _lineString.getLastPoint();
				_startPoint = this.map.getMapPxFromLocation(new Location(tempPoint.x, tempPoint.y));
			}
		}
		
		//Getters and Setters		
		public function get id():Number {
			return _id;
		}
		public function set id(nb:Number):void {
			_id = nb;
		}
		
		public function get newFeature():Boolean {
			return _newFeature;
		}
		
		public function set newFeature(newFeature:Boolean):void {
			if(newFeature == true) {
				lastPoint = null;
			}
			_newFeature = newFeature;
		}
		
		public function get lastPoint():Point {
			return _lastPoint;
		}
		public function set lastPoint(value:Point):void {
			_lastPoint = value;
		}
		
		public function get drawContainer():Sprite{
			return _drawContainer;
		}
		
		public function get startPoint():Pixel{
			return _startPoint;
		}
		public function set startPoint(pix:Pixel):void{
			_startPoint = pix;
		}
		
		/**
		 * The style of the path
		 */
		public function get style():Style{
			
			return this._style;
		}
		public function set style(value:Style):void{
			
			this._style = value;
		}
		public function get lineString():LineString{
			return _lineString;
		}
		public function set lineString(value:LineString):void{
			_lineString = value;
		}
		
		public function get currentLineStringFeature():LineStringFeature{
			return _currentLineStringFeature;
		}
		public function set currentLineStringFeature(value:LineStringFeature):void{
			_currentLineStringFeature = value;
		}
	}
}