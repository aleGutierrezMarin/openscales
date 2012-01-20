package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.basetypes.Resolution;
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
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	
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
		public static const WMTS_DEFAULT_FORMAT:String = "image/png";
		/**
		 * @private
		 *  
		 * A tile provider for this layer.
		 */ 
		private var _tileProvider:WMTSTileProvider = null;
		private var _useCapabilities:Boolean = false;
		private var _tmssProvided:Boolean = false;
		private var _styleProvided:Boolean = false;
		private var _loadingCapabilities:Boolean = false;
		private var _req:XMLRequest = null;
		private var _formatSetted:Boolean = false;
		/**
		 * Constructor
		 * 
		 * @param name String A name for the layer
		 * @param url String The url where is located the WMTS service that will be queried by the instance
		 * @param layer String The desired layer identifier. It must be a valid identifier (ie it must be in getCapablities)
		 * @param tileMatrixSet String The desired matrix set identifier. It must be a valid identifier (ie it must be in getCapablities)
		 * @param tileMatrixSets HashMap A HashMap containing all the tileMatrixSets description
		 * @param style String the desired style identifier for returned tiles (see getCapablities for supported format)
		 */ 
		public function WMTS(identifier:String, 
							 url:String, 
							 layer:String,
							 tileMatrixSet:String,
							 tileMatrixSets:HashMap = null,
							 style:String = null
							 )
		{
			
			_styleProvided = true;
			_tmssProvided = true;
			if(!tileMatrixSets)
			{
				_useCapabilities = true;
				_tmssProvided = false;
			}
			
			if (!style)
			{
				_useCapabilities = true;
				_styleProvided = false;
			}
			
			// building the tile provider
			this._tileProvider = new WMTSTileProvider(url,format,tileMatrixSet,layer,tileMatrixSets);
			this._tileProvider.style = style;
			//this.format = WMTS.WMTS_DEFAULT_FORMAT;
			
			super(identifier, url);
			this.tileMatrixSet = tileMatrixSet;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function actualizeGrid(bounds:Bounds, forceReTile:Boolean):void
		{
			if(this._useCapabilities && this.layer && this._tileProvider.tileMatrixSet && (!this._tileProvider.tileMatrixSets || !this.style)) {
				this.getCapabilities();
			} else {
				var resolution:Number = this.getSupportedResolution(this.map.resolution).value;
				var tms:HashMap = this.tileMatrixSets;
				if(!tms.containsKey(this.tileMatrixSet)) {
					this.clear();
					return;
				}
				var tileMatrixSet:TileMatrixSet = tms.getValue(this.tileMatrixSet);
				var tileMatrix:TileMatrix = tileMatrixSet.tileMatrices.getValue(resolution);
				this._tileOrigin = tileMatrix.topLeftCorner.clone();
				super.actualizeGrid(bounds, forceReTile);
			}
		}
		
		override public function redraw(fullRedraw:Boolean=false):void
		{
			if (!this._initialized)
			{
				if(this._useCapabilities && this.layer && this._tileProvider.tileMatrixSet && (!this._tileProvider.tileMatrixSets || !this.style)) {
					this.getCapabilities();
				} else {
					var resolution:Number = this.getSupportedResolution(this.map.resolution).value;
					var tms:HashMap = this.tileMatrixSets;
					if(!tms.containsKey(this.tileMatrixSet)) {
						this.clear();
						return;
					}
					var tileMatrixSet:TileMatrixSet = tms.getValue(this.tileMatrixSet);
					var tileMatrix:TileMatrix = tileMatrixSet.tileMatrices.getValue(resolution);
					this._tileOrigin = tileMatrix.topLeftCorner.clone();
				}
			}
			super.redraw(fullRedraw);
		}
		
		/**
		 * @private
		 * 
		 * Get the WMTS Capabilities to configure its tileMatrixSets
		 */
		private function getCapabilities():void {
			if((!this.tileMatrixSets || !this.style) && !this._loadingCapabilities)
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
			
			if (!this._tmssProvided)
				this.tileMatrixSets = layer.getValue("TileMatrixSets") as HashMap;
			
			if (!this._styleProvided)
				this.style = layer.getValue("DefaultStyle") as String;
			
			if (!_formatSetted)
			this.format = (layer.getValue("Formats") as Array)[0];
				
			//Setting available projections
			//Not really needed for WMTS as different projections are in the tileMatrixSets
			/*if(!this.availableProjections) {
				var aProj:Vector.<String> = new Vector.<String>();
				var arr:Array = this.tileMatrixSets.getKeys();
				
				for(var i:uint = 0 ; i < arr.length ; i++) {
					var tms:TileMatrixSet = (this.tileMatrixSets.getValue(arr[i]) as TileMatrixSet);
					aProj.push(tms.supportedCRS);
				}
				this.availableProjections = aProj;
			}*/
			
			this._loadingCapabilities = false;
			
			if(this.map)
			{
				this.clear();
				this.redraw(true);
			}
			
		}
		
		override protected function checkAvailability():Boolean
		{
			//Parse the tileMatrixSets of the layer and try to find if one is in the projection map
			if(this.projection && this.map && this.map.projection) {
				if(!ProjProjection.isEquivalentProjection(this.projection,this.map.projection)) {
					if(this.tileMatrixSets) {
						var arr:Array = this.tileMatrixSets.getKeys();
						var proj:ProjProjection;
						for(var i:uint = 0 ; i < arr.length ; i++) {
							var tms:TileMatrixSet = (this.tileMatrixSets.getValue(arr[i]) as TileMatrixSet);
							proj = ProjProjection.getProjProjection(tms.supportedCRS);
							if(ProjProjection.isEquivalentProjection(proj,this.map.projection)) {
								this.tileMatrixSet = tms.identifier;
							}
						}
					}
				}
			}
			return super.checkAvailability();
		}
		
		override public function supportsProjection(compareProj:*):Boolean
		{
			var proj:ProjProjection = ProjProjection.getProjProjection(compareProj);
			if(!proj)
				return false;
			//Parse the tileMatrixSets of the layer and try to find if one is in the projection map
			if(!ProjProjection.isEquivalentProjection(this.projection,proj)) {
				if(this.tileMatrixSets) {
					var arr:Array = this.tileMatrixSets.getKeys();
					var proj2:ProjProjection;
					for(var i:uint = 0 ; i < arr.length ; i++) {
						var tms:TileMatrixSet = (this.tileMatrixSets.getValue(arr[i]) as TileMatrixSet);
						proj2 = ProjProjection.getProjProjection(tms.supportedCRS);
						if(ProjProjection.isEquivalentProjection(proj2,proj)) {
							this.tileMatrixSet = tms.identifier;
							return true;
						}
					}
				}
			} else {
				//Projections are equals
				return true;
			}
			
			return false;
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
			this._formatSetted = true;
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
						this.projection = tms.supportedCRS;
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
			if(value && this._tmssProvided)
				this._useCapabilities = false;
			else
				this._useCapabilities = true;
			
			this._styleProvided = true;
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
			if(value && this._styleProvided)
				this._useCapabilities = false;
			else
				this._useCapabilities = true;
			
			this._tileProvider.tileMatrixSets = value;
			this.tileMatrixSet = this.tileMatrixSet;
			this._tmssProvided = true;
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
				var resolution:Resolution = this.getSupportedResolution(this.map.resolution);
				if(tms.tileMatrices.containsKey(resolution.value))
					return (tms.tileMatrices.getValue(resolution.value) as TileMatrix);
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
		}
		
	}
	
}