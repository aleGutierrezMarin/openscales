package org.openscales.core.security
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import mx.utils.Base64Encoder;
	
	import org.openscales.core.Map;
	
	public class AuthBasicSecurity extends AbstractSecurity
	{
		
		/**
		 * Contains the string "login:pass" to add before the url in order 
		 * to send the authentication parameters
		 */
		private var _loginPass:String;
		
		public function AuthBasicSecurity(map:Map, lp:String)
		{
			super(map);
			this._loginPass = lp;
		}
		
		public function get loginPass():String {
			return this._loginPass;
		}
		
		public function set loginPass(value:String):void {
			this._loginPass = value;
		}
		
		override public function getFinalUrl(baseUrl:String):String {
			//No need to change URL for an AuthBasic Security
			var _finalUrl:String = baseUrl;
			return _finalUrl;
		}
		
		override public function addCustomHeaders(urlRequest:URLRequest):URLRequest {
			urlRequest.method = URLRequestMethod.POST;
			if(!urlRequest.data) {
				//We need to force custom data to enable POST Method. 
				//Otherwise, Request is automatically transformed in a GET Request by Flash
				urlRequest.data = "data";
			}
			
			var encoder:Base64Encoder = new Base64Encoder();        
			encoder.encode(this._loginPass);
			
			var credsHeader:URLRequestHeader = new URLRequestHeader("Authorization", "Basic " + encoder.toString());
			urlRequest.requestHeaders.push(credsHeader);
			return urlRequest;
		}
	}
}