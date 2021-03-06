package org.openscales.core.layer.ogc.provider
{
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.layer.ogc.wmts.TileMatrix;
	import org.openscales.core.layer.ogc.wmts.TileMatrixSet;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	
	use namespace os_internal;
	
	public class WMTSTileProvider extends OGCTileProvider
	{
		
		/**
		 * @protected 
		 * Requested layer
		 */ 
		protected var _layer:String = null;
		/**
		 * @protected 
		 * Style to apply on the requested layer
		 */ 
		protected var _style:String = null;
		
		/**
		 * @protected 
		 * Requested matrix set
		 */
		protected var _tileMatrixSet:String = null;
		
		/**
		 * @protected 
		 * MIME type for returned tiles
		 */ 
		protected var _format:String = null;
		
		private var _tileMatrixSets:HashMap = null;
		
		private var _tileMatrixSetsLimits:HashMap = null;
		
		
		private var _maxExtents:HashMap = null;
		
		/**
		 * @param url String The url where the WMTS service is located
		 * @param format String The MIME type for returned tiles
		 * @param tileMatrixSet String The layer tile matrix identifier set where to fetch tiles
		 * @param layer String The layer identifier where to fetch tiles
		 * @param style String The style for returned tiles
		 * @param matrixIds Object An object containing for each matrix (of the matrix set) its identifier an its scaleDenominator. Matrix mus be ordrer by zoomlevel
		 */ 
		public function WMTSTileProvider(
			url:String,
			format:String,
			tileMatrixSet:String,
			layer:String,
			tileMatrixSets:HashMap = null
		)
		{
			super(url, "WMTS", "1.0.0", "GetTile");
			if(tileMatrixSet)
				this._tileMatrixSet = tileMatrixSet;
			this._layer = layer;
			this._style = style;
			this._format = format;
			this._tileMatrixSets = tileMatrixSets;
			this.generateMaxExtents();
		}
		
		/**
		 * An HashMap of limits which will be applied to current <code>tileMatrixSet</code>. The strucuture of the HashMap is explicited in <code>WMTS100Capabilities.read</code> documentation
		 */
		public function get tileMatrixSetsLimits():HashMap
		{
			return _tileMatrixSetsLimits;
		}

		/**
		 * @private
		 */
		public function set tileMatrixSetsLimits(value:HashMap):void
		{
			_tileMatrixSetsLimits = value;
		}

		/**
		 * @Private
		 * calculates maxExtent of each TileMatrixSet
		 */
		private function generateMaxExtents():void {
			if(this._maxExtents) {
				this._maxExtents.clear();
			} else {
				this._maxExtents = new HashMap();
			}
			if(!this._tileMatrixSets)
				return;
			var tmkeys:Array = this._tileMatrixSets.getKeys();
			var l:uint = tmkeys.length;
			if(l==0)
				return;
			var tms:TileMatrixSet;
			var tm:TileMatrix;
			var key:String;
			var keys:Array;
			var j:uint;
			var i:uint;
			var maxExtent:Bounds;
			for(var m:uint=0; m<l; ++m) {
				maxExtent = null;
				key = tmkeys[m];
				tms = this._tileMatrixSets.getValue(key);
				if(tms.tileMatrices != null) {
					keys = tms.tileMatrices.getKeys();
					j = keys.length;
					for(i=0; i<j; ++i) {
						tm = (tms.tileMatrices.getValue(keys[i]) as TileMatrix);
						if(tm == null)
							continue;
						if(maxExtent==null) {
							maxExtent = tm.maxExtent;
						}
						else {
							if(tm.maxExtent.containsBounds(maxExtent,false,false))
								maxExtent = tm.maxExtent;
						}
					}
					if(maxExtent)
						this._maxExtents.put(key,maxExtent.clone());
				}
			}
		}
		
		public function destroy():void {
			this._layer = null;
			if(this._maxExtents) {
				this._maxExtents.clear();
				this._maxExtents = null;
			}
			
			if(this._tileMatrixSets) {
				var tmss:Array = this._tileMatrixSets.getValues();
				var l:uint = tmss.length;
				for(var i:uint = 0; i<l; ++i) {
					(tmss[i] as TileMatrixSet).destroy();
				}
				this._tileMatrixSets.clear();
				this._tileMatrixSets = null;
			}
		}
		
		/**
		 * @Private
		 * calculate Tile index
		 */
		os_internal static function calculateTileIndex(a:Number,b:Number,span:Number):Number {
			if(b<a)
				return -1;
			if(b==a)
				return 0;
			return Math.floor((b-a)/span);
		}
		
		
		/**
		 * @inheritDoc
		 */ 
		override public function getTile(bounds:Bounds, center:Pixel, layer:Layer):ImageTile
		{
			var imageTile:ImageTile = new ImageTile(layer,center,bounds,null,null);
			if(this._tileMatrixSets==null || layer == null || !(layer is WMTS) || layer.map == null)
				return imageTile;
			if(!this._tileMatrixSets.containsKey(this._tileMatrixSet))
				return imageTile;
			var tileMatrixSet:TileMatrixSet = this._tileMatrixSets.getValue(this._tileMatrixSet);
			if(tileMatrixSet==null)
				return imageTile;
			var proj:ProjProjection = ProjProjection.getProjProjection(tileMatrixSet.supportedCRS);
			if(proj != bounds.projection) {
				bounds = bounds.reprojectTo(proj);
			}
			
			//tileMatrix are referenced by their resolutions
			var resolution:Resolution = (layer as Grid).getSupportedResolution(layer.map.resolution.reprojectTo(layer.projection));
			var tileMatrix:TileMatrix = tileMatrixSet.tileMatrices.getValue(resolution.value);
			
			var tileWidth:Number = tileMatrix.tileWidth;
			var tileHeight:Number = tileMatrix.tileHeight;
			
			imageTile.size = new Size(tileWidth,tileHeight);
			
			var tileSpanX:Number = tileWidth * resolution.value;
			var tileSpanY:Number = tileHeight * resolution.value;
			
			var location:Location = bounds.center;
			var tileOrigin:Location = tileMatrix.topLeftCorner;
			if(location.projection!=tileOrigin.projection)
				location = location.reprojectTo(tileOrigin.projection);
			var col:Number = WMTSTileProvider.calculateTileIndex(tileOrigin.x,location.x,tileSpanX);
			var row:Number = WMTSTileProvider.calculateTileIndex(location.y,tileOrigin.y,tileSpanY);
			
			var params:Object = {
				"TILECOL" : col,
				"TILEROW" : row,
				"TILEMATRIX" : tileMatrix.identifier
			};
			if(col>-1 && row>-1 && isInsideLimits(col,row,tileMatrix.identifier,_tileMatrixSet))
				imageTile.url = buildGETQuery(bounds,params);
			else
				imageTile.url=null;
			
			return imageTile;
		}
		
		/**
		 * <p>This method is used internally before any WMTS request is sent.</p>
		 * 
		 * This method checks if the given <code>tileCol</code>, <code>tileRow</code> pair is contained inside TileMatrixSetLimits for the given <code>tileMatrix</code> and <code>tileMatrixSet</code>.
		 * 
		 * <p>Be aware that this method will return true in following cases (in addition to nominal case):
		 * <ul>
		 * <li><code>tileMatrixSetsLimits</code> property is not defined</li>
		 * <li>The is no reference to the given <code>tileMatrixSet</code> inside the <code>tileMatrixSetsLimits</code> property</li>
		 * <li>There are no limits referenced for the given <code>tileMatrix</code> inside the <code>tileMatrixSetsLimits</code> property</li>
		 * </ul>
		 * </p>
		 * 
		 * <p>Thus, this method returns <code>false</code> only when limits are defined but given <code>tileRow</code> and <code>tileCol</code> are not within those limits.</p>
		 * 
		 * @param tileCol a WMTS matrix column identifier
		 * @param tileRow a WMTS matrix row identifier
		 * @param tileMatrix a WMTS matrix identifier
		 * @param tileMatrixSet a WMTS matrix set identifier
		 * @return <code>true</code> or <code>false</code>. See above for more information.
		 */ 
		public function isInsideLimits(tileCol:Number,tileRow:Number,tileMatrix:String,tileMatrixSet:String):Boolean{
			if(!_tileMatrixSetsLimits || !_tileMatrixSetsLimits.getValue(tileMatrixSet)) return true;
			
			var limits:HashMap = (_tileMatrixSetsLimits.getValue(tileMatrixSet) as HashMap).getValue(tileMatrix) as HashMap;
			if(!limits) return true;
			var minTileCol:Number =  new Number(limits.getValue("MinTileCol"));
			var maxTileCol:Number =  new Number(limits.getValue("MaxTileCol"));
			var minTileRow:Number =  new Number(limits.getValue("MinTileRow"));
			var maxTileRow:Number =  new Number(limits.getValue("MaxTileRow"));
			
			if(minTileRow <= tileRow && tileRow <= maxTileRow &&
				minTileCol <= tileCol && tileCol <= maxTileCol) return true;
			
			return false;
		}
		
		/**
		 * generate resolutions uppon tile matrix set
		 */
		public function generateResolutions(numZoomLevels:uint, nominalResolution:Number=NaN):Array {
			//TODO manage nominal resolution
			if(numZoomLevels==0 
				|| this._tileMatrixSet == null
				|| this._tileMatrixSets == null
				|| !this._tileMatrixSets.containsKey(this._tileMatrixSet)) {
				return null;
			}
			
			var tms:TileMatrixSet = this._tileMatrixSets.getValue(this._tileMatrixSet);
			if(tms==null)
				return null;
			var proj:ProjProjection = ProjProjection.getProjProjection(tms.supportedCRS);
			if(!proj)
				return null;
			
			var resolutions:Array = new Array();
			
			var units:String = proj.projParams.units;
			
			var j:uint = 0;
			for each(var i:* in tms.tileMatrices.getValues()) {
				if(i==null)
					continue;
				var tm:TileMatrix = i as TileMatrix;
				resolutions.push(Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,units));
				++j;
				/*if(j>=numZoomLevels)
					break;*/
			}
			return resolutions;
		}
		
		/**
		 * @inheritDoc
		 */ 
		override os_internal function buildGETQuery(bounds:Bounds, params:Object):String {
			
			var queryString:String = super.buildGETQuery(bounds, params);
			
			var tileRow:String = String(params["TILEROW"]);
			var tileCol:String = String(params["TILECOL"]);
			var tileMatrix:String = String(params["TILEMATRIX"]);
			
			if(this._layer != null)
			{
				queryString += "LAYER=" + this._layer + "&";
			}
			
			if(this._style != null)
			{
				queryString += "STYLE=" + this._style + "&";
			}
			
			if (this._format != null)
				queryString += "FORMAT=" + this._format + "&";
			
			if(this._tileMatrixSet != null)
			{
				queryString += "TILEMATRIXSET=" + this._tileMatrixSet + "&";
			}
			
			if(this._tileMatrixSet != null)
			{
				queryString += "TILEMATRIX=" + tileMatrix + "&";
			}
			
			if(tileRow != null)
			{
				queryString += "TILEROW=" + tileRow + "&";
			}
			
			if(tileCol != null)
			{
				queryString += "TILECOL=" + tileCol + "&";
			}
			
			return queryString.substr(0,queryString.length-1);
		}
		
		//GETTERS SETTERS
		
		/**
		 * Indicates tile mimetype
		 */
		public function get format():String {
			return this._format;
		}
		/**
		 * @private
		 */
		public function set format(value:String):void {
			this._format = value;
		}
		
		/**
		 * Indicates the requested layer
		 */
		public function get layer():String
		{
			return this._layer;
		}
		/**
		 * @private
		 */
		public function set layer(value:String):void
		{
			this._layer = value;
		}
		
		/**
		 * Indicates the tile matrix set
		 */
		public function get tileMatrixSet():String
		{
			return this._tileMatrixSet;
		}
		/**
		 * @private
		 */
		public function set tileMatrixSet(value:String):void
		{
			this._tileMatrixSet = value;
		}
		
		/**
		 * Indicates the requested style
		 */
		public function get style():String
		{
			return this._style;
		}
		/**
		 * @private
		 */
		public function set style(value:String):void
		{
			this._style = value;
		}
		
		/**
		 * Indicates available tileMatrixSets
		 */
		public function get tileMatrixSets():HashMap
		{
			return this._tileMatrixSets;
		}
		/**
		 * @private
		 */
		public function set tileMatrixSets(value:HashMap):void
		{
			this._tileMatrixSets = value;
			this.generateMaxExtents();
		}
		
		/**
		 * Returns the maximal maxExtent in the tileMatrixSet
		 * 
		 * @return the maxExtent or null
		 */
		public function get maxExtent():Bounds {
			if(!this._maxExtents)
				return null;
			if(!this._maxExtents.containsKey(this._tileMatrixSet))
				return null;
			return (this._maxExtents.getValue(this._tileMatrixSet) as Bounds).clone();
		}
	}
}
