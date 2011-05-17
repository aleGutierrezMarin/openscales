package org.openscales.core.filter {
	import org.openscales.core.Trace;
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.Geometry;

	public class IntersectsFilter implements IFilter
	{
		private var _geom:Geometry;
		private var _projSrsCode:String;
		
		public function IntersectsFilter(geom:Geometry, srsCode:String/*=Geometry.DEFAULT_SRS_CODE*/) {
			this._geom = geom;
			this._projSrsCode = srsCode;
		}
		
		public function matches(feature:Feature):Boolean {
			if ((this.geometry==null) || (this.projSrsCode==null) || (feature==null)) {
				return false;
			}
			if (this.projSrsCode != feature.layer.map.baseLayer.projSrsCode) {
				this.geometry.transform(this.projSrsCode, feature.layer.map.baseLayer.projSrsCode);
				this.projSrsCode = feature.layer.map.baseLayer.projSrsCode;
			}
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
		
		/**
		 * Getter and setter of the projection
		 */
		public function get projSrsCode():String {
			return this._projSrsCode;
		}
		public function set projSrsCode(value:String):void {
			this._projSrsCode = value;
		}
		
		public function clone():IFilter{
			return new IntersectsFilter(this.geometry,this.projSrsCode);
		}
		
	}
}