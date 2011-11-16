package org.openscales.core.request
{
	import com.adobe.serialization.json.JSON;
	
	import org.openscales.core.utils.Trace;
	import org.openscales.core.utils.UID;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * OpenLSRequest
	 */
	public class OpenLSRequest extends XMLRequest
	{
		private var _id:String = "";
		private var _srsName:String = null;
		private var _maximumResponses:uint = 10;
		private var _freeFormAddress:String = "";
		private var _number:String = "";
		private var _street:String = "";
		private var _postalCode:String = "";
		private var _city:String = "";
		private var _countryCode:String = "";
		private var _version:String = "1.2";
		private var _location:Location = null;
		private var _circleCenter:Location = null;
		private var _circleRadius:Number = 0;
		private var _bounds:Bounds = null;
		private var _reverseMode:String = "point";

		private var _isValidPostalCode:Function = null;
		
		/**
		 * @constructor
		 * 
		 * For the onComplete function, the result of the OpenLS request is
		 * obtained like this:
		 * var xmlString:String = (event.target as URLLoader).data as String;
		 */
		public function OpenLSRequest(url:String, onComplete:Function, onFailure:Function=null) {
			super(url, onComplete, onFailure);
			this.postContentType = "text/plain";
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
		 * Getter and setter of the id of the request.
		 * Default value is "".
		 */
		public function get id():String {
			return this._id;
		}
		public function set id(value:String):void {
			this._id = (value) ? value : "";
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of the SRS name.
		 */
		public function get srsName():String {
			return this._srsName;
		}
		public function set srsName(value:String):void {
			this._srsName = (value) ? value : "";
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of the maximum number of responses.
		 */
		public function get maximumResponses():uint {
			return this._maximumResponses;
		}
		public function set maximumResponses(value:uint):void {
			this._maximumResponses = value;
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of the free form address of the request.
		 * Default value is "".
		 */
		public function get freeFormAddress():String {
			return this._freeFormAddress;
		}
		public function set freeFormAddress(value:String):void {
			this._freeFormAddress = (value) ? value : "";
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of the building number of the request.
		 * Default value is "".
		 */
		public function get number():String {
			return this._number;
		}
		public function set number(value:String):void {
			this._number = (value) ? value : "";
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of the street of the request.
		 * Default value is "".
		 */
		public function get street():String {
			return this._street;
		}
		public function set street(value:String):void {
			this._street = (value) ? value : "";
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of the postal code of the request.
		 * Default value is "".
		 */
		public function get postalCode():String {
			return this._postalCode;
		}
		public function set postalCode(value:String):void {
			var pc:String = (value) ? value : "";
			if (this.isValidPostalCode != null) {
				if (! this.isValidPostalCode(pc)) {
					Trace.error("OpenLSRequest - set postalCode: invalid value \""+value+"\"");
					return;
				}
			}
			this._postalCode = pc;
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of the function that checks if a postal code is
		 * valid or not.
		 */
		public function get isValidPostalCode():Function {
			return this._isValidPostalCode;
		}
		public function set isValidPostalCode(value:Function):void {
			this._isValidPostalCode = value;
		}
		
		/**
		 * Getter and setter of the city of the request.
		 * Default value is "".
		 */
		public function get city():String {
			return this._city;
		}
		public function set city(value:String):void {
			this._city = (value) ? value : "";
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of the country code of the request.
		 */
		public function get countryCode():String {
			return this._countryCode;
		}
		public function set countryCode(value:String):void {
			this._countryCode = value;
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Getter and setter of reverse mode.
		 */
		public function get reverseMode():String {
			return this._reverseMode;
		}
		public function set reverseMode(value:String):void {
			this._reverseMode = value;
			// Update the content of the request
			this.postContent = this.createReverseContent();
		}
		
		/**
		 * Getter and setter of location.
		 */
		public function get location():Location {
			return this._location;
		}
		public function set location(value:Location):void {
			this._location = value;
			// Update the content of the request
			this.postContent = this.createReverseContent();
		}
		
		/**
		 * Getter and setter of circle center.
		 */
		public function get circleCenter():Location {
			return this._circleCenter;
		}
		public function set circleCenter(value:Location):void {
			this._circleCenter = value;
			this._reverseMode = "circle";
			// Update the content of the request
			this.postContent = this.createReverseContent();
		}
		
		/**
		 * Getter and setter of circle radius.
		 */
		public function get circleRadius():Number {
			return this._circleRadius;
		}
		public function set circleRadius(value:Number):void {
			this._circleRadius = value;
			this._reverseMode = "circle";
			// Update the content of the request
			this.postContent = this.createReverseContent();
		}
		
		/**
		 * Getter and setter of bounds.
		 */
		public function get bounds():Bounds {
			return this._bounds;
		}
		public function set bounds(value:Bounds):void {
			this._bounds = value;
			this._reverseMode = "bounds";
			// Update the content of the request
			this.postContent = this.createReverseContent();
		}
		
		/**
		 * Define quickly all the fields of an OpenLS request.
		 * @param id
		 * @param freeFormAddress
		 * @param number
		 * @param street
		 * @param postalCode
		 * @param city
		 * @param countryCode
		 * @param srsName
		 * @param maximumResponses
		 * @param version
		 */
		public function defineSearch(id:String, freeFormAddress:String, number:String, street:String, postalCode:String, city:String, countryCode:String, srsName:String, maximumResponses:uint, version:String = "1.2"):void {
			this.id = id;
			this.freeFormAddress =freeFormAddress;
			this.number = number;
			this.street = street;
			this.postalCode = postalCode;
			this.city = city;
			this.countryCode = countryCode;
			this.srsName = srsName;
			this.maximumResponses = maximumResponses;
			this.version = version;
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Define quickly the fields of a simple OpenLS request.
		 * @param id
		 * @param freeFormAddress
		 * @param countryCode
		 * @param srsName
		 * @param maximumResponses
		 * @param version
		 */
		public function defineSimpleSearch(id:String, freeFormAddress:String, countryCode:String, srsName:String, maximumResponses:uint, version:String = "1.2"):void {
			this.id = id;
			this.freeFormAddress =freeFormAddress;
			this.countryCode = countryCode;
			this.srsName = srsName;
			this.maximumResponses = maximumResponses;
			this.version = version;
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Define quickly the fields of an advanced OpenLS request.
		 * @param id
		 * @param freeFormAddress
		 * @param number
		 * @param street
		 * @param postalCode
		 * @param city
		 * @param countryCode
		 * @param srsName
		 * @param maximumResponses
		 * @param version
		 */
		public function defineAdvancedSearch(id:String, number:String, street:String, postalCode:String, city:String, countryCode:String, srsName:String, maximumResponses:uint, version:String = "1.2"):void {
			this.id = id;
			this.number = number;
			this.street = street;
			this.postalCode = postalCode;
			this.city = city;
			this.countryCode = countryCode;
			this.srsName = srsName;
			this.maximumResponses = maximumResponses;
			this.version = version;
			// Update the content of the request
			this.postContent = this.createContent();
		}
		
		/**
		 * Define quickly the fields of a reverse OpenLS request.
		 * @param id
		 * @param location
		 * @param srsName
		 * @param maximumResponses
		 * @param version
		 */
		public function defineReverseSearch(id:String, location:Location, srsName:String, maximumResponses:uint, version:String = "1.2"):void {
			this.id = id;
			this.location = location;
			this.srsName = srsName;
			this.maximumResponses = maximumResponses;
			this.version = version;
			// Update the content of the request
			this.postContent = this.createReverseContent();
		}
		
		/**
		 * Define quickly the fields of a reverse OpenLS request, with a circle constraint.
		 * @param id
		 * @param location
		 * @param circleCenter
		 * @param circleRadius
		 * @param srsName
		 * @param maximumResponses
		 * @param version
		 */
		public function defineReverseSearchInCircle(id:String, location:Location, circleCenter:Location, circleRadius:Number, srsName:String, maximumResponses:uint, version:String = "1.2"):void {
			this.id = id;
			this.location = location;
			this.circleCenter = circleCenter;
			this.circleRadius = circleRadius;
			this.srsName = srsName;
			this.maximumResponses = maximumResponses;
			this.version = version;
			// Update the content of the request
			this.postContent = this.createReverseContent();
		}
		
		/**
		 * Define quickly the fields of a reverse OpenLS request, with a bounds constraint.
		 * @param id
		 * @param location
		 * @param bounds
		 * @param srsName
		 * @param maximumResponses
		 * @param version
		 */
		public function defineReverseSearchInBounds(id:String, location:Location, bounds:Bounds, srsName:String, maximumResponses:uint, version:String = "1.2"):void {
			this.id = id;
			this.location = location;
			this.bounds = bounds;
			this.srsName = srsName;
			this.maximumResponses = maximumResponses;
			this.version = version;
			// Update the content of the request
			this.postContent = this.createReverseContent();
		}
		
		/**
		 * Create the content of the request using the specified fields.
		 * @return a String describing the content of the request.
		 */
		private function createContent():String {
			if (!this.id || this.id=="") {
				this.id = UID.gen_uid(); 
			}
			var request:String = this.createRequestHeader();
			request += '<Request maximumResponses="'+this.maximumResponses+'" methodName="GeocodeRequest" requestID="'+this.id+'" version="'+this._version+'">';
			request += '<GeocodeRequest>';
			
			if (this.freeFormAddress) {
				request += '<Address countryCode="' + this.countryCode + '">';
				request += '<freeFormAddress>' + this.freeFormAddress + '</freeFormAddress>';
				request += '</Address>';
			}
			else {
				request += '<Address countryCode="' + this.countryCode + '">';
				request += '<StreetAddress><Building number="' + this.number  + '"/>'; 
				request += '<Street>' + this.street + '</Street></StreetAddress>';
				request += '<Place type="Municipality">' + this.city + '</Place>';
				request += '<PostalCode>' + this.postalCode + '</PostalCode></Address>';				
			}
			request += '</GeocodeRequest></Request></XLS>';
			return request;
		}
		
		/**
		 * Create the content of the reverse request using the specified fields.
		 * @return a String describing the content of the reverse request.
		 */
		private function createReverseContent():String {
			if (!this.id || this.id=="") {
				this.id = UID.gen_uid(); 
			}
			var request:String = this.createRequestHeader();
			request += '<Request maximumResponses="'+this.maximumResponses+'" methodName="ReverseGeocodeRequest" requestID="'+this.id+'" version="'+this._version+'">';
			request += '<ReverseGeocodeRequest><ReverseGeocodePreference>StreetAddress</ReverseGeocodePreference>';
			request += '<Position><gml:Point><gml:pos>'+this._location.lon+' '+this._location.lat+'</gml:pos></gml:Point>';
			
			switch (this._reverseMode) {
				case "point":
					break;
				case "circle":
					request += '<gml:CircleByCenterPoint>';
					request += '<gml:pos>'+this._circleCenter.lon+' '+this._circleCenter.lat+'</gml:pos>';
					request += '<gml:radius>'+this._circleRadius+'</gml:radius>';
				    request += '</gml:CircleByCenterPoint>';
					break;
				case "bounds":
					request += '<gml:Polygon><gml:exterior><gml:LinearRing>';
					request += '<gml:pos>'+this._bounds.left+' '+this._bounds.bottom+'</gml:pos>';
					request += '<gml:pos>'+this._bounds.right+' '+this._bounds.bottom+'</gml:pos>';
					request += '<gml:pos>'+this._bounds.right+' '+this._bounds.top+'</gml:pos>';
					request += '<gml:pos>'+this._bounds.left+' '+this._bounds.top+'</gml:pos>';
					request += '</gml:LinearRing></gml:exterior></gml:Polygon>';
					break;
				default:
					break;
			}
			request += '</Position></ReverseGeocodeRequest></Request></XLS>';
			return request;
		}
		
		private function createRequestHeader():String {
			var header:String = '';
			header += '<?xml version="1.0" encoding="UTF-8"?>';
			header += '<XLS xmlns:gml="http://www.opengis.net/gml" xmlns="http://www.opengis.net/xls" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="'+this._version+'"  xsi:schemaLocation="http://www.opengis.net/xls http://schemas.opengis.net/ols/1.2/olsAll.xsd">';
			if (srsName && srsName != "") {
				header += '<RequestHeader srsName="'+this.srsName+'"/>';
			}
			else {
				header += '<RequestHeader/>';
			}
			return header;
		}
		
		/**
		 * Get the XML list of geocoded addresses
		 * @param response XML document describing the OpenLS response
		 * @return the XML list of geocoded addresses
		 */
		static public function resultsList(response:XML):XMLList {
			var xls:Namespace = new Namespace("xls", "http://www.opengis.net/xls");
			var result:XMLList = new XMLList();
			try {
				if (response.xls::Response.xls::ReverseGeocodeResponse.length()>0)
					result = response.xls::Response.xls::ReverseGeocodeResponse;
				else
					if (response.xls::Response.xls::GeocodeResponse.xls::GeocodeResponseList.length()>0)
						result = response.xls::Response.xls::GeocodeResponse.xls::GeocodeResponseList; 
			}
			catch (e:Error) {
				Trace.error("OpenLSRequest - Error while reading XML response");
			}
			return result;
		}
		
		/**
		 * Get the number of geocoded addresses
		 * @param response XML document describing the OpenLS response
		 * @return the number of geocoded addresses
		 */
		static public function resultsNumber(response:XML):Number {
			
			var result:Number = 0;
			try {
				// TODO: vérifier le bon fonctionnement du if
				if (OpenLSRequest.resultsList(response).hasOwnProperty("numberOfGeocodedAddresses"))
					result = OpenLSRequest.resultsList(response).@numberOfGeocodedAddresses.toString() as Number;
				else
					result = OpenLSRequest.resultsList(response).length();
			}
			catch (e:Error) {
				Trace.error("OpenLSRequest - Error while reading XML response");
			}
			return result;
		}
		
		/**
		 * Transform a list of results of a geocoding into an Array
		 * describing which geocoded address by its "accuracy",
		 * "lat", "lon", "number", "street", "postalCode", "city" and "countryCode".
		 * @param resultsList XML document describing the results of a geocoding
		 * @return a Array of String
		 */
		static public function resultsListtoArray(resultsList:XMLList, version:String = "1.2"):Array {
			var results:Array = new Array();
			try {
				switch (resultsList.localName()) {
					case "GeocodeResponseList":
						results = parseGeocodeResponse(resultsList, version);
						break;
					case "ReverseGeocodeResponse":
						results = parseReverseGeocodeResponse(resultsList, version);
						break;
					default:
						break;
				}
			}
			catch (e:Error) {
				Trace.error("OpenLSRequest - Error while reading XMLList response");
			}
			return results;
		}
		
		static private function parseGeocodeResponse(resultsList:XMLList, version:String = "1.2"): Array {
			var xls:Namespace = new Namespace("xls", "http://www.opengis.net/xls");
			var gml:Namespace = new Namespace("gml", "http://www.opengis.net/gml");
			var results:Array = new Array(), result:Object, position:Array;
			
			for each (var gr:XML in resultsList.xls::GeocodedAddress) {
				result = new Object();
				position = gr.gml::Point.gml::pos.toString().split(' ');
				var srsName:String = "EPSG:4326";
				if (gr.gml::Point.gml::pos.@srsName && gr.gml::Point.gml::pos.@srsName.toString()!="") {
					srsName = gr.gml::Point.gml::pos.@srsName.toString().toUpperCase();
				}
				var latlon:Boolean = false;
				if(version == "1.2") {
					if(ProjProjection.projAxisOrder[srsName] && ProjProjection.projAxisOrder[srsName]==ProjProjection.AXIS_ORDER_NE)
						latlon=true;
				}
				if (position.length == 2) {
					if(latlon) {
						result.lat = Number(position[0]);
						result.lon = Number(position[1]);
					} else {
						result.lat = Number(position[1]);
						result.lon = Number(position[0]);
					}
				}
				result.countryCode = gr.xls::Address.@countryCode.toString();
				result.number = gr.xls::Address.xls::StreetAddress.xls::Building.@number.toString();
				result.street = gr.xls::Address.xls::StreetAddress.xls::Street.toString();
				var places:XMLList = gr.xls::Address..xls::Place;
				for each (var node:XML in places) {
					if(node.@type=="Municipality") {
						result.city = node.toString();
						break;
					}
				}
				result.postalCode = gr.xls::Address.xls::PostalCode.toString();
				result.accuracy = Number(gr.xls::GeocodeMatchCode.@accuracy.toString());
				results.push(result);
			}
			
			return results;
		}
		
		static private function parseReverseGeocodeResponse(resultsList:XMLList, version:String = "1.2"): Array {
			var xls:Namespace = new Namespace("xls", "http://www.opengis.net/xls");
			var gml:Namespace = new Namespace("gml", "http://www.opengis.net/gml");
			var results:Array = new Array(), result:Object, position:Array;
			
			var index:uint = 0;
			for each (var gr:XML in resultsList.xls::ReverseGeocodedLocation) {
				result = new Object();
				result.index = index;
				position = gr.gml::Point.gml::pos.toString().split(' ');
				var srsName:String = "EPSG:4326";
				if (gr.gml::Point.gml::pos.@srsName && gr.gml::Point.gml::pos.@srsName.toString()!="") {
					srsName = gr.gml::Point.gml::pos.@srsName.toString().toUpperCase();
				}
				var latlon:Boolean = false;
				if(version == "1.2") {
					if(ProjProjection.projAxisOrder[srsName] && ProjProjection.projAxisOrder[srsName]==ProjProjection.AXIS_ORDER_NE)
						latlon=true;
				}
				if (position.length == 2) {
					if(latlon) {
						result.lat = Number(position[0]);
						result.lon = Number(position[1]);
					} else {
						result.lat = Number(position[1]);
						result.lon = Number(position[0]);
					}
				}
				result.countryCode = gr.xls::Address.@countryCode.toString();
				result.number = gr.xls::Address.xls::StreetAddress.xls::Building.@number.toString();
				result.street = gr.xls::Address.xls::StreetAddress.xls::Street.toString();
				var places:XMLList = gr.xls::Address..xls::Place;
				for each (var node:XML in places) {
					if(node.@type=="Municipality") {
						result.city = node.toString();
						break;
					}
				}
				result.postalCode = gr.xls::Address.xls::PostalCode.toString();
				result.distance = Number(gr.xls::SearchCentreDistance.@value.toString());
				result.matchCode = gr.xls::ExtendedGeocodeMatchCode.toString();
				index++;
				results.push(result);
			}
			
			return results;
		}
		
		/**
		 * Transform a list of results of a geocoding into a JSON formatted
		 * String describing which geocoded address by its "accuracy",
		 * "lat", "lon", "number", "street", "postalCode", "city" and "countryCode".
		 * @param resultsList XML document describing the results of a geocoding
		 * @return a JSON string
		 */
		static public function resultsListtoJSON(resultsList:XMLList, version:String = "1.2"):String {
			return JSON.encode(OpenLSRequest.resultsListtoArray(resultsList, version));
		}
		
		/**
		 * Sends request to OpenLS service
		 */
		override public function send():void {
			super.send();
			this.id = "";
		}
		
	}
	
}
