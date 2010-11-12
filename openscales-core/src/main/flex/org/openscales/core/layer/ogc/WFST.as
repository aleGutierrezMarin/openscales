package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.WFSTFeatureEvent;
	import org.openscales.core.events.WFSTLayerEvent;
	import org.openscales.core.feature.DescribeFeature;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.State;
	import org.openscales.core.filter.Comparison;
	import org.openscales.core.format.FilerEncodingFormat;
	import org.openscales.core.layer.ogc.WFST.Transaction;
	import org.openscales.core.request.XMLRequest;

	public class WFST extends WFS
	{
		
		private var _describeFeature:DescribeFeature = null;
		
		private var _callbackDescribeFeatureInfo:Function = null;
		
		
		private var _transactionArray:Vector.<Transaction> = new Vector.<Transaction>;
		

		/*
		*see to delete this tab cause it is redundant with transactionArray
		*/
		public var featureArray:Vector.<Feature> = new Vector.<Feature>;

		
		public function WFST(name:String, url:String, typename:String,featureNSlocal:String = null)
		{
			//TODO: implement function
			super(name, url, typename);
			getDescribeFeatureInfo();
			
			var featurePrefixTemp:String = typename.split(":")[0];
			if(featurePrefixTemp  != null && featurePrefixTemp != typename){
			  this.featurePrefix = featurePrefixTemp;
			}
			
			if(featureNSlocal != null){
			  this._wfsFormat.featureNS = featureNSlocal;
			}
		}

		/**
		 * Combine the layer's url with its params and these newParams.
		 *
		 * @param newParams
		 * @param altUrl Use this as the url instead of the layer's url
		 */
		override public function getFullRequestString(altUrl:String = null):String {
		
			//filter by url way , by post way is maybe better
			var filterUrl:String ="";
			if(_filter){
				filterUrl = "&FILTER=";
			var filterEncodingFormat:FilerEncodingFormat = new FilerEncodingFormat();
			  filterUrl = "(" + _filter.toXMLString() + ")";
			  filterUrl += "(" + filterEncodingFormat.within("the_geom",this._wfsFormat.boxNode(this.featuresBbox)).toXMLString() + ")";
			 //bbox are mutually exclusive with filter and featurid
			  this.params.bbox = null;
			}
			return super.getFullRequestString(altUrl) + filterUrl;
		}
		
		override public function set map(map:Map):void {
			super.map = map;
			if(map){
				
				/*
				this.map.addEventListener(FeatureEvent.FEATURE_DRAWING_END,this.addTransaction);
				this.map.addEventListener(FeatureEvent.FEATURE_EDITED_END,this.addTransaction);
				*/
				this.map.addEventListener(WFSTFeatureEvent.INSERT,this.addTransaction);
				this.map.addEventListener(WFSTFeatureEvent.UPDATE,this.addTransaction);
				this.map.addEventListener(WFSTFeatureEvent.DELETE,this.addTransaction);
				
				this.map.dispatchEvent(new WFSTLayerEvent(WFSTLayerEvent.WFSTLAYER_ADDED,this));
			}
		}
		
		override public function destroy():void {
			
			this.map.removeEventListener(WFSTFeatureEvent.INSERT,this.addTransaction);
			this.map.removeEventListener(WFSTFeatureEvent.UPDATE,this.addTransaction);
			this.map.removeEventListener(WFSTFeatureEvent.DELETE,this.addTransaction);
			
			this.map.dispatchEvent(new WFSTLayerEvent(WFSTLayerEvent.WFSTLAYER_REMOVED,this));
			_describeFeature = null;
			_transactionArray = null;
			super.destroy();
			//todo desactivate event
		}
		
		public function addTransaction(event:WFSTFeatureEvent):void{
			
			var tempFeature:Vector.<Feature> = event.features;
			for(var i:uint=0;i<tempFeature.length;i++ ){
				
				if(tempFeature[i].state != null && tempFeature[i].state != State.UNKNOWN ){//&& tempFeature[i].layer == this){
					//think about where this code must be and how improve it
					/*if(tempFeature[i].state == State.INSERT && ){
					tempFeature[i].attributes = this.describeFeature.attributes;
					}*/
					transactionArray.push(new Transaction(tempFeature[i].state,tempFeature[i]));
					featureArray.push(tempFeature[i]);
				}
			}
			this.map.dispatchEvent(new WFSTLayerEvent(WFSTLayerEvent.WFSTLAYER_UPDATE_MODEL,this));
			
		}
		
		public function get describeFeature():DescribeFeature
		{
			return _describeFeature;
		}
		
		public function set describeFeature(value:DescribeFeature):void
		{
			_describeFeature = value;
		}
		/**
		 *save curent transaction 
		 * @param callBackTransaction
		 * 
		 */		
		public function saveTransaction():void{
			//todo
			
			var xmlRequestTransaction:XMLRequest = 	new XMLRequest(this.url+"?TYPENAME=" 
				         + this.typename+"&request=transaction&version=1.0.0&service=WFS", onSuccessTransaction, onFailureTransaction);
			xmlRequestTransaction.postContent = this._wfsFormat.write(featureArray);
			xmlRequestTransaction.postContentType = "application/xml";
			xmlRequestTransaction.send();
			
			
		}
		/**
		 * save feature without use interne process of class 
		 * @param features
		 * 
		 */		
		public function saveTransaction2(features:Object):void{
			//todo
			
			var xmlRequestTransaction:XMLRequest = 	new XMLRequest(this.url+"?TYPENAME=" 
				+ this.typename+"&request=transaction&version=1.0.0&service=WFS", onSuccessTransaction, onFailureTransaction);
			xmlRequestTransaction.postContent = this._wfsFormat.write(features);
			xmlRequestTransaction.postContentType = "application/xml"; 
			xmlRequestTransaction.send();
			
			
		}
		
		
		/**
		 * read the responde of server
		 * */
		protected function onSuccessTransaction(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var xmlReponse:XML =   new XML(loader.data);
			//delete the feature link
			featureArray= new Vector.<Feature>;
			if(this.transactionArray.length > 0){
			  this._wfsFormat.readTransactionResponse(xmlReponse,this.transactionArray);
			}
		    this.map.dispatchEvent(new WFSTLayerEvent(WFSTLayerEvent.WFSTLAYER_TRANSACTION_SUCCES,this));
			
			
		}
		/**
		 * read error
		 **/
		protected function onFailureTransaction(event:Event):void {
			
		}
		
		/**
		 * take the description of feature of layer
		 **/
		public function getDescribeFeatureInfo(callback:Function = null):void{
			
			var xmlRequestDescribeFeatureInfo:XMLRequest = 
				new XMLRequest(this._wfsFormat.describeFeatureType, onSuccessDescribeFeature, onFailureDescribeFeature);
			this._callbackDescribeFeatureInfo = callback;
			xmlRequestDescribeFeatureInfo.send();
			
		}
		
		/**
		 * read the responde of server
		 * */
		protected function onSuccessDescribeFeature(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var xmlReponse:XML =   new XML(loader.data);
			this.describeFeature = this._wfsFormat.describeFeatureRead(xmlReponse);
			this.geometryType = this.describeFeature.geometryType;
			this.map.dispatchEvent(new WFSTLayerEvent(WFSTLayerEvent.WFSTLAYER_READY,this));
			if(this._callbackDescribeFeatureInfo != null)
			  this._callbackDescribeFeatureInfo.call();
		}
		
		protected function onFailureDescribeFeature(event:Event):void {
			
		}
		
		/**
		 * the client must negociate with the server which version is the better
		 * */
		protected function neagociateVersionWithServer():void{
			
		}
		
		/**
		 * client does a request to lock a feature which want to edit.
		 * So clien request server:
		 * if the feature is locked , it can not edit the feature 
		 * if the feature is not locked it can edit the feature
		 * a transaction id, must be save to unlock feature
		 * */
		protected function lockFeature():void{
			
		}
		
		protected function updateIdAfterInsertTransaction():void{
			
		}

		/**
		 * this object is use for front end
		 * */
		public function get transactionArray():Vector.<Transaction>
		{
			return _transactionArray;
		}
		
		/**
		 * end of wfs-t
		 * */
	}
}