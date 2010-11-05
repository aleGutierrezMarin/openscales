package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.wfstEvent;
	import org.openscales.core.feature.DescribeFeature;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.State;
	import org.openscales.core.layer.ogc.WFST.Transaction;
	import org.openscales.core.request.XMLRequest;

	public class WFST extends WFS
	{
		
		private var _describeFeature:DescribeFeature = null;
		
		private var callbackDescribeFeatureInfo:Function = null;
		
		[Bindable]
		public var transactionArray:Vector.<Transaction> = new Vector.<Transaction>;
		/*
		*see to delete this tab cause it is redundant with transactionArray
		*/
		public var featureArray:Vector.<Feature> = new Vector.<Feature>;

		
		public function WFST(name:String, url:String, typename:String)
		{
			//TODO: implement function
			super(name, url, typename);
			
		}
		
		override public function set map(map:Map):void {
			super.map = map;
			if(map){
				this.map.addEventListener(wfstEvent.INSERT,this.addTransaction);
				this.map.addEventListener(wfstEvent.UPDATE,this.addTransaction);
				this.map.addEventListener(wfstEvent.DELETE,this.addTransaction);
			}
		}
		
		override public function destroy():void {
			//todo desactivate event
		}
		
		public function addTransaction(event:wfstEvent):void{
			
			var tempFeature:Vector.<Feature> = event.features;
			for(var i:uint=0;i<tempFeature.length;i++ ){
				//think about where this code must be
				tempFeature[i].attributes = this.describeFeature.attributes;
				if(tempFeature[i].state != null && tempFeature[i].state != State.UNKNOWN ){
					transactionArray.push(new Transaction(tempFeature[i].state,tempFeature[i]));
					featureArray.push(tempFeature[i]);
				}
			}
			
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
		 * wfs-t
		 * */
		
		public function saveTransaction():void{
			//todo
			
			var xmlRequestTransaction:XMLRequest = 	new XMLRequest(this.url+"?TYPENAME=" 
				         + this.typename+"&request=transaction&version=1.0.0&service=WFS", onSuccessTransaction, onFailureTransaction);
			xmlRequestTransaction.postContent = this._wfsFormat.write(featureArray);//this._writer.write(features);
			xmlRequestTransaction.postContentType = "application/xml"; 
			xmlRequestTransaction.send();
			
			
		}
		public function saveTransaction2(features:Object):void{
			//todo
			
			var xmlRequestTransaction:XMLRequest = 	new XMLRequest(this.url+"?TYPENAME=" 
				+ this.typename+"&request=transaction&version=1.0.0&service=WFS", onSuccessTransaction, onFailureTransaction);
			xmlRequestTransaction.postContent = this._wfsFormat.write(features);//this._writer.write(features);
			xmlRequestTransaction.postContentType = "application/xml"; 
			xmlRequestTransaction.send();
			
			
		}
		
		
		/**
		 * read the responde of server
		 * */
		protected function onSuccessTransaction(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var xmlReponse:XML =   new XML(loader.data);
			this._wfsFormat.readTransactionResponse(xmlReponse,this.transactionArray);
			//xmlReponse.*Status
			
			
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
			this.callbackDescribeFeatureInfo = callback;
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
			if(this.callbackDescribeFeatureInfo != null)
			  this.callbackDescribeFeatureInfo.call();
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
		 * end of wfs-t
		 * */
	}
}