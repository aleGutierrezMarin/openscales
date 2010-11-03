package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.feature.DescribeFeature;
	import org.openscales.core.request.XMLRequest;

	public class WFST extends WFS
	{
		
		private var _describeFeature:DescribeFeature = null;

		
		public function WFST(name:String, url:String, typename:String)
		{
			//TODO: implement function
			super(name, url, typename);
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
		
		public function saveTransaction(features:Object):void{
			//todo
			
			var xmlRequestTransaction:XMLRequest = 	new XMLRequest(this.url+"?TYPENAME=" +this.typename+"&request=transaction&version=1.0.0&service=WFS", onSuccessTransaction, onFailureTransaction);
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
		public function getDescribeFeatureInfo():void{
			
			var xmlRequestDescribeFeatureInfo:XMLRequest = 
				new XMLRequest(this._wfsFormat.describeFeatureType, onSuccessDescribeFeature, onFailureDescribeFeature);
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
		}
		
		protected function onFailureDescribeFeature(event:Event):void {
			
		}
		/**
		 * end of wfs-t
		 * */
	}
}