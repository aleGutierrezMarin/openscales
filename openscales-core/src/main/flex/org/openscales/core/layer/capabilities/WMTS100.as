package org.openscales.core.layer.capabilities
{
	
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.ogc.WMTS.TileMatrix;
	import org.openscales.core.layer.ogc.WMTS.TileMatrixSet;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * WMTS 1.0.0 capabilities parser
	 *
	 * 
	 * Supported tags are the followings (other ones are disregarded):  
	 *<ul>
	 *<li>Layer</li>
	 *<ul>
	 *	<li>Identifier</li>
	 *	<li>TileMatrixSetLink</li>
	 *  <ul><li>TileMatrixSet</li></ul>
	 *</ul>
	 *<li>TileMatrixSet</li>
	 *<ul>
	 *	<li>Identifier</li>
	 *	<li>SupportedCRS</li>
	 *	<li>TileMatrix</li>
	 *	<ul>
	 *		<li>Identifier</li>
	 *		<li>ScaleDenominator</li>
	 *		<li>TopLeftCorner</li>
	 * 		<li>TileWidth</li>
	 *		<li>TileHeight</li>
	 *		<li>MatrixWidth</li>
	 *		<li>MatrixHeight</li>
	 *	</ul>
	 *</ul>
	 *</ul>
	 * 
	 * @author slopez
	 * @author htulipe
	 */
	public class WMTS100 extends CapabilitiesParser
	{
		private namespace _wmtsns = "http://www.opengis.net/wmts/1.0";
		private namespace _owsns = "http://www.opengis.net/ows/1.1"; 
		
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
			
			this.removeNamespaces(doc);
			
			/*
			Notes: In WMTS, the getCapapabilites document contains both Layer tags 
			and TileMatrixSet tags at the same level. 
			Knowing that Layer tags reference one or more
			tile matrix sets, the method goes in two steps:
			
			1. The method parses TileMatrixSet tags and creates an HashMap of these.
			
			2. In a second time, the method parses Layer tags and feed this._capabilities with an entry for each layer
			That entry points to an hashmap containing references to all tile matrix set linked by the layer (references 
			are taken from the hashmap created in first step)
			
			*/
			
			use namespace _wmtsns;
			use namespace _owsns;
			
			// FIRST STEP
			var matrixSets:HashMap = new HashMap(); // the hahsmap containing all tile matrix sets 
			var node:XML;
			
			//parse TilematrixSets
			var matrixSetsNodes:XMLList = doc..*::TileMatrixSet;
			
			// Variables for creating a TileMatrixSet
			var tileMatrixSetIdentifier:String;
			var supportedCRS:String;
			var tileMatrices:HashMap;
			
			// Variables for creating a TileMatrix
			var tileMatrixIdentifier:String;
			var scaleDenominator:Number;
			var topLeftCorner:Location;
			var topLeftCornerString:String;
			var topLeftCornerArray:Array;
			var tileWidth:uint;
			var tileHeight:uint;
			var matrixHeight:uint;
			var matrixWidth:uint;
			var tileMatrix:TileMatrix;
			var res:Number;
			
			matrixSets = new HashMap();
			// For each matrix set
			for each (node in matrixSetsNodes){
				if(node.parent().localName()=="Contents") {
				
					tileMatrices = new HashMap();
					
					// Getting identifier
					tileMatrixSetIdentifier = node._owsns::Identifier;
					if(tileMatrixSetIdentifier == null) return null; // Can't be null, it will be the hash map key
					
					// TODO SupportedCRS is URI formated whereas OpenScale Projection's code are not, need to convert
					supportedCRS = node._owsns::SupportedCRS;
					
					if( supportedCRS == null)
						continue; // Can't be null need to alculate tile matrices hash map key
					
					supportedCRS = supportedCRS.replace("urn:ogc:def:crs:","").replace("::",":");
					
					if(supportedCRS=="")
						continue;
					
					// For each tile matrix 
					for each (var XMLTileMatrix:XML in node.TileMatrix)
					{
						tileMatrixIdentifier = XMLTileMatrix._owsns::Identifier;
						scaleDenominator = XMLTileMatrix.ScaleDenominator;
						
						// Creating a Location from a string formated like "long lat"
						topLeftCornerString = XMLTileMatrix.TopLeftCorner;
						if(topLeftCornerString != null)
						{
							topLeftCornerArray = topLeftCornerString.split(" ");
							topLeftCorner = new Location(
													parseFloat(topLeftCornerArray[1]),
													parseFloat(topLeftCornerArray[0]),
													supportedCRS);
						}	
						
						tileWidth = XMLTileMatrix.TileWidth;
						tileHeight = XMLTileMatrix.TileHeight;
						matrixWidth = XMLTileMatrix.MatrixWidth;
						matrixHeight = XMLTileMatrix.MatrixHeight;
						
						// If CRS is known (need to check or will throw an error)
						if(ProjProjection.getProjProjection(supportedCRS) != null)
						{
							res = Unit.getResolutionFromScaleDenominator(
								scaleDenominator, 
								ProjProjection.getProjProjection(supportedCRS).projParams.units);
						}
						else
						{
							res = Unit.getResolutionFromScaleDenominator(scaleDenominator)
						}
						
						// Adding the tile matrix to the hashmap
						tileMatrices.put(res, new TileMatrix(
														tileMatrixIdentifier,
														scaleDenominator,
														topLeftCorner,
														tileWidth,
														tileHeight,
														matrixWidth,
														matrixHeight));
						
					}
					
					matrixSets.put(tileMatrixSetIdentifier, new TileMatrixSet(
															tileMatrixSetIdentifier, 
															supportedCRS, 
															tileMatrices));
				}
			}
			
			// END Of FIRST STEP
			// SECOND STEP
			
			//parse Layers
			var layersNodes:XMLList = doc..*::Layer;
			
			//Variables needed for parsing layers tag
			var linkedTileMatrixSets:HashMap; // map containing all linked tilematrix set for the layer
			var layerIdentifier:String; // Identifier of the layer
			var tileMatrixSetId:String; // Identifier of a tilematrixSet
			
			for each (node in layersNodes){
				if(node.parent().localName()=="Contents") {
					
					layerIdentifier  = node._owsns::Identifier;
					// layerIdentifier must be a non null non empty string because it will be an hash map key
					if (layerIdentifier == "" || layerIdentifier == null) return null;
					
					linkedTileMatrixSets = new HashMap();
					
					for each (var XMLTileMatrixSet:XML in node.TileMatrixSetLink)
					{
						tileMatrixSetId = XMLTileMatrixSet.TileMatrixSet;
						
						if(matrixSets.containsKey(tileMatrixSetId))
						{
							linkedTileMatrixSets.put(tileMatrixSetId, matrixSets.getValue(tileMatrixSetId))
						}
					}
				}
				
				this._capabilities.put(layerIdentifier, linkedTileMatrixSets);
			}
			
			// END OF SECOND STEP
			
			return this._capabilities;
		}
		
		/**
		 * Method to remove the additional namespaces of the XML capabilities file.
		 *
		 * @param doc The XML file
		 */
		private function removeNamespaces(doc:XML):void {
			var namespaces:Array = doc.inScopeNamespaces();
			for each (var ns:String in namespaces) {
				doc.removeNamespace(new Namespace(ns));
			}
		}
	}
}