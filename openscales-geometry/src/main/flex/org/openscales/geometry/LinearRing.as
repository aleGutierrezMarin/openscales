package org.openscales.geometry
{

	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.geometry.utils.UtilGeometry;
	import org.openscales.proj4as.ProjProjection;
		
	/**
	 * A Linear Ring is a special LineString which is closed. 
	 * It closes itself automatically on every addPoint/removePoint by adding a
	 * copy of the first point as the last point.
	 * Also, as it is the first in the line family to close itself, an area
	 * getter is defined to calculate the enclosed area of the linearRing.
	 */
	public class LinearRing extends LineString
	{
		private var _units:String;

		public function get units():String
		{
			return _units;
		}

		public function set units(value:String):void
		{
			_units = value;
		}

		/**
		 * @param points
		 * @param projection The projection to use for this LinearRing, default is EPSG:4326
		 */ 
		public function LinearRing(points:Vector.<Number> = null,projection:ProjProjection = null) {
			super(points,projection);
		}

		override public function addComponent(point:Geometry, index:Number=NaN):Boolean {
			var added:Boolean = false;
			if(0<this.componentsLength){
			  var lastPoint:Point = this.getPointAt(this.componentsLength-1);
			}
			if (!isNaN(index) || !(point as Point).equals(lastPoint)) {
				added = super.addComponent(point, index);
			}
			return added;
		}
		
		/**
     	 * Test if a point is inside a linear ring.
     	 * Two major methods are used for this test : "crossing number" or
     	 * "winding number". There are both discussed at
     	 * http://softsurfer.com/Archive/algorithm_0103/algorithm_0103.htm
     	 * 
     	 * This function is an implementation of the "winding number" algorithm
     	 * that uses the Geometry.isLeftOrRigh function.
     	 * 
     	 * @param p the point to test
		 * @return a boolean defining if the point is inside or outside this geometry
     	 */
		override public function containsPoint(p:Point):Boolean {
			// If the point is not inside the bounding box of the LinearRing, it
			// can not be in the LinearRing.
			if (! this.bounds.containsLocation(new Location(p.x, p.y, p.projection))) {
				return false;
			}
			
			var wn:int = 0; // the winding number-
			var p0:Point; // first vertex of the current edge
			var p1:Point;  // second vertex of the current edge
			var realIndex:uint = 0;
			var length:int = this.componentsLength;
			for(var i:int=0; i<length; ++i) {
				realIndex = i*2;
				p0= new Point(this._components[realIndex],this._components[realIndex + 1]);
				
				if(i==length-1) {
					p1 = new Point(this._components[0],this._components[1]);
					
				} else {
					p1 = new Point(this._components[realIndex + 2],this._components[realIndex + 3]);
				}
				if (p0.y <= p.y) {
					if (p1.y > p.y) {
						if (UtilGeometry.isLeftOrRight(p, p0,p1) > 0) {
							wn++;
						}
					}
				} else {
					if (p1.y <= p.y) {
						if (UtilGeometry.isLeftOrRight(p,p0,p1) < 0) {
							wn--;
						}
					}
				}
			}
			return (wn != 0);
		}
		
		/**
		 * Test if a MultiPoint (and so a LineString or a LinearRing) is inside
		 * a linear ring or not.
		 */
		public function containsMultiPoint(mp:MultiPoint):Boolean {
			for(var i:int=0; i<mp.componentsLength; i++) {
				if (! this.containsPoint(mp.componentByIndex(i) as Point) ) {
					return false;
				}
			}
			return true;
		}
			
		/**
     	 * Test for instersection between this LinearRing and a geometry.
     	 * 
     	 * @param geom the geometry (of any type) to intersect with
     	 * @return a boolean defining if an intersection exist or not
      	 */
		override public function intersects(geom:Geometry):Boolean {
			if (geom is Point) {
				return this.containsPoint(geom as Point);
			}
			else if (geom is LinearRing) {
				// LinearRing must be tested before LineString !!!
				return super.intersects(geom);
			}
			else if (geom is LineString) {
				return (geom as LineString).intersects(this);
			}
			else {  // geom is a multi-geometry
				var numSubGeometries:int = (geom as Collection).componentsLength;
				for(var i:int=0; i<numSubGeometries; ++i) {
					if ((geom as Collection).componentByIndex(i).intersects(this)) {
						// The sub-geometry intersects this LinearRing, there is
						//   no need to continue the tests for all the other
						//   sub-geometries
						return true;
					}
				}
			}
    		// No sub-geometry intersects this LinearRing
			return false;
     	}
		
		/**
		 * Calculate the approximate area enclosed by this LinearRing (the
		 * projection and the geodesic are not managed).
		 * 
		 * The auto-intersection of edges of the LinearRing is not managed yet.
		 */
		override public function get area():Number {
			var area:Number = 0;
			if ( this.components && (this.components.length > 4)) {
				var sum:Number = 0;
				var len:Number = len=this.components.length;
				for (var i:Number=0; i<len - 3; i+=2) {
					var bx:Number = this.components[i];
					var by:Number = this.components[i+1];
					var cx:Number = this.components[i+2];
					var cy:Number = this.components[i+3];
					sum += (bx + cx) * (cy - by);
				}
				
				bx = cx;
				by = cy;
				sum += (bx + cx) * (cy - by);
				
				cx = this.components[0];
				cy = this.components[1];
				sum += (bx + cx) * (cy - by);
				
				area = - sum / 2;
			}
			return area;
		}
		
		/**
		 * To get this geometry clone
		 * */
		override public function clone():Geometry{
			var LinearRingClone:LinearRing=new LinearRing();
			var component:Vector.<Number>=this.getcomponentsClone();
			LinearRingClone.projection = this.projection;
			LinearRingClone._bounds = this._bounds;
			LinearRingClone.addPoints(component);
			return LinearRingClone;
		}
	}
}

