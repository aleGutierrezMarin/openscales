package org.openscales.core.control
{
	/**
	 * This class is use to store informations about resolution label to display.
	 * A label is associated to a minimum resolution which determine when it has to be displayed.
	 */
	public class ZoomData
	{
		/**
		 * @private
		 * The label value to display.
		 * @default null
		 */
		private var _label:String = null;

		/**
		 * @private
		 * The minimum resolution level for this label to appear.
		 * @default
		 */
		private var _minResolution:Number = 0;

		/**
		 * @private
		 * The maximum resolution level for this label to appear.
		 * @default
		 */
		private var _maxResolution:Number = 0;
		
		/**
		 * Constructor for the ZoomData
		 * 
		 * @param label The label to display
		 * @param resolution The minimum resolution required to display the label
		 */
		public function ZoomData(label:String, minResolution:Number, maxResolution:Number)
		{
			this._label = label;
			this._minResolution = minResolution;
			this._maxResolution = maxResolution;
		}
		
		/**
		 * The label value to display
		 */
		public function get label():String
		{
			return this._label;
		}
		
		/**
		 * @private
		 */
		public function set label(value:String):void
		{
			this._label = value;
		}
		
		/**
		 * The minimum zomm level for this label to appear.
		 */
		public function get minResolution():Number
		{
			return this._minResolution;
		}
		
		/**
		 * @private
		 */
		public function set minResolution(value:Number):void
		{
			this._minResolution = value;
		}
		
		/**
		 * The maximum zomm level for this label to appear.
		 */
		public function get maxResolution():Number
		{
			return this._maxResolution;
		}
		
		/**
		 * @private
		 */
		public function set maxResolution(value:Number):void
		{
			this._maxResolution = value;
		}
	}
}