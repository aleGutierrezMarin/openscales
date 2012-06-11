package org.openscales.fx.control.search
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.events.ListEvent;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.capabilities.GetCapabilities;
	import org.openscales.fx.control.Control;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	[SkinState("ogc")]
	[SkinState("other")]
	[SkinState("isresults")]
	[SkinState("noresults")]
	
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
		
		private var _supportedFormats:HashMap;
		private var isResults:Boolean = false;
		private var noResults:Boolean = false;
		
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
			if(instance == protocolsList){
				protocolsList.dataProvider = new ArrayCollection(_supportedFormats.getKeys().sort());
			}
			if(instance == submitButton){
				submitButton.enabled = false;
			}
			if(instance == resultList){
				resultList.enabled = false;
			}
			if(instance == urlTextInput){
				urlTextInput.addEventListener(FocusEvent.FOCUS_OUT, onURLTextInputFocusOut);
			}
			
		}
		
		override protected function getCurrentSkinState():String{
			var prot:String = protocolsList.selectedItem as String
			if(super.getCurrentSkinState() == "disabled") return super.getCurrentSkinState();	
			if(prot == "WMS" || prot == "WFS" || prot == "WMTS"){
				if(noResults) return "noresult";
				if(isResults)return "isresults"
				return "ogc";
			}else return "other";
			
		}
		
		protected function onURLTextInputFocusOut(event:FocusEvent):void{
			noResults = false;
			isResults = false;
			var prot:String = (protocolsList.selectedItem as String).replace(/\s/g,"");
			var vers:String = (versionsList.selectedItem as String).replace(/\s/g,"");
			var url:String = (urlTextInput.text).replace(/\s/g,"");
			var getCapapbilities:GetCapabilities = new GetCapabilities(prot, url, onGetCapSuccess, vers,this.map.getProxy(url));
		}
		
		protected function onGetCapSuccess(getCapabilities:GetCapabilities):void{
			var cap:HashMap = getCapabilities.getAllCapabilities();
			if(cap.size() <=0){
				noResults = true;
				invalidateSkinState();
				return;
			}else{
				isResults = true;
				var layerArray:ArrayCollection = new ArrayCollection(cap.getKeys().sort());
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