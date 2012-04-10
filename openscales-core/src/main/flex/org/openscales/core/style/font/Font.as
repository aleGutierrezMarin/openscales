package org.openscales.core.style.font
{
	public class Font
	{
		public static var NORMAL:String = "normal";
		public static var ITALIC:String = "italic";
		public static var BOLD:String = "bold";
		
		private var _family:String = null;
		private var _style:String = Font.NORMAL;
		private var _weight:String = Font.NORMAL;
		private var _size:Number = 10;
		private var _color:Number = 0x000000;
		private var _opacity:Number = 1;
		
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
			this._size = size;
			this._color = color;
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
			return f;
		}
	}
}