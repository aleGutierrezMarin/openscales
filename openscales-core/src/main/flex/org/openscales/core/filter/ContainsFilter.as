package org.openscales.core.filter {
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.Geometry;

	public class ContainsFilter extends IntersectsFilter
	{
		public function ContainsFilter(geom:Geometry, projection:String) {
			super(geom, projection);
		}
		
		override public function matches(feature:Feature):Boolean {
			if (super.matches(feature)) {
				// the two geometries intersect, so we have to test the inclusion
				return this.geometry.contains(feature.geometry, true);
			} else {
				return false;
			}
		}
		
	}
}