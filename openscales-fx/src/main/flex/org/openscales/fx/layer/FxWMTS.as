package org.openscales.fx.layer
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.capabilities.WMTS100;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.fx.FxMap;
	import org.openscales.fx.layer.FxGrid;
	
	public class FxWMTS extends FxGrid
	{
		private var _url:String = null;
		private var _useCapabilities:Boolean = true;
		private var _WMTSlayer:String = null;
		private var _tileMatrixSet:String = null;
		private var _tileMatrixSets:HashMap = null;
		private var _isConfigured:Boolean = false;
		private var _format:String = "image/jpg";
		
		public function FxWMTS()
		{
			super();
		}
		
		private function getCapabilities():void {
			var req:XMLRequest = new XMLRequest(this._url+"?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetCapabilities", loadEnd, onFailure);
			if(this.proxy)
				req.proxy = this.proxy;
			req.send();
		}
		
		override public function configureLayer():Layer {
			this._isConfigured = true;
			if(this._useCapabilities && !this._tileMatrixSets) {
				this.getCapabilities();
				return null;
			}
			
			this.layer.name = this.name;
			
			if(this.proxy)
				this.layer.proxy = this.proxy;
			
			if(this.dpi)
				this.layer.dpi = this.dpi;

			this.layer.tweenOnZoom = this.tweenOnZoom;
			
			this.layer.alpha = super.alpha;
			this.layer.visible = super.visible;
			
			if(!this._useCapabilities) {
				(this.layer as WMTS).tileMatrixSets = this.tileMatrixSets;
				(this.layer as WMTS).tileMatrixSet = this.tileMatrixSet;
				(this.layer as WMTS).format = this.format;
				this.layer.generateResolutions();
			}
			
			return this.layer;
		}
		
		override public function set url(value:String):void {
			if(this.layer != null)
				(this.layer as WMTS).url=value;
			this._url = value;
			if(this._useCapabilities && this._url) {
				this.getCapabilities();
			}
		}
		
		public function get WMTSLayer():String {
			return this._WMTSlayer; 
		}
		
		public function set WMTSLayer(value:String):void {
			if(this.layer != null)
				(this.layer as WMTS).layer = value;;
			this._WMTSlayer = value;
		}
		
		public function get format():String {
			return this._format;
		}
		
		public function set format(value:String):void {
			this._format = value;
			if(this.layer != null)
				(this.layer as WMTS).format=value;
		}
		
		public function get useCapabilities():Boolean
		{
			return _useCapabilities;
		}
		
		public function set useCapabilities(value:Boolean):void
		{
			_useCapabilities = value;
		}
		
		public function get tileMatrixSets():HashMap
		{
			return _tileMatrixSets;
		}
		
		public function set tileMatrixSets(value:HashMap):void
		{
			_tileMatrixSets = value;
			if(this.layer)
				(this.layer as WMTS).tileMatrixSets = value;
		}
		
		public function get tileMatrixSet():String
		{
			return _tileMatrixSet;
		}
		
		public function set tileMatrixSet(value:String):void
		{
			_tileMatrixSet = value;
			if(this.layer)
				(this.layer as WMTS).tileMatrixSet = value;
		}
		
		public function onFailure(event:Event):void {
			
		}
		
		public function loadEnd(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var cap:WMTS100 = new WMTS100();
			var layers:HashMap = cap.read(new XML(loader.data as String));
			if(!layers)
				return;
			
			if(!layers.containsKey(this.WMTSLayer))
				return;
			
			var layer:HashMap = (layers.getValue(this.WMTSLayer) as HashMap);
			if(!layer.containsKey("TileMatrixSets"))
				return;
			
			this.tileMatrixSets = layer.getValue("TileMatrixSets") as HashMap;
			
			this._layer = new WMTS(this.name,this._url,this._WMTSlayer,this._tileMatrixSet,this._tileMatrixSets);
			
			(this._layer as WMTS).format = this.format;
			
			if(this._isConfigured) {
				this.configureLayer();
				this._isConfigured = false;
				if(this.fxmap && this.fxmap.map) {
					this.fxmap.map.addLayer(this.layer);
					this.layer.redraw();
					this.fxmap.map.size = this.fxmap.map.size;
				}
			}
		}
		
	}
}