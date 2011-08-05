package org.openscales.core.format.gml.writer
{

	public class GML321WriterTest
	{
		[Embed(source="/assets/format/MultiSurfaceCollection.xml",mimeType="application/octet-stream")]
		private const GMLFILE1:Class;
		
		[Embed(source="/assets/format/MultiPointCollection.xml",mimeType="application/octet-stream")]
		private const GMLFILE2:Class;
		
		[Embed(source="/assets/format/LineStringCollection.xml",mimeType="application/octet-stream")]
		private const GMLFILE3:Class;
		
		private var format:GML321Writer;
		
		public function GML321WriterTest()
		{
		}
		
		[Before]
		public function setUp():void
		{
			format = new GML321Writer();
		}
		
		[After] 
		public function tearDown():void
		{
			format = null;
		}
		
		
		/*[Test]
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
		// tests readMultiLineString (MultiCurve) 
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
		
		// test buildMultiLineStringNode
		
		var ns:String = "topp=\"http://www.openplans.org/topp\"";
		var featureType:String = "states";
		var geometryName:String = "the_geom";
		
		var xmlNode:XML = format.buildFeatureNode(mlsf, ns, featureType, geometryName);
		var xmlEnvelopeNode:XML = xmlNode..*::Envelope[0];
		Assert.assertEquals("The lower corner coordinates are incorrect", "-442.145 19.099", xmlEnvelopeNode.children()[0].toString());
		Assert.assertEquals("The upper corner coordinates are incorrect", "24 122", xmlEnvelopeNode.children()[1].toString());
		var lineStringNode:XMLList = xmlNode..*::LineString;
		Assert.assertEquals("This feature should contain 2 LineStrings", 2, lineStringNode.length());
		Assert.assertTrue("The content of the first LineString member is incorrect",lineStringNode[0].toString().match("<gml:posList>-102 22 -442.145 19.099</gml:posList>"));
		}
		
		
		[Test]
		public function TestBuildMultiPointCollection():void{
		
		var xml:XML = new XML(new GMLFILE2());
		var featureVector:Vector.<Feature> = format.parseGmlFile(xml);
		var i:uint;
		for (i = 0; i < featureVector.length; i++)
		{
		Assert.assertTrue("This component should be a MultiPointFeature", featureVector[i] is MultiPointFeature);
		}
		var ns:String = "topp=\"http://www.openplans.org/topp\""
		var buildCollection:XML = format.buildFeatureCollectionNode(featureVector,ns, "tasmania_cities","the_geom" );
		var pointCollection:XMLList = buildCollection..*::Point;
		Assert.assertEquals("There should be 13 Points in this collection",13,pointCollection.length());
		
		var tenthMember:XML = buildCollection..*::tasmania_cities[9];
		Assert.assertEquals("The ID of this member is incorrect", "tasmania_cities.10", tenthMember.attributes()[0].toString());
		Assert.assertEquals("The coordinates of the 10th Point are incorrect","147.9144046875 -41.82977294921875",pointCollection[9].children()[0].toString());
		}
		
		[Test]
		public function TestBuildLineStringCollection():void{
		
		var xml:XML = new XML(new GMLFILE3());
		var featureVector:Vector.<Feature> = format.parseGmlFile(xml);
		var i:uint;
		for (i = 0; i < featureVector.length; i++)
		{
		Assert.assertTrue("This component should be a LineStringFeature", featureVector[i] is LineStringFeature);
		}
		var ns:String = "topp=\"http://www.openplans.org/topp\""
		var buildCollection:XML = format.buildFeatureCollectionNode(featureVector,ns, "tasmania_roads","the_geom" );
		var lineCollection:XMLList = buildCollection..*::LineString;
		Assert.assertEquals("There should be 16 LineStrings in this collection",16,lineCollection.length());
		
		var sixteenthMember:XML = buildCollection..*::tasmania_roads[15];
		Assert.assertEquals("The ID of this member is incorrect", "tasmania_roads.16", sixteenthMember.attributes()[0].toString());
		}
		
		
		[Test]
		public function TestBuiltMultiSurfaceCollection():void{
		
		var xml:XML = new XML(new GMLFILE1());
		var featureVector:Vector.<Feature> = format.parseGmlFile(xml);
		var i:uint;
		for (i = 0; i < featureVector.length; i++)
		{
		Assert.assertTrue("the component should be a MultiPolygonFeature", featureVector[i] is MultiPolygonFeature);
		}
		var ns:String = "sf=\"http://www.openplans.org/spearfish\""
		var buildCollection:XML = format.buildFeatureCollectionNode(featureVector,ns, "restricted","the_geom" );
		Assert.assertTrue("The featureType should be \"the geom\"", buildCollection.toString().match("sf:the_geom"));
		var multiSurface:XMLList = buildCollection..*::MultiSurface;
		Assert.assertEquals("There should be 4 MultiSurface memebers in this collection",4,multiSurface.length());
		var polygons:XMLList = multiSurface[0]..*::Polygon;
		Assert.assertEquals("There should be 2 Polygons inside the first MultiSurfaceMember", 2, polygons.length());
		var rings1:XMLList = polygons[0]..*::LinearRing;
		var rings2:XMLList = polygons[1]..*::LinearRing;
		Assert.assertEquals("The coordinates of the first Polygon are incorrect","591954.3359385637 4925859.483293386 591957.3824433011 4925860.249209468 591996.9678179699 4925842.719067588 592066.2434228227 4925813.759259981 592235.2420918944 4925738.302342218 592551.8201372348 4925671.437550496 592560.7822126707 4925327.905382568 591595.3483009903 4925296.068594761 591593.0136062276 4925322.439424193 591587.74604609 4925412.531691931 591618.2329452335 4925451.495549678 591630.4333543724 4925475.174502224 591801.1266256558 4925645.575178106 591930.6806241288 4925789.2201092215 591954.3359385637 4925859.483293386",
		rings1[0].children()[0].toString()); 
		Assert.assertEquals("The coordinates of the second Polygon are incorrect", "591954.3359385601 4925859.483293301 591957.3824433001 4925860.249209401 591996.9678179699 4925842.719067588 592066.2434228227 4925813.759259981 592235.2420918944 4925738.302342218 592551.8201372348 4925671.437550496 592560.7822126707 4925327.905382568 591595.3483009903 4925296.068594761 591593.0136062276 4925322.439424193 591587.74604609 4925412.531691931 591618.2329452335 4925451.495549678 591630.4333543724 4925475.174502224 591801.1266256558 4925645.575178106 591930.6806241288 4925789.2201092215 591954.3359385637 4925859.483293386",
		rings2[0].children()[0].toString());
		
		}
		*/
		
	}
}