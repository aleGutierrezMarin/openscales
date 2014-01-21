package org.openscales.core.events{

	/**
	 * Event allowing to get information about a WMS feature when we click on it.
	 * Dispatched for example by the WMSGetFeatureInfo handler
	 */
	public class GetFeatureInfoEvent extends OpenScalesEvent {

		/**
		 * Data returned by the WMSGetFeatureInfo request
		 */
		private var _data:Object = null;
		private var _url:String = null;
		
		/**
		 * Determine the Data return format
		 * 
		 * @default text/xml Due to OGC definition
		 */
		private var _infoFormat:String = "text/xml";

		/**
		 * Event type dispatched when the get feature info response has been received.
		 */
		public static const GET_FEATURE_INFO_DATA:String="openscales.getfeatureinfodata";

		public function GetFeatureInfoEvent(type:String, data:Object, url:String, bubbles:Boolean = false, cancelable:Boolean = false){
			this._data = data;
			this._url = url;
			super(type, bubbles, cancelable);
		}

		public function get data():Object {
			return this._data;
		}

		public function set data(data:Object):void {
			this._data = data;	
		}

		public function get url():String
		{
			return _url;
		}
		
		public function set infoFormat(value:String):void
		{
			this._infoFormat = value;
		}
		
		public function get infoFormat():String
		{
			return this._infoFormat;
		}

	}
}

