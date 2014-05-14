package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import mx.charts.chartClasses.BoundedValue;
	import mx.collections.ArrayCollection;
	
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.events.TileEvent;
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.capabilities.WMTS100Capabilities;
	import org.openscales.core.layer.ogc.provider.WMTSTileProvider;
	import org.openscales.core.layer.ogc.wmts.TileMatrix;
	import org.openscales.core.layer.ogc.wmts.TileMatrixSet;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.style.symbolizer.Geometry;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
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
		public static const WMTS_DEFAULT_FORMAT:String = "image/jpeg";
		/**
		 * @private
		 *  
		 * A tile provider for this layer.
		 */ 
		protected var _tileProvider:WMTSTileProvider = null;
		private var _useCapabilities:Boolean = false;
		private var _tmssProvided:Boolean = false;
		private var _styleProvided:Boolean = false;
		private var _loadingCapabilities:Boolean = false;
		private var _req:XMLRequest = null;
		private var _formatSetted:Boolean = false;
		
		private var _boundsGrid:Vector.<Vector.<Bounds>> = null;
		private var _boundsGridResolution:Resolution = null;
		
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
			var cap:WMTS100Capabilities = new WMTS100Capabilities();
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
			
			this._tileProvider.tileMatrixSetsLimits = layer.getValue("TileMatrixSetsLimits") as HashMap;
			
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
		
		override public function supportsProjection(compareProj:Object):Boolean
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
			var tile:ImageTile = _tileProvider.getTile(bounds, center, this);
			this.addEventListener(TileEvent.TILE_LOAD_ERROR, onTileloadError);
			return tile;
		}
		
		/**
		 * @inheritDoc
		 */ 
		override public function refreshTile(tile:ImageTile):void {
			tile.digUpAttempt = 0;
		}
		
		/**
		 * Function called when a tile load has failed (normally only status 404)
		 * 
		 * @param event The event received
		 */
		private function onTileloadError(event:TileEvent):void {
			var tile:ImageTile = event.tile as ImageTile;
			
			if (tile == null)
				return;
			if(this.grid == null) { 
				tile.draw();
				return;
			}
			setUpperTile(tile).draw();
		}	
		
		public function setUpperTile(imageTile:ImageTile):ImageTile {
			var tile:ImageTile = imageTile;
			//compute the bounds of the "mother" tile
			var upperBounds:Bounds = this.getUpperBounds(tile);
			if(upperBounds == null) {
				return tile;
			}
			upperBounds.reprojectTo(tile.bounds.projection);
			
			//Get the delta (in %) of the offset
			tile.dx = Math.round((tile.bounds.left - upperBounds.left) / upperBounds.width*1000)/1000;
			tile.dy = Math.round((upperBounds.top - tile.bounds.top) / upperBounds.height*1000)/1000;
			
			//refresh the tile
			tile = _tileProvider.refreshTile(tile, upperBounds); 
			
			return tile;
		}
		
		public function isUnderData():Boolean {
			return false;
		}
		
		public function computeDelta():Number {
			return 0;
		}
		
		/**
		 * Function computing the bounds corresponding to the mother tile of a tile
		 * 
		 * @param tile the source tile
		 * @return the upper bounds of the tile
		 */
		private function getUpperBounds(tile:ImageTile):Bounds {
			return this.getUpperboundsFromBounds(tile.bounds, tile.digUpAttempt);
		}
			
		public function getUpperboundsFromBounds(bounds:Bounds, up:Number):Bounds {
			var upperResolution:Resolution = this.getUpperResolution(this.map.resolution.reprojectTo(this.projection), up);

			//Refresh the upper bounds grid if needed
			if(this._boundsGrid == null || this._boundsGridResolution == null || upperResolution.equals(this._boundsGridResolution) != 0)
				this.computeUpperGrid(up, upperResolution);
			
			var row:Vector.<Bounds>;
			var i:Number;
			var j:Number;
			for (i=0; i < this._boundsGrid.length; i++){
				row = this._boundsGrid[i];
				for (j=0; j < row.length; j++){
					if (this.containsBounds(row[j], bounds))
						return row[j];
				}
			}
			return null;
		}
		
		/**
		 * Function computing a grid of bounds corresponding to the upper level of tm for the map resolution
		 * 
		 * @param tile the source tile
		 * @param targetResolution the upper resolution corresponding to the tms of the bounds to construct
		 */
		private function computeUpperGrid(digUpAttempt:Number, targetResolution:Resolution):void {
			var row:Vector.<Bounds>;
			var bounds:Bounds = this.map.extent.clone();
			var projectedTileOrigin:Location = this._tileOrigin.reprojectTo(bounds.projection);
//			var reprojectedBoundWidth:Number = (bounds.reprojectTo(this.map.projection).width/targetResolution.reprojectTo(this.map.projection).value);
//			var reprojectedBoundHeight:Number = (bounds.reprojectTo(this.map.projection).height/targetResolution.reprojectTo(this.map.projection).value);
			var nativeBoundWidth:Number = (bounds.width/targetResolution.value);
			var nativeBoundHeight:Number = (bounds.height/targetResolution.value);
			
//			var resquestResolutionValue:Number = targetResolution.value;
			var viewSize:Size = new Size(nativeBoundWidth, nativeBoundHeight);
			var minRows:Number = Math.ceil(viewSize.h/this.tileHeight) + Math.max(1, 2 * this.buffer);
			var minCols:Number = Math.ceil(viewSize.w/this.tileWidth) + Math.max(1, 2 * this.buffer);
			var tilelon:Number = targetResolution.value * this.tileWidth;
			var tilelat:Number = targetResolution.value * this.tileHeight;
			
			// Longitude
			var offsetlon:Number = bounds.left - projectedTileOrigin.lon;
			var tilecol:Number = Math.floor(offsetlon/tilelon) - this.buffer;
			var tilecolremain:Number = offsetlon/tilelon - tilecol;
//			var tileoffsetx:Number = -tilecolremain * this.tileWidth;
			var tileoffsetlon:Number = projectedTileOrigin.lon + tilecol * tilelon;
			
			// Latitude
			var offsetlat:Number = bounds.top - (projectedTileOrigin.lat + tilelat);  
			var tilerow:Number = Math.ceil(offsetlat/tilelat) + this.buffer;
			var tilerowremain:Number = tilerow - offsetlat/tilelat;
//			var tileoffsety:Number = -tilerowremain * this.tileHeight;
			var tileoffsetlat:Number = projectedTileOrigin.lat + tilerow * tilelat;
			
			// Offset stretching 
			var upRigth:Location = new Location(tileoffsetlon + tilelon, tileoffsetlat + tilelat, this.projection);
			upRigth = upRigth.reprojectTo(this.map.projection);
			
			var bottomLeft:Location = new Location(tileoffsetlon, tileoffsetlat, this.projection);
			bottomLeft = bottomLeft.reprojectTo(this.map.projection);
			
			var stretchedHeight:Number = (upRigth.lat - bottomLeft.lat) / targetResolution.reprojectTo(this.map.projection).value;
			var stretchedWidth:Number = (upRigth.lon-bottomLeft.lon) / targetResolution.reprojectTo(this.map.projection).value;
			
//			tileoffsetx *= stretchedWidth/this.tileWidth;
//			tileoffsety *= stretchedHeight/this.tileHeight;
			
			var tileoffsetx:Number = 0;
			var tileoffsety:Number = 0;
			var startX:Number = tileoffsetx; 
			var startLon:Number = tileoffsetlon;
			var rowidx:int = 0;
			
			this._boundsGrid = new Vector.<Vector.<Bounds>>();
			this._boundsGridResolution = targetResolution;
			
			// Build the bounds
			do {
				if(this._boundsGrid.length==rowidx) {
					row = new Vector.<Bounds>;
					this._boundsGrid.push(row);
				} else {
					row = this._boundsGrid[rowidx];
				}
				++rowidx;
				
				tileoffsetlon = startLon;
				tileoffsetx = startX;
				var colidx:int = 0;
				do {
					var tileBounds:Bounds = new Bounds(tileoffsetlon, tileoffsetlat, tileoffsetlon + tilelon, tileoffsetlat + tilelat, this.projection);
					
					upRigth = new Location(tileBounds.right, tileBounds.top, tileBounds.projection);
					upRigth = upRigth.reprojectTo(this.map.projection);
					bottomLeft = new Location(tileBounds.left, tileBounds.bottom, tileBounds.projection);
					bottomLeft = bottomLeft.reprojectTo(this.map.projection);
					
					stretchedWidth = Math.round((upRigth.lon-bottomLeft.lon)/targetResolution.reprojectTo(this.map.projection).value);
					stretchedHeight = Math.round((upRigth.lat-bottomLeft.lat)/targetResolution.reprojectTo(this.map.projection).value);
					
					if(row.length==colidx) {
						row.push(tileBounds);
					} else {
						tileBounds = row[colidx];
					}
					
					colidx=++colidx;
					tileoffsetlon += tilelon;       
					tileoffsetx += stretchedWidth;
				} while ((tileoffsetlon <= bounds.right + tilelon * this.buffer) || colidx < minCols)  
				
				tileoffsetlat -= tilelat;
				tileoffsety += stretchedHeight;
			} while((tileoffsetlat >= bounds.bottom - tilelat * this.buffer) || rowidx < minRows)
		}
		
		/**
		 * Function resetting the grid of bounds when map center has changed
		 * 
		 * @param event the event onmapcenterchanged
		 */
		override protected function onMapCenterChanged(event:MapEvent):void {
			this._boundsGrid = null;
			this._boundsGridResolution = null
			super.onMapCenterChanged(event);
		}
		
		/**
		 * Function resetting the grid of bounds when map resolution has changed
		 * 
		 * @param event the event onmapresolutionchanged
		 */
		override protected function onMapResolutionChanged(event:MapEvent):void {
			this._boundsGrid = null;
			this._boundsGridResolution = null
			super.onMapResolutionChanged(event);
		}
		
		/**
		 * Function overriding the standard bounds inclusion test
		 * it takes into account the fact that buonds are too precise some times and only takes 5 decimals
		 * 
		 * @param boundsBig the bounds including
		 * @param boundsSmall the bounds included
		 * @return true if boundsSmall is included in boundsBig, false otherwise
		 */
		private function containsBounds(boundsBig:Bounds, boundsSmall:Bounds, dec:Number=5):Boolean {
			
			dec = Math.round(dec);
			var tmpBounds:Bounds = boundsSmall;
			var tmpThis:Bounds = boundsBig;
			
			var inLeft:Boolean =   (round(tmpBounds.left, dec)   >= round(tmpThis.left, dec))   && (round(tmpBounds.left, dec)   <= round(tmpThis.right, dec));
			var inTop:Boolean =    (round(tmpBounds.top, dec)    >= round(tmpThis.bottom, dec)) && (round(tmpBounds.top, dec)    <= round(tmpThis.top, dec));
			var inRight:Boolean=   (round(tmpBounds.right, dec)  >= round(tmpThis.left, dec))   && (round(tmpBounds.right, dec)  <= round(tmpThis.right, dec));
			var inBottom:Boolean = (round(tmpBounds.bottom, dec) >= round(tmpThis.bottom, dec)) && (round(tmpBounds.bottom, dec) <= round(tmpThis.top, dec));
			
			return inTop && inLeft && inBottom && inRight;
		}
		
		/**
		 * Function overriding the standard rounding Math function to take a number of decimals into account
		 * 
		 * @param value the number to round
 		 * @param dec the number of decimals to keep
		 * @return the rounded number
		 */		
		private function round(value:Number, dec:Number):Number {
			var fact:Number = Math.pow(10, dec);
			return Math.round(value * fact)/fact;
		}
		
		
		/**
		 * Function returning the superior resolution of the target one
		 * 
		 * @param targetResolution the requested resolution
		 * @param up the number of level to go up
		 * @return the upper resolution
		 */	
		public function getUpperResolution(targetResolution:Resolution, up:Number):Resolution {
			if(up <= 0 || up > this.resolutions.length)
				return this.getSupportedResolution(targetResolution);
			
			var bestIndex:Number;
			var bestRatio:Number;
			var i:int;
			var len:int;
			var ratioSeeker:Number;
			
			if(!this.resolutions)
				return new Resolution(0);
			
			var sortedResolutions:Array = this.resolutions.concat();
			sortedResolutions.sort(Array.NUMERIC);
			sortedResolutions.reverse();
			// Find the best resotion to fit the target resolution
			bestIndex = 0;
			bestRatio = Number.POSITIVE_INFINITY;
			i = 0;
			len = sortedResolutions.length;
			
			for (i; i < len; ++i)
			{
				if (sortedResolutions[i] < targetResolution.value)
				{
					ratioSeeker =  targetResolution.value -sortedResolutions[i];
				}
				
				if ( ratioSeeker < bestRatio){
					bestRatio = ratioSeeker;
					bestIndex = i;
				}
				if (bestIndex == 0)
				{
					bestIndex = sortedResolutions.length - 1;
				}
			}
			
			bestIndex = Math.min(sortedResolutions.length - 1, bestIndex - up);
			bestIndex = Math.max(0, bestIndex);
			
			return new Resolution(sortedResolutions[bestIndex], targetResolution.projection);
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
						this.setProjection(tms.supportedCRS);
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
		 * Limits fo each supported tileMatrixSets (format is specified in <code>WMTS00Capabilities.read</code> documentation).
		 * 
		 */
		public function get tileMatrixSetsLimits():HashMap{
			return _tileProvider.tileMatrixSetsLimits;
		}
		
		/**
		 * @private
		 */ 
		public function set tileMatrixSetsLimits(value:HashMap):void{
			this._tileProvider.tileMatrixSetsLimits = value;
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
			if(super.maxExtent)return super.maxExtent;
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
		
		/**
		 * If true, when tile loading fails, a pictogram will replace the tile.
		 * 
		 * @default true
		 */
		public function get useNoDataTile():Boolean
		{
			return _tileProvider.useNoDataTile;
		}
		
		/**
		 * @private
		 */
		public function set useNoDataTile(value:Boolean):void
		{
			_tileProvider.useNoDataTile = value;
		}
		
		
	}
	
}