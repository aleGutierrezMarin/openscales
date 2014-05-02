package org.openscales.core.layer.originator
{
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.Constraint;
	import org.openscales.geometry.basetypes.Bounds;
	
	/**
	 * Instances of ConstraintOriginator are used to keep the informations about the limit of the data covered by the originator 
	 * (extent and minimum and maximum resolution).
	 * 
	 * This ConstraintOriginator class represents the constraint of data provided by an originator.
	 *
	 * @author ajard
	 */ 
	
	public class ConstraintOriginator extends Constraint
	{
		/**
		 * @private
		 * @default null
		 * The extent covered by the originator.
		 */
		private var _extent:Bounds = null;
		
		/**
		 * Constructor of the class ConstraintOriginator.
		 * 
		 * @param extent The extent of the provided data (mandatory)
		 * @param minResolution The minimum resolution of the provided data (mandatory)
		 * @param maxResolution The maximum resolution of the provided data (mandatory)
		 */ 
		public function ConstraintOriginator(extent:Bounds, minResolution:Resolution, maxResolution:Resolution)
		{
			super(minResolution, maxResolution);
			this._extent = extent;
		}
		
		/**
		 * Determines if the ConstraintOriginator passed as param is equal to current instance
		 *
		 * @param constraint ConstraintOriginator to check equality
		 * @return It is equal or not
		 */
		public function equals(constraint:ConstraintOriginator):Boolean {
			var equals:Boolean = false;
			if (constraint != null) 
			{
				equals = this._extent == constraint.extent &&
					this.minResolution == constraint.minResolution &&
					this.maxResolution == constraint.maxResolution;
			}
			return equals;
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
	}
}