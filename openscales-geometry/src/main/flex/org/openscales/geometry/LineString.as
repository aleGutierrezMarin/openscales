package org.openscales.geometry
{
	
	
	import flash.geom.Point;
	
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.utils.UtilGeometry;
	import org.openscales.proj4as.ProjCalculus;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * A LineString is a MultiPoint (2 vertices min), whose points are
	 * assumed to be connected.
	 */
	public class LineString extends MultiPoint
	{
		/**
		 * LineString constructor
		 * 
		 * @param vertices Array of two or more points
		 * @param projection The projection to use for this LineString, default is EPSG:4326
		 */
		public function LineString(vertices:Vector.<Number>,projection:ProjProjection = null) {
			super(vertices,projection);
		}
		
		
		
		/**
		 * @param index the index of the attended vertex
		 * @return the vertex requested or null for an invalid index
		 */
		public function getPointAt(index:Number):org.openscales.geometry.Point {
			// Return null for an invalid request
			var realIndex:uint = index * 2;
			if ((realIndex<0) || (realIndex>=this._components.length)) {
				return null;
			}
			return new org.openscales.geometry.Point(this._components[realIndex],this._components[realIndex + 1]);
		}
		
		/**
		 * @return the last vertex of the LineString
		 */
		public function getLastPoint():org.openscales.geometry.Point {
			return this.getPointAt(this.componentsLength - 1);
		}
		
		/**
		 * Length getter which iterates through the vertices summing the
		 * distances of each edges.
		 */
		override public function get length():Number {
			var length:Number = 0.0;
			var dx2:Number;
			var dy2:Number
			var tabLength:uint = this._components.length;
			if (tabLength > 1) {
				for(var i:int=2; i<tabLength; i+=2) {
					 dx2 = Math.pow(this._components[i-2] - this._components[i], 2);
					 dy2 = Math.pow(this._components[i - 1] - this._components[i + 1], 2);
					length += Math.sqrt( dx2 + dy2 );
				}
			}
			return length;
		}
		
		/**
		 * Calculate the approximate length of the geometry were it projected onto
		 *     the earth.
		 * 
		 * Returns:
		 * {Float} The appoximate geodesic length of the geometry in meters.
		 */
		public function get geodesicLength():Number
		{
			var geom:LineString = this;  // so we can work with a clone if needed
			var lonlatProj:ProjProjection = ProjProjection.getProjProjection("EPSG:4326");
			if(lonlatProj != this.projection) {
				geom = this.clone() as LineString;
				geom.transform(lonlatProj);
			}
			var length:Number = 0;
			if(geom.components && (geom.components.length >= 4)) {
				var p1:flash.geom.Point;
				var p2:flash.geom.Point;
				for(var i:int=3, len:int=geom.components.length; i<len; i=i+2) {
					p1 = new flash.geom.Point(geom.components[i-3], geom.components[i-2]);
					p2 =  new flash.geom.Point(geom.components[i-1], geom.components[i]);
					// this returns km and requires lon/lat properties
					length += ProjCalculus.distVincenty(p1,p2);
				}
			}
			// convert to m
			return length * 1000;
		}
		/**
     	 * Test for instersection between this LineString and a geometry.
     	 * 
     	 * This is a cheapo implementation of the Bentley-Ottmann algorithm but
     	 * it doesn't really keep track of a sweep line data structure.
     	 * It is closer to the brute force method, except that segments are
     	 * X-sorted and potential intersections are only calculated when their
     	 * bounding boxes intersect.
     	 * 
     	 * @param geom the geometry (of any type) to intersect with
     	 * @return a boolean defining if an intersection exist or not
      	 */
		override public function intersects(geom:Geometry):Boolean {
			// Treat the geometry as a collection if it is not a simple point,
			// a simple polyline or a simple polygon
			if ( ! ((geom is org.openscales.geometry.Point) || (geom is LinearRing) || (geom is LineString)) ) {
				 // LinearRing should be tested before LineString if a different
				 // action should be made for each case
				return (geom as Collection).intersects(this);
			}
			
			// The geometry to intersect is a simple Point, a simple polyline or
			//   a simple polygon.
			// First, check if the bounding boxes of the two geometries intersect
			if (! this.bounds.intersectsBounds(geom.bounds)) {
				return false;
			}
			
			// To test if an intersection exists, it is necessary to cut this
			//   line string and the geometry in segments. The segments are
			//   oriented so that x1 <= x2 (but we does not known if y1 <= y2
			//   or not).
			var segs1:Vector.<Vector.<org.openscales.geometry.Point>> = this.getXsortedSegments();
				
			var segs2:Vector.<Vector.<org.openscales.geometry.Point>> = (geom is org.openscales.geometry.Point) ? new Vector.<org.openscales.geometry.Point>[new <org.openscales.geometry.Point>[(geom as org.openscales.geometry.Point),(geom as org.openscales.geometry.Point)]] : (geom as LineString).getXsortedSegments();
			
			var seg1:Vector.<org.openscales.geometry.Point>, seg1y0:Number, seg1y1:Number, seg1yMin:Number, seg1yMax:Number;
			var seg2:Vector.<org.openscales.geometry.Point>, seg2y0:Number, seg2y1:Number, seg2yMin:Number, seg2yMax:Number;
			// Loop over each segment of this LineString
    		for(var i:int=0; i<segs1.length; ++i) {
				seg1 = segs1[i];
				// Loop over each segment of the requested geometry
				for(var j:int=0; j<segs2.length; ++j) {
					// Before to really test the intersection between the two
					//    segments, we will test the intersection between their
					//    respective bounding boxes in four steps.
					seg2 = segs2[j];
					// If the most left vertex of seg2 is at the right of the
					//   most right vertex of seg1, there is no intersection
					if ((seg2[0] as org.openscales.geometry.Point).x > (seg1[1] as org.openscales.geometry.Point).x) {
                		continue;
            		}
					// If the most right vertex of seg2 is at the left of the
					//   most left vertex of seg1, there is no intersection
            		if ((seg2[1] as org.openscales.geometry.Point).x < (seg1[0] as org.openscales.geometry.Point).x) {
            		    // seg2 still left of seg1
            		    continue;
           		 	}
           		 	// To perform similar tests along Y-axis, it is necessary to
           		 	//   order the vertices of each segment
					seg1y0 = (seg1[0] as org.openscales.geometry.Point).y;
					seg1y1 = (seg1[1] as org.openscales.geometry.Point).y;
          		  	seg2y0 = (seg2[0] as org.openscales.geometry.Point).y;
          		  	seg2y1 = (seg2[1] as org.openscales.geometry.Point).y;
          		  	seg1yMin = Math.min(seg1y0, seg1y1);
          		  	seg1yMax = Math.max(seg1y0, seg1y1);
          		  	seg2yMin = Math.min(seg2y0, seg2y1);
          		  	seg2yMax = Math.max(seg2y0, seg2y1);
					// If the most bottom vertex of seg2 is above the most top
					//   vertex of seg1, there is no intersection
					if (seg2yMin > seg1yMax) {
						continue;
					}
					// If the most top vertex of seg2 is below the most bottom
					//   vertex of seg1, there is no intersection
					if (seg2yMax < seg1yMin) {
						continue;
					}
					// Now it sure that the bounding box of the two segments
					//   intersect themselves, so we have to perform the real
					//   intersection test of the two segments
					if (UtilGeometry.segmentsIntersect(seg1, seg2)) {
						// These two segments intersect, there is no need to
						//   continue the tests for all the other couples of
						//   segments
						return true;
					}
				}
    		}
    		
    		// All the couples of segment have been testes, there is no intersection
    		return false;
		}
		   
		/**
		 * Cut the LineString in an array of segments and each of them is sorted
		 * along X-axis to have seg[i].p1.x <= seg[i].p2.x
		 * There is (of course) no sort along Y-axis.
		 * 
		 * @return Array of X-sorted segments
		 */
		private function getXsortedSegments():Vector.<Vector.<org.openscales.geometry.Point>> {
			var point1:org.openscales.geometry.Point, point2:org.openscales.geometry.Point;
			var numSegs:int = this._components.length-3;
			if(numSegs<0)numSegs=0;
			var segments:Vector.<Vector.<org.openscales.geometry.Point>> = new Vector.<Vector.<org.openscales.geometry.Point>>(numSegs);
			for(var i:int=0; i<numSegs; ++i) {
				point1 = new org.openscales.geometry.Point(this._components[i],this._components[i+1])
				point2 = new org.openscales.geometry.Point(this._components[i + 2],this._components[i + 3])
				segments[i] = (this._components[i+2] < this._components[i]) ? new <org.openscales.geometry.Point>[point2,point1] :  new <org.openscales.geometry.Point>[point1,point2];
			}
			return segments;
		}
		/**
		 * To get this geometry clone
		 * */
		override public function clone():Geometry{
			var lineStringClone:LineString=new LineString(null);
			var component:Vector.<Number>=this.getcomponentsClone();
			lineStringClone.projection = this.projection;
			lineStringClone._bounds = this._bounds;
			lineStringClone.addPoints(component);
			return lineStringClone;
		}
	}
}
