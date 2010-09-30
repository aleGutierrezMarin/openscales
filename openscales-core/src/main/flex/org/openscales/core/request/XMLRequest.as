package org.openscales.core.request
{
	import flash.net.URLRequestMethod;

	//import org.openscales.core.Trace;
	
	/**
	 * XMLRequest
	 */
	public class XMLRequest extends AbstractRequest {
		
		private var _isPOSTRequest:Boolean = false;
		
		/**
		 * @constructor
		 */
		
			
		public function XMLRequest(url:String, onComplete:Function, isPOSTRequest:Boolean = false, onFailure:Function=null) {
			super(false, url, onComplete, onFailure);
			
			if(isPOSTRequest){
				this.method = URLRequestMethod.POST;
			}
		
		}
		
	}
	
	/*
	* Getter and setter of the request type
	*
	*/
	
	/*public function get isPOSTRequest():Boolean{
		return this._isPOSTRequest;
	}*/
	/*
	public function set isPOSTRequest(value : Boolean):void{
		this._isPOSTRequest = value;
	}
	*/
}
