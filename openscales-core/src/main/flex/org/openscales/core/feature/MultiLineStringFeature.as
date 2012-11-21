package org.openscales.core.feature
{
	import flash.display.DisplayObject;
	
	import org.openscales.core.style.Style;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.ArrowSymbolizer;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.style.symbolizer.TextSymbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * Feature used to draw a MultiLineString geometry on FeatureLayer
	 */
	public class MultiLineStringFeature extends Feature
	{
		private var _canHaveArrow:Boolean = true;
		
		public function MultiLineStringFeature(geom:MultiLineString=null, data:Object=null, style:Style=null,isEditable:Boolean=false) 
		{
			super(geom, data, style,isEditable);
		}

		public function get lineStrings():MultiLineString {
			return this.geometry as MultiLineString;
		}

		/**
		 * @inheritdoc 
		 */
		override protected function acceptSymbolizer(symbolizer:Symbolizer):Boolean
		{
			if (symbolizer is LineSymbolizer)
				return true;
			else
				return false;
		}
		
		/**
		 * @inheritdoc
		 */
		override protected function executeDrawing(symbolizer:Symbolizer):void {
			
			if(!this.layer.map)
				return;
			
			// Regardless to the style, a MultiLineString is never filled
			this.graphics.endFill();
			
			// Variable declaration before for loop to improve performances
			var p:Point = null;
			var x:Number; 
            var y:Number;
			this.x = 0;
			this.y = 0;
			var lineString:LineString = null;
			var n:uint;
			var i:int;
			var j:int = 0;
			var k:int = this.lineStrings.componentsLength;
			var l:int;
			var coords:Vector.<Number>;
			var commands:Vector.<int> = new Vector.<int>();
			
			for (n = 0; n < k; n++) {
				// Variable declaration before for loop to improve performances
				lineString = (this.lineStrings.componentByIndex(n) as LineString);
				l = lineString.componentsLength*2;
				coords =lineString.getcomponentsClone();
				commands= new Vector.<int>(lineString.componentsLength);
				var arrowSymb:Boolean = false;
				if (symbolizer is ArrowSymbolizer && this._canHaveArrow)
				{
					var px1:Pixel;
					var px2:Pixel;
					var alpha:Number;
					var dispObject:DisplayObject;
					// Draw arrows
					if ((symbolizer as ArrowSymbolizer).leftMarker)
					{
						if (coords.length <4)
							return;
						
						px1 = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[0], coords[1], this.projection));
						px2 = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[2], coords[3], this.projection));
						alpha = Math.atan((px1.x - px2.x)/(px1.y - px2.y));
						alpha = -alpha*180/Math.PI +90;
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
						dispObject = (symbolizer as ArrowSymbolizer).rightMarker.getDisplayObject(this);
						dispObject.rotation = alpha;
						dispObject.x = px2.x;
						dispObject.y = px2.y;
						this.addChild(dispObject);
					}
				} else if (symbolizer is TextSymbolizer) {
					(symbolizer as TextSymbolizer).drawTextField(this);
				}
				for (i = 0; i < l; i+=2) {
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
				if(lineSym != null && lineSym.stroke && lineSym.stroke.dashArray && lineSym.stroke.dashArray.length>0)
				{
					var size:uint = coords.length;
					for(i = 0; i + 2 < size; i = i + 2){
						this.dottedTo(new Pixel(coords[i],coords[i+1]),
							new Pixel(coords[i+2],coords[i+3]),lineSym.stroke);
					}
				}
				else
					this.graphics.drawPath(commands, coords);
				
				this.graphics.endFill();
			}
		}
		
		/**
		 * To obtain feature clone 
		 * */
		override public function clone():Feature{
			var geometryClone:Geometry=this.geometry.clone();
			var MultilineStringFeatureClone:MultiLineStringFeature=new MultiLineStringFeature(geometryClone as MultiLineString,null,this.style,this.isEditable);
			MultilineStringFeatureClone._originGeometry = this._originGeometry;
			MultilineStringFeatureClone.layer = this.layer;
			return MultilineStringFeatureClone;
			
		}			
	}
}

