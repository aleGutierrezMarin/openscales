package org.openscales.core.format
{
	import flexunit.framework.Assert;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;

	public class GeoRssFormatTest
	{
		public function GeoRssFormatTest(){}
		
		private var format:GeoRssFormat;
		private var url:String;
		
		[Embed(source="/assets/format/GeoRss/geoRssSample1.xml",mimeType="application/octet-stream")]
		private const RSSFILE1:Class;
		
		[Embed(source="/assets/format/GeoRss/geoRssSample2.xml",mimeType="application/octet-stream")]
		private const RSSFILE2:Class;
		
		
		[Embed(source="/assets/format/GeoRss/geoRssSample3.xml",mimeType="application/octet-stream")]
		private const RSSFILE3:Class;
		
		[Before]
		public function setUp():void
		{
			this.format = new GeoRssFormat(new HashMap());
		}
		
		[After] 
		public function tearDown():void
		{
			format = null;
		}
		
		[Test]
		public function testParseAndBuildPolygons():void
		{
			var i:uint;
			var rss:XML = new XML(new RSSFILE1());
			var features:Vector.<Feature> = this.format.read(rss) as Vector.<Feature>;
			Assert.assertEquals("The tile of this RSS file should be 'sf:restricted'","sf:restricted",this.format.title);
			Assert.assertEquals("The link of this RSS file is incorrect",
			"http://openscales.org:80/geoserver/sf/wms?height=512&bbox=591579.1858092896%2C4916236.662227167%2C599648.9251686076%2C4925872.146218054&width=428&layers=sf%3Arestricted&request=GetMap&service=wms&styles=restricted&srs=EPSG%3A26713&format=application%2Frss+xml&transparent=false&version=1.1.1",
			this.format.link);
			
			Assert.assertEquals("There should be 4 polygons inside",4,features.length);
			for(i = 0; i < 4; i++){
				Assert.assertTrue("This element should be a polygon feature", features[i] is PolygonFeature);
				var id:String = "restricted."+String(i+1);
				Assert.assertEquals("The id of this feature is incorrect",id, features[i].name);
			}
			
			/**
			 * test the build
			 */ 
			this.format.title = "Polygons";
			this.format.description = "This RSS files contains 4 geometries";
			var rssFile:XML = this.format.write(features) as XML;
			var polyNodes:XMLList = rssFile..*::polygon;
			var itemNodes:XMLList = rssFile..*::item;
			Assert.assertEquals("There should be 4 polygons in this file",4,polyNodes.length());
			Assert.assertEquals("There should be 4 items in this file",4,itemNodes.length());
			for(i = 0; i < 4; i++){
				var itemNode:XML = itemNodes[i];
				var idNode:XML = itemNode..*::guid[0];
				Assert.assertEquals("The id of this feature is incorrect","restricted."+String(i+1), idNode.toString());
			}
			
		}
		
		[Test]
		public function testParseAndBuildLines():void
		{
			var i:uint;
			var rss:XML = new XML(new RSSFILE2());
			var features:Vector.<Feature> = this.format.read(rss) as Vector.<Feature>;
			Assert.assertEquals("The tile of this RSS file should be 'topp:tasmania_roads'","topp:tasmania_roads",this.format.title);
			Assert.assertEquals("The link of this RSS file is incorrect",
			"http://openscales.org:80/geoserver/topp/wms?height=427&bbox=145.19754%2C-43.423512%2C148.27298000000002%2C-40.852802&width=512&layers=topp%3Atasmania_roads&request=GetMap&service=wms&styles=simple_roads&srs=EPSG%3A4326&format=application%2Frss+xml&transparent=false&version=1.1.1",
			this.format.link);
			
			Assert.assertEquals("There should be 16 lines inside",16,features.length);
			for(i = 0; i < 16; i++){
				Assert.assertTrue("This element should be a LineString feature", features[i] is LineStringFeature);
				var id:String = "tasmania_roads."+String(i+1);
				Assert.assertEquals("The id of this feature is incorrect",id, features[i].name);
			}	
			/**
			 * test the build
			 */ 
			var xmlFile:XML = this.format.write(features) as XML;
			
		}
		
		[Test]
		public function testParseGmlContent():void
		{
			var i:uint;
			var rss:XML = new XML(new RSSFILE3());
			var features:Vector.<Feature> = this.format.read(rss) as Vector.<Feature>;
			Assert.assertEquals("The tile of this RSS file should be 'Earthquakes'","Earthquakes",this.format.title);
			Assert.assertEquals("The link of this RSS file is incorrect",
			"http://serverName.net",
			this.format.link);
			
			Assert.assertEquals("There should be 3 geometries inside",3,features.length);
			
			Assert.assertTrue("This element should be a Point feature", features[0] is PointFeature);
			Assert.assertEquals("The id of this feature is incorrect","Point001", features[i].name);
			Assert.assertTrue("This element should be a LineString feature", features[1] is LineStringFeature);
			Assert.assertTrue("This element should be a Polygon feature", features[2] is PolygonFeature);
			
		}
	}
}