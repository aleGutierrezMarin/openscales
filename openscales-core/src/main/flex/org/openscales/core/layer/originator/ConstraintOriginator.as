package org.openscales.core.layer.originator
{
	import org.openscales.geometry.basetypes.Bounds;
	
	/**
	 * Instances of ConstraintOriginator are used to keep the informations about the limit of the data covered by the originator 
	 * (extent and minimum and maximum resolution).
	 * 
	 * This ConstraintOriginator class represents the constraint of data provided by an originator.
	 *
	 * @author ajard
	 */ 
	
	public class ConstraintOriginator
	{
		/**
		 * @private
		 * @default null
		 * The extent covered by the originator.
		 */
		private var _extent:Bounds = null;
		
		/**
		 * @private
		 * @default NaN
		 * The minimum resolution covered by the originator.
		 */
		private var _minResolution:Number = NaN;
		
		/**
		 * @private
		 * @default NaN
		 * The maximum resolution covered by the originator.
		 */
		private var _maxResolution:Number = NaN;
		
		/**
		 * Constructor of the class ConstraintOriginator.
		 * 
		 * @param extent The extent of the provided data (mandatory)
		 * @param minResolution The minimum resolution of the provided data (mandatory)
		 * @param maxResolution The maximum resolution of the provided data (mandatory)
		 */ 
		public function ConstraintOriginator(extent:Bounds, minResolution:Number, maxResolution:Number)
		{
			this._extent = extent;
			this._minResolution = minResolution;
			this._maxResolution = maxResolution;
		}
		
		// getters setters
		
		/**
		 * The extent covered by the originator.
		 */
		public function get extent():Bounds
		{
			return this._extent;
		}
		/**
		 * @private
		 */
		public function set extent(extent:Bounds):void 
		{
			this._extent = extent;
		}
		
		/**
		 * The minimum resolution covered by the originator.
		 */
		public function get minResolution():Number
		{
			return this._minResolution;
		}
		/**
		 * @private
		 */
		public function set minResolution(minResolution:Number):void 
		{
			this._minResolution = minResolution;
		}
		
		/**
		 * The maximum resolution covered by the originator.
		 */
		public function get maxResolution():Number
		{
			return this._maxResolution;
		}
		/**
		 * @private
		 */
		public function set maxResolution(maxResolution:Number):void 
		{
			this._maxResolution = maxResolution;
		}
	}
}