package org.openscales.fx.layer
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
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
			this._layer = new WMTS(this.name,this._url,this._WMTSlayer,this._tileMatrixSet,this._tileMatrixSets);
		}

		override public function configureLayer():Layer {

			
			this._layer.name = this.name;
			this._layer.url = this._url;
			
			if(this.proxy)
				this._layer.proxy = this.proxy;
			if(this.dpi)
				this._layer.dpi = this.dpi;
			this._layer.tweenOnZoom = this.tweenOnZoom;
			this._layer.alpha = super.alpha;
			this._layer.visible = super.visible;
			
			
			if(!this._useCapabilities)
			{
				(this._layer as WMTS).layer = this._WMTSlayer;
				(this._layer as WMTS).tileMatrixSets = this._tileMatrixSets;
				(this._layer as WMTS).tileMatrixSet = this._tileMatrixSet;
				(this._layer as WMTS).format = this._format;	
			}
			
			return this._layer;
		}
		
		override public function set url(value:String):void {
			if(this._layer != null)
				(this._layer as WMTS).url=value;
			this._url = value;
		}
		
		public function get WMTSLayer():String {
			return this._WMTSlayer; 
		}
		
		public function set WMTSLayer(value:String):void {
			if(this._layer != null)
				(this._layer as WMTS).layer = value;;
			this._WMTSlayer = value;
		}
		
		public function get format():String {
			return this._format;
		}
		
		public function set format(value:String):void {
			this._format = value;
			if(this._layer != null)
				(this._layer as WMTS).format=value;
		}
		
		public function get style():String {
			return (this._layer as WMTS).style;
		}
		public function set style(value:String):void {
			if(this._layer != null)
				(this._layer as WMTS).style = value;
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
			this._tileMatrixSets = value;
			
			this._useCapabilities = false;
			
			if(this._layer)
				(this._layer as WMTS).tileMatrixSets = value;
		}
		
		public function get tileMatrixSet():String
		{
			return _tileMatrixSet;
		}
		
		public function set tileMatrixSet(value:String):void
		{
			_tileMatrixSet = value;
			if(this._layer)
				(this._layer as WMTS).tileMatrixSet = value;
		}
	}
}