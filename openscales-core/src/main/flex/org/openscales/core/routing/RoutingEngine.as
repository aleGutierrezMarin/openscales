package org.openscales.core.routing
{
	import org.openscales.core.routing.result.RoutingResult;
	import org.openscales.geometry.basetypes.Location;

	public class RoutingEngine
	{
		protected var _availableTravelModes:Array;
		protected var _availableDistanceUnits:Array;
		protected var _availableAvoidCriterious:Array;
		protected var _availableOptimizeCriterious:Array;
		

		private var _maxSolutions:uint = 1;
		private var _avoidCriterious:Array;
		private var _optimizeCriterious:String=null;
		private var _travelMode:String;
		private var _distanceUnit:String;
		
		public function RoutingEngine()
		{
		}

		/**
		 * available travel modes
		 */
		public function get availableTravelModes():Array
		{
			return _availableTravelModes;
		}
		/**
		 * available distances units
		 */
		public function get availableDistanceUnits():Array
		{
			return _availableDistanceUnits;
		}
		/**
		 * available avoid criterious
		 */
		public function get availableAvoidCriterious():Array
		{
			return _availableAvoidCriterious;
		}
		/**
		 * available optimize criterious
		 */
		public function get availableOptimizeCriterious():Array
		{
			return _availableOptimizeCriterious;
		}
		/**
		 * maximum number of solutions
		 */
		public function get maxSolutions():uint
		{
			return _maxSolutions;
		}
		/**
		 * @private
		 */
		public function set maxSolutions(value:uint):void
		{
			_maxSolutions = value;
		}
		/**
		 * avoid criterious
		 */
		public function get avoidCriterious():Array
		{
			return _avoidCriterious;
		}
		/**
		 * @private
		 */
		public function set avoidCriterious(value:Array):void
		{
			_avoidCriterious = value;
		}
		/**
		 * optimize criterious
		 */
		public function get optimizeCriterious():String
		{
			return _optimizeCriterious;
		}
		/**
		 * @private
		 */
		public function set optimizeCriterious(value:String):void
		{
			_optimizeCriterious = value;
		}
		/**
		 * travel mode used for route calculation
		 */
		public function get travelMode():String
		{
			return _travelMode;
		}
		/**
		 * @private
		 */
		public function set travelMode(value:String):void
		{
			_travelMode = value;
		}
		/**
		 * distance unit
		 */
		public function get distanceUnit():String
		{
			return _distanceUnit;
		}
		/**
		 * @private
		 */
		public function set distanceUnit(value:String):void
		{
			_distanceUnit = value;
		}
		
		/**
		 * compute route for specified locations
		 * 
		 * @param callback the callback function to call when route search ends. It must take a Vector.&lt;RoutingResult&gt; in parameter
		 * @param locations the ordered locations to include in the route, at least 2
		 */
		public function computeRoute(callback:Function, locations:Vector.<Location>):void {
			callback(new Vector.<RoutingResult>());
		}

		

	}
}