package org.openscales.core.format
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.layer.ogc.GPX;

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
		public function testParseCoords():void
		{
			var gpx:XML = new XML(new GPX10FILE());
			var features:Vector.<Feature> = this.format.parseGpxFile(gpx);
			var gpxNode:XML = this.format.buildGpxFile(features);

			
		}
		
	}
}