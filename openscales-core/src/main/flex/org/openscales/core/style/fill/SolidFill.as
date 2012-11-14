package org.openscales.core.style.fill {
	import flash.display.Graphics;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.filter.expression.IExpression;

	/**
	 * Class defining a solid fill, which is characterized by its color and opacity
	 */
	public class SolidFill implements Fill {
		
		private namespace sldns="http://www.opengis.net/sld";
		
		private var _color:Object;

		private var _opacity:Number;

		public function SolidFill(color:uint=0xffffff, opacity:Number=1) {
			this.color = color;
			this.opacity = opacity;
		}

		/**
		 * The color of the fill. Color may be either a uint or a IExpression
		 */
		public function get color():Object {

			return this._color;
		}

		public function set color(value:Object):void {

			if (!(value is uint || value is IExpression)) {

				throw ArgumentError("color attribute must be either a uint or a IExpression");
			}

			this._color = value;
		}

		/**
		 * The opacity of the fill
		 */
		public function get opacity():Number {

			return this._opacity;
		}

		public function set opacity(value:Number):void {

			this._opacity = value;
		}
		
		public function get sld():String {
			var res:String = "<sld:Fill>\n";
			if(this.color is uint) {
				var stringColor:String = (this.color as uint).toString(16);
				var spareStringColor:String = "";
				for (var i:uint = 0; i < (6 - stringColor.length); i++)
				{
					spareStringColor += "0";
				}
				spareStringColor += stringColor;
				
				if(stringColor.length < 6)
					stringColor = spareStringColor;
				res+="<sld:CssParameter name=\"fill\">#"+stringColor+"</sld:CssParameter>\n";
			}
			if(this.opacity) {
				res+="<sld:CssParameter name=\"fill-opacity\">"+this.opacity+"</sld:CssParameter>\n";
			}
			res+="</sld:Fill>"
			return res;
		}
		
		public function set sld(sld:String): void {
			use namespace sldns;
			var dataXML:XML = new XML(sld);
			var childs:XMLList = dataXML.CssParameter;
			this.color = 0;
			for each(var node:XML in childs) {
				if(node.@name == "fill") {
					this.color = parseInt(node[0].toString().replace("#",""),16);
				} else if(node.@name == "fill-opacity") {
					this.opacity = Number(node[0].toString());
				}
			}
		}

		public function configureGraphics(graphics:Graphics, feature:Feature):void {

			var color:uint;
			if (this._color is uint) {

				color = this._color as uint;
			} else {

				color = (this._color as IExpression).evaluate(feature) as uint;
			}

			graphics.beginFill(color, this._opacity);
		}

		public function clone():Fill
		{
			var cloneSolidFill:SolidFill = new SolidFill(0xffffff, this._opacity);
			cloneSolidFill.color = this._color;
			return cloneSolidFill;
		}
	}
}