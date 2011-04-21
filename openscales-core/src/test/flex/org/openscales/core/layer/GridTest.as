package org.openscales.core.layer
{
	import flashx.textLayout.tlf_internal;
	
	import org.flexunit.Assert;
	import org.openscales.core.Map;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.ns.os_internal;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Size;
	
	use namespace os_internal;
	
	public class GridTest
	{
		
		/**
		 * Test if when we add a layers that is not with the same projection as the one of the BaseMap
		 * the two grids have the same origin.
		 */
		[Test]
		public function testGridOriginMatching():void{
			
			var map:Map = new Map();
			map.size = new Size(1200, 700);
			var mapnik:Mapnik = new Mapnik("Mapnik");
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			map.addLayer(mapnik);
			
			var geoServer:WMSC = new WMSC("geoServer", "http://openscales.org/geoserver/gwc/service/wms", "bluemarble");
			geoServer.maxExtent = new Bounds(-180,-90,180,90,geoServer.projSrsCode);
			map.addLayer(geoServer);
			
			var testBounds:Bounds = new Bounds(-180,-90,180,90,geoServer.projSrsCode);
			var testBounds2:Bounds = mapnik.maxExtent.reprojectTo(geoServer.projSrsCode);
			
			Assert.assertEquals(geoServer.getoriginPixel(), mapnik.getoriginPixel());
		}
		
		/**
		 * Test if when we add a layers that is not with the same projection as the one of the BaseMap
		 * two tiles have the same size.
		 */
		[Test]
		public function testTileResize():void{
			
			var map:Map = new Map();
			map.size = new Size(1200, 700);
			var mapnik:Mapnik = new Mapnik("Mapnik");
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			map.addLayer(mapnik);
			
			var geoServer:WMSC = new WMSC("geoServer", "http://openscales.org/geoserver/gwc/service/wms", "bluemarble");
			geoServer.maxExtent = new Bounds(-180,-90,180,90,geoServer.projSrsCode);
			map.addLayer(geoServer);
			
			Assert.assertEquals(mapnik.grid[0][0].width, geoServer.grid[0][0].width);
			Assert.assertEquals(mapnik.grid[0][0].height, geoServer.grid[0][0].height);
			
		}
		
		/**
		 * Test if when we add a layers that is not with the same projection as the one of the BaseMap
		 * two tiles have the same position.
		 */
		[Test]
		public function testTilePosition():void{
			
			var map:Map = new Map();
			map.size = new Size(1200, 700);
			var mapnik:Mapnik = new Mapnik("Mapnik");
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			map.addLayer(mapnik);
			
			var geoServer:WMSC = new WMSC("geoServer", "http://openscales.org/geoserver/gwc/service/wms", "bluemarble");
			geoServer.maxExtent = new Bounds(-180,-90,180,90,geoServer.projSrsCode);
			map.addLayer(geoServer);
			
			Assert.assertEquals(mapnik.grid[0][0].x, geoServer.grid[0][0].x);
			Assert.assertEquals(mapnik.grid[0][0].y, geoServer.grid[0][0].y);
			
		}
	}
}