package org.openscales.core.handler.feature.draw
{
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.core.style.marker.WellKnownMarker;

	/**
	 * Handler to draw points.
	 */
	public class DrawPointHandler extends AbstractDrawHandler
	{

		/**
		 * The layer in which we'll draw
		 */
		private var _drawLayer:VectorLayer = null;

		/**
		 * Single ID for point
		 */		
		private var id:Number = 0;
		
		/**
		 * 
		 */
		private var _style:Style = Style.getDefaultPointStyle();
		

		public function DrawPointHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
		}

		override protected function registerListeners():void{
			if (this.map) {
				this.map.addEventListener(MouseEvent.CLICK, this.drawPoint);
			}
		}

		override protected function unregisterListeners():void{
			if (this.map) {
				this.map.removeEventListener(MouseEvent.CLICK, this.drawPoint);
			}
		}

		/**
		 * Create a point and draw it
		 */		
		protected function drawPoint(event:MouseEvent):void {
			//We draw the point
			if (drawLayer != null){
				
				drawLayer.scaleX=1;
				drawLayer.scaleY=1;
			  
				//var style:Style = Style.getDefaultPointStyle();
				//var style:Style = Style.getDefinedPointStyle(WellKnownMarker.WKN_TRIANGLE,0);
			
				//var pixel:Pixel = new Pixel(drawLayer.mouseX ,drawLayer.mouseY);
				var pixel:Pixel = new Pixel(this.map.mouseX,this.map.mouseY );
				var lonlat:Location = this.map.getLocationFromMapPx(pixel); //this.map.getLocationFromLayerPx(pixel);
				var feature:Feature;
				
				//todo change this bad way
               if(drawLayer.geometryType == "org.openscales.geometry::MultiPoint"){
				   var multiPoint:MultiPoint = new MultiPoint();
				   multiPoint.addPoint(lonlat.lon,lonlat.lat);
				   feature = new MultiPointFeature(multiPoint, null, this._style);
				   feature.name = "point." + drawLayer.idPoint.toString();
				   drawLayer.idPoint++;
				   drawLayer.addFeature(feature);
				   //must be after adding map
				   feature.draw();
				   
			   }else{
				var point:Point = new Point(lonlat.lon,lonlat.lat);
				feature = new PointFeature(point, null, this._style);
				feature.name = "point." + drawLayer.idPoint.toString();
				drawLayer.idPoint++;
				drawLayer.addFeature(feature);
				//must be after adding map
				feature.draw();
			   }
			   this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,feature));
			}
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
	}
}

