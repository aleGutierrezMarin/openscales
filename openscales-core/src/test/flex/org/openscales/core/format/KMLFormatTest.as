package org.openscales.core.format
{
	
	import flash.utils.ByteArray;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertNull;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;

	/**
	 * Used some tips detailed on http://dispatchevent.org/roger/embed-almost-anything-in-your-swf/ to load XML
	 */
	public class KMLFormatTest {
		
		[Embed(source="/assets/kml/sample1.kml", mimeType="application/octet-stream")]
		protected const Sample1KML:Class;
		
		[Embed(source="/assets/kml/sample2.kml", mimeType="application/octet-stream")]
		protected const Sample2KML:Class;

		// sample with linestring
		[Embed(source="/assets/kml/sample3.kml", mimeType="application/octet-stream")]
		protected const Sample3KML:Class;
		
		// sample with multiGeometry
		[Embed(source="/assets/kml/MultiGeomSample.xml", mimeType="application/octet-stream")]
		protected const Sample4KML:Class;
		
		public function KMLFormatTest() {}
		
		protected function sample1KML():XML {
			var ba : ByteArray = (new Sample1KML()) as ByteArray;
			return new XML(ba.readUTFBytes( ba.length ));
		}
		
		protected function sample2KML():XML {
			var ba : ByteArray = (new Sample2KML()) as ByteArray;
			return new XML(ba.readUTFBytes( ba.length ));
		}
		
		protected function sample3KML():XML {
			var ba : ByteArray = (new Sample3KML()) as ByteArray;
			return new XML(ba.readUTFBytes( ba.length ));
		}
		
		[Test]
		public function testReadSample1KML( ) : void {
			var kmlFormat:KMLFormat = new KMLFormat();
			var features:Vector.<Feature> = kmlFormat.read(this.sample1KML()) as Vector.<Feature>;
			
			Assert.assertEquals(1, features.length);
			var firstFeature:PointFeature = features[0] as PointFeature;
			Assert.assertNotNull(firstFeature);
			Assert.assertEquals(0.5777064, firstFeature.point.x);
			Assert.assertEquals(44.83799619999999, firstFeature.point.y);
			
			Assert.assertEquals("Bordeaux", firstFeature.attributes["name"]);
			Assert.assertEquals("Where I was born", firstFeature.attributes["description"]);
			Assert.assertEquals("15/06/1981", firstFeature.attributes["Date"]);
			Assert.assertEquals("France", firstFeature.attributes["Pays"]);
		}
		
		[Test]
		public function testReadSample2KML( ) : void {
			var kmlFormat:KMLFormat = new KMLFormat();
			var features:Vector.<Feature> = kmlFormat.read(this.sample2KML()) as Vector.<Feature>;
			
			Assert.assertEquals(1, features.length);
			var firstFeature:PointFeature = features[0] as PointFeature;
			Assert.assertNotNull(firstFeature);
			Assert.assertEquals(-122.0822035425683, firstFeature.point.x);
			Assert.assertEquals(37.42228990140251, firstFeature.point.y);
			
			Assert.assertEquals("Simple placemark", firstFeature.attributes["name"]);
		}
		
		[Test]
		public function testReadSample3KML( ) : void {
			var kmlFormat:KMLFormat = new KMLFormat();
			var features:Vector.<Feature> = kmlFormat.read(this.sample3KML()) as Vector.<Feature>;

			Assert.assertEquals(1, features.length);
			var firstFeature:LineStringFeature = features[0] as LineStringFeature;
			Assert.assertNotNull(firstFeature);
			Assert.assertEquals(46,firstFeature.lineString.componentsLength);
			
			Assert.assertEquals("LineStringTests", firstFeature.attributes["name"]);
		}
		
		[Test]
		public function testReadWithNullParamater():void{
			var kmlFormat:KMLFormat = new KMLFormat();
			var features:Object = kmlFormat.read(null);
			assertNull("When given a null parameter, read() should return null",features);
		}
		
		[Test]
		public function testReadWithNotXMLParamater():void{
			var kmlFormat:KMLFormat = new KMLFormat();
			var features:Object = kmlFormat.read(new Object());
			assertNull("When given a non XML parameter, read() should return null",features);
		}
		
		[Test]
		public function testParseMultiGeometry( ) : void {
			var kmlFormat:KMLFormat = new KMLFormat();
			var file:XML = new XML(new Sample4KML());
			var i:uint;
			//7 multipolygons and 7 multipoints inside this file because multiPoly are parsed first
			
			var features:Vector.<Feature> = kmlFormat.read(file) as Vector.<Feature>;
			Assert.assertEquals("There should be 14 features inside this list",14,features.length);
			for (i = 0; i < 7; i++)
			{
				Assert.assertTrue("This feature should be a multiPolygonFeature", features[i] is MultiPolygonFeature);
			}
			
			for (i = 7; i < 14; i++)
			{
				Assert.assertTrue("This feature should be a multiPointFeature", features[i] is MultiPointFeature);
			}
			//check the style of the first polygon
			
			var style:Style = features[0].style;
			var rule:Rule = style.rules[0];
			//2 symbolyzers inside, the first for the fill of the poly
			var polySym:Symbolizer = rule.symbolizers[0];
			var fill:SolidFill = (polySym as PolygonSymbolizer).fill as SolidFill;
			Assert.assertEquals("The color of the first polygon should be 1010687",1010687,fill.color);
		}
	}

}


