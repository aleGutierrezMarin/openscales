package org.openscales.core.handler.feature.draw
{
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	public class DrawSegmentHandler extends DrawPathHandler
	{
		public function DrawSegmentHandler(map:Map=null, active:Boolean=false, drawLayer:VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
		
		override protected function drawLine(event:MouseEvent=null):void{
			
			drawLayer.scaleX=1;
			drawLayer.scaleY=1;
			//we determine the point where the user clicked
			//var pixel:Pixel = new Pixel(drawLayer.mouseX,drawLayer.mouseY );
			var pixel:Pixel = new Pixel(this.map.mouseX,this.map.mouseY );
			var lonlat:Location = this.map.getLocationFromMapPx(pixel); //this.map.getLocationFromLayerPx(pixel);
			//manage the case where the layer projection is different from the map projection
			var point:Point = new Point(lonlat.lon,lonlat.lat);
			//initialize the temporary line
			super.startPoint = this.map.getMapPxFromLocation(lonlat);
			//trace("draw line : " + _startPoint.x + " " + _startPoint.y);
			
			//The user click for the first time
			if(newFeature){
				super.lineString = new LineString(new <Number>[point.x,point.y]);
				lastPoint = point;
				//the current drawn linestringfeature
				super.currentLineStringFeature= new LineStringFeature(super.lineString,null, Style.getDrawLineStyle(),true);
				super.currentLineStringFeature.name="path." + id.toString(); ++id;
				drawLayer.addFeature(super.currentLineStringFeature);
				
				newFeature = false;
				//draw the temporary line, update each time the mouse moves		
				this.map.addEventListener(MouseEvent.MOUSE_MOVE,temporaryLine);	
			}
			else {								
				if(!point.equals(lastPoint)){
					super.lineString.addPoint(point.x,point.y);
					drawLayer.redraw();
					lastPoint = point;
					this.drawFinalPath();
				}								
			}
		}
		
	}
}