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
		 * Version of wms protocol used to request the server
		 * Default version is 1.3.0
		 */
		private var _version:String="1.3.0";
		
		/**
		 * @private
		 * The tile provider allows users to generate requests to the server and get the requested tiles
		 */
		private var _tileProvider:WMSTileProvider=null;
		
		/**
		 * @private
		 * Style of the layers to display
		 */
		private var _style:String=null;
		
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
							style:String="default") {

			super(name, url);
			
			//in WMS we must be in single tile mode
			this.singleTile = true;
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
			return this._tileProvider.getTile(bounds);
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
		 * Set the layers that the tileprovider is going to request
		 * 
		 * @param value Names of the layers to request
		 * 
		 */
		public function setLayersToDisplay(value:String):void{
			if(this._tileProvider != null){
				this._tileProvider.layer=value;
			}
		}
		
		/**
		 * Set the MIME format that the tileprovider is going to return after a request
		 * 
		 * @param value Format of the tiles returned
		 * 
		 */
		public function setFormatToDisplay(value:String):void{
			if(this._tileProvider != null){
				this._tileProvider.format=value;
			}
		}
		
		/**
		 * Set the transparency of the tiles returned by the tileprovider
		 * 
		 * @param value true if transparent, false otherwise
		 * 
		 */
		public function setTransparencyToDisplay(value:Boolean):void{
			if(this._tileProvider != null){
				this._tileProvider.transparent=value;
			}
		}
		
		/**
		 * Set the background color of the tiles returned by the tileprovider
		 * 
		 * @param value background color of the tiles returned
		 * 
		 */
		public function setBgcolorToDisplay(value:String):void{
			if(this._tileProvider != null){
				this._tileProvider.bgcolor=value;
			}
		}
		
		/**
		 * Set the wms layer should be tiled or not
		 * 
		 * @param value true if the layer should be tiled, false otherwise.
		 * 
		 */
		public function setTiledToDisplay(value:Boolean):void{
			if(this._tileProvider != null){
				this._tileProvider.tiled=value;
			}
		}
		
		/**
		 * Set the way exceptions should be returned by the tileprovider
		 * 
		 * @param value Format of the exceptions returned
		 * 
		 */
		public function setExceptionsToDisplay(value:String):void{
			if(this._tileProvider != null){
				this._tileProvider.exceptions=value;
			}
		}
		
		/**
		 * Set the SLD style
		 * 
		 * @param value sld style to apply
		 * 
		 */
		public function setSLDToDisplay(value:String):void{
			if(this._tileProvider != null){
				this._tileProvider.sld=value;
			}
		}
		
		/**
		 * Set the URL to request
		 *
		 * @param value URL of the service to request
		 */
		public function setURLToDisplay(value:String):void{
			if(this._tileProvider !=null){
				this._tileProvider.url=value;
			}
		}
		

	}
}

