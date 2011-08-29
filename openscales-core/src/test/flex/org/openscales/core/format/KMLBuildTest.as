package org.openscales.core.format
{
	import org.openscales.core.feature.Feature;

	public class KMLBuildTest
	{
		private var format:KMLFormat;
		private var url:String;
		
		[Embed(source="/assets/kml/sample3.kml",mimeType="application/octet-stream")]
		private const KMLFILE:Class;
		
		public function KMLBuildTest(){}
		
		[Before]
		public function setUp():void
		{
			this.format = new KMLFormat();
			this.url = "http://www.parisavelo.net/velib.kml";
		}
		
		[After] 
		public function tearDown():void
		{
			this.format = null;
			this.url = null;
		}
		
		[Test]
		public function testBuildKMLFile():void
		{			
			var file:XML = new XML(new KMLFILE());
			var features:Vector.<Feature> = this.format.read(file) as Vector.<Feature>;
			var buildedFile:XML = this.format.write(features) as XML;
			
		}
	}
}