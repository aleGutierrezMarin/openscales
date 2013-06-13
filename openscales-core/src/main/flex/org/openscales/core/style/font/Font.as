package org.openscales.core.style.font
{
	public class Font
	{
		private namespace sldns="http://www.opengis.net/sld";
		
		public static var NORMAL:String = "normal";
		public static var ITALIC:String = "italic";
		public static var BOLD:String = "bold";
		
		private var _family:String = null;
		private var _style:String = Font.NORMAL;
		private var _weight:String = Font.NORMAL;
		private var _size:Number = 10;
		private var _color:Number = 0x000000;
		private var _opacity:Number = 1;
		
		/*
		 * A "Font" element specifies the text font to use. The allowed CssParameters are: "font-family", "font-style", "font-weight", and "font-size".
		 */
		public function Font(size:Number = 10,
							 color:Number = 0x000000,
							 opacity:Number = 1,
							 family:String = null,
							 style:String= null,
							 weight:String = null)
		{
			if(family)
				this._family = family;
			if(style)
				this._style = style;
			if(weight)
				this._weight = weight;
			if(!isNaN(size))
				this._size = size;
			if(!isNaN(color))
				this._color = color;
			if(!isNaN(opacity))
				this._opacity = opacity;
			
		}

		/**
		 * font-family
		 */
		public function get family():String
		{
			return _family;
		}
		/**
		 * @private
		 */
		public function set family(value:String):void
		{
			_family = value;
		}
		/**
		 * font-style
		 */
		public function get style():String
		{
			return _style;
		}
		/**
		 * @private
		 */
		public function set style(value:String):void
		{
			_style = value;
		}
		/**
		 * font-weight
		 */
		public function get weight():String
		{
			return _weight;
		}
		/**
		 * @private
		 */
		public function set weight(value:String):void
		{
			_weight = value;
		}
		/**
		 * font-size
		 */
		public function get size():Number
		{
			return _size;
		}
		/**
		 * @private
		 */
		public function set size(value:Number):void
		{
			_size = value;
		}
		/**
		 * font-color
		 */
		public function get color():Number
		{
			return _color;
		}
		/**
		 * @private
		 */
		public function set color(value:Number):void
		{
			_color = value;
		}
		/**
		 * text opacity
		 */
		public function get opacity():Number
		{
			return _opacity;
		}
		/**
		 * @private
		 */
		public function set opacity(value:Number):void
		{
			_opacity = value;
		}

		/**
		 * clone
		 */
		public function clone():Font {
			var f:Font = new Font();
			f.color = this._color;
			f.family = this._family;
			f.size = this._size;
			f.style = this._style;
			f.weight = this._weight;
			f.opacity = this.opacity;
			return f;
		}
		
		public function get sld():String {
				var res:String ="<sld:Font>\n";
				res+="<sld:CssParameter name=\"font-family\">"+this.family+"</sld:CssParameter>\n";
				res+="<sld:CssParameter name=\"font-size\">"+this.size+"</sld:CssParameter>\n";
				if(this.weight == Font.BOLD) {
					res+="<sld:CssParameter name=\"font-weight\">bold</sld:CssParameter>\n";
				}
				if(this.style == Font.ITALIC) {
					res+="<sld:CssParameter name=\"font-style\">italic</sld:CssParameter>\n";
				}
				res+="</sld:Font>\n";
				return res;
		}
		
		public function set sld(sld:String):void {
			use namespace sldns;
			_family = null;
			_style = Font.NORMAL;
			_weight = Font.NORMAL;
			_size = 10;
			_color = 0x000000;
			_opacity = 1;
			
			var dataXML:XML = new XML(sld);
			var childs:XMLList = dataXML..*::CssParameter;
			for each(var node:XML in childs) {
				if(node.@name == "font-family") {
					this._family = node[0].toString();
				} else if(node.@name == "font-weight") {
					if(node[0].toString().toLowerCase()=="bold")
						this._weight = Font.BOLD;
				}
				else if(node.@name == "font-style") {
					if(node[0].toString().toLowerCase()=="italic")
						this._style = Font.ITALIC;
				}
				else if(node.@name == "font-size") {
					this._size = node[0].toString();
				}
			}
		}
	}
}