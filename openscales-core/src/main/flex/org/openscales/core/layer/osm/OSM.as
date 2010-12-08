package org.openscales.core.layer.osm
{
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.core.layer.TMS;

	/**
	 * Base class for Open Street Map layers
	 *
	 * @author Bouiaw
	 */	
	public class OSM extends TMS
	{
		public static const MISSING_TILE_URL:String="http://openscales.org/assets/osm_404.png";
		
		public static const DEFAULT_MAX_RESOLUTION:Number = 156543.0339;
		
		public function OSM(name:String,
							url:String) {

			super(name, url);
			this.projSrsCode = "EPSG:900913";
			// Use the projection to access to the unit
			/* this.units = Unit.METER; */
			this.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,this.projSrsCode);
		}

		override public function getURL(bounds:Bounds):String
		{
			var res:Number = this.map.resolution;
			var x:Number = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileWidth));
			var y:Number = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileHeight));
			var z:Number = this.map.zoom;
			var limit:Number = Math.pow(2, z);

			if (y < 0 || y >= limit ||x < 0 || x >= limit) {
				return OSM.MISSING_TILE_URL;
			} else {
				x = ((x % limit) + limit) % limit;
				y = ((y % limit) + limit) % limit;
				var url:String = this.url;
				var path:String = z + "/" + x + "/" + y + ".png";
				if (this.altUrls != null) {
					url = this.selectUrl(this.url + path, this.getUrls());
				}
				return url + path;
			}
		}

	}
}
