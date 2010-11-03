package org.openscales.core.filter {
	import org.openscales.core.Trace;
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.Geometry;

	public class IntersectsFilter implements IFilter
	{
		private var _geom:Geometry;
		
		public function IntersectsFilter(geom:Geometry) {
			this._geom = geom;
		}
		
		public function matches(feature:Feature):Boolean {
			if ((this.geometry==null) || (feature==null)) {
				return false;
			}
			// If needed, reproject the geometry of the filter in the projection of the input feature
			// FixMe: this reprojection should be done with temporary geometries directly inside the intersect function of the Geometries
			if (this.geometry.projSrsCode != feature.geometry.projSrsCode) {
				this.geometry.projSrsCode = feature.geometry.projSrsCode;
			}
			// Do the test
			return this.geometry.intersects(feature.geometry);
		}
		
		/**
		 * Getter and setter of the geometry
		 */
		public function get geometry():Geometry {
			return this._geom;
		}
		public function set geometry(value:Geometry):void {
			this._geom = value;
		}
		
		public function clone():IFilter{
			return new IntersectsFilter(this.geometry);
		}
		
	}
}