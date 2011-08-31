package org.openscales.core.format
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.geometry.Point;

	public class KMLBuildTest
	{
		private var format:KMLFormat;
		private var url:String;
		
		[Embed(source="/assets/kml/GlobalSample.xml",mimeType="application/octet-stream")]
		private const KMLGLOBAL:Class;
		
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
			var style:Style = new Style();
			var rule:Rule = new Rule();
			var stroke:Stroke = new Stroke();
			var fill:SolidFill = new SolidFill(9872929,0.23);
			var sym:PointSymbolizer = new PointSymbolizer(new WellKnownMarker("square",fill,stroke,0.23));
			rule.symbolizers.push(sym);
			style.rules.push(rule);
			
			var pointF:PointFeature = new PointFeature(new Point(42.4555,2.559999901),null,style);
			var features:Vector.<Feature> = new Vector.<Feature>();
			features.push(pointF);
			var buildedFile:XML = this.format.write(features) as XML;
			
		}
		
		[Test]
		public function testGlobalBuild():void
		{			
			var file:XML = new XML(new KMLGLOBAL());
			var features:Vector.<Feature> = this.format.read(file) as Vector.<Feature>;
			var buildedFile:XML = this.format.write(features) as XML;
			
		}
	}
}