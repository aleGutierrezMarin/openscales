// ActionScript file
package org.openscales.core.layer.capabilities
{
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;

	/**
	 * WFS 1.1.1 capabilities parser
	 */
	public class WMS111Capabilities extends CapabilitiesParser
	{
		import org.openscales.core.basetypes.maps.HashMap;
		private namespace _wmsns = "http://www.opengis.net/wms";


		/**
		 * WFS 1.1.1 capabilities parser
		 */
		public function WMS111Capabilities()
		{
			super();

			this._version = "1.1.1";
			
			this._layerNode = "Layer";
			this._name = "Name";
			this._format = "Format";
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

				var srsNodes:XMLList = layer.SRS;
				var csSrsList:String = "";
				for each (var srs:XML in srsNodes)
				{
					value = srs.toString();
					if (csSrsList != "")
						csSrsList = csSrsList + "," + value;
					else
						csSrsList = value;
				}
				layerCapabilities.put("SRS", csSrsList);
				
				value = layer.Abstract;
				layerCapabilities.put("Abstract", value);

				value = layer.KeywordList;
				layerCapabilities.put("KeywordList", value);
				
				left = new Number(layer.LatLonBoundingBox.@minx.toXMLString());
				bottom = new Number(layer.LatLonBoundingBox.@miny.toXMLString());
				right = new Number(layer.LatLonBoundingBox.@maxx.toXMLString());
				top = new Number(layer.LatLonBoundingBox.@maxy.toXMLString());;

				layerCapabilities.put("LatLonBoundingBox", new Bounds(left,bottom,right,top,Geometry.DEFAULT_SRS_CODE));

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

