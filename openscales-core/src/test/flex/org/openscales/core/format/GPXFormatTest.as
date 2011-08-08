package org.openscales.core.format
{
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.layer.ogc.GPX;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.Point;
	
	import spark.primitives.Line;

	public class GPXFormatTest
	{
		
		private var format:GPXFormat;
		private var gpxLayer:GPX;
		private var url:String;
		
		[Embed(source="/assets/format/Gpx11Example.xml",mimeType="application/octet-stream")]
		private const GPX11FILE:Class;
		
		[Embed(source="/assets/format/Gpx10Example.xml",mimeType="application/octet-stream")]
		private const GPX10FILE:Class;
		
		[Before]
		public function setUp():void
		{
			url = "http://openscales.org/assets/sample.gpx"; 
			this.format = new GPXFormat(new HashMap());
		}
		
		[After] 
		public function tearDown():void
		{
			format = null;
		}
		
		[Test]
		public function testParseGpxFile():void
		{
			var i:uint;
			var gpx:XML = new XML(new GPX10FILE());
			var features:Vector.<Feature> = this.format.parseGpxFile(gpx);
			
			//there are 7 features in the gpx file but two of them have the same name
			//so the last point will not be added to the list because 
			//adding two features with identical IDs is not allowed
			//total of features: 4 points and 2 multiLineStrings
			
			Assert.assertEquals("There should be 6 valid features in this vector",6, features.length);
			for (i = 0; i < 4; i++)
				Assert.assertTrue("The first 4 components should be PointFeatures", features[i] is PointFeature);
			for(i = 4; i < 6; i++)
				Assert.assertTrue("The last two components should be MultiLineStringFeatures", features[i] is MultiLineStringFeature);
			
			var multiLine:MultiLineString = (features[4] as MultiLineStringFeature).lineStrings;
			var line:Vector.<Geometry> = multiLine.getcomponentsClone();
	
			Assert.assertEquals("There should be one lineString in the first multiLine", 1, line.length);
			var onlyLine:LineString = line[0] as LineString;
			var points:Vector.<Point> = onlyLine.toVertices();
			
			Assert.assertEquals("There should be 11 points in this lineString",11, points.length);
		
			var gpxNode:XML = this.format.buildGpxFile(features);

			Assert.assertEquals("The abscissa of the 10th Point should be 43.801739", 43.801739, points[9].x);
			Assert.assertEquals("The ordinate of the 10th Point should be -116.079333", -116.079333, points[9].y);
		}
		
	}
}