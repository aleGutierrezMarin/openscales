package org.openscales.core.style.symbolizer {
	import flash.display.Graphics;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.GraphicFill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.graphic.ExternalGraphic;
	import org.openscales.core.style.stroke.Stroke;

	/**
	 * A "PolygonSymbolizer" specifies the rendering of a polygon or area geometry, including its interior fill and border stroke.
	 */
	public class PolygonSymbolizer extends Symbolizer implements IFillSymbolizer, IStrokeSymbolizer {
		
		private namespace sldns="http://www.opengis.net/sld";
		
		private var _stroke:Stroke;

		private var _fill:Fill;

		public function PolygonSymbolizer(fill:Fill=null, stroke:Stroke=null) {
			this._fill = fill;
			this._stroke = stroke;
		}

		/**
		 * Defines how the polygon lines are rendered
		 */
		public function get stroke():Stroke {

			return this._stroke;
		}

		public function set stroke(value:Stroke):void {

			this._stroke = value;
		}

		/**
		 * Describes how the polygon fill is rendered
		 */
		public function get fill():Fill {

			return this._fill;
		}

		public function set fill(value:Fill):void {

			this._fill = value;
		}

		override public function configureGraphics(graphics:Graphics, feature:Feature):void {

			if (this._fill) {

				this._fill.configureGraphics(graphics, null);
			} else {

				graphics.endFill();
			}

			if (this._stroke) {

				this._stroke.configureGraphics(graphics);
			} else {

				graphics.lineStyle();
			}
         }
		
		override public function clone():Symbolizer{
			var clonePolygonSymbolizer:PolygonSymbolizer = new PolygonSymbolizer();
			clonePolygonSymbolizer.fill = this._fill == null ? null : this._fill.clone();
			clonePolygonSymbolizer.stroke = this._stroke == null ? null : this._stroke.clone();
			clonePolygonSymbolizer.geometry = this.geometry == null ? null : this.geometry.clone();
			return clonePolygonSymbolizer;
		}
		
		override public function get sld():String {
			var res:String = "<sld:PolygonSymbolizer>\n";
			if(this.geometry) {
				res += this.geometry.sld;
			}
			var tmp:String;
			if(this.fill) {
				tmp = this.fill.sld;
				if(tmp)
					res+=tmp+"\n";
			}
			if(this.stroke) {
				tmp = this.stroke.sld;
				if(tmp)
					res+=tmp+"\n";
			}
			res+="</sld:PolygonSymbolizer>\n";
			return res;
		}
		
		override public function set sld(sldRule:String):void {
			use namespace sldns;
			super.sld = sldRule;
			var dataXML:XML = new XML(sldRule);
			if(this._stroke)
				this._stroke = null;
			if(this._fill)
				this._fill = null;
			var childs:XMLList = dataXML.Fill;
			if(childs[0]) {
				// external ressource
				if(childs[0].GraphicFill.length()>0) {
					this.fill = new GraphicFill();
				} else { // solidfill
					this.fill = new SolidFill();
				}
				this.fill.sld = childs[0].toString();
			}
			childs = dataXML.Stroke;
			if(childs[0]) {
				this.stroke = new Stroke();
				this.stroke.sld = childs[0].toString();
			}
		}
	}
}