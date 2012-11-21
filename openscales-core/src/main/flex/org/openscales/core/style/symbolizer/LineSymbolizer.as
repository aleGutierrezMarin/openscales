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
			var lineSymbolizer:LineSymbolizer;
			if(this._stroke)
				lineSymbolizer = new LineSymbolizer(this._stroke.clone());
			else
				lineSymbolizer = new LineSymbolizer();
			lineSymbolizer.geometry = this.geometry == null ? null : this.geometry.clone();
			return lineSymbolizer;
		}
		
		override public function get sld():String {
			var res:String = "<sld:LineSymbolizer>\n";
			if(this.geometry) {
				res += this.geometry.sld;
			}
			var tmp:String;
			if(this.stroke) {
				tmp = this.stroke.sld;
				if(tmp)
					res+=tmp;
			}
			res+="</sld:LineSymbolizer>\n";
			return res;
		}
		
		override public function set sld(sldRule:String):void {
			use namespace sldns;
			super.sld = sldRule;
			var dataXML:XML = new XML(sldRule);
			if(this._stroke)
				this._stroke = null;
			var childs:XMLList = dataXML.Stroke;
			if(childs[0]) {
				this.stroke = new Stroke();
				this.stroke.sld = childs[0].toString();
			}
		}
	}
}