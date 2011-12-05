package org.openscales.fx.layer
{
	import org.openscales.core.utils.Util;
	import org.openscales.core.layer.HTTPRequest;

	/**
	 * Abstract HTTPRequest Flex wrapper
	 */
	public class FxHTTPRequest extends FxLayer
	{
		public function FxHTTPRequest()
		{
			super();
		}
		
		public function get url():String {
			if(this._layer != null)
				return (this._layer as HTTPRequest).url;
			return null;
		}
		
		public function set url(value:String):void {
	    	if(this._layer != null)
	    		(this._layer as HTTPRequest).url = value;
	    }
		
		public function set altUrls(value:Array):void {
	    	if(this._layer != null)
	    		(this._layer as HTTPRequest).altUrls = value;
	    }
	    
	    public function set params(value:Object):void {
	    	if(this._layer != null)
	    		Util.extend((this._layer as HTTPRequest).params, value);
	    }
		
		public function set method(value:String):void {
			if(this._layer != null)
				(this._layer as HTTPRequest).method = value;
		}
	}
}