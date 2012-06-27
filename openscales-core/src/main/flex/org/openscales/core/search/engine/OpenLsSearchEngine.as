package org.openscales.core.search.engine
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import mx.collections.ArrayCollection;
	
	import org.openscales.core.request.OpenLSRequest;
	import org.openscales.core.search.result.Address;
	import org.openscales.core.search.result.Confidence;
	import org.openscales.core.utils.UID;
	import org.openscales.geometry.basetypes.Location;

	public class OpenLsSearchEngine extends SearchEngine
	{
		private var _serviceUrl:String = null;
		private var _version:String = null;
		private var _countryCode:String = null;
		private var _srsName:String = null;
		private var _req:OpenLSRequest = null;
		
		public function OpenLsSearchEngine(serviceUrl:String, countryCode:String, srsName:String="epsg:4326", version:String="1.2")
		{
			super();
			
			this._serviceUrl = serviceUrl;
			this._version = version;
			this._countryCode = countryCode;
			this._srsName = srsName;
		}
		
		/**
		 * reverse geocode a location
		 * 
		 * @param callback the callback function to wall when search ends. It must take a Vector.&lt;Address&gt; in parameter
		 * @param loc the location
		 */
		override public function reverseGeocode(callback:Function, loc:Location):void {
			if(callback==null)
				return;
			if(this._req)
				this._req.destroy();
			this._req = new OpenLSRequest(this._serviceUrl,function(event:Event):void {
				if(callback!=null) {
					callback(parseResponse(new XML((event.target as URLLoader).data)));
				}
			});
			this._req.defineReverseSearch(UID.gen_uid(), new Vector.<String>, loc.reprojectTo("EPSG:4326"), this._srsName, this.maxResults, this.version);
			this._req.security = this.security;
			this._req.send();
		}
		
		/**
		 * search with a querystring
		 * 
		 * @param callback the callback function to wall when search ends. It must take a Vector.&lt;Address&gt; in parameter
		 * @param queryString the queryString
		 */
		override public function searchByQueryString(callback:Function, queryString:String):void {
			if(callback==null)
				return;
			if(this._req)
				this._req.destroy();
			this._req = new OpenLSRequest(this._serviceUrl,function(event:Event):void {
				if(callback!=null) {
					callback(parseResponse(new XML((event.target as URLLoader).data)));
				}
			});
			this._req.defineSimpleSearch(UID.gen_uid(),queryString,this._countryCode, this._srsName, this.maxResults, this.version);
			this._req.security = this.security;
			this._req.send();
		}
		
		private function parseResponse(xml:XML):Vector.<Address> {
			var results:Vector.<Address> = new Vector.<Address>();
			if(xml) {
				var xmlList:XMLList = OpenLSRequest.resultsList(xml);
				if (xmlList && xmlList.length()>0) {
					var resultsAc:ArrayCollection = new ArrayCollection(OpenLSRequest.resultsListtoArray(xmlList, this.version));
					if (resultsAc.length > 0) {
						var i:int = resultsAc.length-1;
						var addr:Address;
						for (i; i>=0; --i) {
							addr = new Address();
							results.push(addr);
							addr.location = new Location(parseFloat(resultsAc[i].lon),
								parseFloat(resultsAc[i].lat),
								"EPSG:4326");
							
							addr.precision = parseFloat(resultsAc[i].accuracy);
							if(addr.precision>=0.9)
								addr.confidence = Confidence.HIGH;
							else if(addr.precision>=0.75)
								addr.confidence = Confidence.MEDIUM;
							else
								addr.confidence = Confidence.LOW;
							
							addr.locality = resultsAc[i].municipality;
							addr.postalCode = resultsAc[i].postalCode;
							addr.addressLine = resultsAc[i].number+" "+resultsAc[i].street;
						}
					}
				}
			}
			this._req.destroy();
			this._req = null;
			return results;
		}
		

		/**
		 * Service url
		 */
		public function get serviceUrl():String
		{
			return _serviceUrl;
		}
		/**
		 * @private
		 */
		public function set serviceUrl(value:String):void
		{
			_serviceUrl = value;
		}
		
		/**
		 * OpenLS version
		 */
		public function get version():String
		{
			return _version;
		}
		/**
		 * @private
		 */
		public function set version(value:String):void
		{
			_version = value;
		}

		/**
		 * srsName
		 */
		public function get srsName():String
		{
			return _srsName;
		}
		/**
		 * @private
		 */
		public function set srsName(value:String):void
		{
			_srsName = value;
		}

	}
}