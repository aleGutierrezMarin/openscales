package org.openscales.core.layer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.utils.Timer;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.events.TileEvent;
	import org.openscales.core.layer.params.IHttpParams;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Base class for layers that use a lattice of tiles.
	 *
	 * @author Bouiaw
	 */
	public class Grid extends HTTPRequest
	{
		
		private var _timer:Timer;
		
		private const DEFAULT_TILE_WIDTH:Number = 256;
		
		private const DEFAULT_TILE_HEIGHT:Number = 256;
		
		/** The grid array contains tiles **/		
		private var _grid:Vector.<Vector.<ImageTile>> = null;
		
		//private var _backGridContainer:Sprite = new Sprite();
		private var _backGrid:Vector.<Vector.<Bitmap>> = null;
		
		protected var _tiled:Boolean = true;
		
		private var _numLoadingTiles:int = 0;
		
		private var _origin:Pixel = null;
		
		private var _buffer:Number;
		
		protected var _tileWidth:Number = DEFAULT_TILE_WIDTH;
		
		protected var _tileHeight:Number = DEFAULT_TILE_HEIGHT;
		
		protected var _tileOrigin:Location = new Location(0,0,"EPSG:4326");
		
		private var _tileToRemove:ImageTile;
		
		private var _defaultMatrixTranform:Matrix
		
		private var _resquestResolution:Number = 0;

		private var _initialized:Boolean = false;
		
		private var _scaleOnZoomRatiochanged:Number = 1;
		
		private var _requestedResolution:Resolution;
		
		private var _previousCenter:Location = null;
		
		private var _previousResolution:Resolution = null;
		
		private var _cumulatedRoundedValueX:Number = 0;
		
		private var _cumulatedRoundedValueY:Number = 0;
		
		private var _lastScale:Number = 1;
		private var _lastRoundedScale:Number = 1;
		
		/**
		 * Create a new grid layer
		 *
		 * @param name
		 * @param url
		 * @param params
		 * @param isBaseLayer
		 * @param visible
		 * @param projection
		 * @param proxy
		 */
		public function Grid(name:String,
							 url:String,
							 params:IHttpParams = null) {
			
			//TODO delete url and params after osmparams work
			super(name, url, params);
			
			//this.addChild(_backGridContainer);
			//this._backGridContainer.add
			this.buffer = 0;
			this._defaultMatrixTranform = this.transform.matrix;
			this.addEventListener(TileEvent.TILE_LOAD_END,tileLoadHandler);
			this.addEventListener(TileEvent.TILE_LOAD_START,tileLoadHandler);
		}
		
		override protected function onMapMove(e:MapEvent):void {
			// Clear pending requests after zooming in order to avoid to add
			// too many tile requests  when the user is zooming step by step
			if(e.zoomChanged) {
				var j:uint;
				for each(var array:Vector.<ImageTile> in this._grid)	{
					j = array.length;
					for (var i:Number = 0;i<j;i++)	{
						var tile:ImageTile = array[i];
						if (tile != null && !tile.loadComplete) {
							tile.clear();
						}
					}
				}
			}
			super.onMapMove(e);
		}
		
		override public function destroy():void {
			this.clear();
			this.grid = null;
			super.destroy();
		}
		
		/**
		 * Go through and remove all tiles from the grid, calling
		 *    destroy() on each of them to kill circular references
		 */
		override public function clear():void {
			if (this._grid && this._grid.length>0) {
				var i:uint = this._grid.length;
				var j:uint = this._grid[0].length;
				var iRow:uint;
				var iCol:uint;
				for(iRow=0; iRow < i; ++iRow) {
					var row:Vector.<ImageTile> = this._grid.pop();
					for(iCol=0; iCol < j; ++iCol) {
						var tile:ImageTile = row.pop();
						this.removeTileMonitoringHooks(tile);
						tile.destroy();						
					}
				}
				while (this.numChildren > 0)
					this.removeChildAt(0);
				this.grid = null;
			}
		}
		
		override public function get available():Boolean
		{
			return (super.available && ProjProjection.isEquivalentProjection(this.projection,this.map.projection));
		}
		
		/**
		 * Override the redraw method for raster data. Check the informations of the map
		 * to define the available parameter for raster data.
		 */
		override public function redraw(fullRedraw:Boolean = false):void 
		{
			if (this.map == null)
				return;
			
			if (!this.map.mapInitialized)
				return;

			if (!available || !this.visible) 
			{
				this.clear();
				this._initialized = false;
				return;
			}
			var centerChangedCache:Boolean = this._centerChanged;
			var resolutionChangedCache:Boolean = this._resolutionChanged;
			var projectionChangedCache:Boolean = this._projectionChanged;
			this._centerChanged = false;
			this._projectionChanged = false;
			this._resolutionChanged = false;
			
			var ratio:Number;
			
			var resolution:Number = this.getSupportedResolution(this.map.resolution).value;
			var bounds:Bounds = this.map.extent.clone();
			var tilesBounds:Bounds = this.getTilesBounds();  
			var forceReTile:Boolean = this._grid==null || !this._grid.length || fullRedraw || !tilesBounds;
			if (this.loadComplete)
			{
				this._backGrid = null;
			}
			
			if (centerChangedCache || projectionChangedCache || resolutionChangedCache || forceReTile || !_initialized)
			{
				if (!this._timer.running)
				{
					if (!this.tiled) 
					{
						/*if (this.loadComplete)
						{*/
						var bmpBounds:Bounds;
						if(this._backGrid == null)
						{
							this._backGrid = new Vector.<Vector.<Bitmap>>(1);
							this._backGrid[0] = new Vector.<Bitmap>(1);
							this._backGrid[0][0] = null;
						}
						if(this._initialized)
						{
							var NewLayerBounds:Bounds = this.maxExtent.getIntersection(bounds);
							NewLayerBounds = this.map.maxExtent.getIntersection(NewLayerBounds);
							bmpBounds = this.grid[0][0].bounds;
							var scale:Number = this.scaleX;
							var intersectBounds:Bounds = NewLayerBounds.getIntersection(bmpBounds);
							if (intersectBounds != null)
							{
								var BMD:BitmapData = new BitmapData(this.map.width , this.map.height , true, 0x000000);
								BMD.draw(this, null, null, null, null, true);
								_backGrid[0][0] = new Bitmap(BMD);
								_backGrid[0][0].scaleX = _backGrid[0][0].scaleY = scale;
								_backGrid[0][0].x = this.x;
								_backGrid[0][0].y = this.y;
							}else
							{
								_backGrid[0][0] = null;
							}
							
						}
						this.clear();
						this._lastScale = 1;
						this.initSingleTile(bounds);
						if(_backGrid[0][0])
						{
							_backGrid[0][0].x -= this.grid[0][0].x;
							_backGrid[0][0].y -= this.grid[0][0].y;
							this.grid[0][0].addChildAt(_backGrid[0][0], 0);
							this.addChild(this.grid[0][0]);
						}
					} else {
						if ((resolution != this._resquestResolution) || forceReTile)
						{
							
							var bmpBounds:Bounds;
							
							if(this._initialized)
							{
								var gridRowLength:int = this.grid.length;
								var gridColLength:int = this.grid[0].length;
								
								// Compute the bitmapBounds
								var TopLeftCorner:Location = new Location(this.grid[0][0].bounds.left, this.grid[0][0].bounds.top, this.projection);
								var BottomRightCorner:Location = new Location(this.grid[gridRowLength - 1][gridColLength - 1].bounds.right, this.grid[gridRowLength - 1][gridColLength - 1].bounds.bottom);
								var firstDrawnTileIndex:Point;
								var lastDrawnTileIndex:Point;
								/*outerLoop: for (var i:int = 0; i< gridRowLength; ++i)
								{
									for (var j:int = 0; j < gridColLength; ++j)
									{
										if (this.grid[i][j].drawn)
										{
											var gridbounds:Bounds = grid[i][j].bounds;
											TopLeftCorner = new Location(gridbounds.left, gridbounds.top, this.projection);
											firstDrawnTileIndex = new Point(i, j);
											break outerLoop;
										}
									}
								}
								
								outerLoop2: for (var i:int = gridRowLength - 1; i > 0; --i)
								{
									for (var j:int = gridColLength - 1 ; j > 0 ; --j)
									{
										if (this.grid[i][j].drawn)
										{
											var gridbounds:Bounds = grid[i][j].bounds;
											BottomRightCorner = new Location(gridbounds.right, gridbounds.bottom, this.projection);
											lastDrawnTileIndex = new Point(i, j);
											break outerLoop2;
										}
									}
								}*/
								
								
								var NewLayerBounds:Bounds = this.maxExtent.getIntersection(bounds);
								NewLayerBounds = this.map.maxExtent.getIntersection(NewLayerBounds);
								bmpBounds = this.grid[0][0].bounds;
								var scale:Number = this.scaleX;
								var intersectBounds:Bounds = NewLayerBounds.getIntersection(bmpBounds);
								/*if (intersectBounds != null)
								{*/
								var matrix:Matrix = new Matrix;
								matrix.scale(scale, scale);
								var drawnWidth:Number = (BottomRightCorner.x - TopLeftCorner.x) / this.requestedResolution.value;
								var drawnHeight:Number = -(BottomRightCorner.y - TopLeftCorner.y) / this.requestedResolution.value;
								
								var BMD:BitmapData = new BitmapData(drawnWidth, drawnHeight, false, 0x000000);
								BMD.draw(this, null, null, null, null, true);
								var fullBitmap:Bitmap = new Bitmap(BMD);
								
								
								var bmpRequestedResolution:Number = this.requestedResolution.value;
								var fullBmpBounds:Bounds = new Bounds(TopLeftCorner.x, BottomRightCorner.y, BottomRightCorner.x, TopLeftCorner.y);/*TopLeftCorner.y - (BMD.height*this.requestedResolution.value),TopLeftCorner.x + (BMD.width*this.requestedResolution.value),TopLeftCorner.y,this.projection);*/
								
								
								
								//_backGrid[0][0] = new Bitmap(BMD);
								
								//_backGrid[0][0].scaleX *= scale
								//_backGrid[0][0].scaleY *= scale;
								//this.addChild(_backGrid[0][0]);
								//_backGrid[0][0].scaleX = _backGrid[0][0].scaleY = scale;
								//_backGrid[0][0].x = this.x;
								//_backGrid[0][0].y = this.y;
								/*}else*/
								/*{
									_backGrid[0][0] = null;
								}*/
							}
							
							this.initGriddedTiles(bounds, true);
							this._lastScale = 1;
							ratio = this._requestedResolution.value/this.map.resolution.value;
							this.scaleLayer(ratio, new Pixel(this.x - this._origin.x, this.y - this._origin.y));
							resolutionChangedCache = false;
							this._previousResolution = this.map.resolution;
							centerChangedCache = false;
							this._previousCenter = this.map.center.clone();
							this.actualizeGridSize(bounds);

							if (fullBmpBounds != null)
							{
								gridRowLength = this.grid.length;
								gridColLength = this.grid[0].length;
								
								this._backGrid = new Vector.<Vector.<Bitmap>>(1);
								this._backGrid[0] = new Vector.<Bitmap>(1);
								for (var i:int = 0; i< gridRowLength; ++i)
								{
									this._backGrid[i] = new Vector.<Bitmap>(1);
									for (var j:int = 0; j< gridColLength; ++j)
									{
										this._backGrid[i][j] = new Bitmap();
									}
								}
								
								
								for (var i:int = 0; i< gridRowLength; ++i)
								{
									for (var j:int = 0; j < gridColLength; ++j)
									{
										if (this.grid[i][j].bounds.intersectsBounds(fullBmpBounds, false))
										{
											var bufferTileBound:Bounds = this.grid[i][j].bounds.getIntersection(fullBmpBounds);
											var tiletopLeftcorner:Location = new Location(bufferTileBound.left, bufferTileBound.top, this.projection);
											var deltaX:Number = (tiletopLeftcorner.x - TopLeftCorner.x)/bmpRequestedResolution;
											var deltaY:Number = -(tiletopLeftcorner.y - TopLeftCorner.y)/bmpRequestedResolution;
											var bmpRatio:Number = this.requestedResolution.value/bmpRequestedResolution;
											var region:Rectangle = new Rectangle(deltaX, deltaY, this.tileWidth/bmpRatio, this.tileHeight/bmpRatio);
											var tile:BitmapData = new BitmapData(this.tileWidth, this.tileHeight);
											tile.copyPixels(BMD, region, new Point());
											_backGrid[i][j] = new Bitmap(tile);
										}
									}
								}
								for (var i:int = 0; i< gridRowLength; ++i)
								{
									for (var j:int = 0; j < gridColLength; ++j)
									{
										if (_backGrid[i][j] && this.grid[i][j])
										{
											_backGrid[i][j].scaleX = _backGrid[i][j].scaleY *= (bmpRequestedResolution/this.requestedResolution.value);
											//_backGrid[i][j].scaleX = _backGrid[i][j].scaleY *= 1/this.scaleX;
											this.grid[i][j].addChildAt(_backGrid[i][j], 0);
										}
									}
								}
							}
								
							/*if(_backGrid[0][0])
							{
								//_backGrid[0][0].x -= this.grid[0][0].x;
								//_backGrid[0][0].y -= this.grid[0][0].y;
								_backGrid[0][0].scaleX = _backGrid[0][0].scaleY *= 1/this.scaleX;
								this.grid[0][0].addChildAt(_backGrid[0][0], 0);
								//this.addChildAt(_backGrid[0][0], 0);
								//this.addChild(this.grid[0][0]);
							}*/
						} else 
						{
							this.moveGriddedTiles(bounds);
							this.actualizeGridSize(bounds);
							if (_backGrid)
							{
								if (_backGrid[0][0])
								{
									//this.grid[0][0].addChildAt(_backGrid[0][0], 0);
								}
							}
						}
					} 
					_initialized = true;
				}
			}
			
			if (resolutionChangedCache)
			{
				ratio = this._previousResolution.value / this.map.resolution.value;
				this.scaleLayer(ratio, new Pixel(this.map.size.w/2, this.map.size.h/2));
				this._previousResolution = this.map.resolution;
				resolutionChangedCache = false
			}
			
			if (centerChangedCache)
			{
				var deltaLon:Number = this.map.center.lon - this._previousCenter.lon;
				var deltaLat:Number = this.map.center.lat - this._previousCenter.lat;
				var deltaX:Number = deltaLon/this.map.resolution.value;
				var deltaY:Number = deltaLat/this.map.resolution.value;
				
				this.x = this.x - deltaX;
				this.y = this.y + deltaY;
				this._previousCenter = this.map.center;
				centerChangedCache = false;
			}
		}
		
		/**
		 * Method that will scale the layer sprite with the given scale at the given pixel
		 */
		private function scaleLayer(scale:Number, offSet:Pixel = null):void
		{
			if (offSet == null)
			{
				offSet = new Pixel(0, 0);
			}
			this.scaleX = this.scaleY = this._lastScale;
			var temporaryScale:Number = this.scaleX * scale;
			this._lastScale = temporaryScale;
			var temporaryWidth:Number = this.tileWidth * temporaryScale;
			var roundedWidth:Number = Math.round(temporaryWidth);
			temporaryScale = roundedWidth / this.tileWidth;
			this.scaleX = this.scaleY = temporaryScale;
			this.x -= (offSet.x - this.x) * (scale - 1);
			this.y -= (offSet.y - this.y) * (scale - 1);
		}
		
		/**
		 * Check if the grid is not too small to fill the specified bound. 
		 * If it's too small, this method will add row and collumns to the grid
		 */
		public function actualizeGridSize(bounds:Bounds):void
		{
			if (this._grid == null)
			{
				return;
			}
			var tileLon:Number;
			var tileLat:Number;
			var nbTileToAdd:Number;
			var tileoffsetlon:Number;
			var tileoffsetlat:Number;
			var tileBounds:Bounds;
			var x:Number;
			var y:Number;
			var px:Pixel;
			var tile:ImageTile;
			var tlLayer:Pixel = this.grid[0][0].position;
			var ratio:Number = this.getSupportedResolution(this.map.resolution).value / this.map.resolution.value; 
			var tlViewPort:Pixel =  new Pixel(tlLayer.x + this.x/ratio, tlLayer.y + this.y/ratio); 
			// Add Columns
			if(bounds.width / this.map.resolution.value > (this._grid[0].length - buffer) * this.tileWidth * ratio + tlViewPort.x * ratio)
			{	
				var gridRowLength:Number = this._grid[0].length;
				var gridRightBound:Number = this.grid[0][gridRowLength-1].bounds.right;
				var deltaLon:Number = bounds.right - gridRightBound;
				tileLon = this.tileWidth * this.requestedResolution.value;
				tileLat = this.tileHeight * this.requestedResolution.value;
				nbTileToAdd = deltaLon / tileLon;
				nbTileToAdd = Math.abs(nbTileToAdd);
				if (nbTileToAdd > 0)
				{
					var rowLength:Number = this._grid.length;
					for(var _r:int = 0; _r < rowLength; ++_r)
					{
						for (var i:int = 0; i < nbTileToAdd; ++i)
						{
							tileoffsetlon = this._grid[_r][gridRowLength - 1 + i].bounds.right;
							tileoffsetlat = this._grid[_r][gridRowLength - 1 + i].bounds.bottom;
							tileBounds = new Bounds(tileoffsetlon, 
								tileoffsetlat, 
								tileoffsetlon + tileLon,
								tileoffsetlat + tileLat,
								this.projection);
							x = this._grid[_r][gridRowLength - 1 + i].x + this.tileWidth;
							
							y = this._grid[_r][gridRowLength - 1 + i].y;
							
							px = new Pixel(x, y);
							tile = this.addTile(tileBounds, px);
							this._grid[_r].push(tile);
						}
					}
				}
			}
			
			// Add rows
			if(bounds.height / this.map.resolution.value > (this._grid.length - buffer) * this.tileHeight * ratio + tlViewPort.y * ratio)
			{
				var gridColLength:Number = this._grid.length;
				var gridBottomBound:Number = this.grid[gridColLength-1][0].bounds.bottom;
				var deltaLat:Number = bounds.bottom - gridBottomBound;
				tileLon = this.tileWidth * this.requestedResolution.value;
				tileLat = this.tileHeight * this.requestedResolution.value;
				nbTileToAdd = deltaLat / tileLat;
				nbTileToAdd = Math.abs(nbTileToAdd);
				if (nbTileToAdd > 0)
				{
				var colLength:Number = this._grid[0].length;
					for (var j:int = 0; j < nbTileToAdd; ++j)
					{
						var row:Vector.<ImageTile> = new Vector.<ImageTile>();
						for(var c:int = 0; c < colLength; ++c)
						{
							tileoffsetlon = this._grid[gridColLength - 1 + j][c].bounds.left;
							tileoffsetlat = this._grid[gridColLength - 1 + j][c].bounds.bottom;
							tileBounds = new Bounds(tileoffsetlon, 
								tileoffsetlat - tileLat, 
								tileoffsetlon + tileLon,
								tileoffsetlat,
								this.projection);
							x = this._grid[gridColLength - 1 + j][c].x;
							
							y = this._grid[gridColLength - 1 + j][c].y + this.tileHeight;
							
							px = new Pixel(x, y);
							tile = this.addTile(tileBounds, px);
							row.push(tile);
						}
						this._grid.push(row);
					}
				}
			}
			var rl:int = this._grid.length;
			var cl:int;
			for (var r:int=0; r<rl; r++) {
				var _row:Vector.<ImageTile> = this._grid[r];
				cl = _row.length;
				for (var col:int=0; col<cl; ++col) {
					var _tile:ImageTile = _row[col];
					if (!_tile.drawn && 
						_tile.bounds.intersectsBounds(bounds, false)) {
						_tile.draw();
					}
				}
			}
		}
		
		public function set tileWidth(value:Number):void {
			this._tileWidth = value;	
		}
		
		public function get tileWidth():Number {
			return this._tileWidth;
		}
		
		public function set tileHeight(value:Number):void {
			this._tileHeight= value;	
		}
		
		public function get tileHeight():Number {
			return this._tileHeight;
		}	
		
		
		override protected function onMapCenterChanged(event:MapEvent):void
		{
			this._timer.reset();
			this._timer.start();
			super.onMapCenterChanged(event);
		}
		
		override protected function onMapResolutionChanged(event:MapEvent):void
		{
			
			this._timer.reset();
			this._timer.start();
			super.onMapResolutionChanged(event);
		}
		/**
		 * Return the bounds of the tile grid.
		 *
		 * @return A Bounds object representing the bounds of all the currently loaded tiles
		 */
		public function getTilesBounds():Bounds {
			if(this._grid == null)
				return null;
			var i:uint = this._grid.length;
			
			if (i>0) {
				var bottom:int = i - 1;
				var bottomLeftTile:ImageTile = this._grid[bottom][0];
				var right:int = this._grid[0].length - 1; 
				var topRightTile:ImageTile = this._grid[0][right];
				return new Bounds(bottomLeftTile.bounds.left, 
					bottomLeftTile.bounds.bottom,
					topRightTile.bounds.right, 
					topRightTile.bounds.top,
					this.projection);
			}
			return null;
		}
		
		/**
		 * Initialization singleTile
		 * This Method compute the intersection between the map extent, the layer maxExtent and the map maxExtent
		 * to resquest the correct extent and build the grid to set up a single tile layer.
		 * @param bounds
		 */
		public function initSingleTile(bounds:Bounds):void {
			this.transform.matrix = this._defaultMatrixTranform.clone();
			this._requestedResolution = this.getSupportedResolution(this.map.resolution);
			var center:Location;
			var geoTileWidth:Number;
			var geoTileHeight:Number;
			
			bounds = this.maxExtent.getIntersection(bounds);
			bounds = this.map.maxExtent.getIntersection(bounds);
			
			if (bounds == null)
			{
				Trace.debug("Singletile requested extent is null, no intersection");
				return;
			}
			if(bounds.projection!=this.projection)
				bounds = bounds.reprojectTo(this.projection);
			
			center= bounds.center;
			geoTileWidth = bounds.width;
			geoTileHeight = bounds.height;
			var topLeftCorner:Location = new Location(bounds.left, bounds.top);
			var bottomRightCorner:Location = new Location(bounds.right, bounds.bottom);
			this.tileWidth = Math.round(geoTileWidth/this.map.resolution.value);
			this.tileHeight = Math.round(geoTileHeight/this.map.resolution.value);
			var ul:Location = new Location(bounds.left, bounds.top, bounds.projection);
			var px:Pixel = this.map.getMapPxFromLocation(ul);
			
			if(this._grid==null) {
				this._grid = new Vector.<Vector.<ImageTile>>(1);
				this._grid[0] = new Vector.<ImageTile>(1);
				this._grid[0][0] = null;
			}
			
			var tile:ImageTile = this.addTile(bounds, px);
			tile.draw();
			if ( this._grid[0][0] != null)
			{
				this._tileToRemove = this._grid[0][0];
				tile.layer.addEventListener(TileEvent.TILE_LOAD_END,this.removeTransitionTile);
				
			}
			this._grid[0][0] = tile;         
			this.removeExcessTiles(1,1);
		}
		
		/**
		 * 
		 */
		private function removeTransitionTile(event:TileEvent):void
		{
			this._tileToRemove.destroy();
		}
		
		public function getSupportedResolution(targetResolution:Resolution, finest:Boolean = true):Resolution
		{
			var bestResolution:Number;
			var bestRatio:Number;
			var i:int;
			var len:int;
			var ratioSeeker:Number;
			if (finest)
			{
				if(!this.resolutions)
					return new Resolution(0);
				// Find the best resotion to fit the target resolution
				bestResolution = 0;
				bestRatio = Number.POSITIVE_INFINITY;
				i = 0;
				len = this.resolutions.length;
				
				for (i; i < len; ++i)
				{
					if (this.resolutions[i] <= targetResolution.value)
					{
						ratioSeeker =  targetResolution.value -this.resolutions[i];
					}
					
					if ( ratioSeeker < bestRatio){
						bestRatio = ratioSeeker;
						bestResolution = this.resolutions[i];
					}
					if (bestResolution == 0)
					{
						bestResolution = resolutions[resolutions.length - 1];
					}
				}
				return new Resolution(bestResolution, targetResolution.projection);
			}else
			{
				if(!this.resolutions)
					return new Resolution(0);
				// Find the best resotion to fit the target resolution
				bestResolution = 0;
				bestRatio = Number.POSITIVE_INFINITY;
				i = 0;
				len = this.resolutions.length;
				
				for (i; i < len; ++i)
				{
					if (this.resolutions[i] >= targetResolution.value)
					{
						ratioSeeker = this.resolutions[i]-targetResolution.value;
					}
					
					if ( ratioSeeker < bestRatio){
						bestRatio = ratioSeeker;
						bestResolution = this.resolutions[i];
					}
					if (bestResolution == 0)
					{
						bestResolution = resolutions[0];
					}
				}
				return new Resolution(bestResolution, targetResolution.projection);
			}
		}
		
		/**
		 * Ititialize gridded tiles
		 * 
		 * when clearTiles == true (most of time), Tile.clearAndMoveTo is called. 
		 * This method reset tile, so produce a white flash (usefull when loading map)
		 * Actually used when zooming in / out
		 * 
		 * when clearTiles == false, Tile.moveTo is called,
		 * no white flash, but there is some problems if used for something else than modifying map extent
		 */
		public function initGriddedTiles(bounds:Bounds, clearTiles:Boolean=true):void {
			this.transform.matrix = this._defaultMatrixTranform.clone();
			/*if (this._grid != null)
			{
				var rowlength:Number = this._grid.length;
				for (var i:int = 0; i<rowlength; ++i)
				{
					var colLength:Number = this._grid[i].length;
					for (var j:int = 0; j<colLength; ++j)
					{
						this._grid[i][j].transform.matrix = this._defaultMatrixTranform.clone();
					}
				}
			}*/
			var projectedTileOrigin:Location = this._tileOrigin.reprojectTo(bounds.projection);
			this.requestedResolution = this.getSupportedResolution(this.map.resolution);
			_resquestResolution = this.requestedResolution.value;
			var viewSize:Size = this.map.size;
			var minRows:Number = Math.ceil(viewSize.h/this.tileHeight) + 
				Math.max(1, 2 * this.buffer);
			var minCols:Number = Math.ceil(viewSize.w/this.tileWidth) +
				Math.max(1, 2 * this.buffer);
			
			
			var tilelon:Number = _resquestResolution * this.tileWidth;
			var tilelat:Number = _resquestResolution * this.tileHeight;
			
			// Longitude
			var offsetlon:Number = bounds.left - projectedTileOrigin.lon;
			var tilecol:Number = Math.floor(offsetlon/tilelon) - this.buffer;
			var tilecolremain:Number = offsetlon/tilelon - tilecol;
			var tileoffsetx:Number = -tilecolremain * this.tileWidth;
			var tileoffsetlon:Number = projectedTileOrigin.lon + tilecol * tilelon;
			
			// Latitude
			var offsetlat:Number = bounds.top - (projectedTileOrigin.lat + tilelat);  
			var tilerow:Number = Math.ceil(offsetlat/tilelat) + this.buffer;
			var tilerowremain:Number = tilerow - offsetlat/tilelat;
			var tileoffsety:Number = -tilerowremain * this.tileHeight;
			var tileoffsetlat:Number = projectedTileOrigin.lat + tilerow * tilelat;
			tileoffsetx= Math.round(tileoffsetx);
			tileoffsety= Math.round(tileoffsety)
			this._origin = new Pixel(tileoffsetx, tileoffsety);
			this.x += tileoffsetx;
			this.y += tileoffsety;
			tileoffsetx = 0;
			tileoffsety = 0;
			//tileoffsetx = Math.round(tileoffsetx);
			//tileoffsety = Math.round(tileoffsety);
			var startX:Number = tileoffsetx; 
			var startLon:Number = tileoffsetlon;
			var rowidx:int = 0;
			
			if(this._grid == null) {
				this._grid = new Vector.<Vector.<ImageTile>>();
			}
			do {
				var row:Vector.<ImageTile>;
				if(this._grid.length==rowidx) {
					row = new Vector.<ImageTile>;
					this._grid.push(row);
				} else {
					row = this._grid[rowidx];
				}
				++rowidx;
				
				tileoffsetlon = startLon;
				tileoffsetx = startX;
				var colidx:int = 0;
				do {
					var tileBounds:Bounds = new Bounds(tileoffsetlon, 
						tileoffsetlat, 
						tileoffsetlon + tilelon,
						tileoffsetlat + tilelat,
						this.projection);
					var x:Number = tileoffsetx;
					
					var y:Number = tileoffsety;
					
					var px:Pixel = new Pixel(x, y);
					var tile:ImageTile;
					if(row.length==colidx) {
						tile = this.addTile(tileBounds, px);
						row.push(tile);
					} else {
						tile = row[colidx];
						if(clearTiles)
							tile.clearAndMoveTo(tileBounds, px, false);
						else 
							tile.moveTo(tileBounds, px, false);
					}
					colidx=++colidx;
					
					tileoffsetlon += tilelon;       
					tileoffsetx += this.tileWidth;
				} while ((tileoffsetlon <= bounds.right + tilelon * this.buffer) || colidx < minCols)  
				
				tileoffsetlat -= tilelat;
				tileoffsety += this.tileHeight;
			} while((tileoffsetlat >= bounds.bottom - tilelat * this.buffer) || rowidx < minRows)
			
			//shave off exceess rows and colums
			this.removeExcessTiles(rowidx, colidx);
			
			//now actually draw the tiles
			this.spiralTileLoad();
		}
		/**
		 *   Starts at the top right corner of the grid and proceeds in a spiral
		 *    towards the center, adding tiles one at a time to the beginning of a
		 *    queue.
		 *
		 *   Once all the grid's tiles have been added to the queue, we go back
		 *    and iterate through the queue (thus reversing the spiral order from
		 *    outside-in to inside-out), calling draw() on each tile.
		 */
		protected function spiralTileLoad():void {
			var tileQueue:Array = new Array();
			var directions:Array = ["right", "down", "left", "up"];
			var iRow:int = 0;
			var iCell:int = -1;
			var direction:int = 0;
			var directionsTried:int = 0;
			
			if(this._grid.length==0)
				return;
			
			while( directionsTried < 4) {
				var testRow:int = iRow;
				var testCell:int = iCell;
				switch (directions[direction]) {
					case "right":
						testCell++;
						break;
					case "down":
						testRow++;
						break;
					case "left":
						testCell--;
						break;
					case "up":
						testRow--;
						break;
				} 
				
				var gridx:int = this._grid.length;
				
				if(testRow>=0 && testRow < this._grid.length && this._grid[testRow])
					var gridy:int = this._grid[testRow].length;
				
				// if the test grid coordinates are within the bounds of the 
				//  grid, get a reference to the tile.
				var tile:ImageTile = null;
				if ((testRow < this._grid.length) && (testRow >= 0) &&
					(testCell < this._grid[testRow].length) && (testCell >= 0)) {
					tile = this._grid[testRow][testCell];
				}
				
				if ((tile != null) && (!tile.queued)) {
					//add tile to beginning of queue, mark it as queued.
					tileQueue.push(tile);
					tile.queued = true;
					
					//restart the directions counter and take on the new coords
					directionsTried = 0;
					iRow = testRow;
					iCell = testCell;
				} else {
					//need to try to load a tile in a different direction
					direction = (direction + 1) % 4;
					directionsTried++;
				}
			} 
			// now we go through and draw the tiles in forward order
			for(var i:int=tileQueue.length-1; i >= 0; i--) {
				tile = tileQueue[i];
				tile.draw();
				//mark tile as unqueued for the next time (since tiles are reused)
				tile.queued = false;       
			}
		}
		
		public function addTile(bounds:Bounds, position:Pixel):ImageTile {
			return null;
		}
		
		override public function set x(value:Number):void
		{
			var epsilon:Number = value - Math.round(value);
			this._cumulatedRoundedValueX += epsilon;
			super.x = Math.round(value);
			if (this._cumulatedRoundedValueX >= 1 || this._cumulatedRoundedValueX <= -1)
			{
				var roundedCumulatedValue:Number = Math.round(_cumulatedRoundedValueX);
				super.x = super.x + roundedCumulatedValue;
				this._cumulatedRoundedValueX -= roundedCumulatedValue;
			}
		}
		
		override public function set y(value:Number):void
		{
			var epsilon:Number = value - Math.round(value);
			this._cumulatedRoundedValueY += epsilon;
			super.y = Math.round(value);
			if (this._cumulatedRoundedValueY >= 1 || this._cumulatedRoundedValueY <= -1)
			{
				var roundedCumulatedValue:Number = Math.round(_cumulatedRoundedValueY);
				super.y = super.y + roundedCumulatedValue;
				this._cumulatedRoundedValueY -= roundedCumulatedValue;
			}
		}
		
		
		public function removeTileMonitoringHooks(tile:ImageTile):void {
		}
		/**
		 * This mOonly when mapEvent.MOVE_END is thrown
		 */
		public function moveGriddedTiles(bounds:Bounds):void {
			var buffer:Number = this.buffer || 1;
			
			while (true) {
				var tlLayer:Pixel = this.grid[0][0].position;
				var ratio:Number = this.getSupportedResolution(this.map.resolution).value / this.map.resolution.value; 
				var tlViewPort:Pixel =  new Pixel(tlLayer.x + this.x/ratio, tlLayer.y + this.y/ratio); 
				if (tlViewPort.x > -this.tileWidth * (buffer - 1)) {
					this.shiftColumn(true);
				} else if (tlViewPort.x < -this.tileWidth * buffer) {
					this.shiftColumn(false);
				} else if (tlViewPort.y > -this.tileHeight * (buffer - 1)) {
					this.shiftRow(true);
				} else if (tlViewPort.y < -this.tileHeight * buffer) {
					this.shiftRow(false);
				} else {
					break;
				}
			};
			
			if (this.buffer == 0) {
				var rl:int = this._grid.length;
				var cl:int;
				for (var r:int=0; r<rl; r++) {
					var row:Vector.<ImageTile> = this._grid[r];
					cl = row.length;
					for (var c:int=0; c<cl; ++c) {
						var tile:ImageTile = row[c];
						if (!tile.drawn && 
							tile.bounds.intersectsBounds(bounds, false)) {
							tile.draw();
						}
					}
				}
			}
		}
		
		/**
		 * Shifty grid work
		 *
		 * @param prepend if true, prepend to beginning.
		 *                          if false, then append to end
		 */
		private function shiftRow(prepend:Boolean):void {
			var modelRowIndex:int = (prepend) ? 0 : (this._grid.length - 1);
			var modelRow:Vector.<ImageTile> = this._grid[modelRowIndex];
			var resolution:Number = this.getSupportedResolution(this.map.resolution).value;
			var deltaY:Number = (prepend) ? -this.tileHeight : this.tileHeight;
			var deltaLat:Number = resolution * -deltaY;
			var row:Vector.<ImageTile> = (prepend) ? this._grid.pop() : this._grid.shift();
			
			var j:uint = modelRow.length;
			for (var i:uint=0; i < j; ++i) {
				var modelTile:ImageTile = modelRow[i];
				var bounds:Bounds = modelTile.bounds.clone();
				var position:Pixel = modelTile.position.clone();
				bounds.bottom = bounds.bottom + deltaLat;
				bounds.top = bounds.top + deltaLat;
				position.y = position.y + deltaY;
				row[i].clearAndMoveTo(bounds, position);
			}
			
			if (prepend) {
				this._grid.unshift(row);
			} else {
				this._grid.push(row);
			}
		}
		
		/**
		 * Shift grid work in the other dimension
		 *
		 * @param prepend if true, prepend to beginning.
		 *                          if false, then append to end
		 */
		private function shiftColumn(prepend:Boolean):void {
			var deltaX:Number = (prepend) ? -this.tileWidth : this.tileWidth;
			var resolution:Number = this.requestedResolution.value;
			var deltaLon:Number = resolution * deltaX;
			
			var j:uint = this._grid.length;
			for (var i:uint=0; i<j; ++i) {
				var row:Vector.<ImageTile> = this._grid[i];
				var modelTileIndex:int = (prepend) ? 0 : (row.length - 1);
				var modelTile:ImageTile = row[modelTileIndex];
				var bounds:Bounds = modelTile.bounds.clone();
				var position:Pixel = modelTile.position.clone();
				bounds.left = bounds.left + deltaLon;
				bounds.right = bounds.right + deltaLon;
				position.x = position.x + deltaX;
				var tile:ImageTile = prepend ? this._grid[i].pop() : this._grid[i].shift()
				tile.clearAndMoveTo(bounds, position);
				if (prepend) {
					this._grid[i].unshift(tile);
				} else {
					this._grid[i].push(tile);
				}
			}
		}
		
		/**
		 * When the size of the map or the buffer changes, we may need to
		 *     remove some excess rows and columns.
		 *
		 * @param rows Maximum number of rows we want our grid to have.
		 * @param colums Maximum number of columns we want our grid to have.
		 */
		public function removeExcessTiles(rows:int, columns:int):void {
			while (this._grid.length > rows) {
				var row:Vector.<ImageTile> = this._grid.pop();
				for (var i:int=0, l:int=row.length; i<l; i++) {
					var tile:ImageTile = row[i];
					this.removeTileMonitoringHooks(tile)
					tile.destroy();
				}
			}
			
			for (i=0, l=this._grid.length; i<l; i++) {
				row = this._grid[i];
				while (row.length > columns) {
					tile = row.pop();
					this.removeTileMonitoringHooks(tile);
					tile.destroy();
				}
			}
		}
		
		/**
		 * Returns The tile bounds for a layer given a pixel location.
		 *
		 * @param viewPortPx The location in the viewport.
		 *
		 * @return Bounds of the tile at the given pixel location.
		 */
		public function getTileBounds(viewPortPx:Pixel):Bounds {
			var maxExtent:Bounds = this.maxExtent;
			var resolution:Number = this.map.resolution.value;
			var tileMapWidth:Number = resolution * this.tileWidth;
			var tileMapHeight:Number = resolution * this.tileHeight;
			var mapPoint:Location = this.getLocationFromMapPx(viewPortPx);
			var tileLeft:Number = maxExtent.left + (tileMapWidth * Math.floor((mapPoint.lon - maxExtent.left) / tileMapWidth));
			var tileBottom:Number = maxExtent.bottom + (tileMapHeight * Math.floor((mapPoint.lat - maxExtent.bottom) / tileMapHeight));
			return new Bounds(tileLeft,
				tileBottom,
				tileLeft + tileMapWidth,
				tileBottom + tileMapHeight,
				this.projection);
		}
		
		private function tileLoadHandler(event:TileEvent):void	{
			switch(event.type)	{
				case TileEvent.TILE_LOAD_START:	{
					// set layer loading to true
					this.loading = true;
					break;
				}
				case TileEvent.TILE_LOAD_END:	{
					// check if there are still tiles loading
					for each(var array:Vector.<ImageTile> in this._grid)	{
						var j:uint = array.length;
						for (var i:Number = 0;i<j;i++)	{
							var tile:ImageTile = array[i];
							if (tile != null && !tile.loadComplete){
								return;	
							}
						}
					}
					this.loading = false;
					break;
				}
			}
		}
		
		private function onTimerEnd(event:TimerEvent):void
		{
			/*if(!this.tiled)
			{*/
				this._centerChanged = true;
				this._resolutionChanged = true;
			/*}*/
		}
		
		//Getters and Setters
		override public function get imageSize():Size {
			if(this._imageSize == null)
				this._imageSize = new Size(this.tileWidth, this.tileHeight);
			return new Size(this.tileWidth, this.tileHeight); 
		}
		
		public function get grid():Vector.<Vector.<ImageTile>> {
			return this._grid;
		}
		
		public function set grid(value:Vector.<Vector.<ImageTile>>):void {
			this._grid = value;
		}
		
		public function get tiled():Boolean {
			return this._tiled;
		}
		
		public function set tiled(value:Boolean):void {
			this._tiled = value;
		}
		
		public function get numLoadingTiles():int {
			return this._numLoadingTiles;
		}
		
		public function set numLoadingTiles(value:int):void {
			this._numLoadingTiles = value;
		}
		
		/**
		 * Used only when in gridded mode, this specifies the number of
		 * extra rows and colums of tiles on each side which will
		 * surround the minimum grid tiles to cover the map.
		 */
		public function get buffer():Number {
			return this._buffer; 
		}
		
		public function set buffer(value:Number):void {
			this._buffer = value; 
		}
		
		/**
		 * The tileOrigin to define the grid
		 * @default 0,0
		 */
		public function get tileOrigin():Location
		{
			return this._tileOrigin;
		}	
		
		/**
		 * @private
		 */
		public function set tileOrigin(value:Location):void
		{
			this._tileOrigin = value;
			this.redraw(true);
		}
		
		public function getMapPxRescalesFromLayerPx(layerPx:Pixel):Pixel
		{
			var resolution:Number = this.getSupportedResolution(this.map.resolution).value;
			var ratio:Number = resolution/this.map.resolution.value;
			return new Pixel(layerPx.x + this.x / ratio, layerPx.y + this.y / ratio);
		}
		
		public function set requestedResolution(value:Resolution):void
		{
			this._requestedResolution = value;
		}
		
		public function get requestedResolution():Resolution
		{
			return this._requestedResolution;
		}
		
		override public function set map(value:Map):void
		{
			
			super.map = value;
			if (this.map != null)
			{
				_previousCenter = this.map.center.clone();
				_previousResolution = this.map.resolution;
				if(this._timer) {
					this._timer.reset();
				} else {
					this._timer = new Timer(500,1);
					this._timer.addEventListener(TimerEvent.TIMER, this.onTimerEnd);
				}
				this._initialized = false;
			}
		}
		
		override protected function onMapResize(event:MapEvent):void
		{
			var deltaW:Number = event.newSize.w - event.oldSize.w;
			var deltaH:Number = event.newSize.h - event.oldSize.h;
			this.x += deltaW/2;
			this.y += deltaH/2;
			if (this._grid != null)
			{
				this.moveGriddedTiles(this.map.extent);
				this.actualizeGridSize(this.map.extent);
			}
		}
		
		/**
		 * Return if the layer is loading data
		 */
		/*public function get loading():Boolean
		{
			if (!this.grid)
				return false;
			
			var gridRowLength:int = this.grid.length;
			var gridColLength:int = this.grid[0].length;
			for (var i:int=0; i<gridRowLength; ++i)
			{
				for(var j:int=0; j<gridColLength; ++j)
				{
					if (this.grid[i][j].loadComplete)
							return true;
				}
			}
			return false;
		}*/
		/*override public function get minResolution():Resolution {
			var minRes:Resolution = super.minResolution;
			
			if(!minRes || isNaN(minRes.value) || isFinite(minRes.value))
			{
				if (this.resolutions && (this.resolutions.length > 0)) {
					minRes = new Resolution(this.resolutions[this.resolutions.length - 1], this.projection);
				}
			}
			else
			{
				// if is valide
				for(var i:int=this.resolutions.length; i>-1; --i)
				{
					if( this.resolutions[i] >= minRes.value)
						return new Resolution(this.resolutions[i],this.projection);
				}
				
				if (this.resolutions && (this.resolutions.length > 0)) {
					minRes = new Resolution(this.resolutions[this.resolutions.length - 1],this.projection);
				}
			}
			
			return minRes;
		}*/
	}
}

