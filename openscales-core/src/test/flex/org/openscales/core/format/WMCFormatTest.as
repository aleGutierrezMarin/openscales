package org.openscales.core.format
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.geometry.basetypes.Size;

	public class WMCFormatTest
	{
		
		[Embed(source="/assets/format/wmc/GeneralTest.xml",mimeType="application/octet-stream")]
		private const WMCGeneralType:Class;
		
		[Embed(source="/assets/format/wmc/LayerTypeTest.xml",mimeType="application/octet-stream")]
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
			this.format.read(wmcFile);
			assertEquals("Wrong window width parsing", 500, this.format.windowSize.w);
			assertEquals("Wrong window height parsing", 300, this.format.windowSize.h);
			assertEquals("Wrong bbox left parsing", -180, this.format.generalBbox.left);
			assertEquals("Wrong bbox bottom parsing", -90, this.format.generalBbox.bottom);
			assertEquals("Wrong bbox right parsing", 180, this.format.generalBbox.right);
			assertEquals("Wrong bbox top parsing", 90, this.format.generalBbox.top);
			assertEquals("Wrong bbox SRS parsing", "EPSG:4326", this.format.generalBbox.projection);
		}
		
		[Test]
		public function shouldWMCParseLayerType():void
		{
			var wmcFile:XML = new XML(new WMCLayerType());
			this.format.read(wmcFile);
			var layers:Vector.<Layer> = this.format.layerList;
			assertEquals("wrong layer number", 2, layers.length);
			var layer1:Layer = layers[0];
			assertTrue("Wrong layer service parsing", (layer1 is WMS));
			assertEquals("Wrong layer version parsing", "1.1.1", (layer1 as WMS).version);
			assertEquals("Wrong service url parsing", "http://openscales.org/geoserver/ows", (layer1 as WMS).url);
			assertEquals("Wrong layer name parsing", "bluemarble", (layer1 as WMS).layers);
			assertEquals("Wrong layer title parsing", "bluemarble_I18N", (layer1 as WMS).name);
			assertTrue("Wrong layer minScaleDenominator", (0.0000106 <(layer1 as WMS).minResolution.value) && (0.0000108 >(layer1 as WMS).minResolution.value))
			assertEquals("Wrong layer minScaleDenominator projection", "EPSG:4326", (layer1 as WMS).minResolution.projection);
			assertTrue("Wrong layer maxScaleDenominator", (0.00004291 <(layer1 as WMS).maxResolution.value) && (0.00004292 >(layer1 as WMS).maxResolution.value))
			assertEquals("Wrong layer maxScaleDenominator projection", "EPSG:4326", (layer1 as WMS).maxResolution.projection);
			assertEquals("Wrong layer srs parsing", "EPSG:4326", (layer1 as WMS).projection);
			assertEquals("Wrong layer default format parsing", "image/gif", (layer1 as WMS).format);	
		}
	}
}