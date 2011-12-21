package org.openscales.core.layer.params.ogc
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.params.AbstractParams;
	import org.openscales.core.layer.params.IHttpParams;
	import org.openscales.geometry.Geometry;

	/**
	 * Implementation of IHttpParams interface.
	 * It represents the common OGC requests params.
	 */
	internal class OGCParams extends AbstractParams implements IHttpParams
	{

		private var _service:String;
		private var _version:String;
		private var _request:String;
		private var _srs:String;

		private var _additionalParams:HashMap = null;

		public function OGCParams(service:String, version:String, request:String) {
			this._service = service;
			this._version = version;
			this._request = request;

			_additionalParams = new HashMap();

			_srs = Geometry.DEFAULT_SRS_CODE;
		}


		override public function toGETString():String {
			var str:String = "";

			if (this._service != null)
				str += "SERVICE=" + this._service + "&";

			if (this._version != null)
				str += "VERSION=" + this._version + "&";

			if (this._request != null)
				str += "REQUEST=" + this._request + "&";

			if (this._srs != null) {
				if(this.service == "WFS" && (this._version == "2.0.0" || this._version == "1.1.0")) {
					str += "SRSNAME=" + this._srs + "&";
				} else {
					str += "SRS=" + this._srs + "&";
				}
			}

			var keys:Array = _additionalParams.getKeys();
			var n:uint = keys.length;
			for (n; n>0; --n) {
				var key:String = keys.pop();
				var value:String = _additionalParams.getValue(key);

				str += key + "=" + value + "&";
			}

			return str;
		}

		//Getters and setters
		public function get service():String {
			return _service;
		}

		public function set service(service:String):void {
			_service = service;
		}

		public function get version():String {
			return _version;
		}

		public function set version(version:String):void {
			_version = version;
		}

		public function get request():String {
			return _request;
		}

		public function set request(request:String):void {
			_request = request;
		}

		public function get srs():String {
			return _srs;
		}

		public function set srs(srs:String):void {
			_srs = srs;
		}



		override public function setAdditionalParam(key:String, value:String):void {
			_additionalParams.put(key, value);
		}
	}
}

