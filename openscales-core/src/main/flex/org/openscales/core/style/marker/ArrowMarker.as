package org.openscales.core.style.marker
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.stroke.Stroke;

	public class ArrowMarker extends Marker
	{
		public static const AM_TRIANGLE:String = "triangle";
		
		public static const AM_NARROW_TRIANGLE:String = "narrow_triangle"
		
		public static const AM_THIN:String = "thin";
		
		public static const AM_NARROW_THIN:String = "narrow_thin"
		
		private var _am:String;
		
		private var _fill:SolidFill;
		
		private var _stroke:Stroke;
		
		public function ArrowMarker(arrowMarker:String=AM_TRIANGLE, fill:SolidFill=null, stroke:Stroke=null, size:Object=6, opacity:Number=1, rotation:Number=0)
		{
			super(size, opacity, rotation);
			this._am = arrowMarker;
			this._fill = fill ? fill : new SolidFill(0x888888);
			this._stroke = stroke ? stroke : new Stroke(0x000000);
		}
		
		override public function getDisplayObject(feature:Feature):DisplayObject {
			
			var result:DisplayObject = this.generateGraphic(feature);
			
			result.alpha = this.opacity;
			result.rotation = this.rotation;
			
			return result;
		}
		
		override protected function generateGraphic(feature:Feature):DisplayObject {
			
			var shape:Shape = new Shape();
			
			var size:Number = this.getSizeValue(feature);
			
			// Configure fill and stroke for drawing
			if (this._fill) {
				
				this._fill.configureGraphics(shape.graphics, feature);
			}
			if (this._stroke) {
				
				this._stroke.configureGraphics(shape.graphics);
			}
			
			switch (this.arrowMarker) {
				
				case ArrowMarker.AM_TRIANGLE: {
					shape.graphics.moveTo(-size/2, size);
					shape.graphics.lineTo(0, 0);
					shape.graphics.lineTo(size/2, size);
					shape.graphics.lineTo(-size/2, size);
					break;
				}
					
				case ArrowMarker.AM_NARROW_TRIANGLE: {
					shape.graphics.moveTo(-size/3, size);
					shape.graphics.lineTo(0, 0);
					shape.graphics.lineTo(size/3, size);
					shape.graphics.lineTo(-size/3, size);
					break;
				}
				case ArrowMarker.AM_THIN: {
					shape.graphics.endFill();
					shape.graphics.moveTo(-size/2, size);
					shape.graphics.lineTo(0, 0);
					shape.graphics.lineTo(size/2, size);

					break;
				}
				case ArrowMarker.AM_NARROW_THIN: {
					shape.graphics.endFill();
					shape.graphics.moveTo(-size/3, size);
					shape.graphics.lineTo(0, 0);
					shape.graphics.lineTo(size/3, size);
					
					break;
				}
					// TODO : Add support for other arrows
			}
			shape.graphics.endFill();
			return shape;
		}
		
		public function get fill():SolidFill {
			return this._fill;
		}
		
		public function set fill(value:SolidFill):void {
			this._fill = value;
		}
		
		
		public function get stroke():Stroke {
			return this._stroke;
		}
		
		public function set stroke(value:Stroke):void {
			this._stroke = value;
		}
		
		public function get arrowMarker():String{
			return this._am;
		}
		
		public function set arrowMarker(value:String):void
		{
			this._am = value;
		}
		
		override public function clone():Marker
		{
			var fillClone:SolidFill = this.fill.clone() as SolidFill;
			var strokeClone:Stroke = this.stroke.clone();
			var newAm:ArrowMarker = new ArrowMarker(this._am, fillClone, strokeClone, size, opacity, rotation);
			return newAm;
		}
	}
}