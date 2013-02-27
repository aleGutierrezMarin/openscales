package org.openscales.core.layer.ogc
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.ProjProjection;
	
	public class GeoRSSTest
	{
		private var _instance:GeoRss;
		
		[Embed(source="/assets/georss/topp-tasmania_water_bodies.xml",mimeType="application/octet-stream")]
		private const GeoRSSFile:Class;
		
		public function GeoRSSTest()
		{
		}
		
		[Before]
		public function setUp():void{
			_instance = new GeoRss("instance");
		}
		
		[Test]
		public function shouldSetStyle():void{
			var s:Style = new Style(); 
			_instance.style = s;
			assertEquals("Setting style does not work", s, _instance.style);
		}
		
		[Test]
		public function shouldSetRefresh():void{
			_instance.refreshDelay = 5;
			assertEquals("Setting refresh does not work", 5, _instance.refreshDelay);
		}
		
		[Test]
		public function shouldSetPopUpWidth():void{
			_instance.popUpWidth = 500;
			assertEquals("Setting popup width does not work", 500, _instance.popUpWidth);
		}
		
		[Test]
		public function shouldSetPopUpHeight():void{
			_instance.popUpHeight = 500;
			assertEquals("Setting popup height does not work", 500, _instance.popUpHeight);
		}
		
		/*
		common layers tests
		*/
		[Test]
		public function shouldSetUrl():void{
			_instance.url = "myurl";
			assertEquals("Setting url does not work", "myurl", _instance.url);
		}
		
		[Test]
		public function shouldSetOriginators():void{
			var orig:Vector.<DataOriginator> = new Vector.<DataOriginator>();
			orig.push(new DataOriginator("orig1","url1","url1"));
			orig.push(new DataOriginator("orig2","url2","url2"));
			_instance.originators = orig;
			assertTrue("Orginiators setting does not work", _instance.originators == orig);
			assertEquals("Originators setting does not work", 2, _instance.originators.length);
		}
		
		[Test]
		public function shouldSetMaxExtentFromString():void{
			_instance.maxExtent="-4.0,30.0,10.5,60.0,WGS84";
			assertTrue("Setting max extent from Bounds failed", _instance.maxExtent.projection== _instance.projection);
		}
		
		[Test]
		public function shouldSetMaxExtentFromBounds():void{
			var bounds:Bounds = new Bounds(-4.0,30.0,10.5,60.0,"WGS84");
			_instance.maxExtent=bounds;
			assertTrue("Setting max extent from Bounds failed", _instance.maxExtent.projection == _instance.projection);
		}
		
		[Test] 
		public function shouldSetMinResolution():void{
			_instance.minResolution = new Resolution(5.0,"WGS84");
			assertEquals("Resolution value is not set properly",5.0,_instance.minResolution.value);
			assertEquals("Projection value is not set properly",_instance.projection,_instance.minResolution.projection);
		}
		
		[Test] 
		public function shouldSetMinResolutionWithLayerProjectionAsDefaultProjection():void{
			_instance.minResolution = new Resolution(5.0);
			assertEquals("Resolution value is not set properly",5.0,_instance.minResolution.value);
			assertEquals("Projection value is not set properly",_instance.projection,_instance.minResolution.projection);
		}
		
		[Test] 
		public function shouldSetMaxResolution():void{
			_instance.maxResolution = new Resolution(5.0,"WGS84");
			assertEquals("Resolution value is not set properly",5.0,_instance.maxResolution.value);
			assertEquals("Projection value is not set properly",_instance.projection,_instance.maxResolution.projection);
		}
		
		[Test] 
		public function shouldSetMaxResolutionWithLayerProjectionAsDefaultProjection():void{
			_instance.maxResolution = new Resolution(5.0);
			assertEquals("Resolution value is not set properly",5.0,_instance.maxResolution.value);
			assertEquals("Projection value is not set properly",_instance.projection,_instance.maxResolution.projection);
		}
		
		/**
		 * Validates that when you have a GeoRSS layer without features
		 * When you ask the maxExtent
		 * Then, the maxExtent is returned
		 */
		[Test]
		public function shouldHaveLayerMaxExtentIfNoFeatures():void
		{
			_instance.maxExtent = "-150,-20,160,10,EPSG:4326";
			var map:Map = new Map();
			map.addLayer(_instance);
			
			assertEquals("Wrong maxExtent left bounds", -150, _instance.maxExtent.left)
			assertEquals("Wrong maxExtent bottom bounds", -20, _instance.maxExtent.bottom)
			assertEquals("Wrong maxExtent right bounds", 160, _instance.maxExtent.right)
			assertEquals("Wrong maxExtent top bounds", 10, _instance.maxExtent.top)
			assertEquals("Wrong maxExtent bounds projection", ProjProjection.getProjProjection("WGS84"), _instance.maxExtent.projection)
		}
	}
}