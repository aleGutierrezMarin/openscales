package org.openscales.fx.layer
{
	import org.openscales.core.layer.HTTPRequest;
	import org.openscales.core.utils.Util;
	
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
		
		public function set altUrls(value:*):void {
			if(this._layer != null) {
				if(value is Array)
					(this._layer as HTTPRequest).altUrls = (value as Array);
				if(value is String)
					(this._layer as HTTPRequest).altUrls = (value as String).split(",");
			}
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