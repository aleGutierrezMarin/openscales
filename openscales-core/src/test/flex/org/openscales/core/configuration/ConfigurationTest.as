package org.openscales.core.configuration
{
	import flash.utils.ByteArray;
	
	import org.flexunit.Assert;
	import org.openscales.core.Map;

	/**
	 * Used some tips detailed on http://dispatchevent.org/roger/embed-almost-anything-in-your-swf/ to load XML
	 */
	public class ConfigurationTest {
		
		[Embed(source="/assets/configuration/sampleMapConfOk.xml", mimeType="application/octet-stream")]
		protected const SampleMapConfOk:Class;
		
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
		public function testLayersFromCatalogCount( ) : void {
			var conf:IConfiguration = new Configuration(XML(new SampleMapConfOk()));
			Assert.assertEquals(5, conf.layersFromCatalog.length);
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
			
			Assert.assertEquals("16", map.getLayerByName("Metacarta").resolutions.length);
			Assert.assertEquals("1.40625", map.getLayerByName("Metacarta").resolutions[0]);			
		}
		
		[Test]
		public function testGenerateResolutions( ) : void {
			var conf:IConfiguration = new Configuration(XML(new SampleMapConfOk()));
			var map:Map = new Map();
			map.configuration=conf;
			conf.configure();
			
			Assert.assertEquals("20", map.baseLayer.resolutions.length);
			Assert.assertEquals("156543.0339", map.baseLayer.resolutions[0]);
			Assert.assertEquals("0.29858214168548586", map.baseLayer.resolutions[19]);
			
		}

	}

}


