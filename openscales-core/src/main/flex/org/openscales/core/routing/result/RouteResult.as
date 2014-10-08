package org.openscales.core.routing.result {
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;

	/*
	* http://msdn.microsoft.com/en-us/library/ff701718.aspx
	*/
	public class RouteResult {
		
		public var bounds:Bounds;
		
		public var startPoint:Location;
		public var endPoint:Location;
		
		public var totalDistance:Number;
		public var totalDuration:Number; // secs
		public var totalDurationTraffic:Number; // secs
		
		public var directions:Vector.<RouteDirection>;
		
		public var route:LineString;
		
		public var statusCode:Number;
		
		public function RouteResult() {
		}
		
		
	} // class
	
} // pkg