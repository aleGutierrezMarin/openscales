package org.openscales.core.layer.ogc
{

	import org.openscales.core.layer.Grid;
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

		private var _reproject:Boolean = true;

		public function WMS(name:String = "",
							url:String = "",
							layers:String = "") {

			super(name, url, new WMSParams(layers));
			
			this.singleTile = true;
			
			CACHE_SIZE = 32;

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
		
		override public function getURL(bounds:Bounds):String {
			var projectedBounds:Bounds = bounds.clone();
			
			if (this.isBaseLayer != true  && this.reproject == true && this.map.baseLayer && this.projSrsCode != this.map.baseLayer.projSrsCode) {
			  	projectedBounds.transform(this.projSrsCode,this.map.baseLayer.projSrsCode);
			}

			this.params.bbox = projectedBounds.boundsToString();
			(this.params as WMSParams).width = this.imageSize.w;
			(this.params as WMSParams).height = this.imageSize.h;
			if (this.reproject == false) {
				if (this.projSrsCode != null || this.map.baseLayer.projSrsCode != null) {
					(this.params as WMSParams).srs = (this.projSrsCode == null) ? this.map.baseLayer.projSrsCode : projSrsCode;
				}
			} else {
				(this.params as WMSParams).srs = this.projSrsCode;
			}
			
			return this.url + ((this.url.indexOf("?")==-1) ? "?" : "&") + this.params.toGETString();
		}

		override public function addTile(bounds:Bounds, position:Pixel):ImageTile {
			var url:String = this.getURL(bounds);
			var img:ImageTile = new ImageTile(this, position, bounds, 
				url, new Size(this.tileWidth, this.tileHeight));
			if(this.method != null)
				img.method = this.method;
			return img;
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

	}
}

