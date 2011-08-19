package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.WFSTFeatureEvent;
	import org.openscales.core.events.WFSTLayerEvent;
	import org.openscales.core.feature.DescribeFeature;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.State;
	import org.openscales.core.format.FilterEncodingFormat;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.WFSFormat;
	import org.openscales.core.layer.ogc.WFST.Transaction;
	import org.openscales.core.request.XMLRequest;
	
	public class WFST extends WFS
	{
		private var _filter:XML;
		
		private var _describeFeature:DescribeFeature = null;
		
		private var  _xmlRequestDescribeFeatureInfo:XMLRequest = null;
		
		private var _xmlRequestTransaction:XMLRequest = null;
		
		private var _callbackDescribeFeatureInfo:Function = null;
		
		private var _transactionArray:Vector.<Transaction> = new Vector.<Transaction>;
		
		/**
		 * @private
		 * the wfsformat
		 */
		private var _wfsFormat:WFSFormat = null;
		private var _writer:Format = null;
		
		private var _geometryColumn:String = "the_geom";
		
		/*
		*see to delete this tab cause it is redundant with transactionArray
		*/
		public var featureArray:Vector.<Feature> = new Vector.<Feature>;
		
		
		public function WFST(name:String, url:String, typename:String,featureNSlocal:String = null)
		{
			
			super(name, url, typename);
			
			this._wfsFormat = new WFSFormat(this);
			
			var featurePrefixTemp:String = typename.split(":")[0];
			if(featurePrefixTemp  != null && featurePrefixTemp != typename){
				this.featurePrefix = featurePrefixTemp;
			}
			
			if(featureNSlocal != null){
				this._wfsFormat.featureNS = featureNSlocal;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getFullRequestString():String {
			//filter by url way , by post way is maybe better
			var filterUrl:String ="";
			if(_filter){
				filterUrl = "&FILTER=";
				var filterEncodingFormat:FilterEncodingFormat = new FilterEncodingFormat();
				filterUrl += filterEncodingFormat.filterWithBbox(_filter,"the_geom",this._wfsFormat.boxNode(this.featuresBbox)).toXMLString();
				//bbox are mutually exclusive with filter and featurid
				this.params.bbox = null;
			}
			return super.getFullRequestString() + filterUrl;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function loadFeatures(url:String):void {	
			if (map) {
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_LOAD_START, this ));
			} else {
				Trace.warn("Warning : no LAYER_LOAD_START dispatched because map event dispatcher is not defined");
			}
			
			if(_request)
				_request.destroy();
			this.loading = true;
			
			_request = new XMLRequest(url, onSuccess, onFailure);
			_request.proxy = this.proxy;
			_request.security = this.security;
			_request.cache = false;
			_request.send();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onSuccess(event:Event):void {
			if(this._wfsFormat != null)
				this._wfsFormat.reset();
			
			
			if (this.map.projection != null && this.projSrsCode != null && this.projSrsCode != this.map.projection) {
				this._wfsFormat.externalProjSrsCode = this.projSrsCode;
				this._wfsFormat.internalProjSrsCode = this.map.projection;
			}
			super.onSuccess(event);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set map(map:Map):void {
			super.map = map;
			if(map){
				getDescribeFeatureInfo();
				this.map.addEventListener(WFSTFeatureEvent.INSERT,this.addTransaction);
				this.map.addEventListener(WFSTFeatureEvent.UPDATE,this.addTransaction);
				this.map.addEventListener(WFSTFeatureEvent.DELETE,this.addTransaction);
				
				this.map.dispatchEvent(new WFSTLayerEvent(WFSTLayerEvent.WFSTLAYER_ADDED,this));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			
			if(this._wfsFormat != null)
				this._wfsFormat.destroy();
			this._wfsFormat = null;
			
			if(_xmlRequestDescribeFeatureInfo != null)
				_xmlRequestDescribeFeatureInfo.destroy();
			if(_xmlRequestTransaction != null)
				_xmlRequestTransaction.destroy();
			
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
		 * Save curent transaction 
		 * 
		 * @param callBackTransaction
		 * 
		 */		
		public function saveTransaction():void{
			//todo
			
			_xmlRequestTransaction = 	new XMLRequest(this.url+"?TYPENAME=" 
				+ this.typename+"&request=transaction&version=1.0.0&service=WFS", onSuccessTransaction, onFailureTransaction);
			_xmlRequestTransaction.postContent = this._wfsFormat.write(featureArray);
			_xmlRequestTransaction.postContentType = "application/xml";
			_xmlRequestTransaction.send();
			
			
		}
		/**
		 * Save feature without use interne process of class 
		 * 
		 * @param features
		 * 
		 */		
		public function saveFeaturesTransaction(features:Object):void{
			_xmlRequestTransaction = new XMLRequest(this.url+"?TYPENAME=" 
				+ this.typename+"&request=transaction&version=1.0.0&service=WFS", onSuccessTransaction, onFailureTransaction);
			_xmlRequestTransaction.postContent = this._wfsFormat.write(features);
			_xmlRequestTransaction.postContentType = "application/xml"; 
			_xmlRequestTransaction.send();
			
		}
		
		/**
		 * cancel all current transaction 
		 * @return 
		 * 
		 */		
		public function cancelAllTransaction():void{
			for(var i:uint=0;i<featureArray.length;i++ ){
				featureArray[i].state = State.UNKNOWN;
			}
			featureArray = new Vector.<Feature>;
			_transactionArray = new Vector.<Transaction>;
		}
		
		
		/**
		 * Read the responde of server
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
		 * Read error
		 **/
		protected function onFailureTransaction(event:Event):void {
			this.map.dispatchEvent(new WFSTLayerEvent(WFSTLayerEvent.WFSTLAYER_TRANSACTION_FAIL,this));
			Trace.log("The transaction failed");
		}
		
		/**
		 * Take the description of feature of layer
		 **/
		public function getDescribeFeatureInfo(callback:Function = null):void{
			
			_xmlRequestDescribeFeatureInfo = 
				new XMLRequest(this._wfsFormat.describeFeatureType, onSuccessDescribeFeature, onFailureDescribeFeature);
			this._callbackDescribeFeatureInfo = callback;
			_xmlRequestDescribeFeatureInfo.send();
			
		}
		
		/**
		 * Read the responde of server
		 * 
		 */
		protected function onSuccessDescribeFeature(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var xmlReponse:XML =   new XML(loader.data);
			this.describeFeature = this._wfsFormat.describeFeatureRead(xmlReponse);
			if(this.describeFeature != null){
				this.geometryType = this.describeFeature.geometryType;
				this.map.dispatchEvent(new WFSTLayerEvent(WFSTLayerEvent.WFSTLAYER_READY,this));
				if(this._callbackDescribeFeatureInfo != null)
					this._callbackDescribeFeatureInfo.call();
			}
			else{
				getDescribeFeatureInfo();
			}
		}
		
		protected function onFailureDescribeFeature(event:Event):void {
			Trace.log("The describe feature transaction failed");
		}
		
		/**
		 * the client must negociate with the server which version is the better
		 * */
		protected function negociateVersionWithServer():void{
			throw "Not yet implement ";
		}
		
		/**
		 * Client does a request to lock a feature which want to edit.
		 * So clien request server:
		 * if the feature is locked , it can not edit the feature 
		 * if the feature is not locked it can edit the feature
		 * a transaction id, must be save to unlock feature
		 * */
		protected function lockFeature():void{
			throw "Not yet implement ";
		}
		
		protected function updateIdAfterInsertTransaction():void{
			throw "Not yet implement ";
		}
		
		/**
		 * this object is use for front end
		 * */
		public function get transactionArray():Vector.<Transaction>
		{
			return _transactionArray;
		}
		
		public function get filter():XML
		{
			return _filter;
		}
		
		public function set filter(value:XML):void
		{
			_filter = value;
		}
		
		
		/**
		 * Indicates the writer
		 */
		public function get writer():Format {
			return this._writer;
		}
		/**
		 * @private
		 */
		public function set writer(value:Format):void {
			this._writer = value;
		}
		
		/**
		 * Indicates the feature namespace
		 */
		public function get featureNS():String {
			return this._wfsFormat.featureNS;
		}
		/**
		 * @private
		 */
		public function set featureNS(value:String):void {
			this._wfsFormat.featureNS = value;
		}
		
		/**
		 * Indicates the feature prefix
		 */
		public function get featurePrefix():String {
			return this._wfsFormat.featurePrefix;
		}
		/**
		 * @private
		 */
		public function set featurePrefix(value:String):void {
			this._wfsFormat.featurePrefix = value;
		}
		
		/**
		 * Indicates the geometry attribute name
		 */
		public function get geometryColumn():String {
			return this._geometryColumn;
		}
		/**
		 * @private
		 */
		public function set geometryColumn(value:String):void {
			this._geometryColumn = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get extractAttributes():Boolean {
			return this._wfsFormat.extractAttributes;
		}
		/**
		 * @private
		 */
		override public function set extractAttributes(value:Boolean):void {
			this._wfsFormat.extractAttributes = value;
			super.extractAttributes = value;
		}
	}
}