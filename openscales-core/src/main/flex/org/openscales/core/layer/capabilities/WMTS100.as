package org.openscales.core.layer.capabilities
{
	import org.openscales.core.basetypes.maps.HashMap;

	/**
	 * WMTS 1.0.0 capabilities parser
	 * 
	 * @author slopez
	 */
	public class WMTS100 extends CapabilitiesParser
	{
		private namespace _wmtsns = "http://www.opengis.net/wmts/1.0";
		
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
			var matrixSets:HashMap = new HashMap();
			var layerCapabilities:HashMap = new HashMap();
			var node:XML;
			
			//parse TilematrixSets
			var matrixSetsNodes:XMLList = doc..*::TileMatrixSet;
			for each (node in matrixSetsNodes){
				if(node.parent().localName()=="Contents") {
					
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