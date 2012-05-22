package org.openscales.core.layer.capabilities
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;

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
		protected var _format:String = null;
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
			return this._capabilities;
		}

		/**
		 * Instanciate a layer contained in the capabilities. 
		 * <p>This method should be called after having <code>read</code> the capabilities. If it is not the case, or if the layer name does not match any of the capabilities, the method will return <code>null</code></p>.
		 * 
		 * @param name The name of the layer to be instanciated
		 */ 
		public function instanciate(name:String):Layer{
			return null;
		}		

		public function get version():String {
			return _version;
		}

	}
}

