package org.openscales.geometry
{
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;


	/**
	 * A Geometry is a description of a geographic object.
	 * Create an instance of this class with the Geometry constructor.
	 * This is a base class, typical geometry types are described by subclasses of this class.
	 */
	public class Geometry 
	{
		public static const DEFAULT_SRS_CODE:String = "EPSG:4326";
		
		/**
     	 * The bounds of this geometry
		 * 
     	 */
		protected var _bounds:Bounds = null;
		
		/**
		 * projection of the geometry 
		 */
		protected var _projSrsCode:String = DEFAULT_SRS_CODE;
		
		public function Geometry() {
			super();
		}
		
		/**
		 * Destroy the geometry
		 */
		public function destroy():void {
			this._bounds = null;
		}
		
		/**
		 * To get this geometry clone
		 */
		public function clone():Geometry {
			return null;
		}

		public function toShortString():String {
			return "";
		}
		/**
		 * Method to convert the coordinates of the geometry from a projection system to an other one.
		 * @param sourceSrs SRS of the source projection
		 * @param destSrs SRS of the destination projection
		 */
		public function transform(sourceSrs:String, destSrs:String):void {
			// Update the pojection associated to the geometry
			this.projSrsCode = destSrs;
			// Update the geometry
			// Noting to do for this generic class
		}

		/**
		 * Clear the geometry's bounds
		 */
		public function clearBounds():void {
			this._bounds = null;
		}

		public function get bounds():Bounds {
			if (this._bounds == null) {
				this.calculateBounds();
			}
			return this._bounds;
		}

		/**
		 * The definition of the bounding box of the geometry must be overrided
		 * in each sub class
		 */
		public function calculateBounds():void {
			this._bounds = null;
		}

		/**
		 * Return an array of all the vertices (Point) of this geometry
		 */
		public function toVertices():Vector.<Point> {
			return new Vector.<Geometry>();
		}

		/**
		 * Determines if the feature is placed at the given point with a certain tolerance (or not).
		 *
		 * @param lonlat The given point
		 * @param toleranceLon The longitude tolerance
		 * @param toleranceLat The latitude tolerance
		 */
		public function atPoint(lonlat:Location, toleranceLon:Number, toleranceLat:Number):Boolean {
			var atPoint:Boolean = false;
			var bounds:Bounds = this.bounds;
			if ((bounds != null) && (lonlat != null)) {

				var dX:Number = (!isNaN(toleranceLon)) ? toleranceLon : 0;
				var dY:Number = (!isNaN(toleranceLat)) ? toleranceLat : 0;

				var toleranceBounds:Bounds = 
					new Bounds(this.bounds.left - dX,
					this.bounds.bottom - dY,
					this.bounds.right + dX,
					this.bounds.top + dY,
					this.projSrsCode);

				atPoint = toleranceBounds.containsLocation(lonlat);
			}
			return atPoint;
		}
		
		/**
     	 * Calculate the closest distance between two geometries (on the x-y plane).
     	 *
     	 * @param geometry The target geometry.
     	 *
     	 * 
     	 * @return The distance between this geometry and the target.
     	 *     If details is true, the return will be an object with distance,
     	 *     x0, y0, x1, and x2 properties.  The x0 and y0 properties represent
     	 *     the coordinates of the closest point on this geometry. The x1 and y1
     	 *     properties represent the coordinates of the closest point on the
     	 *     target geometry.
      	 */
		 public function distanceTo(geometry:Geometry, options:Object=null):Number{
    		var distance:Number;
    		// TODO
    		return distance;
    	}
		
		/**
		 * Determine if the input geometry intersects this one.
		 * 
		 * @param geometry Any type of geometry.
		 * @return Boolean defining if the input geometry intersects this one.
		 */
		public function intersects(geom:Geometry):Boolean {
			return false;
		}
		
		/**
		 * Determine if the input geometry is fully contained in this one.
		 * 
		 * @param geometry Any type of geometry.
		 * @param assertIntersection if the intersection has already been tested
		 * it is better to not retest it by setting this parameter to "true"
		 * @return Boolean defining if the input geometry is contained or not.
		 */
		public function contains(geom:Geometry, assertIntersection:Boolean=false):Boolean {
			// If the two geometries doesn't intersect themselves, the input
			// geometry cannot be contained in this one.
			if ((! assertIntersection) && (! this.intersects(geom))) {
				return false;
			}
			// The two geometries intersect, so the inclusion may be tested by
			// using the containsPoint for each vertex of the input geometry.
			var vertices:Vector.<Point> = geom.toVertices();
			if (vertices.length == 0) {
				return false;
			}
			for each(var vertex:Point in vertices) {
				if (! this.containsPoint(vertex)) {
					return false;
				}
			}
			return true;
		}
		
		/**
     	 * Test if a point is inside this geometry.
     	 * 
     	 * @param p the point to test
		 * @return a boolean defining if the point is inside or outside this geometry
     	 */
		public function containsPoint(p:Point):Boolean {
			return false;
		}
		
		public function get projSrsCode():String {
			return this._projSrsCode;
		}
		
		public function set projSrsCode(value:String):void {
			this._projSrsCode = value;
			if (value == null) {
				this.clearBounds();
			} else {
				if (this._bounds != null) { // the private variable is tested to avoid to create the bounds if it doesn't exist
					this._bounds = this._bounds.reprojectTo(this._projSrsCode);
				}
			}
		}
		
		/**
		 * Returns the geometry's length. Overrided by subclasses.
		 */
		public function get length():Number {
			return 0.0;
		}
        /**
		 * Returns the geometry's area. Overrided by subclasses.
		 */
		public function get area():Number {
			return 0.0;
		}
		
	}
}

