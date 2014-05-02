package org.openscales.fx.layer
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMTS;
	
	public class FxWMTS extends FxGrid
	{
		private var _url:String = null;
		private var _useCapabilities:Boolean = true;
		private var _tmssProvided:Boolean = false;
		private var _styleProvided:Boolean = false;
		private var _WMTSlayer:String = null;
		private var _tileMatrixSet:String = null;
		private var _tileMatrixSets:HashMap = null;
		private var _format:String = WMTS.WMTS_DEFAULT_FORMAT;
		private var _style:String = null;
		
		public function FxWMTS()
		{
			super();
			this._layer = new WMTS(this.identifier,this._url,this._WMTSlayer,this._tileMatrixSet,this._tileMatrixSets, this._style);
		}

		override public function configureLayer():Layer {

			
			this._layer.identifier = this.identifier;
			this._layer.url = this._url;
			
			if(this.proxy)
				this._layer.proxy = this.proxy;
			if(this.dpi)
				this._layer.dpi = this.dpi;

			this._layer.alpha = super.alpha;
			this._layer.visible = super.visible;
			
			if(!this._useCapabilities)
			{
				(this._layer as WMTS).layer = this._WMTSlayer;
				(this._layer as WMTS).tileMatrixSets = this._tileMatrixSets;
				(this._layer as WMTS).tileMatrixSet = this._tileMatrixSet;
				(this._layer as WMTS).style = this._style;
				(this._layer as WMTS).format = this._format;	
			}else
			{
				if (this._styleProvided)
					(this._layer as WMTS).style = this._style;
				
				if (this._tmssProvided)
					(this._layer as WMTS).tileMatrixSets = this._tileMatrixSets;
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
			
			this._styleProvided = true;
			
			if (this._tmssProvided && this._styleProvided)
				this._useCapabilities = false;
			
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
			this._tmssProvided = true;
			
			if (this._tmssProvided && this._styleProvided)
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