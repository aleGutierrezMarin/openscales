package org.openscales.core.layer.capabilities
{
	import org.openscales.geometry.basetypes.Bounds;

	/**
	 * WFS 1.1.0 capabilities parser
	 */
	public class WMS110 extends CapabilitiesParser
	{
		import org.openscales.core.basetypes.maps.HashMap;
		private namespace _wmsns = "http://www.opengis.net/wms";


		/**
		 * WFS 1.1.0 capabilities parser
		 */
		public function WMS110()
		{
			super();

			this._version = "1.1.0";
			
			this._layerNode = "Layer";
			this._name = "Name";
			this._title = "Title";
			this._srs = "SRS";
			this._abstract = "Abstract";
			this._keywordList = "KeywordList";
			this._latLonBoundingBox = "LatLonBoundingBox";
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
			this.removeNamespaces(doc);

			var srsCode:String = null;
			for each (var layer:XML in layerNodes){

				name = layer.Name;
				layerCapabilities.put("Name", name);

				value = layer.Title;
				layerCapabilities.put("Title", value);

				value = layer.SRS.toString();
				while (value.search(" ") > 0) {
					value = value.replace(" ",",");
				}
				layerCapabilities.put("SRS", value);
				srsCode = value;

				value = layer.Abstract;
				layerCapabilities.put("Abstract", value);
				
				value = layer.KeywordList;
				layerCapabilities.put("KeywordList", value);

				left = new Number(layer.LatLonBoundingBox.@minx.toXMLString());
				bottom = new Number(layer.LatLonBoundingBox.@miny.toXMLString());
				right = new Number(layer.LatLonBoundingBox.@maxx.toXMLString());
				top = new Number(layer.LatLonBoundingBox.@maxy.toXMLString());;

				layerCapabilities.put("LatLonBoundingBox", new Bounds(left,bottom,right,top,"EPSG:4326"));

				left = new Number(layer.BoundingBox.@minx.toXMLString());
				bottom = new Number(layer.BoundingBox.@miny.toXMLString());
				right = new Number(layer.BoundingBox.@maxx.toXMLString());
				top = new Number(layer.BoundingBox.@maxy.toXMLString());;
						
				layerCapabilities.put("BoundingBox", new Bounds(left,bottom,right,top,srsCode));
				
				
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

