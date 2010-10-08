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
		public function XMLRequest(url:String, onComplete:Function, onFailure:Function=null,method: String = null) {
			super(false, url, onComplete, onFailure);
			this.method = method;
		
		}
		
	}
	
}
