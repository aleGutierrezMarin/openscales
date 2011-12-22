package org.openscales.core.layer.params.ogc
{
	import org.openscales.core.layer.params.IHttpParams;

	/**
	 * Implementation of IHttpParams interface.
	 * Extends OGCParams.
	 * It adds specific WFS request params.
	 */
	public class WFSParams extends OGCParams
	{
		private var _typename:String;
		private var _maxFeatures:Number;
		private var _handle:String;
		
		// Constructor
		public function WFSParams(typename:String, version:String = "2.0.0")
		{
			super("WFS", version, "GetFeature");
			
			// Properties initialization
			this._typename = typename;
		}
		
		override public function toGETString():String
		{
			var str:String = super.toGETString();
			
			if (this.bbox != null)
			{
				str += "BBOX=" + this.bbox + "&";
			}
			if (this._typename != null)
				if(version != "2.0.0"){
					str += "TYPENAME=" + this._typename + "&";	
				}else
				{
					str += "TYPENAMES=" + this._typename + "&";
				}

			if (this._maxFeatures >= 0 && version != "2.0.0")
				str += "MAXFEATURES=" + this._maxFeatures + "&"; 

			if (this._handle != null)
				str += "HANDLE=" + this._handle + "&";
			if(version == "2.0.0")
				str += "outputFormat=text/xml; subtype=gml/3.2&";
			return str.substr(0, str.length-1);
		}

		// Getters & setters
		public function get typename():String {
			return _typename;
		}

		public function set typename(typename:String):void {
			_typename = typename;
		}

		public function get maxFeatures():Number {
			return _maxFeatures;
		}

		public function set maxFeatures(maxFeatures:Number):void {
			_maxFeatures = maxFeatures;
		}

		public function get handle():String {
			return _handle;
		}

		public function set handle(handle:String):void {
			_handle = handle;
		}
	}
}
