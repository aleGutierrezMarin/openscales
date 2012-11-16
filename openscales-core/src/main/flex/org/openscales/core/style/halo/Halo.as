package org.openscales.core.style.halo
{
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;

	public class Halo
	{
		private var _color:Number = 0xffffff;
		private var _radius:Number = 2;
		private var _opacity:Number = 1;
		private var _quality:int = BitmapFilterQuality.HIGH;
		
		public function Halo(color:Number = 0xffffff, radius:Number = 2, opacity:Number = 1)
		{
			if(!isNaN(color))
				this._color = color;
			if(!isNaN(radius))
				this._radius = radius;
			if(!isNaN(opacity))
				this._opacity = opacity;
		}
		
		public function clone():Halo {
			var h:Halo = new Halo(this._color,this._radius,this._opacity);
			h.quality = this._quality;
			return h;
		}
		
		public function getFilter():BitmapFilter {
			return new GlowFilter(this._color,this._opacity,this._radius,this._radius,10,this._quality);
		}

		public function get color():Number
		{
			return _color;
		}

		public function set color(value:Number):void
		{
			_color = value;
		}

		public function get radius():Number
		{
			return _radius;
		}

		public function set radius(value:Number):void
		{
			_radius = value;
		}

		public function get opacity():Number
		{
			return _opacity;
		}

		public function set opacity(value:Number):void
		{
			_opacity = value;
		}

		public function get quality():int
		{
			return _quality;
		}

		public function set quality(value:int):void
		{
			_quality = value;
		}


	}
}