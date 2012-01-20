package org.openscales.core.format.gml.parser
{
	
	import flash.xml.XMLNode;
	
	import flexunit.framework.Assert;
	
	import org.openscales.core.Map;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.layer.ogc.GML;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	public class GML321ParserTest
	{
		private var format:GML321;
		
		public function GML321ParserTest(){}
		
		[Before]
		public function setUp():void
		{
			format = new GML321();
		}
		
		[After] 
		public function tearDown():void
		{
			format = null;
		}
		
		[Test]
		public function testParseCoords():void
		{
			var xml:XML = <coords
			xmlns:gml="http://www.opengis.net/gml/3.2">
			<gml:posList>-88.071564 37.51099000000001 -88.087883 37.476273000000006 -88.311707 37.442852 -56.311707 22.442852</gml:posList>
			</coords>;
			var proj:ProjProjection = ProjProjection.getProjProjection("EPSG:4326");
			var xmlCoords:Vector.<Number> = new <Number>[-88.071564, 37.51099000000001, -88.087883, 37.476273000000006, -88.311707, 37.442852, -56.311707, 22.442852];
			format.dim = 2;
			var coords:Vector.<Number> = format.parseCoords(xml, proj);
			Assert.assertEquals("There should be 8 coordinates", 8, coords.length);
			
			for (var i:uint = 0; i<8; ++i )
			{
				Assert.assertEquals("The value should be "+xmlCoords[i],xmlCoords[i],coords[i]);
			}
			format.dim = 3;
			coords = format.parseCoords(xml, proj);
			Assert.assertNull("The vector should be null",coords);
			
			
		}
		
		[Test]
		public function testReadSimplePolygon():void
		{
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:states gml:id="states.1">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>-91.516129 36.986771000000005</gml:lowerCorner>
<gml:upperCorner>-87.507889 42.50936100000001</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<topp:the_geom>
<gml:MultiSurface srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:surfaceMember>
<gml:Polygon>
<gml:exterior>
<gml:LinearRing>
<gml:posList>-88.071564 37.51099000000001 -88.087883 37.476273000000006 -88.311707 37.442852</gml:posList>
</gml:LinearRing>
</gml:exterior>
</gml:Polygon>
</gml:surfaceMember>
</gml:MultiSurface>
</topp:the_geom>
</topp:states>
</wfs:member>;
			
			var feature:Feature = format.parseFeature(xml);
			Assert.assertNotNull("Feature should not be null!",feature);
			Assert.assertTrue("The feature should be a multi polygon feature",(feature is MultiPolygonFeature));
			Assert.assertEquals("The id of the feature is incorrect","states.1",feature.name);
			Assert.assertEquals("The projection of the feature should be epsg:4326",ProjProjection.getProjProjection("EPSG:4326").srsCode,feature.geometry.projection.srsCode);
			var mp:MultiPolygon = (feature as MultiPolygonFeature).polygons;
			Assert.assertEquals("There should be only one component in the multi polygon!", 1, mp.componentsLength);
			Assert.assertTrue("The component should be a Polygon", (mp.getcomponentsClone()[0] is Polygon));
			var pol:Polygon = mp.getcomponentsClone()[0] as Polygon;
			Assert.assertEquals("There should be only one component in the polygon!", 1, pol.componentsLength);
			Assert.assertTrue("The component should be a LinearRing", (pol.getcomponentsClone()[0] is LinearRing));
			var lr:LinearRing = (pol.getcomponentsClone()[0] as LinearRing);
			Assert.assertEquals("The Linear ring should have 3 points", 3, lr.componentsLength);
		}
		
		[Test]
		public function testReadComplexPolygon1():void
		{
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:states gml:id="states.1">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>-91.516129 36.986771000000005</gml:lowerCorner>
<gml:upperCorner>-87.507889 42.50936100000001</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<topp:the_geom>
<gml:MultiSurface srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:surfaceMember>
	<gml:Polygon>
<gml:exterior>
<gml:LinearRing>
<gml:posList>-88.071564 37.51099000000001 -88.087883 37.476273000000006 -88.311707 37.442852</gml:posList>
</gml:LinearRing>
</gml:exterior>
<gml:interior>
<gml:LinearRing>
<gml:posList>-28.071564 27.51099000000001 -58.087883 17.476273000000006</gml:posList>
</gml:LinearRing>
</gml:interior>				
	</gml:Polygon>
</gml:surfaceMember>
<gml:surfaceMember>				
	<gml:Polygon>
<gml:exterior>
<gml:LinearRing>
<gml:posList>-28.071564 27.51099000000001 -58.087883 17.476273000000006</gml:posList>
</gml:LinearRing>
</gml:exterior>			
	</gml:Polygon>
</gml:surfaceMember>
</gml:MultiSurface>
</topp:the_geom>
</topp:states>
</wfs:member>;
			
			var feature:Feature = format.parseFeature(xml);	
			var mpf:MultiPolygonFeature = feature as MultiPolygonFeature;
			Assert.assertNotNull("MultiPolygonFeature should not be null",mpf);
			var mp:MultiPolygon = mpf.polygons;
			Assert.assertNotNull("MultiPolygon should not be null",mp);
			Assert.assertEquals("There should be 2 components in this feature", 2, mp.componentsLength);
			Assert.assertNotNull("The first Polygon should not be null",  mp.getcomponentsClone()[0]);
			Assert.assertTrue("This component should be a polygon",mp.getcomponentsClone()[0] is Polygon );
			
			var polygonOne:Polygon = mp.getcomponentsClone()[0] as Polygon;
			Assert.assertNotNull("The first LinearRing should not be null", polygonOne.getcomponentsClone()[0]);
			Assert.assertTrue("This component should be a LinearRing", polygonOne.getcomponentsClone()[0] is LinearRing);
			
			var linearRingOne:LinearRing = polygonOne.getcomponentsClone()[0] as LinearRing;
			Assert.assertEquals("There should be 3 Points in the exterior LinearRing",3, linearRingOne.componentsLength);
			
			Assert.assertNotNull("The second LinearRing should not be null",polygonOne.getcomponentsClone()[1]);
			Assert.assertTrue("This component should be a LinearRing", polygonOne.getcomponentsClone()[1] is LinearRing);
			
			var linearRingTwo:LinearRing = polygonOne.getcomponentsClone()[1] as LinearRing;
			Assert.assertEquals("There should be 2 Points in the interior LinearRing",2,linearRingTwo.componentsLength);
			
		}		
		
		[Test]
		public function testReadComplexPolygon2():void {
			// tests the order of the interior/exterior LinearRings 
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:states gml:id="states.1"> 
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>-58 17</gml:lowerCorner>
<gml:upperCorner>-28 27</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<topp:the_geom>
<gml:MultiSurface srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:surfaceMember>
<gml:Polygon>
<gml:interior>
<gml:LinearRing>
<gml:posList>-28 27 -58 17</gml:posList>
</gml:LinearRing>
</gml:interior>
<gml:exterior>
<gml:LinearRing>
<gml:posList>-28 27 -58 17 -58 17</gml:posList>				
</gml:LinearRing>
</gml:exterior>			
</gml:Polygon>
</gml:surfaceMember>
</gml:MultiSurface>
</topp:the_geom>
</topp:states>
</wfs:member>;
			
			var n:Namespace =  new Namespace('topp','http://topp.example');
			var feature:Feature = format.parseFeature(xml);	
			var mpf:MultiPolygonFeature = feature as MultiPolygonFeature;	
			var mp:MultiPolygon = mpf.polygons;
			var polygon:Polygon = mp.getcomponentsClone()[0] as Polygon;
			var exteriorRing:LinearRing = polygon.getcomponentsClone()[0] as LinearRing;
			Assert.assertEquals("The exterior ring should contain 3 Points",3, exteriorRing.componentsLength);
			var interiorRing:LinearRing = polygon.getcomponentsClone()[1] as LinearRing;
			Assert.assertEquals("The interior ring should contain 2 Points",2,interiorRing.componentsLength);
			
			
		}
		
		[Test]
		public function testReadLineString():void{
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:states gml:id="states.1">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>-73 40</gml:lowerCorner>
<gml:upperCorner>-10 42</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<topp:the_geom>
<gml:LineString srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:posList>-10 40 -73 42</gml:posList>
</gml:LineString>
</topp:the_geom>
</topp:states>
</wfs:member>;		
			
			var feature:Feature = format.parseFeature(xml);	
			var lsf:LineStringFeature = feature as LineStringFeature;
			Assert.assertNotNull("The LineStringFeature should not be null", lsf);
			Assert.assertTrue("This feature should be a LineStringFeature", lsf is LineStringFeature);
			Assert.assertTrue("This component should be a LineString", lsf.lineString);
			var ls:LineString = lsf.lineString;
			Assert.assertEquals("The length of the LineString should be 63.0317380372777", 63.0317380372777, ls.length);
			
		}
		
		[Test]
		public function testReadPoint():void{
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:states gml:id="states.1">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>-74.0108375113659 40.70754683896324</gml:lowerCorner>
<gml:upperCorner>-74.0108375113659 40.70754683896324</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<topp:the_geom>
<gml:Point srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:pos>-74.0108375113659 40.70754683896324</gml:pos>
</gml:Point>
</topp:the_geom>
</topp:states>
</wfs:member>;		
			
			var feature:Feature = format.parseFeature(xml);	
			Assert.assertTrue("This feature should be a PointFeature", feature is PointFeature);
			var pf:PointFeature = feature as PointFeature;
			Assert.assertNotNull("The PointFeature should not be null", pf);
			Assert.assertTrue("This component should be a Point", pf.point is Point);
			var p:Point = pf.point;
			Assert.assertEquals("The first coordinate is incorrect",-74.0108375113659, p.x );
			Assert.assertEquals("The second coordinate is incorrect",40.70754683896324, p.y );
			
		}
	}
	
}