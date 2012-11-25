package org.openscales.core.style
{

	import org.flexunit.Assert;
	import org.openscales.core.style.fill.GraphicFill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.graphic.ExternalGraphic;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	
	public class SLDTests
	{
		
		/**
		 * simple parsing test
		 */
		[Test]
		public function testSimpleSLD():void{
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
			xml+= "<sld:CssParameter name=\"fill-opacity\">1</sld:CssParameter>\n";
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
		public function testRule():void{
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
		public function testSolidFill():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml = "<Fill>\n";
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
			xml = "<Fill>\n";
			xml+= "<CssParameter name=\"fill\">#ffffff</CssParameter>\n";
			xml+= "</Fill>\n";
			
			fill = new SolidFill();
			fill.sld = xml;
			
			Assert.assertEquals(parseInt("ffffff",16),fill.color);
			Assert.assertEquals(1,fill.opacity);
			
			xml = "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#ffffff</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"fill-opacity\">1</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			
			Assert.assertEquals(xml,fill.sld);
			
			xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml = "<Fill>\n";
			xml+= "</Fill>\n";
			
			fill = new SolidFill();
			fill.sld = xml;
			
			Assert.assertEquals(0,fill.color);
			Assert.assertEquals(1,fill.opacity);
			
			xml = "<sld:Fill>\n";
			xml+= "<sld:CssParameter name=\"fill\">#000000</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"fill-opacity\">1</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			
			Assert.assertEquals(xml,fill.sld);
		}
		
		/**
		 * SolidFill test
		 */
		[Test]
		public function testGraphiFill():void{
			var xml:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			xml = "<Fill xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n";
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
			xml+= "<sld:CssParameter name=\"fill\">#ffffff</sld:CssParameter>\n";
			xml+= "<sld:CssParameter name=\"fill-opacity\">0.5</sld:CssParameter>\n";
			xml+= "</sld:Fill>\n";
			
			//Assert.assertEquals(xml,fill.sld);
			
		}
	}
}