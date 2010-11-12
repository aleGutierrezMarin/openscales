package org.openscales.core.handler.feature.draw
{
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * Handler to draw points.
	 */
	public class DrawPointHandler extends AbstractDrawHandler
	{

		/**
		 * The layer in which we'll draw
		 */
		private var _drawLayer:FeatureLayer = null;

		/**
		 * Single ID for point
		 */		
		private var id:Number = 0;

		public function DrawPointHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.FeatureLayer=null)
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
				Trace.log("Drawing point");
			  
				var style:Style = Style.getDefaultPointStyle();
			
				var pixel:Pixel = new Pixel(drawLayer.mouseX ,drawLayer.mouseY);
				var lonlat:Location = this.map.getLocationFromLayerPx(pixel);
				var feature:Feature;
				
				//todo change this bad way
               if(drawLayer.geometryType == "org.openscales.geometry::MultiPoint"){
				   var multiPoint:MultiPoint = new MultiPoint();
				   multiPoint.addPoint(lonlat.lon,lonlat.lat);
				   feature = new MultiPointFeature(multiPoint, null, style);
				   feature.name = id.toString(); id++;
				   drawLayer.addFeature(feature);
				   //must be after adding map
				   feature.draw();
				   
			   }else{
				var point:Point = new Point(lonlat.lon,lonlat.lat);
				feature = new PointFeature(point, null, style);
				feature.name = id.toString();
				id++;
				drawLayer.addFeature(feature);
				//must be after adding map
				feature.draw();
			   }
			   this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,feature));
			}
		}
	}
}

