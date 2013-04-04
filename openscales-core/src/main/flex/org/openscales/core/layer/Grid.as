package org.openscales.core.layer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.events.TileEvent;
	import org.openscales.core.layer.params.IHttpParams;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Base class for layers that use a lattice of tiles.
	 *
	 * @author Bouiaw
	 * @author mviry
	 */
	public class Grid extends HTTPRequest
	{
		
		private const DEFAULT_TILE_WIDTH:Number = 256;
		private const DEFAULT_TILE_HEIGHT:Number = 256;		
		private var _grid:Vector.<Vector.<ImageTile>> = null;
		private var _backGrid:Vector.<Vector.<Bitmap>> = null;
		protected var _tiled:Boolean = true;
		private var _origin:Pixel = null;
		private var _buffer:Number;
		protected var _tileWidth:Number = DEFAULT_TILE_WIDTH;
		protected var _tileHeight:Number = DEFAULT_TILE_HEIGHT;
		protected var _tileOrigin:Location = new Location(0,0,Geometry.DEFAULT_SRS_CODE);
		private var _defaultMatrixTranform:Matrix;
		private var _resquestResolution:Number = 0;
		private var _requestedResolution:Resolution;
		private var _previousCenter:Location = null;
		private var _cumulatedRoundedValueX:Number = 0;
		private var _cumulatedRoundedValueY:Number = 0;
		private var _tileWidthErrorPerPixel:Number = 0;
		private var _tileHeightErrorPerPixel:Number = 0;
		private var _isStretched:Boolean = false;
		
		private var _finest:Boolean = true;

		
		private var _realMatrixTranform:Matrix;
		private var _initialRoundedMatrixTransform:Matrix;
		
		
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
		public function Grid(identifier:String,
							 url:String,
							 params:IHttpParams = null
							 ) {
			
			//TODO delete url and params after osmparams work
			super(identifier, url, params);
			
			this.blendMode = BlendMode.LAYER;
			this.buffer = 0;
			this._defaultMatrixTranform = this.transform.matrix;
			this.addEventListener(TileEvent.TILE_LOAD_END,tileLoadHandler);
			this.addEventListener(TileEvent.TILE_LOAD_START,tileLoadHandler);
		}
		
		/**
		 * @inherited
		 */
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
			this._centerChanged = false;
			this._resolutionChanged = false;
			this._projectionChanged = false;
			if (this._grid && this._grid.length>0) {
				var i:uint = this._grid.length;
				var j:uint = this._grid[0].length;
				var iRow:uint;
				var iCol:uint;
				for(iRow=0; iRow < i; ++iRow) {
					var row:Vector.<ImageTile> = this._grid.pop();
					for(iCol=0; iCol < j; ++iCol) {
						var tile:ImageTile = row.pop();
						tile.destroy();						
					}
				}
				while (this.numChildren > 0)
					this.removeChildAt(0);
				this.grid = null;
			}
		}
		

		
		/**
		 * Override the redraw method for raster data. Check the informations of the map
		 * to define the available parameter for raster data.
		 */
		override public function redraw(fullRedraw:Boolean = false):void 
		{
			super.redraw(fullRedraw);
			
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
			var mapReloadCache:Boolean = this._mapReload;
			this._centerChanged = false;
			this._projectionChanged = false;
			this._resolutionChanged = false;
			this._mapReload = false;
			
			if (projectionChangedCache)
			{
				this.clear();
				_initialized = false;
				fullRedraw = true;
			}
			var ratio:Number;
			
			
			//var tilesBounds:Bounds = this.getTilesBounds();  
			var forceReTile:Boolean = this._grid==null || !this._grid.length || fullRedraw// || !tilesBounds;
			
			if (this.loadComplete)
			{
				this._backGrid = null;
			}
			
			if (resolutionChangedCache && _initialized)
			{
				ratio = this.requestedResolution.value / this.map.resolution.reprojectTo(this.projection).value;
				this.scaleLayer(ratio, new Pixel(this.map.size.w/2, this.map.size.h/2));
				resolutionChangedCache = false;
			}
			if (centerChangedCache && _initialized)
			{
				var deltaLon:Number = this.map.center.lon - this._previousCenter.lon;
				var deltaLat:Number = this.map.center.lat - this._previousCenter.lat;
				var deltaXCenter:Number = deltaLon/this.map.resolution.value;
				var deltaYCenter:Number = deltaLat/this.map.resolution.value;
				
				//this._realMatrixTranform.tx -= deltaXCenter;
				//this._realMatrixTranform.ty += deltaYCenter;
				this.x = this.transform.matrix.tx - deltaXCenter
				this.y = this.transform.matrix.ty + deltaYCenter
				this._previousCenter = this.map.center;
				centerChangedCache = false;
			}
			if (mapReloadCache || forceReTile || !_initialized)
			{
				var bounds:Bounds = this.map.extent.clone();
				var tilesBounds:Bounds = this.getTilesBounds();  
				actualizeGrid(bounds, (forceReTile || !tilesBounds.intersectsBounds(bounds)));
				resolutionChangedCache = false;
				centerChangedCache = false;
			}
		}
		
		
		/**
		 * Actualize the grid, 
		 * If we do not need to request another resolution, if needed, we only move rows and columns or
		 * add rows and column to fill the given bounds.
		 * 
		 * If another resolution is requested or the foreReTile flag is setted to true, the grid will be
		 * completly recomputed with transition tiles toa void white flash wile reloading
		 */
		protected function actualizeGrid(bounds:Bounds, forceReTile:Boolean):void
		{
			var bmpBounds:Bounds;
			var scale:Number;
			var BMD:BitmapData;
			var ratio:Number;
			var resolution:Resolution = this.getSupportedResolution(this.map.resolution.reprojectTo(this.projection));
			
			// for tile Stretching we need to reproject the resolution tu be sure that the native grid is correctly initilized
			if (!ProjProjection.isEquivalentProjection(this.projection, this.map.projection) && ProjProjection.isStretchable(this.projection, this.map.projection))
			{
				bounds = bounds.reprojectTo(this.projection);
				this._isStretched = true;
			}
			if (!this.tiled) 
			{
				// Initialize the backGrid
				if(this._backGrid == null)
				{
					this._backGrid = new Vector.<Vector.<Bitmap>>(1);
					this._backGrid[0] = new Vector.<Bitmap>(1);
					this._backGrid[0][0] = null;
				}
				if(this._initialized)
				{
					// Save the bitmap before zoom
					var NewLayerBounds:Bounds = this.maxExtent.getIntersection(bounds);
					NewLayerBounds = this.map.maxExtent.getIntersection(NewLayerBounds);
					bmpBounds = this.grid[0][0].bounds;
					scale = this.scaleX;
					if (NewLayerBounds == null)
						return;
					var intersectBounds:Bounds = NewLayerBounds.getIntersection(bmpBounds);
					if (intersectBounds != null)
					{
						intersectBounds.reprojectTo(this.projection);
						var mapWidth:Number = this.map.width;
						var mapHeight:Number = this.map.height;
						
						if (mapWidth * mapHeight >= 16777216)
						{
							mapWidth = mapHeight = 4095;
						}
						if(mapWidth == 0)
						{
							mapWidth = 1;
						}
						if (mapHeight == 0)
						{
							mapHeight = 1;
						}
						if (intersectBounds != null)
						{
							BMD = new BitmapData(mapWidth , mapHeight , true, this.map.backTileColor);
							BMD.draw(this, null, null, null, null, true);
							_backGrid[0][0] = new Bitmap(BMD, PixelSnapping.NEVER, true);
							_backGrid[0][0].scaleX = _backGrid[0][0].scaleY = scale;
							_backGrid[0][0].x = this.x;
							_backGrid[0][0].y = this.y;
						}else
						{
							_backGrid[0][0] = null;
						}
					}
				}
				this.clear();
				this.initSingleTile(bounds, resolution);
				this.requestedResolution = this.map.resolution.reprojectTo(this.projection);
				this.transform.matrix = this._defaultMatrixTranform.clone();
				
				// Apply the savec bitmap as preloaded data in the grid
				if(_backGrid[0][0] && !this.grid[0][0].loadComplete)
				{
					_backGrid[0][0].x -= this.grid[0][0].x;
					_backGrid[0][0].y -= this.grid[0][0].y;
					this.grid[0][0].addChildAt(_backGrid[0][0], 0);
					this.addChild(this.grid[0][0]);
				}
			} else {
				if ((resolution.value != this._resquestResolution) || forceReTile)
				{
					var i:int;
					var j:int;
					var gridColLength:int;
					var gridRowLength:int;
					var TopLeftCorner:Location;
					
					// Store the bitmap of the loaded scene before the grid modification
					if(this._initialized)
					{
						gridRowLength = this.grid.length;
						gridColLength = this.grid[0].length;
						
						// Compute the bitmapBounds
						TopLeftCorner = new Location(this.grid[0][0].bounds.left, this.grid[0][0].bounds.top, this.projection);
						var BottomRightCorner:Location = new Location(this.grid[gridRowLength - 1][gridColLength - 1].bounds.right, this.grid[gridRowLength - 1][gridColLength - 1].bounds.bottom);
						var firstDrawnTileIndex:Point;
						var lastDrawnTileIndex:Point;
						
						bmpBounds = this.grid[0][0].bounds;
						scale = this._realMatrixTranform.a/this.scaleX;
						var drawnWidth:Number = (BottomRightCorner.x - TopLeftCorner.x) / this.requestedResolution.value;
						var drawnHeight:Number = -(BottomRightCorner.y - TopLeftCorner.y) / this.requestedResolution.value;
						var fullBmpBounds:Bounds = null;
						
						// Avoid to reach bitmap size limits
						if (drawnWidth == 0 || drawnHeight == 0)
						{
							drawnWidth = 1;
							drawnHeight = 1;
						}
						if (drawnHeight > 8191)
						{
							drawnHeight = 8191;
						}
						if (drawnWidth > 8191)
						{
							drawnWidth = 8191;
						}
						if (drawnWidth * drawnHeight < 16777215)
						{
							// Draw the current scene into a Bitmap
							BMD = new BitmapData(drawnWidth, drawnHeight, true, this.map.backTileColor);
							BMD.draw(this, this.transform.matrix, null, null, null, true);
							var fullBitmap:Bitmap = new Bitmap(BMD, PixelSnapping.NEVER, true);
							var deltaMatrix:Matrix = this._defaultMatrixTranform.clone();
							var bmpRequestedResolution:Number = this.requestedResolution.value;
							fullBmpBounds = this.map.extent.clone().reprojectTo(this.projection);
							TopLeftCorner = new Location(fullBmpBounds.left, fullBmpBounds.top, this.projection);
						}
					}
					// Actualize the grid
					this._cumulatedRoundedValueX = 0;
					this._cumulatedRoundedValueY = 0;
					this._tileWidthErrorPerPixel = 0;
					this._tileHeightErrorPerPixel = 0;
					this.transform.matrix = this._defaultMatrixTranform.clone();
					this._realMatrixTranform = this.transform.matrix.clone();
					this._initialRoundedMatrixTransform = this.transform.matrix.clone();
					this.initGriddedTiles(bounds, true);
					
					// Cut the backgrid to preload the grid with the previously loaded tile level
					if (fullBmpBounds != null)
					{
						gridRowLength = this.grid.length;
						gridColLength = this.grid[0].length;
						
						this._backGrid = new Vector.<Vector.<Bitmap>>(1);
						this._backGrid[0] = new Vector.<Bitmap>(1);
						for (i = 0; i< gridRowLength; ++i)
						{
							this._backGrid[i] = new Vector.<Bitmap>(1);
							for (j = 0; j< gridColLength; ++j)
							{
								this._backGrid[i][j] = new Bitmap();
							}
						}
						for (i = 0; i< gridRowLength; ++i)
						{
							for (j = 0; j < gridColLength; ++j)
							{
								if (this.grid[i][j].bounds.intersectsBounds(fullBmpBounds, false))
								{
									var bufferTileBound:Bounds;
									var tiletopLeftcorner:Location;
									var deltaX:Number;
									var deltaY:Number;
									var recWidth:Number;
									var recHeight:Number;
									var region:Rectangle;
									var tile:BitmapData;
									
									// If : the gridBound is fullcontained in the bitmap
									// else : the gridBound is partially contained in the bitmap
									if (fullBmpBounds.containsBounds(this.grid[i][j].bounds))
									{
										bufferTileBound = this.grid[i][j].bounds.getIntersection(fullBmpBounds);
										tiletopLeftcorner = new Location(bufferTileBound.left, bufferTileBound.top, this.projection);
										
										// Reproject everything into the map projection for tileStretching
										tiletopLeftcorner = tiletopLeftcorner.reprojectTo(this.map.projection);
										TopLeftCorner = TopLeftCorner.reprojectTo(this.map.projection);
										
										deltaX = (tiletopLeftcorner.x - TopLeftCorner.x)/this.map.resolution.value ;
										deltaY = -(tiletopLeftcorner.y - TopLeftCorner.y)/this.map.resolution.value;
										recWidth = (this.grid[i][j].bounds.reprojectTo(this.map.projection).width / this.map.resolution.value) + 1;
										recHeight = (this.grid[i][j].bounds.reprojectTo(this.map.projection).height / this.map.resolution.value) + 1;
										if (recWidth == 0 || recHeight == 0)
										{
											recWidth = 1;
											recHeight = 1;
										}
										region = new Rectangle(deltaX, deltaY, recWidth, recHeight);
										tile = new BitmapData(recWidth, recHeight, true, this.map.backTileColor);
										tile.copyPixels(BMD, region, new Point(0,0));
										_backGrid[i][j] = new Bitmap(tile, PixelSnapping.NEVER, true);
										//_backGrid[i][j] -=
									}else
									{
										var tilePartBounds:Bounds = fullBmpBounds.getIntersection(this.grid[i][j].bounds);
										tiletopLeftcorner = new Location(tilePartBounds.left, tilePartBounds.top, this.projection);
										
										// Reproject everything into the map projection for tileStretching
										tiletopLeftcorner = tiletopLeftcorner.reprojectTo(this.map.projection);
										TopLeftCorner = TopLeftCorner.reprojectTo(this.map.projection);
										tilePartBounds = tilePartBounds.reprojectTo(this.map.projection);
										
										deltaX = (tiletopLeftcorner.x - TopLeftCorner.x)/this.map.resolution.value;
										deltaY = -(tiletopLeftcorner.y - TopLeftCorner.y)/this.map.resolution.value;
										var finalDeltaX:Number = (tilePartBounds.left - this.grid[i][j].bounds.reprojectTo(this.map.projection).left)/this.map.resolution.value;
										var finalDeltaY:Number = -(tilePartBounds.top - this.grid[i][j].bounds.reprojectTo(this.map.projection).top)/this.map.resolution.value ;
										var recCutWidth:Number = (tilePartBounds.width / this.map.resolution.value ) +1;
										var recCutHeight:Number  = (tilePartBounds.height / this.map.resolution.value ) +1;
										recWidth = (this.grid[i][j].bounds.reprojectTo(this.map.projection).width / this.map.resolution.value) +1;
										recHeight = (this.grid[i][j].bounds.reprojectTo(this.map.projection).height / this.map.resolution.value) +1;
										if (recHeight == 0 || recWidth == 0)
										{
											recHeight = 1;
											recWidth = 1;
										}
										if (recWidth > 8191)
										{
											recWidth = 8191;
										}
										if (recHeight > 8191)
										{
											recHeight = 8191;
										}
										if (recHeight * recWidth > 16777216)
										{
											recHeight = recWidth = 4095;
										}
										region = new Rectangle(deltaX, deltaY, recCutWidth, recCutHeight);
										tile = new BitmapData(recWidth, recHeight, true, this.map.backTileColor);
										tile.copyPixels(BMD, region, new Point(finalDeltaX, finalDeltaY));
										var transitiontile:Bitmap = new Bitmap(tile, PixelSnapping.NEVER, true);
										_backGrid[i][j] = transitiontile;
										
									}
								}
							}
						}
					}
					
					// Scale the grid for the new resolution
					ratio = this._requestedResolution.value/this.map.resolution.reprojectTo(this.projection).value;
					this.scaleLayer(ratio, new Pixel(0, 0));
					this._previousCenter = this.map.center.clone();

					if (fullBmpBounds)
					{
						// Preload bitmap in the new grid
						for (i = 0; i< gridRowLength; ++i)
						{
							for (j = 0; j < gridColLength; ++j)
							{
								if (_backGrid[i][j] && this.grid[i][j])
								{
									if (!this.grid[i][j].loadComplete)
									{
									_backGrid[i][j].scaleY *= 1/(this.scaleY * this.grid[i][j].scaleY);
									_backGrid[i][j].scaleX *= 1/(this.scaleX * this.grid[i][j].scaleX);
									this.grid[i][j].addChildAt(_backGrid[i][j], 0);
									this.grid[i][j].drawn = true;
									this.addChild(grid[i][j]);
									}
								}
							}
						}
					}
				}
				this.moveGriddedTiles(bounds);
				this.actualizeGridSize(bounds);
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
			
			var newTransMatrix:Matrix;
			if (this.tiled)
			{
				// Compute the Cumulated Scale error due to panning width a rounded scale.
				var deltaX:Number = this.transform.matrix.tx -  this._initialRoundedMatrixTransform.tx;
				var deltaY:Number = this.transform.matrix.ty -  this._initialRoundedMatrixTransform.ty;
				_realMatrixTranform.tx += deltaX + (_tileWidthErrorPerPixel*deltaX);
				_realMatrixTranform.ty += deltaY + (_tileHeightErrorPerPixel*deltaY);
				
				// Round the scale value to avoid white seams between tiles
				var temporaryScaleX:Number = scale;
				var temporaryScaleY:Number = scale;
				var temporaryWidth:Number = this.tileWidth * temporaryScaleX * this.grid[0][0].scaleX;
				var temporaryHeigth:Number = this.tileHeight * temporaryScaleY * this.grid[0][0].scaleY;
				var roundedWidth:Number = Math.round(temporaryWidth);
				var roundedHeigth:Number = Math.round(temporaryHeigth);
				temporaryScaleX = roundedWidth / this.tileWidth / this.grid[0][0].scaleX ;
				temporaryScaleY = roundedHeigth / this.tileHeight / this.grid[0][0].scaleY ;
				this._tileWidthErrorPerPixel = ((temporaryWidth - roundedWidth)/this.tileWidth)/scale;
				this._tileHeightErrorPerPixel = ((temporaryHeigth - roundedHeigth)/this.tileHeight)/scale;
			
				// Apply the accurate transform matrix to avoid error accumulation due to scale rounding 
				this.transform.matrix = this._realMatrixTranform.clone();
				
				// Compute the rounded Matrix Transform
				newTransMatrix = this.transform.matrix.clone();
				newTransMatrix.tx -= (offSet.x);
				newTransMatrix.ty -= (offSet.y);
				newTransMatrix.scale(temporaryScaleX/this.scaleX, temporaryScaleY/this.scaleY);
				newTransMatrix.tx += (offSet.x );
				newTransMatrix.ty += (offSet.y );
				
				// Compute the accurate transform matrix
				var unroundedTransMatrix:Matrix = this.transform.matrix.clone();
				unroundedTransMatrix.tx -= (offSet.x);
				unroundedTransMatrix.ty -= (offSet.y);
				unroundedTransMatrix.scale(scale/this.scaleY, scale/this.scaleY);
				unroundedTransMatrix.tx += (offSet.x );
				unroundedTransMatrix.ty += (offSet.y );
				
				// Apply the rounded transform matrix and store the accurate transform matrix
				_realMatrixTranform = unroundedTransMatrix.clone();
				this.transform.matrix = newTransMatrix.clone();
				this._initialRoundedMatrixTransform = newTransMatrix.clone();
			}else
			{
				newTransMatrix = this.transform.matrix.clone();
				newTransMatrix.tx -= (offSet.x);
				newTransMatrix.ty -= (offSet.y);
				newTransMatrix.scale(scale/this.scaleX, scale/this.scaleY);
				newTransMatrix.tx += (offSet.x );
				newTransMatrix.ty += (offSet.y );
				this.transform.matrix = newTransMatrix.clone();
			}
			this.x = this.x;
			this.y = this.y;
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
			var ratio:Number = this.getSupportedResolution(this.map.resolution).reprojectTo(this.projection).value / this.map.resolution.reprojectTo(this.projection).value; 
			var tlViewPort:Pixel =  new Pixel(tlLayer.x + this.x/ratio, tlLayer.y + this.y/ratio); 
			if (this.projection != bounds.projection)
			{
				bounds = bounds.reprojectTo(this.projection);
			}
			
			var stretchedWidth:Number;
			var stretchedHeight:Number;
			var upRigth:Location;
			var bottomLeft:Location;
			
			// Add Columns
			if(bounds.width / this.map.resolution.reprojectTo(this.projection).value > (this._grid[0].length - buffer) * this.tileWidth * ratio + tlViewPort.x * ratio)
			{	
				var gridRowLength:Number = this._grid[0].length;
				//var gridRightBound:Number = this.grid[0][gridRowLength-1].bounds.right;
				var deltaWidth:Number = (bounds.width / this.map.resolution.reprojectTo(this.projection).value) - ((this._grid[0].length - buffer) * this.tileWidth * ratio + tlViewPort.x * ratio);
					
				var deltaLon:Number = deltaWidth * this.requestedResolution.value; // bounds.right - gridRightBound;
				tileLon = this.tileWidth * this.requestedResolution.value;
				tileLat = this.tileHeight * this.requestedResolution.value;
				nbTileToAdd = deltaLon / tileLon;
				nbTileToAdd = Math.abs(nbTileToAdd);
				if (nbTileToAdd > 0)
				{
					var rowLength:Number = this._grid.length;
					for(var _r:int = 0; _r < rowLength; ++_r)
					{
						var tileScaleY:Number = this.grid[r][gridRowLength-1].scaleY;
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
							tile.scaleY = tileScaleY;
							this._grid[_r].push(tile);
						}
					}
				}
			}
			// Add rows
			if(bounds.height / this.map.resolution.reprojectTo(this.projection).value > (this._grid.length - buffer) * this.tileHeight * ratio + tlViewPort.y * ratio)
			{
				var gridColLength:Number = this._grid.length;
				//var gridBottomBound:Number = this.grid[gridColLength-1][0].bounds.bottom;
				
				var deltaHeight:Number = (bounds.height / this.map.resolution.reprojectTo(this.projection).value) - ((this._grid.length - buffer) * this.tileHeight * ratio + tlViewPort.y * ratio);
				var deltaLat:Number =deltaHeight* this.requestedResolution.value;//bounds.bottom - gridBottomBound;
				var stretchingScaleY:Number = 1;
				
				
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
							
							if (this._isStretched)
							{
								upRigth = new Location(tileBounds.right, tileBounds.top, tileBounds.projection);
								upRigth = upRigth.reprojectTo(this.map.projection);
								bottomLeft = new Location(tileBounds.left, tileBounds.bottom, tileBounds.projection);
								bottomLeft = bottomLeft.reprojectTo(this.map.projection);
								stretchedWidth = (upRigth.lon-bottomLeft.lon)/this.requestedResolution.reprojectTo(this.map.projection).value;
								stretchedHeight = (upRigth.lat-bottomLeft.lat)/this.requestedResolution.reprojectTo(this.map.projection).value;
								stretchingScaleY = stretchedHeight/this.tileHeight;
							}
							x = this._grid[gridColLength - 1 + j][c].x;
							
							if (gridColLength > 1)
								y = this._grid[gridColLength - 1 + j][c].y + this.tileHeight * this._grid[gridColLength - 2 + j][c].scaleY;
							else
								y = this._grid[gridColLength - 1 + j][c].y + this.tileHeight * this._grid[gridColLength - 1 + j][c].scaleY;
							
							px = new Pixel(x, y);
							tile = this.addTile(tileBounds, px);
							tile.scaleY = stretchingScaleY;
							row.push(tile);
						}
						this._grid.push(row);
					}
				}
			}
			var rl:int = this._grid.length;
			var cl:int;
			for (var r:int=0; r<rl; ++r) {
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
				if (bottomLeftTile.bounds)
				{
					return new Bounds(bottomLeftTile.bounds.left, 
						bottomLeftTile.bounds.bottom,
						topRightTile.bounds.right, 
						topRightTile.bounds.top,
						this.projection);
				}
			}
			return null;
		}
		
		/**
		 * Initialization singleTile
		 * This Method compute the intersection between the map extent, the layer maxExtent and the map maxExtent
		 * to resquest the correct extent and build the grid to set up a single tile layer.
		 * @param bounds
		 * @param resolution to request
		 */
		public function initSingleTile(bounds:Bounds, resolution:Resolution):void {
			this._requestedResolution = resolution;
			var center:Location;
			var geoTileWidth:Number;
			var geoTileHeight:Number;
			
			bounds = this.maxExtent.getIntersection(bounds);
			bounds = this.map.maxExtent.getIntersection(bounds);
			
			if (bounds == null)
			{
				return;
			}
			if(bounds.projection!=this.projection)
				bounds = bounds.reprojectTo(this.projection);
			
			center= bounds.center;
			geoTileWidth = bounds.width;
			geoTileHeight = bounds.height;
			var topLeftCorner:Location = new Location(bounds.left, bounds.top);
			var bottomRightCorner:Location = new Location(bounds.right, bounds.bottom);
			var finalResolution:Resolution = this.map.resolution;
			if (this.projection != this.map.projection)
			{
				finalResolution = this.map.resolution.reprojectTo(this.projection);
			}
			var unityLocReproj:Location = new Location(1,1,this.projection).reprojectTo(this.map.projection);
			this.tileWidth = Math.round(bounds.reprojectTo(this.map.projection).width/this.map.resolution.value);
			this.tileHeight = Math.round(bounds.reprojectTo(this.map.projection).height/this.map.resolution.value);
			var ul:Location = new Location(bounds.left, bounds.top, bounds.projection);
			var px:Pixel = this.map.getMapPxFromLocation(ul.reprojectTo(this.map.projection));
			
			var yStretching:Number = finalResolution.value / this.map.resolution.value * unityLocReproj.y;
			//bounds.top = bounds.top*(yStretching);
			//bounds.bottom = bounds.bottom*(yStretching);
			if(this._grid==null) {
				this._grid = new Vector.<Vector.<ImageTile>>(1);
				this._grid[0] = new Vector.<ImageTile>(1);
				this._grid[0][0] = null;
			}
			
			var tile:ImageTile = this.addTile(bounds, px);
			tile.draw();
			this._grid[0][0] = tile;         
			this.removeExcessTiles(1,1);
			_initialized = true;
		}
		
		/**
		 * Return the closest requestable resolution to the targetResolution given as parameter.
		 */
		public function getSupportedResolution(targetResolution:Resolution):Resolution
		{
			var bestResolution:Number;
			var bestRatio:Number;
			var i:int;
			var len:int;
			var ratioSeeker:Number;
			if (_finest)
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
					if (this.resolutions[i] < targetResolution.value)
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
			
			var projectedTileOrigin:Location = this._tileOrigin.reprojectTo(bounds.projection);
			this.requestedResolution = this.getSupportedResolution(this.map.resolution.reprojectTo(this.projection));
			var reprojectedBoundWidth:Number = (bounds.reprojectTo(this.map.projection).width/requestedResolution.reprojectTo(this.map.projection).value);
			var reprojectedBoundHeight:Number = (bounds.reprojectTo(this.map.projection).height/requestedResolution.reprojectTo(this.map.projection).value);
			var nativeBoundWidth:Number = (bounds.width/requestedResolution.value);
			var nativeBoundHeight:Number = (bounds.height/requestedResolution.value);
			
			
			_resquestResolution = this.requestedResolution.value;
			var viewSize:Size = new Size(nativeBoundWidth, nativeBoundHeight);
			var minRows:Number = Math.ceil(viewSize.h/this.tileHeight) + Math.max(1, 2 * this.buffer);
			var minCols:Number = Math.ceil(viewSize.w/this.tileWidth) + Math.max(1, 2 * this.buffer);
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
			
			// Offset stretching 
			var upRigth:Location = new Location(tileoffsetlon + tilelon, tileoffsetlat + tilelat, this.projection);
			upRigth = upRigth.reprojectTo(this.map.projection);
			
			var bottomLeft:Location = new Location(tileoffsetlon, tileoffsetlat, this.projection);
			bottomLeft = bottomLeft.reprojectTo(this.map.projection);
			
			var stretchedHeight:Number = (upRigth.lat - bottomLeft.lat) / this.requestedResolution.reprojectTo(this.map.projection).value;
			var stretchedWidth:Number = (upRigth.lon-bottomLeft.lon) / this.requestedResolution.reprojectTo(this.map.projection).value;
			
			tileoffsetx *= stretchedWidth/this.tileWidth;
			tileoffsety *= stretchedHeight/this.tileHeight;
			
			this._origin = new Pixel(tileoffsetx, tileoffsety);
			this.x += Math.round(tileoffsetx);
			this.y += Math.round(tileoffsety);
			tileoffsetx = 0;
			tileoffsety = 0;
			var startX:Number = tileoffsetx; 
			var startLon:Number = tileoffsetlon;
			var rowidx:int = 0;
			
			if(this._grid == null) {
				this._grid = new Vector.<Vector.<ImageTile>>();
			}
			
			// Build the tiles
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
					
					
					// Stretch the tile
					upRigth = new Location(tileBounds.right, tileBounds.top, tileBounds.projection);
					upRigth = upRigth.reprojectTo(this.map.projection);
					bottomLeft = new Location(tileBounds.left, tileBounds.bottom, tileBounds.projection);
					bottomLeft = bottomLeft.reprojectTo(this.map.projection);
					stretchedWidth = (upRigth.lon-bottomLeft.lon)/this.requestedResolution.reprojectTo(this.map.projection).value;
					stretchedHeight = (upRigth.lat-bottomLeft.lat)/this.requestedResolution.reprojectTo(this.map.projection).value;
					
					var stretchingScaleX:Number = stretchedWidth/this.tileWidth;
					var stretchingScaleY:Number = stretchedHeight/this.tileHeight;
					var roundedWidth:Number = Math.round(stretchedWidth);
					var roundedHeight:Number = Math.round(stretchedHeight);
					
					stretchingScaleX = roundedWidth / this.tileWidth;
					stretchingScaleY = roundedHeight / this.tileHeight;
					stretchedWidth = roundedWidth;
					stretchedHeight = roundedHeight;
					
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
					tile.scaleX = stretchingScaleX;
					tile.scaleY = stretchingScaleY;
					colidx=++colidx;
					
					tileoffsetlon += tilelon;       
					tileoffsetx += stretchedWidth;
				} while ((tileoffsetlon <= bounds.right + tilelon * this.buffer) || colidx < minCols)  
				
				tileoffsetlat -= tilelat;
				tileoffsety += stretchedHeight;
			} while((tileoffsetlat >= bounds.bottom - tilelat * this.buffer) || rowidx < minRows)
			
			//shave off exceess rows and colums
			this.removeExcessTiles(rowidx, colidx);
			
			//now actually draw the tiles
			this.spiralTileLoad();
			_initialized = true;
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
		
		/**
		 * Method to add a tile.
		 * Each layer format need to override this method and return the imageTile associated to the 
		 * bounds and place it at the given position
		 */
		public function addTile(bounds:Bounds, position:Pixel):ImageTile {
			return null;
		}
		
		/**
		 * While panning the map, the layer will move as well. The rows and the columns of the grid
		 * may need to be shifted.
		 * this method takes a bounds as parameter and check if the gridd need to add/remove rows or
		 * columns to fill the bounds
		 */
		public function moveGriddedTiles(bounds:Bounds):void {
			if (bounds.projection != this.projection)
			{
				bounds = bounds.reprojectTo(this.projection);
			}
			var buffer:Number = this.buffer || 1;
			var counter:Number = 0;
			while (true) {
				counter++;
				if (counter > 500)
				{
					this._initialized = false;
					break;
				}
				var tlLayer:Pixel = this.grid[0][0].position;
				var tileScaleY:Number = this.grid[0][0].scaleY;
				var tileScaleX:Number = this.grid[0][0].scaleX;
				var tlViewPort:Pixel =  new Pixel(tlLayer.x + this.transform.matrix.tx/this.transform.matrix.a, tlLayer.y + this.transform.matrix.ty/this.transform.matrix.d); 
				if (tlViewPort.x > -this.tileWidth* tileScaleX * (buffer - 1)) {
					this.shiftColumn(true);
				} else if (tlViewPort.x < -this.tileWidth * tileScaleX * buffer) {
					this.shiftColumn(false);
				} else if (tlViewPort.y > -this.tileHeight * tileScaleY * (buffer - 1)) {
					this.shiftRow(true);
				} else if (tlViewPort.y < -this.tileHeight * tileScaleY * buffer) {
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
			var resolution:Number = this.getSupportedResolution(this.map.resolution.reprojectTo(this.projection)).value;
			var deltaY:Number = (prepend) ? -this.tileHeight : this.tileHeight;
			var deltaLat:Number = resolution * -deltaY;
			var row:Vector.<ImageTile> = (prepend) ? this._grid.pop() : this._grid.shift();
			var positionMultiplicator:Number = 1;
			var heightMultiplicator:Number = 1;
			var j:uint = modelRow.length;
			var upRigth:Location;
			var bottomLeft:Location;
			var stretchedHeight:Number;
			for (var i:uint=0; i < j; ++i) {
				var modelTile:ImageTile = modelRow[i];
				var bounds:Bounds = modelTile.bounds.clone();
				bounds.bottom = bounds.bottom + deltaLat;
				bounds.top = bounds.top + deltaLat;
				
				if (this._isStretched)
				{
					upRigth = new Location(bounds.right, bounds.top, bounds.projection);
					upRigth = upRigth.reprojectTo(this.map.projection);
					bottomLeft = new Location(bounds.left, bounds.bottom, bounds.projection);
					bottomLeft = bottomLeft.reprojectTo(this.map.projection);
					stretchedHeight = (upRigth.lat-bottomLeft.lat)/this.requestedResolution.reprojectTo(this.map.projection).value;;
					stretchedHeight = Math.ceil(stretchedHeight);
					heightMultiplicator = stretchedHeight/this.tileHeight;
					if (prepend)
					{
						positionMultiplicator = heightMultiplicator;
						
					}else{
						positionMultiplicator = modelTile.scaleY;
					}
				}
				
				var position:Pixel = modelTile.position.clone();

				position.y = position.y + deltaY * positionMultiplicator;
				row[i].clearAndMoveTo(bounds, position);
				row[i].scaleY = heightMultiplicator;
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
			var upRigth:Location;
			var bottomLeft:Location;
			var stretchedHeight:Number;
			for (var i:uint=0; i<j; ++i) {
				var row:Vector.<ImageTile> = this._grid[i];
				var modelTileIndex:int = (prepend) ? 0 : (row.length - 1);
				var modelTile:ImageTile = row[modelTileIndex];
				var bounds:Bounds = modelTile.bounds.clone();
				var position:Pixel = modelTile.position.clone();
				bounds.left = bounds.left + deltaLon;
				bounds.right = bounds.right + deltaLon;
				position.x = position.x + deltaX;
				var tile:ImageTile = prepend ? this._grid[i].pop() : this._grid[i].shift();
				tile.scaleY = modelTile.scaleY;
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
					tile.destroy();
				}
			}
			
			for (i=0, l=this._grid.length; i<l; i++) {
				row = this._grid[i];
				while (row.length > columns) {
					tile = row.pop();
					tile.destroy();
				}
			}
		}
		
		
		
		//Getters and Setters
		/**
		 * Set the x coordinate of the layer. this method is overided to have only
		 * rounded value of the coordinate, But the différence is stored and will be added
		 * when the cumulated value is more that 1 pixel. 
		 * 
		 * This allow us to keep integer values to avoid white seams between tiles and
		 * keep precision.
		 */
		override public function set x(value:Number):void
		{
			value -= (value - this.transform.matrix.tx)*this._tileWidthErrorPerPixel;
			var epsilon:Number = value - Math.round(value);
			this._cumulatedRoundedValueX += epsilon;
			super.x = Math.round(value);
			if (this._cumulatedRoundedValueX >= 1 || this._cumulatedRoundedValueX <= -1)
			{
				var roundedCumulatedValue:Number = Math.round(_cumulatedRoundedValueX);
				super.x = this.transform.matrix.tx + roundedCumulatedValue;
				this._cumulatedRoundedValueX -= roundedCumulatedValue;
			}
		}
		
		/**
		 * Set the y coordinate of the layer. this method is overided to have only
		 * rounded value of the coordinate, But the différence is stored and will be added
		 * when the cumulated value is more that 1 pixel. 
		 * 
		 * This allow us to keep integer values to avoid white seams between tiles and
		 * keep precision.
		 */
		override public function set y(value:Number):void
		{
			value -= (value - this.transform.matrix.ty)*this._tileHeightErrorPerPixel;
			var epsilon:Number = value - Math.round(value);
			this._cumulatedRoundedValueY += epsilon;
			super.y = Math.round(value);
			if (this._cumulatedRoundedValueY >= 1 || this._cumulatedRoundedValueY <= -1)
			{
				var roundedCumulatedValue:Number = Math.round(_cumulatedRoundedValueY);
				super.y = this.transform.matrix.ty + roundedCumulatedValue;
				this._cumulatedRoundedValueY -= roundedCumulatedValue;
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
			var resolution:Number = this.map.resolution.reprojectTo(this.projection).value;
			var tileMapWidth:Number = resolution * this.tileWidth;
			var tileMapHeight:Number = resolution * this.tileHeight;
			var mapPoint:Location = this.getLocationFromMapPx(viewPortPx);
			var tileLeft:Number = maxExtent.left + (tileMapWidth * (mapPoint.lon - maxExtent.left) / tileMapWidth);
			var tileBottom:Number = maxExtent.bottom + (tileMapHeight * (mapPoint.lat - maxExtent.bottom) / tileMapHeight);
			return new Bounds(tileLeft,
				tileBottom,
				tileLeft + tileMapWidth,
				tileBottom + tileMapHeight,
				this.projection);
		}
		
		/**
		 * The container of the image tiles of the Layer.
		 */
		public function get grid():Vector.<Vector.<ImageTile>> {
			return this._grid;
		}
		
		/**
		 * @private
		 */
		public function set grid(value:Vector.<Vector.<ImageTile>>):void {
			this._grid = value;
		}
		
		/**
		 * Boolean that define if the layer will be tiled or not.
		 * If it's tiled the requested tiles size will be this.tileWidth*this.tileHeight.
		 * Else it will be a single tile of the same size as the map size 
		 */
		public function get tiled():Boolean {
			return this._tiled;
		}
		
		/**
		 * @private
		 */
		public function set tiled(value:Boolean):void {
			this._tiled = value;
		}
		
		/**
		 * Used only when in gridded mode, this specifies the number of
		 * extra rows and colums of tiles on each side which will
		 * surround the minimum grid tiles to cover the map.
		 */
		public function get buffer():Number {
			return this._buffer; 
		}
		
		/**
		 * @private
		 */
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
		
		/**
		 * Get the mapPx corresponding to the given layer pixel while in freeZoom
		 */
		public function getMapPxRescalesFromLayerPx(layerPx:Pixel):Pixel
		{
			var resolution:Number = this.getSupportedResolution(this.map.resolution.reprojectTo(this.projection)).value;
			var ratio:Number = resolution/this.map.resolution.reprojectTo(this.projection).value;
			return new Pixel(layerPx.x + this.x / ratio, layerPx.y + this.y / ratio);
		}
		
		
		/**
		 * The resolution in which the tile are requested to the server.
		 * This is the resolution of the tile without scaling due to freeZoom
		 */
		public function set requestedResolution(value:Resolution):void
		{
			this._requestedResolution = value;
		}
		
		/**
		 * @private
		 */
		public function get requestedResolution():Resolution
		{
			return this._requestedResolution;
		}
		
		
		/**
		 * @inherited
		 */
		override public function set map(value:Map):void
		{
			
			super.map = value;
			if (this.map != null)
			{
				_previousCenter = this.map.center.clone();
				this._initialized = false;
			}
		}
		
		/**
		 * The default tile width to use while requesting in tiled mode
		 */
		public function set tileWidth(value:Number):void {
			this._tileWidth = value;	
		}
		
		/**
		 * @private
		 */
		public function get tileWidth():Number {
			return this._tileWidth;
		}
		
		/**
		 * The default tile height to use while requesting in tiled mode
		 */
		public function set tileHeight(value:Number):void {
			this._tileHeight= value;	
		}
		
		/**
		 * @private
		 */
		public function get tileHeight():Number {
			return this._tileHeight;
		}	
		
		/**
		 * Return true if the layer is available with the map configuration. This mean that it can be drawn
		 * You need to check also the flash visible boolean to know if the layer will be drawn. 
		 */
		override protected function checkAvailability():Boolean
		{

			if(!super.checkAvailability()) {
				return false;
			}
			
			//Parsing available projections for the layer
			if(this.availableProjections) {
				
				var proj:ProjProjection;
				
				var stretchableProjection:ProjProjection = null;
				
				for each(var projCode:String in this.availableProjections) {
					
					proj = ProjProjection.getProjProjection(projCode);
					
					if(ProjProjection.isEquivalentProjection(proj,this.map.projection)) {
						if(!ProjProjection.isEquivalentProjection(this.projection, proj)) {
							//Changing layer projection
							this.projection = proj;
							return true;
						} else {
							//Layer projection is already Map projection
							return true;
						}
					}
					
					if (ProjProjection.isStretchable(proj, this.map.projection)) {
						
						stretchableProjection = proj;
					}
					
				}
				
				// If no compatible projection was found BUT a stretchable projection is available,
				// we return this one
				if (stretchableProjection != null && !ProjProjection.isEquivalentProjection(this.projection, stretchableProjection) ) {
					this.projection = stretchableProjection;
					return true;
				}
				
			}
			
			//Available projections is not set for this layer
			//try simple comparison
			if(ProjProjection.isEquivalentProjection(this.projection,this.map.projection)) {
				return true;
			}
			
			//Otherwise, try to stretch the layer
			if(ProjProjection.isStretchable(this.projection, this.map.projection)) {
				return true;
			}
			
			//Otherwise return false
			return false;
		}
		
		// Callbacks
		
		/**
		 * Actualize the grid size when the map size has changed.
		 * We focus on keeping the center of the grid at the center of the map
		 */
		override protected function onMapResize(event:MapEvent):void
		{
			var deltaW:Number = event.newSize.w - event.oldSize.w;
			var deltaH:Number = event.newSize.h - event.oldSize.h;
			this.x += deltaW/2;
			this.y += deltaH/2;
			/*if (this._grid != null)
			{
				this.moveGriddedTiles(this.map.extent);
				this.actualizeGridSize(this.map.extent);
			}*/
		}
		
		/**
		 * Calback to handle TILE_LOAD_START ans TILE_LOAD_END events and set the loading state of the layer
		 * according to tiles status.
		 */
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

		/**
		 * Used to decide which resolution to request among available resolutions array. If <code>true</code>, finest resolution will be requested. 
		 * 
		 * @default true
		 */ 
		public function get finest():Boolean
		{
			return _finest;
		}

		public function set finest(value:Boolean):void
		{
			_finest = value;
		}

	}
}

