package org.openscales.core.style.graphic
{
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.stroke.Stroke;

	public class WellKnownGraphic implements Graphic
	{
		// A square
		public static const WKN_SQUARE:String = "square";
		// A circle
		public static const WKN_CIRCLE:String = "circle";
		// A triangle pointing up
		public static const WKN_TRIANGLE:String = "triangle";
		// five-pointed star
		public static const WKN_STAR:String = "star";
		// A square cross with space around (not suitable for hatch fills)
		public static const WKN_CROSS:String = "cross";
		// A square X with space around (not suitable for hatch fills)
		public static const WKN_X:String = "x";
		
		private var _size:Object;
		private var _wellKnownGraphicName:String;
		private var _fill:Fill;
		private var _stroke:Stroke;
		private var _opacity:Number = 1;
		private var _rotation:Number = 0;
		
		public function WellKnownGraphic(wellKnownGraphicName:String=WKN_SQUARE,
										 fill:Fill=null,
										 stroke:Stroke=null,
										 size:Object=6,
										 opacity:Number=1,
										 rotation:Number=0)
		{
			this._wellKnownGraphicName = wellKnownGraphicName;
			this._fill = fill;
			this._stroke = stroke;
			this._opacity = opacity;
			this._size = size;
			this._rotation = rotation;
		}
		
		public function clone():Graphic {
			return new WellKnownGraphic(this._wellKnownGraphicName,
										this._fill.clone(),
										this._stroke.clone(),
										this._size,
										this._opacity,
										this._rotation);
		}
		
		public function get sld():String
		{
			//TODO
			return null;
		}
		
		public function set sld(value:String):void
		{
			//TODO
		}
		
		public function get size():Object
		{
			return _size;
		}
		
		public function set size(value:Object):void
		{
			_size = value;
		}

		public function get wellKnownGraphicName():String
		{
			return _wellKnownGraphicName;
		}

		public function set wellKnownGraphicName(value:String):void
		{
			_wellKnownGraphicName = value;
		}

		public function get fill():Fill
		{
			return _fill;
		}

		public function set fill(value:Fill):void
		{
			_fill = value;
		}

		public function get stroke():Stroke
		{
			return _stroke;
		}

		public function set stroke(value:Stroke):void
		{
			_stroke = value;
		}

		public function get opacity():Number
		{
			return _opacity;
		}

		public function set opacity(value:Number):void
		{
			_opacity = value;
		}

		public function get rotation():Number
		{
			return _rotation;
		}

		public function set rotation(value:Number):void
		{
			_rotation = value;
		}
	}
}