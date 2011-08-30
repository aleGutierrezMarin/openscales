package org.openscales.core.layer.capabilities
{
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;

	/**
	 * Generic class for GetCapabilities parsers.
	 */
	internal class CapabilitiesParser
	{

		protected var _version:String;

		protected var _capabilities:HashMap = null;

		protected var _layerListNode:String = null;
		protected var _layerNode:String = null;
		protected var _capabilitiesPrefix:String = null;
		protected var _srs:String = null;
		protected var _latLonBoundingBox:String = null;
		protected var _title:String = null;
		protected var _name:String = null;
		protected var _abstract:String = null;
		protected var _keywordList:String = null;
		
		public function CapabilitiesParser()
		{
			_capabilities = new HashMap(false);
		}

		/**
		 * @param doc XML an XML tree representing a capabilities
		 * @return An Hash containing capabilities
		 */ 
		public function read(doc:XML):HashMap {
			Trace.warn("Not implemented method.");
			return this._capabilities;
		}


		public function get version():String {
			return _version;
		}

	}
}

