package org.openscales.core.search
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.search.result.Address;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * Bing locations V1 api support
	 * based on http://msdn.microsoft.com/en-us/library/ff701715.aspx
	 */
	public class BingSearch extends SearchEngine
	{
		private static var APIURL:String = "http://dev.virtualearth.net/REST/v1/";
		
		private var _key:String = null;
		private var _request:XMLRequest = null;
		private var _callBack:Function = null;
		
		/**
		 * Constructor
		 * @param key the bing api key
		 */
		public function BingSearch(key:String)
		{
			this._key = key;
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function searchByQueryString(callback:Function, queryString:String):void {
			queryString = queryString.replace(/^\s+|\s+$/g, "");
			if(queryString!="")
				this.performRequest(callback,APIURL+"Locations/"+queryString+"?o=json&key="+this._key);
		}
		/**
		 * @inheritDoc
		 */
		override public function reverseGeocode(callback:Function, loc:Location):void {
			loc = loc.reprojectTo(ProjProjection.getProjProjection("EPSG:4326"));
			this.performRequest(callback,APIURL+"Locations/"+loc.lat+","+loc.lon+"?o=json&key="+this._key);
		}
		
		/**
		 * @private
		 * perform request
		 */
		private function performRequest(callback:Function, url:String):void {
			this.clear();
			this._callBack = callback;
			this._request = new XMLRequest(url,this.onSuccess,this.onFailure);
			this._request.send();
		}
		/**
		 * @private
		 * handle success
		 */
		private function onSuccess(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var obj:Object = JSON.decode(loader.data as String) as Object;
			var results:Vector.<Address> = new Vector.<Address>();
			if(obj["resourceSets"] && obj["resourceSets"][0]["resources"]) {
				var ressources:Array = obj["resourceSets"][0]["resources"] as Array;
				var address:Address = null;
				var i:uint = 0;
				for(obj in ressources) {
					obj = ressources[obj];
					address = new Address();
					if(obj["bbox"] && obj["bbox"] is Array) {
						address.bbox = new Bounds(obj["bbox"][1],obj["bbox"][0],obj["bbox"][3],obj["bbox"][2]);
					}
					if(obj["name"])
						address.name = obj["name"].toString();
					if(obj["point"] && obj["point"]["coordinates"] && obj["point"]["coordinates"] is Array)
						address.location = new Location(obj["point"]["coordinates"][1],obj["point"]["coordinates"][0]);
					if(obj["address"]) {
						if(obj["address"]["addressLine"])
							address.addressLine = obj["address"]["addressLine"].toString();
						if(obj["address"]["adminDistrict"])
							address.state = obj["address"]["adminDistrict"].toString();
						if(obj["address"]["countryRegion"])
							address.countryRegion = obj["address"]["countryRegion"].toString();
						if(obj["address"]["formattedAddress"])
							address.formattedAddress = obj["address"]["formattedAddress"].toString();
						if(obj["address"]["locality"])
							address.locality = obj["address"]["locality"].toString();
						if(obj["address"]["postalCode"])
							address.postalCode = obj["address"]["postalCode"].toString();
					}
					if(obj["confidence"])
						address.confidence = obj["confidence"].toString();
					results.push(address);
					++i;
					if(i>=this.maxResults)
						break;
				}
			}
			if(this._callBack!=null)
				this._callBack(results);
			this.clear();
		}
		/**
		 * @private
		 * handle failures
		 */
		private function onFailure(event:Event):void {
			this.clear();
			this._callBack(new Vector.<Address>());
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