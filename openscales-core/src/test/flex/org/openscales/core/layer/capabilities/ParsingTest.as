package org.openscales.core.layer.capabilities
{
	import org.flexunit.Assert;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.core.basetypes.maps.HashMap;

	public class ParsingTest
	{

		private var doc10:XML = new XML('<WFS_Capabilities version="1.0.0" xsi:schemaLocation="http://www.opengis.net/wfs http://sigma.openplans.org:80/geoserver/schemas/wfs/1.0.0/WFS-capabilities.xsd" xmlns="http://www.opengis.net/wfs" xmlns:it.geosolutions="http://www.geo-solutions.it" xmlns:cite="http://www.opengeospatial.net/cite" xmlns:tiger="http://www.census.gov" xmlns:sde="http://geoserver.sf.net" xmlns:sigma="http://sigma.openplans.org" xmlns:topp="http://www.openplans.org/topp" xmlns:seb="http://seb.com" xmlns:sf="http://www.openplans.org/spearfish" xmlns:za="http://opengeo.org/za" xmlns:opengeo="http://open-geo.com" xmlns:nurc="http://www.nurc.nato.int" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">   <Service>     <Name>My GeoServer WFS</Name>     <Title>My GeoServer WFS</Title>     <Abstract>This is a description of your Web Feature Server.  The GeoServer is a full transactional Web Feature Server, you may wish to limit GeoServer to a Basic service level to prevent modificaiton of your geographic data.</Abstract>     <Keywords>WFS, WMS, GEOSERVER</Keywords>     <OnlineResource>http://sigma.openplans.org:80/geoserver/wfs</OnlineResource>     <Fees>NONE</Fees>     <AccessConstraints>NONE</AccessConstraints>   </Service>   <Capability>     <Request>       <GetCapabilities>         <DCPType>           <HTTP>             <Get onlineResource="http://sigma.openplans.org:80/geoserver/wfs?request=GetCapabilities"/>           </HTTP>         </DCPType>         <DCPType>           <HTTP>             <Post onlineResource="http://sigma.openplans.org:80/geoserver/wfs?"/>           </HTTP>         </DCPType>       </GetCapabilities>       <DescribeFeatureType>         <SchemaDescriptionLanguage>           <XMLSCHEMA/>         </SchemaDescriptionLanguage>         <DCPType>           <HTTP>             <Get onlineResource="http://sigma.openplans.org:80/geoserver/wfs?request=DescribeFeatureType"/>           </HTTP>         </DCPType>         <DCPType>           <HTTP>             <Post onlineResource="http://sigma.openplans.org:80/geoserver/wfs?"/>           </HTTP>         </DCPType>       </DescribeFeatureType>       <GetFeature>         <ResultFormat>           <GML2/>           <SHAPE-ZIP/>           <GEOJSON/>           <GML3/>         </ResultFormat>         <DCPType>           <HTTP>             <Get onlineResource="http://sigma.openplans.org:80/geoserver/wfs?request=GetFeature"/>           </HTTP>         </DCPType>         <DCPType>           <HTTP>             <Post onlineResource="http://sigma.openplans.org:80/geoserver/wfs?"/>           </HTTP>         </DCPType>       </GetFeature>       <Transaction>         <DCPType>           <HTTP>             <Get onlineResource="http://sigma.openplans.org:80/geoserver/wfs?request=Transaction"/>           </HTTP>         </DCPType>         <DCPType>           <HTTP>             <Post onlineResource="http://sigma.openplans.org:80/geoserver/wfs?"/>           </HTTP>         </DCPType>       </Transaction>       <LockFeature>         <DCPType>           <HTTP>             <Get onlineResource="http://sigma.openplans.org:80/geoserver/wfs?request=LockFeature"/>           </HTTP>         </DCPType>         <DCPType>           <HTTP>             <Post onlineResource="http://sigma.openplans.org:80/geoserver/wfs?"/>           </HTTP>         </DCPType>       </LockFeature>       <GetFeatureWithLock>         <ResultFormat>           <GML2/>         </ResultFormat>         <DCPType>           <HTTP>             <Get onlineResource="http://sigma.openplans.org:80/geoserver/wfs?request=GetFeatureWithLock"/>           </HTTP>         </DCPType>         <DCPType>           <HTTP>             <Post onlineResource="http://sigma.openplans.org:80/geoserver/wfs?"/>           </HTTP>         </DCPType>       </GetFeatureWithLock>     </Request>   </Capability>   <FeatureTypeList>     <Operations>       <Query/>       <Insert/>       <Update/>       <Delete/>       <Lock/>     </Operations>     <FeatureType>       <Name>topp:water_shorelines</Name>       <Title>Tiger 2005fe water shorelines</Title>       <Abstract>This layer contains the shorelines for all water bodies in the United States.  It is derived from the TIGER dataset.</Abstract>       <Keywords>tiger2005fe, water_shorelines, TIGER</Keywords>       <SRS>EPSG:4326</SRS>       <LatLongBoundingBox minx="-124.731422" miny="24.955967" maxx="-66.969849" maxy="49.371735"/>     </FeatureType>     <FeatureType>       <Name>topp:states</Name>       <Title>USA Population</Title>       <Abstract>This is some census data on the states.</Abstract>       <Keywords>census, united, boundaries, state, states</Keywords>       <SRS>EPSG:4326</SRS>       <LatLongBoundingBox minx="-126.499157180092" miny="6.515329319907995" maxx="-65.20211381990799" maxy="67.81237268009201"/>     </FeatureType>     <FeatureType>       <Name>topp:sfzones</Name>       <Title>sfzones_Type</Title>       <Abstract>Generated from sfzones</Abstract>       <Keywords>sfzones</Keywords>       <SRS>EPSG:2227</SRS>       <LatLongBoundingBox minx="-122.51551192679109" miny="37.70601857958319" maxx="-122.35585669052094" maxy="37.8129590980132"/>     </FeatureType>   </FeatureTypeList>   <ogc:Filter_Capabilities>     <ogc:Spatial_Capabilities>       <ogc:Spatial_Operators>         <ogc:Disjoint/>         <ogc:Equals/>         <ogc:DWithin/>         <ogc:Beyond/>         <ogc:Intersect/>         <ogc:Touches/>         <ogc:Crosses/>         <ogc:Within/>         <ogc:Contains/>         <ogc:Overlaps/>         <ogc:BBOX/>       </ogc:Spatial_Operators>     </ogc:Spatial_Capabilities>     <ogc:Scalar_Capabilities>       <ogc:Logical_Operators/>       <ogc:Comparison_Operators>         <ogc:Simple_Comparisons/>         <ogc:Between/>         <ogc:Like/>         <ogc:NullCheck/>       </ogc:Comparison_Operators>       <ogc:Arithmetic_Operators>         <ogc:Simple_Arithmetic/>         <ogc:Functions>           <ogc:Function_Names>             <ogc:Function_Name nArgs="1">abs</ogc:Function_Name>             <ogc:Function_Name nArgs="1">abs_2</ogc:Function_Name>             <ogc:Function_Name nArgs="1">abs_3</ogc:Function_Name>             <ogc:Function_Name nArgs="1">abs_4</ogc:Function_Name>             <ogc:Function_Name nArgs="1">acos</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Area</ogc:Function_Name>             <ogc:Function_Name nArgs="1">asin</ogc:Function_Name>             <ogc:Function_Name nArgs="1">atan</ogc:Function_Name>             <ogc:Function_Name nArgs="2">atan2</ogc:Function_Name>             <ogc:Function_Name nArgs="3">between</ogc:Function_Name>             <ogc:Function_Name nArgs="1">boundary</ogc:Function_Name>             <ogc:Function_Name nArgs="1">boundaryDimension</ogc:Function_Name>             <ogc:Function_Name nArgs="2">buffer</ogc:Function_Name>             <ogc:Function_Name nArgs="3">bufferWithSegments</ogc:Function_Name>             <ogc:Function_Name nArgs="1">ceil</ogc:Function_Name>             <ogc:Function_Name nArgs="1">centroid</ogc:Function_Name>             <ogc:Function_Name nArgs="2">classify</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Collection_Average</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Collection_Bounds</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Collection_Count</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Collection_Max</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Collection_Median</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Collection_Min</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Collection_Sum</ogc:Function_Name>             <ogc:Function_Name nArgs="1">Collection_Unique</ogc:Function_Name>             <ogc:Function_Name nArgs="2">Concatenate</ogc:Function_Name>             <ogc:Function_Name nArgs="2">contains</ogc:Function_Name>             <ogc:Function_Name nArgs="1">convexHull</ogc:Function_Name>             <ogc:Function_Name nArgs="1">cos</ogc:Function_Name>             <ogc:Function_Name nArgs="2">crosses</ogc:Function_Name>             <ogc:Function_Name nArgs="2">dateFormat</ogc:Function_Name>             <ogc:Function_Name nArgs="2">dateParse</ogc:Function_Name>             <ogc:Function_Name nArgs="2">difference</ogc:Function_Name>             <ogc:Function_Name nArgs="1">dimension</ogc:Function_Name>             <ogc:Function_Name nArgs="2">disjoint</ogc:Function_Name>             <ogc:Function_Name nArgs="2">distance</ogc:Function_Name>             <ogc:Function_Name nArgs="1">double2bool</ogc:Function_Name>             <ogc:Function_Name nArgs="1">endPoint</ogc:Function_Name>             <ogc:Function_Name nArgs="1">envelope</ogc:Function_Name>             <ogc:Function_Name nArgs="2">EqualInterval</ogc:Function_Name>             <ogc:Function_Name nArgs="2">equalsExact</ogc:Function_Name>             <ogc:Function_Name nArgs="3">equalsExactTolerance</ogc:Function_Name>             <ogc:Function_Name nArgs="2">equalTo</ogc:Function_Name>             <ogc:Function_Name nArgs="1">exp</ogc:Function_Name>             <ogc:Function_Name nArgs="1">exteriorRing</ogc:Function_Name>             <ogc:Function_Name nArgs="1">floor</ogc:Function_Name>             <ogc:Function_Name nArgs="1">geometryType</ogc:Function_Name>             <ogc:Function_Name nArgs="1">geomFromWKT</ogc:Function_Name>             <ogc:Function_Name nArgs="1">geomLength</ogc:Function_Name>             <ogc:Function_Name nArgs="2">getGeometryN</ogc:Function_Name>             <ogc:Function_Name nArgs="1">getX</ogc:Function_Name>             <ogc:Function_Name nArgs="1">getY</ogc:Function_Name>             <ogc:Function_Name nArgs="1">getZ</ogc:Function_Name>             <ogc:Function_Name nArgs="2">greaterEqualThan</ogc:Function_Name>             <ogc:Function_Name nArgs="2">greaterThan</ogc:Function_Name>             <ogc:Function_Name nArgs="0">id</ogc:Function_Name>             <ogc:Function_Name nArgs="2">IEEEremainder</ogc:Function_Name>             <ogc:Function_Name nArgs="3">if_then_else</ogc:Function_Name>             <ogc:Function_Name nArgs="11">in10</ogc:Function_Name>             <ogc:Function_Name nArgs="3">in2</ogc:Function_Name>             <ogc:Function_Name nArgs="4">in3</ogc:Function_Name>             <ogc:Function_Name nArgs="5">in4</ogc:Function_Name>             <ogc:Function_Name nArgs="6">in5</ogc:Function_Name>             <ogc:Function_Name nArgs="7">in6</ogc:Function_Name>             <ogc:Function_Name nArgs="8">in7</ogc:Function_Name>             <ogc:Function_Name nArgs="9">in8</ogc:Function_Name>             <ogc:Function_Name nArgs="10">in9</ogc:Function_Name>             <ogc:Function_Name nArgs="1">int2bbool</ogc:Function_Name>             <ogc:Function_Name nArgs="1">int2ddouble</ogc:Function_Name>             <ogc:Function_Name nArgs="1">interiorPoint</ogc:Function_Name>             <ogc:Function_Name nArgs="2">interiorRingN</ogc:Function_Name>             <ogc:Function_Name nArgs="2">intersection</ogc:Function_Name>             <ogc:Function_Name nArgs="2">intersects</ogc:Function_Name>             <ogc:Function_Name nArgs="1">isClosed</ogc:Function_Name>             <ogc:Function_Name nArgs="1">isEmpty</ogc:Function_Name>             <ogc:Function_Name nArgs="2">isLike</ogc:Function_Name>             <ogc:Function_Name nArgs="1">isNull</ogc:Function_Name>             <ogc:Function_Name nArgs="1">isRing</ogc:Function_Name>             <ogc:Function_Name nArgs="1">isSimple</ogc:Function_Name>             <ogc:Function_Name nArgs="1">isValid</ogc:Function_Name>             <ogc:Function_Name nArgs="3">isWithinDistance</ogc:Function_Name>             <ogc:Function_Name nArgs="1">length</ogc:Function_Name>             <ogc:Function_Name nArgs="2">lessEqualThan</ogc:Function_Name>             <ogc:Function_Name nArgs="2">lessThan</ogc:Function_Name>             <ogc:Function_Name nArgs="1">log</ogc:Function_Name>             <ogc:Function_Name nArgs="2">max</ogc:Function_Name>             <ogc:Function_Name nArgs="2">max_2</ogc:Function_Name>             <ogc:Function_Name nArgs="2">max_3</ogc:Function_Name>             <ogc:Function_Name nArgs="2">max_4</ogc:Function_Name>             <ogc:Function_Name nArgs="2">min</ogc:Function_Name>             <ogc:Function_Name nArgs="2">min_2</ogc:Function_Name>             <ogc:Function_Name nArgs="2">min_3</ogc:Function_Name>             <ogc:Function_Name nArgs="2">min_4</ogc:Function_Name>             <ogc:Function_Name nArgs="1">not</ogc:Function_Name>             <ogc:Function_Name nArgs="2">notEqualTo</ogc:Function_Name>             <ogc:Function_Name nArgs="1">numGeometries</ogc:Function_Name>             <ogc:Function_Name nArgs="1">numInteriorRing</ogc:Function_Name>             <ogc:Function_Name nArgs="1">numPoints</ogc:Function_Name>             <ogc:Function_Name nArgs="2">overlaps</ogc:Function_Name>             <ogc:Function_Name nArgs="1">parseBoolean</ogc:Function_Name>             <ogc:Function_Name nArgs="1">parseDouble</ogc:Function_Name>             <ogc:Function_Name nArgs="1">parseInt</ogc:Function_Name>             <ogc:Function_Name nArgs="0">pi</ogc:Function_Name>             <ogc:Function_Name nArgs="2">pointN</ogc:Function_Name>             <ogc:Function_Name nArgs="2">pow</ogc:Function_Name>             <ogc:Function_Name nArgs="1">PropertyExists</ogc:Function_Name>             <ogc:Function_Name nArgs="2">Quantile</ogc:Function_Name>             <ogc:Function_Name nArgs="0">random</ogc:Function_Name>             <ogc:Function_Name nArgs="2">relate</ogc:Function_Name>             <ogc:Function_Name nArgs="3">relatePattern</ogc:Function_Name>             <ogc:Function_Name nArgs="1">rint</ogc:Function_Name>             <ogc:Function_Name nArgs="1">round</ogc:Function_Name>             <ogc:Function_Name nArgs="1">round_2</ogc:Function_Name>             <ogc:Function_Name nArgs="1">roundDouble</ogc:Function_Name>             <ogc:Function_Name nArgs="1">sin</ogc:Function_Name>             <ogc:Function_Name nArgs="1">sqrt</ogc:Function_Name>             <ogc:Function_Name nArgs="2">StandardDeviation</ogc:Function_Name>             <ogc:Function_Name nArgs="1">startPoint</ogc:Function_Name>             <ogc:Function_Name nArgs="2">strConcat</ogc:Function_Name>             <ogc:Function_Name nArgs="2">strEndsWith</ogc:Function_Name>             <ogc:Function_Name nArgs="2">strEqualsIgnoreCase</ogc:Function_Name>             <ogc:Function_Name nArgs="2">strIndexOf</ogc:Function_Name>             <ogc:Function_Name nArgs="2">strLastIndexOf</ogc:Function_Name>             <ogc:Function_Name nArgs="1">strLength</ogc:Function_Name>             <ogc:Function_Name nArgs="2">strMatches</ogc:Function_Name>             <ogc:Function_Name nArgs="4">strReplace</ogc:Function_Name>             <ogc:Function_Name nArgs="2">strStartsWith</ogc:Function_Name>             <ogc:Function_Name nArgs="3">strSubstring</ogc:Function_Name>             <ogc:Function_Name nArgs="2">strSubstringStart</ogc:Function_Name>             <ogc:Function_Name nArgs="1">strToLowerCase</ogc:Function_Name>             <ogc:Function_Name nArgs="1">strToUpperCase</ogc:Function_Name>             <ogc:Function_Name nArgs="1">strTrim</ogc:Function_Name>             <ogc:Function_Name nArgs="2">symDifference</ogc:Function_Name>             <ogc:Function_Name nArgs="1">tan</ogc:Function_Name>             <ogc:Function_Name nArgs="1">toDegrees</ogc:Function_Name>             <ogc:Function_Name nArgs="1">toRadians</ogc:Function_Name>             <ogc:Function_Name nArgs="2">touches</ogc:Function_Name>             <ogc:Function_Name nArgs="1">toWKT</ogc:Function_Name>             <ogc:Function_Name nArgs="2">union</ogc:Function_Name>             <ogc:Function_Name nArgs="2">UniqueInterval</ogc:Function_Name>             <ogc:Function_Name nArgs="2">within</ogc:Function_Name>           </ogc:Function_Names>         </ogc:Functions>       </ogc:Arithmetic_Operators>     </ogc:Scalar_Capabilities>   </ogc:Filter_Capabilities> </WFS_Capabilities>');
		private var doc11:XML = new XML('<WFS_Capabilities version="1.1.0" xsi:schemaLocation="http://www.opengis.net/wfs http://sigma.openplans.org:80/geoserver/schemas/wfs/1.1.0/wfs.xsd" updateSequence="62" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.opengis.net/wfs" xmlns:wfs="http://www.opengis.net/wfs" xmlns:ows="http://www.opengis.net/ows" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:it.geosolutions="http://www.geo-solutions.it" xmlns:cite="http://www.opengeospatial.net/cite" xmlns:tiger="http://www.census.gov" xmlns:sde="http://geoserver.sf.net" xmlns:sigma="http://sigma.openplans.org" xmlns:topp="http://www.openplans.org/topp" xmlns:seb="http://seb.com" xmlns:sf="http://www.openplans.org/spearfish" xmlns:za="http://opengeo.org/za" xmlns:opengeo="http://open-geo.com" xmlns:nurc="http://www.nurc.nato.int">   <ows:ServiceIdentification>     <ows:Title>My GeoServer WFS</ows:Title>     <ows:Abstract>This is a description of your Web Feature Server.  The GeoServer is a full transactional Web Feature Server, you may wish to limit GeoServer to a Basic service level to prevent modificaiton of your geographic data.</ows:Abstract>     <ows:Keywords>       <ows:Keyword>WFS</ows:Keyword>       <ows:Keyword>WMS</ows:Keyword>       <ows:Keyword>GEOSERVER</ows:Keyword>     </ows:Keywords>     <ows:ServiceType>WFS</ows:ServiceType>     <ows:ServiceTypeVersion>1.1.0</ows:ServiceTypeVersion>     <ows:Fees>NONE</ows:Fees>     <ows:AccessConstraints>NONE</ows:AccessConstraints>   </ows:ServiceIdentification>   <ows:ServiceProvider>     <ows:ProviderName>The Open Planning Project</ows:ProviderName>     <ows:ServiceContact>       <ows:IndividualName/>       <ows:PositionName/>       <ows:ContactInfo>         <ows:Phone>           <ows:Voice/>           <ows:Facsimile/>         </ows:Phone>         <ows:Address>           <ows:City/>           <ows:AdministrativeArea/>           <ows:PostalCode/>           <ows:Country/>         </ows:Address>       </ows:ContactInfo>     </ows:ServiceContact>   </ows:ServiceProvider>   <ows:OperationsMetadata>     <ows:Operation name="GetCapabilities">       <ows:DCP>         <ows:HTTP>           <ows:Get xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>           <ows:Post xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>         </ows:HTTP>       </ows:DCP>       <ows:Parameter name="AcceptVersions">         <ows:Value>1.0.0</ows:Value>         <ows:Value>1.1.0</ows:Value>       </ows:Parameter>       <ows:Parameter name="AcceptFormats">         <ows:Value>text/xml</ows:Value>       </ows:Parameter>     </ows:Operation>     <ows:Operation name="DescribeFeatureType">       <ows:DCP>         <ows:HTTP>           <ows:Get xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>           <ows:Post xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>         </ows:HTTP>       </ows:DCP>       <ows:Parameter name="outputFormat">         <ows:Value>text/xml; subtype=gml/3.1.1</ows:Value>       </ows:Parameter>     </ows:Operation>     <ows:Operation name="GetFeature">       <ows:DCP>         <ows:HTTP>           <ows:Get xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>           <ows:Post xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>         </ows:HTTP>       </ows:DCP>       <ows:Parameter name="resultType">         <ows:Value>results</ows:Value>         <ows:Value>hits</ows:Value>       </ows:Parameter>       <ows:Parameter name="outputFormat">         <ows:Value>text/xml; subtype=gml/3.1.1</ows:Value>         <ows:Value>GML2</ows:Value>         <ows:Value>GML2-GZIP</ows:Value>         <ows:Value>SHAPE-ZIP</ows:Value>         <ows:Value>gml3</ows:Value>         <ows:Value>json</ows:Value>         <ows:Value>text/xml; subtype=gml/2.1.2</ows:Value>       </ows:Parameter>       <ows:Constraint name="LocalTraverseXLinkScope">         <ows:Value>2</ows:Value>       </ows:Constraint>     </ows:Operation>     <ows:Operation name="GetGmlObject">       <ows:DCP>         <ows:HTTP>           <ows:Get xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>           <ows:Post xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>         </ows:HTTP>       </ows:DCP>     </ows:Operation>     <ows:Operation name="LockFeature">       <ows:DCP>         <ows:HTTP>           <ows:Get xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>           <ows:Post xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>         </ows:HTTP>       </ows:DCP>       <ows:Parameter name="releaseAction">         <ows:Value>ALL</ows:Value>         <ows:Value>SOME</ows:Value>       </ows:Parameter>     </ows:Operation>     <ows:Operation name="GetFeatureWithLock">       <ows:DCP>         <ows:HTTP>           <ows:Get xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>           <ows:Post xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>         </ows:HTTP>       </ows:DCP>       <ows:Parameter name="resultType">         <ows:Value>results</ows:Value>         <ows:Value>hits</ows:Value>       </ows:Parameter>       <ows:Parameter name="outputFormat">         <ows:Value>text/xml; subtype=gml/3.1.1</ows:Value>         <ows:Value>GML2</ows:Value>         <ows:Value>GML2-GZIP</ows:Value>         <ows:Value>SHAPE-ZIP</ows:Value>         <ows:Value>gml3</ows:Value>         <ows:Value>json</ows:Value>         <ows:Value>text/xml; subtype=gml/2.1.2</ows:Value>       </ows:Parameter>     </ows:Operation>     <ows:Operation name="Transaction">       <ows:DCP>         <ows:HTTP>           <ows:Get xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>           <ows:Post xlink:href="http://sigma.openplans.org:80/geoserver/wfs?"/>         </ows:HTTP>       </ows:DCP>       <ows:Parameter name="inputFormat">         <ows:Value>text/xml; subtype=gml/3.1.1</ows:Value>       </ows:Parameter>       <ows:Parameter name="idgen">         <ows:Value>GenerateNew</ows:Value>         <ows:Value>UseExisting</ows:Value>         <ows:Value>ReplaceDuplicate</ows:Value>       </ows:Parameter>       <ows:Parameter name="releaseAction">         <ows:Value>ALL</ows:Value>         <ows:Value>SOME</ows:Value>       </ows:Parameter>     </ows:Operation>   </ows:OperationsMetadata>   <FeatureTypeList>     <Operations>       <Operation>Query</Operation>       <Operation>Insert</Operation>       <Operation>Update</Operation>       <Operation>Delete</Operation>       <Operation>Lock</Operation>     </Operations>     <FeatureType>       <Name>topp:water_shorelines</Name>       <Title>Tiger 2005fe water shorelines</Title>       <Abstract>This layer contains the shorelines for all water bodies in the United States.  It is derived from the TIGER dataset.</Abstract>       <ows:Keywords>         <ows:Keyword>tiger2005fe</ows:Keyword>         <ows:Keyword>water_shorelines</ows:Keyword>         <ows:Keyword>TIGER</ows:Keyword>       </ows:Keywords>       <DefaultSRS>urn:x-ogc:def:crs:EPSG:4326</DefaultSRS>       <ows:WGS84BoundingBox>         <ows:LowerCorner>-124.731422 24.955967</ows:LowerCorner>         <ows:UpperCorner>-66.969849 49.371735</ows:UpperCorner>       </ows:WGS84BoundingBox>     </FeatureType>     <FeatureType>       <Name>topp:states</Name>       <Title>USA Population</Title>       <Abstract>This is some census data on the states.</Abstract>       <ows:Keywords>         <ows:Keyword>census</ows:Keyword>         <ows:Keyword>united</ows:Keyword>         <ows:Keyword>boundaries</ows:Keyword>         <ows:Keyword>state</ows:Keyword>         <ows:Keyword>states</ows:Keyword>       </ows:Keywords>       <DefaultSRS>urn:x-ogc:def:crs:EPSG:4326</DefaultSRS>       <ows:WGS84BoundingBox>         <ows:LowerCorner>-126.499157180092 6.515329319907995</ows:LowerCorner>         <ows:UpperCorner>-65.20211381990799 67.81237268009201</ows:UpperCorner>       </ows:WGS84BoundingBox>     </FeatureType>     <FeatureType>       <Name>topp:sfzones</Name>       <Title>sfzones_Type</Title>       <Abstract>Generated from sfzones</Abstract>       <ows:Keywords>         <ows:Keyword>sfzones</ows:Keyword>       </ows:Keywords>       <DefaultSRS>urn:x-ogc:def:crs:EPSG:2227</DefaultSRS>       <ows:WGS84BoundingBox>         <ows:LowerCorner>-122.51551192679109 37.70601857958319</ows:LowerCorner>         <ows:UpperCorner>-122.35585669052094 37.8129590980132</ows:UpperCorner>       </ows:WGS84BoundingBox>     </FeatureType>   </FeatureTypeList>   <ogc:Filter_Capabilities>     <ogc:Spatial_Capabilities>       <ogc:GeometryOperands>         <ogc:GeometryOperand>gml:Envelope</ogc:GeometryOperand>         <ogc:GeometryOperand>gml:Point</ogc:GeometryOperand>         <ogc:GeometryOperand>gml:LineString</ogc:GeometryOperand>         <ogc:GeometryOperand>gml:Polygon</ogc:GeometryOperand>       </ogc:GeometryOperands>       <ogc:SpatialOperators>         <ogc:SpatialOperator name="Disjoint"/>         <ogc:SpatialOperator name="Equals"/>         <ogc:SpatialOperator name="DWithin"/>         <ogc:SpatialOperator name="Beyond"/>         <ogc:SpatialOperator name="Intersects"/>         <ogc:SpatialOperator name="Touches"/>         <ogc:SpatialOperator name="Crosses"/>         <ogc:SpatialOperator name="Contains"/>         <ogc:SpatialOperator name="Overlaps"/>         <ogc:SpatialOperator name="BBOX"/>       </ogc:SpatialOperators>     </ogc:Spatial_Capabilities>     <ogc:Scalar_Capabilities>       <ogc:LogicalOperators/>       <ogc:ComparisonOperators>         <ogc:ComparisonOperator>LessThan</ogc:ComparisonOperator>         <ogc:ComparisonOperator>GreaterThan</ogc:ComparisonOperator>         <ogc:ComparisonOperator>LessThanEqualTo</ogc:ComparisonOperator>         <ogc:ComparisonOperator>GreaterThanEqualTo</ogc:ComparisonOperator>         <ogc:ComparisonOperator>EqualTo</ogc:ComparisonOperator>         <ogc:ComparisonOperator>NotEqualTo</ogc:ComparisonOperator>         <ogc:ComparisonOperator>Like</ogc:ComparisonOperator>         <ogc:ComparisonOperator>Between</ogc:ComparisonOperator>         <ogc:ComparisonOperator>NullCheck</ogc:ComparisonOperator>       </ogc:ComparisonOperators>       <ogc:ArithmeticOperators>         <ogc:SimpleArithmetic/>         <ogc:Functions>           <ogc:FunctionNames>             <ogc:FunctionName nArgs="1">abs</ogc:FunctionName>             <ogc:FunctionName nArgs="1">abs_2</ogc:FunctionName>             <ogc:FunctionName nArgs="1">abs_3</ogc:FunctionName>             <ogc:FunctionName nArgs="1">abs_4</ogc:FunctionName>             <ogc:FunctionName nArgs="1">acos</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Area</ogc:FunctionName>             <ogc:FunctionName nArgs="1">asin</ogc:FunctionName>             <ogc:FunctionName nArgs="1">atan</ogc:FunctionName>             <ogc:FunctionName nArgs="2">atan2</ogc:FunctionName>             <ogc:FunctionName nArgs="3">between</ogc:FunctionName>             <ogc:FunctionName nArgs="1">boundary</ogc:FunctionName>             <ogc:FunctionName nArgs="1">boundaryDimension</ogc:FunctionName>             <ogc:FunctionName nArgs="2">buffer</ogc:FunctionName>             <ogc:FunctionName nArgs="3">bufferWithSegments</ogc:FunctionName>             <ogc:FunctionName nArgs="0">Categorize</ogc:FunctionName>             <ogc:FunctionName nArgs="1">ceil</ogc:FunctionName>             <ogc:FunctionName nArgs="1">centroid</ogc:FunctionName>             <ogc:FunctionName nArgs="2">classify</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Collection_Average</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Collection_Bounds</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Collection_Count</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Collection_Max</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Collection_Median</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Collection_Min</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Collection_Sum</ogc:FunctionName>             <ogc:FunctionName nArgs="1">Collection_Unique</ogc:FunctionName>             <ogc:FunctionName nArgs="2">Concatenate</ogc:FunctionName>             <ogc:FunctionName nArgs="2">contains</ogc:FunctionName>             <ogc:FunctionName nArgs="1">convexHull</ogc:FunctionName>             <ogc:FunctionName nArgs="1">cos</ogc:FunctionName>             <ogc:FunctionName nArgs="2">crosses</ogc:FunctionName>             <ogc:FunctionName nArgs="2">dateFormat</ogc:FunctionName>             <ogc:FunctionName nArgs="2">dateParse</ogc:FunctionName>             <ogc:FunctionName nArgs="2">difference</ogc:FunctionName>             <ogc:FunctionName nArgs="1">dimension</ogc:FunctionName>             <ogc:FunctionName nArgs="2">disjoint</ogc:FunctionName>             <ogc:FunctionName nArgs="2">distance</ogc:FunctionName>             <ogc:FunctionName nArgs="1">double2bool</ogc:FunctionName>             <ogc:FunctionName nArgs="1">endPoint</ogc:FunctionName>             <ogc:FunctionName nArgs="1">envelope</ogc:FunctionName>             <ogc:FunctionName nArgs="2">EqualInterval</ogc:FunctionName>             <ogc:FunctionName nArgs="2">equalsExact</ogc:FunctionName>             <ogc:FunctionName nArgs="3">equalsExactTolerance</ogc:FunctionName>             <ogc:FunctionName nArgs="2">equalTo</ogc:FunctionName>             <ogc:FunctionName nArgs="1">exp</ogc:FunctionName>             <ogc:FunctionName nArgs="1">exteriorRing</ogc:FunctionName>             <ogc:FunctionName nArgs="1">floor</ogc:FunctionName>             <ogc:FunctionName nArgs="1">geometryType</ogc:FunctionName>             <ogc:FunctionName nArgs="1">geomFromWKT</ogc:FunctionName>             <ogc:FunctionName nArgs="1">geomLength</ogc:FunctionName>             <ogc:FunctionName nArgs="2">getGeometryN</ogc:FunctionName>             <ogc:FunctionName nArgs="1">getX</ogc:FunctionName>             <ogc:FunctionName nArgs="1">getY</ogc:FunctionName>             <ogc:FunctionName nArgs="1">getZ</ogc:FunctionName>             <ogc:FunctionName nArgs="2">greaterEqualThan</ogc:FunctionName>             <ogc:FunctionName nArgs="2">greaterThan</ogc:FunctionName>             <ogc:FunctionName nArgs="0">id</ogc:FunctionName>             <ogc:FunctionName nArgs="2">IEEEremainder</ogc:FunctionName>             <ogc:FunctionName nArgs="3">if_then_else</ogc:FunctionName>             <ogc:FunctionName nArgs="11">in10</ogc:FunctionName>             <ogc:FunctionName nArgs="3">in2</ogc:FunctionName>             <ogc:FunctionName nArgs="4">in3</ogc:FunctionName>             <ogc:FunctionName nArgs="5">in4</ogc:FunctionName>             <ogc:FunctionName nArgs="6">in5</ogc:FunctionName>             <ogc:FunctionName nArgs="7">in6</ogc:FunctionName>             <ogc:FunctionName nArgs="8">in7</ogc:FunctionName>             <ogc:FunctionName nArgs="9">in8</ogc:FunctionName>             <ogc:FunctionName nArgs="10">in9</ogc:FunctionName>             <ogc:FunctionName nArgs="1">int2bbool</ogc:FunctionName>             <ogc:FunctionName nArgs="1">int2ddouble</ogc:FunctionName>             <ogc:FunctionName nArgs="1">interiorPoint</ogc:FunctionName>             <ogc:FunctionName nArgs="2">interiorRingN</ogc:FunctionName>             <ogc:FunctionName nArgs="2">intersection</ogc:FunctionName>             <ogc:FunctionName nArgs="2">intersects</ogc:FunctionName>             <ogc:FunctionName nArgs="1">isClosed</ogc:FunctionName>             <ogc:FunctionName nArgs="1">isEmpty</ogc:FunctionName>             <ogc:FunctionName nArgs="2">isLike</ogc:FunctionName>             <ogc:FunctionName nArgs="1">isNull</ogc:FunctionName>             <ogc:FunctionName nArgs="1">isRing</ogc:FunctionName>             <ogc:FunctionName nArgs="1">isSimple</ogc:FunctionName>             <ogc:FunctionName nArgs="1">isValid</ogc:FunctionName>             <ogc:FunctionName nArgs="3">isWithinDistance</ogc:FunctionName>             <ogc:FunctionName nArgs="1">length</ogc:FunctionName>             <ogc:FunctionName nArgs="2">lessEqualThan</ogc:FunctionName>             <ogc:FunctionName nArgs="2">lessThan</ogc:FunctionName>             <ogc:FunctionName nArgs="1">log</ogc:FunctionName>             <ogc:FunctionName nArgs="2">max</ogc:FunctionName>             <ogc:FunctionName nArgs="2">max_2</ogc:FunctionName>             <ogc:FunctionName nArgs="2">max_3</ogc:FunctionName>             <ogc:FunctionName nArgs="2">max_4</ogc:FunctionName>             <ogc:FunctionName nArgs="2">min</ogc:FunctionName>             <ogc:FunctionName nArgs="2">min_2</ogc:FunctionName>             <ogc:FunctionName nArgs="2">min_3</ogc:FunctionName>             <ogc:FunctionName nArgs="2">min_4</ogc:FunctionName>             <ogc:FunctionName nArgs="1">not</ogc:FunctionName>             <ogc:FunctionName nArgs="2">notEqualTo</ogc:FunctionName>             <ogc:FunctionName nArgs="1">numGeometries</ogc:FunctionName>             <ogc:FunctionName nArgs="1">numInteriorRing</ogc:FunctionName>             <ogc:FunctionName nArgs="1">numPoints</ogc:FunctionName>             <ogc:FunctionName nArgs="2">overlaps</ogc:FunctionName>             <ogc:FunctionName nArgs="1">parseBoolean</ogc:FunctionName>             <ogc:FunctionName nArgs="1">parseDouble</ogc:FunctionName>             <ogc:FunctionName nArgs="1">parseInt</ogc:FunctionName>             <ogc:FunctionName nArgs="0">pi</ogc:FunctionName>             <ogc:FunctionName nArgs="2">pointN</ogc:FunctionName>             <ogc:FunctionName nArgs="2">pow</ogc:FunctionName>             <ogc:FunctionName nArgs="1">PropertyExists</ogc:FunctionName>             <ogc:FunctionName nArgs="2">Quantile</ogc:FunctionName>             <ogc:FunctionName nArgs="0">random</ogc:FunctionName>             <ogc:FunctionName nArgs="2">relate</ogc:FunctionName>             <ogc:FunctionName nArgs="3">relatePattern</ogc:FunctionName>             <ogc:FunctionName nArgs="1">rint</ogc:FunctionName>             <ogc:FunctionName nArgs="1">round</ogc:FunctionName>             <ogc:FunctionName nArgs="1">round_2</ogc:FunctionName>             <ogc:FunctionName nArgs="1">roundDouble</ogc:FunctionName>             <ogc:FunctionName nArgs="1">sin</ogc:FunctionName>             <ogc:FunctionName nArgs="1">sqrt</ogc:FunctionName>             <ogc:FunctionName nArgs="2">StandardDeviation</ogc:FunctionName>             <ogc:FunctionName nArgs="1">startPoint</ogc:FunctionName>             <ogc:FunctionName nArgs="2">strConcat</ogc:FunctionName>             <ogc:FunctionName nArgs="2">strEndsWith</ogc:FunctionName>             <ogc:FunctionName nArgs="2">strEqualsIgnoreCase</ogc:FunctionName>             <ogc:FunctionName nArgs="2">strIndexOf</ogc:FunctionName>             <ogc:FunctionName nArgs="2">strLastIndexOf</ogc:FunctionName>             <ogc:FunctionName nArgs="1">strLength</ogc:FunctionName>             <ogc:FunctionName nArgs="2">strMatches</ogc:FunctionName>             <ogc:FunctionName nArgs="4">strReplace</ogc:FunctionName>             <ogc:FunctionName nArgs="2">strStartsWith</ogc:FunctionName>             <ogc:FunctionName nArgs="3">strSubstring</ogc:FunctionName>             <ogc:FunctionName nArgs="2">strSubstringStart</ogc:FunctionName>             <ogc:FunctionName nArgs="1">strToLowerCase</ogc:FunctionName>             <ogc:FunctionName nArgs="1">strToUpperCase</ogc:FunctionName>             <ogc:FunctionName nArgs="1">strTrim</ogc:FunctionName>             <ogc:FunctionName nArgs="2">symDifference</ogc:FunctionName>             <ogc:FunctionName nArgs="1">tan</ogc:FunctionName>             <ogc:FunctionName nArgs="1">toDegrees</ogc:FunctionName>             <ogc:FunctionName nArgs="1">toRadians</ogc:FunctionName>             <ogc:FunctionName nArgs="2">touches</ogc:FunctionName>             <ogc:FunctionName nArgs="1">toWKT</ogc:FunctionName>             <ogc:FunctionName nArgs="2">union</ogc:FunctionName>             <ogc:FunctionName nArgs="2">UniqueInterval</ogc:FunctionName>             <ogc:FunctionName nArgs="2">within</ogc:FunctionName>           </ogc:FunctionNames>         </ogc:Functions>       </ogc:ArithmeticOperators>     </ogc:Scalar_Capabilities>     <ogc:Id_Capabilities>       <ogc:FID/>       <ogc:EID/>     </ogc:Id_Capabilities>   </ogc:Filter_Capabilities> </WFS_Capabilities>');

		[Test]
		public function testWfs100():void {

			var parser:WFS100 = new WFS100();
			var capabilities:HashMap = parser.read(doc10);
			var featureCap:HashMap = null;

			Assert.assertFalse(capabilities == null);
			Assert.assertEquals(3,capabilities.size());
			Assert.assertFalse(capabilities.getValue("topp:water_shorelines") == null);
			Assert.assertFalse(capabilities.getValue("topp:states") == null);
			Assert.assertFalse(capabilities.getValue("topp:sfzones") == null);

			featureCap = capabilities.getValue("topp:water_shorelines");
			Assert.assertFalse(featureCap == null);
			Assert.assertEquals(5,featureCap.size());
			Assert.assertTrue(featureCap.getValue("SRS") == "EPSG:4326");
			var b:Bounds = null;
			b = featureCap.getValue("Extent");
			Assert.assertTrue( b != null);
			Assert.assertTrue(b.equals(new Bounds("EPSG:4326",-124.731422,24.955967,-66.969849,49.371735)));
			Assert.assertEquals("Tiger 2005fe water shorelines", featureCap.getValue("Title"));
			Assert.assertEquals("This layer contains the shorelines for all water bodies in the United States.  It is derived from the TIGER dataset.", featureCap.getValue("Abstract"));
			featureCap = null;
		}
		
		[Test]
		public function testWfs110():void {

			var parser:WFS110 = new WFS110();
			var capabilities:HashMap = parser.read(doc11);
			var featureCap:HashMap = null;

			Assert.assertFalse(capabilities == null);
			Assert.assertEquals(3,capabilities.size());
			Assert.assertFalse(capabilities.getValue("topp:water_shorelines") == null);
			Assert.assertFalse(capabilities.getValue("topp:states") == null);
			Assert.assertFalse(capabilities.getValue("topp:sfzones") == null);

			featureCap = capabilities.getValue("topp:water_shorelines");
			Assert.assertFalse(featureCap == null);
			Assert.assertEquals(5,featureCap.size());
			Assert.assertTrue(featureCap.getValue("SRS") == "EPSG:4326");
			var b:Bounds = null;
			b = featureCap.getValue("Extent");
			Assert.assertTrue( b != null);
			Assert.assertTrue(b.equals(new Bounds("EPSG:4326",-124.731422,24.955967,-66.969849,49.371735)));
			Assert.assertEquals("Tiger 2005fe water shorelines", featureCap.getValue("Title"));
			Assert.assertEquals("This layer contains the shorelines for all water bodies in the United States.  It is derived from the TIGER dataset.", featureCap.getValue("Abstract"));
			featureCap = null;
		}

	}
}

