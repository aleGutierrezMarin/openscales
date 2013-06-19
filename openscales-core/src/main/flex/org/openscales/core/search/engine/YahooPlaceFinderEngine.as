package org.openscales.core.search.engine
{
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.search.result.Address;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjProjection;
  import org.openscales.core.json.GENERICJSON;

	/**
	 * This engine provide methods to interrogate Yahoo PlaceFinder API.
	 * 
	 * @see http://developer.yahoo.com/geo/placefinder/
	*/
	public class YahooPlaceFinderEngine extends SearchEngine
	{
		private var _url:String = "http://where.yahooapis.com/geocode";
		private var _appID:String;
		private var _request:XMLRequest = null;
		private var _callBack:Function = null;
		
		
		/**
		 * @param appID Your Yahoo application ID touse with the PlaceFinder API
		 */ 
		public function YahooPlaceFinderEngine(appID:String="")
		{
			super();
			this._appID = appID;
		}

		/**
		 * This method sends a query to the PlaceFinder API using the <code>location</code> parameter set to <code>queryString</code> value
		 * 
		 * @param callback A function to execute when research has returned
		 * @param queryString The query to send
		 */
		override public function searchByQueryString(callback:Function, queryString:String):void{
			queryString = queryString.replace(/^\s+|\s+$/g, "");//Removing trailing and beginning space
			queryString = queryString.replace(/\s/g,'+');// Replacing every other space by + character
			if(queryString!="")
				this.performRequest(callback,_url+"?location="+queryString+"&flags=JX&appid="+this._appID);
		}
		
		/**
		 * This method sends a query to the PlaceFinder API using the <code>location</code> parameter set to <code>loc</code> lat/lon value
		 * 
		 * @param callback A function to execute when research has returned
		 * @param loc The location to reverse
		 */
		override public function reverseGeocode(callback:Function, loc:Location):void{
			loc = loc.reprojectTo(ProjProjection.getProjProjection("EPSG:4326"));
			this.performRequest(callback,_url+"?location="+loc.lat.toString()+"+"+loc.lon.toString()+"&flags=JX&gflags=R&appid="+this._appID);
		}
		
		/**
		 * @private
		 * 
		 * Perfom an XML request
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
			var obj:Object = GENERICJSON.parse(loader.data as String) as Object;
			var addresses:Vector.<Address> = new Vector.<Address>();
			var top:Number;
			var bottom:Number;
			var left:Number;
			var right:Number;
			var address:Address;
			var i:uint = 0;
			if(obj['ResultSet']['Results']){
				var results:Array = obj['ResultSet']['Results'] as Array;
				for each(var result:Object in results){
					address = new Address();
					if(result['boundingbox']){
						top = result['boundingbox']['north'];
						bottom = result['boundingbox']['south'];
						left = result['boundingbox']['west'];
						right = result['boundingbox']['east'];
						address.bbox = new Bounds(left,bottom,right,top,ProjProjection.getProjProjection("EPSG:4326"));
					}
					if(result['name']) address.name = result['name'].toString();
					if(result['longitude'] && result['latitude']) address.location = new Location(result['longitude'],result['latitude'], ProjProjection.getProjProjection("ESPG:4326"));
					
					address.addressLine = "";
					if(result['line1']){
						address.addressLine = result['line1'].toString()+" ";
					}
					if(result['line2']){
						address.addressLine += result['line2'].toString()+" ";
					}
					if(result['line3']){
						address.addressLine += result['line3'].toString()+" ";
					}
					if(result['line4']){
						address.addressLine += result['line4'].toString()+" ";
					}
					
					address.formattedAddress = address.addressLine;
					
					if(result['city']){
						address.locality = result['city'].toString();
					}
					if(result['uzip']){
						address.postalCode = result['uzip'].toString();
					}
					if(result['country']){
						address.countryRegion = result['country'].toString();
					}
					if(result['state']){
						address.state = result['state'].toString();
					}
					
					addresses.push(address);
					++i;
					if(i>=this.maxResults)
						break;
				}
			}
			if(this._callBack!=null)
				this._callBack(addresses);
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
		
		/**
		 * Yahoo application ID to use with the PlaceFinder API
		 */ 
		public function get appID():String
		{
			return _appID;
		}

		/**
		 * @private
		 */ 
		public function set appID(value:String):void
		{
			_appID = value;
		}

		/**
		 * The PlaceFinder API URL
		 * 
		 * @default http://where.yahooapis.com/geocode
		 */ 
		public function get url():String
		{
			return _url;
		}

		/**
		 * @private
		 */ 
		public function set url(value:String):void
		{
			_url = value;
		}

	}
}