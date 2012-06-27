// ActionScript file
package org.openscales.core.layer.capabilities
{
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;

	/**
	 * WFS 1.1.1 capabilities parser
	 */
	public class WMS130Capabilities extends CapabilitiesParser
	{
		import org.openscales.core.basetypes.maps.HashMap;
		private namespace _wmsns = "http://www.opengis.net/wms";

		/**
		 * @private
		 * Minimum bounding rectangle in decimal degrees covered by the layer
		 */
		private var _exGeographicBoundingBox:String;

		/**
		 * WFS 1.3.0 capabilities parser
		 */
		public function WMS130Capabilities()
		{
			super();

			this._version = "1.3.0";
			
			this._layerNode = "Layer";
			this._name = "Name";
			this._format = "Format";
			this._title = "Title";
			this._srs = "CRS";
			this._abstract = "Abstract";
			this._keywordList = "KeywordList";
			this._latLonBoundingBox = "LatLonBoundingBox";
			this._exGeographicBoundingBox = "EX_GeographicBoundingBox";
		}

		/**
		 * Method which parses the XML capabilities file returned by the WFS server
		 *
		 * @param doc Is the XML document to parse.
		 * @return An HashMap containing the capabilities of layers available on the server.
		 */
		public override function read(doc:XML):HashMap {

			use namespace _wmsns;

			var layerCapabilities:HashMap = new HashMap();
			var value:String = null;
			var name:String = null;
			var x:XML;
			var left:Number, bottom:Number, right:Number, top:Number;

			var layerNodes:XMLList = doc..*::Layer;
			var getMapNodes:XMLList = doc..*::GetMap;
			
			this.removeNamespaces(doc);

			for each (var getMap:XML in getMapNodes){
				var fomatNodes:XMLList = getMap.Format;
				this._format = "";
				for each (var fmt:XML in fomatNodes)
				{
					value = fmt.toString();
					if (this._format != "")
						this._format = this._format + "," + value;
					else
						this._format = value;
				}
			}
			
			for each (var layer:XML in layerNodes){

				layerCapabilities.put("Format", this._format);
				
				name = layer.Name;
				layerCapabilities.put("Name", name);

				value = layer.Title;
				layerCapabilities.put("Title", value);

				value = layer.Format.toString();
				if(value && value != ""){
					while (value.search(" ") > 0) {
						value = value.replace(" ",",");
					}
					layerCapabilities.put("Format", value);
					this._format = value;
				}
				
				var srsNodes:XMLList = layer.CRS;
				var csSrsList:String = "";
				for each (var srs:XML in srsNodes)
				{
					value = srs.toString();
					if (csSrsList != "")
						csSrsList = csSrsList + "," + value;
					else
						csSrsList = value;
				}
				layerCapabilities.put("CRS", csSrsList);
				
				value = layer.Abstract;
				layerCapabilities.put("Abstract", value);

				value = layer.KeywordList;
				layerCapabilities.put("KeywordList", value);
				
				left = new Number(layer.EX_GeographicBoundingBox.westBoundLongitude);
				bottom = new Number(layer.EX_GeographicBoundingBox.southBoundLatitude);
				right = new Number(layer.EX_GeographicBoundingBox.eastBoundLongitude);
				top = new Number(layer.EX_GeographicBoundingBox.northBoundLatitude);
				
				// in decimal degrees => Geometry.DEFAULT_SRS_CODE
				layerCapabilities.put("EX_GeographicBoundingBox", new Bounds(left,bottom,right,top,Geometry.DEFAULT_SRS_CODE));
				
				left = new Number(layer.BoundingBox.@minx.toXMLString());
				bottom = new Number(layer.BoundingBox.@miny.toXMLString());
				right = new Number(layer.BoundingBox.@maxx.toXMLString());
				top = new Number(layer.BoundingBox.@maxy.toXMLString());
    						
				layerCapabilities.put("BoundingBox", new Bounds(left,bottom,right,top,csSrsList));
				
				if (name != "")
					this._capabilities.put(name, layerCapabilities);

				//We cannot use clear() or reset() or we'll loose the datas
				layerCapabilities = new HashMap();
			}

			return this._capabilities;
		}

		/**
		 * This method instanciate the layer listed in capabilities whose Name tag match the <code>name</code> parameter. Be aware that the <code>Layer.url</code> property won't be set since this information is not hold by capabilities.
		 * 
		 * @param The layer name as contained in capabilities
		 * @return A WMS instance where format is image/png or the first capabilities format if image/png is not supported. Also projection is EPSG:4326 or first projection supported if 4326 is not in capabilities. 
		 */ 
		override public function instanciate(name:String):Layer{
			if(!_capabilities) return null;
			var layerData:HashMap = _capabilities.getValue(name);
			if(!layerData)return null;
			var identifier:String = layerData.getValue("Name");
			var formats:String = layerData.getValue("Format")
			var format:String = formats.match(/image(\/png)/gi).length > 0 ? "image/png" : formats.split(",")[0];
			var crss:String = layerData.getValue("CRS");
			var crs:String = crss.match(/EPSG:4326/gi).length > 0 ? "EPSG:4326" : crss.split(",")[0];
			
			var wmsLayer:WMS = new WMS(identifier,"",identifier,"",format);
			wmsLayer.displayedName = layerData.getValue("Title");
			wmsLayer.version = "1.3.0";
			wmsLayer.format = format;
			wmsLayer.projection = crs!=""?crs:Layer.DEFAULT_PROJECTION;
			wmsLayer.abstract = layerData.getValue("Abstract");
			wmsLayer.maxExtent = layerData.getValue("EX_GeographicBoundingBox");
			wmsLayer.transparent = true;
			wmsLayer.availableProjections = new Vector.<String>(crss.split(","));
			return wmsLayer;
			
		}
		
		/**
		 * Method to remove the additional namespaces of the XML capabilities file.
		 *
		 * @param doc The XML file
		 */
		private function removeNamespaces(doc:XML):void {
			var namespaces:Array = doc.inScopeNamespaces();
			var ns:String;
			for each (ns in namespaces) {
				doc.removeNamespace(new Namespace(ns));
			}
		}

	}
}

