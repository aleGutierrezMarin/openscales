package org.openscales.geometry
{
	import org.openscales.proj4as.ProjProjection;

	/**
	 * MultiPolygon is a geometry with multiple Polygon components
	 */
	public class MultiPolygon extends Collection
	{

		/**
		 * @param components
		 * @param projection The projection to use for this MultiPolygon, default is EPSG:4326
		 */ 
		public function MultiPolygon(components:Vector.<Geometry> = null, projection:ProjProjection = null) {
			super(components,projection);
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
		 * @param dest the destination projection, can be both a String or a ProjProjection
		 */
		override public function transform(dest:*):void {
			// Update the pojection associated to the geometry
			var source:ProjProjection = this.projection;
			this.projection = dest;
			// Update the geometry
			for (var i:int=0; i<this.componentsLength; ++i) {
				this._components[i].projection = source;
				this._components[i].transform(dest);
			}
		}

		/**
		 * To get this geometry clone
		 * */
		override public function clone():Geometry{
			var MultiPolygonClone:MultiPolygon=new MultiPolygon();
			var component:Vector.<Geometry>=this.getcomponentsClone();
			MultiPolygonClone.projection = this.projection;
			MultiPolygonClone.addComponents(component);
			return MultiPolygonClone;
		}
	}
}

