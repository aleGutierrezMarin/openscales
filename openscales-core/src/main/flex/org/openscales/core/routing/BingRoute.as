package org.openscales.core.routing
{
	import org.openscales.core.routing.result.RouteDirection;
	import org.openscales.core.routing.result.RouteResult;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;

	/**
	 * Bing route api suuport
	 * based on http://msdn.microsoft.com/en-us/library/ff701717.aspx
	 */
	public class BingRoute {
		
		private static var APIURL:String = "http://dev.virtualearth.net/REST/v1/";
		
		public static const OPTIMIZATION_DISTANCE:String = "distance";
		public static const OPTIMIZATION_TIME:String = "time";
		public static const OPTIMIZATION_TIME_AND_TRAFFIC:String = "timeWithTraffic";
		public static const OPTIMIZATION_TIME_AVOID_CLOUSURE:String = "timeAvoidClosure";
		
		public static const TRAVEL_MODE_DRIVING:String = "Driving";
		public static const TRAVEL_MODE_WALKING:String = "Walking";
		public static const TRAVEL_MODE_TRANSIT:String = "Transit";
		
		public static const DISTANCE_UNIT_KM:String = "km";
		public static const DISTANCE_UNIT_MILES:String = "mi";
		
		public static const LANG_PT_BR:String = "pt-BR";
		public static const LANG_EN_US:String = "en-US";
		
		
		private var _key:String = null;
		private var _request:XMLRequest = null;
		private var _callBack:Function = null;
		
		private var routePathOutput:String = "Points";
		protected var maxSolutions:uint = 1;
		
		// http://msdn.microsoft.com/en-us/library/hh441729.aspx
		public var language:String = LANG_PT_BR;
		
		public var avoid_highway:Boolean = false;
		public var avoid_tolls:Boolean = false;
		public var minimize_highways:Boolean = false;
		public var minimize_tolls:Boolean = false;
		
		public var optimization:String = null;
		public var tolerance:Number = 0.00000344978;
		public var distanceUnit:String = DISTANCE_UNIT_KM;
		public var travelMode:String = TRAVEL_MODE_DRIVING;
		
		public function BingRoute( key:String ) {
			this._key = key;
		}
		
		private function buildQueryUrl():String {
			
			var queryString:String = "o=json";
			queryString += "&key="+this._key;
			queryString += "&rpo="+this.routePathOutput;
			queryString += "&tl="+this.tolerance;
			queryString += "&du="+this.distanceUnit;
			queryString += "&maxSolns="+this.maxSolutions;
			queryString += "&travelMode="+this.travelMode;
			queryString += "&c="+this.language;
			
			if ( avoid_highway && avoid_tolls ) {
				queryString += "&avoid=highways,tolls";
			} else if ( avoid_tolls && !minimize_tolls ) {
				queryString += "&avoid=tolls";
			} else if ( avoid_highway && !minimize_highways ) {
				queryString += "&avoid=highways";
			} else if ( minimize_highways && minimize_tolls && !avoid_highway && !avoid_tolls ) {
				queryString += "&avoid=minimizeHighways,minimizeTolls";
			} else if ( minimize_highways && !avoid_highway ) {
				queryString += "&avoid=minimizeHighways";
			} else if ( minimize_tolls && !avoid_tolls ) {
				queryString += "&avoid=minimizeTolls";
			}
			
			if ( optimization != null ) {
				queryString += "&optmz="+optimization;
			}
			
			return APIURL+"Routes/"+travelMode+"?"+queryString;
		}
		
		public function getRouteByReverseGeocode( callbackFn:Function, locations:Vector.<String> ):void {
			var queryString:String = buildQueryUrl();
			
			var contador:uint = 0;
			for each ( var loc:String in locations ) {
				if ( ( contador == 0 ) || ( contador == ( locations.length-1) ) ) {
					queryString += "&wp.";
				} else {
					queryString += "&vwp.";
				}
				
				queryString += contador+"="+loc;
				++contador;
			}
			
//			trace(queryString);
			this.performRequest( callbackFn, queryString );
		}
		
		public function getRouteByPoints( callbackFn:Function, waypoints:Vector.<Location> ):void {
			var queryString:String = buildQueryUrl();
			
			var contador:uint = 0;
			for each ( var l:Location in waypoints ) {
				if ( ( contador == 0 ) || ( contador == ( waypoints.length-1) ) ) {
					queryString += "&wp.";
				} else {
					queryString += "&vwp.";
				}
				
				queryString += contador+"="+l.lat+","+l.lon;
				++contador;
			}
			
//			trace(queryString);
			this.performRequest( callbackFn, queryString );
		}
		
		private function performRequest( callback:Function, url:String ):void {
			this.clear();
			this._callBack = callback;
			this._request = new XMLRequest(url, this.onSuccess, this.onFailure);
			this._request.send();
		}
		
		private function clear():void {
			if(this._request != null) {
				this._request.destroy();
				this._request = null;
			}
			if(this._callBack != null) {
				this._callBack = null;
			}
		}
		
		private function onFailure(e:Event):void {

		}
		
		private function onSuccess(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			var obj:Object = JSON.decode(loader.data as String) as Object;
			
			var result:RouteResult = new RouteResult();
			result.statusCode = obj[ "statusCode" ];
			
			if ( result.statusCode == 200 ) {
				
				var resource:Object = obj[ "resourceSets" ][0][ "resources" ][0];
				result.totalDistance = resource[ "travelDistance" ];
				result.totalDuration = resource[ "travelDuration" ];
				result.totalDurationTraffic = resource[ "travelDurationTraffic" ];
				
				var bbox:Object = resource[ "bbox" ];
				result.bounds = new Bounds( bbox[1], bbox[0], bbox[3], bbox[2] );
				
				var legs:Object = resource[ "routeLegs" ][0];
				
				result.startPoint = new Location( legs[ "actualStart" ][ "coordinates" ][1], legs[ "actualStart" ][ "coordinates" ][0] );
				result.endPoint = new Location( legs[ "actualEnd" ][ "coordinates" ][1], legs[ "actualEnd" ][ "coordinates" ][0] );
				
//				{
//					"compassDirection": "northeast",
//					"details": [
//						{
//							"compassDegrees": 47,
//							"endPathIndices": [
//								3
//							],
//							"maneuverType": "DepartStart",
//							"mode": "Driving",
//							"names": [
//								"Rua Bento da Rocha"
//							],
//							"roadType": "Street",
//							"startPathIndices": [
//								0
//							]
//						}
//					],
//					"exit": "",
//					"iconType": "Auto",
//					"instruction": {
//						"formattedText": null,
//						"maneuverType": "DepartStart",
//						"text": "Depart Rua Bento da Rocha toward Rua Comendador Jo\u00e3o Cintra"
//					},
//					"maneuverPoint": {
//						"type": "Point",
//						"coordinates": [
//							-22.436103,
//							-46.822984
//						]
//					},
//					"sideOfStreet": "Unknown",
//					"tollZone": "",
//					"towardsRoadName": "Rua Comendador Jo\u00e3o Cintra",
//					"transitTerminus": "",
//					"travelDistance": 0.196,
//					"travelDuration": 34,
//					"travelMode": "Driving"
//				},
				
				var itinerary:Object = legs[ "itineraryItems" ];
				result.directions = new Vector.<RouteDirection>(); 
				
				for each ( var dir:Object in itinerary ) {
					var rd:RouteDirection = new RouteDirection();
					rd.hasTolls = dir[ "tollZone" ];
					rd.towardsRoadName = dir[ "towardsRoadName" ];
					rd.travelDistance = dir[ "travelDistance" ];
					rd.travelDuration = dir[ "travelDuration" ];
					rd.travelMode = dir[ "travelModel" ];
					rd.direction = dir[ "compassDirection" ];
					
					if ( dir[ "instruction" ] && dir[ "instruction" ][ "text" ] ) {
						rd.instruction = dir[ "instruction" ][ "text" ];
					}
					
					if ( dir[ "maneuverPoint" ] && dir[ "maneuverPoint" ][ "coordinates" ] ) {
						rd.maneuverPoint = new Location( dir[ "maneuverPoint" ][ "coordinates" ][1], dir[ "maneuverPoint" ][ "coordinates" ][0] ); 
					}
				}
				
				if ( resource[ "routePath" ] && resource[ "routePath" ][ "line" ] && resource[ "routePath" ][ "line" ][ "coordinates" ] ) {
					var path:Object = resource[ "routePath" ][ "line" ][ "coordinates" ];
					
					result.route = new LineString(new Vector.<Number>);
					for each ( var coord:Object in path ) {
						result.route.addPoint( coord[1], coord[0] );
					} // for
				}
				
			} // if 200
			
			_callBack( result );
			
		} // function
		
	}
}