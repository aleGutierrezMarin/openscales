package org.openscales.core.style
{

	import org.flexunit.Assert;
	import org.openscales.core.style.fill.GraphicFill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.font.Font;
	import org.openscales.core.style.graphic.ExternalGraphic;
	import org.openscales.core.style.graphic.Graphic;
	import org.openscales.core.style.graphic.Mark;
	import org.openscales.core.style.halo.Halo;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	
	/**
	 * this class allow testing of sld import/export
	 */
	public class SLDTests
	{
		
		/**
		 * simple parsing test
		 */
		[Test]
		public function test1SimpleSLD():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<StyledLayerDescriptor version=\"1.0.0\" xsi:schemaLocation=\"http://www.opengis.net/sld StyledLayerDescriptor.xsd\" xmlns=\"http://www.opengis.net/sld\" xmlns:ogc=\"http://www.opengis.net/ogc\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n";
			xml+= "<NamedLayer>\n";
			xml+= "<Name>testNamedLayerName</Name>\n";
			xml+= "<UserStyle>\n";
			xml+= "<Name>testUserStyleName</Name>\n";
			xml+= "<IsDefault>1</IsDefault>\n";
			xml+= "<FeatureTypeStyle>\n";
			xml+= "<Rule>\n";
			xml+= "<Name>testRuleName1</Name>\n";
			xml+= "<PolygonSymbolizer>\n";
			xml+= "<Geometry>\n";
			xml+= "<ogc:PropertyName>testPropertyName1</ogc:PropertyName>\n";
			xml+= "</Geometry>\n";
			xml+= "<Fill>\n";
			xml+= "<CssParameter name=\"fill\">#ffffff</CssParameter>\n";
			xml+= "</Fill>\n";
			xml+= "</PolygonSymbolizer>\n";
			xml+= "</Rule>\n";
			xml+= "<Rule>\n";
			xml+= "<Name>testRuleName2</Name>\n";
			xml+= "<PolygonSymbolizer>\n";
			xml+= "<Geometry>\n";
			xml+= "<ogc:Function name=\"testFunction\">\n";
			xml+= "<ogc:PropertyName>testPropertyName2</ogc:PropertyName>\n";
			xml+= "</ogc:Function>\n";
			xml+= "</Geometry>\n";
			xml+= "<Fill>\n";
			xml+= "<CssParameter name=\"fill\">#000000</CssParameter>\n";
			xml+= "<CssParameter name=\"fill-opacity\">0.5</CssParameter>\n";
			xml+= "</Fill>\n";
			xml+= "</PolygonSymbolizer>\n";
			xml+= "</Rule>\n";
			xml+= "</FeatureTypeStyle>\n";
			xml+= "</UserStyle>\n";
			xml+= "</NamedLayer>\n";
			xml+= "</StyledLayerDescriptor>";
			
			var style:Style = new Style();
			style.sld = xml;
			Assert.assertEquals("testNamedLayerName",style.name);
			Assert.assertEquals(2,style.rules.length);
			Assert.assertEquals("testRuleName1",style.rules[0].name);
			Assert.assertEquals(1,style.rules[0].symbolizers.length);
			Assert.assertTrue(style.rules[0].symbolizers[0] is PolygonSymbolizer);
			Assert.assertNotNull((style.rules[0].symbolizers[0] as PolygonSymbolizer).geometry);
			Assert.assertNull((style.rules[0].symbolizers[0] as PolygonSymbolizer).geometry.functionName);
			Assert.assertEquals("testPropertyName1",(style.rules[0].symbolizers[0] as PolygonSymbolizer).geometry.propertyName);
			Assert.assertNotNull((style.rules[0].symbolizers[0] as PolygonSymbolizer).fill);
			Assert.assertTrue((style.rules[0].symbolizers[0] as PolygonSymbolizer).fill is SolidFill);
			Assert.assertEquals(parseInt("ffffff",16),((style.rules[0].symbolizers[0] as PolygonSymbolizer).fill as SolidFill).color);
			Assert.assertEquals(1,((style.rules[0].symbolizers[0] as PolygonSymbolizer).fill as SolidFill).opacity);

			Assert.assertEquals("testRuleName2",style.rules[1].name);
			Assert.assertEquals(1,style.rules[1].symbolizers.length);
			Assert.assertTrue(style.rules[1].symbolizers[0] is PolygonSymbolizer);
			Assert.assertNotNull((style.rules[1].symbolizers[0] as PolygonSymbolizer).geometry);
			Assert.assertEquals("testFunction",(style.rules[1].symbolizers[0] as PolygonSymbolizer).geometry.functionName);
			Assert.assertEquals("testPropertyName2",(style.rules[1].symbolizers[0] as PolygonSymbolizer).geometry.propertyName);
			Assert.assertNotNull((style.rules[1].symbolizers[0] as PolygonSymbolizer).fill);
			Assert.assertTrue((style.rules[1].symbolizers[0] as PolygonSymbolizer).fill is SolidFill);
			Assert.assertEquals(parseInt("000000",16),((style.rules[1].symbolizers[0] as PolygonSymbolizer).fill as SolidFill).color);
			Assert.assertEquals(0.5,((style.rules[1].symbolizers[0] as PolygonSymbolizer).fill as SolidFill).opacity);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<sld:StyledLayerDescriptor version=\"1.0.0\" \n";
			xml+= "xsi:schemaLocation=\"http://www.opengis.net/sld StyledLayerDescriptor.xsd\" \n";
			xml+= "xmlns=\"http://www.opengis.net/sld\" \n";
			xml+= "xmlns:sld=\"http://www.opengis.net/sld\" \n";
			xml+= "xmlns:ogc=\"http://www.opengis.net/ogc\" \n";
			xml+= "xmlns:xlink=\"http://www.w3.org/1999/xlink\" \n";
			xml+= "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n";
			xml+= "<sld:NamedLayer>\n";
			xml+= "<sld:Name>testNamedLayerName</sld:Name>\n";
			xml+= "<sld:UserStyle>\n";
			xml+= "<sld:Name>testNamedLayerName</sld:Name>\n";
			xml+= "<sld:FeatureTypeStyle>\n";
			xml+= "<sld:Rule>\n";
			xml+= "<sld:Abstract></sld:Abstract>\n";
			xml+= "<sld:Name>testRuleName1</sld:Name>\n";
			xml+= "<sld:PolygonSymbolizer>\n";
			xml+= "<sld:Geometry>\n";
			xml+= "<ogc:PropertyName>testPropertyName1</ogc:PropertyName>\n";
			xml+= "</sld:Geometry>\n";
			xml+= "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#ffffff</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			xml+= "</sld:PolygonSymbolizer>\n";
			xml+= "</sld:Rule>\n";
			xml+= "<sld:Rule>\n";
			xml+= "<sld:Abstract></sld:Abstract>\n";
			xml+= "<sld:Name>testRuleName2</sld:Name>\n";
			xml+= "<sld:PolygonSymbolizer>\n";
			xml+= "<sld:Geometry>\n";
			xml+= "<ogc:Function name=\"testFunction\">\n";
			xml+= "<ogc:PropertyName>testPropertyName2</ogc:PropertyName>\n";
			xml+= "</ogc:Function>\n";
			xml+= "</sld:Geometry>\n";
			xml+= "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"fill-opacity\">0.5</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			xml+= "</sld:PolygonSymbolizer>\n";
			xml+= "</sld:Rule>\n";
			xml+= "</sld:FeatureTypeStyle>\n";
			xml+= "</sld:UserStyle>\n";
			xml+= "</sld:NamedLayer>\n";
			xml+= "</sld:StyledLayerDescriptor>";
			Assert.assertEquals(xml,style.sld);
		}
		
		
		/**
		 * rule test
		 */
		[Test]
		public function test2Rule():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Rule>\n";
			xml+= "<Name>testRuleName</Name>\n";
			xml+= "<Abstract>testRuleAbstract</Abstract>\n";
			xml+= "<Title>testRuleTitle</Title>\n";
			xml+= "<MinScaleDenominator>100</MinScaleDenominator>\n";
			xml+= "<MaxScaleDenominator>10</MaxScaleDenominator>\n";
			xml+= "</Rule>";
			
			var rule:Rule = new Rule();
			rule.sld = xml;
			
			Assert.assertEquals("testRuleName",rule.name);
			Assert.assertEquals("testRuleTitle",rule.title);
			Assert.assertEquals("testRuleAbstract",rule.abstract);
			Assert.assertEquals(100,rule.minScaleDenominator);
			Assert.assertEquals(10,rule.maxScaleDenominator);

			xml = "<sld:Rule>\n";
			xml+= "<sld:Title>testRuleTitle</sld:Title>\n";
			xml+= "<sld:Abstract>testRuleAbstract</sld:Abstract>\n";
			xml+= "<sld:Name>testRuleName</sld:Name>\n";
			xml+= "<sld:MinScaleDenominator>100</sld:MinScaleDenominator>\n";
			xml+= "<sld:MaxScaleDenominator>10</sld:MaxScaleDenominator>\n";
			xml+= "</sld:Rule>\n";
			
			Assert.assertEquals(xml,rule.sld);
		}

		/**
		 * SolidFill test
		 */
		[Test]
		public function test3SolidFill():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Fill>\n";
			xml+= "<CssParameter name=\"fill\">#ffffff</CssParameter>\n";
			xml+= "<CssParameter name=\"fill-opacity\">0.5</CssParameter>\n";
			xml+= "</Fill>\n";
			
			var fill:SolidFill = new SolidFill();
			fill.sld = xml;
			
			Assert.assertEquals(parseInt("ffffff",16),fill.color);
			Assert.assertEquals(0.5,fill.opacity);
			
			xml = "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#ffffff</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"fill-opacity\">0.5</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			
			Assert.assertEquals(xml,fill.sld);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Fill>\n";
			xml+= "<CssParameter name=\"fill\">#ffffff</CssParameter>\n";
			xml+= "</Fill>\n";
			
			fill = new SolidFill();
			fill.sld = xml;
			
			Assert.assertEquals(parseInt("ffffff",16),fill.color);
			Assert.assertEquals(1,fill.opacity);
			
			xml = "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#ffffff</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			
			Assert.assertEquals(xml,fill.sld);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Fill>\n";
			xml+= "</Fill>\n";
			
			fill = new SolidFill();
			fill.sld = xml;
			
			Assert.assertEquals(0,fill.color);
			Assert.assertEquals(1,fill.opacity);
			
			xml = "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#000000</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			
			Assert.assertEquals(xml,fill.sld);
		}
		
		/**
		 * GraphicFill test
		 */
		[Test]
		public function test4GraphiFill():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Fill xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n";
			xml+= "<GraphicFill>\n";
			xml+= "<Graphic>\n";
			xml+= "<ExternalGraphic>\n";
			xml+= "<OnlineResource xlink:type=\"simple\" xlink:href=\"testImage.png\" />\n";
			xml+= "<Format>image/png</Format>\n";
			xml+= "</ExternalGraphic>\n";
			xml+= "</Graphic>\n";
			xml+= "</GraphicFill>\n";
			xml+= "</Fill>\n";
			
			var fill:GraphicFill = new GraphicFill();
			fill.sld = xml;
			
			Assert.assertNotNull(fill.graphic);
			Assert.assertEquals(1,fill.graphic.graphics.length);
			Assert.assertTrue(fill.graphic.graphics[0] is ExternalGraphic);
			Assert.assertEquals("image/png",(fill.graphic.graphics[0] as ExternalGraphic).format);
			Assert.assertEquals("testImage.png",(fill.graphic.graphics[0] as ExternalGraphic).onlineResource);
			
			xml = "<sld:Fill>\n";
			xml+= "<sld:GraphicFill>\n";
			xml+= "<sld:Graphic>\n";
			xml+= "<sld:ExternalGraphic>\n";
			xml+= "<sld:OnlineResource xlink:type=\"simple\" xlink:href=\"testImage.png\"/>\n";
			xml+= "<sld:Format>image/png</sld:Format>\n";
			xml+= "</sld:ExternalGraphic>\n";
			xml+= "<sld:Size>6</sld:Size>\n";
			xml+= "</sld:Graphic>\n";
			xml+= "</sld:GraphicFill>\n";
			xml+= "</sld:Fill>\n";
			
			Assert.assertEquals(xml,fill.sld);
			
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml = "<Fill>\n";
			xml+= "<GraphicFill>\n";
			xml+= "<Graphic>\n";
			xml+= "<Mark>\n";
			xml+= "<WellKnownName>shape://times</WellKnownName>\n";
			xml+= "<Stroke>\n";
			xml+= "<CssParameter name=\"stroke\">#000000</CssParameter>\n";
			xml+= "<CssParameter name=\"stroke-width\">42</CssParameter>\n";
			xml+= "</Stroke>\n";
			xml+= "</Mark>\n";
			xml+= "</Graphic>\n";
			xml+= "</GraphicFill>\n";
			xml+= "</Fill>\n";
			
			fill = new GraphicFill();
			fill.sld = xml;
			
			Assert.assertNotNull(fill.graphic);
			Assert.assertEquals(1,fill.graphic.graphics.length);
			Assert.assertTrue(fill.graphic.graphics[0] is Mark);
			Assert.assertEquals("shape://times",(fill.graphic.graphics[0] as Mark).wellKnownGraphicName);
			Assert.assertNotNull((fill.graphic.graphics[0] as Mark).stroke);
			Assert.assertEquals(42,(fill.graphic.graphics[0] as Mark).stroke.width);
			Assert.assertEquals(parseInt("000000",16),(fill.graphic.graphics[0] as Mark).stroke.color);
			
			xml = "<sld:Fill>\n";
			xml+= "<sld:GraphicFill>\n";
			xml+= "<sld:Graphic>\n";
			xml+= "<sld:Mark>\n";
			xml+= "<sld:WellKnownName>shape://times</sld:WellKnownName>\n";
			xml+= "<sld:Stroke>\n";
			xml+= "<sld:CssParameter name=\"stroke\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-width\">42</sld:CssParameter>\n";
			xml+= "</sld:Stroke>\n";
			xml+= "</sld:Mark>\n";
			xml+= "<sld:Size>6</sld:Size>\n";
			xml+= "</sld:Graphic>\n";
			xml+= "</sld:GraphicFill>\n";
			xml+= "</sld:Fill>\n";
			Assert.assertEquals(xml,fill.sld);
		}
		
		/**
		 * Font test
		 */
		[Test]
		public function test5Font():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Font>\n";
			xml+= "<CssParameter name=\"font-family\">Arial</CssParameter>\n";
			xml+= "<CssParameter name=\"font-size\">42</CssParameter>\n";
			xml+= "</Font>\n";
			
			var font:Font = new Font();
			font.sld = xml;

			Assert.assertEquals(parseInt("000000",16),font.color);
			Assert.assertEquals(1,font.opacity);
			Assert.assertEquals(42,font.size);
			Assert.assertEquals(Font.NORMAL,font.weight);
			Assert.assertEquals(Font.NORMAL,font.style);
			Assert.assertEquals("Arial",font.family);
			
			xml = "<sld:Font>\n";
			xml+= "<sld:CssParameter name=\"font-family\">Arial</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"font-size\">42</sld:CssParameter>\n";
			xml+= "</sld:Font>\n";
			
			Assert.assertEquals(xml,font.sld);
			
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Font>\n";
			xml+= "<CssParameter name=\"font-family\">Times</CssParameter>\n";
			xml+= "<CssParameter name=\"font-size\">10</CssParameter>\n";
			xml+= "<CssParameter name=\"font-weight\">bold</CssParameter>\n";
			xml+= "<CssParameter name=\"font-style\">italic</CssParameter>\n";
			xml+= "</Font>\n";
			
			font = new Font();
			font.sld = xml;
			
			Assert.assertEquals(parseInt("000000",16),font.color);
			Assert.assertEquals(1,font.opacity);
			Assert.assertEquals(10,font.size);
			Assert.assertEquals(Font.BOLD,font.weight);
			Assert.assertEquals(Font.ITALIC,font.style);
			Assert.assertEquals("Times",font.family);
			
			xml = "<sld:Font>\n";
			xml+= "<sld:CssParameter name=\"font-family\">Times</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"font-size\">10</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"font-weight\">bold</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"font-style\">italic</sld:CssParameter>\n";
			xml+= "</sld:Font>\n";
			
			Assert.assertEquals(xml,font.sld);
		}
		
		/**
		 * ExternalGraphic test
		 */
		[Test]
		public function test6ExternalGraphic():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<ExternalGraphic xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n";
			xml+= "<OnlineResource xlink:type=\"simple\" xlink:href=\"testImage.png\" />\n";
			xml+= "<Format>image/jpeg</Format>\n";
			xml+= "</ExternalGraphic>\n";
			
			var graphic:ExternalGraphic = new ExternalGraphic();
			graphic.sld = xml;
			
			Assert.assertEquals("testImage.png",graphic.onlineResource);
			Assert.assertEquals("image/jpeg",graphic.format);
			
			xml = "<sld:ExternalGraphic>\n";
			xml+= "<sld:OnlineResource xlink:type=\"simple\" xlink:href=\"testImage.png\"/>\n";
			xml+= "<sld:Format>image/jpeg</sld:Format>\n";
			xml+= "</sld:ExternalGraphic>\n";
			
			Assert.assertEquals(xml,graphic.sld);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<ExternalGraphic />\n";
			
			graphic = new ExternalGraphic();
			graphic.sld = xml;
			Assert.assertEquals("",graphic.sld);
		}
		
		/**
		 * ExternalGraphic test
		 */
		[Test]
		public function test7Mark():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Mark>\n";
			xml+= "<WellKnownName>testMarker</WellKnownName>\n";
			xml+= "</Mark>\n";
			
			var graphic:Mark = new Mark();
			graphic.sld = xml;
			
			Assert.assertEquals("testMarker",graphic.wellKnownGraphicName);
			Assert.assertNull(graphic.stroke);
			Assert.assertNull(graphic.fill);
			
			xml = "<sld:Mark>\n";
			xml+= "<sld:WellKnownName>testMarker</sld:WellKnownName>\n";
			xml+= "</sld:Mark>\n";
			
			Assert.assertEquals(xml,graphic.sld);
			
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Mark>\n";
			xml+= "<WellKnownName>testMarker</WellKnownName>\n";
			xml+= "<Stroke></Stroke>";
			xml+= "<Fill></Fill>";
			xml+= "</Mark>\n";
			
			graphic = new Mark();
			graphic.sld = xml;
			
			Assert.assertEquals("testMarker",graphic.wellKnownGraphicName);
			Assert.assertNotNull(graphic.stroke);
			Assert.assertNotNull(graphic.fill);
			
			xml = "<sld:Mark>\n";
			xml+= "<sld:WellKnownName>testMarker</sld:WellKnownName>\n";
			xml+= "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#000000</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			xml+= "<sld:Stroke>\n";
			xml+= "<sld:CssParameter name=\"stroke\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-width\">1</sld:CssParameter>\n";
			xml+= "</sld:Stroke>\n";
			xml+= "</sld:Mark>\n";
			
			Assert.assertEquals(xml,graphic.sld);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Mark />\n";
			
			graphic = new Mark();
			graphic.sld = xml;
			Assert.assertEquals("",graphic.sld);
		}
		
		/**
		 * Font test
		 */
		[Test]
		public function test8Graphic():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Graphic>\n";
			xml+= "<Size>10</Size>\n";
			xml+= "<Rotation>45</Rotation>\n";
			xml+= "<Opacity>0.5</Opacity>\n";
			xml+= "</Graphic>\n";
			
			var graphic:Graphic = new Graphic();
			graphic.sld = xml;
			
			Assert.assertEquals(10,graphic.size);
			Assert.assertEquals(45,graphic.rotation);
			Assert.assertEquals(0.5,graphic.opacity);
			Assert.assertEquals(0,graphic.graphics.length);
			
			xml = "<sld:Graphic>\n";
			xml+= "<sld:Size>10</sld:Size>\n";
			xml+= "<sld:Rotation>45</sld:Rotation>\n";
			xml+= "<sld:Opacity>0.5</sld:Opacity>\n";
			xml+= "</sld:Graphic>\n";
			
			Assert.assertEquals(xml,graphic.sld);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Graphic>\n";
			xml+= "<Size>10</Size>\n";
			xml+= "<Rotation>45</Rotation>\n";
			xml+= "<Opacity>0.5</Opacity>\n";
			xml+= "<ExternalGraphic />\n";
			xml+= "<ExternalGraphic />\n";
			xml+= "<Mark />\n";
			xml+= "<Mark />\n";
			xml+= "</Graphic>\n";
			
			graphic = new Graphic();
			graphic.sld = xml;
			
			Assert.assertEquals(10,graphic.size);
			Assert.assertEquals(45,graphic.rotation);
			Assert.assertEquals(0.5,graphic.opacity);
			Assert.assertEquals(4,graphic.graphics.length);
			Assert.assertTrue(graphic.graphics[0] is ExternalGraphic);
			Assert.assertTrue(graphic.graphics[1] is ExternalGraphic);
			Assert.assertTrue(graphic.graphics[2] is Mark);
			Assert.assertTrue(graphic.graphics[3] is Mark);
		}
		
		/**
		 * Halo test
		 */
		[Test]
		public function test9Halo():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Halo>\n";
			xml+= "<Radius>1</Radius>\n";
			xml+= "</Halo>\n";
			
			var halo:Halo = new Halo();
			halo.sld = xml;
			
			Assert.assertEquals(1,halo.radius);
			
			xml = "<sld:Halo>\n";
			xml+= "<sld:Radius>1</sld:Radius>\n";
			xml+= "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#ffffff</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			xml+= "</sld:Halo>\n";
			
			Assert.assertEquals(xml,halo.sld);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Halo>\n";
			xml+= "<Radius>10</Radius>\n";
			xml+= "<Fill>\n";
			xml+= "<CssParameter name=\"fill\">#000000</CssParameter>\n";
			xml+= "<CssParameter name=\"fill-opacity\">0.5</CssParameter>\n";
			xml+= "</Fill>\n";
			xml+= "</Halo>\n";
			
			halo = new Halo();
			halo.sld = xml;
			
			Assert.assertEquals(10,halo.radius);
			Assert.assertEquals(parseInt("000000",16),halo.color);
			Assert.assertEquals(0.5,halo.opacity);
			
			xml = "<sld:Halo>\n";
			xml+= "<sld:Radius>10</sld:Radius>\n";
			xml+= "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"fill-opacity\">0.5</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			xml+= "</sld:Halo>\n";
			
			Assert.assertEquals(xml,halo.sld);
		}
		
		/**
		 * Stroke test
		 */
		[Test]
		public function test10Stroke():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Stroke/>\n";
			
			var stroke:Stroke = new Stroke();
			stroke.sld = xml;
			
			Assert.assertEquals(parseInt("000000",16),stroke.color);
			Assert.assertEquals(1,stroke.width);
			Assert.assertEquals(1,stroke.opacity);
			Assert.assertNull(stroke.linecap);
			Assert.assertNull(stroke.linejoin);
			Assert.assertNull(stroke.dashArray);
			
			xml = "<sld:Stroke>\n";
			xml+= "<sld:CssParameter name=\"stroke\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-width\">1</sld:CssParameter>\n";
			xml+= "</sld:Stroke>\n";
			
			Assert.assertEquals(xml,stroke.sld);
			
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Stroke>\n";
			xml+="<CssParameter name=\"stroke\">#ffffff</CssParameter>\n";
			xml+="<CssParameter name=\"stroke-opacity\">0.5</CssParameter>\n";
			xml+="<CssParameter name=\"stroke-width\">10</CssParameter>\n";
			xml+="<CssParameter name=\"stroke-linecap\">round</CssParameter>\n";
			xml+="<CssParameter name=\"stroke-linejoin\">round</CssParameter>\n";
			xml+= "</Stroke>\n";
			
			stroke = new Stroke();
			stroke.sld = xml;
			
			Assert.assertEquals(parseInt("ffffff",16),stroke.color);
			Assert.assertEquals(10,stroke.width);
			Assert.assertEquals(0.5,stroke.opacity);
			Assert.assertEquals("round",stroke.linecap);
			Assert.assertEquals("round",stroke.linejoin);
			Assert.assertNull(stroke.dashArray);
			Assert.assertEquals(0,stroke.dashoffset);
			
			xml = "<sld:Stroke>\n";
			xml+= "<sld:CssParameter name=\"stroke\">#ffffff</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-opacity\">0.5</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-width\">10</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-linecap\">round</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-linejoin\">round</sld:CssParameter>\n";
			xml+= "</sld:Stroke>\n";
			
			Assert.assertEquals(xml,stroke.sld);
			
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Stroke>\n";
			xml+= "<CssParameter name=\"stroke-dasharray\">4 4</CssParameter>\n";
			xml+= "<CssParameter name=\"stroke-dashoffset\">10</CssParameter>\n";
			xml+= "</Stroke>\n";
			
			stroke = new Stroke();
			stroke.sld = xml;
			
			Assert.assertNotNull(stroke.dashArray);
			Assert.assertTrue(2, stroke.dashArray.length);
			Assert.assertTrue(10,stroke.dashoffset);
			
			xml = "<sld:Stroke>\n";
			xml+= "<sld:CssParameter name=\"stroke\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-width\">1</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-dasharray\">4 4</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-dashoffset\">10</sld:CssParameter>\n";
			xml+= "</sld:Stroke>\n";
			
			Assert.assertEquals(xml,stroke.sld);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Stroke>\n";
			xml+= "<CssParameter name=\"stroke-dasharray\">4 4</CssParameter>\n";
			xml+= "</Stroke>\n";
			
			stroke = new Stroke();
			stroke.sld = xml;
			
			Assert.assertNotNull(stroke.dashArray);
			Assert.assertEquals(0,stroke.dashoffset);
			
			xml = "<sld:Stroke>\n";
			xml+= "<sld:CssParameter name=\"stroke\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-width\">1</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-dasharray\">4 4</sld:CssParameter>\n";
			xml+= "</sld:Stroke>\n";
			
			Assert.assertEquals(xml,stroke.sld);
			
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml+= "<Stroke>\n";
			xml+= "<CssParameter name=\"stroke-dashoffset\">10</CssParameter>\n";
			xml+= "</Stroke>\n";
			
			stroke = new Stroke();
			stroke.sld = xml;
			
			xml = "<sld:Stroke>\n";
			xml+= "<sld:CssParameter name=\"stroke\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"stroke-width\">1</sld:CssParameter>\n";
			xml+= "</sld:Stroke>\n";
			
			Assert.assertEquals(xml,stroke.sld);
		}
		
		/**
		 * PointSymbolizer test
		 */
		[Test]
		public function test11PointSymbolizer():void{
			Assert.assertTrue(false);
		}
		
		/**
		 * LineSymbolizer test
		 */
		[Test]
		public function test12LineSymbolizer():void{
			Assert.assertTrue(false);
		}
		
		/**
		 * PolygonSymbolizer test
		 */
		[Test]
		public function test13PolygonSymbolizer():void{
			Assert.assertTrue(false);
		}
		
		/**
		 * Text test
		 */
		[Test]
		public function test14TextSymbolizer():void{
			Assert.assertTrue(false);
		}
	}
}