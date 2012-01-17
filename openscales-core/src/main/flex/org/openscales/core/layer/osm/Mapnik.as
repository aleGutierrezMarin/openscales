package org.openscales.core.layer.osm
{
	import org.openscales.core.utils.Util;

	/**
	 * Mapnik OpenStreetMap layer
	 *
	 * More informations on
	 * http://wiki.openstreetmap.org/index.php/Mapnik
	 */
	public class Mapnik extends OSM
	{
		public function Mapnik(identifier:String,displayedName:String=null)
		{
			var url:String = "http://a.tile.openstreetmap.org/";
			super(identifier, displayedName, url);

			this.altUrls = [ "http://b.tile.openstreetmap.org/",
							 "http://c.tile.openstreetmap.org/" ];
			this.generateResolutions(18, OSM.DEFAULT_MAX_RESOLUTION);
		}

	}
}

