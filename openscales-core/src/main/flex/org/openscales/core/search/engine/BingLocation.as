package org.openscales.core.search.engine
{	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.json.GENERICJSON;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.search.result.Address;
	import org.openscales.geometry.basetypes.Location;

	// http://msdn.microsoft.com/en-us/library/ff701710.aspx
	public class BingLocation {
		
		private static var APIURL:String = "http://dev.virtualearth.net/REST/v1/";
		
		public static const LANG_PT_BR:String = "pt-BR";
		public static const LANG_EN_US:String = "en-US";
		
		private var _key:String = null;
		
		private var _request:XMLRequest = null;
		private var _callBack:Function = null;

		
		public var language:String = LANG_PT_BR;
		
		public function BingLocation( key:String ) {
			this._key = key;
		}
		
		private function buildQueryUrl( loc:Location ):String {
			var queryString:String = "o=json";
			queryString += "&key="+this._key;
			queryString += "&c="+this.language;
			queryString += "&includeEntityTypes=Address";
			
			return APIURL+"Locations/"+loc.lat+","+loc.lon+"?"+queryString;
		}
		
		public function getReverse( callbackFn:Function, loc:Location ):void {
			var queryString:String = buildQueryUrl(loc);
			
			trace(queryString);
			this.performRequest( callbackFn, queryString );
		}
		
		private function performRequest( callback:Function, url:String ):void {
			this.clear();
			this._callBack = callback;
			this._request = new XMLRequest(url, this.onSuccess, this.onFailure);
			this._request.send();
		}
		
		private function onFailure(e:Event):void {
			_callBack( null );
		}
		
		private function onSuccess(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			var obj:Object = GENERICJSON.parse(loader.data as String) as Object;
			
			if ( obj[ "statusCode" ] == 200 ) {
		
				var myObj:Object = obj[ "resourceSets" ][0][ "resources" ][0];
				var value:Object = myObj[ "address" ];
				var point:Object = myObj[ "point" ][ "coordinates" ];
				
				var address:Address = new Address();
				address.formattedAddress = value[ "formattedAddress" ];
				address.addressLine = value[ "addressLine" ];
				address.countryRegion = value[ "countryRegion" ];
				address.locality = value[ "locality" ];
				address.postalCode = value[ "postalCode" ];
				address.state = value[ "adminDistrict" ];
				address.name = myObj[ "name" ];
				address.confidence = myObj[ "confidence" ];
				address.location = new Location( point[1], point[0] );
//				address.bbox = myObj[ "bbox" ];
				address.precision = 0;
				
				_callBack( address );
				
			} else {
				
				_callBack( null );
				
			}
		 
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
		
	}
}