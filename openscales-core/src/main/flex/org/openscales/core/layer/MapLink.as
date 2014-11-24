package org.openscales.core.layer
{
	import org.openscales.core.layer.osm.OSM;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.core.basetypes.Resolution;
	
	public class MapLink extends OSM
	{
		public function MapLink( identifier:String ) {
			var url:String = "http://tmmap-a.akamaihd.net/tilegenerator/tile.ashx/";
			super(identifier, url);
			this.generateResolutions(18, OSM.DEFAULT_MAX_RESOLUTION);
		}
		
		
		override public function getURL(bounds:Bounds):String {
			var res:Resolution = this.getSupportedResolution(this.map.resolution.reprojectTo(this.projection));
			var x:Number = Math.round((bounds.left - this.maxExtent.left) / (res.value * this.tileWidth));
			var y:Number = Math.round((this.maxExtent.top - bounds.top) / (res.value * this.tileHeight));
			var z:Number = this.getZoomForResolution(res.reprojectTo(this.projection).value);
			var limit:Number = Math.pow(2, z);
			
			if (y < 0 || y >= limit ||x < 0 || x >= limit) {
				return OSM.MISSING_TILE_URL;
			} else {
				x = ((x % limit) + limit) % limit;
				y = ((y % limit) + limit) % limit;
				var url:String = this.url;
				var path:String = "?zoom=" + z + "&x=" + x + "&y=" + y;
				if (this.altUrls != null) {
					url = this.selectUrl(this.url + path, this.getUrls());
				}
				
				return url + path + "&tileCacheControlVersion=11";
			}
		}
		
	}
}