package org.openscales.core.layer
{
	import org.openscales.core.layer.osm.OSM;
	
	public class MapQuest extends OSM
	{
		public function MapQuest( identifier:String, layer:String = "map")
		{
		
			// Layers: map, hyb and sat
			
			var url:String = "http://ttiles01.mqcdn.com/tiles/1.0.0/vx/"+layer+"/";
			super(identifier, null);
			
			this.altUrls = [ 
				"http://ttiles02.mqcdn.com/tiles/1.0.0/vx/"+layer+"/",
				"http://ttiles03.mqcdn.com/tiles/1.0.0/vx/"+layer+"/",
				"http://ttiles04.mqcdn.com/tiles/1.0.0/vx/"+layer+"/"
			];
			
			this.generateResolutions(18, OSM.DEFAULT_MAX_RESOLUTION);
		}
	}
}