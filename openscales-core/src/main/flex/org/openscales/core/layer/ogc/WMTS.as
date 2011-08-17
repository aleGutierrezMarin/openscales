package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.capabilities.WMTS100;
	import org.openscales.core.layer.ogc.provider.WMTSTileProvider;
	import org.openscales.core.layer.ogc.wmts.TileMatrix;
	import org.openscales.core.layer.ogc.wmts.TileMatrixSet;
	import org.openscales.core.layer.params.IHttpParams;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	
	/**
	 * Instances of the WMTS class allow viewing of tiles from a service that 
	 * implements the OGC WMTS specification version 1.0.0.
	 * 
	 * @example Usage example
	 * <listing version="3.0"> 
	 * 		var m:Map = new Map();
	 * 		var wmts:WMTS = new WMTS("myLayer","http://foo.org","layer1","matrixSet15");
	 * 		m.addLayer(wmts);
	 * </listing>
	 * 
	 * @author htulipe
	 * @author slopez
	 */
	public class WMTS extends Grid
	{
		public static const WMTS_DEFAULT_FORMAT:String = "image/jpeg";
		/**
		 * @private
		 *  
		 * A tile provider for this layer.
		 */ 
		private var _tileProvider:WMTSTileProvider = null;
		//	private var _projection:String = Geometry.DEFAULT_SRS_CODE;
		private var _useCapabilities:Boolean = false;
		private var _loadingCapabilities:Boolean = false;
		private var _req:XMLRequest = null;
		/**
		 * Constructor
		 * 
		 * @param name String A name for the layer
		 * @param url String The url where is located the WMTS service that will be queried by the instance
		 * @param layer String The desired layer identifier. It must be a valid identifier (ie it must be in getCapablities)
		 * @param tileMatrixSet String The desired matrix set identifier. It must be a valid identifier (ie it must be in getCapablities)
		 * @param format String The Mime type defining the format for returned tiles (see getCapablities for supported format)
		 * @param style String the desired style identifier for returned tiles (see getCapablities for supported format)
		 * @param matrixIds Object An object containing for each matrix (of the matrix set) its identifier an its scaleDenominator
		 */ 
		public function WMTS(name:String, 
							 url:String, 
							 layer:String,
							 tileMatrixSet:String,
							 tileMatrixSets:HashMap = null)
		{
			if(!tileMatrixSets)
				_useCapabilities = true;
			// building the tile provider
			this._tileProvider = new WMTSTileProvider(url,format,tileMatrixSet,layer,tileMatrixSets);
			
			this.tileMatrixSet = tileMatrixSet;
			this.format = WMTS.WMTS_DEFAULT_FORMAT;
			super(name, url);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function redraw(fullRedraw:Boolean=true):void {
			if(this._useCapabilities && this.layer && this._tileProvider.tileMatrixSet && !this._tileProvider.tileMatrixSets) {
				this.getCapabilities();
			} else {
				var zoom:Number = this.getZoomForResolution(this.map.resolution);
				var resolution:Number = (this.resolutions[zoom] as Number);
				var tms:HashMap = this.tileMatrixSets;
				if(!tms.containsKey(this.tileMatrixSet)) {
					this.clear();
					return;
				}
				var tileMatrixSet:TileMatrixSet = tms.getValue(this.tileMatrixSet);
				var tileMatrix:TileMatrix = tileMatrixSet.tileMatrices.getValue(resolution);
				this.tileOrigin = tileMatrix.topLeftCorner.clone();
				super.redraw(fullRedraw);
			}
		}
		
		/**
		 * @private
		 * 
		 * Get the WMTS Capabilities to configure its tileMatrixSets
		 */
		private function getCapabilities():void {
			if(!this.tileMatrixSets && !this._loadingCapabilities)
			{
				if(_req) {
					_req.destroy();
					_req = null;
				}
				this._loadingCapabilities = true;
				_req = new XMLRequest(this._url+"?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetCapabilities", loadEnd, onFailure);
				if(this.proxy)
					_req.proxy = this.proxy;
				_req.send();
			}
		}
		
		/**
		 * Function called if the getCapabilities request return failure
		 * 
		 * @param event The event received
		 */
		public function onFailure(event:Event):void {
			this._loadingCapabilities = false;
		}
		
		/**
		 * Function called once the getCapabilities request is done
		 * 
		 * @param event The event received
		 */
		public function loadEnd(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var cap:WMTS100 = new WMTS100();
			var layers:HashMap = cap.read(new XML(loader.data as String));
			if(!layers)
				return;
			
			if(!layers.containsKey(this.layer))
				return;
			
			var layer:HashMap = (layers.getValue(this.layer) as HashMap);
			if(!layer.containsKey("TileMatrixSets"))
				return;
			
			this.tileMatrixSets = layer.getValue("TileMatrixSets") as HashMap;
			
			this._loadingCapabilities = false;
			
			if(this.map)
			{
				this.clear();
				this.redraw(true);
				this.map.redrawLayers();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if(_req) {
				_req.destroy();
				_req = null;
			}
			if(this._tileProvider!=null) {
				this._tileProvider.destroy();
				this._tileProvider = null;
			}
			super.destroy();
		}
		
		/**
		 * @inheritDoc
		 */ 
		override public function addTile(bounds:Bounds, center:Pixel):ImageTile
		{	
			// using the provider to get a tile from its bounds
			return _tileProvider.getTile(bounds, center, this);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function generateResolutions(numZoomLevels:uint=Layer.DEFAULT_NUM_ZOOM_LEVELS, nominalResolution:Number=NaN):void {
			var resolutions:Array = this._tileProvider.generateResolutions(numZoomLevels,nominalResolution);
			if(resolutions)
				this.resolutions = resolutions;
			else
				super.generateResolutions(numZoomLevels, nominalResolution);
			this._autoResolution = true;
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getURL(bounds:Bounds):String {
			return this._tileProvider.getTile(bounds,null,this).url;
		}
		
		/**
		 * @inheritDoc
		 */
		/*
		override public function get projSrsCode():String {
		return _projection;
		}
		*/
		/**
		 * Indicates tile mimetype
		 */
		public function get format():String {
			if(this._tileProvider == null)
				return WMTS.WMTS_DEFAULT_FORMAT;
			return this._tileProvider.format;
		}
		/**
		 * @private
		 */
		public function set format(value:String):void {
			this._tileProvider.format = value;
		}
		
		/**
		 * Indicates the requested layer
		 */
		public function get layer():String
		{
			return this._tileProvider.layer;
		}
		/**
		 * @private
		 */
		public function set layer(value:String):void
		{
			this._tileProvider.layer = value;
		}
		
		/**
		 * Indicates the tile matrix set
		 */
		public function get tileMatrixSet():String
		{
			return this._tileProvider.tileMatrixSet;
		}
		/**
		 * @private
		 */
		public function set tileMatrixSet(value:String):void
		{
			var event:LayerEvent = null;
			
			if(value && this._tileProvider) {
				this._tileProvider.tileMatrixSet = value;
				
				if(this._tileProvider.tileMatrixSets) {
					var tms:TileMatrixSet = this._tileProvider.tileMatrixSets.getValue(value) as TileMatrixSet;
					
					if(tms) {
						this.projSrsCode = tms.supportedCRS;
						event = new LayerEvent(LayerEvent.LAYER_PROJECTION_CHANGED, this);
					}
				}
			}
			this.generateResolutions();
			if(this.map && event)
				this.map.dispatchEvent(event);
		}
		
		/**
		 * Indicates the requested style
		 */
		public function get style():String
		{
			return this._tileProvider.style;
		}
		/**
		 * @private
		 */
		public function set style(value:String):void
		{
			this._tileProvider.style = value;
		}
		
		/**
		 * Indicates available tileMatrixSets
		 */
		public function get tileMatrixSets():HashMap
		{
			return this._tileProvider.tileMatrixSets;
		}
		/**
		 * @private
		 */
		public function set tileMatrixSets(value:HashMap):void
		{
			if(value)
				this._useCapabilities = false;
			else
				this._useCapabilities = true;
			
			this._tileProvider.tileMatrixSets = value;
			this.tileMatrixSet = this.tileMatrixSet;
		}
		
		/**
		 * @private
		 * returns revelant tilematrix
		 * 
		 * @return a tilematrix or null if none
		 */
		public function get tileMatrix():TileMatrix {
			if(this._tileProvider.tileMatrixSets!=null
				&& this._tileProvider.tileMatrixSets.containsKey(this._tileProvider.tileMatrixSet)) {
				var tms:TileMatrixSet = this._tileProvider.tileMatrixSets.getValue(this._tileProvider.tileMatrixSet) as TileMatrixSet;
				var zoom:Number = this.getZoomForResolution(this.map.resolution);
				var resolution:Number = this.resolutions[zoom] as Number;
				if(tms.tileMatrices.containsKey(resolution))
					return (tms.tileMatrices.getValue(resolution) as TileMatrix);
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get tileHeight():Number {
			var tm:TileMatrix = this.tileMatrix;
			if(tm != null)
				return tm.tileHeight;
			return super.tileHeight;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get tileWidth():Number {
			var tm:TileMatrix = this.tileMatrix;
			if(tm != null)
				return tm.tileWidth;
			return super.tileWidth;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get maxExtent():Bounds {
			if(this._tileProvider != null) {
				var _maxExtent:Bounds = this._tileProvider.maxExtent;
				if(_maxExtent!=null)
					return _maxExtent;
			}
			return super.maxExtent;
		}
		
		override public function set url(value:String):void {
			super.url = value;
			this._tileProvider.url = value;
			
			if(this._useCapabilities && this._url) {
				this.getCapabilities();
			}
		}
		
	}
	
}