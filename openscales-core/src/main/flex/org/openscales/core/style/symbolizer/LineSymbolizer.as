package org.openscales.core.style.symbolizer {
	import flash.display.Graphics;

	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.stroke.Stroke;

	public class LineSymbolizer extends Symbolizer implements IStrokeSymbolizer {
		private namespace sldns="http://www.opengis.net/sld";
		
		private var _stroke:Stroke;

		public function LineSymbolizer(stroke:Stroke=null) {
			this._stroke = stroke;
		}

		public function get stroke():Stroke {

			return this._stroke;
		}

		public function set stroke(value:Stroke):void {

			this._stroke = value;
		}

		override public function configureGraphics(graphics:Graphics, feature:Feature):void {

			if (this._stroke) {
				this._stroke.configureGraphics(graphics);
			} else {
				graphics.lineStyle();
			}
		}
		
		override public function clone():Symbolizer{
			var lineSymbolizer:LineSymbolizer = new LineSymbolizer(this._stroke.clone());
			lineSymbolizer.geometry = this.geometry;
			return lineSymbolizer;
		}
	}
}