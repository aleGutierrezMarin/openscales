package org.openscales.core.format
{
	import flash.xml.XMLNode;
	
	import mx.messaging.management.Attribute;
	
	import org.openscales.core.Trace;
	import org.openscales.core.UID;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.DescribeFeature;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.State;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WFST.Transaction;
	
	/**
	 * WFS writer extending GML format.
	 * Useful to WFS-T functionality.
	 */
	public class WFS2Format extends GML32Format
	{

		private var _layer:WFS = null;
		
		protected var _wfsns:String = "http://www.opengis.net/wfs";
		
		protected var _wfsprefix:String = "wfs";
		
		protected var _ogcns:String = "http://www.opengis.net/ogc";

		protected var _fesns:String = "http://www.opengis.net/fes/2.0";
		
		protected var _ogcprefix:String = "ogc";
		
		private var _featureNS:String = "http://www.openplans.org/topp";
		
		private var _featurePrefix:String = "topp"; 
		
		protected var _featureName:String = "featureMember";
		
		protected var _layerName:String = "features";
		
		protected var _geometryName:String = "geometry";
		
		protected var _collectionName:String = "FeatureCollection";
		
		protected var _version:String = "2.0.0";
		
		private var wfsNS:Namespace;
		private var fesNS:Namespace;

		/**
		 * WFSFormat constructor
		 *
		 * @param layer
		 */
		public function WFS2Format(layer:WFS) {
			super(layer.addFeature,layer.featuresids,true); /* call GML32 constructor */
			this.layer = layer;
			if (layer.geometryColumn) {
				this._geometryName = layer.geometryColumn;
			}
			var wfsLayer:WFS = this.layer as WFS;
			if (wfsLayer.typename) {
				this._featureName = wfsLayer.typename;
			}
			wfsNS = new Namespace("wfs",this._wfsns);
			fesNS = new Namespace("fes",this._fesns);
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
			var geometryNode:XML = this.buildGeometryNode(feature.geometry); // or this.buildFeatureNode.children[1].children[0]
			var geomContainer:XML = new XML("<" + this._featurePrefix + ":" + this._geometryName + 
				//<topp:the_geom xmlns:topp="http://www.openplans.org/topp"/>; 
				// same ns or _featurePrefix (topp) and same geometryName (the_geom) for all the features? 
				" xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\">" +
				"</" + this._featurePrefix + ":" + this._geometryName + ">");
			
			geomContainer.appendChild(geometryNode);
			var featureContainer:XML = new XML("<"+ this._featureName + "" +
				                               " xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\">" +
											   "</" + this._featureName + ">"); // WFS 2: add feature id (feature.name)
			featureContainer.appendChild(geomContainer);
	
			
			addAttributesInsert(featureContainer,feature); 
			return featureContainer;
		}
		
		public function addAttributesInsert(featureContainer:XML,feature:Feature):void{
			var attr:String;
			for(attr in feature.attributes) {
				//todo change this oldway xmlnodes
				var attrText:XMLNode = new XMLNode(2, feature.attributes[attr]); // 1 or 3. why 2?
				var nodename:String = attr;
				if (attr.search(":") != -1) {
					nodename = attr.split(":")[1];
				}    
				var attrContainer:XML = new XML("<" + this._featurePrefix + ":" + nodename +
					" xmlns:" + this._featurePrefix + "=\"" + this._featureNS + "\">" +
					"</" + this._featurePrefix + ":" + nodename + ">");  
				attrContainer.appendChild(attrText);// add the value
				featureContainer.appendChild(attrContainer);
			}    
			
		}
		
		public function addAttributesUpdate(featureContainer:XML,feature:Feature):void{
			var attr:String;
			for(attr in feature.attributes) {
				
				var attrText:XMLNode = new XMLNode(2, feature.attributes[attr]); 
				var nodename:String = attr;
				if (attr.search(":") != -1) {
					nodename = attr.split(":")[1];
				}   
				if(nodename == "pos" || nodename == "posList") continue; // not allowed to add coords node  ?; 
				var propertyNode:XML = new XML("<Property></Property>");
				propertyNode.setNamespace(wfsNS);
				
				var nameNode:XML = new XML("<ValueReference></ValueReferece>");
				nameNode.setNamespace(wfsNS);
				var valueNode:XML = new XML("<Value></Value>");
				valueNode.setNamespace(wfsNS);
				
				nameNode.appendChild(nodename);
				valueNode.appendChild(attrText);// add the value for the node <Value>
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
			var insertNode:XML = new XML("<Insert></Insert>");
			insertNode.addNamespace(wfsNS);
			insertNode.setNamespace(wfsNS);
			
			insertNode.@handle = feature.name; // handle or id?
			insertNode.appendChild(this.createFeatureXML(feature));
			return insertNode;
		}

		/**
		 * Takes a feature, and generates a WFS-T Transaction "Update"
		 *
		 * @param feature
		 */
		public function update(feature:Feature):XML { // calls addAttributesUpdate;
			// what about changing the value of an attribute?
			if (!feature.name) { Trace.error("Can't update a feature for which there is no FID."); }
		
			var updateNode:XML = new XML("<Update></Update>");
			updateNode.addNamespace(wfsNS);
			updateNode.setNamespace(wfsNS);
			
			updateNode.@typeName = this._layer.typename;
			updateNode.@handle = feature.name; // why "handle" instead of "id"?
			
			var propertyNode:XML = new XML("<Property></Property>");
			propertyNode.setNamespace(wfsNS);
			var nameNode:XML = new XML("<ValueReference></ValueReference>"); // the node whose value (content) will be updated
			nameNode.appendChild(this._geometryName);
			
			propertyNode.appendChild(nameNode);
			//TODO improve this
			var valueNode:XML = new XML("<wfs:Value xmlns:" + this._wfsprefix + "=\"" + this._wfsns + "\">" 
				                        + this.buildGeometryNode(feature.geometry).toString() 
										+ "</wfs:Value>");
			propertyNode.appendChild(valueNode);
			updateNode.appendChild(propertyNode);
			addAttributesUpdate(updateNode,feature);// call in case you want to add NEW tags/attributes to the feature
			
			
			var filterNode:XML = new XML("<Filter></Filter>");
			filterNode.addNamespace(fesNS);
			filterNode.setNamespace(fesNS);
			var filterIdNode:XML = new XML("<ResourceId></ResourceId>");
			filterNode.setNamespace(fesNS);
			filterIdNode.@rid = feature.name;
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
				Trace.error("Can't remove a feature for which there is no FID."); 
				return null; 
			}
			var deleteNode:XML = new XML("<Delete></Delete>");
			deleteNode.setNamespace(wfsNS);
			deleteNode.@handle = feature.name;
			deleteNode.@typeName = this._layerName;

			var filterNode:XML = new XML("<Filter></Filter>");
			filterNode.addNamespace(fesNS);
			filterNode.setNamespace(fesNS);
			var filterIdNode:XML = new XML("<ResourceId></ResourceId>");
			filterIdNode.setNamespace(fesNS);
			filterIdNode.@rid = feature.attributes.fid;
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
import org.openscales.core.feature.State;
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
		 * there are written in the same order in the specification
		 * */
		var featureId:XMLList = xml..*::FeatureId;
		var length:uint = featureId.length();
		for(var i:uint = 0; i < length; ++i){
			//update only the operation from this transaction and not the old
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
		 *http://localhost:8080/geoserver/wfs/DescribeFeatureType?typename=topp:ebo_couchelocale3l\" 
		 **/
		public function get describeFeatureType():String{
			return this._layer.url + "/DescribeFeatureType?typename=" + this._layer.typename+"&version="+ this._version;
		}

	}
}

