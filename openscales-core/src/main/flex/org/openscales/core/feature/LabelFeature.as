package org.openscales.core.feature
{
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.LabelPoint;
	
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
				value = new Location(this.labelPoint.x, this.labelPoint.y);
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
		 * To get the geometry (the LabelPoint) of the LabelFeature
		 */
		public function get labelPoint():LabelPoint{
			return this.geometry as LabelPoint;
		}
	}
}