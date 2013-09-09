package org.openscales.core.request.csw
{
	import flash.net.URLRequestMethod;
	
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.request.csw.getrecordbyid.GetRecordByIdRequest202;
	import org.openscales.core.utils.Trace;
	
	public class GetRecordByIdRequest extends XMLRequest
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
		 * Element set of the request
		 */
		private var _elementSet:String = "brief";
		
		/**
		 * Record id to request
		 */
		private var _recordId:String;
		
		
		public function GetRecordByIdRequest(url:String, onComplete:Function, onFailure:Function=null, method:String=null)
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
				var request:GetRecordByIdRequest202 = new GetRecordByIdRequest202(this.url, this._oncomplete, this._onFailure, URLRequestMethod.GET);
				request.security = this.security;
				request.proxy = this.proxy;
				request.buildQuery(_recordId, _elementSet);
				request.send();
			}else
			{
				Trace.error("CSW GetRecordById version : "+_version+" not supported")
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
		 * Record id to request
		 */
		public function get recordId():String
		{
			return this._recordId;
		}
		
		/**
		 * @private
		 */
		public function set recordId(value:String):void
		{
			this._recordId = value;
		}
	}
}