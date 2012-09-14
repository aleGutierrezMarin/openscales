package org.openscales.core.feature {
	import flash.display.DisplayObject;
	import flash.display.GraphicsPathCommand;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.openscales.core.style.Style;
	import org.openscales.core.style.font.Font;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.style.symbolizer.TextSymbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;

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
		
		/**
		 * @inheritdoc
		 */
		override protected function acceptSymbolizer(symbolizer:Symbolizer):Boolean
		{
			if (symbolizer is PolygonSymbolizer || symbolizer is TextSymbolizer || symbolizer is PointSymbolizer)
				return true;
			else
				return false;
		}

		/**
		 * @inheritdoc
		 */
		override protected function executeDrawing(symbolizer:Symbolizer):void {

			if (symbolizer is PointSymbolizer) {
				this.renderPointSymbolizer(symbolizer as PointSymbolizer);
			} else if (symbolizer is TextSymbolizer) {
				(symbolizer as TextSymbolizer).drawTextField(this);
			} else if(this.layer.map) {
				// Variable declaration before for loop to improve performances
				var p:Point = null;
				var x:Number;
				var y:Number;
				this.x = 0;
				this.y = 0;
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
						var px:Pixel = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[j], coords[j+1], this.projection));
						coords[j] = px.x; 
						coords[j+1] = px.y;
						if (j==0) {
							commands.push(GraphicsPathCommand.MOVE_TO);
						} else {
							commands.push(GraphicsPathCommand.LINE_TO); 
						}
					}
					// Draw the last line of the polygon, as Flash won't render it if there is no fill for the polygon
					if (linearRing.componentsLength > 0) {
						coords.push(coords[0]); 
						coords.push(coords[1]);
						commands.push(GraphicsPathCommand.LINE_TO);
					}
					this.graphics.drawPath(commands, coords);
					
				}
				this.graphics.endFill();
			}
		}

		protected function renderPointSymbolizer(symbolizer:PointSymbolizer):void {

			var x:Number;
			var y:Number;
			var resolution:Number = this.layer.map.resolution.value;
			var dX:int = -int(this.layer.map.x) + this.left;
			var dY:int = -int(this.layer.map.y) + this.top;
			x = dX + this.geometry.bounds.center.x / resolution;
			y = dY - this.geometry.bounds.center.y / resolution;

			if (symbolizer.graphic) {
				var o:DisplayObject = symbolizer.graphic.getDisplayObject(this);
				o.x = x;
				o.y = y;
				this.addChild(o);
			}
		}

		/**
		 * To obtain feature clone
		 * */
		override public function clone():Feature {
			var geometryClone:Geometry = this.geometry.clone();
			var PolygonFeatureClone:PolygonFeature = new PolygonFeature(geometryClone as Polygon, null, this.style, this.isEditable);
			PolygonFeatureClone._originGeometry = this._originGeometry;
			PolygonFeatureClone.layer = this.layer;
			return PolygonFeatureClone;

		}
	}
}

