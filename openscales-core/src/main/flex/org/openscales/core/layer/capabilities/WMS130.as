// ActionScript file
package org.openscales.core.layer.capabilities
{
	import org.openscales.geometry.basetypes.Bounds;

	/**
	 * WFS 1.1.1 capabilities parser
	 */
	public class WMS130 extends CapabilitiesParser
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
		public function WMS130()
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
			
			var srsCode:String = null;
			for each (var layer:XML in layerNodes){

				layerCapabilities.put("Format", this._format);
				
				name = layer.Name;
				layerCapabilities.put("Name", name);

				value = layer.Title;
				layerCapabilities.put("Title", value);

				value = layer.Format.toString();
				while (value.search(" ") > 0) {
					value = value.replace(" ",",");
				}
				layerCapabilities.put("Format", value);
				this._format = value;
				
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
				
				left = new Number(layer.BoundingBox.westBoundLongitude);
				bottom = new Number(layer.BoundingBox.southBoundLatitude);
				right = new Number(layer.BoundingBox.eastBoundLongitude);
				top = new Number(layer.BoundingBox.northBoundLatitude);
				
				// in decimal degrees => EPSG:4326
				layerCapabilities.put("EX_GeographicBoundingBox", new Bounds(left,bottom,right,top,"EPSG:4326"));
				
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

