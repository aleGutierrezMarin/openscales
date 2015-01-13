package org.openscales.core.layer
{
	import org.openscales.core.basetypes.Resolution;

	public class Constraint
	{
		/**
		 * @private
		 * @default NaN
		 * The minimum resolution covered by the originator.
		 */
		private var _minResolution:Resolution = null;
		
		/**
		 * @private
		 * @default NaN
		 * The maximum resolution covered by the originator.
		 */
		private var _maxResolution:Resolution = null;
		
		public function Constraint(minResolution:Resolution, maxResolution:Resolution)
		{
			this._minResolution = minResolution;
			this._maxResolution = maxResolution;
		}
		
		/**
		 * The minimum resolution covered by the originator.
		 */
		public function get minResolution():Resolution
		{
			return this._minResolution;
		}
		/**
		 * @private
		 */
		public function set minResolution(minResolution:Resolution):void 
		{
			this._minResolution = minResolution;
		}
		
		/**
		 * The maximum resolution covered by the originator.
		 */
		public function get maxResolution():Resolution
		{
			return this._maxResolution;
		}
		/**
		 * @private
		 */
		public function set maxResolution(maxResolution:Resolution):void 
		{
			this._maxResolution = maxResolution;
		}
	}
}