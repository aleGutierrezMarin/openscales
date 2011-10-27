package org.openscales.core.layer
{
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.geometry.basetypes.Bounds;
	
	/**
	 * Defines a constraint for layer that have multibbox.
	 * 
	 * A constraint is defined by a range of resolutions (minResolution, maxResolution) and a list of bounding boxes
	 * 
	 * NB: All values in those instance should be projected in WGS84 
	 */ 
	public class MultiBoundingBoxConstraint extends Constraint
	{
		private var _bboxes:Vector.<Bounds> = null;
		
		public function MultiBoundingBoxConstraint(minResolution:Resolution, maxResolution:Resolution, bboxes:Vector.<Bounds>)
		{
			super(minResolution, maxResolution);
			this._bboxes = bboxes;
		}

		/**
		 * List of bounding boxes
		 */
		public function get bboxes():Vector.<Bounds>
		{
			return _bboxes;
		}

		/**
		 * @private
		 */
		public function set bboxes(value:Vector.<Bounds>):void
		{
			_bboxes = value;
		}

	}
}