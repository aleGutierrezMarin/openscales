package org.openscales.core.style.fill
{
	import com.foxaweb.utils.Raster;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	import org.openscales.core.feature.Feature;
	
	public class HatchingFill implements Fill
	{
		
		public static const VERTLINE:String = "shape://vertline";
		public static const HORLINE:String = "shape://horline";
		public static const PLUS:String = "shape://plus";
		public static const SLASH:String = "shape://slash";
		public static const BACKSLASH:String = "shape://backslash";
		public static const TIMES:String = "shape://times";
		
		private var _type:String = SLASH;

		private var _size:uint = 11;
		
		private var _color:uint = 0x000000;
		
		private var _opacity:Number = 1;
		
		private var _width:uint = 1;
		
		private var _smooth:Boolean = false;
		
		private var _bitmapData:Raster = null;
		
		
		
		public function HatchingFill()
		{
		}
		
		public function configureGraphics(graphics:Graphics, feature:Feature):void
		{
			graphics.beginBitmapFill(this.bitmapData, null, true, this._smooth);
		}
		
		public function clone():Fill
		{
			var fill:HatchingFill = new HatchingFill();
			fill.color = _color;
			fill.opacity = _opacity;
			fill.size = _size;
			fill.smooth = _smooth;
			fill.type = type;
			fill.width = width;
			return fill;
		}
		
		private function get bitmapData():Raster {
			if(!this._bitmapData) {
				var alpha:int = (opacity*255);
				alpha*=0x1000000;
				var color:Number = this._color+alpha;
			
				// create bitmapData
				this._bitmapData = new Raster(size,size,true,NaN);
				var middle:int = Math.round(this._size/2)-1;
				var delta:int = Math.floor((this._width-1)/2);
				var i:uint;
				var corner:Boolean = (this._type != TIMES);
				if(this._type==VERTLINE || this._type == PLUS) {
					this._bitmapData.line(middle,0,middle,this._size-1,color);
					for(i = delta; i>0 ;--i) {
						this._bitmapData.line(middle+i,0,middle+i,this._size-1,color);
						this._bitmapData.line(middle-i,0,middle-i,this._size-1,color);
					}
				}
				if(this._type==HORLINE || this._type == PLUS) {
					this._bitmapData.line(0,middle,this._size-1,middle,color);
					for(i = delta; i>0 ;--i) {
						this._bitmapData.line(0,middle+i,this._size-1,middle+i,color);
						this._bitmapData.line(0,middle-i,this._size-1,middle-i,color);
					}
				}
				if(this._type==SLASH || this._type == TIMES) {
					this._bitmapData.line(0,this._size-1,this._size-1,0,color);
					for(i = delta; i>0 ;--i) {
						//main line
						this._bitmapData.line(0,this._size-i,this._size-i,0,color);
						this._bitmapData.line(i-1,this._size-1,this._size-1,i-1,color);
						if(corner) {
							//top left corner
							this._bitmapData.line(0,i-2,i-2,0,color);
							// bottom right corner
							this._bitmapData.line(this._size-i+1,this._size-1,this._size-1,this._size-i+1,color);
						}
					}
				}
				if(this._type==BACKSLASH || this._type == TIMES) {
					this._bitmapData.line(0,0,this._size-1,this._size-1,color);
					for(i = delta; i>0 ;--i) {
						//main line
						this._bitmapData.line(0,i-1,this._size-i,this._size-1,color);
						this._bitmapData.line(i-1,0,this._size-1,this._size-i,color);
						if(corner) {
							//top rigth corner
							this._bitmapData.line(this._size-i+1,0,this._size-1,i-2,color);
							// bottom left corner
							this._bitmapData.line(0,this._size-i+1,i-2,this._size-1,color);
						}
					}
				}
			}
			return this._bitmapData;
		}
		
		
		public function get sld():String
		{
			var sld:String = "<sld:Fill>\n<sld:GraphicFill>\n<sld:Graphic>\n";
			sld+= "<sld:Mark>\n";
			sld+= "<sld:WellKnownName>"+this._type+"</sld:WellKnownName>\n";
			sld+= "<sld:Stroke>\n";
			var stringColor:String = this._color.toString(16);
			var spareStringColor:String = "";
			for (var i:uint = 0; i < (6 - stringColor.length); i++)
			{
				spareStringColor += "0";
			}
			spareStringColor += stringColor;
			
			if(stringColor.length < 6)
				stringColor = spareStringColor;
			sld+= "<sld:CssParameter name=\"stroke\">#"+stringColor+"</sld:CssParameter>\n";
			sld+= "<sld:CssParameter name=\"stroke-opacity\">"+this._opacity+"</sld:CssParameter>\n";
			sld+= "<sld:CssParameter name=\"stroke-width\">"+this._width+"</sld:CssParameter>\n";
			sld+= "</sld:Stroke>\n";
			sld+= "</sld:Mark>\n";
			sld+= "<sld:Size>"+this._size+"</sld:Size>\n";
			sld+= "</sld:Graphic>\n</sld:GraphicFill>\n</sld:Fill>";
			return sld;
		}
		
		public function set sld(sld:String):void
		{
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
			_bitmapData = null;
		}
		
		public function get size():uint
		{
			return _size;
		}
		
		public function set size(value:uint):void
		{
			_size = value;
			_bitmapData = null;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			_color = value;
			_bitmapData = null;
		}
		
		/**
		 * The width of the stroke
		 */
		public function get width():Number{
			
			return this._width;
		}
		
		public function set width(value:Number):void{
			
			this._width = value;
			_bitmapData = null;
		}
		
		/**
		 * The height of the stroke
		 */
		public function get opacity():Number{
			
			return this._opacity;
		}
		
		public function set opacity(value:Number):void{
			
			this._opacity = value;
			_bitmapData = null;
		}
		
		/**
		 * Whether the bitmap should be smoothed
		 */
		public function get smooth():Boolean {
			
			return this._smooth;
		}
		
		public function set smooth(value:Boolean):void {
			
			this._smooth = value;
		}
	}
}