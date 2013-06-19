package org.openscales.core.layer.ogc
{
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.ProjProjection;
	
	public class GPXTest
	{
		[Embed(source="/assets/gpx/Gpx11Example.xml",mimeType="application/octet-stream")]
		private const GPX11FILE:Class;
		
		[Embed(source="/assets/gpx/Gpx10Example.xml",mimeType="application/octet-stream")]
		private const GPX10FILE:Class;
		
		private var gpx10:XML;
		private var gpx11:XML;
		private var _instance:GPX;
		
		public function GPXTest(){}
		
		
		[Before]
		public function setUp():void
		{
			this.gpx10 = new XML(new GPX10FILE());
			this.gpx11 = new XML(new GPX11FILE());
			_instance = new GPX("instance");
		}
		
		[After]
		public function tearDown():void
		{}
		
		/**
		 * Validates that all the features are retrieved from the gpx file 
		 * 
		 */
		
		[Test]
		public function testGPX10Layer():void
		{
			var i:uint;
			var layer:GPX = new GPX("layer", "1.0",null, this.gpx10);
			var map:Map = new Map();
			map.addLayer(layer);
			var features:Vector.<Feature> = layer.features;		
			
			//there are 7 features in the gpx file but two of them have the same name
			//so the last point will not be added to the list because 
			//adding two features with identical IDs is not allowed
			//total of features: 4 points and 2 multiLineStrings
			
			Assert.assertEquals("There should be 6 valid features in this vector",6, features.length);
			for (i = 0; i < 4; i++)
				Assert.assertTrue("The first 4 components should be PointFeatures", features[i] is PointFeature);
			for(i = 4; i < 6; i++)
				Assert.assertTrue("The last 2 components should be MultiLineStringFeatures", features[i] is MultiLineStringFeature);
			
			
			var multiLine:MultiLineString = (features[4] as MultiLineStringFeature).lineStrings;
			var line:Vector.<Geometry> = multiLine.getcomponentsClone();
			
			Assert.assertEquals("There should be one lineString in the first multiLine", 1, line.length);
			var onlyLine:LineString = line[0] as LineString;
			var points:Vector.<Point> = onlyLine.toVertices();
			
			Assert.assertEquals("There should be 11 points in this lineString",11, points.length);
			
		}
		
		/*
		common layers tests
		*/
		[Test]
		public function shouldSetUrl():void{
			_instance.url = "myurl";
			assertEquals("Setting url does not work", "myurl", _instance.url);
		}
		
		/**
		 * Validates that when you have a GPX layer without features
		 * When you ask the maxExtent
		 * Then, the maxExtent is returned
		 */
		[Test]
		public function shouldHaveLayerMaxExtentIfNoFeatures():void
		{
			var layer:GPX = new GPX("layer", "1.0");
			layer.maxExtent = "-150,-20,160,10,EPSG:4326";
			var map:Map = new Map();
			map.addLayer(layer);
			
			assertEquals("Wrong maxExtent left bounds", -150, layer.maxExtent.left)
			assertEquals("Wrong maxExtent bottom bounds", -20, layer.maxExtent.bottom)
			assertEquals("Wrong maxExtent right bounds", 160, layer.maxExtent.right)
			assertEquals("Wrong maxExtent top bounds", 10, layer.maxExtent.top)
			assertEquals("Wrong maxExtent bounds projection", ProjProjection.getProjProjection("EPSG:4326"), layer.maxExtent.projection)
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
	}
}