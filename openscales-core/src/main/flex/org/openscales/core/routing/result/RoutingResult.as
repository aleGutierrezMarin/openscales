package org.openscales.core.routing.result
{
	import org.openscales.geometry.basetypes.Location;

	public class RoutingResult
	{
		private var _distanceUnit:String;
		private var _durationUnit:String;
		private var _travelDistance:Number;
		private var _travelDuration:Number;
		private var _startLocation:Location;
		private var _endLocation:Location;
		private var _itinerary:Vector.<Location>;
		
		
		public function RoutingResult()
		{
		}

		public function get distanceUnit():String
		{
			return _distanceUnit;
		}

		public function set distanceUnit(value:String):void
		{
			_distanceUnit = value;
		}

		public function get durationUnit():String
		{
			return _durationUnit;
		}

		public function set durationUnit(value:String):void
		{
			_durationUnit = value;
		}

		public function get travelDistance():Number
		{
			return _travelDistance;
		}

		public function set travelDistance(value:Number):void
		{
			_travelDistance = value;
		}

		public function get travelDuration():Number
		{
			return _travelDuration;
		}

		public function set travelDuration(value:Number):void
		{
			_travelDuration = value;
		}

		public function get startLocation():Location
		{
			return _startLocation;
		}

		public function set startLocation(value:Location):void
		{
			_startLocation = value;
		}

		public function get endLocation():Location
		{
			return _endLocation;
		}

		public function set endLocation(value:Location):void
		{
			_endLocation = value;
		}

		public function get itinerary():Vector.<Location>
		{
			return _itinerary;
		}

		public function set itinerary(value:Vector.<Location>):void
		{
			_itinerary = value;
		}


	}
}