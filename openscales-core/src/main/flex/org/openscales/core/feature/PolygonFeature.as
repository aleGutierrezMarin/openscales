package org.openscales.core.feature {
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;

	/**
	 * Feature used to draw a Polygon geometry on FeatureLayer
	 */
	public class PolygonFeature extends Feature {
		public function PolygonFeature(geom:Polygon=null, data:Object=null, style:Style=null, isEditable:Boolean=false) {
			super(geom, data, style, isEditable);
		}

		public function get polygon():Polygon {
			return this.geometry as Polygon;
		}

		override protected function executeDrawing(symbolizer:Symbolizer):void {

			if (symbolizer is PointSymbolizer) {

				this.renderPointSymbolizer(symbolizer as PointSymbolizer);
			} else {
				// Variable declaration before for loop to improve performances
				var p:Point = null;
				var x:Number;
				var y:Number;
				var resolution:Number = this.layer.map.resolution.value;
				var dX:int = -int(this.layer.map.layerContainer.x) + this.left;
				var dY:int = -int(this.layer.map.layerContainer.y) + this.top;
				var linearRing:LinearRing = null;
				var i:int;
				var j:int;
				var k:int = this.polygon.componentsLength;
				var l:int;
				var coords:Vector.<Number>;
				var commands:Vector.<int> = new Vector.<int>();

				for (i = 0; i < k; ++i) {
					linearRing = (this.polygon.componentByIndex(i) as LinearRing);
					l = linearRing.componentsLength*2;
					coords =linearRing.getcomponentsClone();
					commands= new Vector.<int>();
					for (j = 0; j < l; j+=2){
						
						coords[j] = dX + coords[j] / resolution; 
						coords[j+1] = dY - coords[j+1] / resolution;
						
						if (j==0) {
							commands.push(1);
						} else {
							commands.push(2); 
						}
					}
					// Draw the last line of the polygon, as Flash won't render it if there is no fill for the polygon
					if (linearRing.componentsLength > 0) {
						coords.push(coords[0]); 
						coords.push(coords[1]);
						commands.push(2);
					}
					this.graphics.drawPath(commands, coords);
				}
			}
		}

		protected function renderPointSymbolizer(symbolizer:PointSymbolizer):void {

			var x:Number;
			var y:Number;
			var resolution:Number = this.layer.map.resolution.value;
			var dX:int = -int(this.layer.map.layerContainer.x) + this.left;
			var dY:int = -int(this.layer.map.layerContainer.y) + this.top;
			x = dX + this.geometry.bounds.center.x / resolution;
			y = dY - this.geometry.bounds.center.y / resolution;

			if (symbolizer.graphic) {

				this.addChild(symbolizer.graphic.getDisplayObject(this));
			}
		}

		/**
		 * To obtain feature clone
		 * */
		override public function clone():Feature {
			var geometryClone:Geometry = this.geometry.clone();
			var PolygonFeatureClone:PolygonFeature = new PolygonFeature(geometryClone as Polygon, null, this.style, this.isEditable);
			return PolygonFeatureClone;

		}
	}
}

