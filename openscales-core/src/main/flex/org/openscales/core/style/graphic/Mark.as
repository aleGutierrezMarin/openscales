package org.openscales.core.style.graphic
{
	import com.foxaweb.utils.Raster;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.GraphicFill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.stroke.Stroke;

	public class Mark implements IGraphic
	{
		private namespace sldns="http://www.opengis.net/sld";
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
		// An open arrow
		public static const WKN_OARROW:String = "oarrow";
		// A complete arrow
		public static const WKN_CARROW:String = "carrow";
		
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
		
		public function getDisplayObject(feature:Feature, size:Number, isFill:Boolean):DisplayObject {
			if(!this._fill && !this._stroke)
				return null;
			
			if(isFill) {
				if(!this._stroke) {
					return new Shape();
				}
				switch (this._wellKnownGraphicName) {
					case VERTLINE:
					case HORLINE:
					case PLUS:
					case SLASH:
					case BACKSLASH:
					case TIMES: {
						return this.getBitmapData(size);
						break;
					}
				}
			}
			
			var shape:Sprite = new Sprite();
			
			if(isFill) {
				shape.x=size/2;
				shape.y=size/2;
			}
			// Configure fill and stroke for drawing
			if (this._fill) {		
				this._fill.configureGraphics(shape.graphics, feature);
			}
			if (this._stroke) {	
				this._stroke.configureGraphics(shape.graphics);
			}
			
			drawMark(shape, size);
			
			return shape;
		}
		
		public function drawMark(shape:Sprite, size:Number): void {
			switch (this._wellKnownGraphicName) {
				
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
				case WKN_OARROW: {
					shape.graphics.endFill();
					shape.graphics.moveTo(-size/2,-size/2);
					shape.graphics.lineTo(size/2,0);
					shape.graphics.lineTo(-size/2,size/2);
					break;
				}
				case WKN_CARROW: {
					shape.graphics.moveTo(-size/2,-size/2);
					shape.graphics.lineTo(size/2,0);
					shape.graphics.lineTo(-size/2,size/2);
					shape.graphics.lineTo(-size/2,-size/2);
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
					shape.graphics.moveTo(0,-size/2);
					shape.graphics.lineTo(0,size/2);
					shape.graphics.moveTo(-size/2, 0);
					shape.graphics.lineTo(size/2, 0);
					break;
				}
				case SLASH: {
					shape.graphics.moveTo(-size/2,size/2);
					shape.graphics.lineTo(size/2,-size/2);
					break;
				}
				case BACKSLASH: {
					shape.graphics.moveTo(-size/2,-size/2);
					shape.graphics.lineTo(size/2,size/2);
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
				case WKN_SQUARE:
				default: {
					shape.graphics.drawRect(-(size / 2), -(size / 2), size, size);
					break;
				}
			}
			shape.graphics.endFill();
		}
		
		private function getBitmapData(size:Number):Bitmap {
			
			var alpha:int = (this._stroke.opacity*255);
			alpha*=0x1000000;
			var color:Number = this._stroke.color+alpha;
			
			// create bitmapData
			var bitmapData:Raster = new Raster(size,size,true,NaN);
			var middle:int = Math.round(size/2)-1;
			var delta:int = Math.floor((this._stroke.width)/2);
			var i:uint;
			var corner:Boolean = (this._wellKnownGraphicName != TIMES);
			if(this._wellKnownGraphicName==VERTLINE || this._wellKnownGraphicName == PLUS) {
				bitmapData.line(middle,0,middle,size-1,color);
				for(i = delta; i>0 ;--i) {
					bitmapData.line(middle+i,0,middle+i,size-1,color);
					bitmapData.line(middle-i,0,middle-i,size-1,color);
				}
			}
			if(this._wellKnownGraphicName==HORLINE || this._wellKnownGraphicName == PLUS) {
				bitmapData.line(0,middle,size-1,middle,color);
				for(i = delta; i>0 ;--i) {
					bitmapData.line(0,middle+i,size-1,middle+i,color);
					bitmapData.line(0,middle-i,size-1,middle-i,color);
				}
			}
			if(this._wellKnownGraphicName==SLASH || this._wellKnownGraphicName == TIMES) {
				bitmapData.line(0,size-1,size-1,0,color);
				for(i = delta; i>0 ;--i) {
					//main line
					bitmapData.line(0,size-i,size-i,0,color);
					bitmapData.line(i-1,size-1,size-1,i-1,color);
					if(corner) {
						//top left corner
						bitmapData.line(0,i-2,i-2,0,color);
						// bottom right corner
						bitmapData.line(size-i+1,size-1,size-1,size-i+1,color);
					}
				}
			}
			if(this._wellKnownGraphicName==BACKSLASH || this._wellKnownGraphicName == TIMES) {
				bitmapData.line(0,0,size-1,size-1,color);
				if(delta > 0){
					for(i = delta; i>0 ;--i) {
						//main line
						bitmapData.line(0,i-1,size-i,size-1,color);
						bitmapData.line(i-1,0,size-1,size-i,color);
						if(corner) {
							//top rigth corner
							bitmapData.line(size-i+1,0,size-1,i-2,color);
							// bottom left corner
							bitmapData.line(0,size-i+1,i-2,size-1,color);
						}
					}
				}
			}
			return new Bitmap(bitmapData);
		}
		
		public function get sld():String
		{
			//if(!this._wellKnownGraphicName)
				//return "";
			var ret:String="<sld:Mark>\n";
			if(this._wellKnownGraphicName)
				ret+="<sld:WellKnownName>"+this._wellKnownGraphicName+"</sld:WellKnownName>\n";
			if(this._fill)
				ret+=this._fill.sld;
			if(this._stroke)
				ret+=this._stroke.sld;
			ret+="</sld:Mark>\n";
			return ret;
		}
		
		public function set sld(value:String):void
		{
			use namespace sldns;
			var dataXML:XML = new XML(value);
			if(this._stroke)
				this._stroke = null;
			if(this._fill)
				this._fill = null;
			this._wellKnownGraphicName = null;
			if(dataXML.WellKnownName.length()>0)
				this._wellKnownGraphicName = dataXML.WellKnownName[0].toString();
			
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