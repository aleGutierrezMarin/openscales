package org.openscales.core.style
{

	import org.flexunit.Assert;
	
	public class StyleSLDGeneratorTest
	{
		
		private var simpleStyleStart:String;
		private var simpleStyleEnd:String;
		private var simpleRuleStart:String;
		private var simpleRuleEnd:String;
		private var minScaleDenominator:String;
		private var maxScaleDenominator:String;
		
		[Before]
		public function init():void {
			simpleStyleStart ="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			simpleStyleStart+="<sld:StyledLayerDescriptor version=\"1.0.0\" \n"; 
			simpleStyleStart+="xsi:schemaLocation=\"http://www.opengis.net/sld StyledLayerDescriptor.xsd\" \n";
			simpleStyleStart+="xmlns=\"http://www.opengis.net/sld\" \n"; 
			simpleStyleStart+="xmlns:ogc=\"http://www.opengis.net/ogc\" \n"; 
			simpleStyleStart+="xmlns:xlink=\"http://www.w3.org/1999/xlink\" \n";
			simpleStyleStart+="xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n";
			simpleStyleStart+="<sld:NamedLayer>\n";
			simpleStyleStart+="<sld:Name>myTestStyle</sld:Name>\n";
			simpleStyleStart+="<sld:UserStyle>\n";
			simpleStyleStart+="<sld:Name>myTestStyle</sld:Name>\n";
			simpleStyleStart+="<sld:FeatureTypeStyle>\n";
			
			simpleStyleEnd ="</sld:FeatureTypeStyle>\n";
			simpleStyleEnd+="</sld:UserStyle>\n";
			simpleStyleEnd+="</sld:NamedLayer>\n";
			simpleStyleEnd+="</sld:StyledLayerDescriptor>";
			
			simpleRuleStart ="<sld:Rule>\n";
			simpleRuleStart+="<sld:Title>myRuleTitle</sld:Title>\n";
			simpleRuleStart+="<sld:Name>myTestRule</sld:Name>\n";
			simpleRuleStart+="<sld:Abstract>myRuleTitle</sld:Abstract>\n";
			minScaleDenominator ="<sld:MinScaleDenominator>0</sld:MinScaleDenominator>\n";
			maxScaleDenominator ="<sld:MaxScaleDenominator>42.5</sld:MaxScaleDenominator>\n";

			simpleRuleEnd ="</sld:Rule>";
		}
		
		/**
		 * This test asserts that an empty Style return conform sld xml string
		 */
		[Test]
		public function emptyStyle():void{
			var style:Style = new Style();
			style.name = "myTestStyle";
			var xml:String = simpleStyleStart+simpleStyleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, style.sld);
		}
		
		/**
		 * This test asserts that an empty Rule return conform sld xml string
		 */ 
		[Test]
		public function emptyRule():void{
			var rule:Rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			var xml:String = simpleRuleStart+simpleRuleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, rule.sld);
		}
		
		/**
		 * This test asserts that an empty Rule with a minscaledenominator return conform sld xml string
		 */ 
		[Test]
		public function emptyRuleMinScaleDenominatorEqualsZero():void{
			var rule:Rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			rule.minScaleDenominator = 0;
			var xml:String = simpleRuleStart+minScaleDenominator+simpleRuleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, rule.sld);
		}
		
		/**
		 * This test asserts that an empty Rule with a non zero minscaledenominator return conform sld xml string
		 */ 
		[Test]
		public function emptyRuleMinScaleDenominatorIsNonZero():void{
			var rule:Rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			rule.minScaleDenominator = 10.5;
			var minScaleDenominator:String ="<sld:MinScaleDenominator>10.5</sld:MinScaleDenominator>\n";
			var xml:String = simpleRuleStart+minScaleDenominator+simpleRuleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, rule.sld);
		}
		
		/**
		 * This test asserts that an empty Rule with a maxscaledenominator return conform sld xml string
		 */ 
		[Test]
		public function emptyRuleMaxScaleDenominator():void{
			var rule:Rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			rule.maxScaleDenominator = 42.5;
			var xml:String = simpleRuleStart+maxScaleDenominator+simpleRuleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, rule.sld);
		}
		
		/**
		 * This test asserts that an empty Rule with a minscaledenominator and a manscaledenominator return conform sld xml string
		 */ 
		[Test]
		public function emptyRuleMinMaxScaleDenominator():void{
			var rule:Rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			rule.minScaleDenominator = 0;
			rule.maxScaleDenominator = 42.5;
			var xml:String = simpleRuleStart+minScaleDenominator+maxScaleDenominator+simpleRuleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, rule.sld);
		}
		
		/**
		 * This test asserts that a Style with a Rule with a minscaledenominator and a manscaledenominator return conform sld xml string
		 */ 
		[Test]
		public function emptyStyleWithOneRule():void{
			var style:Style = new Style();
			style.name = "myTestStyle";
			var rule:Rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			rule.minScaleDenominator = 0;
			rule.maxScaleDenominator = 42.5;
			style.rules.push(rule);
			var xml:String = simpleStyleStart
							 + simpleRuleStart
							 + minScaleDenominator
							 + maxScaleDenominator
							 + simpleRuleEnd+"\n"
							 + simpleStyleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, style.sld);
		}
		
		/**
		 * This test asserts that a Style with two rules return conform sld xml string
		 */ 
		[Test]
		public function emptyStyleWithTwoRule():void{
			var style:Style = new Style();
			style.name = "myTestStyle";
			var rule:Rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			rule.minScaleDenominator = 0;
			rule.maxScaleDenominator = 42.5;
			style.rules.push(rule);
			style.rules.push(rule);
			var xml:String = simpleStyleStart
				+ simpleRuleStart
				+ minScaleDenominator
				+ maxScaleDenominator
				+ simpleRuleEnd+"\n"
				+ simpleRuleStart
				+ minScaleDenominator
				+ maxScaleDenominator
				+ simpleRuleEnd+"\n"
				+ simpleStyleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, style.sld);
		}
		
		/**
		 * This test asserts that a Style with two different Rules return conform sld xml string
		 */ 
		[Test]
		public function emptyStyleWithTwoDifferentRule():void{
			var style:Style = new Style();
			style.name = "myTestStyle";
			var rule:Rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			rule.minScaleDenominator = 0;
			rule.maxScaleDenominator = 42.5;
			style.rules.push(rule);
			rule = new Rule();
			rule.name = "myTestRule";
			rule.abstract = "myRuleTitle";
			rule.title = "myRuleTitle";
			rule.minScaleDenominator = 0;
			style.rules.push(rule);
			var xml:String = simpleStyleStart
				+ simpleRuleStart
				+ minScaleDenominator
				+ maxScaleDenominator
				+ simpleRuleEnd+"\n"
				+ simpleRuleStart
				+ minScaleDenominator
				+ simpleRuleEnd+"\n"
				+ simpleStyleEnd;
			Assert.assertEquals("The sld xml is invalid", xml, style.sld);
		}

	}
}