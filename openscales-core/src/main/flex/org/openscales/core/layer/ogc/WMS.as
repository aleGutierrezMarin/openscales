package org.openscales.core.layer.ogc
{

	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.capabilities.GetCapabilities;
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
		 * An HashMap containing the capabilities of the layer.
		 */
		private var _capabilities:HashMap = null;
		/**
		 * @private
		 * Do we use get capabilities?
		 */
		private var _useCapabilities:Boolean = false;
		
		/**
		 * @private
		 * Version of wms protocol used to request the server
		 * Default version is 1.1.1
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
		protected var _styles:String="";
		
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
		 * @param styles Styles of the layers to display
		 * 
		 */
		public function WMS(identifier:String = "",
							url:String = "",
							layers:String = "",
							styles:String = "",
							format:String = "image/png"){
			
			super(identifier, url);
			
			// Properties initialization
			this._layerName = name;
			super.url = url;
			this._layers = layers;
			this._styles = styles;
			this._format = format;
			
			// In WMS we must be in single tile mode
			this.tiled = false;
			
			// Call the tile provider to generate the request and get the tile requested
			this._tileProvider = new WMSTileProvider(url, this._version, layers, this.projection, styles, format);
		}
		
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
			if(!params)return null;
			return (this.params as WMSParams).exceptions;
		}
		
		public function set exception(value:String):void {
			if(!params)return;
			(this.params as WMSParams).exceptions = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set map(map:Map):void {
			super.map = map;
			// GetCapabilities request made here in order to have the proxy set 
			if (url != null && url != "" && this.capabilities == null && useCapabilities == true) {
				var getCap:GetCapabilities = new GetCapabilities("wms", url, this.capabilitiesGetter,
					version, this.proxy, this.security);
			}
		}
		
		/**
		 * Override method used to update the wms tile displayed when using the zoom control
		 * 
		 */
		override public function redraw(fullRedraw:Boolean = false):void {
			if (this.map == null)
				return;
			if(this._useCapabilities && !this._capabilities)
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
		 * Default version is 1.1.1
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
		 * Get and set the styles of the WMS protocol
		 */
		public function get styles():String
		{
			return _styles;
		}
		/**
		 * @private
		 */
		public function set styles(value:String):void
		{
			_styles = value;
			
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

		/**
		 * @private
		 */
		override public function set projection (value:*):void
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
		
		/**
		 * Indicates the capabilities result
		 */
		public function get capabilities():HashMap {
			return this._capabilities;
		}
		/**
		 * @private
		 */
		public function set capabilities(value:HashMap):void {
			this._capabilities = value;
		}
		
		/**
		 * Indicates if capabilities should be used.
		 * Default false
		 */
		public function get useCapabilities():Boolean {
			return this._useCapabilities;
		}
		/**
		 * @private
		 */
		public function set useCapabilities(value:Boolean):void {
			this._useCapabilities = value;
			this.available = this.checkAvailability();
		}
		
		/**
		 * Callback method called by the capabilities retriever.
		 *
		 * @param the GetCapabilities instance which call it.
		 */
		public function capabilitiesGetter(caller:GetCapabilities):void {
			this._capabilities = caller.getLayerCapabilities(this.layers);
			if ((this._capabilities != null) && (this.projection == null || this.useCapabilities)) {
				var projs:String = this._capabilities.getValue("SRS");
				var aProj:Vector.<String> = new Vector.<String>();
				if(projs) {
					var projsArray:Array = projs.split(",");
					for each(var oSrs:String in projsArray) {
						if(oSrs && oSrs.length>0)
							aProj.push(oSrs);
					}
				}
				//this.projection = this._capabilities.getValue("SRS");
				//Setting availableProjections
				
				/*aProj.push(this._capabilities.getValue("SRS"));
				var otherSRS:Vector.<String> = (this._capabilities.getValue("OtherSRS") as Vector.<String>);
				for each(var oSrs:String in otherSRS) {
					if(aProj.indexOf(oSrs) < 0) {
						aProj.push(oSrs);
					}
				}*/
				this.availableProjections = aProj;
				
				if(this.map)
					this.redraw(true);
			}
		}
	}
}

