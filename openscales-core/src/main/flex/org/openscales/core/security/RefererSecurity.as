package org.openscales.core.security
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	
	public class RefererSecurity extends AbstractSecurity
	{
		public function RefererSecurity(map:Map)
		{
			super(map);
		}
		
		override public function getFinalUrl(baseUrl:String):String {
			//No need to change URL for an AuthBasic Security
			return baseUrl;
		}
		
		override public function addCustomHeaders(urlRequest:URLRequest):URLRequest {
			try 
			{
				urlRequest.method = URLRequestMethod.POST;
				if(!urlRequest.data) {
					//We need to force custom data to enable POST Method. 
					//Otherwise, Request is automatically transformed in a GET Request by Flash
					urlRequest.data = "data";
				}
				urlRequest.requestHeaders.push(new URLRequestHeader("FlashReferer", ExternalInterface.call("window.location.href.toString")));
			} catch(e:Error) { 
				Trace.error("Some error occured. ExternalInterface doesn't work in Standalone player."); 
			}
			
			return urlRequest;
		}
	}
}