package org.openscales.proj4as {
	
	/**
	 * Define a point in Proj4as
	 */
	public class ProjPoint {
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function ProjPoint(x:Number=NaN, y:Number=NaN, z:Number=NaN) {
			this.x=x;
			this.y=y;
			this.z=z;
		}
		
		public function clone():ProjPoint {
			return new ProjPoint(this.x, this.y, this.z);
		}
		
		/**
		 * APIMethod: toString
		 * Return a readable string version of the point
		 *
		 * @return String representation of Proj4js.Point object.
		 */
		public function toString():String {
			return ("x=" + this.x + ",y=" + this.y);
		}
		
		/**
		 * APIMethod: toShortString
		 * Return a short string version of the point.
		 *
		 * @return Shortened String representation of Proj4js.Point object.
		 */
		public function toShortString():String {
			return (this.x + ", " + this.y);
		}
		
		
		
	}
}