package org.openscales.core.layer.ogc
{
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.provider.WMTSTileProvider;
	import org.openscales.core.layer.params.IHttpParams;
	import org.openscales.core.tile.ImageTile;
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
		public static const WMTS_DEFAULT_FORMAT:String = "image/jpeg";
		/**
		 * @private
		 *  
		 * A tile provider for this layer.
		 */ 
		private var _tileProvider:WMTSTileProvider;
		
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
			super(name, url);
			// building the tile provider
			this._tileProvider = new WMTSTileProvider(url,format,tileMatrixSet,layer,tileMatrixSets);
			this.format = WMTS.WMTS_DEFAULT_FORMAT;
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
			this.resolutions = this._tileProvider.generateResolutions(numZoomLevels,nominalResolution);
			this._autoResolution = true;
		}
		
		override public function getURL(bounds:Bounds):String {
			return this._tileProvider.getTile(bounds,null,this).url;
		}
		
		/**
		 * Indicates tile mimetype
		 */
		public function get format():String {
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
			this._tileProvider.tileMatrixSet = value;
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
			this._tileProvider.tileMatrixSets = value;
		}

	}
	
}