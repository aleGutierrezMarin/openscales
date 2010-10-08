package org.openscales.core.request
{
	import flash.net.URLRequestMethod;

	//import org.openscales.core.Trace;
	
	/**
	 * DataRequest is used to download binary data available from an URL, like
	 * an image.
	 */
	public class DataRequest extends AbstractRequest {
		
		/**
		 * @constructor
		 */
		public function DataRequest(url:String,
									onComplete:Function,
									onFailure:Function=null,
									method: String = null) {
			super(true, url, onComplete, onFailure);
			if(method!=null && method!="")
				this.method = method;
		}
		
	}
	
}
