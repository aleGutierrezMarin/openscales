package org.openscales.core.format.wmc.writer
{
	import flexunit.framework.Assert;
	
	public class WMC110WriterTest
	{		
		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testBuildViewContext():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildViewContext("eos_data_gateways");
			
			var xmlResult:XML = <ViewContext id="eos_data_gateways" version="1.1.0" xmlns="http://www. opengeospatial.net/context" xmlns:sld="http://www. opengeospatial.net/sld" xmlns:xlink="http://www.w3.org/1999/xlink"/>;
			
			Assert.assertTrue(xml == xmlResult);		
		}
		
		[Test]
		public function testBuildGeneral():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildGeneral("EPSG:4326", -180.000000, -90.000000, 180.000000, 90.000000, "EOS Data Gateways");
			
			var xmlResult:XML = <General><BoundingBox SRS="EPSG:4326" minx="-180" miny="-90" maxx="180" maxy="90"/><Title>EOS Data Gateways</Title></General>;
			
			Assert.assertTrue(xml = xmlResult);			
		}		
		
		[Test]
		public function testBuildWindow():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildWindow(500, 300);
						
			var xmlResult:XML = <Window width="500" height="300"/>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildBoundingBox():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildBoundingBox("EPSG:4326", -180.000000, -90.000000, 180.000000, 90.000000);
			
			var xmlResult:XML = <BoundingBox SRS="EPSG:4326" minx="-180" miny="-90" maxx="180" maxy="90" />;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildKeywordList():void{
			var writer:WMC110Writer = new WMC110Writer();
			var keywords:Array = new Array();
			
			keywords.push("keyword 1");
			keywords.push("keyword 2");
			keywords.push("keyword 3");
			
			var xml:XML = writer.buildKeywordList(keywords);
			
			var xmlResult:XML = <KeywordList><Keyword>keyword 1</Keyword><Keyword>keyword 2</Keyword><Keyword>keyword 3</Keyword></KeywordList>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildLogoURL():void{						
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildLogoURL("http://eos.nasa.gov/imswelcome", "image/gif", 130, 74);
			
			var xmlResult:XML = <LogoURL width="130" height="74" format="image/gif"><OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"></OnlineResource></LogoURL>;
					
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml = writer.buildLogoURL("http://eos.nasa.gov/imswelcome", "image/gif");
			
			xmlResult = <LogoURL format="image/gif"><OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"/></LogoURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildDescriptionURL():void{						
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildDescriptionURL("http://eos.nasa.gov/imswelcome", "text/html");
			
			var xmlResult:XML = <DescriptionURL format="text/html"><OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"/></DescriptionURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml = writer.buildDescriptionURL("http://eos.nasa.gov/imswelcome");
			
			xmlResult = <DescriptionURL><OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"/></DescriptionURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildOnlineResource():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildOnlineResource("http://eos.nasa.gov/imswelcome");
			
			var xmlResult:XML = <OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"/>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildContactInformation():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildContactInformation("Tom Kralidis", "Canada Centre for Remote Sensing",
				"Systems Scientist", "postal", "615 Booth Street, room 650", "Ottawa", "Ontario", "K1A 0E9",
				"Canada", "+01 613 947 1828", "+01 613 947 2410", "tom.kralidis@ccrs.nrcan.gc.ca");
			
			var xmlResult:XML = <ContactInformation><ContactPersonPrimary><ContactPerson>Tom Kralidis</ContactPerson><ContactOrganization>Canada Centre for Remote Sensing</ContactOrganization></ContactPersonPrimary><ContactPosition>Systems Scientist</ContactPosition><ContactAddress><AddressType>postal</AddressType><Address>615 Booth Street, room 650</Address><City>Ottawa</City><StateOrProvince>Ontario</StateOrProvince><PostCode>K1A 0E9</PostCode><Country>Canada</Country></ContactAddress><ContactVoiceTelephone>+01 613 947 1828</ContactVoiceTelephone><ContactFacsimileTelephone>+01 613 947 2410</ContactFacsimileTelephone><ContactElectronicMailAddress>tom.kralidis@ccrs.nrcan.gc.ca</ContactElectronicMailAddress></ContactInformation>;

			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildContactPersonPrimary():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildContactPersonPrimary("Tom Kralidis", "Canada Centre for Remote Sensing");
			
			var xmlResult:XML = <ContactPersonPrimary><ContactPerson>Tom Kralidis</ContactPerson><ContactOrganization>Canada Centre for Remote Sensing</ContactOrganization></ContactPersonPrimary>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildContactAddress():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildContactAddress("postal", "615 Booth Street, room 650", "Ottawa", "Ontario", "K1A 0E9", "Canada");
			
			var xmlResult:XML = <ContactAddress><AddressType>postal </AddressType><Address>615 Booth Street, room 650</Address><City>Ottawa</City><StateOrProvince>Ontario</StateOrProvince><PostCode>K1A 0E9</PostCode><Country>Canada</Country></ContactAddress>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildExtension():void{
			var writer:WMC110Writer = new WMC110Writer();

			var xml:XML = writer.buildExtension(new XML(<shom:Layer xmlns:shom="http://www.shom.fr"><shom:Category>BDD</shom:Category><shom:Extractable>false</shom:Extractable></shom:Layer>));
			
			var xmlResult:XML = <Extension></Extension>;
			xmlResult.appendChild(<shom:Layer xmlns:shom="http://www.shom.fr"><shom:Category>BDD</shom:Category><shom:Extractable>false</shom:Extractable></shom:Layer>);
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildLayerList():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildLayerList()
			
			var xmlResult:XML = <LayerList />;
			
			Assert.assertTrue(xml == xmlResult);	
		}
		
		[Test]
		public function testBuildLayer():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildLayer(true, false, "WORLD_MODIS_1KM:MapAdmin",
				"WORLD_MODIS_1KM", "http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi", 
				"OGC:WMS", "1.1.0", "ESA CubeSERV");
			
			var xmlResult:XML = <Layer queryable="1" hidden="0"><Server service="OGC:WMS" version="1.1.0" title="ESA CubeSERV"><OnlineResource type="simple" href="http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi" xmlns="http://www.w3.org/1999/xlink"/></Server><Name>WORLD_MODIS_1KM:MapAdmin</Name><Title>WORLD_MODIS_1KM</Title></Layer>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml = writer.buildLayer(true, false, "WORLD_MODIS_1KM:MapAdmin",
				"WORLD_MODIS_1KM", "http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi", 
				"OGC:WMS", "1.1.0");
			
			xmlResult = <Layer queryable="1" hidden="0"><Server service="OGC:WMS" version="1.1.0"><OnlineResource type="simple" href="http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi" xmlns="http://www.w3.org/1999/xlink"/></Server><Name>WORLD_MODIS_1KM:MapAdmin</Name><Title>WORLD_MODIS_1KM</Title></Layer>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildAbstractLayer():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildAbstractLayer("Global maps derived from various  Earth Observation sensors / WORLD_MODIS_1KM:MapAdmin");
			
			var xmlResult:XML = <Abstract>Global maps derived from various  Earth Observation sensors / WORLD_MODIS_1KM:MapAdmin</Abstract>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml =  writer.buildAbstractLayer();
			
			Assert.assertNull(xml);		
		}
		
		[Test]
		public function testBuildDataURLLayer():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildDataURLLayer("http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi");
			
			var xmlResult:XML = <DataURL><OnlineResource type="simple" href="http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi" xmlns="http://www.w3.org/1999/xlink"></OnlineResource></DataURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildMetadataURLLayer():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildMetadataURLLayer("http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi");
			
			var xmlResult:XML = <MetadataURL><OnlineResource type="simple" href="http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi" xmlns="http://www.w3.org/1999/xlink"></OnlineResource></MetadataURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildSRSLayer():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var xml:XML = writer.buildSRSLayer("EPSG:4326");
			
			var xmlResult:XML = <SRS>EPSG:4326</SRS>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml = writer.buildSRSLayer();
			
			
			Assert.assertNull(xml);
		}
		
		[Test]
		public function testBuildDimensionListLayer():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var dimensions:Array = new Array();
			var dimension1:Object = {name:"my dimension", units:"meter", unitSym:"m", userValue:"100", multipleValues:true, nearestValue:true, current:true,  mydefault:"default"};
			var dimension2:Object = {name:"my dimension", units:"kmeter", unitSym:"km", userValue:"100", multipleValues:true, nearestValue:true, current:false,  mydefault:"default"};
			dimensions.push(dimension1);
			dimensions.push(dimension2);
						
			var xml:XML = writer.buildDimensionListLayer(dimensions);
			
			var xmlResult:XML = <DimensionList><Dimension name="my dimension" units="meter" unitSym="m" userValue="100" default="default" multipleValues="true" nearestValue="true" current="true">undefined</Dimension><Dimension name="my dimension" units="kmeter" unitSym="km" userValue="100" default="default" multipleValues="true" nearestValue="true" current="false">undefined</Dimension></DimensionList>;
			
			Assert.assertTrue(xml == xmlResult);
			
			xml = writer.buildDimensionListLayer(new Array());
			
			Assert.assertNull(xml);
			
			dimension1 = {units:"meter", unitSym:"m", userValue:"100", multipleValues:true, nearestValue:true, current:true,  mydefault:"default"};
			dimensions = new Array();
			dimensions.push(dimension1);
			
			xml = writer.buildDimensionListLayer(dimensions);
			
			Assert.assertNull(xml);
		}
		
		[Test]
		public function testBuildFormatListLayer():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var formats:Array = new Array();
			var format1:Object = {value:"image/png", current:true};
			formats.push(format1);
			var format2:Object = {value:"image/jpeg", current:false};
			formats.push(format2);
			var format3:Object = {value:"image/gif", current:false};
			formats.push(format3);
			
			var xml:XML = writer.buildFormatListLayer(formats);
			
			var xmlResult:XML = <FormatList><Format current="1">image/png</Format><Format current="0">image/jpeg</Format><Format current="0">image/gif</Format></FormatList>;
			
			Assert.assertTrue(xml == xmlResult);
			
			formats = new Array();
			
			xml = writer.buildFormatListLayer(formats);
			
			Assert.assertNull(xml);
		}
		
		[Test]
		public function testBuildStyleListLayer():void{
			var writer:WMC110Writer = new WMC110Writer();
			
			var styles:Array = new Array();
			var legendURL:Object = {href:" http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi?VERSION=1.1.0&amp;REQUEST=GetLegendIcon&amp;LAYER=WORLD_MODIS_1KM:MapAdmin&amp;SPATIAL_TYPE=RASTER&amp;STYLE=default&amp;FORMAT=image/gif", format:"image/gif", width:16, height:16 };
			var style1:Object = {current:true, name:"default", title:"default", abstract:"default", legendURL:legendURL};
			styles.push(style1);
			
			var xml:XML = writer.buildStyleListLayer(styles);
			
			var xmlResult:XML = <StyleList><Style current="1"><Name>default</Name><Title>default</Title><Abstract>default</Abstract><LegendURL width="16" height="16" format="image/gif"><OnlineResource type="simple" href=" http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi?VERSION=1.1.0&amp;amp;REQUEST=GetLegendIcon&amp;amp;LAYER=WORLD_MODIS_1KM:MapAdmin&amp;amp;SPATIAL_TYPE=RASTER&amp;amp;STYLE=default&amp;amp;FORMAT=image/gif" xmlns="http://www.w3.org/1999/xlink"/></LegendURL></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			styles = new Array();
			style1 = {current:true, SLDURL:"http://OnlineResource.com", SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			
			xml = writer.buildStyleListLayer(styles);
			
			xmlResult = <StyleList><Style current="1"><SLD><Name>my SLDName</Name><Title>my SLDTitle</Title><OnlineResource type="simple" href="http://OnlineResource.com" xmlns="http://www.w3.org/1999/xlink"/></SLD></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			styles = new Array();
			style1 = {current:true, SLDURL:"http://OnlineResource.com", StyledLayerDescriptor:new XML(<StyledLayerDescriptor>test</StyledLayerDescriptor>), SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			
			xml = writer.buildStyleListLayer(styles);
			
			Assert.assertNull(xml);
			
			styles = new Array();
			style1 = {current:true, StyledLayerDescriptor:new XML(<StyledLayerDescriptor>test</StyledLayerDescriptor>), SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			
			xml = writer.buildStyleListLayer(styles);
			
			xmlResult = <StyleList><Style current="1"><SLD><Name>my SLDName</Name><Title>my SLDTitle</Title><StyledLayerDescriptor>test</StyledLayerDescriptor></SLD></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			styles = new Array();
			style1 = {current:true, FeatureTypeStyle:new XML(<FeatureTypeStyle>test</FeatureTypeStyle>), SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			
			xml = writer.buildStyleListLayer(styles);
			
			xmlResult = <StyleList><Style current="1"><SLD><Name>my SLDName</Name><Title>my SLDTitle</Title><FeatureTypeStyle>test</FeatureTypeStyle></SLD></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			styles = new Array();
			style1 = {current:true, FeatureTypeStyle:new XML(<FeatureTypeStyle>test</FeatureTypeStyle>), SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			legendURL = {href:" http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi?VERSION=1.1.0&amp;REQUEST=GetLegendIcon&amp;LAYER=WORLD_MODIS_1KM:MapAdmin&amp;SPATIAL_TYPE=RASTER&amp;STYLE=default&amp;FORMAT=image/gif", format:"image/gif", width:16, height:16 };
			var style2:Object = {current:true, name:"default", title:"default", abstract:"default", legendURL:legendURL};
			styles.push(style2);
			
			xml = writer.buildStyleListLayer(styles);
			
			xmlResult = <StyleList><Style current="1"><SLD><Name>my SLDName</Name><Title>my SLDTitle</Title><FeatureTypeStyle>test</FeatureTypeStyle></SLD></Style><Style current="1"><Name>default</Name><Title>default</Title><Abstract>default</Abstract><LegendURL width="16" height="16" format="image/gif"><OnlineResource type="simple" href=" http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi?VERSION=1.1.0&amp;amp;REQUEST=GetLegendIcon&amp;amp;LAYER=WORLD_MODIS_1KM:MapAdmin&amp;amp;SPATIAL_TYPE=RASTER&amp;amp;STYLE=default&amp;amp;FORMAT=image/gif" xmlns="http://www.w3.org/1999/xlink"/></LegendURL></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
	}
}