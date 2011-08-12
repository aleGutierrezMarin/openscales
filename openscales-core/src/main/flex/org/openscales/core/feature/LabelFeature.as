package org.openscales.core.feature
{
	import org.openscales.core.style.Style;
	import org.openscales.geometry.LabelPoint;
	import org.openscales.geometry.basetypes.Location;
	
	public class LabelFeature extends Feature
	{
		/**
		 * Constructor class
		 * 
		 * @param geom
		 * @param data
		 * @param style
		 * @param isEditable
		 */
		public function LabelFeature(geom:LabelPoint=null, data:Object=null, style:Style=null, isEditable:Boolean=false)
		{
			super(geom, data, style, isEditable);
		}
		
		/**
		 * @inherits
		 */
		override public function get lonlat():Location{
			var value:Location = null;
			if(this.labelPoint != null){
				value = new Location(this.labelPoint.x, this.labelPoint.y, this.labelPoint.projSrsCode);
			}
			return value;
		}
		
		/**
		 * @inherits
		 */
		override public function destroy():void{
			super.destroy();
		}
		
		/**
		 * @inherits
		 */
		override public function draw():void{
			var x:Number;
			var y:Number;
			var resolution:Number = this.layer.map.resolution;
			var dX:int = -int(this.layer.map.layerContainer.x) + this.left;
			var dY:int = -int(this.layer.map.layerContainer.y) + this.top;
			x = dX + labelPoint.x / resolution;
			y = dY - labelPoint.y / resolution;
			this.labelPoint.label.x = x - this.labelPoint.label.width / 2;
			this.labelPoint.label.y = y;
			this.addChild(this.labelPoint.label);
		}
		
		/**
		 * To get the geometry (the LabelPoint) of the LabelFeature
		 */
		public function get labelPoint():LabelPoint{
			return this.geometry as LabelPoint;
		}
	}
}