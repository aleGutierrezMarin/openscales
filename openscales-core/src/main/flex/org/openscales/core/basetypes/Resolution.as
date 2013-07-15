package org.openscales.core.basetypes
{
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * This class is used to carry the resolution and the associated projection.
	 */
	public class Resolution
	{
		
		private var _projection:ProjProjection;
		private var _value:Number; 
		
		/**
		 * @param resolutionValue Numeric value of the resolution (must be consistent with projection's units)
		 * @param projection The projection in which this value is expressed
		 */ 
		public function Resolution(resolutionValue:Number, projection:Object = null)
		{
			this._projection = ProjProjection.getProjProjection(projection);
			if(this._projection == null)
				this._projection = ProjProjection.getProjProjection(Geometry.DEFAULT_SRS_CODE);
			this._value = resolutionValue;
		}
		
		/**
		 * Reproject the resolution to the given projection and return the result
		 * 
		 * @param a ProjProjection object or a String representing the SRS code of the projection (eg.: EPSG:4326) 
		 */
		public function reprojectTo(newProjection:Object):Resolution
		{
			var proj:ProjProjection = ProjProjection.getProjProjection(newProjection);
			if(proj == null)
				return null;
			var resolution:Number = this._value;
			
			if (!ProjProjection.isEquivalentProjection(this._projection, proj))
			{
				resolution = Proj4as.unit_transform(this._projection, proj, resolution);
			}
			return new Resolution(resolution, newProjection);
		}
		
		/**
		 * 
		 * 
		 * 
		 */		
		
		public function equals(projToCompare:Resolution):Number{
			var valToCompare:Number;
			valToCompare  = projToCompare.value;
			
			if(this.projection != projToCompare.projection){
				valToCompare = Proj4as.unit_transform(projToCompare.projection, this.projection, projToCompare.value);
			}
			
			if(this.value>valToCompare){
				return 1;
			}else if(this.value==valToCompare){
				return 0;
			}else{
				return -1;
			}
			
			
		}
		
		/**
		 * Current projection of the resolution. This parameter is readOnly. To modify it
		 * use the reprojectTo method that will return a new object Resolution.
		 */
		public function get projection():ProjProjection
		{
			return this._projection;
		}
		
		/**
		 * @private
		 */
		public function get value():Number
		{
			return this._value;
		}
	}
}