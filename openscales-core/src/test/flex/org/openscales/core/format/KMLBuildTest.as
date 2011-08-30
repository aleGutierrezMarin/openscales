package org.openscales.core.format
{
	import org.openscales.core.feature.Feature;

	public class KMLBuildTest
	{
		private var format:KMLFormat;
		private var url:String;
		
		[Embed(source="/assets/kml/PointsSample.xml",mimeType="application/octet-stream")]
		private const KMLPOINTS:Class;
		
		[Embed(source="/assets/kml/LinesSample.xml",mimeType="application/octet-stream")]
		private const KMLLINES:Class;
		
		[Embed(source="/assets/kml/PolySample.xml",mimeType="application/octet-stream")]
		private const KMLPOLY:Class;
		
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
		public function testBuildLines():void
		{			
			var file:XML = new XML(new KMLLINES());
			var features:Vector.<Feature> = this.format.read(file) as Vector.<Feature>;
			var buildedFile:XML = this.format.write(features) as XML;
			
		}
		
		[Test]
		public function testBuildPoly():void
		{			
			var file:XML = new XML(new KMLPOLY());
			var features:Vector.<Feature> = this.format.read(file) as Vector.<Feature>;
			var buildedFile:XML = this.format.write(features) as XML;
			
		}
		
		[Test]
		public function testBuildPoints():void
		{			
			//make this test with a real pointFeature that you create here
			var file:XML = new XML(new KMLPOINTS());
			var features:Vector.<Feature> = this.format.read(file) as Vector.<Feature>;
			var buildedFile:XML = this.format.write(features) as XML;
			
		}
	}
}