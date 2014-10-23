package org.openscales.core.layer
{
	import org.openscales.core.layer.osm.OSM;
	
	public class Waze extends OSM
	{
		public function Waze( identifier:String )
		{
			// Hibrido ( transparencias )
			// http://etiles1.waze.com/wms/wme?PROJECTION=EPSG%3A900913&FORMAT=image%2Fpng&TRANSPARENT=TRUE&LAYERS=roads&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&SRS=EPSG%3A900913&BBOX=-5213652.6544066,-2562205.0176195,-5212358.0022402,-2560910.3654531&WIDTH=542&HEIGHT=542
			
			var url:String = "http://worldtiles1.waze.com/tiles/";
			super(identifier, url);
			
			this.altUrls = [ "http://worldtiles2.waze.com/tiles/",
				"http://worldtiles3.waze.com/tiles/",
				"http://worldtiles4.waze.com/tiles/" ];
			this.generateResolutions(18, OSM.DEFAULT_MAX_RESOLUTION);
		}
	}
}