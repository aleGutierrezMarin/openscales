package org.openscales.core.feature {
	import flash.display.DisplayObject;
	
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * Feature used to draw a MultiPoint geometry on FeatureLayer
	 */
	public class MultiPointFeature extends Feature {
		public function MultiPointFeature(geom:MultiPoint=null, data:Object=null, style:Style=null, isEditable:Boolean=false) {
			super(geom, data, style, isEditable);
		}

		public function get points():MultiPoint {
			return this.geometry as MultiPoint;
		}

		/**
		 * @inheritdoc
		 */
		override protected function acceptSymbolizer(symbolizer:Symbolizer):Boolean
		{
			if (symbolizer is PointSymbolizer)
				return true;
			else
				return false;
		}
		
		/**
		 * @inheritdoc
		 */
		override protected function executeDrawing(symbolizer:Symbolizer):void {
			
			// Variable declaration before for loop to improve performances
			var p:Point = null;
			var x:Number; 
			var y:Number;
			this.x = 0;
			this.y = 0;
			var point:Point = null;
			var i:int;
			var j:int = this.points.componentsLength;
			for(i=0;i<j;++i){
			
				point = this.points.componentByIndex(i) as Point;
				
				if (symbolizer is PointSymbolizer) {
					var px:Pixel = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(point.x, point.y, this.projection));
					x = px.x;
					y = px.y;
					this.graphics.drawRect(x, y, 5, 5);
					this.graphics.endFill();
					
					var pointSymbolizer:PointSymbolizer = (symbolizer as PointSymbolizer);
					if (pointSymbolizer.graphic) {
	
						var render:DisplayObject = pointSymbolizer.graphic.getDisplayObject(this);
						render.x += x;
						render.y += y;
	
						this.addChild(render);
					}
				}
			}

		}

		/**
		 * To obtain feature clone
		 * */
		override public function clone():Feature {
			var geometryClone:Geometry = this.geometry.clone();
			var MultiPointFeatureClone:MultiPointFeature = new MultiPointFeature(geometryClone as MultiPoint, null, this.style, this.isEditable);
			MultiPointFeatureClone._originGeometry = this._originGeometry;
			MultiPointFeatureClone.layer = this.layer;
			return MultiPointFeatureClone;

		}
	}
}

