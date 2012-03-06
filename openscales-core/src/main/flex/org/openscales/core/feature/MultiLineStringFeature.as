package org.openscales.core.feature
{
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.Symbolizer;
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
		public function MultiLineStringFeature(geom:MultiLineString=null, data:Object=null, style:Style=null,isEditable:Boolean=false) 
		{
			super(geom, data, style,isEditable);
		}

		public function get lineStrings():MultiLineString {
			return this.geometry as MultiLineString;
		}

		override protected function executeDrawing(symbolizer:Symbolizer):void {
			// Regardless to the style, a MultiLineString is never filled
			this.graphics.endFill();
			
			// Variable declaration before for loop to improve performances
			var p:Point = null;
			var x:Number; 
            var y:Number;
			this.x = 0;
			this.y = 0;
			var lineString:LineString = null;
			var i:int;
			var j:int = 0;
			var k:int = this.lineStrings.componentsLength;
			var l:int;
			var coords:Vector.<Number>;
			var commands:Vector.<int> = new Vector.<int>();
			
			for (i = 0; i < k; i++) {
				lineString = (this.lineStrings.componentByIndex(i) as LineString);
				l = lineString.componentsLength*2;
				coords =lineString.getcomponentsClone();
				commands= new Vector.<int>(lineString.componentsLength);
				for (j = 0; j < l; j+=2){
					var px:Pixel = this.layer.getLayerPxForLastReloadedStateFromLocation(new Location(coords[j], coords[j+1], this.projection));
					coords[j] = px.x; 
					coords[j+1] = px.y;
					if (j==0) {
						commands.push(1);
					} else {
						commands.push(2); 
					}
				}
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

