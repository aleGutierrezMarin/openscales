package org.openscales.core.style.stroke
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	
	/**
	 * Class defining how a stroke is rendered
	 */
	public class Stroke
	{
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
		
		private var _pWhiteSize:uint = 0;
		private var _pDottedSize:uint = 0;
		
		public function Stroke(color:uint = 0x000000, width:Number = 1, opacity:Number = 1, linecap:String = LINECAP_ROUND, linejoin:String = LINEJOIN_ROUND, pWhiteSize:uint = 0, pDottedSize:uint = 0)
		{
			this._color = color;
			this._width = width;
			this._opacity = opacity;
			this._linecap = linecap;
			this._linejoin = linejoin;
			this._pWhiteSize = pWhiteSize;
			this._pDottedSize = pDottedSize;
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
		 * The size of the space between dots
		 */
		public function get pWhiteSize():uint{
			
			return this._pWhiteSize;
		}
		public function set pWhiteSize(value:uint):void{
			
			this._pWhiteSize = value;
		}
		
		/**
		 * The size of the dots
		 */
		public function get pDottedSize():uint{
			
			return this._pDottedSize;
		}
		public function set pDottedSize(value:uint):void{
			
			this._pDottedSize = value;
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
	}
}