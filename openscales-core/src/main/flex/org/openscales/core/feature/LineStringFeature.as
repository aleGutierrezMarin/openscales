package org.openscales.core.feature
{
	import flash.display.DisplayObject;
	
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.ArrowSymbolizer;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.basetypes.Location;
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

		/**
		 * @inheritdoc
		 */
		override protected function acceptSymbolizer(symbolizer:Symbolizer):Boolean
		{
			if (symbolizer is LineSymbolizer)
				return true;
			else
				return false
		}
		
		/**
		 * @inheritdoc
		 */
		override protected function executeDrawing(symbolizer:Symbolizer):void {
			
			if(!this.layer.map)
				return;
			
			// Regardless to the style, a LineString is never filled
			this.graphics.endFill();
			
			this.x = 0;
			this.y = 0;
			// Variable declaration before for loop to improve performances
			var j:uint = (this.lineString.componentsLength*2);
			var coords:Vector.<Number> = this.lineString.getcomponentsClone();
			var commands:Vector.<int> = new Vector.<int>();
			var arrowSymb:Boolean = false;
			if (symbolizer is ArrowSymbolizer)
			{
				var px1:Pixel;
				var px2:Pixel;
				var alpha:Number;
				var dispObject:DisplayObject;
				if ((symbolizer as ArrowSymbolizer).leftMarker)
				{
					if (coords.length <4)
						return;
					
					px1 = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[0], coords[1], this.projection));
					px2 = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[2], coords[3], this.projection));
					alpha = Math.atan((px1.x - px2.x)/(px1.y - px2.y));
					alpha = -alpha*180/Math.PI +90;
					/*if ((px1.x - px2.x) < 0)
						alpha -= 90;
					else 
						alpha -= 90;*/
					if ((px1.y - px2.y) < 0)
						alpha -= 90;
					else 
						alpha += 90;
					dispObject = (symbolizer as ArrowSymbolizer).leftMarker.getDisplayObject(this);
					dispObject.rotation = alpha;
					dispObject.x = px1.x;
					dispObject.y = px1.y;
					this.addChild(dispObject);
				}
				if ((symbolizer as ArrowSymbolizer).rightMarker)
				{
					if (coords.length <4)
						return;
					
					var coordSize:uint = coords.length;
					px1 = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[coordSize-4], coords[coordSize-3], this.projection));
					px2 = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[coordSize-2], coords[coordSize-1], this.projection));
					alpha = Math.atan((px2.x - px1.x)/(px2.y - px1.y));
					alpha = -alpha*180/Math.PI +90;
					if ((px1.y - px2.y) < 0)
						alpha += 90;
					else 
						alpha -= 90;
					dispObject = (symbolizer as ArrowSymbolizer).leftMarker.getDisplayObject(this);
					dispObject.rotation = alpha;
					dispObject.x = px2.x;
					dispObject.y = px2.y;
					this.addChild(dispObject);
				}
			}
			for (var i:uint = 0; i < j; i+=2) {
				var px:Pixel = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[i], coords[i+1], this.projection));
				coords[i] = px.x; 
				coords[i+1] = px.y;
				
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

