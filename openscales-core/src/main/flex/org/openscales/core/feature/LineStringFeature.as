package org.openscales.core.feature
{
	import org.openscales.core.utils.Trace;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * Feature used to draw a LineString geometry on FeatureLayer
	 */
	public class LineStringFeature extends Feature
	{
		public function LineStringFeature(geom:LineString=null, data:Object=null, style:Style=null,isEditable:Boolean=false) 
		{
			super(geom, data, style,isEditable);
		}

		public function get lineString():LineString {
			return this.geometry as LineString;
		}

		override protected function executeDrawing(symbolizer:Symbolizer):void {
			
			if(!this.layer.map)
				return;
			
			// Regardless to the style, a LineString is never filled
			this.graphics.endFill();
			
			// Variable declaration before for loop to improve performances
            var resolution:Number = this.layer.map.resolution.value; 
            var dX:int = -int(this.layer.map.x) + this.left; 
            var dY:int = -int(this.layer.map.y) + this.top;
			var j:uint = (this.lineString.componentsLength*2);
			var coords:Vector.<Number> = this.lineString.getcomponentsClone();
			var commands:Vector.<int> = new Vector.<int>();
			for (var i:uint = 0; i < j; i+=2) {
				
				coords[i] = dX + coords[i] / resolution; 
				coords[i+1] = dY - coords[i+1] / resolution;
                 
				if (i==0) {
					commands.push(1);
				} else {
					commands.push(2); 
				}
			}
			
			var lineSym:LineSymbolizer = (symbolizer as LineSymbolizer);
			if(lineSym != null && lineSym.stroke.pWhiteSize != 0 && lineSym.stroke.pDottedSize != 0)
			{
				var size:uint = coords.length;
				for(var k:uint = 0; k + 2 < size; k = k + 2){
					this.dottedTo(new Pixel(coords[k],coords[k+1]), new Pixel(coords[k+2],coords[k+3]),
						lineSym.stroke.pWhiteSize,lineSym.stroke.pDottedSize);
				}
			}
			else
				this.graphics.drawPath(commands, coords);
			
			this.graphics.endFill();
			
		}
		/**
		 * To obtain feature clone 
		 * */
		override public function clone():Feature{
			var geometryClone:Geometry=this.geometry.clone();
			var style:Style = null;
			if( this.style){
				style  = this.style.clone();
			}
			var lineStringFeatureClone:LineStringFeature=new LineStringFeature(geometryClone as LineString,null,style,this.isEditable);
			lineStringFeatureClone._originGeometry = this._originGeometry;
			lineStringFeatureClone.layer = this.layer;
			return lineStringFeatureClone;
			
		}
		
		
		//test
		public function dottedTo(px1:Pixel, px2:Pixel, pWhiteSize:int, pDottedSize:int):void
		{
			var dx:Number = px2.x - px1.x;
			var dy:Number = px2.y - px1.y;
			var dist:Number = Math.sqrt(Math.pow(dx,2) + Math.pow(dy,2));
			var angle:Number = Math.atan2(dy, dx) * 180 / Math.PI;
			
			var tempPixel:Pixel = new Pixel(px1.x, px1.y);
			this.graphics.moveTo(tempPixel.x, tempPixel.y);
			var cos:Number = Math.cos(angle / 180 * Math.PI);
			var sin:Number = Math.sin(angle / 180 * Math.PI);
			while (dist > 0)
			{
				dist -= pDottedSize;
				if (dist < 0){
					tempPixel.x = px2.x;
					tempPixel.y = px2.y;
				}
				else{
					tempPixel.x = tempPixel.x + (pDottedSize * cos);
					tempPixel.y = tempPixel.y + (pDottedSize * sin);
				}
				this.graphics.lineTo(tempPixel.x, tempPixel.y);
				tempPixel.x = tempPixel.x + (pWhiteSize * cos);
				tempPixel.y = tempPixel.y + (pWhiteSize * sin);
				this.graphics.moveTo(tempPixel.x, tempPixel.y);
				dist -= pWhiteSize;
			}
		}
	}
}

