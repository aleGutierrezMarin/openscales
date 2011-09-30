package org.openscales.core.format
{
	import flash.xml.XMLNode;
	
	import mx.messaging.management.Attribute;
	
	import org.openscales.core.utils.Trace;
	import org.openscales.core.utils.UID;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.DescribeFeature;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.State;
	import org.openscales.core.format.gml.GMLFormat;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WFST;
	import org.openscales.core.layer.ogc.WFST.Transaction;
	
	/**
	 * WFS writer extending GML format.
	 * Useful to WFS-T functionality.
	 */
	public class WFSFormat extends GMLFormat
	{
		
		private var _layer:WFS = null;
		
		private var _wfsns:String = "http://www.opengis.net/wfs";
		
		private var _wfsprefix:String = "wfs";
		
		private var _ogcns:String = "http://www.opengis.net/ogc";
		
		private var _ogcprefix:String = "ogc";
		
		private var _featureNS:String = "http://www.openplans.org/topp";
		
		private var _featurePrefix:String = "topp"; 
		
		private var _featureName:String = "featureMember";
		
		private var _layerName:String = "features";
		
		private var _geometryName:String = "geometry";
		
		private var _collectionName:String = "FeatureCollection";
		
		private var _version:String = "1.0.0";
		
		/**
		 * WFSFormat constructor
		 *
		 * @param layer
		 */
		public function WFSFormat(layer:WFST) {
			super(layer.addFeature,layer.featuresids,true);
			this.layer = layer;
			
			if (layer.geometryColumn) {
				this._geometryName = layer.geometryColumn;
			}
			
			if (layer.typename) {
				this._featureName = layer.typename;
			}
		}
		
		/**
		 * Takes a feature list, and generates a WFS-T Transaction
		 *
		 * @param features
		 */
		override public function write(features:Object):Object {
			var transaction:XML = new XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"     +
				"<" + this._wfsprefix + ":Transaction service=\"WFS\" version=\"" + this._version + "\"  " +
				" xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" "                  +
				" xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\""                   +
				" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""                 +
				" xsi:schemaLocation=\"http://www.opengis.net/wfs "                        +
				this._featureNS                                                          +
				" http://schemas.opengis.net/wfs/1.0.0/WFS-transaction.xsd\  "             +
				this.describeFeatureType +" \" " +
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
		public function createFeatureXML(feature:Feature):XML {
			var geometryNode:XML = this.buildGeometryNode(feature.geometry);
			var geomContainer:XML = new XML("<" + this._featurePrefix + ":" + this._geometryName +
				" xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\">" +
				"</" + this._featurePrefix + ":" + this._geometryName + ">");
			
			geomContainer.appendChild(geometryNode);
			var featureContainer:XML = new XML("<"+ this._featureName + "" +
				" xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\">" +
				"</" + this._featureName + ">");
			featureContainer.appendChild(geomContainer);
			addAttributesInsert(featureContainer,feature);
			return featureContainer;
		}
		
		public function addAttributesInsert(featureContainer:XML,feature:Feature):void{
			var attr:String;
			for(attr in feature.attributes) {
				//todo change this oldway xmlnodes
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
			
		}
		
		public function addAttributesUpdate(featureContainer:XML,feature:Feature):void{
			var attr:String;
			for(attr in feature.attributes) {
				
				//todo change this oldway xmlnodes
				var attrText:XMLNode = new XMLNode(2, feature.attributes[attr]); 
				var nodename:String = attr;
				if (attr.search(":") != -1) {
					nodename = attr.split(":")[1];
				}   
				if(nodename == "coordinates") continue;
				var propertyNode:XML = new XML("<" + this._wfsprefix + ":Property xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\" >" +
					"</" + this._wfsprefix + ":Property>");
				var nameNode:XML = new XML("<" + this._wfsprefix + ":Name xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\" >" +
					"</" + this._wfsprefix + ":Name>");
				var valueNode:XML = new XML("<" + this._wfsprefix + ":Value xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\" >" +
					"</" + this._wfsprefix + ":Value>");
				nameNode.appendChild(nodename);
				valueNode.appendChild(attrText);
				propertyNode.appendChild(nameNode);
				propertyNode.appendChild(valueNode)
				featureContainer.appendChild(propertyNode);
			}    
			
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
			insertNode.@handle = feature.name;
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
			updateNode.@handle = feature.name;
			
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
			addAttributesUpdate(updateNode,feature);
			
			
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
		public function remove(feature:Feature):XML {
			//todo must be tested
			if (!feature.attributes.fid) { 
				Trace.error("Can't update a feature for which there is no FID."); 
				return null; 
			}
			var deleteNode:XML = new XML("<wfs:Delete></wfs:Delete>");
			deleteNode.@handle = feature.name;
			deleteNode.@typeName = this._layerName;
			
			var filterNode:XML = new XML("<ogc:Filter></ogc:Filter>");
			var filterIdNode:XML = new XML("<ogc:FeatureId></ogc:FeatureId>");
			filterIdNode.@fid = feature.attributes.fid;
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
			var length:uint = value..*::element.length();
			
			if (length > 0){
				var elements:XMLList;
				var name:String = "";
				var attributes:Object = new Object();
				var geometryType:String;
				elements = value..*::element;
				
				for(var i:uint;i<length;i++ ){
					name = elements[i].@name;
					//if(name == "__gid" ) continue;
					if(name != this._geometryName){
						attributes[name] = elements[i].@type;
					}else{
						geometryType = elements[i].@type;
					}
					
				}
				describeFeature = new DescribeFeature(geometryType,attributes);	
				describeFeature.setGeometryTypeFromGMLFormat(geometryType);
				
			}
			return describeFeature;
		}
		/**
		 * 
		 * @param xml
		 * @param transactions
		 * TODO improve to manage exception
		 */		
		public function readTransactionResponse(xml:XML,transactions:Vector.<Transaction>):void{
			
			//if(xml.localName() != "WFS_TransactionResponse" ) return;
			/**
			 * in the specifiaction there are writed, the same order
			 * */
			var featureId:XMLList = xml..*::FeatureId;
			var length:uint = featureId.length();
			for(var i:uint = 0; i < length; ++i){
				//update just the operation from this transaction and not the old
				if(transactions[i].state == Transaction.NOTSEND){
					if(xml.localName() != "ServiceExceptionReport" ) {
						if(featureId[i].@fid != "none" && transactions[i].feature.state == State.INSERT ){
							transactions[i].feature.name = featureId[i].@fid;
							transactions[i].id = featureId[i].@fid;
						}
						transactions[i].feature.state = State.UNKNOWN;
						transactions[i].state = Transaction.SUCCESS;
					} else{
						transactions[i].state = Transaction.FAIL;
					}
				}
			} 
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
		
		public function get featurePrefix():String
		{
			return _featurePrefix;
		}
		
		public function set featurePrefix(value:String):void
		{
			_featurePrefix = value;
		}
		
		public function get featureNS():String
		{
			return _featureNS;
		}
		
		public function set featureNS(value:String):void
		{
			_featureNS = value;
		}
		/**
		 * example
		 * http://localhost:8080/geoserver/wfs/DescribeFeatureType?typename=topp:states 
		 **/
		public function get describeFeatureType():String{
			return this._layer.url + "/DescribeFeatureType?typename=" + this._layer.typename+"&version="+ this._version;
		}
		
	}
}

