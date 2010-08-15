package org.openscales.basetypes
{
	import org.openscales.IProjectable;
	import org.openscales.geometry.Point;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * This class represents a location defined by:
	 * a x coordinate
	 * an y coordinate
	 * a ProjProjection
	 * 
	 * @author slopez
	 */
	public class Location implements IProjectable
	{
		private var _projection:ProjProjection = null;
		private var _x:Number;
		private var _y:Number;
		
		/**
		 * Constructor
		 * @param x:Number the X coordinate of the location
		 * @param y:Number the Y coordinate of the location
		 * @param proj:ProjProjection the projection of the coordinates, default EPSG:4326
		 */
		public function Location(x:Number,y:Number,proj:ProjProjection=null)
		{
			this._x = x;
			this._y = y;
			if(proj==null)
				this._projection = ProjProjection.getProjProjection("EPSG:4326");
			else
				this._projection = proj;
		}
		
		/**
		 * getter for the ProjProjection of the Location
		 * 
		 * @return ProjProjection the ProjProjection of the Location
		 */
		public function get projection():ProjProjection {
			return this._projection;
		}
		
		/**
		 * Clone the current location
		 * 
		 * @return IProjectable a clone of the current location
		 */
		public function clone():Location {
			return new Location(this._x,this._y,this._projection);
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
		 * Reproject the current location in another ProjProjection
		 * 
		 * @param newProj:ProjProjection the target projection
		 * 
		 * @return Location the equivalent Location of this location in the new ProjProjection
		 */
		public function reprojectTo(newProj:ProjProjection):Location {
			if(newProj.srsCode == this._projection.srsCode)
				return this;
			var p:ProjPoint = new ProjPoint(this._x, this._y);
			Proj4as.transform(this._projection, newProj, p);
			
			return new Location(p.x,p.y,newProj);
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
			return new Location(this._x + x, this._y + y, this._projection);
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
				equals = this._x == loc.x
					&& this._y == loc.y
					&& this._projection.srsCode == loc.projection.srsCode;
			}
			return equals;
		}
		
		/**
		 * Create a Location from a string
		 * @param str:String the string representing the coordinates
		 * @param proj:ProjProjection the projection of the coordinates, default EPSG:4326
		 * 
		 * @return Location the location.
		 */
		public static function getLocationFromString(str:String,proj:ProjProjection=null):Location {
			var pair:Array = str.split(",");
			return new Location(Number(pair[0]), Number(pair[1]), proj);
		}
		
	}
}