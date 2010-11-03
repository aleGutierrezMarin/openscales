package org.openscales.geometry
{

	/**
	 * MultiPolygon is a geometry with multiple Polygon components
	 */
	public class MultiPolygon extends Collection
	{

		public function MultiPolygon(srsCode:String, components:Vector.<Geometry>) {
			super(srsCode, components);
			this.componentTypes = new <String>["org.openscales.geometry::Polygon"];
		}
		
		/**
		 * Component of the specified index, casted to the Polygon type
		 */
// TODO: how to do that in AS3 ?
		/*override public function componentByIndex(i:int):Polygon {
			return (super.componentByIndex(i) as Polygon);
		}*/
		
		public function addPolygon(polygon:Polygon, index:Number=NaN):void {
			this.addComponent(polygon, index);
		}

		public function removePolygon(polygon:Polygon):void {
			this.removeComponent(polygon);
		}

		override public function toShortString():String {
			var s:String = "(";
			for (var i:int=0; i<this.componentsLength; ++i) {
				s = s + this._components[i].toShortString();
			}
			return s + ")";
		}
		/**
		 * Method to convert the multipolygon (x/y) from a projection system to an other.
		 *
		 * @param sourceSrs SRS of the source projection
		 * @param destSrs SRS of the destination projection
		 */
		override protected function reprojectGeometry(sourceSrs:String, destSrs:String):void {
			for (var i:int=0; i<this.componentsLength; ++i) {
				(this._components[i] as Polygon).projSrsCode = destSrs;
			}
		}

		/**
		 * To get this geometry clone
		 * */
		override public function clone():Geometry{
			var MultiPolygonClone:MultiPolygon = new MultiPolygon(this.projSrsCode, null);
			var component:Vector.<Geometry> = this.getcomponentsClone();
			MultiPolygonClone.addComponents(component);
			return MultiPolygonClone;
		}
	}
}

