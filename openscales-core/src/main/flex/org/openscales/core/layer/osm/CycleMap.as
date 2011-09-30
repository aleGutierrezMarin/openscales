package org.openscales.core.layer.osm
{
	import org.openscales.core.utils.Util;

	/**
	 * CycleMap OpenStreetMap layer
	 *
	 * More informations on
	 * http://www.gravitystorm.co.uk/shine/cycle-info/
	 */
	public class CycleMap extends OSM
	{
		public function CycleMap(name:String)
		{
			var url:String = "http://a.tile.opencyclemap.org/cycle/";

			var alturls:Array = ["http://b.tile.opencyclemap.org/cycle/",
								 "http://c.tile.opencyclemap.org/cycle/"];

			super(name, url);

			this.altUrls = alturls;

			this.generateResolutions(17, OSM.DEFAULT_MAX_RESOLUTION);
		}
	}
}

