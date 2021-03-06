package org.openscales.core.layer.capabilities
{

	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.security.ISecurity;
	import org.openscales.core.utils.Trace;

	/**
	 * Class to request Capabilities to a given server.
	 */
	public class GetCapabilities
	{
		private var _parsers:HashMap = null;

		private var _service:String = null;
		private var _version:String = null;
		private var _request:String = null;
		private var _url:String = null;
		private var _proxy:String = null;
		private var _security:ISecurity = null;
		private var _parser:CapabilitiesParser = null;
		
		private var _capabilities:HashMap = null;

		private var _requested:Boolean = false;

		private var _cbkFunc:Function = null;

		/**
		 * Class contructor
		 * 
		 * cbkFunc must have this signature :
		 * public function cbkFunc(getCap:GetCapabilities):void {
		 * }
		 * 
		 * It takes the GetCapabilites object as parameter in order to access the variables set by the Getcapabilities request.
		 */
		public function GetCapabilities(service:String, url:String, cbkFunc:Function=null, version:String=null, proxy:String = null, security:ISecurity=null)
		{			
			this._service = service.toUpperCase();
			this._url = url;
			this._request = "GetCapabilities";
			this._capabilities = new HashMap(false)
			this._parsers = new HashMap();
			this._security = security;
			
			_parsers.put("WFS 1.0.0",WFS100Capabilities);
		    _parsers.put("WFS 1.1.0",WFS110Capabilities);
			_parsers.put("WFS 2.0.0",WFS200Capabilities);
		    _parsers.put("WMS 1.0.0",WMS100Capabilities);
		    _parsers.put("WMS 1.1.0",WMS110Capabilities);
		    _parsers.put("WMS 1.1.1",WMS111Capabilities);
			_parsers.put("WMS 1.3.0",WMS130Capabilities);
			_parsers.put("WMTS 1.0.0",WMTS100Capabilities);
				
			this._proxy = proxy;

			this._cbkFunc = cbkFunc;
			
			this._version = version;

			this.requestCapabilities();

		}

		/**
		 * Method which will request the capabilities
		 *
		 * @param failedVersion The last WFS version protocol requested unsuported by the server
		 * @return If the server was requested
		 */
		private function requestCapabilities(failedVersion:String = null):Boolean{

			if (this._service != "WFS" && this._service != "WMS" && this._service != "WMTS"){
				return false;
			}

			if (this._url == null) {
				return false;
			}
			
			var urlRequest:String = this.buildRequestUrl(); 

			var _req:XMLRequest = new XMLRequest(urlRequest, this.parseResult, this.onFailure);
			_req.security = this._security;
			_req.proxy = this._proxy;
			//_req.security = null; //FixMe: should the security be managed here ?
			_req.send();

			return true;
		}

		/**
		 * Method to build the request url
		 *
		 * @return The built url with needed parameters
		 */
		private function buildRequestUrl():String {
			var url:String = this._url;

			if(url.indexOf("?")==-1) {
				url += "?";
			} else {
				url += "&";
			}

			url += "REQUEST=" + this._request;
			if(this._version)
				url += "&VERSION=" + this._version;
			url += "&SERVICE=" + this._service;

			return url;
		}

		/**
		 * Callback method after GetCapabilities request
		 */
		private function parseResult(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			
			try
			{
				var doc:XML =  new XML(loader.data);
			}
			catch (error:Error) 
			{

			     onFailure(event);
			     return;
			}

            // this can cause "infinite loops" on 'buggy' WMS servers
			//if (doc.@version != this._version) {
			//	this.requestCapabilities(doc.@version);
			//}
			
			if(!this._version)
				this._version = doc.@version;

			if(!this._version)
				this._version = "1.0.0";
			
			
			var parser:Class = _parsers.getValue(this._service + " " + this._version);
			this._parser = new parser;
			
			if (this._parser == null) 
			{
				Trace.error("GetCapabilities: Not found server compatible version");
			}
			
			this._capabilities = this._parser.read(doc);
			
			// add auto version in result
			var map:Array = this._capabilities.getKeys();
			
			for each(var item:Object in map)
			{
				this._capabilities.getValue(item).put("auto-version", this._version);
			}

			this._requested = true;

			if (this._cbkFunc != null) {
				this._cbkFunc.call(this,this);
			}
		}
		
		/**
		 * onFailure handler for XMLRequest 
		 */
		private function onFailure(event:Event):void 
		{		
			// load of capabilities failed. return empty capabilities map
			Trace.error("Failed loading GetCapabilities XML request");
			this._capabilities = new HashMap();
			this._requested = true;

			if (this._cbkFunc != null) {
				this._cbkFunc.call(this,this);
			}
		}
		
		/**
		 * Call the <code>instanciate</code> method of current parser
		 */ 
		public function instanciateLayer(layerName:String):Layer{
			return _parser.instanciate(layerName);
		}
		
		/**
		 * Returns the capabilities HashMap representation of the specified layer name
		 *
		 * @param layerName The layer's name
		 * @return An HashMap containing the capabilities of requested layer
		 */
		public function getLayerCapabilities(layerName:String):HashMap {

			return this._capabilities.getValue(layerName);
		}

		/**
		 * Returns all the capabilities (i.e. all layers or features available and their properties) of the
		 * requested server.
		 *
		 * @return An HashMap containing capabilities of all layers available on the server
		 */
		public function getAllCapabilities():HashMap {

			return this._capabilities;
		}

		public function set proxy(value:String):void {
			this._proxy = value;
		}

		public function get proxy():String {
			return this._proxy;
		}

		public function get version():String {
			return this._version;
		}
	}
}

