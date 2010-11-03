package org.openscales.geometry.basetypes
{
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.Point;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * This class represents a location defined by:
	 * an x coordinate
	 * an y coordinate
	 * a projection defined by its SRS code
	 * 
	 * @author slopez
	 */
	public class Location
	{
		private var _projection:ProjProjection = null;
		private var _x:Number;
		private var _y:Number;
		
		/**
		 * Constructor
		 * @param x:Number the X coordinate of the location
		 * @param y:Number the Y coordinate of the location
		 * @param srsCode:String the SRS code defining the projection of the coordinates, initialized to Geometry.DEFAULT_SRS_CODE if null
		 */
		public function Location(srsCode:String, x:Number, y:Number)
		{
			this._projection = ProjProjection.getProjProjection((srsCode==null) ? Geometry.DEFAULT_SRS_CODE : srsCode);
			this._x = x;
			this._y = y;
		}
		
		/**
		 * Clone the current location
		 * 
		 * @return IProjectable a clone of the current location
		 */
		public function clone():Location {
			return new Location(this.projSrsCode, this.x, this.y);
		}
		
		/**
		 * getter for x coordinate of the Location
		 * 
		 * @return Number the x coordinate
		 */
		public function get x():Number {
			return this._x;
		}
		
		/**
		 * getter for Y coordinate of the Location
		 * 
		 * @return Number the y coordinate
		 */
		public function get y():Number {
			return this._y;
		}
		
		/**
		 * getter for the projection's SRS code of the Location
		 * 
		 * @return String the SRS code defining projection of the Location
		 */
		public function get projSrsCode():String {
			return (this._projection==null) ? null : this._projection.srsCode;
		}
		
		/**
		 * getter for lon coordinate of the Location
		 * 
		 * @return Number the lon coordinate
		 */
		public function get lon():Number {
			return this._x;
		}
		
		/**
		 * getter for lat coordinate of the Location
		 * 
		 * @return Number the lat coordinate
		 */
		public function get lat():Number {
			return this._y;
		}
		
		/**
		 * Reproject the current location in another projection
		 * @param newSrsCode:String SRS code of the target projection
		 * @return Location the equivalent Location of this location in the new projection
		 */
		public function reprojectTo(newSrsCode:String):Location {
			if (newSrsCode == this.projSrsCode) {
				return this;
			}
			var p:ProjPoint = new ProjPoint(this.x, this.y);
			Proj4as.transform(this.projSrsCode, newSrsCode, p);
			return new Location(newSrsCode, p.x, p.y);
		}
		
		/**
		 * give the equivalent string of the current location
		 * 
		 * @return String the current location
		 */
		public function toString():String {
			return "lon=" + this._x + ",lat=" + this._y;
		}
		
		/**
		 * give the equivalent short string of the current location
		 * 
		 * @return String the current location
		 */
		public function toShortString():String {
			return this._x + ", " + this._y;
		}
		
		/**
		 * add delta derivation to the current Location
		 * 
		 * @param x:Number the X derivation
		 * @param y:Number the Y derivation
		 * 
		 * @return Location the new Location
		 */
		public function add(x:Number, y:Number):Location {
			return new Location(this.projSrsCode, this.x + x, this.y + y);
		}
		
		/**
		 * compare a Location with the current one
		 * 
		 * @param loc:Location the Location to compare with
		 * 
		 * @return Boolean is equal
		 */
		public function equals(loc:Location):Boolean {
			var equals:Boolean = false;
			if (loc != null) {
				equals = this.x == loc.x
						&& this.y == loc.y
						&& this.projSrsCode == loc.projSrsCode;
			}
			return equals;
		}
		
		/**
		 * Create a Location from a string
		 * @param str:String the string representing the coordinates
		 * @param srsCode:String the SRS code defining the projection of the coordinate
		 * 
		 * @return Location the location.
		 */
		public static function getLocationFromString(str:String,srsCode:String=null):Location {
			var pair:Array = str.split(",");
			return new Location(srsCode, Number(pair[0]), Number(pair[1]));
		}
		
	}
}