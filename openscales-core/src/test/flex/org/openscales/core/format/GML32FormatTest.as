package org.openscales.core.format
{
	import com.gskinner.motion.easing.Linear;
	
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
	
	public class GML32FormatTest
	{
		private var format:GML32Format;
		[Embed(source="/assets/GMLtest.xml",mimeType="application/octet-stream")]
		private const GMLFILE:Class;
		
		[Before]
		public function setUp():void
		{
			format = new GML32Format(null,null);
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
			var xmlCoords:Vector.<Number> = new <Number>[-88.071564, 37.51099000000001, -88.087883, 37.476273000000006, -88.311707, 37.442852, -56.311707, 22.442852];
			var coords:Vector.<Number> = format.parseCoords(xml,2);
			Assert.assertEquals("There should be 8 coordinates", 8, coords.length);
			
			for (var i:uint = 0; i<8; ++i )
			{
				Assert.assertEquals("The value should be "+xmlCoords[i],xmlCoords[i],coords[i]);
			}
			
			coords = format.parseCoords(xml,3);
			Assert.assertNull("The length of the vector should be null",coords);
			
		
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
			Assert.assertEquals("The projection of the feature should be epsg:4326","EPSG:4326",feature.geometry.projSrsCode);
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
		
		
			
		[Test]
		public function TestBuildPointNode():void{
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
			var pf:PointFeature = feature as PointFeature;
			var ns:String = "topp=\"http://www.openplans.org/topp\"";
			var featureType:String = "states";
			var geometryName:String = "the_geom";
			
     		var xmlNode:XML = format.buildFeatureNode(feature, ns, featureType, geometryName);
				
		}
		
		[Test]
		public function TestBuildLineStringNode():void{
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
			var ns:String = "topp=\"http://www.openplans.org/topp\"";
			var featureType:String = "states";
			var geometryName:String = "the_geom";
			
			var xmlNode:XML = format.buildFeatureNode(feature, ns, featureType, geometryName);
			
		}
		
		[Test]
		public function TestBuildMultiLineStringNode():void{
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:states gml:id="states.1">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>-442.145 19.099</gml:lowerCorner>
<gml:upperCorner>24 122</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<topp:the_geom>
<gml:MultiCurve srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:curveMember>			
<gml:LineString>
<gml:posList>-102 22 -442.145 19.099</gml:posList>		
</gml:LineString>
</gml:curveMember>
<gml:curveMember>			
<gml:LineString>
<gml:posList>24 122 -15.222 19.099</gml:posList>		
</gml:LineString>
</gml:curveMember>				
</gml:MultiCurve>
</topp:the_geom>
</topp:states>
</wfs:member>;			
			/* tests readMultiLineString (MultiCurve) */
			var feature:Feature = format.parseFeature(xml);	
			Assert.assertTrue("this should be a multiLineString object", feature is MultiLineStringFeature);
			var mlsf:MultiLineStringFeature = feature as MultiLineStringFeature;
			Assert.assertTrue("this element should be a MultiLineString", mlsf.lineStrings is MultiLineString);
			var ls:MultiLineString = mlsf.lineStrings;
			Assert.assertEquals("there should be 2 lineStrings inside", 2, ls.componentsLength);
			Assert.assertTrue("this element should be a LineString", ls.getcomponentsClone()[0] is LineString);
			var lineStringOne:LineString = ls.getcomponentsClone()[0] as LineString;
			Assert.assertTrue("this element should be a Point",lineStringOne.getPointAt(0) is Point);
			var pointOne:Point = lineStringOne.getPointAt(0);
			Assert.assertEquals("the x coord should be -102", -102, pointOne.x);
			
			var ns:String = "topp=\"http://www.openplans.org/topp\"";
			var featureType:String = "states";
			var geometryName:String = "the_geom";
			
			var xmlNode:XML = format.buildFeatureNode(mlsf, ns, featureType, geometryName);
		
			
		}
		
		
		
		[Test]
		public function TestBuildPolygonNode():void{
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:states gml:id="states.1">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>-102.145 17.222</gml:lowerCorner>
<gml:upperCorner>-4.0715 22.51099</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<topp:the_geom>
<gml:Polygon>
<gml:exterior>
<gml:LinearRing>
<gml:posList>-4.0715 22.51099 -102.145 17.222</gml:posList>
</gml:LinearRing>
</gml:exterior>			
</gml:Polygon>
</topp:the_geom>
</topp:states>
</wfs:member>;	
			
			var feature:Feature = format.parseFeature(xml);	
			var pf:PolygonFeature = feature as PolygonFeature;
			var ns:String = "topp=\"http://www.openplans.org/topp\"";
			var featureType:String = "states";
			var geometryName:String = "the_geom";
			
			//Assert.assertNull("this element should be null",pf.polygon);
			var xmlNode:XML = format.buildFeatureNode(feature, ns, featureType, geometryName);
			
		}		
		
		[Test]
		public function TestBuildMultiPolygonNode():void{
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:states gml:id="states.1">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>-91.2356 36.51099</gml:lowerCorner>
<gml:upperCorner>-88.07 41.222</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
	<topp:the_geom>
	<gml:MultiSurface srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
				
	<gml:surfaceMember>
		<gml:Polygon>
			<gml:exterior>
			<gml:LinearRing>
			<gml:posList>-88.07 37.51 -88.08 37.47 -88.311 37.442</gml:posList>
			</gml:LinearRing>
			</gml:exterior>
			<gml:interior>
			<gml:LinearRing>
			<gml:posList>-90.071 39.51099 -89.0878 40.476273</gml:posList>
			</gml:LinearRing>
			</gml:interior>	
			<gml:interior>
			<gml:LinearRing>
			<gml:posList>-91.2356 37.2599 -88.0809 38.00089</gml:posList>
			</gml:LinearRing>
			</gml:interior>		
		</gml:Polygon>
	</gml:surfaceMember>			
	
	<gml:surfaceMember>			
		<gml:Polygon>
			<gml:exterior>
			<gml:LinearRing>
			<gml:posList>-89.0715 36.51099 -90.145 41.222</gml:posList>
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
			var mp:MultiPolygon = mpf.polygons;
			var polygon:Polygon = mp.getcomponentsClone()[0] as Polygon;
			
			var ns:String = "topp=\"http://www.openplans.org/topp\"";
			var featureType:String = "states";
			var geometryName:String = "the_geom";

			Assert.assertEquals("There should be 3 LinearRings inside",3,polygon.getcomponentsClone().length);
			var xmlNode:XML = format.buildFeatureNode(feature, ns, featureType, geometryName);
			
		}
		
		[Test]
		public function TestBuildMultiPointNode():void{
			var xml:XML = <wfs:member
xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:topp="http://www.openplans.org/topp"
xmlns:wfs="http://www.opengis.net/wfs/2.0">
<topp:tasmania_cities gml:id="tasmania_cities.2">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:lowerCorner>58.35168321968 -123.54576589999</gml:lowerCorner>
<gml:upperCorner>147.617773828125 -41.6182861328125</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<topp:the_geom>
<gml:MultiPoint srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
<gml:pointMember>
<gml:Point>
<gml:pos>147.617773828125 -41.6182861328125</gml:pos>
</gml:Point>
</gml:pointMember>
<gml:pointMember>
<gml:Point>
<gml:pos>58.35168321968 -123.54576589999</gml:pos>
</gml:Point>
</gml:pointMember>				
</gml:MultiPoint>
</topp:the_geom>
</topp:tasmania_cities>
</wfs:member>;			
			
			var feature:Feature = format.parseFeature(xml);	
			var x:String = feature.name;
			var mpf:MultiPointFeature = feature as MultiPointFeature;
			var mp:MultiPoint = mpf.points;
			var points:Vector.<Point> = mp.toVertices(); 
			var ns:String = "topp=\"http://www.openplans.org/topp\"";
			var featureType:String = "tasmania_cities";
			var geometryName:String = "the_geom";
			
			Assert.assertEquals("there should be two points inside the multipoint",2, points.length);
			var xmlNode:XML = format.buildFeatureNode(feature, ns, featureType, geometryName);
			
		}
		
		
		[Test]
		public function TestBuildFeatureCollectionNode():void{
			var xml:XML =<wfs:FeatureCollection xmlns:sf="http://www.openplans.org/spearfish" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:wfs="http://www.opengis.net/wfs/2.0">
<wfs:member>
<sf:restricted gml:id="restricted.3">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#26713">
<gml:lowerCorner>598239.5942270659 4916224.777098622</gml:lowerCorner>
<gml:upperCorner>599657.4754089377 4917345.075533595</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<sf:the_geom>
<gml:MultiSurface srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#26713">
<gml:surfaceMember>
<gml:Polygon>
<gml:exterior>
<gml:LinearRing>
<gml:posList>598239.5942270659 4917334.785918331 599645.0893316591 4917345.075533595 599657.4754089377 4916247.277528859 598255.0195882423 4916224.777098622 598239.5942270659 4917334.785918331</gml:posList>
</gml:LinearRing>
</gml:exterior>
</gml:Polygon>
</gml:surfaceMember>
</gml:MultiSurface>
</sf:the_geom>
<sf:cat>4</sf:cat>
</sf:restricted>
</wfs:member>
<wfs:member>
<sf:restricted gml:id="restricted.4">
<gml:boundedBy>
<gml:Envelope srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#26713">
<gml:lowerCorner>592250.9171658278 4916851.195066947</gml:lowerCorner>
<gml:upperCorner>597086.9686143089 4921789.551205</gml:upperCorner>
</gml:Envelope>
</gml:boundedBy>
<sf:the_geom>
<gml:MultiSurface srsDimension="2" srsName="http://www.opengis.net/gml/srs/epsg.xml#26713">
<gml:surfaceMember>
<gml:Polygon>
<gml:exterior>
<gml:LinearRing>
<gml:posList>592316.9379796328 4921789.551205 595825.0954050707 4921744.536515899 595885.9596931553 4921724.645000904 595988.6597380087 4921687.164865309 596085.2476595924 4921639.762469891 596199.3035518276 4921572.496462965 596425.0407301437 4921395.970557282 596646.8773303393 4921175.924634823 596705.3044231973 4921085.024251698 596895.7087137242 4920764.209535123 597037.3181371056 4920411.356964448 597086.9686143089 4920134.155276274 597086.9455551769 4920123.465548163 595404.9389344064 4916851.195066947 595299.9499316034 4916886.386015123 595162.2497092936 4916933.814845423 594983.526128624 4917022.501919034 594829.906966761 4917102.010213899 594395.0453582691 4917391.676438842 594318.2555423079 4917440.593210369 594052.0932835294 4917582.785221043 593703.9205438099 4917824.291862512 593327.876386339 4918204.019530202 592902.7306171365 4918762.450187511 592799.5541783689 4918932.025310009 592746.4663403123 4919027.503578438 592681.9715953676 4919129.097605954 592425.6305890534 4919588.921377501 592354.4073250518 4919747.786211425 592321.8954023286 4919852.413886508 592250.9171658278 4920477.809486801 592252.310983779 4920771.012968304 592264.8066111131 4921269.605086448 592316.9379796328 4921789.551205</gml:posList>
</gml:LinearRing>
</gml:exterior>
</gml:Polygon>
</gml:surfaceMember>
</gml:MultiSurface>
</sf:the_geom>
<sf:cat>3</sf:cat>
</sf:restricted>
</wfs:member>
</wfs:FeatureCollection>;
			
			var features:Vector.<Feature> = new Vector.<Feature>();
			var i:uint;
			var memberList:XMLList = xml..*::member;
			for(i = 0; i<memberList.length(); i++){
			features[i] = format.parseFeature(memberList[i]);
			}
			
			var ns:String = "sf=\"http://www.openplans.org/spearfish\""
			var featureType:String = "restricted";
			var geometryName:String = "the_geom";
			
			var featureCollection:XML = format.buildFeatureCollectionNode(features,ns,featureType,geometryName);
			
		}
		
		
		[Test]
		public function TestParseGML32Collection():void{
			
			var xml:XML = new XML(new GMLFILE());
			var featureVector:Vector.<Feature> = format.parseGmlFile(xml);
			var i:uint;
			for (i = 0; i < featureVector.length; i++)
			{
				Assert.assertTrue("the component should be a LineStringFeature", featureVector[i] is LineStringFeature);
			}
		}	
		
	}
	
	
}