package org.openscales.core.format
{
	import org.openscales.core.feature.Feature;

	public class GPXFormatTest
	{
		
		private var format:GPXFormat;
		
		[Embed(source="/assets/format/GpxExample.xml",mimeType="application/octet-stream")]
		private const GPXFILE:Class;
		
		[Before]
		public function setUp():void
		{
			this.format = new GPXFormat(null);
		}
		
		[After] 
		public function tearDown():void
		{
			format = null;
		}
		
		[Test]
		public function testParseCoords():void
		{
			var gpx:XML = new XML(new GPXFILE());
			var features:Vector.<Feature> = this.format.parseGpxFile(gpx);
			
			
		}
		
	}
}