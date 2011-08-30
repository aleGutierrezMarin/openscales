package org.openscales.core.layer.capabilities
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.ogc.wmts.TileMatrixSet;
	
	public class WMTS100Test
	{
		
		public function WMTS100Test() {}
		
		[Test]
		public function testRead():void 
		{
			// Creating an instance of WMTS100
			var instance:WMTS100 = new WMTS100();
			
			var WMTSLayers:HashMap = instance.read(xmlData);
			
			// With valid xml, method should return an non null value
			assertNotNull(WMTSLayers);
			// hash map sould be of size 3 (xmlData contains 3 Layer tags)
			assertEquals(WMTSLayers.size(), 3);
			
			//Getting layer capabilities
			var layerCapabilities:HashMap = WMTSLayers.getValue("medford:buildings");
			// Returned value should be non null
			assertNotNull(layerCapabilities);
			// layer capabilites should contains three keys: TileMatrixSets, Formats, Styles
			assertTrue(layerCapabilities.containsKey("TileMatrixSets"));
			assertTrue(layerCapabilities.containsKey("Formats"));
			assertTrue(layerCapabilities.containsKey("Styles"));
			assertTrue(layerCapabilities.containsKey("Identifier"));
			assertTrue(layerCapabilities.containsKey("Title"));
			assertEquals(5,layerCapabilities.size());
			
			//Getting tile matrix sets hashmap
			var tileMatrixSets:HashMap = layerCapabilities.getValue("TileMatrixSets");
			// Returned value should be non null
			assertNotNull(tileMatrixSets);
			// Returned value should be a 2 element hashmap
			assertEquals(tileMatrixSets.size(), 2);
			// Getting a tile matrix set
			var tileMatrixSet:TileMatrixSet = tileMatrixSets.getValue("EPSG:4326");
			// Returned value should not be null
			assertNotNull(tileMatrixSet);
			// returned value should be the one expected
			assertEquals("EPSG:4326", tileMatrixSet.supportedCRS);
			// getting tile matrices
			var tileMatrices:HashMap = tileMatrixSet.tileMatrices;
			// Returned value should not be null
			assertNotNull(tileMatrices);
			// Size should be 31
			assertEquals(31, tileMatrices.size());
			
			// Getting styles array
			var styles:Array = layerCapabilities.getValue("Styles");
			// Returned value should not be null
			assertNotNull(styles);
			// Size should be 1
			assertEquals(styles.length,1);
			// Value should be consitent with XML
			assertEquals(styles[0] as String,"_null");
			
			// Getting formats array
			var formats:Array = layerCapabilities.getValue("Formats");
			// Returned value should not be null
			assertNotNull(formats);
			// Size should be 5
			assertEquals(formats.length,5);
			// Value should be consitent with XML
			assertEquals(formats[0] as String,"image/png");
			assertEquals(formats[1] as String,"image/gif");
			assertEquals(formats[2] as String,"image/png8");
			assertEquals(formats[3] as String,"image/jpeg");
			assertEquals(formats[4] as String,"application/vnd.google-earth.kml+xml");		
		}
		
		// Sample xml data
		private var xmlData:XML = <Capabilities xmlns="http://www.opengis.net/wmts/1.0"
xmlns:ows="http://www.opengis.net/ows/1.1"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:gml="http://www.opengis.net/gml" xsi:schemaLocation="http://www.opengis.net/wmts/1.0 http://geowebcache.org/schema/opengis/wmts/1.0.0/wmtsGetCapabilities_response.xsd"
version="1.0.0">
<ows:ServiceIdentification>
  <ows:Title>Web Map Tile Service - GeoWebCache</ows:Title>
  <ows:ServiceType>OGC WMTS</ows:ServiceType>
  <ows:ServiceTypeVersion>1.0.0</ows:ServiceTypeVersion>
</ows:ServiceIdentification>
<ows:ServiceProvider>
  <ows:ProviderName>http://v2.suite.opengeo.org/geoserver/gwc/service/wmts</ows:ProviderName>
  <ows:ProviderSite xlink:href="http://v2.suite.opengeo.org/geoserver/gwc/service/wmts" />
  <ows:ServiceContact>
    <ows:IndividualName>GeoWebCache User</ows:IndividualName>
  </ows:ServiceContact>
</ows:ServiceProvider>
<ows:OperationsMetadata>
  <ows:Operation name="GetCapabilities">
    <ows:DCP>
      <ows:HTTP>
        <ows:Get xlink:href="http://v2.suite.opengeo.org/geoserver/gwc/service/wmts?">
          <ows:Constraint name="GetEncoding">
            <ows:AllowedValues>
              <ows:Value>KVP</ows:Value>
            </ows:AllowedValues>
          </ows:Constraint>
        </ows:Get>
      </ows:HTTP>
    </ows:DCP>
  </ows:Operation>
  <ows:Operation name="GetTile">
    <ows:DCP>
      <ows:HTTP>
        <ows:Get xlink:href="http://v2.suite.opengeo.org/geoserver/gwc/service/wmts?">
          <ows:Constraint name="GetEncoding">
            <ows:AllowedValues>
              <ows:Value>KVP</ows:Value>
            </ows:AllowedValues>
          </ows:Constraint>
        </ows:Get>
      </ows:HTTP>
    </ows:DCP>
  </ows:Operation>
  <ows:Operation name="GetFeatureInfo">
    <ows:DCP>
      <ows:HTTP>
        <ows:Get xlink:href="http://v2.suite.opengeo.org/geoserver/gwc/service/wmts?">
          <ows:Constraint name="GetEncoding">
            <ows:AllowedValues>
              <ows:Value>KVP</ows:Value>
            </ows:AllowedValues>
          </ows:Constraint>
        </ows:Get>
      </ows:HTTP>
    </ows:DCP>
  </ows:Operation>
</ows:OperationsMetadata>
<Contents>
  <Layer>
    <ows:Title>medford:hydro</ows:Title>
    <ows:WGS84BoundingBox>
      <ows:LowerCorner>-122.904 42.29</ows:LowerCorner>
      <ows:UpperCorner>-122.777 42.397</ows:UpperCorner>
    </ows:WGS84BoundingBox>
    <ows:Identifier>medford:hydro</ows:Identifier>
    <Style isDefault="true">
      <ows:Identifier>_null</ows:Identifier>
    </Style>
    <Format>image/png</Format>
    <Format>image/gif</Format>
    <Format>image/png8</Format>
    <Format>image/jpeg</Format>
    <Format>application/vnd.google-earth.kml+xml</Format>
    <InfoFormat>text/plain</InfoFormat>
    <InfoFormat>text/html</InfoFormat>
    <InfoFormat>application/vnd.ogc.gml</InfoFormat>
    <TileMatrixSetLink>
		<TileMatrixSet>EPSG:900913</TileMatrixSet>
    </TileMatrixSetLink>
	<TileMatrixSetLink>
		<TileMatrixSet>EPSG:4326</TileMatrixSet>
    </TileMatrixSetLink>
  </Layer>
  <Layer>
    <ows:Title>medford:buildings</ows:Title>
    <ows:WGS84BoundingBox>
      <ows:LowerCorner>-122.915 42.287</ows:LowerCorner>
      <ows:UpperCorner>-122.777 42.404</ows:UpperCorner>
    </ows:WGS84BoundingBox>
    <ows:Identifier>medford:buildings</ows:Identifier>
    <Style isDefault="true">
      <ows:Identifier>_null</ows:Identifier>
    </Style>
    <Format>image/png</Format>
    <Format>image/gif</Format>
    <Format>image/png8</Format>
    <Format>image/jpeg</Format>
    <Format>application/vnd.google-earth.kml+xml</Format>
    <InfoFormat>text/plain</InfoFormat>
    <InfoFormat>text/html</InfoFormat>
    <InfoFormat>application/vnd.ogc.gml</InfoFormat>
    <TileMatrixSetLink>
		<TileMatrixSet>EPSG:900913</TileMatrixSet>
    </TileMatrixSetLink>
	<TileMatrixSetLink>
		<TileMatrixSet>EPSG:4326</TileMatrixSet>
    </TileMatrixSetLink>
  </Layer>
  <Layer>
    <ows:Title>medford:citylimits</ows:Title>
    <ows:WGS84BoundingBox>
      <ows:LowerCorner>-122.911 42.289</ows:LowerCorner>
      <ows:UpperCorner>-122.777 42.398</ows:UpperCorner>
    </ows:WGS84BoundingBox>
    <ows:Identifier>medford:citylimits</ows:Identifier>
    <Style isDefault="true">
      <ows:Identifier>_null</ows:Identifier>
    </Style>
    <Format>image/png</Format>
    <Format>image/gif</Format>
    <Format>image/png8</Format>
    <Format>image/jpeg</Format>
    <Format>application/vnd.google-earth.kml+xml</Format>
    <InfoFormat>text/plain</InfoFormat>
    <InfoFormat>text/html</InfoFormat>
    <InfoFormat>application/vnd.ogc.gml</InfoFormat>
    <TileMatrixSetLink>
		<TileMatrixSet>EPSG:900913</TileMatrixSet>
    </TileMatrixSetLink>
	<TileMatrixSetLink>
		<TileMatrixSet>EPSG:4326</TileMatrixSet>
    </TileMatrixSetLink>
</Layer>
<TileMatrixSet>
    <ows:Identifier>EPSG:4326</ows:Identifier>
    <ows:SupportedCRS>urn:ogc:def:crs:EPSG::4326</ows:SupportedCRS>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:0</ows:Identifier>
      <ScaleDenominator>2.795411320143589E8</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>2</MatrixWidth>
      <MatrixHeight>1</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:1</ows:Identifier>
      <ScaleDenominator>1.3977056600717944E8</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>4</MatrixWidth>
      <MatrixHeight>2</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:2</ows:Identifier>
      <ScaleDenominator>6.988528300358972E7</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>8</MatrixWidth>
      <MatrixHeight>4</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:3</ows:Identifier>
      <ScaleDenominator>3.494264150179486E7</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>16</MatrixWidth>
      <MatrixHeight>8</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:4</ows:Identifier>
      <ScaleDenominator>1.747132075089743E7</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>32</MatrixWidth>
      <MatrixHeight>16</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:5</ows:Identifier>
      <ScaleDenominator>8735660.375448715</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>64</MatrixWidth>
      <MatrixHeight>32</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:6</ows:Identifier>
      <ScaleDenominator>4367830.1877243575</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>128</MatrixWidth>
      <MatrixHeight>64</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:7</ows:Identifier>
      <ScaleDenominator>2183915.0938621787</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>256</MatrixWidth>
      <MatrixHeight>128</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:8</ows:Identifier>
      <ScaleDenominator>1091957.5469310894</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>512</MatrixWidth>
      <MatrixHeight>256</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:9</ows:Identifier>
      <ScaleDenominator>545978.7734655447</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>1024</MatrixWidth>
      <MatrixHeight>512</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:10</ows:Identifier>
      <ScaleDenominator>272989.38673277234</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>2048</MatrixWidth>
      <MatrixHeight>1024</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:11</ows:Identifier>
      <ScaleDenominator>136494.69336638617</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>4096</MatrixWidth>
      <MatrixHeight>2048</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:12</ows:Identifier>
      <ScaleDenominator>68247.34668319309</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>8192</MatrixWidth>
      <MatrixHeight>4096</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:13</ows:Identifier>
      <ScaleDenominator>34123.67334159654</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>16384</MatrixWidth>
      <MatrixHeight>8192</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:14</ows:Identifier>
      <ScaleDenominator>17061.83667079827</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>32768</MatrixWidth>
      <MatrixHeight>16384</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:15</ows:Identifier>
      <ScaleDenominator>8530.918335399136</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>65536</MatrixWidth>
      <MatrixHeight>32768</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:16</ows:Identifier>
      <ScaleDenominator>4265.459167699568</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>131072</MatrixWidth>
      <MatrixHeight>65536</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:17</ows:Identifier>
      <ScaleDenominator>2132.729583849784</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>262144</MatrixWidth>
      <MatrixHeight>131072</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:18</ows:Identifier>
      <ScaleDenominator>1066.364791924892</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>524288</MatrixWidth>
      <MatrixHeight>262144</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:19</ows:Identifier>
      <ScaleDenominator>533.182395962446</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>1048576</MatrixWidth>
      <MatrixHeight>524288</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:20</ows:Identifier>
      <ScaleDenominator>266.591197981223</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>2097152</MatrixWidth>
      <MatrixHeight>1048576</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:21</ows:Identifier>
      <ScaleDenominator>133.2955989906115</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>4194304</MatrixWidth>
      <MatrixHeight>2097152</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:22</ows:Identifier>
      <ScaleDenominator>66.64779949530575</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>8388608</MatrixWidth>
      <MatrixHeight>4194304</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:23</ows:Identifier>
      <ScaleDenominator>33.323899747652874</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>16777216</MatrixWidth>
      <MatrixHeight>8388608</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:24</ows:Identifier>
      <ScaleDenominator>16.661949873826437</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>33554432</MatrixWidth>
      <MatrixHeight>16777216</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:25</ows:Identifier>
      <ScaleDenominator>8.330974936913218</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>67108864</MatrixWidth>
      <MatrixHeight>33554432</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:26</ows:Identifier>
      <ScaleDenominator>4.165487468456609</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>134217728</MatrixWidth>
      <MatrixHeight>67108864</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:27</ows:Identifier>
      <ScaleDenominator>2.0827437342283046</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>268435456</MatrixWidth>
      <MatrixHeight>134217728</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:28</ows:Identifier>
      <ScaleDenominator>1.0413718671141523</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>536870912</MatrixWidth>
      <MatrixHeight>268435456</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:29</ows:Identifier>
      <ScaleDenominator>0.5206859335570762</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>1073741824</MatrixWidth>
      <MatrixHeight>536870912</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:4326:30</ows:Identifier>
      <ScaleDenominator>0.2603429667785381</ScaleDenominator>
      <TopLeftCorner>90.0 -180.0</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>2147483648</MatrixWidth>
      <MatrixHeight>1073741824</MatrixHeight>
    </TileMatrix>
  </TileMatrixSet> 
  <TileMatrixSet>
    <ows:Identifier>EPSG:900913</ows:Identifier>
    <ows:SupportedCRS>urn:ogc:def:crs:EPSG::900913</ows:SupportedCRS>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:0</ows:Identifier>
      <ScaleDenominator>5.590822639508929E8</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>1</MatrixWidth>
      <MatrixHeight>1</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:1</ows:Identifier>
      <ScaleDenominator>2.7954113197544646E8</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>2</MatrixWidth>
      <MatrixHeight>2</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:2</ows:Identifier>
      <ScaleDenominator>1.3977056598772323E8</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>4</MatrixWidth>
      <MatrixHeight>4</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:3</ows:Identifier>
      <ScaleDenominator>6.988528299386162E7</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>8</MatrixWidth>
      <MatrixHeight>8</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:4</ows:Identifier>
      <ScaleDenominator>3.494264149693081E7</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>16</MatrixWidth>
      <MatrixHeight>16</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:5</ows:Identifier>
      <ScaleDenominator>1.7471320748465404E7</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>32</MatrixWidth>
      <MatrixHeight>32</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:6</ows:Identifier>
      <ScaleDenominator>8735660.374232702</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>64</MatrixWidth>
      <MatrixHeight>64</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:7</ows:Identifier>
      <ScaleDenominator>4367830.187116351</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>128</MatrixWidth>
      <MatrixHeight>128</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:8</ows:Identifier>
      <ScaleDenominator>2183915.0935581755</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>256</MatrixWidth>
      <MatrixHeight>256</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:9</ows:Identifier>
      <ScaleDenominator>1091957.5467790877</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>512</MatrixWidth>
      <MatrixHeight>512</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:10</ows:Identifier>
      <ScaleDenominator>545978.7733895439</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>1024</MatrixWidth>
      <MatrixHeight>1024</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:11</ows:Identifier>
      <ScaleDenominator>272989.38669477194</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>2048</MatrixWidth>
      <MatrixHeight>2048</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:12</ows:Identifier>
      <ScaleDenominator>136494.69334738597</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>4096</MatrixWidth>
      <MatrixHeight>4096</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:13</ows:Identifier>
      <ScaleDenominator>68247.34667369298</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>8192</MatrixWidth>
      <MatrixHeight>8192</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:14</ows:Identifier>
      <ScaleDenominator>34123.67333684649</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>16384</MatrixWidth>
      <MatrixHeight>16384</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:15</ows:Identifier>
      <ScaleDenominator>17061.836668423246</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>32768</MatrixWidth>
      <MatrixHeight>32768</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:16</ows:Identifier>
      <ScaleDenominator>8530.918334211623</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>65536</MatrixWidth>
      <MatrixHeight>65536</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:17</ows:Identifier>
      <ScaleDenominator>4265.4591671058115</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>131072</MatrixWidth>
      <MatrixHeight>131072</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:18</ows:Identifier>
      <ScaleDenominator>2132.7295835529058</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>262144</MatrixWidth>
      <MatrixHeight>262144</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:19</ows:Identifier>
      <ScaleDenominator>1066.3647917764529</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>524288</MatrixWidth>
      <MatrixHeight>524288</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:20</ows:Identifier>
      <ScaleDenominator>533.1823958882264</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>1048576</MatrixWidth>
      <MatrixHeight>1048576</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:21</ows:Identifier>
      <ScaleDenominator>266.5911979441132</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>2097152</MatrixWidth>
      <MatrixHeight>2097152</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:22</ows:Identifier>
      <ScaleDenominator>133.2955989720566</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>4194304</MatrixWidth>
      <MatrixHeight>4194304</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:23</ows:Identifier>
      <ScaleDenominator>66.6477994860283</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>8388608</MatrixWidth>
      <MatrixHeight>8388608</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:24</ows:Identifier>
      <ScaleDenominator>33.32389974301415</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>16777216</MatrixWidth>
      <MatrixHeight>16777216</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:25</ows:Identifier>
      <ScaleDenominator>16.661949871507076</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>33554432</MatrixWidth>
      <MatrixHeight>33554432</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:26</ows:Identifier>
      <ScaleDenominator>8.330974935753538</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>67108864</MatrixWidth>
      <MatrixHeight>67108864</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:27</ows:Identifier>
      <ScaleDenominator>4.165487467876769</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>134217728</MatrixWidth>
      <MatrixHeight>134217728</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:28</ows:Identifier>
      <ScaleDenominator>2.0827437339383845</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>268435456</MatrixWidth>
      <MatrixHeight>268435456</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:29</ows:Identifier>
      <ScaleDenominator>1.0413718669691923</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>536870912</MatrixWidth>
      <MatrixHeight>536870912</MatrixHeight>
    </TileMatrix>
    <TileMatrix>
      <ows:Identifier>EPSG:900913:30</ows:Identifier>
      <ScaleDenominator>0.5206859334845961</ScaleDenominator>
      <TopLeftCorner>2.0037508E7 -2.003750834E7</TopLeftCorner>
      <TileWidth>256</TileWidth>
      <TileHeight>256</TileHeight>
      <MatrixWidth>1073741824</MatrixWidth>
      <MatrixHeight>1073741824</MatrixHeight>
    </TileMatrix>
  </TileMatrixSet>
</Contents>
<ServiceMetadataURL xlink:href="http://v2.suite.opengeo.org/geoserver/gwc/service/wmts?REQUEST=getcapabilities&amp;VERSION=1.0.0"/>
</Capabilities>;
	}
}