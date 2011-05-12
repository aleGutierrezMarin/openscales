package org.openscales.core.control
{
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.openscales.core.Map;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.security.ign.IGNGeoRMSecurity;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	public class OverviewMapRatioTest
	{
		
		[Test]
		public function positionTest():void
		{
			var position:Pixel = new Pixel (200,300);
			var overview:OverviewMapRatio = new OverviewMapRatio(position);
			assertEquals(position.x, overview.position.x);
			assertEquals(position.y, overview.position.y);
			
		}
		
		[Test]
		public function centerTest():void
		{
			var _map:Map = new Map();
			_map.size=new Size(1200, 700);
			
			// Main map creation
			var IGN:WMSC = new WMSC("OrthoPhoto", "http://wxs.ign.fr/geoportail/wmsc", "ORTHOIMAGERY.ORTHOPHOTOS");
			IGN.projection = "IGNF:GEOPORTALFXX";
			var resoArray:Array = new Array(39135.75,19567.875,9783.9375,4891.96875,2445.984375,2048,1024,512,256,128,64,32,16,8,4,2,1,0.5,0.25,0.125,0.0625);
			IGN.resolutions = resoArray;
			IGN.minZoomLevel = 5;
			IGN.maxZoomLevel = 17;
			IGN.method = "POST";
			IGN.version ="1.1.1";
			
			IGN.maxExtent = new Bounds(-1048576,3670016,2097152,6815744, "IGNF:GEOPORTALFXX");
			var securityIGN:IGNGeoRMSecurity = new IGNGeoRMSecurity(_map, "1905042184761803857", "http://www.openscales.org/proxy.php?url=", "http://jeton-api.ign.fr", "POST");
			IGN.security = securityIGN;
			_map.addLayer(IGN);
			
			
			// Overview map Creation
			var mapnik:Mapnik=new Mapnik("Mapnik");
			mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);
			
			var position:Pixel = new Pixel(100, 100);
			var overview:OverviewMapRatio = new OverviewMapRatio(position, mapnik);
			overview.ratio = 4;
			overview.map = _map;
			overview.size = new Size(200, 200);
			
			assertEquals(overview.map.center.reprojectTo(_map.baseLayer.projSrsCode), _map.center);
		}
	}
}