package org.openscales.core.control
{
	import org.flexunit.Assert;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.originator.ConstraintOriginator;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class DataOriginatorsDisplayTest
	{		
		[Test]
		public function testDataoriginatorsInitialization():void 
		{
			// create map
			var _map:Map = new Map();
			_map.size = new Size(1200, 700);

			// add layers
			var mapnik:Mapnik = new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projection);		
			_map.addLayer(mapnik);
			
			// new originator for mapnik
			var url:String = "http://url_originator";
			var urlPicture:String = "http://url_picture_originator";
			var originator1:DataOriginator = new DataOriginator("originator", url, urlPicture);
			mapnik.addOriginator(originator1);
			
			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			cycle.proxy = "http://openscales.org/proxy.php?url=";
			_map.addLayer(cycle); 
			
			// same originator for cycleMap
			var originator2:DataOriginator = new DataOriginator("originator 2", url, urlPicture);
			cycle.addOriginator(originator2);
			
			var regions:WFS = new WFS("IGN - Geopla (Region)", "http://openscales.org/geoserver/wfs","pg:ign_geopla_region");
			regions.projection = "EPSG:2154";
			regions.style = Style.getDefaultSurfaceStyle();
			_map.addLayer(regions);
			
			// new originator for WFS
			var originator3:DataOriginator = new DataOriginator("originator 3", url, urlPicture);
			regions.addOriginator(originator3);
			
			// create DataOriginators controller
			var displayOriginators:DataOriginatorsDisplay = new DataOriginatorsDisplay();
			_map.addControl(displayOriginators);
			
			// search for the 3 originatorq in the list :
			var containsOriginator1:Boolean = false;
			var containsOriginator2:Boolean = false;
			var containsOriginator3:Boolean = false;
			
			var i:uint = 0;
			var j:uint = displayOriginators.dataOriginators.originators.length;
			for (; i<j; ++i) 
			{
				if (displayOriginators.dataOriginators.originators[i] == originator1) 
				{
					containsOriginator1 = true;
				}
				if (displayOriginators.dataOriginators.originators[i] == originator2) 
				{
					containsOriginator2 = true;
				}
				if (displayOriginators.dataOriginators.originators[i] == originator3) 
				{
					containsOriginator3 = true;
				}
			}
			Assert.assertTrue(containsOriginator1);
			Assert.assertTrue(containsOriginator2);
			Assert.assertTrue(containsOriginator3);
		}
	}
}