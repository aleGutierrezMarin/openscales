package org.openscales.core.basetypes
{
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.Proj4as;

	/**
	 * This class is used to carry the resolution and the associated projection.
	 */
	public class Resolution
	{
		
		private var _projection:String;
		private var _value:Number; 
			
		public function Resolution(resolutionValue:Number, projection:String = "EPSG:4326")
		{
			this._projection = projection;
			this._value = resolutionValue;
		}
		
		/**
		 * Reproject the resolution to the given projection and return the result
		 */
		public function reprojectTo(newProjection:String):Resolution
		{
			var resolution:Number = this._value;
			
			if (this._projection != newProjection)
			{
				resolution = Proj4as.unit_transform(this._projection, newProjection, resolution);
			}
			return new Resolution(resolution, newProjection);
		}
		
		/**
		 * Current projection of the resolution. This parameter is readOnly. To modify it
		 * use the reprojectTo method that will return a new object Resolution.
		 */
		public function get projection():String
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