package org.openscales.core.request.csw
{
	import flash.net.URLRequestMethod;
	
	import org.openscales.core.format.FilterEncodingFormat;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.request.csw.getrecords.GetRecordsRequest202;
	import org.openscales.core.utils.Trace;
	
	
	
	/**
	 * Request class used to generate a CSW 2.0.2 GetRecords request
	 * This request will be sent with POST method because of filter encoding
	 */
	public class GetRecordsRequest extends XMLRequest
	{
		
		/**
		 * CSW version number.
		 * Default to 2.0.2
		 */
		private var _version:String = "2.0.2";
		
		/**
		 * Callback for the onComplete, bufferized to choose the CSW version
		 */
		private var _oncomplete:Function;
		
		/**
		 * Callback for the onFailure, bufferized to choose the CSW version
		 */
		private var _onFailure:Function;
		
		/**
		 * Contain the XMl data for the filter
		 */
		private var _filter:XML;
		
		/**
		 * Start position of the records for the request
		 */
		private var _startPosition:Number = 1;
		
		/**
		 * Number of records per request
		 */
		private var _maxRecords:Number = 10;
		
		/**
		 * Element set of the request
		 */
		private var _elementSet:String = "brief";
		
		
		public function GetRecordsRequest(url:String, onComplete:Function, onFailure:Function=null, method:String=null)
		{
			super(url, onComplete, onFailure, method);
			this._oncomplete = onComplete;
			this._onFailure = onFailure;
		}
		
		/**
		 * @inheritdoc
		 */
		override public function send():void
		{
			if (_version == "2.0.2")
			{
				var request:GetRecordsRequest202 = new GetRecordsRequest202(this.url, this._oncomplete, this._onFailure, URLRequestMethod.POST);
				request.security = this.security;
				request.proxy = this.proxy;
				request.buildQuery(this._filter, this._startPosition, this._maxRecords, _elementSet);
				request.send();
			}else
			{
				Trace.error("CSW GetRecords version : "+_version+" not supported")
			}
		}
		
		
		// getter setter
		
		/**
		 * The element set name to request
		 * Can be : brief, summary, full
		 * @default "brief"
		 */
		public function get elementSetName():String
		{
			return this._elementSet;	
		}
		
		/**
		 * @private
		 */ 
		public function set elementSetName(value:String):void
		{
			this._elementSet = value;
		}
		/**
		 * The max number records in the request
		 * Use this parameter combined with startPosition parameter to choose wich records to return
		 * default to 10.
		 * 
		 * example : startPosition = 10 and maxRecord = 5 will return record number 10 to record number 14
		 */
		public function get maxRecords():Number
		{
			return this._maxRecords;
		}
		
		/**
		 * @private
		 */
		public function set maxRecords(value:Number):void
		{
			this._maxRecords = value;
		}
		
		/**
		 * The start position of the first record return in the getRecord request
		 * Use this parameter combined with maxRecord parameter to choose wich records to return
		 * default to 1.
		 * 
		 * example : startPosition = 10 and maxRecord = 5 will return record number 10 to record number 14
		 */
		public function get startPosition():Number
		{
			return this._startPosition;
		}
		
		/**
		 * @private
		 */
		public function set startPosition(value:Number):void
		{
			this._startPosition = value
		}
		
		/**
		 * CSW version number.
		 * Default to 2.0.2
		 */
		public function get version():String
		{
			return this._version;
		}
		
		/**
		 * @private
		 */
		public function set version(value:String):void
		{
			this._version = value;
		}
		
		
		/**
		 * The FilterEncoding XML data used to filter the getRecord request
		 */
		public function get filter():XML
		{
			return this._filter;	
		}
		
		/**
		 * @private
		 */
		public function set filter(value:XML):void
		{
			this._filter = value;
		}
	}
}