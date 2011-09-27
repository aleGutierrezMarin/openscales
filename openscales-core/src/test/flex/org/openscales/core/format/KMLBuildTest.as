package org.openscales.core.format
{
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiLineString;
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
			//3 LineStringFeatures to parse/build so 3 style nodes and 3 placemark node 
			var i:uint;
			var file:XML = new XML(new KMLLINES());
			var features:Vector.<Feature> = this.format.read(file) as Vector.<Feature>;
			var buildedFile:XML = this.format.write(features) as XML;
			
			var styleNodes:XMLList = buildedFile..*::Style;
			var placemarks:XMLList = buildedFile..*::Placemark;
			var lineNodes:XMLList = buildedFile..*::LineString;
			Assert.assertTrue("There should be 3 style nodes in this file",styleNodes.length() == 3);
			Assert.assertTrue("There should be 3 placemark nodes in this file",placemarks.length() == 3);
			Assert.assertTrue("There should be 3 LineString nodes in this file",lineNodes.length() == 3);

			//the 1st feature has a default style; check the validity of the other 2 styles	
			var lineStyle1:XML = styleNodes[1]..*::LineStyle[0];
			var colorNode1:XML = lineStyle1..*::color[0];
			var lineStyle2:XML = styleNodes[2]..*::LineStyle[0];
			var colorNode2:XML = lineStyle2..*::color[0];
			Assert.assertTrue("The color tag of this line should be 7fff00ff",
				colorNode1.toString() == "7fff00ff");
			Assert.assertTrue("The color tag of this line should be 7fff00ff",
				colorNode2.toString() == "7f00ffff");
			//check the style reference in the placemarks
			var styleUrl:XMLList = buildedFile..*::styleUrl;
			for (i = 0; i < 3; i++)
			{
				Assert.assertEquals("The styleUrl of this feature is incorrect",
					"#feature"+i.toString(), styleUrl[i].toString());
			}
			
		}
		
		[Test]
		public function testBuildPoly():void
		{			
			//3 polygon features in this file;
			//each poly is defined by only one linear ring (there are no innerBoundaries)
			var file:XML = new XML(new KMLPOLY());
			var features:Vector.<Feature> = this.format.read(file) as Vector.<Feature>;
			var buildedFile:XML = this.format.write(features) as XML;
			
			var styleNodes:XMLList = buildedFile..*::Style;
			var placemarks:XMLList = buildedFile..*::Placemark;
			var polyNodes:XMLList = buildedFile..*::Polygon;
			var linearRings:XMLList = buildedFile..*::LinearRing;
			
			Assert.assertTrue("There should be 3 style nodes in this file",styleNodes.length() == 3);
			Assert.assertTrue("There should be 3 placemark nodes in this file",placemarks.length() == 3);
			Assert.assertTrue("There should be 3 polygon nodes in this file",polyNodes.length() == 3);
			Assert.assertTrue("There should be 3 ring nodes in this file",linearRings.length() == 3);
			
			//check the coordinates of the 1st polygon; altitude not supported
			var coords:String = "-122.0848938459612,37.42257124044786 -122.0849580979198,37.42211922626856 -122.0847469573047,37.42207183952619 -122.0845725380962,37.42209006729676 -122.0845954886723,37.42215932700895 -122.0838521118269,37.42227278564371 -122.083792243335,37.42203539112084 -122.0835076656616,37.42209006957106 -122.0834709464152,37.42200987395161 -122.0831221085748,37.4221046494946 -122.0829247374572,37.42226503990386 -122.0829339169385,37.42231242843094 -122.0833837359737,37.42225046087618 -122.0833607854248,37.42234159228745 -122.0834204551642,37.42237075460644 -122.083659133885,37.42251292011001 -122.0839758438952,37.42265873093781 -122.0842374743331,37.42265143972521 -122.0845036949503,37.4226514386435 -122.0848020460801,37.42261133916315 -122.0847882750515,37.42256395055121 -122.0848938459612,37.42257124044786";
			var fileCoords:XML = linearRings[0]..*::coordinates[0]; 
			Assert.assertEquals("The coordonates of the 1st polygon are incorrect", coords, fileCoords.toString());

			
		}
		
		[Test]
		public function testBuildPoints():void
		{		
			//create the point here to verify the style
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
			
			var styleNodes:XMLList = buildedFile..*::Style;
			var placemarks:XMLList = buildedFile..*::Placemark;
			var pointNodes:XMLList = buildedFile..*::Point;
			var coordNodes:XML = pointNodes[0]..*::coordinates[0];
			
			Assert.assertTrue("There should be 1 style node in this file",styleNodes.length() == 1);
			Assert.assertTrue("There should be 1 placemark nodes in this file",placemarks.length() == 1);
			Assert.assertTrue("There should be 1 point nodes in this file",pointNodes.length() == 1);
			Assert.assertTrue("There should be 1 point nodes in this file",
				coordNodes.toString() == "42.4555,2.559999901");
			
			//9872929 is 96A621 in hex so 21A696 in kml; 0.23*255 is 58.65 and 3A
			//so the color content should be 3A21A696
			var iconStyle:XML = styleNodes[0]..*::IconStyle[0];
			var colorNode:XML = iconStyle..*::color[0];
			Assert.assertEquals("The color of this point should be 3A21A696",
				"3A21A696", colorNode.toString().toUpperCase());
			
		}
		
		[Test]
		public function testGlobalBuild():void
		{	
			//test only the number and type of features in the file
			//9 polygon features, 2 point features, 2 CustomMarkers(without style) and 6 line Features, ergo 19 features and 17 styles
			//the custom markers are not supported for the build,they are treated as points
			
			var file:XML = new XML(new KMLGLOBAL());
			var features:Vector.<Feature> = this.format.read(file) as Vector.<Feature>;
			var buildedFile:XML = this.format.write(features) as XML;
			
			var styleNodes:XMLList = buildedFile..*::Style;
			var placemarks:XMLList = buildedFile..*::Placemark;
			
			var pointNodes:XMLList = buildedFile..*::Point;
			var polyNodes:XMLList = buildedFile..*::Polygon;
			var lineNodes:XMLList = buildedFile..*::LineString;
			
			Assert.assertEquals("There should be 17 style nodes in this file",styleNodes.length(),17);
			Assert.assertEquals("There should be 19 placemark nodes in this file",placemarks.length(),19);
			Assert.assertEquals("There should be 2 point nodes in this file",pointNodes.length(),4);
			Assert.assertEquals("There should be 9 polygon nodes in this file",polyNodes.length(),9);
			Assert.assertEquals("There should be 6 line nodes in this file",lineNodes.length(),6);
			
		}
		
		[Test]
		public function testBuildMultyGeom():void
		{	
			//one multilinestring feature
			//color and style already tested; test only the multigeometry node
			var features:Vector.<Feature> = new Vector.<Feature>();
	
			var v:Vector.<Number> = new <Number>[20,12.2,45,13.21];
			var line1:LineString = new LineString(v);
			var line2:LineString = new LineString(v);
			var geomVect:Vector.<Geometry> = new Vector.<Geometry>();
			geomVect.push(line1);
			geomVect.push(line2);
			
			var multiLine:MultiLineString = new MultiLineString(geomVect);
			
			var style:Style = new Style();
			var rule:Rule = new Rule();
			var stroke:Stroke = new Stroke(651477,2.8,1); // 651477 = 09f0d5 so BGR = d5f009 in the kml file
			var lineSym:LineSymbolizer = new LineSymbolizer(stroke);
			rule.symbolizers.push(lineSym);
			style.rules.push(rule);
		
			var feature:MultiLineStringFeature = new MultiLineStringFeature(multiLine,null,style);
			features.push(feature);
			
			var file:XML = this.format.write(features) as XML;
			var geomNode:XML  = file..*::MultiGeometry[0];
			var lines:XMLList = geomNode..*::LineString;
			var lineStyles:XMLList = file..*::LineStyle;
			var width:String = lineStyles[0]..*::width[0].toString();
			Assert.assertEquals("There are only 2 geometries in this multiGeometry node",2,geomNode.children().length());
			Assert.assertEquals("There are 2 LineString nodes in this multiGeometry",2, lines.length());
			Assert.assertEquals("There is one line style for this multilinestring",1,lineStyles.length());
			Assert.assertEquals("The width of the lines should be 2.8","2.8",width);
				
		}
	}
}