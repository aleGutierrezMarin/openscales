package org.openscales.core.style.graphic
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.stroke.Stroke;

	public class Mark implements IGraphic
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
		
		//Shapes intended to be hatch generators
		// vertline
		public static const VERTLINE:String = "shape://vertline";
		// horline
		public static const HORLINE:String = "shape://horline";
		// plus
		public static const PLUS:String = "shape://plus";
		// slash
		public static const SLASH:String = "shape://slash";
		// backslash
		public static const BACKSLASH:String = "shape://backslash";
		// times
		public static const TIMES:String = "shape://times";
		// dot
		public static const DOT:String = "shape://dot";
		// opened arrow
		public static const OARROW:String = "shape://oarrow";
		// closed arrow
		public static const CARROW:String = "shape://carrow";

		private var _wellKnownGraphicName:String;
		private var _fill:Fill;
		private var _stroke:Stroke;
		
		public function Mark(wellKnownGraphicName:String=WKN_SQUARE,
										 fill:Fill=null,
										 stroke:Stroke=null)
		{
			this._wellKnownGraphicName = wellKnownGraphicName;
			this._fill = fill;
			this._stroke = stroke;
		}
		
		public function clone():IGraphic {
			var ret:Mark = new Mark(this._wellKnownGraphicName);
			ret.fill = this._fill == null ? null:this._fill.clone();
			ret.stroke = this._stroke == null ? null:this._stroke.clone();
			return ret;
		}
		
		public function getDisplayObject(feature:Feature, size:Number):DisplayObject {
			if(!this._fill && !this._stroke)
				return null;
			
			var shape:Shape = new Shape();
			
			// Configure fill and stroke for drawing
			if (this._fill) {		
				this._fill.configureGraphics(shape.graphics, feature);
			}
			if (this._stroke) {	
				this._stroke.configureGraphics(shape.graphics);
			}
			
			switch (this._wellKnownGraphicName) {
				case WKN_SQUARE:  {
					shape.graphics.drawRect(-(size / 2), -(size / 2), size, size);
					break;
				}
				case WKN_CIRCLE:
				case DOT: {
					shape.graphics.drawCircle(0, 0, size / 2);
					break;
				}
				case WKN_TRIANGLE:  {
					shape.graphics.moveTo(0, -(size / 2));
					shape.graphics.lineTo(size / 2, size / 2);
					shape.graphics.lineTo(-size / 2, size / 2);
					shape.graphics.lineTo(0, -(size / 2));
					break;
				}
				case WKN_STAR: {
					var amountCorners:uint = 5;
					var angleOffset:int = 0;
					var angleStep: Number = Math.PI / amountCorners;
					var angle: Number = angleOffset;
					var innerRadius:Number = size/4;
					var outerRadius:Number = size/2;
					for( var i: int = 0; i<amountCorners; ++i, angle += angleStep )
					{
						if( i == 0 )
						{
							shape.graphics.moveTo(
								Math.cos( angle ) * innerRadius,
								Math.sin( angle ) * innerRadius
							);
						}
						else
						{
							shape.graphics.lineTo(
								Math.cos( angle ) * innerRadius,
								Math.sin( angle ) * innerRadius
							);
						}
						angle += angleStep;
						shape.graphics.lineTo(
							Math.cos( angle ) * outerRadius,
							Math.sin( angle ) * outerRadius
						);
					}
					break;
				}
				case WKN_CROSS: {
					shape.graphics.moveTo(1-size/2, 0);
					shape.graphics.lineTo(-1+size/2, 0);
					shape.graphics.moveTo(0, 1-size/2);
					shape.graphics.lineTo(0,-1+size/2);
					break;
				}
				case WKN_X: {
					shape.graphics.moveTo(1-size/2,1-size/2);
					shape.graphics.lineTo(-1+size/2,-1+size/2);
					shape.graphics.moveTo(1-size/2,-1+size/2);
					shape.graphics.lineTo(-1+size/2,1-size/2);
					break;
				}
				case VERTLINE: {
					shape.graphics.moveTo(0,-size/2);
					shape.graphics.lineTo(0,size/2);
					break;
				}
				case HORLINE: {
					shape.graphics.moveTo(-size/2, 0);
					shape.graphics.lineTo(size/2, 0);
					break;
				}
				case PLUS: {
					shape.graphics.moveTo(0,size/2);
					shape.graphics.lineTo(0,size/2);
					shape.graphics.moveTo(-size/2, 0);
					shape.graphics.lineTo(size/2, 0);
					break;
				}
				case SLASH: {
					shape.graphics.moveTo(-size/2,size/2);
					shape.graphics.lineTo(size/2,-size/2);
					//TODO check if angles are OK
					break;
				}
				case BACKSLASH: {
					shape.graphics.moveTo(-size/2,-size/2);
					shape.graphics.lineTo(size/2,size/2);
					//TODO check if angles are OK
					break;
				}
				case TIMES: {
					shape.graphics.moveTo(-size/2,-size/2);
					shape.graphics.lineTo(size/2,size/2);
					shape.graphics.moveTo(-size/2,size/2);
					shape.graphics.lineTo(size/2,-size/2);
					break;
				}
				case OARROW: {
					shape.graphics.endFill();
					shape.graphics.moveTo(-size/2,-size/2);
					shape.graphics.lineTo(size/2,0);
					shape.graphics.lineTo(-size/2,size/2);
					break;
				}
				case CARROW: {
					shape.graphics.moveTo(-size/2,-size/2);
					shape.graphics.lineTo(size/2,0);
					shape.graphics.lineTo(-size/2,size/2);
					shape.graphics.lineTo(-size/2,-size/2);
					break;
				}
				// TODO : Add support for other well known names
			}
			shape.graphics.endFill();
			return shape;
		}
		
		public function get sld():String
		{
			var ret:String="<sld:Mark>\n";
			ret+="<sld:WellKnownName>"+this._wellKnownGraphicName+"</sld:WellKnownName>\n";
			if(this._fill)
				ret+=this._fill.sld;
			if(this._stroke)
				ret+=this._stroke.sld;
			ret+="<sld:Mark>\n";
			return ret;
		}
		
		public function set sld(value:String):void
		{
			//TODO
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
	}
}