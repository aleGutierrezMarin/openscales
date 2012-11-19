package org.openscales.core.style.stroke
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	
	import mx.graphics.Stroke;
	
	import org.openscales.core.style.graphic.Graphic;
	
	/**
	 * Class defining how a stroke is rendered
	 */
	public class Stroke
	{
		private namespace sldns="http://www.opengis.net/sld";
		
		/**
		 * Possible values for the linejoin of the stroke, i.e. how two segments of a line are connected
		 */
		public static const LINEJOIN_MITER:String = "miter";
		public static const LINEJOIN_ROUND:String = "round";
		public static const LINEJOIN_BEVEL:String = "bevel";
		
		/**
		 * Possible values for the linecap of the stroke, i.e. how the ends of the line are displayed
		 */
		public static const LINECAP_BUTT:String = "butt";
		public static const LINECAP_ROUND:String = "round";
		public static const LINECAP_SQUARE:String = "square";
		
		private var _color:uint = 0;
		
		private var _width:Number = 1;
		
		private var _opacity:Number = 1;
		
		private var _linecap:String;
		
		private var _linejoin:String;
		
		private var _dashArray:Array = null;
		private var _dashoffset:uint = 0;
		
		/**
		 * A "Stroke" specifies the appearance of a linear geometry.
		 * The following parameters may be used: color, opacity, width, linejoin, linecap, dasharray, and dashoffset.
		 */
		
		public function Stroke(color:uint = 0x000000, width:Number = 1, opacity:Number = 1, linecap:String = LINECAP_ROUND, linejoin:String = LINEJOIN_ROUND, dashArray:Array = null, dashoffset:uint = 0)
		{
			this._color = color;
			this._width = width;
			this._opacity = opacity;
			this._linecap = linecap;
			this._linejoin = linejoin;
			this._dashArray = dashArray;
			this._dashoffset = dashoffset;
		}
		
		/**
		 * The color of the stroke
		 */
		public function get color():uint{
			
			return this._color;
		}
		
		public function set color(value:uint):void{
			
			this._color = value;
		}
		
		/**
		 * The width of the stroke
		 */
		public function get width():Number{
		
			return this._width;	
		}
		
		public function set width(value:Number):void{
			
			this._width = value;
		}
		
		/**
		 * The height of the stroke
		 */
		public function get opacity():Number{
			
			return this._opacity;
		}
		
		public function set opacity(value:Number):void{
			
			this._opacity = value;
		}
		
		public function get linecap():String{
			
			return this._linecap;
		}
		
		public function set linecap(value:String):void{
			
			this._linecap = value;
		}
		
		public function get linejoin():String{
			
			return this._linejoin;
		}
		
		public function set linejoin(value:String):void{
			
			this._linejoin = value;
		}
		
		/**
		 * The dashArray
		 */
		public function get dashArray():Array{
			
			return this._dashArray;
		}
		public function set dashArray(value:Array):void{
			
			this._dashArray = value;
		}
		
		/**
		 * The dots offeset
		 */
		public function get dashoffset():uint{
			
			return this._dashoffset;
		}
		public function set dashoffset(value:uint):void{
			
			this._dashoffset = value;
		}
		
		public function configureGraphics(graphics:Graphics):void{
			
				var linecap:String;
				var linejoin:String;
				switch (this.linecap) {
					case Stroke.LINECAP_ROUND:
						linecap = CapsStyle.ROUND;
						break;
					case Stroke.LINECAP_SQUARE:
						linecap = CapsStyle.SQUARE;
						break;
					default:
						linecap = CapsStyle.NONE;
				}

				switch (this.linejoin) {
					case Stroke.LINEJOIN_ROUND:
						linejoin = JointStyle.ROUND;
						break;
					case Stroke.LINEJOIN_BEVEL:
						linejoin = JointStyle.BEVEL;
						break;
					default:
						linejoin = JointStyle.MITER;
				}

				graphics.lineStyle(this.width, this.color, this.opacity, false, LineScaleMode.NORMAL, linecap, linejoin);
		}
		
		public function clone():Stroke
		{
			var cloneStroke:Stroke = new Stroke();
			cloneStroke.color = this._color;
			cloneStroke.width = this._width;
			cloneStroke.opacity = this._opacity;
			cloneStroke.linecap = this._linecap;
			cloneStroke.linejoin = this._linejoin;			
			cloneStroke.dashArray = this._dashArray;
			cloneStroke.dashoffset = this._dashoffset;
			return cloneStroke;
		}
		
		public function get sld():String {
			var res:String = "<sld:Stroke>\n";
			if(this.color) {
				var stringColor:String = this.color.toString(16);
				var spareStringColor:String = "";
				for (var i:uint = 0; i < (6 - stringColor.length); i++)
				{
					spareStringColor += "0";
				}
				spareStringColor += stringColor;
				
				if(stringColor.length < 6)
					stringColor = spareStringColor;
				res+="<sld:CssParameter name=\"stroke\">#"+stringColor+"</sld:CssParameter>\n";
			}
			if(this.opacity) {
				res+="<sld:CssParameter name=\"stroke-opacity\">"+this.opacity+"</sld:CssParameter>\n";
			}
			if(this.width) {
				res+="<sld:CssParameter name=\"stroke-width\">"+this.width+"</sld:CssParameter>\n";
			}
			if(this.linecap) {
				res+="<sld:CssParameter name=\"stroke-linecap\">"+this.linecap+"</sld:CssParameter>\n";
			}
			if(this.linejoin) {
				res+="<sld:CssParameter name=\"stroke-linejoin\">"+this.linejoin+"</sld:CssParameter>\n";
			}
			if(this.dashArray && this.dashArray.length>0) {
				res+="<sld:CssParameter name=\"stroke-dasharray\">"+this.dashArray.join(" ")+"</sld:CssParameter>";
				if(this.dashoffset) {
					res+="<sld:CssParameter name=\"stroke-dashoffset\">"+this.dashoffset+"</sld:CssParameter>";
				}
			}
			res+="</sld:Stroke>"
			return res;
		}
		public function set sld(sld:String):void {
			this.color = 0;
			this.opacity = 1;
			this.width = 1;
			this.linecap = LINECAP_ROUND;
			this._linejoin = LINEJOIN_ROUND;
			this._dashArray = null;
			this._dashoffset = 0;
			
			use namespace sldns;
			var dataXML:XML = new XML(sld);
			var childs:XMLList = dataXML.CssParameter;
			
			for each(var node:XML in childs) {
				if(node.@name == "stroke") {
					this._color = parseInt(node[0].toString().replace("#",""),16);
				} else if(node.@name == "stroke-opacity") {
					this._opacity = Number(node[0].toString());
				} else if(node.@name == "stroke-width") {
					this._width = Number(node[0].toString());
				}else if(node.@name == "stroke-linecap") {
					this._linecap = node[0].toString();
				} else if(node.@name == "stroke-linejoin") {
					this._linejoin = node[0].toString();
				} else if(node.@name == "stroke-dasharray") {
					this._dashArray = node[0].toString().split(" ");
				} else if(node.@name == "stroke-dashoffset") {
					this._dashoffset = Number(node[0].toString());
				}
			}
		}
	}
}