package org.openscales.core.feature
{
	import flash.geom.Matrix;
	
	import org.openscales.core.Trace;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.ArrowSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;

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
			
			// Regardless to the style, a LineString is never filled
			this.graphics.endFill();
			
			// Variable declaration before for loop to improve performances
			var resolution:Number = this.layer.map.resolution 
			var dX:int = -int(this.layer.map.layerContainer.x) + this.left; 
			var dY:int = -int(this.layer.map.layerContainer.y) + this.top;
			var j:uint = (this.lineString.componentsLength*2);
			var coords:Vector.<Number> = this.lineString.getcomponentsClone();
			var commands:Vector.<int> = new Vector.<int>();
			
			if(symbolizer is ArrowSymbolizer){
				
				this.graphics.beginFill(0);
				
				var arrowPos:int = (symbolizer as ArrowSymbolizer).position;
				
				var index:uint = (2*arrowPos) % coords.length;
				
				var x:Number = dX + coords[i] / resolution;
				var y:Number = dY - coords[i+1] / resolution;
				
				var segmentX:Number = coords[i]-coords[(coords.length+i-2)% coords.length];
				var segmentY:Number = coords[(coords.length+i-1)% coords.length]-coords[i+1];
				
				var normalizedX:Number = segmentX/Math.sqrt(Math.pow(segmentX,2)+Math.pow(segmentY,2));
				var normalizedY:Number = segmentY/Math.sqrt(Math.pow(segmentX,2)+Math.pow(segmentY,2));
				
				var transform:Matrix = new Matrix(normalizedX,normalizedY,-normalizedY,normalizedX,x,y);
				
				var tip:flash.geom.Point = transform.transformPoint(new flash.geom.Point(12,0));
				var leftBase:flash.geom.Point = transform.transformPoint(new flash.geom.Point(-4,-8));
				var rightBase:flash.geom.Point = transform.transformPoint(new flash.geom.Point(-4,8));
				
				this.graphics.moveTo(tip.x,tip.y);
				this.graphics.lineTo(leftBase.x,leftBase.y);
				this.graphics.lineTo(rightBase.x,rightBase.y);
				this.graphics.lineTo(tip.x,tip.y);
				
				this.graphics.endFill();
			}
			else{							
				
				for (var i:uint = 0; i < j; i+=2) {
					
					coords[i] = dX + coords[i] / resolution; 
					coords[i+1] = dY - coords[i+1] / resolution;
	                 
					if (i==0) {
						commands.push(1);
					} else {
						commands.push(2); 
					}
				} 
				this.graphics.drawPath(commands, coords);
			}
			
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
			return lineStringFeatureClone;
			
		}		
	}
}

