package org.openscales.core.request
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	
	import org.openscales.core.events.RequestEvent;
	import org.openscales.core.security.ISecurity;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.utils.UID;

	/**
	 * Request wapper in order to make data or XML request easier to use (proxy, timeout, etc.)
	 * 
	 * TODO See http://github.com/yahoo/yos-social-as3/blob/2e12ae0d3cfd01cd950b63db8c601495bdaf318d/Source/com/yahoo/net/Connection.as for improvements ?
	 */
	public class AbstractRequest implements IRequest
	{
		/**
		 * This class manage a pool of connections so that the it
		 * can manage the number of simultaneous connections and
		 * prevent browser's "saturation"
		 */
		private static const DEFAULT_MAX_ACTIVE_TIME:uint = 0; // 5000 for a timeout of 5s by request

		public static const PUT:String = "put";
		public static const DELETE:String = "delete";

		private var _url:String;
		private var _method:String = null;
		private var _postContent:Object = null;
		private var _postContentType:String = null;
		private var _proxy:String = null;
        private var _security:ISecurity = null;

		private var _onComplete:Function = null;
		private var _onFailure:Function = null;
		private var _isSent:Boolean = false;
		private var _isCompleted:Boolean = false;
		private var _loader:Object = null;
		
		private var _uid:String;

		private var _cache:Boolean=true;
		/**
		 * @constructor
		 * Create a new Request
		 * 
		 * @param SWForImage Boolean that defines if the request is a loading of a SWF object / an image or not
		 * @param url URL to use for the request (for instance http://server/dir/image123.png to dowload an image)
		 * @param onComplete Function called when the request is completed (param: evt:flash.events.Event)
		 * @param onFailure Function called when an error occurs (param: evt:flash.events.Event)
		 */
		public function AbstractRequest(SWForImage:Boolean,
										url:String,
										onComplete:Function,
										onFailure:Function=null) {
			this._uid = UID.gen_uid();
			// Create a loader for a SWF or an image (Loader), or for an URL (URLLoader)
			this._loader = (SWForImage) ? new Loader() : new URLLoader();

			_loader.addEventListener(IOErrorEvent.IO_ERROR,function(event:Event):void{
				event.stopImmediatePropagation();
				
				if (this._onFailure == null)
					this._onFailure = onFailure;
				if(this._onFailure)
					this._onFailure.apply(this,[event]);
			});
			
			this.url = url;
			this._onComplete = onComplete;
			this._onFailure = onFailure;
			this._addListeners();
		}

		/**
		 * Destroy the request.
		 */
		public function destroy():void {
			this._removeListeners();
			if(!this._isSent && this.security!=null)
				this.security.removeWaitingRequest(this);
			
			try {
				if (this._isCompleted && (this.loader is Loader)) {
					(this.loader as Loader).unloadAndStop(true);
				} // else ? // FixMe
				if(this._isSent)
					this.loader.close();
			} catch(e:Error) {
				// Empty catch is evil, but here it's fair.
			}
			this._isSent = true;
			//this._loader = null; // FixMe
		}
		
		/**
		 * Add listeners
		 */
		private function _addListeners():void {
			try {
				this.loaderInfo.addEventListener(Event.COMPLETE, this._loadEnd, false, int.MAX_VALUE, true);
				this.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this._loadEnd, false, int.MAX_VALUE, true);
				// IOErrorEvent.IO_ERROR must be listened to avoid this following error:
				// IOErrorEvent non pris en charge : text=Error #2124: Le type du fichier chargé est inconnu.
				this.loaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this._loadEnd, false, int.MAX_VALUE, true);
				// SecurityErrorEvent.SECURITY_ERROR must be listened for the cross domain errors
				
				/*if (this._onComplete != null) {
					this.loaderInfo.addEventListener(Event.COMPLETE, this._onComplete);
				}*/
				
				if (this._onFailure != null) {
					this.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this._onFailure);
					this.loaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this._onFailure);
				}
			} catch (e:Error) {
				// Empty catch is evil, but here it's fair.
			}
		}
		
		/**
		 * Remove listeners
		 */
		private function _removeListeners():void {
			try {
				this.loaderInfo.removeEventListener(Event.COMPLETE, this._loadEnd);
				this.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this._loadEnd);
				this.loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this._loadEnd);
				
				/*if (this._onComplete != null) {
					this.loaderInfo.removeEventListener(Event.COMPLETE, this._onComplete);
				}*/
				
				if (this._onFailure != null) {
					this.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this._onFailure);
					this.loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this._onFailure);
				}
			} catch (e:Error) {
				// Empty catch is evil, but here it's fair.
			}
		}
		
		/**
		 * When a loader ends, then start another if one
		 * 
		 * @param e:Event one of the listened events.
		 * We don't care about whitch one it is because it just means that a connection have been released.
		 */
		private function _loadEnd(event:Event=null):void {
			if (event==null || (event.type == TimerEvent.TIMER)) {
				if (this._onFailure != null) {
					this._onFailure(new IOErrorEvent(IOErrorEvent.IO_ERROR));
				}
				this.destroy(); // called last since the listeners will be removed
			} else {
				if (event.type == Event.COMPLETE) {
					this._isCompleted = true;
					if (this._onComplete != null) {
						this._onComplete(new RequestEvent(event.type,this.url,event.target,event.bubbles,event.cancelable));
					}
				}
				else if (this._onFailure == null) {
					switch (event.type) {
						case IOErrorEvent.IO_ERROR:
						case SecurityErrorEvent.SECURITY_ERROR:
							Trace.error(event.toString());
							break;
					}
				}
			}
		}
		
		/**
		 * Getter and setter of the url of the request.
		 */
		public function get url():String {
			return this._url;
		}
		public function set url(value:String):void {
			if ((! value) || (value=="")) {
				Trace.error("AbstractRequest - set url: invalid void value");
				return;
			}
			this._url = value;
		}

		public function get uid():String {
			return this._uid;
		}

		/**
		 * Getter and setter of the method of the request.
		 * The valid values are null (default), URLRequestMethod.GET,
		 * URLRequestMethod.POST, AbstractRequest.PUT and AbstractRequest.DELETE.
		 * If the value is null, the getter returns URLRequestMethod.POST if
		 * postContent is not null and URLRequestMethod.GET otherwise.
		 */
		public function get method():String {
			if (this._method) {
				return this._method;
			} else {
				return (this.postContent) ? URLRequestMethod.POST : URLRequestMethod.GET;
			}
		}
		public function set method(value:String):void {
			switch (value) {
				case URLRequestMethod.GET:
				case URLRequestMethod.POST:
				case AbstractRequest.PUT:
				case AbstractRequest.DELETE:
					this._method = value;
					break;
				default:
					Trace.warn("AbstractRequest - set method: invalid value, null will be used");
					this._method = null;
					break;
			}
		}

		/**
		 * Getter and setter of the content of a POST request.
		 * Default value is null, so the request is a GET request.
		 */
		public function get postContent():Object {
			return this._postContent;
		}
		public function set postContent(value:Object):void {
			this._postContent = value;
		}

		/**
		 * Getter and setter of the content type of a POST request.
		 * If postContentType is not explicitly defined, then
		 * "application/x-www-form-urlencoded" is returned if the postContent is
		 * an URLVariables and "application/xml" is returned otherwise.
		 */
		public function get postContentType():String {
			if (this._postContentType) {
				return this._postContentType;
			} else {
				return (this.postContent is URLVariables) ? "application/x-www-form-urlencoded" : "application/xml";
			}
		}
		public function set postContentType(value:String):void {
			this._postContentType = value;
		}

		/**
		 * Getter and setter of the proxy to use for a request.
		 * If a proxy (server side script) is used to avoid cross domain issues,
		 * specify its address here (for instance http://server/proxy.php?url=).
		 * Default value is null.
		 */
		public function get proxy():String {
			return this._proxy;
		}
		public function set proxy(value:String):void {
			this._proxy = value;
		}

		/**
		 * Getter and setter of the security module to use for a request.
		 * Default value is null.
		 */
		public function get security():ISecurity {
			return this._security;
		}
		public function set security(value:ISecurity):void {
			this._security = value;
		}

		/**
		 * Has the request been already sent ?
		 */
		protected function get isSent():Boolean {
			return this._isSent;
		}

		/**
		 * Getter of the loader of the request.
		 */
		public function get loader():Object {
			return this._loader;
		}

		/**
		 * Getter of the object that can be listened while loading.
		 */
		protected function get loaderInfo():Object {
			return (this.loader is Loader) ? this.loader.contentLoaderInfo : this.loader;
		}

		/**
		 * Getter of the final url of the request (using proxy and security).
		 */
		protected function get finalUrl():String {
			var _finalUrl:String = this.url;
			
			if (this.security != null) {
				if (! this.security.initialized) {
					// A redraw will be called on the layer when a SecurityEvent.SECURITY_INITIALIZED will be dispatched
					return null;
				}
				
				_finalUrl = this.security.getFinalUrl(_finalUrl);
			}

			if ((this.proxy != null)) {
				if(this.proxy.charAt(this.proxy.length-1) == '/')
				{
					_finalUrl = _finalUrl.replace("http://", "http:/");
					_finalUrl = this.proxy + _finalUrl;
				}else{
					_finalUrl = this.proxy + encodeURIComponent(_finalUrl);
				}
			}
			
			if (!this._cache){
				_finalUrl += "&timestamp=" + new Date().getTime();
			}

 			return _finalUrl;
		}

		/**
		 * Send the request (can be called only once).
		 * The request is really launched if the maximum number of parallels
		 * requests is not reached and it is pooled otherwise.
		 * If AbstractRequest.maxConn is zero, all the requests are launched
		 * immediately.
		 */
		public function send():void {
			if (this.isSent) {
				return;
			}
			this._isSent = true;
			if(this.security != null && !this.security.initialized) {
				this.security.addWaitingRequest(this);
				this.security.initialize();
				return;
			}
			this.execute();
		}

		/**
		 * Execute the request
		 */
		private function execute():void {
			try {
				// Define the urlRequest
				var _finalUrl:String = this.finalUrl;
				if ((_finalUrl==null) || (_finalUrl=="")) {
					// invalid url, abort
					this._loadEnd(null);
					return;
				}
				
				var urlRequest:URLRequest = new URLRequest(_finalUrl);
				urlRequest.method = this.method;
				if (urlRequest.method == URLRequestMethod.POST) {
					urlRequest.contentType = this.postContentType;
					urlRequest.data = this.postContent;
				}
				
				if (this.security != null) {
					if (! this.security.initialized) {
						return;
					}
					
					urlRequest = this.security.addCustomHeaders(urlRequest);
				}
				
				if (this.loader is Loader) {
					this.loader.name = this.url; // Needed, see KMLFormat.updateImages for instance
					// Define the context for the loading of the SWF or Image
					var loaderContext:LoaderContext = new LoaderContext();
					loaderContext.checkPolicyFile = true;
					// Send the request
					(this.loader as Loader).load(urlRequest, loaderContext);
				} else {
					// Send the request
					(this.loader as URLLoader).load(urlRequest);
				}
			} catch (e:Error) {
				this._loadEnd(null);
			}
		}
		
		/**
		 * Setter for "cache" property
		 * 
		 * @param value Boolean
		 */
		public function set cache(value:Boolean):void{
			this._cache = value;
		}
		
		/**
		 * getter for "cache" property
		 * 
		 * @return Boolean
		 */
		public function get cache():Boolean{
			return this._cache;
		}
	}
	
}
