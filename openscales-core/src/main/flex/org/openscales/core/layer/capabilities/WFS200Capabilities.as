package org.openscales.core.layer.capabilities
{
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.proj4as.ProjProjection;
	import org.openscales.core.style.Style;
	import org.openscales.core.basetypes.maps.HashMap;


	/**
	 * WFS 2.0.0 capabilities parser
	 */
	public class WFS200Capabilities extends CapabilitiesParser
	{
		
		private namespace _wfsns = "http://www.opengis.net/wfs/2.0";
		private namespace _owsns = "http://www.opengis.net/ows/1.1";

		/**
		 * WFS 2.0.0 capabilities parser
		 */
		public function WFS200Capabilities()
		{
			super();

			this._version = "2.0.0";

			this._layerListNode = "FeatureTypeList";
			this._layerNode = "FeatureType";
			this._name = "Name";
			this._title = "Title";
			this._srs = "DefaultCRS";
			this._abstract = "Abstract";
			this._latLonBoundingBox = "WGS84BoundingBox";
		}

		/**
		 * Method which parses the XML capabilities file returned by the WFS server
		 *
		 * @param doc Is the XML document to parse.
		 * @return An HashMap containing the capabilities of layers available on the server.
		 */
		public override function read(doc:XML):HashMap {

			use namespace _wfsns;
			use namespace _owsns;

			var featureCapabilities:HashMap = new HashMap();
			var value:String = null;
			var name:String = null;
			var projection:String = null;
			var latLon:Bounds = null;
			var lowerCorner:String; var upperCorner:String; var bounds:String;

			var featureNodes:XMLList = doc..*::FeatureType;
			this.removeNamespaces(doc);

			for each (var feature:XML in featureNodes){

				name = feature.Name;
				featureCapabilities.put("Name", name);

				value = feature.Title;
				featureCapabilities.put("Title", value);

				projection = feature.DefaultCRS;
				projection = projection.substr(projection.indexOf("EPSG"));
				featureCapabilities.put("SRS", projection);

				var otherSRSNodes:XMLList = feature.OtherCRS;
				var otherSRS:Vector.<String> = new Vector.<String>();
				for each (var srs:XML in otherSRSNodes)
				{
					value = srs.toString();
					value = value.substr(value.indexOf("EPSG"));
					if (value != "")
						otherSRS.push(srs.toString());
				}
				
				featureCapabilities.put("OtherSRS", otherSRS);
				
				value = feature.Abstract;
				featureCapabilities.put("Abstract", value);


				var boundingBoxes:XMLList = feature..*::WGS84BoundingBox;
				lowerCorner = feature.WGS84BoundingBox.LowerCorner;
				upperCorner = feature.WGS84BoundingBox.UpperCorner;
				bounds = lowerCorner.replace(" ",",");
				bounds += ",";
				bounds += upperCorner.replace(" ",",");
				latLon = Bounds.getBoundsFromString(bounds+","+Geometry.DEFAULT_SRS_CODE);
				featureCapabilities.put("Extent", latLon);

				this._capabilities.put(name, featureCapabilities);

				//We cannot use clear() or reset() or we'll loose the datas
				featureCapabilities = new HashMap();
			}



			return this._capabilities;
		}

		override public function instanciate(name:String):Layer{
			
			if(!_capabilities)return null;
			var layerData:HashMap = _capabilities.getValue(name);
			if(!layerData)return null;
			
			var wfs:WFS;
			
			var identifier:String = layerData.getValue("Name");
			var title:String = layerData.getValue("Title");
			var srs:String= layerData.getValue("SRS");
			var abs:String = layerData.getValue("Abstract");
			var maxExtent:String = layerData.getValue("Extent");
			
			wfs = new WFS(identifier,"",identifier,"2.0.0");
			wfs.displayedName = title;
			wfs.projection = ProjProjection.getProjProjection(srs);
			wfs.abstract = abs;
			wfs.maxExtent = maxExtent;
			wfs.style = Style.getDefaultStyle();
			
			return wfs;
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

