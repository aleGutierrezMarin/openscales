package org.openscales.core.layer.ogc.provider
{
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.layer.ogc.WMTS.TileMatrix;
	import org.openscales.core.layer.ogc.WMTS.TileMatrixSet;
	import org.openscales.core.layer.ogc.provider.OGCTileProvider;
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
		private var _capabilitiesRequested:Boolean = false;
		
		
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
			
			this._tileMatrixSet = tileMatrixSet.toUpperCase();
			this._layer = layer;
			this._style = style;
			this._format = format;
			this._tileMatrixSets = tileMatrixSets;
		}
		
		public function destroy():void {
			//TODO
		}
		
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
			if(this._tileMatrixSets==null || layer == null || layer.map == null)
				return imageTile;
			if(!this._tileMatrixSets.containsKey(this._tileMatrixSet))
				return imageTile;
			var tileMatrixSet:TileMatrixSet = this._tileMatrixSets.getValue(this._tileMatrixSet);
			if(tileMatrixSet==null)
				return imageTile;
			Trace.debug(bounds.toString());
			if(tileMatrixSet.supportedCRS.toUpperCase() != bounds.projSrsCode.toUpperCase()) {
				bounds = bounds.reprojectTo(tileMatrixSet.supportedCRS);
			}
			
			var mapResolution:Number = layer.map.resolution;
			var mapUnit:String = ProjProjection.getProjProjection(layer.map.baseLayer.projSrsCode).projParams.units;
			
			//tileMatrix are referenced by their resolutions
			var zoom:Number = layer.getZoomForResolution(mapResolution);
			var resolution:Number = (layer.resolutions[zoom] as Number);
			var tileMatrix:TileMatrix = tileMatrixSet.tileMatrices.getValue(resolution);
			
			var tileWidth:Number = tileMatrix.tileWidth;
			var tileHeight:Number = tileMatrix.tileHeight;
			
			var tileSpanX:Number = tileWidth * resolution;
			var tileSpanY:Number = tileHeight * resolution;
			
			var location:Location = bounds.center;
			var tileOrigin:Location = tileMatrix.topLeftCorner;
			var col:Number = WMTSTileProvider.calculateTileIndex(tileOrigin.x,location.x,tileSpanX);
			var row:Number = WMTSTileProvider.calculateTileIndex(location.y,tileOrigin.y,tileSpanY);
			if(col<0 || row< 0 || col>tileMatrix.matrixWidth-1 || row>tileMatrix.matrixHeight-1)
				return imageTile;
			Trace.debug("test1");
			var params:Object = {
				"TILECOL" : col,
				"TILEROW" : row,
				"TILEMATRIX" : tileMatrix.identifier
			};
			
			imageTile.url = buildGETQuery(bounds,params);
			
			imageTile.size = new Size(tileWidth,tileHeight);
			Trace.debug("Tile url: "+imageTile.url);
			if(center != null)
				Trace.debug(center.toString());
			else
				Trace.debug("pas de center");
			return imageTile;
		}
		
		public function generateResolutions(numZoomLevels:uint, nominalResolution:Number=NaN):Array {
			var resolutions:Array = new Array();
			if(numZoomLevels==0 || !this._tileMatrixSets.containsKey(this._tileMatrixSet))
				return resolutions;
			
			var tms:TileMatrixSet = this._tileMatrixSets.getValue(this._tileMatrixSet);
			
			if(tms==null)
				return resolutions;
			var j:uint = 0;
			for each(var i:* in tms.tileMatrices.getValues()) {
				if(i==null)
					continue;
				var tm:TileMatrix = i as TileMatrix;
				resolutions.push(Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units));
				++j;
				if(j>=numZoomLevels)
					break;
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
			this._tileMatrixSet = value.toUpperCase();
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
		}
		
		/**
		 * Returns the maximal maxExtent in the tileMatrixSet
		 * 
		 * @return the maxExtent or null
		 */
		public function get maxExtent():Bounds {
			var maxExtent:Bounds = null;
			if(this._tileMatrixSets != null
				&& this._tileMatrixSets.containsKey(this._tileMatrixSet)) {
				var tms:TileMatrixSet = this._tileMatrixSets.getValue(this._tileMatrixSet);
				if(tms.tileMatrices != null) {
					var keys:Array = tms.tileMatrices.getKeys();
					var j:uint = keys.length;
					for(var i:uint=0; i<j; ++i) {
						var tm:TileMatrix = (tms.tileMatrices.getValue(keys[i]) as TileMatrix);
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
				}
			}
			if(maxExtent != null)
				return maxExtent.clone();
			return null;
		}
	}
}
