package org.openscales.core.layer.osm
{
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.TMS;
	import org.openscales.core.layer.originator.ConstraintOriginator;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;

	/**
	 * Base class for Open Street Map layers
	 *
	 * @author Bouiaw
	 */	
	public class OSM extends TMS
	{
		public static const MISSING_TILE_URL:String="http://openscales.org/assets/osm_404.png";
		
		public static const DEFAULT_MAX_RESOLUTION:Number = 156543.0339;
		
		private static const OSM_ORIGINATOR:DataOriginator = new DataOriginator("OpenStreetMap","http://www.openstreetmap.org","http://www.openstreetmap.org/assets/osm_logo-9b6498da08de0514dfcb996c32e84dbd.png");
		private static const CREATIVE_BY_CA:DataOriginator = new DataOriginator("Creative Commons", "http://creativecommons.org/licenses/by-sa/2.0/", "http://wiki.april.org/skins/common/images/icons/cc-by-sa.png");

		
		public function OSM(identifier:String,
							url:String = null,
							data:XML = null) {

			super(identifier, url,displayedName);

			this.projection = "EPSG:900913";
			// Use the projection to access to the unit
			/* this.units = Unit.METER; */
			this.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,this.projection);
			var constraint:ConstraintOriginator = new ConstraintOriginator(this.maxExtent, this.minResolution, this.maxResolution);
			OSM_ORIGINATOR.constraints.push(constraint);
			CREATIVE_BY_CA.constraints.push(constraint);
			this.originators.push(OSM_ORIGINATOR);
			this.originators.push(CREATIVE_BY_CA);
			this._tileOrigin = new Location(this.maxExtent.left,this.maxExtent.top,this.maxExtent.projection);
		}

		override public function getURL(bounds:Bounds):String
		{
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
				var path:String = z + "/" + x + "/" + y + ".png";
				if (this.altUrls != null) {
					url = this.selectUrl(this.url + path, this.getUrls());
				}
				return url + path;
			}
		}

	}
}
