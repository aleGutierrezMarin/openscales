package org.openscales.core.routing
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.routing.result.RoutingResult;
	import org.openscales.geometry.basetypes.Location;

	public class BingRouteEngine extends RoutingEngine
	{
		private var _key:String;
		private var _request:XMLRequest = null;
		private var _callBack:Function = null;
		
		/**
		 * @param key Bing map api key
		 */
		public function BingRouteEngine(key:String)
		{
			this._key = key;
			this._availableAvoidCriterious = new Array("highways","tolls","minimizeHighways","minimizeTolls");
			this._availableDistanceUnits = new Array("km","mi");
			this._availableOptimizeCriterious = new Array("time","distance","timeWithTraffic");
			this._availableTravelModes = new Array("Driving","Walking","Transit");
			this.optimizeCriterious = "time";
			this.distanceUnit="km"
			this.travelMode = "Driving;"
			super();
		}
		/**
		 * @inheritDoc
		 */
		override public function computeRoute(callback:Function, locations:Vector.<Location>):void {
			this.clear();
			var i:uint = locations.length;
			if(!locations||j<2) {
				callback(new Vector.<RoutingResult>());
			}
			this._callBack = callback;
			
			if(this.maxSolutions>3)
				this.maxSolutions=3;
			
			var url:String = "http://dev.virtualearth.net/REST/V1/Routes?o=xml&key="+this._key+
				"&maxSolns="+this.maxSolutions+"&du="+this.distanceUnit+"&optmz="+this.optimizeCriterious;
			if(this.avoidCriterious && this.avoidCriterious.length>0)
				url+="&avoid="+this.avoidCriterious.join(",");
			
			var j:uint = 0;
			var loc:Location;
			for(;j<i;++j) {
				loc = locations[j].reprojectTo("EPSG:4326");
				url+="&wp."+j+"="+loc.lat+","+loc.lon;
			}
			this._request = new XMLRequest(url,this.onSuccess,this.onFailure);
			this._request.send();
		}
		/**
		 * @private
		 * handle success
		 */
		private function onSuccess(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultXML:XML = new XML(loader.data);
			var results:Vector.<RoutingResult> = new Vector.<RoutingResult>();
			var routes:XMLList = resultXML..*::Route;
			var i:uint = routes.length();
			var j:uint = 0;
			var k:uint;
			var l:uint;
			var route:XML;
			var node:XML;
			var nodeList:XMLList;
			var result:RoutingResult;
			for(;j<i;++j) {
				route = routes[0];
				result = new RoutingResult();
				result.distanceUnit = route..*::DistanceUnit[0].text();
				result.durationUnit = route..*::DurationUnit[0].text();
				result.travelDistance = Number(route..*::TravelDistance[0].text());
				result.travelDuration = Number(route..*::TravelDuration[0].text());
				node = route..*::ActualStart[0];
				result.startLocation = new Location(Number(node..*::Longitude[0].text()), Number(node..*::Latitude[0].text()));
				node = route..*::ActualEnd[0];
				result.startLocation = new Location(Number(node..*::Longitude[0].text()), Number(node..*::Latitude[0].text()));
				result.itinerary = new Vector.<Location>();
				nodeList = route..*::ItineraryItem;
				k = nodeList.length();
				for(l=0;l<k;++l) {
					node = nodeList[l];
					result.itinerary.push(new Location(Number(node..*::Longitude[0].text()), Number(node..*::Latitude[0].text())));
				}
				results.push(result);
			}
			this._callBack(results);
		}
		/**
		 * @private
		 * handle failures
		 */
		private function onFailure(event:Event):void {
			this.clear();
			this._callBack(new Vector.<RoutingResult>());
		}
		
		/**
		 * @private
		 * clear past requests
		 */
		private function clear():void {
			if(this._request != null) {
				this._request.destroy();
				this._request = null;
			}
			if(this._callBack != null) {
				this._callBack = null;
			}
		}
	}
}