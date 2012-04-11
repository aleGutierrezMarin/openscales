package org.openscales.core.feature
{
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.style.symbolizer.TextSymbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	public class LabelFeature extends PointFeature
	{
		private var _text:String = "";
		
		/**
		 * Constructor class
		 * 
		 * @param geom
		 * @param data
		 */
		public function LabelFeature(geom:Point=null, data:Object=null)
		{
			super(geom,data,Style.getDefaultLabelStyle());
		}
		
		override protected function acceptSymbolizer(symbolizer:Symbolizer):Boolean
		{
			if (symbolizer is TextSymbolizer)
				return true;
			else
				return false;
		}
		
		public static function createLabelFeature(loc:Location, data:Object=null):LabelFeature {
			var pt:Point = new Point(loc.lon,loc.lat);
			pt.projection = loc.projection;
			return new LabelFeature(pt, data);
		}
		
		override public function clone():Feature
		{
			var geometryClone:Geometry = this.geometry.clone();
			var LabelFeatureClone:LabelFeature = new LabelFeature(this._originGeometry as Point, this.data);
			LabelFeatureClone.style = this.style.clone();
			return LabelFeatureClone;
		}

		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			_text = value;
		}
		
		/**
		 * @inheritdoc
		 */
		override protected function executeDrawing(symbolizer:Symbolizer):void {
			var x:Number;
			var y:Number;
			if(!this.layer || !this.layer.map)
				return;
			var resolution:Number = this.layer.map.resolution.value;
			this.x = 0;
			this.y = 0;
			var px:Pixel = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(this.point.x, this.point.y, this.projection));
			x = px.x;
			y = px.y;
			this.graphics.drawRect(x, y, 5, 5);
			this.graphics.endFill();
			
			if (symbolizer is TextSymbolizer) {
				(symbolizer as TextSymbolizer).drawTextField(this, this._text);
			}
		}

	}
}