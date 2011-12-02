package org.openscales.core.layer.ogc
{

	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.ogc.provider.WMSTileProvider;
	import org.openscales.core.layer.params.ogc.WMSParams;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.core.tile.Tile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
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
		protected var _version:String="1.1.1";
		
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
		protected var _format:String ="image/png";
		
		/**
		 * @private 
		 * Way to display errors for the requested tile
		 */ 
		protected var _exceptions:String;
		
		/**
		 * @private 
		 * Indicates if the tile should be transparent or not
		 */ 
		protected var _transparent:Boolean = true;
		
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
							style:String = "",
							format:String = "image/png")
		{
			super(name, url);
			
			// Properties initialization
			this._layerName = name;
			super.url = url;
			this._layers = layers;
			this._style = style;
			this._format = format;
			
			// In WMS we must be in single tile mode
			this.tiled = false;
			
			// Call the tile provider to generate the request and get the tile requested
			this._tileProvider = new WMSTileProvider(url, this._version, layers, this.projection, style, format);
		}
		
		//
	    /*override public function get maxExtent():Bounds {
			/*if (! super.maxExtent) {
				return null;
			}*/

			/*var maxExtent:Bounds =  super.maxExtent.clone();
			if(this.map == null){
				return maxExtent;
			}
			// fix me
			if (this.reproject == true && this.projection != this.map.projection) {
				maxExtent = maxExtent.reprojectTo(this.map.projection);
			}
			return super.maxExtent;
		}*/
		
		/**
		 * Generate the tile corresponding to the bounds given as parameter
		 * 
		 * @param bounds Bounds of the area to display
		 * @param position
		 */
		override public function addTile(bounds:Bounds, position:Pixel):ImageTile {
			return this._tileProvider.getTile(bounds, position, this);
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
		override public function redraw(fullRedraw:Boolean = false):void {
			if (this.map == null)
				return;
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
		 * Get and set the version of the WMS protocol
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
			
			// Update the tileProvider version at the same time
			if(this._tileProvider != null){
				this._tileProvider.version = value;
			}
		}
		
		/**
		 * Get and set the style of the WMS protocol
		 */
		public function get style():String
		{
			return _style;
		}
		/**
		 * @private
		 */
		public function set style(value:String):void
		{
			_style = value;
			
			// Update the tileProvider style at the same time
			if(this._tileProvider != null){
				this._tileProvider.style = value;
			}
		}
		
		/**
		 * Way to display errors for the requested tile
		 */ 
		public function get exceptions():String
		{
			return this._exceptions;
		}
		/**
		 * @private
		 */
		public function set exceptions(exceptions:String):void
		{
			this._exceptions = exceptions;
			
			// Update the tileProvider exceptions at the same time
			if(this._tileProvider != null){
				this._tileProvider.exceptions = exceptions;
			}
		}
		
		
		override public function get tiled():Boolean {
			return this._tiled;
		}
		
		override public function set tiled(value:Boolean):void {
			this._tiled = value;
			
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
			this.redraw(true);
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
		 * MIME type for the requested layer (default : image/png)
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
			
			// Update the tileProvider format at the same time
			if(this._tileProvider != null){
				this._tileProvider.format = format;
			}
		}
		
		/**
		 * Service url where the developper get the layer
		 */
		override public function get url():String
		{
			return super.url;
		}
		/**
		 * @private
		 */
		override public function set url(value:String):void
		{
			super.url = value;
			
			// Update the tileProvider version of the protocol at the same time
			if(this._tileProvider != null){
				this._tileProvider.url = value;
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
			
			// Update the tileProvider layer at the same time
			if(this._tileProvider != null){
				this._tileProvider.layer = value;
			}
		}
		
		
		override public function get projection():String
		{
			return _projection;
		}
		/**
		 * @private
		 */
		override public function set projection (value:String):void
		{
			super.projection = value;
			
			// Update the tileProvider projection at the same time
			if(this._tileProvider != null){
				this._tileProvider.projection = value;
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
		 * The width of the tiles requested.
		 * If the layer is not in tiled mode, the value of tileWidth 
		 * is the width of the map or NaN if the layer is not in a map
		 * @param value width of the tile
		 */
		override public function set tileWidth(value:Number):void {
			super.tileWidth = value;
			if(this._tileProvider !=null){
				this._tileProvider.width=value;
			}
		}
		
		/**
		 * The height of the tiles requested.
		 * If the layer is not in tiled mode, the value of tileHeight
		 * is the height of the map or NaN if the layer is not in a map
		 * @param value height of the tile
		 */
		override public function set tileHeight(value:Number):void {
			super.tileHeight = value;
			if(this._tileProvider !=null){
				this._tileProvider.height=value;
			}
		}
		
		/**
		 * @inherit
		 */
		override public function get tileOrigin():Location
		{
			return super.tileOrigin;
		}	
		
		/**
		 * @private
		 */
		override public function set tileOrigin(value:Location):void
		{
			super.tileOrigin = value;
		}
	}
}

