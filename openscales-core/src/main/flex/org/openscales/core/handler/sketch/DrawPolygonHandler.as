package org.openscales.core.handler.sketch
{
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.LonLat;
	import org.openscales.core.basetypes.Pixel;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.geometry.LinearRing;
	import org.openscales.core.geometry.Point;
	import org.openscales.core.geometry.Polygon;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;

	/**
	 * This handler manage the function draw of the polygon.
	 * Active this handler to draw a polygon.
	 */
	public class DrawPolygonHandler extends AbstractDrawHandler
	{
		/**
		 * polygon feature which is currently drawn
		 * */
		 
		 private var _polygonFeature:PolygonFeature=null;
		
		/**
		 *this attribute is used to see a point the first time 
		 * a user clicks 
		 **/
		
		private var _firstPointFeature:PointFeature=null;
		
		/**
		 * To know if we create a new feature, or if some points are already added
		 */
		private var _newFeature:Boolean = true;
		
		/**
		 * Handler which manage the doubleClick, to finalize the polygon
		 */
		private var _dblClickHandler:ClickHandler = new ClickHandler();
		
		/**
		 * As we draw a first point to know where we started the polygon
		 */
		private var _firstPointRemoved:Boolean = false;
		
		/**
		 * Single id of the polygon
		 */
		private var id:Number = 0;

		/**
		 * Constructor of the polygon handler
		 * 
		 * @param map the map reference
		 * @param active determine if the handler is active or not
		 * @param drawLayer The layer on which we'll draw
		 */
		public function DrawPolygonHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
		}

		override protected function registerListeners():void{
			this._dblClickHandler.active = true;
			this._dblClickHandler.doubleclick = this.mouseDblClick;
			this.map.addEventListener(MouseEvent.CLICK, this.mouseClick);	
		}

		override protected function unregisterListeners():void{
			this._dblClickHandler.active = false;
			this.map.removeEventListener(MouseEvent.CLICK, this.mouseClick);
		}
		
		public function mouseClick(event:MouseEvent):void {

			if (drawLayer != null) {

				var name:String = "polygon."+id.toString(); id++;
				
				//we determine the point where the user clicked
				var pixel:Pixel = new Pixel(drawLayer.mouseX ,drawLayer.mouseY);
				var lonlat:LonLat = this.map.getLonLatFromLayerPx(pixel);
				//manage the case where the layer projection is different from the map projection
				if(this.drawLayer.projection.srsCode!=this.map.projection.srsCode)
				lonlat.transform(this.map.projection,this.drawLayer.projection);
				var point:Point = new Point(lonlat.lon,lonlat.lat);
				var lring:LinearRing=null;
				var polygon:Polygon=null;
				//2 cases, and very different. If the user starts the polygon or if the user is drawing the polygon
				if(newFeature) {					
					 lring = new LinearRing([point]);
					 polygon = new Polygon([lring]);
					
				//	var polygonFeature:PolygonFeature = new PolygonFeature(polygon);
					
					this._polygonFeature=new PolygonFeature(polygon);
					
					
					//this._polygonFeature=new PolygonFeature(				
					this._polygonFeature.style = Style.getDrawSurfaceStyle();

					// We create a point the first time to see were the user clicked
					this._firstPointFeature=  new PointFeature(point);
					
					//add the point feature to the drawLayer, and the polygon (which contains only one point for the moment)
					drawLayer.addFeature(this._firstPointFeature);
					drawLayer.addFeature(this._polygonFeature);
					this._polygonFeature.unregisterListeners();
					this._firstPointFeature.unregisterListeners();

					newFeature = false;
				}
				else {
					drawLayer.removeFeature(this._firstPointFeature);
					//add the point to the linearRing
					 lring=(this._polygonFeature.geometry as Polygon).componentByIndex(0) as LinearRing;
					lring.addComponent(point);
					drawLayer.redraw();
				}
			}		
		}

		public function mouseDblClick(event:MouseEvent):void {
			drawFinalPoly();
		}
		
		/**
		 * Finish the polygon
		 */
		public function drawFinalPoly():void{
			//Change style of finished polygon
			var style:Style = Style.getDefaultSurfaceStyle();
			
			//We finalize the last feature (of course, it's a polygon)
			//var feature:VectorFeature = drawLayer.features[drawLayer.features.length - 1];
			
			if(this._polygonFeature!=null){
				//the user just drew one point, it's not a real polygon so we delete it 
				
				(drawLayer as VectorLayer).removeFeature(this._firstPointFeature);
				//Check if the polygon (in fact, the linearRing) contains at least 3 points (if not, it's not a polygon)
				if((this._polygonFeature.polygon.componentByIndex(0) as LinearRing).componentsLength>2){
					//Apply the "finished" style
					this._polygonFeature.style = style;	
					this._polygonFeature.registerListeners();				
				}
				else{
					drawLayer.removeFeature(this._polygonFeature);
				}
				drawLayer.redraw();
			}
			//the polygon is finished
			newFeature = true;
		}

		override public function set map(value:Map):void {
			super.map = value;
			this._dblClickHandler.map = value;
		}

		//Getters and Setters


		public function get newFeature():Boolean {
			return _newFeature;
		}

		public function get firstPointRemoved():Boolean {
			return _firstPointRemoved;
		}

		public function set newFeature(value:Boolean):void {
			_newFeature = value;
		}

		public function get clickHandler():ClickHandler {
			return _dblClickHandler;
		}
	}
}

