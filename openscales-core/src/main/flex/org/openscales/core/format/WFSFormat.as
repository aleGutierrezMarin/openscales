package org.openscales.core.format
{
	import flash.xml.XMLNode;
	
	import mx.messaging.management.Attribute;
	
	import org.openscales.core.Trace;
	import org.openscales.core.feature.DescribeFeature;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.State;
	import org.openscales.core.layer.ogc.WFS;

	/**
	 * WFS writer extending GML format.
	 * Useful to WFS-T functionality.
	 */
	public class WFSFormat extends GMLFormat
	{

		private var _layer:WFS = null;

		/**
		 * WFSFormat constructor
		 *
		 * @param layer
		 */
		public function WFSFormat(layer:WFS) {
			super(layer.addFeature,layer.featuresids,true);
			this.layer = layer;
			if (this.layer.featureNS) {
				this._featureNS = this.layer.featureNS;
			}    
			if (layer.geometryColumn) {
				this._geometryName = layer.geometryColumn;
			}
			var wfsLayer:WFS = this.layer as WFS;
			if (wfsLayer.typename) {
				this._featureName = wfsLayer.typename;
			}
		}

		/**
		 * Takes a feature list, and generates a WFS-T Transaction
		 *
		 * @param features
		 */
		override public function write(features:Object):Object {
			var transaction:XML = new XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"     +
				"<" + this._wfsprefix + ":Transaction service=\"WFS\" version=\"1.0.0\"  " +
				" xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" "                  +
				" xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\""                   +
				" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""                 +
				" xsi:schemaLocation=\"http://www.opengis.net/wfs "                        +
				" http://www.openplans.org/topp"                                           +
				" http://schemas.opengis.net/wfs/1.0.0/WFS-transaction.xsd\  "             +
				  describeFeatureType + "\" " +
				" xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\" >" +
				"</" + this._wfsprefix + ":Transaction>");
			
			for (var i:int=0; i < features.length; i++) {
				switch (features[i].state) {
					case State.INSERT:
						transaction.appendChild(this.insert(features[i]));
						break;
					case State.UPDATE:
						transaction.appendChild(this.update(features[i]));
						break;
					case State.DELETE:
						transaction.appendChild(this.remove(features[i]));
						break;
				}
			}
			return transaction;
		}

		/**
		 * Create an XML feature
		 *
		 * @param feature A vectorfeature
		 */
		override public function createFeatureXML(feature:Feature):XML {
			var geometryNode:XML = this.buildGeometryNode(feature.geometry);
			var geomContainer:XML = new XML("<" + this._featurePrefix + ":" + this._geometryName +
				" xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\">" +
				"</" + this._featurePrefix + ":" + this._geometryName + ">");
			
			geomContainer.appendChild(geometryNode);
			var featureContainer:XML = new XML("<"+ this._featureName + "" +
				                               " xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\">" +
											   "</" + this._featureName + ">");
			featureContainer.appendChild(geomContainer);
			var attr:String;
			for(attr in feature.attributes) {
				var attrText:XMLNode = new XMLNode(2, feature.attributes[attr]); 
				var nodename:String = attr;
				if (attr.search(":") != -1) {
					nodename = attr.split(":")[1];
				}    
				var attrContainer:XML = new XML("<" + this._featurePrefix + ":" + nodename +
					                            " xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\">" +
												"</" + this._featurePrefix + ":" + nodename + ">");
				attrContainer.appendChild(attrText);
				featureContainer.appendChild(attrContainer);
			}    
			return featureContainer;
		}

		/**
		 * Takes a feature, and generates a WFS-T Transaction "Insert"
		 *
		 * @param feature
		 */
		public function insert(feature:Feature):XML {
			var insertNode:XML = new XML("<" + this._wfsprefix + ":Insert" +
				" xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\">"  +
				"</" + this._wfsprefix + ":Insert>");
			insertNode.appendChild(this.createFeatureXML(feature));
			return insertNode;
		}

		/**
		 * Takes a feature, and generates a WFS-T Transaction "Update"
		 *
		 * @param feature
		 */
		public function update(feature:Feature):XML {
			if (!feature.name) { Trace.error("Can't update a feature for which there is no FID."); }
		
			var updateNode:XML = new XML("<wfs:Update xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\" ></wfs:Update>");
			updateNode.@typeName = this._layer.typename;
			
			var propertyNode:XML = new XML("<wfs:Property xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\" ></wfs:Property>");
			var nameNode:XML = new XML("<wfs:Name xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\" >"
				                       + this._geometryName 
									   + "</wfs:Name>");
			
			propertyNode.appendChild(nameNode);
			//TODO improve this
			var valueNode:XML = new XML("<wfs:Value xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\">" 
				                        + this.buildGeometryNode(feature.geometry).toString() 
										+ "</wfs:Value>");
			
			propertyNode.appendChild(valueNode);
			updateNode.appendChild(propertyNode);
			
			var filterNode:XML = new XML("<ogc:Filter xmlns:ogc=\"http://www.opengis.net/ogc\" ></ogc:Filter>");
			var filterIdNode:XML = new XML("<ogc:FeatureId xmlns:ogc=\"http://www.opengis.net/ogc\" ></ogc:FeatureId>");
			filterIdNode.@fid = feature.name;
			filterNode.appendChild(filterIdNode);
			updateNode.appendChild(filterNode);
			

			return updateNode;
		}

		/**
		 * Takes a feature, and generates a WFS-T Transaction "Delete"
		 *
		 * @param feature
		 */
		public function remove(feature:Feature):XMLNode {
			//todo change  xmlNode(oldway) to xml
			if (!feature.attributes.fid) { 
				Trace.error("Can't update a feature for which there is no FID."); 
				return null; 
			}
			var deleteNode:XMLNode = new XMLNode(1, "wfs:Delete");
			deleteNode.attributes.typeName = this._layerName;

			var filterNode:XMLNode = new XMLNode(1, "ogc:Filter");
			var filterIdNode:XMLNode = new XMLNode(1, "ogc:FeatureId");
			filterIdNode.attributes.fid = feature.attributes.fid;
			filterNode.appendChild(filterIdNode);
			deleteNode.appendChild(filterNode);

			return deleteNode;
		}
		
		/**
		 * parse describe response and tranform in DescribeFeature
		 * 
		 **/
		public function describeFeatureRead(value:XML):DescribeFeature{
			var describeFeature:DescribeFeature = null;
			var length:uint = value..*::element.length()
			
			if (length > 0){
				var elements:XMLList;
				var name:String = "";
				var attributes:Object = new Object();
				var geometryType:String;
				elements = value..*::element;
				
				for(var i:uint;i<length;i++ ){
					name = elements[i].@name;
					if(name != this._geometryName){
						attributes[name] = elements[i].@type;
					}else{
						geometryType = elements[i].@type;
					}
				
				}
				describeFeature = new DescribeFeature(geometryType,attributes);	
			
			}
				
			return describeFeature;
		}

		override public function destroy():void {
			this.layer = null;
			super.destroy();
		}

		//Getters and Setters
		public function get layer():WFS {
			return this._layer;
		}

		public function set layer(value:WFS):void {
			this._layer = value;
		}
		/**
		 *http://localhost:8080/geoserver/wfs/DescribeFeatureType?typename=topp:ebo_couchelocale3l\" 
		 **/
		public function get describeFeatureType():String{
			return this._layer.url + "/DescribeFeatureType?typename=" + this._layer.typename;
		}

	}
}

