package org.openscales.core.security
{
	import flash.net.URLRequest;
	
	import org.openscales.core.Map;
	import org.openscales.core.request.AbstractRequest;
	import org.openscales.core.security.events.SecurityEvent;


	/**
	 * Base abstract class for all securities
	 */
	public class AbstractSecurity implements ISecurity
	{
		/**
		 * Map used to dispatch events
		 */
		private var _map:Map = null;
		
		private var _waitingRequests:Vector.<AbstractRequest> = null;
		
		protected var _initialized:Boolean = false;
		
		/**
		 * Proxy eventually used to auhtenticate
		 */ 
		private var _proxy:String = null;

		public function AbstractSecurity(map:Map)
		{
			this._map = map;
			this._map.addSecurity(this);
			this.initialize();
		}

		public function destroy():void {
			if(this._waitingRequests!=null) {
				var i:int = this._waitingRequests.length;
				for(i;i>0;--i)
					this._waitingRequests.pop().destroy();
			}
			this._map = null;
		}
		public function initialize():void {
			this._initialized = true;
			map.dispatchEvent(new SecurityEvent(SecurityEvent.SECURITY_INITIALIZED, this));
			if(this._waitingRequests!=null) {
				var i:int = this._waitingRequests.length;
				var request:AbstractRequest;
				for(i;i>0;--i) {
					request = this._waitingRequests.pop();
					request.send();
				}
				this._waitingRequests = null;
			}
		}

		public function update():void {
			map.dispatchEvent(new SecurityEvent(SecurityEvent.SECURITY_UPDATED, this));
		}

		public function logout():void {
			map.dispatchEvent(new SecurityEvent(SecurityEvent.SECURITY_LOGOUT, this));
		}

		public function get securityParameter():String
		{
			return null;
		}

		public function get map():Map {
			return this._map;
		}

		public function set map(value:Map):void {
			this._map = value;
		}
		
		/**
		 * Proxy used for security authentication
		 *  
		 * There is 3 cases :
		 *  - proxy is explicitly defined
		 *  - proxy is explicitly defined to "" => no proxy will be used
		 *  - proxy is null => use the proxy of the map
		 */
		public function get proxy():String {
			if(!this._proxy && map && map.proxy)
				return this.map.proxy;
			return this._proxy;
		}
		
		public function set proxy(value:String):void {
			this._proxy = value;
		}

		public function get initialized():Boolean {
			return this._initialized;
		}
		
		public function addWaitingRequest(request:AbstractRequest):void {
			if(request.proxy == null)
				request.proxy = this.proxy;
			if(this.initialized) {
				request.send();
			} else {
				if(this._waitingRequests==null)
					this._waitingRequests = new Vector.<AbstractRequest>();
				if(this._waitingRequests.indexOf(request)==-1)
					return;
				this._waitingRequests.push(request);
			}
		}

		public function removeWaitingRequest(request:AbstractRequest):void {
			if(this._waitingRequests==null)
				return;
			var i:int = this._waitingRequests.indexOf(request);
			if(i==-1)
				return;
			request.proxy=null;
			this._waitingRequests.splice(i,1);
		}
		
		public function getFinalUrl(baseUrl:String):String {
			var _finalUrl:String = baseUrl;
			if (_finalUrl)
			{
				_finalUrl += (_finalUrl.indexOf("?") == -1) ? "?" : "&"; // If there is no "?" in the url, we will have to add it, else we will have to add "&"
				if(this.securityParameter!=null)
					_finalUrl += this.securityParameter;
			}
			return _finalUrl;
		}
		
		public function addCustomHeaders(urlRequest:URLRequest):URLRequest {
			return urlRequest;
		}
	}
}

