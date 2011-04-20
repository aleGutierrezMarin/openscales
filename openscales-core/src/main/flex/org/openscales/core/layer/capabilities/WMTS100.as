package org.openscales.core.layer.capabilities
{
	
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;

	/**
	 * WMTS 1.0.0 capabilities parser
	 * 
	 * @author slopez
	 */
	public class WMTS100 extends CapabilitiesParser
	{
		private namespace _wmtsns = "http://www.opengis.net/wmts/1.0";
		private namespace _owsns = "htttp://www.opengis.net/ows/1.1" 
		
		public function WMTS100()
		{
			super();
			this._version = "1.0.0";

			this._layerNode = "FeatureType";
			this._title = "ows:Title";
			this._abstract = "ows:Abstract";
		}
		
		/**
		 * @Inherit
		 */
		public override function read(doc:XML):HashMap {
			use namespace _wmtsns;
			use namespace _owsns;
			
			var matrixSets:HashMap = new HashMap();
			var layerCapabilities:HashMap = new HashMap();
			var node:XML;
			
			//parse TilematrixSets
			var matrixSetsNodes:XMLList = doc..*::TileMatrixSet;
			
			var identifier:String;
			var supportedCRS:String;
			var tileMatrices:HashMap;
			
			for each (node in matrixSetsNodes){
				if(node.parent().localName()=="Contents") {
					Trace.debug(node.Identifier);
				}
			}
			//parse Layers
			var layersNodes:XMLList = doc..*::Layer;
			for each (node in layersNodes){
				if(node.parent().localName()=="Contents") {
					
				}
			}
			
			return this._capabilities;
		}
	}
}