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
		
		private var _style:String=null;
		
		private var _reproject:Boolean = true;

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
				 maxExtent.transform(this.projSrsCode,this.map.baseLayer.projSrsCode);
			}
			return maxExtent;
		}
		
		
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
		
		override public function redraw(fullRedraw:Boolean = true):void {
			(_tileProvider as WMSTileProvider).width = this.tileWidth;
			(_tileProvider as WMSTileProvider).height = this.tileHeight;
			super.redraw(fullRedraw);
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

	}
}

