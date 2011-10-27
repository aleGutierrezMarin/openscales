package org.openscales.core.filter {
	import org.openscales.core.utils.Trace;
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.Geometry;

	public class IntersectsFilter implements IFilter
	{
		private var _geom:Geometry;
		private var _projection:String;
		
		public function IntersectsFilter(geom:Geometry, projection:String) {
			this._geom = geom;
			this._projection = projection;
		}
		
		/**
		 * Allow to know if a feature match with the filter
		 * 
		 * @param the feature
		 * @return true is the feature match, else false
		 */
		public function matches(feature:Feature):Boolean {
			if ((this.geometry==null) || (this.projection==null) || (feature==null)) {
				return false;
			}
			if (this.projection != feature.layer.map.projection) {
				this.geometry.transform(this.projection, feature.layer.map.projection);
				this.projection = feature.layer.map.projection;
			}
			return this.geometry.intersects(feature.geometry);
		}
		
		/**
		 * Indicates the geometry used in the filter
		 */
		public function get geometry():Geometry {
			return this._geom;
		}
		/**
		 * @private
		 */
		public function set geometry(value:Geometry):void {
			this._geom = value;
		}
		
		/**
		 * Indicates the projection
		 */
		public function get projection():String {
			return this._projection;
		}
		/**
		 * @private
		 */
		public function set projection(value:String):void {
			this._projection = value;
		}
		
		/**
		 * Clone the filter
		 */
		public function clone():IFilter{
			return new IntersectsFilter(this.geometry,this.projection);
		}
		
	}
}