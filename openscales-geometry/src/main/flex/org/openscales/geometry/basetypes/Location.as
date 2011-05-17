package org.openscales.geometry.basetypes
{
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.Point;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjPoint;
	
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
		private var _projSrsCode:String = null;
		private var _x:Number;
		private var _y:Number;
		
		/**
		 * Constructor
		 * 
		 * @param x:Number the X coordinate of the location
		 * @param y:Number the Y coordinate of the location
		 * @param srsCode:String the SRS code defining the projection of the coordinates, default is Geometry.DEFAULT_SRS_CODE
		 */
		public function Location(x:Number,y:Number,srsCode:String=null)
		{
			this._x = x;
			this._y = y;
			this._projSrsCode = (srsCode==null) ? Geometry.DEFAULT_SRS_CODE : srsCode;
		}
		
		/**
		 * Clones the current location
		 * 
		 * @return IProjectable a clone of the current location
		 */
		public function clone():Location {
			return new Location(this._x,this._y,this._projSrsCode);
		}
		
		/**
		 * Indicates the x coordinate
		 */
		public function get x():Number {
			return this._x;
		}
		
		/**
		 * Indicates the y coordinate
		 */
		public function get y():Number {
			return this._y;
		}
		
		/**
		 * Indicates the SRS code defining projection of the Location
		 */
		public function get projSrsCode():String {
			return this._projSrsCode;
		}
		
		/**
		 * Indicates the lon coordinate
		 */
		public function get lon():Number {
			return this._x;
		}
		
		/**
		 * Indicates the lat coordinate
		 */
		public function get lat():Number {
			return this._y;
		}
		
		/**
		 * Reprojects the current location in another projection
		 * 
		 * @param newSrsCode:String SRS code of the target projection
		 * @return Location the equivalent Location of this location in the new projection
		 */
		public function reprojectTo(newSrsCode:String):Location {
			if (newSrsCode == this._projSrsCode) {
				return this;
			}
			var p:ProjPoint = new ProjPoint(this._x, this._y);
			Proj4as.transform(this._projSrsCode, newSrsCode, p);
			return new Location(p.x,p.y,newSrsCode);
		}
		
		/**
		 * Gives the equivalent string of the current location
		 * 
		 * @return String the current location
		 */
		public function toString():String {
			return "lon=" + this._x + ",lat=" + this._y;
		}
		
		/**
		 * Gives the equivalent short string of the current location
		 * 
		 * @return String the current location
		 */
		public function toShortString():String {
			return this._x + ", " + this._y;
		}
		
		/**
		 * Adds delta derivation to the current Location
		 * 
		 * @param x:Number the X derivation
		 * @param y:Number the Y derivation
		 * 
		 * @return Location the new Location
		 */
		public function add(x:Number, y:Number):Location {
			return new Location(this._x + x, this._y + y, this._projSrsCode);
		}
		
		/**
		 * Compares a Location with the current one
		 * 
		 * @param loc:Location the Location to compare with
		 * 
		 * @return Boolean is equal
		 */
		public function equals(loc:Location):Boolean {
			var equals:Boolean = false;
			if (loc != null) {
				equals = this._x == loc.x
					&& this._y == loc.y
					&& this._projSrsCode == loc.projSrsCode;
			}
			return equals;
		}
		
		/**
		 * Creates a Location from a string
		 * @param str:String the string representing the coordinates
		 * @param srsCode:String the SRS code defining the projection of the coordinate
		 * 
		 * @return Location the location.
		 */
		public static function getLocationFromString(str:String,srsCode:String=null):Location {
			var pair:Array = str.split(",");
			return new Location(Number(pair[0]), Number(pair[1]), srsCode);
		}
		
	}
}