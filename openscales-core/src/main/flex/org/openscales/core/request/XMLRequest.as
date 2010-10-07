package org.openscales.core.request
{
	import flash.net.URLRequestMethod;

	/**
	 * XMLRequest
	 */
	public class XMLRequest extends AbstractRequest {
		
		
		/**
		 * @constructor
		 */
		public function XMLRequest(url:String, onComplete:Function, onFailure:Function=null) {
			super(false, url, onComplete, onFailure);
	
		
		}
		
	}
	
}
