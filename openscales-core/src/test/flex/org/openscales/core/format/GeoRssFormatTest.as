package org.openscales.core.format
{
	import org.openscales.core.feature.Feature;

	public class GeoRssFormatTest
	{
		public function GeoRssFormatTest(){}
		
		private var format:GeoRssFormat;
		private var url:String;
		
		[Embed(source="/assets/format/GeoRss/geoRssSample1.xml",mimeType="application/octet-stream")]
		private const RSSFILE:Class;
		
		[Before]
		public function setUp():void
		{
			this.format = new GeoRssFormat();
		}
		
		[After] 
		public function tearDown():void
		{
			format = null;
		}
		
		[Test]
		public function testParseGpxFile():void
		{
			var rss:XML = new XML(new RSSFILE());
			var object:Vector.<Feature> = this.format.read(rss) as Vector.<Feature>;
		}
	}
}