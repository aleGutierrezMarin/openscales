package org.openscales.core.search.result
{
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	
	[Bindable]
	public class Address
	{
		private var _bbox:Bounds = null;
		private var _name:String = null;
		private var _location:Location = null;
		private var _confidence:String = null;
		private var _precision:Number = -1;
		private var _addressLine:String = null;
		private var _locality:String = null;
		private var _postalCode:String = null;
		private var _state:String = null;
		private var _countryRegion:String = null;
		private var _formattedAddress:String = null;
		
		public function Address()
		{
		}

		/**
		 * bounding box of the result
		 */
		public function get bbox():Bounds
		{
			return _bbox;
		}
		/**
		 * @private
		 */
		public function set bbox(value:Bounds):void
		{
			_bbox = value;
		}
		/**
		 * the name
		 */
		public function get name():String
		{
			return _name;
		}
		/**
		 * @private
		 */
		public function set name(value:String):void
		{
			_name = value;
		}
		/**
		 * the location
		 */
		public function get location():Location
		{
			return _location;
		}
		/**
		 * @private
		 */
		public function set location(value:Location):void
		{
			_location = value;
		}
		/**
		 * the confidence (ex:high)
		 */
		public function get confidence():String
		{
			return _confidence;
		}
		/**
		 * @private
		 */
		public function set confidence(value:String):void
		{
			_confidence = value;
		}
		/**
		 * the precision (ex: 1)
		 */
		public function get precision():Number
		{
			return _precision;
		}
		/**
		 * @private
		 */
		public function set precision(value:Number):void
		{
			_precision = value;
		}
		/**
		 * the address line
		 */
		public function get addressLine():String
		{
			return _addressLine;
		}
		/**
		 * @private
		 */
		public function set addressLine(value:String):void
		{
			_addressLine = value;
		}
		/**
		 * the locality
		 */
		public function get locality():String
		{
			return _locality;
		}
		/**
		 * @private
		 */
		public function set locality(value:String):void
		{
			_locality = value;
		}
		/**
		 * the postal code
		 */
		public function get postalCode():String
		{
			return _postalCode;
		}
		/**
		 * @private
		 */
		public function set postalCode(value:String):void
		{
			_postalCode = value;
		}
		/**
		 * the state
		 */
		public function get state():String
		{
			return _state;
		}
		/**
		 * @private
		 */
		public function set state(value:String):void
		{
			_state = value;
		}
		/**
		 * the country code
		 */
		public function get countryRegion():String
		{
			return _countryRegion;
		}
		/**
		 * @private
		 */
		public function set countryRegion(value:String):void
		{
			_countryRegion = value;
		}
		/**
		 * the formated address
		 */
		public function get formattedAddress():String
		{
			return _formattedAddress;
		}
		/**
		 * @private
		 */
		public function set formattedAddress(value:String):void
		{
			_formattedAddress = value;
		}
	}
}