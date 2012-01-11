package org.openscales.core.configuration
{
	import flash.utils.ByteArray;
	
	import org.flexunit.Assert;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;

	/**
	 * Used some tips detailed on http://dispatchevent.org/roger/embed-almost-anything-in-your-swf/ to load XML
	 */
	public class ConfigurationTest {
		
		[Embed(source="/assets/configuration/sampleMapConfOk.xml", mimeType="application/octet-stream")]
		protected const SampleMapConfOk:Class;
		
		public function ConfigurationTest() {}
		
		[Test]
		public function testLoadingConfOkByContructor( ) : void {
			var conf:IConfiguration = new Configuration(XML(new SampleMapConfOk()));
			Assert.assertNotNull(conf);
			Assert.assertNotNull(conf.config);
		}
		
		[Test]
		public function testLayersFromMapCount( ) : void {
			var conf:IConfiguration = new Configuration(XML(new SampleMapConfOk()));
			Assert.assertEquals(2, conf.layersFromMap.length);
		}
		
		
		[Test]
		public function testHandlersCount( ) : void {
			var conf:IConfiguration = new Configuration(XML(new SampleMapConfOk()));
			Assert.assertEquals(2, conf.handlers.length());
		}
		
		[Test]
		public function testControlsCount( ) : void {
			var conf:IConfiguration = new Configuration(XML(new SampleMapConfOk()));
			Assert.assertEquals(1, conf.controls.length());
		}
		
		[Test]
		public function testConfigureMap( ) : void {
			var conf:IConfiguration = new Configuration(XML(new SampleMapConfOk()));
			var map:Map = new Map();
			map.configuration=conf;
			conf.configure();
		}
		
		[Test]
		public function testDefaultResolutions( ) : void {
			var conf:IConfiguration = new Configuration(XML(new SampleMapConfOk()));
			var map:Map = new Map();
			map.configuration=conf;
			conf.configure();
			
			Assert.assertEquals(String(Layer.DEFAULT_NUM_ZOOM_LEVELS), map.getLayerByIdentifier("Metacarta").resolutions.length);
			Assert.assertEquals(String(Layer.DEFAULT_NOMINAL_RESOLUTION.value), map.getLayerByIdentifier("Metacarta").resolutions[0]);			
		}
		
		
	}

}


