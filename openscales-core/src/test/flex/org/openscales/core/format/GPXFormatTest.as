package org.openscales.core.format
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.layer.ogc.GPX;

	public class GPXFormatTest
	{
		
		private var format:GPXFormat;
		private var gpxLayer:GPX;
		private var url:String;
		
		[Embed(source="/assets/format/Gpx11Example.xml",mimeType="application/octet-stream")]
		private const GPX11FILE:Class;
		
		[Embed(source="/assets/format/Gpx10Example.xml",mimeType="application/octet-stream")]
		private const GPX10FILE:Class;
		
		[Before]
		public function setUp():void
		{
			url = "http://openscales.org/geoserver/tiger/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=tiger:tiger_roads&maxFeatures=50&outputFormat=text/xml;%20subtype=gml/3.2"; 
			this.format = new GPXFormat(new HashMap());
		}
		
		[After] 
		public function tearDown():void
		{
			format = null;
		}
		
		[Test]
		public function testParseCoords():void
		{
			var gpx:XML = new XML(new GPX11FILE());
			var features:Vector.<Feature> = this.format.parseGpxFile(gpx);
			//this.gpxLayer = new GPX("gpxLayer","1.1",url,gpx);
			//var features:Vector.<Feature> = this.gpxLayer.featureVector;
			var pointNode:XML = this.format.buildAttributeNodes(features[0]);

			
		}
		
	}
}