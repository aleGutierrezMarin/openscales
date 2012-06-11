package org.openscales.fx.control.search
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.KML;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.capabilities.GetCapabilities;
	import org.openscales.core.layer.ogc.GPX;
	import org.openscales.core.layer.ogc.GeoRss;
	import org.openscales.fx.control.Control;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	[SkinState("ogc")]
	[SkinState("other")]
	[SkinState("isresults")]
	[SkinState("noresults")]
	[SkinState("loading")]
	[SkinState("URLSource")]
	[SkinState("localFileSource")]
	
	public class AddExternalLayer extends Control
	{
		/**
		 * List of supported protocols
		 */ 
		[SkinPart(required="true")]
		public var protocolsList:List;
		
		/**
		 * Button used to add layer to map
		 */ 
		[SkinPart(required="true")]
		public var submitButton:Button;
		
		/**
		 * Text input where the user fill the we bservice user where to look for a GetCap
		 */ 
		[SkinPart(required="true")]
		public var urlTextInput:TextInput;
		
		
		/**
		 * List displaying GetCap results
		 */ 
		[SkinPart(required="true")]
		public var resultList:List;
		
		/**
		 * Button used to cancel
		 */ 
		[SkinPart]
		public var cancelButton:Button;
		
		/**
		 * List of supported versions for selected protocol 
		 */ 
		[SkinPart(required="true")]
		public var versionsList:List;
		
		[SkinPart]
		public var otherURLSourceTextInput:TextInput;
		
		[SkinPart]
		public var chooseLocalFileButton:Button
		
		[SkinPart(required="true")]
		public var otherLayerNameTextInput:TextInput;
		
		private var _supportedFormats:HashMap;
		private var isResults:Boolean = false;
		private var noResults:Boolean = false;
		private var urlNotEmpty:Boolean =false;
		private var localeFile:Boolean = false;
		private var loading:Boolean = false;
		private var _capabilities:GetCapabilities;
		private var fileReference:FileReference;
		private var _localData:ByteArray;
		
		public function AddExternalLayer()
		{
			super();
			_supportedFormats = new HashMap();
			this._supportedFormats.put("WMS",["1.0.0", "1.1.0", "1.1.1","1.3.0"]);
			this._supportedFormats.put("WMTS",["1.0.0"]);
			this._supportedFormats.put("WFS",["1.0.0","1.1.0","2.0.0"]);
			this._supportedFormats.put("KML",["2.0","2.2"]);
			this._supportedFormats.put("GPX",["1.0","1.1"]);
			this._supportedFormats.put("GeoRSS",["1.1"]);
			
		}
		
		override protected function onCreationComplete(event:Event):void{
			super.onCreationComplete(event);
			protocolsList.addEventListener(IndexChangeEvent.CHANGE, updateProtocolsSelectedItem);
			protocolsList.selectedIndex = protocolsList.dataProvider.getItemIndex("WMS");
			updateProtocolsSelectedItem(null);
		}
		
		override protected function partAdded(partName:String, instance:Object):void{
			super.partAdded(partName,instance);
			if(instance == protocolsList){
				protocolsList.dataProvider = new ArrayCollection(_supportedFormats.getKeys().sort());
			}
			if(instance == otherLayerNameTextInput){
				otherLayerNameTextInput.addEventListener(Event.CHANGE, function (event:Event):void{invalidateSkinState();});
			}
			
			if(instance == otherURLSourceTextInput){
				otherURLSourceTextInput.addEventListener(Event.CHANGE, onURLSourceTextInputChange);
			}
			if(instance == chooseLocalFileButton){
				chooseLocalFileButton.addEventListener(MouseEvent.CLICK,generateFileReference);
			}
			
		}
		
		protected function onURLSourceTextInputChange(event:Event):void{
			if (otherURLSourceTextInput.text != "" )urlNotEmpty = true;
			else urlNotEmpty = false;
			invalidateSkinState();
		}
		
		protected function generateFileReference(event:MouseEvent):void{
			localeFile = false;
			invalidateSkinState();
			//create the FileReference instance
			fileReference = new FileReference();
			
			//listen for when they select a file
			fileReference.addEventListener(Event.SELECT, onFileSelect);
			
			//listen for when then cancel out of the browse dialog
			fileReference.addEventListener(Event.CANCEL,onCancel);
			
			//open a native browse dialog that filters for text files
			fileReference.browse();
		}
		
		/**
		 * Called when a file is selected on 
		 */
		protected function onFileSelect(e:Event):void
		{
			//listen for when the file has loaded
			fileReference.addEventListener(Event.COMPLETE, onLoadComplete);
			
			//load the content of the file
			fileReference.load();
		}
		
		/**
		 * private
		 * called when the file has completed loading
		 */
		private function onLoadComplete(e:Event):void
		{
			//get the data from the file as a ByteArray
			_localData = fileReference.data;
			localeFile = true;
			invalidateSkinState();
			//clean up the FileReference instance
			fileReference = null;
		}
	
		/**
		 * Called when the user cancel the browse process
		 */
		protected function onCancel(e:Event):void				
		{
			fileReference = null;
		}
		
		override protected function getCurrentSkinState():String{
			var prot:String = protocolsList.selectedItem as String
			if(super.getCurrentSkinState() == "disabled") return super.getCurrentSkinState();	
			if(prot == "WMS" || prot == "WFS" || prot == "WMTS"){
				if(noResults) return "noresults";
				if(isResults)return "isresults";
				if(loading)return "loading";
				return "ogc";
			}else {
				if(urlNotEmpty && otherLayerNameTextInput && otherLayerNameTextInput.text != "") return "URLSource";
				if(localeFile && otherLayerNameTextInput && otherLayerNameTextInput.text != "") return "localFileSource";
				return "other";
			}
			
		}
		
		public function lookForGetCap():void{
			resultList.dataProvider = null;
			noResults = false;
			isResults = false;
			loading = false;
			
			var prot:String = (protocolsList.selectedItem as String).replace(/\s/g,"");
			var vers:String = (versionsList.selectedItem as String).replace(/\s/g,"");
			var url:String = (urlTextInput.text).replace(/\s/g,"");
			if(url && url != ""){
				_capabilities = new GetCapabilities(prot, url, onGetCapSuccess, vers,this.map.getProxy(url));
				loading = true;
			}
			invalidateSkinState();
		}
		
		public function addOGCLayer(name:String):Boolean{
			if(_capabilities && _map){
				var layer:Layer = _capabilities.instanciateLayer(name);
				if(!layer)return false;
				layer.url = urlTextInput.text;
				layer.projection = _map.projection;
				layer.maxExtent = _map.maxExtent;
				return _map.addLayer(layer);
			}
			return false;
		}
		
		/**
		 * @param source 0 for url, 1 for local file system
		 */ 
		public function addOtherLayer(source:uint):Boolean{
			
			var prot:String = protocolsList.selectedItem as String;
			var name:String = otherLayerNameTextInput.text;
			var url:String = otherURLSourceTextInput.text;
			var vers:String = versionsList.selectedItem as String;
			var xml:XML;
			if(name == "")return false;
			var layer:Layer;
			switch(prot){
				case "KML":
					if(source == 0) {
						layer = new KML(name, url);
					} else {
						xml = new XML(_localData.readUTFBytes(_localData.bytesAvailable));
						layer = new KML(name, null, xml);
					}
					break;
				
				case "GPX":
					if(source == 0) {
						layer = new GPX(name, vers, url);
					} else {
						xml = new XML(_localData.readUTFBytes(_localData.bytesAvailable));
						layer = new GPX(name, vers, null, xml);
					}
					break;
				
				case "GeoRSS":
					if(source == 0) {
						layer = new GeoRss(name,url);
					} else {
					}
					break;
			}
			if(!layer) return false;
			return map.addLayer(layer);
			
		}
		
		protected function onGetCapSuccess(getCapabilities:GetCapabilities):void{
			var cap:HashMap = getCapabilities.getAllCapabilities();
			if(cap.size() <=0){
				noResults = true;
				invalidateSkinState();
				return;
			}else{
				isResults = true;
				var layerArray:ArrayCollection = new ArrayCollection(cap.getValues());
				//layerArray.sort = new Sort();
				resultList.dataProvider = layerArray;
				invalidateSkinState();
			}
		}
		
		protected function updateProtocolsSelectedItem(event:IndexChangeEvent):void{
			var prot:String = protocolsList.selectedItem as String;
			var vers:Array = _supportedFormats.getValue(prot);
			versionsList.dataProvider = new ArrayCollection(vers);
			versionsList.selectedIndex = versionsList.dataProvider.length-1;
			invalidateSkinState();
			
		}
	}
}