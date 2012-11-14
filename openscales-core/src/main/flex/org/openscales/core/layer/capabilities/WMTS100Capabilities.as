package org.openscales.core.layer.capabilities
{
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.layer.ogc.wmts.TileMatrix;
	import org.openscales.core.layer.ogc.wmts.TileMatrixSet;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * WMTS 1.0.0 capabilities parser
	 *
	 * 
	 * Supported tags are the followings (other ones are disregarded):  
	 *
	 * <ul>
	 * 		<li>Layer</li>
	 * 		<li>Layer.Identifier</li>
	 * 		<li>Layer.Style</li>
	 * 		<li>Layer.Style.Identifier</li>
	 * 		<li>Layer.Format</li>
	 * 		<li>Layer.TileMatrixSetLink</li>
	 * 		<li>Layer.TileMatrixSetLink.TileMatrixSet</li>
	 * 		<li>Layer.TileMatrixSetLink.TileMatrixSetLimits</li>
	 * 		<li>TileMatrixSet</li>
	 * 		<li>TileMatrixSet.Identifier</li>
	 * 		<li>TileMatrixSet.SupportedCRS</li>
	 * 		<li>TileMatrixSet.TileMatrix</li>
	 * 		<li>TileMatrixSet.TileMatrix.Identifier</li>
	 * 		<li>TileMatrixSet.TileMatrix.ScaleDenominator</li>
	 * 		<li>TileMatrixSet.TileMatrix.TopLeftCorner</li>
	 * 		<li>TileMatrixSet.TileMatrix.TileWidth</li>
	 * 		<li>TileMatrixSet.TileMatrix.TileHeight</li>
	 * 		<li>TileMatrixSet.TileMatrix.MatrixWidth</li>
	 * 		<li>TileMatrixSet.TileMatrix.MatrixHeight</li>	
	 * </ul>
	 * 
	 * @author slopez
	 * @author htulipe
	 */
	public class WMTS100Capabilities extends CapabilitiesParser
	{
		private namespace _wmtsns = "http://www.opengis.net/wmts/1.0";
		private namespace _owsns = "http://www.opengis.net/ows/1.1"; 
		
		public function WMTS100Capabilities()
		{
			super();
			this._version = "1.0.0";

			this._layerNode = "FeatureType";
			this._title = "ows:Title";
			this._abstract = "ows:Abstract";
		}
		
		/**
		 * 
		 * <p>
		 * for WMTS the returned value is an HashMap as follows:
		 * <br/>
		 * "TileMatrixSets" ==> HashMap(String ==> TileMatrixSet)<br/>
		 * "TileMatrixSetsLimits" ==> HashMap(String ==> TileMatrixSetLimits) (see doc of <code>parseLimits</code>) <br/>
		 * "Formats" ==> Array(String)<br/>
		 * "Styles" ==> Array(String)<br/>
		 * "Identifier" ==> String<br/>
		 * "Title" ==> String<br/>
		 * "DefaultStyle" ==> String
		 * </p> 
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
					var proj:ProjProjection = ProjProjection.getProjProjection(supportedCRS);
					if(!proj)
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
							if(proj.lonlat)
								topLeftCorner = new Location(
									parseFloat(topLeftCornerArray[0]),
									parseFloat(topLeftCornerArray[1]),
									proj);
							else
								topLeftCorner = new Location(
														parseFloat(topLeftCornerArray[1]),
														parseFloat(topLeftCornerArray[0]),
														proj);
						}	
						
						tileWidth = XMLTileMatrix.TileWidth;
						tileHeight = XMLTileMatrix.TileHeight;
						matrixWidth = XMLTileMatrix.MatrixWidth;
						matrixHeight = XMLTileMatrix.MatrixHeight;
						
						// If CRS is known (need to check or will throw an error)
						res = Unit.getResolutionFromScaleDenominator(
								scaleDenominator, 
								proj.projParams.units);
						
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
															proj.srsCode, 
															tileMatrices));
				}
			}
			
			// END Of FIRST STEP
			// SECOND STEP
			
			//parse Layers
			var layersNodes:XMLList = doc..*::Layer;
			
			//Variables needed for parsing layers tag
			var layerCapabilities:HashMap; // map containing all data about a layer
			var linkedTileMatrixSets:HashMap; // map containing all linked tilematrix set for the layer
			var tileMatrixSetLimits:HashMap; // map containing all tms limits
			var styles:Array; // array containg available styles for the layer
			var formats:Array; // array containing available formats for the layer
			
			var title:String; // The layer Title
			var layerIdentifier:String; // Identifier of the layer
			var tileMatrixSetId:String; // Identifier of a tilematrixSet
			var layerAbstract:String; // Abstract of the layer
			var lowerCornerArray:Array; // Array containing lower corner coordinates of wgs bbox
			var upperCornerArray:Array; // Array containing upper corner coordinates of wgs bbox
			
			var style:String;
			var defaultStyle:String;
			var format:String;
			
			for each (node in layersNodes){
				if(node.parent().localName()=="Contents") {
					
					layerAbstract = node._owsns::Abstract;
					
					layerIdentifier  = node._owsns::Identifier;
					// layerIdentifier must be a non null non empty string because it will be an hash map key
					if (layerIdentifier == "" || layerIdentifier == null) return null;
					
					layerCapabilities = new HashMap();
					linkedTileMatrixSets = new HashMap();
					tileMatrixSetLimits = new HashMap();
					styles = new Array();
					formats = new Array();
					
					// Identifier
					layerCapabilities.put("Identifier", layerIdentifier);
					
					layerCapabilities.put("Abstract", layerAbstract?layerAbstract:"");
					
					// Title
					title = node._owsns::Title;
					layerCapabilities.put("Title", title);
					
					for each (var XMLTileMatrixSet:XML in node.TileMatrixSetLink)
					{
						tileMatrixSetId = XMLTileMatrixSet.TileMatrixSet;
						
						
						
						if(node.*::TileMatrixSetLink[0].*::TileMatrixSetLimits.length() > 0){
							var XMLTileMatrixSetLimits:XML = node.*::TileMatrixSetLink[0].*::TileMatrixSetLimits[0];
							tileMatrixSetLimits.put(tileMatrixSetId, parseLimits(XMLTileMatrixSetLimits));
						}
						
						if(matrixSets.containsKey(tileMatrixSetId))
						{
							linkedTileMatrixSets.put(tileMatrixSetId, matrixSets.getValue(tileMatrixSetId));
						}
						
					}
					
					
					
					
					layerCapabilities.put("TileMatrixSets", linkedTileMatrixSets);
					layerCapabilities.put("TileMatrixSetsLimits", tileMatrixSetLimits);
					
					// Parsing Format tags
					for each (var XMLFormat:XML in node.Format)
					{
						format = XMLFormat;						
						formats.push(format);
					}
					
					layerCapabilities.put("Formats", formats);
					
					// Parsing Style tags
					for each(var XMLStyle:XML in node.Style)
					{
						
						style = XMLStyle._owsns::Identifier;	
						if (XMLStyle.@isDefault == "true")
						{
							defaultStyle = style;
						}
						styles.push(style);
					}
					
					layerCapabilities.put("Styles", styles);
					layerCapabilities.put("DefaultStyle", defaultStyle);
					
					//Parsing WGS84BoundingBox
					for each(var XMLWGS84BoundingBox:XML in node.WGS84BoundingBox){
						lowerCornerArray = XMLWGS84BoundingBox.LowerCorner.split(" ");
						upperCornerArray = XMLWGS84BoundingBox.UpperCorner.split(" ");
						layerCapabilities.put("WGS84BoundingBox",new Bounds(lowerCornerArray[0],lowerCornerArray[1],upperCornerArray[0],upperCornerArray[1],"EPSG:4326"));
					}
					
				}
				
				this._capabilities.put(layerIdentifier, layerCapabilities);
			}
			
			// END OF SECOND STEP
			
			return this._capabilities;
		}
		
		/**
		 * Parse a TileMatrixSetLimits XML node and transform it to an HashMap (each XML tag being a key)
		 * 
		 * @param TileMatrixSetLimits An XML code representing a TileMatrixSetLimits as specified by OGC
		 */
		public function parseLimits(TileMatrixSetLimits:XML):HashMap{
			var res:HashMap = new HashMap();
			var limitsHashMap:HashMap;
			var limits:XMLList = TileMatrixSetLimits.*::TileMatrixLimits;
			var tileMatrix:String;
			var minTileRow:String;
			var maxTileRow:String;
			var minTileCol:String;
			var maxTileCol:String;
			
			for each (var limitXML:XML in limits){
				tileMatrix  = minTileRow = maxTileRow = minTileCol = maxTileCol = "";
				limitsHashMap = new HashMap();
				tileMatrix = limitXML.*::TileMatrix[0];
				if(tileMatrix == "") continue;
				
				minTileRow = limitXML.*::MinTileRow[0];
				maxTileRow = limitXML.*::MaxTileRow[0];
				minTileCol = limitXML.*::MinTileCol[0];
				maxTileCol = limitXML.*::MaxTileCol[0];
				
				limitsHashMap.put("MinTileRow", minTileRow);
				limitsHashMap.put("MaxTileRow", maxTileRow);
				limitsHashMap.put("MinTileCol", minTileCol);
				limitsHashMap.put("MaxTileCol", maxTileCol);
				res.put(tileMatrix, limitsHashMap);
			}
			return res;
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
		
		override public function instanciate(name:String):Layer{
			if(!_capabilities)return null;
			var layerData:HashMap = _capabilities.getValue(name);
			if(!layerData)return null;
			
			var identifier:String = layerData.getValue("Identifier") as String;
			
			var tmss:Array = (layerData.getValue("TileMatrixSets") as HashMap).getKeys().sort();
			
			var tms:TileMatrixSet = (layerData.getValue("TileMatrixSets") as HashMap).getValue(tmss[0]);
			var crs:String;
			if(tms) crs = tms.supportedCRS;
			
			if(tmss.length ==0)return null;
			
			var formats:Array = (layerData.getValue("Formats") as Array).sort();
			
			var format:String = formats.length > 0? formats[0]:WMTS.WMTS_DEFAULT_FORMAT;
			
			var defStyle:String = layerData.getValue("DefaultStyle") as String;
			var wmts:WMTS = new WMTS(identifier,"",identifier,tmss[0],(layerData.getValue("TileMatrixSets") as HashMap),defStyle);
			wmts.format = format;
			wmts.projection = crs;
			wmts.displayedName = layerData.getValue("Title");
			wmts.abstract = layerData.getValue("Abstract");
			//wmts.tileMatrixSetsLimits = layerData.getValue("TileMatrixSetsLimits");
			wmts.maxExtent = layerData.getValue("WGS84BoundingBox");
			return wmts;
		}
	}
}