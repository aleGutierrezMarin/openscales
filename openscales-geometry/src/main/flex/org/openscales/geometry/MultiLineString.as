package org.openscales.geometry
{
	import org.openscales.proj4as.ProjProjection;

	/**
	 * A MultiLineString is a geometry with multiple LineString components.
	 */
	public class MultiLineString extends Collection
	{

		public function MultiLineString(components:Vector.<Geometry> = null) {
			super(components);
			this.componentTypes = new <String>["org.openscales.geometry::LineString"];
		}
		
		/**
		 * Component of the specified index, casted to the Polygon type
		 */
// TODO: how to do that in AS3 ?
		/*override public function componentByIndex(i:int):LineString {
			return (super.componentByIndex(i) as LineString);
		}*/

		/**
		 * AddLineSring permit to add a line in the MultiLineString.
		 * In order to not allow 2 lineString witch start at the same point, we make a test with the last component.
		 */
		public function addLineString(lineString:LineString, index:Number=NaN):void {
			this.addComponent(lineString, index);
		}

		public function removeLineString(lineString:LineString):void {
			this.removeComponent(lineString);
		}

		override public function toShortString():String {
			var s:String = "(";
			for(var i:int=0; i<this.componentsLength; ++i) {
				s = s + this._components[i].toShortString();
			}
			return s + ")";
		}
		/**
		 * Method to convert the multilinestring (x/y) from a projection system to an other.
		 *
		 * @param dest the destination projection, can be both a String or a ProjProjection
		 */
		override public function transform(dest:*):void {
			// Update the pojection associated to the geometry
			var source:ProjProjection = this.projection;
			this.projection = dest;
			// Update the geometry
			if(this.componentsLength > 0){
				for(var i:int=0; i<this.componentsLength; ++i) {
					(this._components[i] as LineString).projection = source;
					(this._components[i] as LineString).transform(dest);
				}
			}
		}
		/**
		 * To get this geometry clone
		 * */
		override public function clone():Geometry{
			var MultiLineStringClone:MultiLineString=new MultiLineString();
			var component:Vector.<Geometry>=this.getcomponentsClone();
			MultiLineStringClone.projection = this.projection;
			MultiLineStringClone.addComponents(component);
			return MultiLineStringClone;
		}
	}
}

