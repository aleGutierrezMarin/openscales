package org.openscales.core.request
{
	import com.adobe.serialization.json.JSON;
	
	import org.openscales.core.utils.Trace;
	import org.openscales.core.utils.UID;
	
	/**
	 * OpenLSRequest
	 */
	public class OpenLSRequest extends XMLRequest
	{
		private var _id:String = "";
		private var _freeFormAddress:String = "";
		private var _number:String = "";
		private var _street:String = "";
		private var _postalCode:String = "";
		private var _city:String = "";
		private var _countryCode:String = "";
				
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
		 * Getter and setter of the free form address of the request (for simple search).
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
		 * Getter and setter of the number of the request.
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
		 * Getter and setter of the function that check if a postal code is
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
		 * @freeFormAddress
		 * @param number
		 * @param street
		 * @param postalCode
		 * @param city
		 * @param countryCode
		 */
		public function define(id:String, freeFormAddress:String, number:String, street:String, postalCode:String, city:String, countryCode:String):void {
			this.id = id;
			this.freeFormAddress =freeFormAddress;
			this.number = number;
			this.street = street;
			this.postalCode = postalCode;
			this.city = city;
			this.countryCode = countryCode;
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
			//Trace.debug("OpenLSRequest - requestId : " + this.id);
			var request:String = '';
			request += '<?xml version="1.0" encoding="UTF-8"?>';
			request += '<XLS version="1.2" xmlns="http://www.opengis.net/xls" xmlns:xls="http://www.opengis.net/xls" xmlns:gml="http://www.opengis.net/gml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/xls">';
			request += '<xls:RequestHeader srsName="epsg:4326"/>';
			request += '<xls:Request maximumResponses="5" methodName="GeocodeRequest" requestID="'+this.id+'" version="1.0">';
			request += '<GeocodeRequest>';
			
			if (this.freeFormAddress) {
				request += '<Address countryCode="FR">';
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
			request += '</xls:Request>';
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
			return response.xls::Response.xls::GeocodeResponse.xls::GeocodeResponseList;
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
		 * Transform a list of results of a geocoding into a JSON formatted
		 * String describing which geocoded address by its "accuracy",
		 * "city", "lat", "lon", "postalCode" and "streetOrPOI".
		 * @param resultsList XML document describing the results of a geocoding
		 * @return a JSON string
		 */
		static public function resultsListtoArray(resultsList:XMLList):Array {
			var xls:Namespace = new Namespace("xls", "http://www.opengis.net/xls");
			var gml:Namespace = new Namespace("gml", "http://www.opengis.net/gml");
			var results:Array = new Array(), result:Object, position:Array;
			for each (var gr:XML in resultsList.xls::GeocodedAddress) {
				result = new Object();
				position = gr.gml::Point.gml::pos.toString().split(' ');
				if (position.length == 2) {
					result.lat = Number(position[0]);
					result.lon = Number(position[1]);
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
				//result.city = gr.xls::Address.xls::Place.toString();
				result.postalCode = gr.xls::Address.xls::PostalCode.toString();
				result.accuracy = Number(gr.xls::GeocodeMatchCode.@accuracy.toString());
				results.push(result);
			}
			return results;
		}
		
		/**
		 * Transform a list of results of a geocoding into a JSON formatted
		 * String describing which geocoded address by its "accuracy",
		 * "city", "lat", "lon", "postalCode" and "streetOrPOI".
		 * @param resultsList XML document describing the results of a geocoding
		 * @return a JSON string
		 */
		static public function resultsListtoJSON(resultsList:XMLList):String {
			return JSON.encode(OpenLSRequest.resultsListtoArray(resultsList));
		}
		
		override public function send():void {
			super.send();
			this.id = "";
		}
		
	}
	
}
