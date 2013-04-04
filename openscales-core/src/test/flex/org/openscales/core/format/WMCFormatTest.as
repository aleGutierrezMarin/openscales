package org.openscales.core.format
{
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	import org.openscales.proj4as.proj.ProjParams;

	public class WMCFormatTest
	{
		
		[Embed(source="/assets/format/WMC/GeneralTest.xml",mimeType="application/octet-stream")]
		private const WMCGeneralType:Class;
		
		[Embed(source="/assets/format/WMC/LayerTypeTest.xml",mimeType="application/octet-stream")]
		private const WMCLayerType:Class;
		
		private var format:WMCFormat;
		
		public function WMCFormatTest()
		{
		}
		
		
		[Before]
		public function setUp():void
		{
			this.format = new WMCFormat();
		}
		
		
		[Test]
		public function shouldWMCParseGeneralType():void
		{
			var wmcFile:XML = new XML(new WMCGeneralType());
			var begin:Number = new Date().time;
			var end:Number;		
			
			this.format.read(wmcFile);
			
			end = new Date().time;
			var elapsed:Number = end-begin;
			Trace.debug("shouldWMCParseGeneralType - Elapsed time for parsing : "+elapsed);
			
			assertEquals("Wrong window width parsing", 500, this.format.windowSize.w);
			assertEquals("Wrong window height parsing", 300, this.format.windowSize.h);
			assertEquals("Wrong bbox left parsing", -180, this.format.generalBbox.left);
			assertEquals("Wrong bbox bottom parsing", -90, this.format.generalBbox.bottom);
			assertEquals("Wrong bbox right parsing", 180, this.format.generalBbox.right);
			assertEquals("Wrong bbox top parsing", 90, this.format.generalBbox.top);
			assertEquals("Wrong bbox SRS parsing", ProjProjection.getProjProjection("EPSG:4326").srsCode, this.format.generalBbox.projection.srsCode);
		}
		
		[Test]
		public function shouldWMCParseLayerType():void
		{
			var wmcFile:XML = new XML(new WMCLayerType());
			
			var begin:Number = new Date().time;
			var end:Number;		
			
			this.format.read(wmcFile);
			
			end = new Date().time;
			var elapsed:Number = end-begin;
			Trace.debug("shouldWMCParseLayerType - Elapsed time for parsing : "+elapsed);
			
			var layers:Vector.<Layer> = this.format.layerList;
			assertEquals("wrong layer number", 2, layers.length);
			var layer1:Layer = layers[0];
			assertTrue("Wrong layer service parsing", (layer1 is WMS));
			assertEquals("Wrong layer version parsing", "1.1.1", (layer1 as WMS).version);
			assertEquals("Wrong service url parsing", "http://openscales.org/geoserver/ows", (layer1 as WMS).url);
			assertEquals("Wrong layer name parsing", "bluemarble", (layer1 as WMS).layers);
			assertEquals("Wrong layer title parsing", "bluemarble_I18N", (layer1 as WMS).identifier);
			assertTrue("Wrong layer minScaleDenominator", (0.000003832 <(layer1 as WMS).minResolution.value) && (0.000003834 >(layer1 as WMS).minResolution.value))
			assertEquals("Wrong layer minScaleDenominator projection", ProjProjection.getProjProjection("EPSG:4326").srsCode, (layer1 as WMS).minResolution.projection.srsCode);
			assertTrue("Wrong layer maxScaleDenominator", (0.00004651 <(layer1 as WMS).maxResolution.value) && (0.00004653 >(layer1 as WMS).maxResolution.value))
			assertEquals("Wrong layer maxScaleDenominator projection", ProjProjection.getProjProjection("EPSG:4326").srsCode, (layer1 as WMS).maxResolution.projection.srsCode);
			assertEquals("Wrong layer srs parsing", "EPSG:4326", (layer1 as WMS).projection.srsCode);
			assertEquals("Wrong layer default format parsing", "image/gif", (layer1 as WMS).format);	
		}
		
		[Test]
		public function testWrite():void{
			var format:WMCFormat = new WMCFormat();
			
			var layerWMS:WMS = new WMS("layerNameWMS", "urlWMS", "my layer", "default", "image/png");
			layerWMS.displayedName = "displayedNameWMS";
			var layerWFS:WFS = new WFS("layerNameWFS", "urlWFS", "polyline", "2.0.0");
			layerWFS.displayedName = "displayedNameWFS";
			var layerWMTS:WMTS = new WMTS("layerNameWMTS", "urlWMTS", "layerWMTS","tileMatrixWMTS");
			layerWMTS.displayedName = "displayedNameWTMS";

			var map:Map = new Map(600, 400, new ProjProjection("EPSG:4326"));
			map.resolution = new Resolution(0.01955206909139374,new ProjProjection("EPSG:4326"));
			map.minResolution = new Resolution(0.00010590128,new ProjProjection("EPSG:4326"));
			map.maxExtent = new Bounds(-180,-90,180,90);
			map.center = new Location(2, 47.286, new ProjProjection("EPSG:4326"));
			
			map.addLayer(layerWMS);
			map.addLayer(layerWFS);
			map.addLayer(layerWMTS);
			
			
			var context:Object = {map:map, title:"mon titre", id:"mon id"}; 
			var xml:XML = (format.write(context)) as XML;
			
			var xmlResult:XML = 
				<ViewContext id="mon id" version="1.1.0" xmlns="http://www.opengeospatial.net/context" xmlns:sld="http://www.opengeospatial.net/sld" xmlns:xlink="http://www.w3.org/1999/xlink">
				  <General>
					<BoundingBox SRS="EPSG:4326" minx="-3.865620727418123" miny="43.37558618172125" maxx="7.865620727418123" maxy="51.19641381827875"/>
					<Title>
					  mon titre
					</Title>
					<Window width="600" height="400"/>
				  </General>
				  <LayerList>
					<Layer queryable="1" hidden="0">
					  <Server service="OGC:WMS" version="1.1.1">
						<OnlineResource xlink:type="simple" xlink:href="urlWMS"/>
					  </Server>
					  <Name>
						layerNameWMS
					  </Name>
					  <Title>
						displayedNameWMS
					  </Title>
					</Layer>
					<Layer queryable="1" hidden="0">
					  <Server service="OGC:WFS" version="2.0.0">
						<OnlineResource xlink:type="simple" xlink:href="urlWFS"/>
					  </Server>
					  <Name>
						layerNameWFS
					  </Name>
					  <Title>
						displayedNameWFS
					  </Title>
					</Layer>
					<Layer queryable="1" hidden="0">
					  <Server service="OGC:WMTS" version="1.0.0">
						<OnlineResource xlink:type="simple" xlink:href="urlWMTS"/>
					  </Server>
					  <Name>
						layerWMTS
					  </Name>
					  <Title>
						displayedNameWTMS
					  </Title>
					  <FormatList>
						<Format current="1">
						  image/jpeg
						</Format>
					  </FormatList>
					</Layer>
				  </LayerList>
				</ViewContext>
				;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			context = {map:map, title:"mon titre"}; 
			
			Assert.assertNull(format.write(context));
			
			context = {map:"toto", title:"mon titre", id:"mon id"}; 
			
			Assert.assertNull(format.write(context));
		}
		
		[Test]
		public function testBuildViewContext():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildViewContextNode("eos_data_gateways");
			
			var xmlResult:XML = <ViewContext id="eos_data_gateways" version="1.1.0" xmlns="http://www.opengeospatial.net/context" xmlns:sld="http://www.opengeospatial.net/sld" xmlns:xlink="http://www.w3.org/1999/xlink"/>;
			
			Assert.assertTrue(xml == xmlResult);		
		}
		
		[Test]
		public function testBuildGeneral():void{
			var format:WMCFormat = new WMCFormat();
			
			var bounds:Bounds = new Bounds(-180.000000, -90.000000, 180.000000, 90.000000, new ProjParams().srsCode = "EPSG:4326");
			var xml:XML = format.buildGeneralNode(bounds, "EOS Data Gateways");
			
			var xmlResult:XML = <General><BoundingBox SRS="EPSG:4326" minx="-180" miny="-90" maxx="180" maxy="90"/><Title>EOS Data Gateways</Title></General>;
			
			Assert.assertTrue(xml = xmlResult);			
		}		
		
		[Test]
		public function testBuildWindow():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildWindowNode(500, 300);
			
			var xmlResult:XML = <Window width="500" height="300"/>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildBoundingBox():void{
			var format:WMCFormat = new WMCFormat();
			
			var bounds:Bounds = new Bounds(-180.000000, -90.000000, 180.000000, 90.000000, new ProjParams().srsCode = "EPSG:4326");
			var xml:XML = format.buildBoundingBoxNode(bounds);
			
			var xmlResult:XML = <BoundingBox SRS="EPSG:4326" minx="-180" miny="-90" maxx="180" maxy="90" />;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildKeywordList():void{
			var format:WMCFormat = new WMCFormat();
			var keywords:Array = new Array();
			
			keywords.push("keyword 1");
			keywords.push("keyword 2");
			keywords.push("keyword 3");
			
			var xml:XML = format.buildKeywordListNode(keywords);
			
			var xmlResult:XML = <KeywordList><Keyword>keyword 1</Keyword><Keyword>keyword 2</Keyword><Keyword>keyword 3</Keyword></KeywordList>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildLogoURL():void{						
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildLogoURLNode("http://eos.nasa.gov/imswelcome", "image/gif", 130, 74);
			
			var xmlResult:XML = <LogoURL width="130" height="74" format="image/gif"><OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"></OnlineResource></LogoURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml = format.buildLogoURLNode("http://eos.nasa.gov/imswelcome", "image/gif");
			
			xmlResult = <LogoURL format="image/gif"><OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"/></LogoURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildDescriptionURL():void{						
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildDescriptionURLNode("http://eos.nasa.gov/imswelcome", "text/html");
			
			var xmlResult:XML = <DescriptionURL format="text/html"><OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"/></DescriptionURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml = format.buildDescriptionURLNode("http://eos.nasa.gov/imswelcome");
			
			xmlResult = <DescriptionURL><OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"/></DescriptionURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildOnlineResource():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildOnlineResourceNode("http://eos.nasa.gov/imswelcome");
			
			var xmlResult:XML = <OnlineResource type="simple" href="http://eos.nasa.gov/imswelcome" xmlns="http://www.w3.org/1999/xlink"/>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildContactInformation():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildContactInformationNode("Tom Kralidis", "Canada Centre for Remote Sensing",
				"Systems Scientist", "postal", "615 Booth Street, room 650", "Ottawa", "Ontario", "K1A 0E9",
				"Canada", "+01 613 947 1828", "+01 613 947 2410", "tom.kralidis@ccrs.nrcan.gc.ca");
			
			var xmlResult:XML = <ContactInformation><ContactPersonPrimary><ContactPerson>Tom Kralidis</ContactPerson><ContactOrganization>Canada Centre for Remote Sensing</ContactOrganization></ContactPersonPrimary><ContactPosition>Systems Scientist</ContactPosition><ContactAddress><AddressType>postal</AddressType><Address>615 Booth Street, room 650</Address><City>Ottawa</City><StateOrProvince>Ontario</StateOrProvince><PostCode>K1A 0E9</PostCode><Country>Canada</Country></ContactAddress><ContactVoiceTelephone>+01 613 947 1828</ContactVoiceTelephone><ContactFacsimileTelephone>+01 613 947 2410</ContactFacsimileTelephone><ContactElectronicMailAddress>tom.kralidis@ccrs.nrcan.gc.ca</ContactElectronicMailAddress></ContactInformation>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildContactPersonPrimary():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildContactPersonPrimaryNode("Tom Kralidis", "Canada Centre for Remote Sensing");
			
			var xmlResult:XML = <ContactPersonPrimary><ContactPerson>Tom Kralidis</ContactPerson><ContactOrganization>Canada Centre for Remote Sensing</ContactOrganization></ContactPersonPrimary>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildContactAddress():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildContactAddressNode("postal", "615 Booth Street, room 650", "Ottawa", "Ontario", "K1A 0E9", "Canada");
			
			var xmlResult:XML = <ContactAddress><AddressType>postal </AddressType><Address>615 Booth Street, room 650</Address><City>Ottawa</City><StateOrProvince>Ontario</StateOrProvince><PostCode>K1A 0E9</PostCode><Country>Canada</Country></ContactAddress>;
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildExtension():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildExtensionNode(new XML(<shom:Layer xmlns:shom="http://www.shom.fr"><shom:Category>BDD</shom:Category><shom:Extractable>false</shom:Extractable></shom:Layer>));
			
			var xmlResult:XML = <Extension></Extension>;
			xmlResult.appendChild(<shom:Layer xmlns:shom="http://www.shom.fr"><shom:Category>BDD</shom:Category><shom:Extractable>false</shom:Extractable></shom:Layer>);
			
			Assert.assertTrue(xml == xmlResult);
		}
		
		[Test]
		public function testBuildLayerList():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildLayerListNode()
			
			var xmlResult:XML = <LayerList />;
			
			Assert.assertTrue(xml == xmlResult);	
		}
		
		[Test]
		public function testBuildLayer():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildLayerNode(true, false, "WORLD_MODIS_1KM:MapAdmin",
				"WORLD_MODIS_1KM", "http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi", 
				"OGC:WMS", "1.1.0", "ESA CubeSERV");
			
			var xmlResult:XML = <Layer queryable="1" hidden="0"><Server service="OGC:WMS" version="1.1.0" title="ESA CubeSERV"><OnlineResource type="simple" href="http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi" xmlns="http://www.w3.org/1999/xlink"/></Server><Name>WORLD_MODIS_1KM:MapAdmin</Name><Title>WORLD_MODIS_1KM</Title></Layer>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml = format.buildLayerNode(true, false, "WORLD_MODIS_1KM:MapAdmin",
				"WORLD_MODIS_1KM", "http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi", 
				"OGC:WMS", "1.1.0");
			
			xmlResult = <Layer queryable="1" hidden="0"><Server service="OGC:WMS" version="1.1.0"><OnlineResource type="simple" href="http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi" xmlns="http://www.w3.org/1999/xlink"/></Server><Name>WORLD_MODIS_1KM:MapAdmin</Name><Title>WORLD_MODIS_1KM</Title></Layer>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildAbstractLayer():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildAbstractLayerNode("Global maps derived from various  Earth Observation sensors / WORLD_MODIS_1KM:MapAdmin");
			
			var xmlResult:XML = <Abstract>Global maps derived from various  Earth Observation sensors / WORLD_MODIS_1KM:MapAdmin</Abstract>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml =  format.buildAbstractLayerNode();
			
			Assert.assertNull(xml);		
		}
		
		[Test]
		public function testBuildDataURLLayer():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildDataURLLayerNode("http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi");
			
			var xmlResult:XML = <DataURL><OnlineResource type="simple" href="http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi" xmlns="http://www.w3.org/1999/xlink"></OnlineResource></DataURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildMetadataURLLayer():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildMetadataURLLayerNode("http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi");
			
			var xmlResult:XML = <MetadataURL><OnlineResource type="simple" href="http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi" xmlns="http://www.w3.org/1999/xlink"></OnlineResource></MetadataURL>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
		
		[Test]
		public function testBuildSRSLayer():void{
			var format:WMCFormat = new WMCFormat();
			
			var xml:XML = format.buildSRSLayerNode("EPSG:4326");
			
			var xmlResult:XML = <SRS>EPSG:4326</SRS>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			xml = format.buildSRSLayerNode();
			
			
			Assert.assertNull(xml);
		}
		
		[Test]
		public function testBuildDimensionListLayer():void{
			var format:WMCFormat = new WMCFormat();
			
			var dimensions:Array = new Array();
			var dimension1:Object = {name:"my dimension", units:"meter", unitSym:"m", userValue:"100", multipleValues:true, nearestValue:true, current:true,  mydefault:"default"};
			var dimension2:Object = {name:"my dimension", units:"kmeter", unitSym:"km", userValue:"100", multipleValues:true, nearestValue:true, current:false,  mydefault:"default"};
			dimensions.push(dimension1);
			dimensions.push(dimension2);
			
			var xml:XML = format.buildDimensionListLayerNode(dimensions);
			
			var xmlResult:XML = <DimensionList><Dimension name="my dimension" units="meter" unitSym="m" userValue="100" default="default" multipleValues="true" nearestValue="true" current="true">undefined</Dimension><Dimension name="my dimension" units="kmeter" unitSym="km" userValue="100" default="default" multipleValues="true" nearestValue="true" current="false">undefined</Dimension></DimensionList>;
			
			Assert.assertTrue(xml == xmlResult);
			
			xml = format.buildDimensionListLayerNode(new Array());
			
			Assert.assertNull(xml);
			
			dimension1 = {units:"meter", unitSym:"m", userValue:"100", multipleValues:true, nearestValue:true, current:true,  mydefault:"default"};
			dimensions = new Array();
			dimensions.push(dimension1);
			
			xml = format.buildDimensionListLayerNode(dimensions);
			
			Assert.assertNull(xml);
		}
		
		[Test]
		public function testBuildFormatListLayer():void{
			var format:WMCFormat = new WMCFormat();
			
			var formats:Array = new Array();
			var format1:Object = {value:"image/png", current:true};
			formats.push(format1);
			var format2:Object = {value:"image/jpeg", current:false};
			formats.push(format2);
			var format3:Object = {value:"image/gif", current:false};
			formats.push(format3);
			
			var xml:XML = format.buildFormatListLayerNode(formats);
			
			var xmlResult:XML = <FormatList><Format current="1">image/png</Format><Format current="0">image/jpeg</Format><Format current="0">image/gif</Format></FormatList>;
			
			Assert.assertTrue(xml == xmlResult);
			
			formats = new Array();
			
			xml = format.buildFormatListLayerNode(formats);
			
			Assert.assertNull(xml);
		}
		
		[Test]
		public function testBuildStyleListLayer():void{
			var format:WMCFormat = new WMCFormat();
			
			var styles:Array = new Array();
			var legendURL:Object = {href:" http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi?VERSION=1.1.0&amp;REQUEST=GetLegendIcon&amp;LAYER=WORLD_MODIS_1KM:MapAdmin&amp;SPATIAL_TYPE=RASTER&amp;STYLE=default&amp;FORMAT=image/gif", format:"image/gif", width:16, height:16 };
			var style1:Object = {current:true, name:"default", title:"default", abstract:"default", legendURL:legendURL};
			styles.push(style1);
			
			var xml:XML = format.buildStyleListLayerNode(styles);
			
			var xmlResult:XML = <StyleList><Style current="1"><Name>default</Name><Title>default</Title><Abstract>default</Abstract><LegendURL width="16" height="16" format="image/gif"><OnlineResource type="simple" href=" http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi?VERSION=1.1.0&amp;amp;REQUEST=GetLegendIcon&amp;amp;LAYER=WORLD_MODIS_1KM:MapAdmin&amp;amp;SPATIAL_TYPE=RASTER&amp;amp;STYLE=default&amp;amp;FORMAT=image/gif" xmlns="http://www.w3.org/1999/xlink"/></LegendURL></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			styles = new Array();
			style1 = {current:true, SLDURL:"http://OnlineResource.com", SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			
			xml = format.buildStyleListLayerNode(styles);
			
			xmlResult = <StyleList><Style current="1"><SLD><Name>my SLDName</Name><Title>my SLDTitle</Title><OnlineResource type="simple" href="http://OnlineResource.com" xmlns="http://www.w3.org/1999/xlink"/></SLD></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			styles = new Array();
			style1 = {current:true, SLDURL:"http://OnlineResource.com", StyledLayerDescriptor:new XML(<StyledLayerDescriptor>test</StyledLayerDescriptor>), SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			
			xml = format.buildStyleListLayerNode(styles);
			
			Assert.assertNull(xml);
			
			styles = new Array();
			style1 = {current:true, StyledLayerDescriptor:new XML(<StyledLayerDescriptor>test</StyledLayerDescriptor>), SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			
			xml = format.buildStyleListLayerNode(styles);
			
			xmlResult = <StyleList><Style current="1"><SLD><Name>my SLDName</Name><Title>my SLDTitle</Title><StyledLayerDescriptor>test</StyledLayerDescriptor></SLD></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			styles = new Array();
			style1 = {current:true, FeatureTypeStyle:new XML(<FeatureTypeStyle>test</FeatureTypeStyle>), SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			
			xml = format.buildStyleListLayerNode(styles);
			
			xmlResult = <StyleList><Style current="1"><SLD><Name>my SLDName</Name><Title>my SLDTitle</Title><FeatureTypeStyle>test</FeatureTypeStyle></SLD></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
			
			styles = new Array();
			style1 = {current:true, FeatureTypeStyle:new XML(<FeatureTypeStyle>test</FeatureTypeStyle>), SLDName:"my SLDName", SLDTitle:"my SLDTitle"};
			styles.push(style1);
			legendURL = {href:" http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi?VERSION=1.1.0&amp;REQUEST=GetLegendIcon&amp;LAYER=WORLD_MODIS_1KM:MapAdmin&amp;SPATIAL_TYPE=RASTER&amp;STYLE=default&amp;FORMAT=image/gif", format:"image/gif", width:16, height:16 };
			var style2:Object = {current:true, name:"default", title:"default", abstract:"default", legendURL:legendURL};
			styles.push(style2);
			
			xml = format.buildStyleListLayerNode(styles);
			
			xmlResult = <StyleList><Style current="1"><SLD><Name>my SLDName</Name><Title>my SLDTitle</Title><FeatureTypeStyle>test</FeatureTypeStyle></SLD></Style><Style current="1"><Name>default</Name><Title>default</Title><Abstract>default</Abstract><LegendURL width="16" height="16" format="image/gif"><OnlineResource type="simple" href=" http://mapserv2.esrin.esa.it/cubestor/cubeserv/cubeserv.cgi?VERSION=1.1.0&amp;amp;REQUEST=GetLegendIcon&amp;amp;LAYER=WORLD_MODIS_1KM:MapAdmin&amp;amp;SPATIAL_TYPE=RASTER&amp;amp;STYLE=default&amp;amp;FORMAT=image/gif" xmlns="http://www.w3.org/1999/xlink"/></LegendURL></Style></StyleList>;
			
			Assert.assertTrue(xml.toString() == xmlResult.toString());
		}
	}
}