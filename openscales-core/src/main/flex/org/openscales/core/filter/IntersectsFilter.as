package org.openscales.core.filter {
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.Geometry;
	import org.openscales.proj4as.ProjProjection;

	public class IntersectsFilter implements IFilter
	{
		private var _geom:Geometry;
		private var _projection:ProjProjection;
		
		public function IntersectsFilter(geom:Geometry, projection:*) {
			this._geom = geom;
			this.projection = projection;
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
				this.geometry.projection = this.projection;
				this.geometry.transform(feature.layer.map.projection);
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
		public function get projection():ProjProjection {
			return this._projection;
		}
		/**
		 * @private
		 */
		public function set projection(value:*):void {
			this._projection = ProjProjection.getProjProjection(value);
		}
		
		/**
		 * Clone the filter
		 */
		public function clone():IFilter{
			return new IntersectsFilter(this.geometry,this.projection);
		}
		
		public function get sld():String {
			return null;
		}
		public function set sld(sld:String):void {
			//TODO
		}
		
	}
}