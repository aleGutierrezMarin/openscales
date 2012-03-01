package org.openscales.core.feature {
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * Feature used to draw a Point geometry on FeatureLayer
	 */
	public class PointFeature extends Feature {

		/**
		 * the geometry of the parent when the feature is an edition feature
		 **/
		private var _editionFeatureParentGeometry:ICollection = null;


		public function PointFeature(geom:Point=null, data:Object=null, style:Style=null ) {
			//The point is none editable
			super(geom, data, style, false);
		}

		public static function createPointFeature(loc:Location, data:Object=null, style:Style=null ):PointFeature {
			var pt:Point = new Point(loc.lon,loc.lat);
			pt.projection = loc.projection;
			return new PointFeature(pt, data, style);
		}
		
		override public function get lonlat():Location {
			var value:Location = null;
			if (this.point != null) {
				value = new Location(this.point.x, this.point.y, this.point.projection);
			}
			return value;
		}

		override public function destroy():void {
			this._editionFeatureParentGeometry = null;
			super.destroy();
		}
		
		/*override public function onMouseHover(pevt:MouseEvent):void {
			super.onMouseHover(pevt);
			
			//Define Hover Style
			this.style = Style.getDefaultSelectedPointStyle();
			this.draw();
			
		}*/
		
		/*override public function onMouseOut(pevt:MouseEvent):void {
			this.style = Style.getDefaultPointStyle();
			super.onMouseOut(pevt);
			this.draw();
		}*/
		
		public function get point():Point {
			return this.geometry as Point;
		}

		override public function draw():void {
			var i:int = this.numChildren;
			for (i; i > 0; i--) {
				this.removeChildAt(0);
			}
			super.draw();
		}

		override protected function executeDrawing(symbolizer:Symbolizer):void {
			var x:Number;
			var y:Number;
			if(!this.layer || !this.layer.map)
				return;
			var resolution:Number = this.layer.map.resolution.value;
			var dX:int = -int(this.layer.map.x) + this.left;
			var dY:int = -int(this.layer.map.y) + this.top;
			x = dX + point.x / resolution;
			y = dY - point.y / resolution;
			this.graphics.drawRect(x, y, 5, 5);
			this.graphics.endFill();

			if (symbolizer is PointSymbolizer) {
				var pointSymbolizer:PointSymbolizer = (symbolizer as PointSymbolizer);
				if (pointSymbolizer.graphic) {
					var render:DisplayObject = pointSymbolizer.graphic.getDisplayObject(this);
					render.x += x;
					render.y += y;
					this.addChild(render);
				}
			}
		}

		/**
		 * To obtain feature clone
		 * */
		override public function clone():Feature {
			var geometryClone:Geometry = this.geometry.clone();
			var PointFeatureClone:PointFeature = new PointFeature(geometryClone as Point, null, this.style);
			PointFeatureClone._originGeometry = this._originGeometry;
			PointFeatureClone.layer = this.layer;
			return PointFeatureClone;
		}


		/**
		 * To know the segment of the Collection the edition point belongs to
		 * @param point:geometry point to test
		 * @param detectionTolerance:Number
		 * @return the segment number
		 * */
		public function getSegmentsIntersection(collection:ICollection, detectionTolerance:Number=8):int {

			var arrayResult:Array = new Array();
			var LineString1:LineString = null;
			var intersect:Boolean = false;
			var distanceArray:Array = new Array();
			var i:int;
			var j:int;

			if (collection != null) {
				j = collection.componentsLength - 1;
				for (i = 0; i < j; ++i) {
					var point1:Point = collection.componentByIndex(i) as Point;
					var point2:Point = collection.componentByIndex(i + 1) as Point;

					if (point1 != null && point2 != null) {
						var top:Number = Math.max(point1.y, point2.y);
						var right:Number = Math.max(point1.x, point2.x);
						var bottom:Number = Math.min(point1.y, point2.y);
						var left:Number = Math.min(point1.x, point2.x);
						if (point.y <= top && point.y >= bottom && point.x >= left && point.x <= right) {
							intersect = true;
						}
						if (intersect)
							arrayResult.push(new Array(new LineString(new <Number>[point1.x,point1.y, point2.x,point2.y]), i + 1));

					}
					intersect = false;
				}
			
			//The last segment
			point1 = collection.componentByIndex(0) as Point;
			point2 = collection.componentByIndex(collection.componentsLength - 1) as Point;
			if (point1.x != point2.x || point1.y != point2.y) {
				if (point1 != null && point2 != null) {
					top = Math.max(point1.y, point2.y);
					right = Math.max(point1.x, point2.x);
					bottom = Math.min(point1.y, point2.y);
					left = Math.min(point1.x, point2.x);
					if (point.y <= top && point.y >= bottom && point.x >= left && point.x <= right) {
						intersect = true;
					}
					if (intersect)
						arrayResult.push(new Array(new LineString(new <Number>[point1.x,point1.y, point2.x,point2.y]), collection.componentsLength));

				}
			}
			distanceArray = new Array();
			j = arrayResult.length;
			for (i = 0; i < j; i++) {
				//Scalar product to find the closest point with tolerance
				var pointA:Point = (arrayResult[i][0] as LineString).componentByIndex(0) as Point;
				var pointB:Point = (arrayResult[i][0] as LineString).componentByIndex(1) as Point;

				var pointPx:Pixel = this.layer.map.getMapPxFromLocation(new Location(point.x, point.y));

				var pointPxA:Pixel = this.layer.map.getMapPxFromLocation(new Location(pointA.x, pointA.y));

				var pointPxB:Pixel = this.layer.map.getMapPxFromLocation(new Location(pointB.x, pointB.y));

				//pointPx = this.layer.map.getMapPxFromLayerPx(pointPx);
				//pointPxA = this.layer.map.getMapPxFromLayerPx(pointPxA);
				//pointPxB = this.layer.map.getMapPxFromLayerPx(pointPxB);



				var scalarPointAPointBPower:Number = Math.pow((pointPxA.x - pointPxB.x), 2) + Math.pow((pointPxA.y - pointPxB.y), 2);

				var scalarPointPointAPower:Number = Math.pow((pointPx.x - pointPxA.x), 2) + Math.pow((pointPxA.y - pointPx.y), 2);

				var scalarAHAB:Number = Math.pow((pointPx.x - pointPxA.x) * (pointPxB.x - pointPxA.x) + (pointPx.y - pointPxA.y) * (pointPxB.y - pointPxA.y), 2);

				var scalarPointPointBPower:Number = Math.pow((pointPx.x - pointPxB.x), 2) + Math.pow((pointPxB.y - pointPx.y), 2);

				var distance:Number = Math.pow((scalarPointPointAPower - scalarAHAB / scalarPointAPointBPower), 1 / 2);

				if (distance < detectionTolerance) {
					distanceArray.push(new Array(distance, arrayResult[i][1]));
				}
			}
			if (distanceArray.length > 1) {
				distanceArray.sort(sortOnValue);
				return distanceArray[0][1];
			} else if (distanceArray.length == 1)
				return distanceArray[0][1];
			}
			return -1;
		}
		private  function sortOnValue(a:Number,b:Number):Number{
			if(a>b) return 1;
			else if(a<b) return -1;
			else return 0;
		}
	}
}

