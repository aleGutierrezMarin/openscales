package org.openscales.core.layer.ogc
{

	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.ogc.provider.WMSTileProvider;
	import org.openscales.core.layer.params.ogc.WMSParams;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.core.tile.Tile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;

	/**
	 * Instances of WMS are used to display data from OGC Web Mapping Services.
	 *
	 * @author Bouiaw
	 */	
	public class WMS extends Grid
	{
		/**
		 * @private
		 * Layer name in the layer switcher
		 */ 
		protected var _layerName:String;
		
		/**
		 * @private
		 * Version of wms protocol used to request the server
		 * Default version is 1.3.0
		 */
		protected var _version:String="1.3.0";
		
		/**
		 * @private
		 * The tile provider allows users to generate requests to the server and get the requested tiles
		 */
		private var _tileProvider:WMSTileProvider=null;
		
		/**
		 * @private
		 * Style of the layers to display
		 */
		protected var _style:String="";
		
		/**
		 * @private
		 * MIME type for the requested layer
		 */
		protected var _format:String;
		
		/**
		 * @private 
		 * Way to display errors for the requested tile
		 */ 
		protected var _exceptions:String;
		
		/**
		 * @private 
		 * Indicates if the tile should be transparent or not
		 */ 
		protected var _transparent:Boolean;
		
		/**
		 * @private 
		 * Background color of the requested tile
		 */ 
		protected var _bgcolor:String;
		
		/**
		 * @private
		 * Layer identifier to request from service
		 */
		protected var _layers:String;
		
		
		
		/**
		 * @private
		 * Indicate if the map is reprojected
		 */
		private var _reproject:Boolean = true;

		/**
		 * Constructor of the class
		 * 
		 * @param name Name of the layers to display
		 * @param url URL of the service to request
		 * @param style Styles of the layers to display
		 * 
		 */
		public function WMS(name:String = "",
							url:String = "",
							layers:String = "",
							style:String="") {

			super(name, url);
			
			//in WMS we must be in single tile mode
			this.tiled = true;
			CACHE_SIZE = 32;
			
			//Call the tile provider to generate the request and get the tile requested 
			this._tileProvider = new WMSTileProvider(this,url,this._version, layers,this.projSrsCode);
			this._tileProvider.style=style;

		}
	    override public function get maxExtent():Bounds {
			if (! super.maxExtent) {
				return null;
			}
			
			var maxExtent:Bounds =  super.maxExtent.clone();
			if (this.isBaseLayer != true && this.reproject == true && this.map.baseLayer && this.projSrsCode != this.map.baseLayer.projSrsCode) {
				maxExtent = maxExtent.reprojectTo(this.map.baseLayer.projSrsCode);
			}
			return maxExtent;
		}
		
		/**
		 * Generate the tile corresponding to the bounds given as parameter
		 * 
		 * @param bounds Bounds of the area to display
		 * @param position
		 */
		override public function addTile(bounds:Bounds, position:Pixel):ImageTile {
			var imgTile:ImageTile =  this._tileProvider.getTile(bounds);
			imgTile.position = position;
			return imgTile;
		}

		public function get reproject():Boolean {
			return this._reproject;
		}

		public function set reproject(value:Boolean):void {
			this._reproject = value;
		}
		
		public function get exception():String {
			return (this.params as WMSParams).exceptions;
		}
		
		public function set exception(value:String):void {
			(this.params as WMSParams).exceptions = value;
		}
		
		/**
		 * Override method used to update the wms tile displayed when using the zoom control
		 * 
		 */
		override public function redraw(fullRedraw:Boolean = true):void {
			(_tileProvider as WMSTileProvider).width = this.tileWidth;
			(_tileProvider as WMSTileProvider).height = this.tileHeight;
			super.redraw(fullRedraw);
		}

		/**
		 * Override method to get the well-formed url to get the requested tile
		 * 
		 */
		override public function getURL(bounds:Bounds):String {
			return this._tileProvider.getTileUrl(bounds);
		}
		/**
		 * Get and set the version of the wms protocol
		 */
		public function get version():String
		{
			return _version;
		}
		/**
		 * @private
		 */
		public function set version(value:String):void
		{
			this._version = value;
			
			//update the tileprovider version of the protocol at the same time
			if (this._tileProvider != null){
				this._tileProvider.version = value;
			}
		}

		public function get style():String
		{
			return _style;
		}

		public function set style(value:String):void
		{
			_style = value;
			
			//update the tileprovider of the wmslayer at once
			if(this._tileProvider != null){
				this._tileProvider.style=value;
			}
		}
		
		/**
		 * Way to display errors for the requested tile
		 */ 
		public function get exceptions():String {
			return this._exceptions;
		}
		/**
		 * @private
		 */
		public function set exceptions(exceptions:String):void {
			this._exceptions = exceptions;
			
			//update the tileprovider of the wmslayer at once
			if(this._tileProvider != null){
				this._tileProvider.exceptions=exceptions;
			}
		}
		
		override public function get tiled():Boolean {
			return super._tiled;
		}
		
		override public function set tiled(value:Boolean):void {
			super._tiled = value;
			
			//update the tileprovider of the wmslayer at once
			if(this._tileProvider != null){
				this._tileProvider.tiled=value;
			}
		}
		
		/**
		 * Indicates if the layer's tiles should be transparent or not
		 */ 
		public function get transparent():Boolean {
			return this._transparent;
		}
		/**
		 * @private
		 */
		public function set transparent(transparent:Boolean):void {
			this._transparent = transparent;
			
			//update the tileprovider of the wmslayer at once
			if(this._tileProvider != null){
				this._tileProvider.transparent=transparent;
			}
		}
		
		/**
		 * Background color of the requested tiles
		 */ 
		public function get bgcolor():String {
			return this._bgcolor;
		}
		/**
		 * @private
		 */
		public function set bgcolor(bgcolor:String):void {
			this._bgcolor = bgcolor;
			
			//update the tileprovider of the wmslayer at once
			if(this._tileProvider != null){
				this._tileProvider.bgcolor=bgcolor;
			}
		}
		
		/**
		 * 
		 * MIME type for the requested layer (default : image/jpeg) 
		 */
		public function get format():String
		{
			return _format;
		}
		/**
		 * @private
		 */
		public function set format(value:String):void
		{
			this._format = value;
			
			//update the tileprovider of the wmslayer at once
			if(this._tileProvider != null){
				this._tileProvider.format=format;
			}
		}
		
		/**
		 * Service url where the developper get the layer
		 */
		override public function get url():String
		{
			return super._url;
		}
		/**
		 * @private
		 */
		override public function set url(value:String):void
		{
			super._url = value;
			
			//update the tileprovider of the wmslayer at once
			if(this._tileProvider != null){
				this._tileProvider.url=value;
			}
		}
		
		
		/**
		 * Set the layers that the tileprovider is going to request
		 * 
		 * @param value Names of the layers to request
		 * 
		 */
		public function get layers():String
		{
			return this._layers;
		}
		/**
		 * @private
		 */
		public function set layers(value:String):void
		{
			this._layers = value;
			
			if(this._tileProvider != null){
				this._tileProvider.layer=value;
			}
		}
		
		public function get projection():String
		{
			return _projSrsCode;
		}
		/**
		 * @private
		 */
		public function set projection (value:String):void
		{
			super.projSrsCode=value;
			
			if(this._tileProvider != null){
				this._tileProvider.projection=value;
			}
		}
		
		/**
		 * 
		 * Layer name to display in the layer switcher
		 */ 
		public function get layerName():String
		{
			return this._layerName;
		}
		/**
		 * @private
		 */
		public function set layerName(value:String):void
		{
			this._layerName = value;
		}
		
		
		/**
		 * Set the width of the tile returned by the request
		 *
		 * @param value width of the tile
		 */
		override public function set tileWidth(value:Number):void {
			super.tileWidth = value;
			if(this._tileProvider !=null){
				this._tileProvider.width=value;
			}
		}
		
		/**
		 * Set the height of the tile returned by the request
		 *
		 * @param value height of the tile
		 */
		override public function set tileHeight(value:Number):void {
			super.tileHeight = value;
			if(this._tileProvider !=null){
				this._tileProvider.height=value;
			}
		}
	}
}

