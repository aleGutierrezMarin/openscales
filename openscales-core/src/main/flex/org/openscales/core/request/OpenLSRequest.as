package org.openscales.core.request
{
	import com.adobe.serialization.json.JSON;
	
	import org.openscales.core.utils.Trace;
	import org.openscales.core.utils.UID;
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
		 * Create the content of the request using the specified fields.
		 * @return a String describing the content of the request.
		 */
		private function createContent():String {
			if (!this.id || this.id=="") {
				this.id = UID.gen_uid(); 
			}
			var request:String = '';
			request += '<?xml version="1.0" encoding="UTF-8"?>';
			request += '<XLS xmlns:gml="http://www.opengis.net/gml" xmlns="http://www.opengis.net/xls" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="'+this._version+'"  xsi:schemaLocation="http://www.opengis.net/xls http://schemas.opengis.net/ols/1.2/olsAll.xsd">';
			if (srsName && srsName != "") {
				request += '<RequestHeader srsName="'+this.srsName+'"/>';
			}
			else {
				request += '<RequestHeader/>';
			}
			request += '<Request maximumResponses="'+this.maximumResponses+'" methodName="GeocodeRequest" requestID="'+this.id+'" version="'+this._version+'">';
			request += '<GeocodeRequest>';
			
			if (this.freeFormAddress) {
				request += '<Address countryCode="' + this.countryCode + '">';
				request += '<freeFormAddress>' + this.freeFormAddress + '</freeFormAddress>';
				request += '</Address>';
			}
			else {
				request += '<Address countryCode="' + this.countryCode + '">';
				request += '<StreetAddress>';
				request += '<Building number="' + this.number  + '"/>'; 
				request += '<Street>' + this.street + '</Street>';
				request += '</StreetAddress>';
				request += '<Place type="Municipality">' + this.city + '</Place>';
				request += '<PostalCode>' + this.postalCode + '</PostalCode>';
				request += '</Address>';				
			}
			request += '</GeocodeRequest>';
			request += '</Request>';
			request += '</XLS>';
			return request;
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
			return OpenLSRequest.resultsList(response).@numberOfGeocodedAddresses.toString() as Number;
		}
		
		/**
		 * Transform a list of results of a geocoding into an Array
		 * describing which geocoded address by its "accuracy",
		 * "lat", "lon", "numuber", "street", "postalCode", "city" and "countryCode".
		 * @param resultsList XML document describing the results of a geocoding
		 * @return a Array of String
		 */
		static public function resultsListtoArray(resultsList:XMLList, version:String = "1.2"):Array {
			var xls:Namespace = new Namespace("xls", "http://www.opengis.net/xls");
			var gml:Namespace = new Namespace("gml", "http://www.opengis.net/gml");
			var results:Array = new Array(), result:Object, position:Array;
			try {
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
			}
			catch (e:Error) {
				Trace.error("OpenLSRequest - Error while reading XMLList response");
			}
			return results;
		}
		
		/**
		 * Transform a list of results of a geocoding into a JSON formatted
		 * String describing which geocoded address by its "accuracy",
		 * "lat", "lon", "numuber", "street", "postalCode", "city" and "countryCode".
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
