package org.openscales.core.layer.ogc.provider
{
	import org.openscales.core.Trace;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.layer.ogc.provider.OGCTileProvider;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	use namespace os_internal;
	
	public class WMTSTileProvider extends OGCTileProvider
	{
		public const METERS_PER_INCH:Number = 0.0254;
		public const INCHES_PER_UNIT:Object = {"dd":"1.4553128",
			"m":"39.3700787",
			"ft":"0.08333",
			"inches":"1.0"};
		
		/**
		 * @protected 
		 * Reference to openscales layer
		 */
		protected var _openScaleLayer:WMTS;
		
		/**
		 * @protected 
		 * Requested layer
		 */ 
		protected var _layer:String;
		/**
		 * @protected 
		 * Style to apply on the requested layer
		 */ 
		protected var _style:String;
		
		/**
		 * @protected 
		 * Requested matrix set
		 */
		protected var _tileMatrixSet:String;
		
		/**
		 * @protected 
		 * MIME type for returned tiles
		 */ 
		protected var _format:String;
		
		/**
		 * @protected
		 * An object containing for each matrix (of the tileMatrixSet)
		 * <p>In the array, matrix are ordered, minimum index containing the identifier of the lowest matrix</p>
		 */
		protected var _matrixIds:Object;
		
		/**
		 * Tile origin for the matrix, default top-left corner of layer max extent
		 * 
		 * @protected
		 */ 
		private var _tileOrigin:Location
		
		/**
		 * TODO change this
		 */
		public var zoom:Number;
		
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
			style:String,
			matrixIds:Object
		)
		{
			super(url, "WMTS", "1.0.0", "GetTile");
			
			this._tileMatrixSet = tileMatrixSet;
			this._layer = layer;
			this._style = style;
			this._format = format;
			this._matrixIds = matrixIds;
		}
		
		/**
		 * @private
		 * 
		 * Internal method used to get the tile matrix matching the specified zoom level.
		 * If matrixIds does not exists or is empty, the method will return the zoom level as a string
		 * If matrixIds exists, the method will return the matrix identifier matching the specified zoom level.
		 * If the zoom level exceeds matrixIds length, the method returns the value of the last index of matrixIds 
		 * <br/>
		 * 
		 * @param zoomLevel Number The required zoom level
		 * @return String The matching tile matrix identifier
		 */ 
		os_internal function calculateTileMatrix(zoomLevel:Number):String
		{	
			/*if(this._matrixIds==null) return String(zoomLevel);
			
			var lgth:Number = this._matrixIds.length
		
			// matrixIds is empty, returning zoomLevel as matrix
			if(lgth <= 0) return String(zoomLevel);	
			
			// if zoomLevel is correspond to a matrixIds index, returning the corresponding matrix 
			if(zoomLevel <= lgth) return this._matrixIds[String(zoomLevel-1)]["identifier"];
			
			//if zoomLevel exceed greatest zoom, returning greatest index matrix
			if(zoomLevel > lgth) return this._matrixIds[String(lgth-1)];
			*/
			// Fallback
			return String(zoomLevel);
			
		}
		
		/**
		 * @private
		 * 
		 * Internal method used to calculate tile row and col according to specified parameters
		 * 
		 * @param location Location The location (map coordinates) from which we want to calculate corresponding row and col
		 * @param resolution: Number The resolution of the Map (maps units/pixels)
		 * @param tileOrigin Location The location (map coordinates) of top left corner of the Map
		 * @param tileWidth Number The typical tiles width (pixels) for the current matrix
		 * @param tileHeight Number The typical tiles height (pixels) for the current matrix
		 * 
		 * @return Array An array of 2 String elements where index 0 contains the tile column and index 1 the tile row. 
		 * @see Map
		 */ 
		os_internal function calculateTileRowAndCol(bounds:Bounds, tileOrigin:Location):Array
		{
			var ret:Array = new Array(2);
			
			var location:Location = bounds.center;
			
			var fx:Number = (location.lon - tileOrigin.lon) / Math.abs(Math.abs(bounds.right) - Math.abs(bounds.left));
			var fy:Number = (tileOrigin.lat - location.lat) / Math.abs(Math.abs(bounds.top) - Math.abs(bounds.bottom));
			
			ret[0] = String(Math.floor(fx));//tile col
			ret[1] = String(Math.floor(fy));//tile row
			
			return ret;
		}
		
		
		
		
		/**
		 * @inheritDoc
		 */ 
		override public function getTile(bounds:Bounds):ImageTile
		{
			// Should calculateTileMatrix
			var tileMatrix:String = calculateTileMatrix(this.zoom);
			// then call calculateTileRowAndCol
			
			 var tOrigin:Location= new Location(0,12000000,"IGNF:LAMB93");
			
			var infos:Array = this.calculateTileRowAndCol(bounds, tOrigin);
			/*if(infos[0]<0 || infos[1]<0)
				return null;*/
			
			var params:Object = {
				"TILECOL" : String(infos[0]),
				"TILEROW" : String(infos[1]),
				"TILEMATRIX" : tileMatrix
			}
			
			var queryString:String =  buildGETQuery(bounds,params);
			
			return new ImageTile(null,null,bounds, queryString, new Size(256,256) );
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
			
			if(tileMatrix != null)
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
		
		/**
		 * ???
		 */
		public function get openScaleLayer():WMTS
		{
			return _openScaleLayer;
		}
		/**
		 * @private
		 */
		public function set openScaleLayer(value:WMTS):void
		{
			_openScaleLayer = value;
		}
		
		/**
		 * Indicates the requested layer
		 */
		public function get layer():String
		{
			return _layer;
		}
		/**
		 * @private
		 */
		public function set layer(value:String):void
		{
			_layer = value;
		}
		
		/**
		 * Indicates the tile matrix set
		 */
		public function get tileMatrixSet():String
		{
			return _tileMatrixSet;
		}
		/**
		 * @private
		 */
		public function set tileMatrixSet(value:String):void
		{
			_tileMatrixSet = value;
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
			this.style = value;
		}

		/**
		 * Tile origin for the matrix, default top-left corner of layer max extent
		 * 
		 * @protected
		 */
		public function get tileOrigin():Location
		{
			return _tileOrigin;
		}

		/**
		 * @private
		 */
		public function set tileOrigin(value:Location):void
		{
			_tileOrigin = value;
		}
		
	}
}
