package org.openscales.core.layer.ogc {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.TileEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.capabilities.WMTS100;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	public class WMTSTest {
		
		private const THICK_TIME:uint = 8000;
		private const NAME:String = "WMTS Layer";
		
		private const URL:String = "http://someServer.com/wmts";
		private const REAL_URL:String = "http://openscales.org/geoserver/gwc/service/wmts";
		
		private const LAYER:String = "SCAN50_PNG_LAMB93";
		private const REAL_LAYER:String = "topp:world_borders";
		
		private const CRS:String = "IGNF:LAMB93";
		private const REAL_CRS:String = "EPSG:900913";
		
		private const MATRIX_SET_ID:String = "LAMB93_2.5m";
		private const REAL_MATRIX_SET_ID:String = "EPSG:900913";
		
		private const MATRIX_SET_ID_PM:String = "PM";
		
		private const STYLE:String = "default";
		
		private const FORMAT:String = "image/jpeg";
		
		private var _map:Map = null;
		
		private var _timer:Timer;
		private var _wmts:WMTS = null;
		private var _wms:WMS = null;
		
		private var _handler:Function = null;
		private var _handlerFail:Function = null;
		
		private var _tileMatrixSets:HashMap;
		
		[Embed(source="/assets/layer/capabilities/wmtscapabilities.xml",mimeType="application/octet-stream")]
		private const SIMPLECAPABILITIES:Class;
		
		[Embed(source="/assets/layer/capabilities/extendedwmtscapabilities.xml",mimeType="application/octet-stream")]
		private const EXTENDEDCAPABILITIES:Class;
		
		public function WMTSTest() {}
		
		[Before]
		public function setUp():void
		{
			this._timer = new Timer(THICK_TIME, 1);
			this._timer.start();
		}
		
		[After]
		public function tearDown():void
		{
			_map = null;
			
			if(this._handler!=null && _wmts)
				_wmts.removeEventListener(TileEvent.TILE_LOAD_START, this._handler);
			
			_wmts = null;
			_wms = null;
			
			if(this._timer)
			{
				if(this._handler!=null)
					this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this._handler);
				if(this._handlerFail!=null)
					this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this._handlerFail);
				
				this._timer.stop();
				this._timer = null;
			}
		}
		
		
		/**
		 * @private
		 * Return true if the passed layer exist at least once in the passed map
		 */
		private function mapHasLayer(map:Map, layer:Class):Boolean{
			
			return map.layers.some(function(item:Layer, index:uint, vector:Vector.<Layer>):Boolean{
				return (item is layer);
			});
		}
		
		/**
		 * Test the initialization of a WMTS layer with Default parameters
		 * 
		 * Given a new WMTS layer
		 * Then its default values are correctly set
		 */
		[Test]
		public function shouldHaveAppropriateDefaultParameters():void{
			
			// Given a new WMTS layer
			var layer:WMTS = new WMTS("myLayer","http://test.com/wmts","requestedLayer","tileMatrixSet");
			
			// Then its default values are correctly set
			assertEquals("Incorrect default opacity",1, layer.alpha);
			assertEquals("Incorrect default visibility",true, layer.visible);
			assertEquals("Incorrect default dpi",92,layer.dpi);
			assertEquals("Incorrect default styles parameter",null,layer.style);
			assertEquals("Incorrect default format parameter","image/jpeg",layer.format);
			assertEquals("Incorrect default projection",ProjProjection.getProjProjection("EPSG:4326").srsCode,layer.projection.srsCode);
		}
		
		/**
		 * 
		 * Given a map of 200x200px, centered on 0,0
		 * And a WMTS layer on this map
		 * When layer is redrawn
		 * Then request is sent according to the layer parameters
		 */
		[Test(async)] 
		public function shouldGenerateCorrectQueriesWithMinimumParams():void
		{
			// Given a map of 256x256px, centered on 0,12000000
			this._map = new Map();
			this._map.size = new Size(256,256);
			this._map.projection = "IGNF:LAMB93";
			//this._map.projection = "EPSG:4326";
			this._map.center = new Location(0,12000000,"IGNF:LAMB93");
			this._map.maxExtent = new Bounds(-8.38, 38.14, 14.11, 55.92, "EPSG:4326");
			
			// And a WMTS layer on this map
			var cap:WMTS100 = new WMTS100();
			var layers:HashMap = cap.read(new XML(new SIMPLECAPABILITIES()));
			var tmshm:HashMap = (layers.getValue(LAYER) as HashMap).getValue("TileMatrixSets") as HashMap;
			
			this._wmts = new WMTS(NAME,URL,LAYER, MATRIX_SET_ID,tmshm);
			this._wmts.buffer=0;
			this._wmts.style="default";
			
			// Then request is sent according to the layer parameters
			this._handler = Async.asyncHandler(this,assertGenerateCorrectQueriesWithMinimumParams,
				2000,null,noRequestSend);
			
			this._wmts.addEventListener(TileEvent.TILE_LOAD_START,this._handler);
			
			this._map.addLayer(this._wmts);
			
		}
		
		
		private function assertGenerateCorrectQueriesWithMinimumParams(event:TileEvent,obj:Object):void
		{
			this._wmts.removeEventListener(TileEvent.TILE_LOAD_START,this._handler);
			
			var url:String = event.tile.url;
			assertTrue("Request sent to incorrect server",url.match('^'+this._wmts.url));
			
			// OGC parameters (version, service & request)
			assertTrue("Incorrect VERSION", url.match('VERSION=1.0.0'));
			assertTrue("Incorrect REQUEST", url.match('REQUEST=GetTile'));
			assertTrue("Incorrect SERVICE", url.match('SERVICE=WMTS'));
			
			// wmts specific parameters
			assertTrue("Incorrect LAYER parameter",url.match('LAYER='+this._wmts.layer));
			assertTrue("Incorrect TILEMATRIXSET parameter", url.match('TILEMATRIXSET='+this._wmts.tileMatrixSet));
			assertTrue("Incorrect STYLE parameter",url.match('STYLE='+this._wmts.style));
			
		}
		
		/**
		 * Test if the tilematrixSets params is correctly set
		 * 
		 * Given a map and a WMTS layer (with tileMatrixSets to null)
		 * When the WMTS layer is add to the map
		 * Then the tileMatrixSets is defined (owing to a getCapabilities)
		 */
		[Test(async)] 
		public function shouldGenerateCorrectTileMatrixSetsWithAGetCapabilities():void
		{
			// Given a map and a WMTS layer (with tileMatrixSets to null)
			this._map = new Map();
			this._map.size = new Size(256,256);
			this._map.center = new Location(0,12000000,"IGNF:LAMB93");
			
			var wmts:WMTS = new WMTS(NAME,REAL_URL,REAL_LAYER,REAL_MATRIX_SET_ID);
			
			// When the WMTS layer is add to the map
			this._map.addLayer(wmts);
			
			// wait few times...
			this._handler = this.assertGenerateCorrectTileMatrixSetsWithAGetCapabilities;
			
			this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this._handler);
		}
		
		private function assertGenerateCorrectTileMatrixSetsWithAGetCapabilities():void{
			
			this._timer.removeEventListener(TimerEvent.TIMER,this._handler);
			
			assertNotNull("Incorrect map can't be null", this._map);
			
			// Then the layer is added with the given properties, is visible and its opacity is equal to 1
			assertTrue(mapHasLayer(this._map, WMTS));
			
			var wmts:WMTS = this._map.layers[0] as WMTS;
			
			assertNotNull("Incorrect layer musn't be null", wmts);
			
			assertEquals("Incorrect name", wmts.identifier,NAME);
			assertEquals("Incorrect url", wmts.url, REAL_URL);
			assertEquals("Incorrect layers", wmts.layer, REAL_LAYER);
			assertEquals("Incorrect tilematrixset", wmts.tileMatrixSet, REAL_MATRIX_SET_ID);
			assertNotNull("Incorrect tilesMatrixSets musn't be null", wmts.tileMatrixSets);
			assertEquals("Incorrect format", wmts.format, FORMAT);
			assertEquals("Incorrect visibility", wmts.visible, true);
			assertEquals("Incorrect opacity", wmts.alpha, 1);
			assertTrue("Incorrect displayed", wmts.displayed);
		}
		
		
		/**
		 * Test if a map with a WMTS and a WMS with EPSG:2154 display all layers correctly even if 
		 * WMTS has asynchronous behaviour
		 * 
		 * Given a map with a WMTS (as baselayer) and a WMS with Lambert projection
		 * When the WMTS is loaded
		 * Then the map contains the two layers and both are displayed
		 * 
		 */
		[Test(async)] 
		public function shouldDisplayLayersCorrectlyWithAWMTSBaselayerAndWMSWithLambert93Projection():void
		{
			// Given a map with a WMTS (as baselayer) and a WMS with Lambert projection
			this._map = new Map();
			this._map.size = new Size(256,256);
			this._map.center = new Location(0,12000000,"IGNF:LAMB93");
			
			this._wmts = new WMTS(NAME,REAL_URL,REAL_LAYER,REAL_MATRIX_SET_ID);
			this._wms = new WMS("wms", "http://openscales.org/geoserver/wms", "pg:ign_geopla_dep", null, "image/jpeg");
			this._wms.version =  "1.3.0";
			
			// When the WMTS is loaded
			this._handler = assertDisplayLayersCorrectlyWithAWMTSBaselayerAndWMSWithLambert93Projection;
			this._handlerFail = noRequestSend;
			this._wmts.addEventListener(TileEvent.TILE_LOAD_START,this._handler);
			this._timer.addEventListener(TimerEvent.TIMER_COMPLETE, this._handlerFail);
			this._map.addLayer(this._wmts);
			this._map.addLayer(this._wms);
			this._timer.start();
		}
		
		private function assertDisplayLayersCorrectlyWithAWMTSBaselayerAndWMSWithLambert93Projection(event:TileEvent):void
		{
			this._wmts.removeEventListener(TileEvent.TILE_LOAD_START,this._handler);
			
			this._timer.stop();
			this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this._handlerFail);
			this._timer = null;
			
			assertNotNull("Inccorect Map", this._map); 
			
			// Then the map contains the two layers and both are displayed
			assertEquals("Incorrect number of layers in the map", 2, this._map.layers.length);
			
			assertNotNull("Inccorect layer 0 should be WMTS", (this._map.layers[0] as WMTS)); 
			assertNotNull("Inccorect layer 1 should be WMS", (this._map.layers[1]  as WMS)); 
			
			assertTrue("Incorrect display value for the WMTS layer", this._map.layers[0].displayed);
			assertTrue("Incorrect display value for the WMS layer", this._map.layers[1].displayed);
		}
		
		/**
		 * 
		 * Given a map of 200x200px, centered on 0,0
		 * And a WMTS layer on this map with multiple TileMatrixSets
		 * When layer default projection is not in the map's projection
		 * Then layer projection is changed according to available tileMatrixSets
		 */
		[Test(async)] 
		public function shouldChangeLayerTileMatrixSetIfNotCompatibleWithMapProjection():void
		{
			// Given a map of 256x256px, centered on 0,12000000
			this._map = new Map();
			this._map.size = new Size(256,256);
			this._map.projection = "IGNF:LAMB93";
			//this._map.projection = "EPSG:4326";
			this._map.center = new Location(0,12000000,"IGNF:LAMB93");
			this._map.maxExtent = new Bounds(-8.38, 38.14, 14.11, 55.92, "EPSG:4326");
			
			// And a WMTS layer on this map
			var cap:WMTS100 = new WMTS100();
			var layers:HashMap = cap.read(new XML(new EXTENDEDCAPABILITIES()));
			var tmshm:HashMap = (layers.getValue(LAYER) as HashMap).getValue("TileMatrixSets") as HashMap;
			
			this._wmts = new WMTS(NAME,URL,LAYER, MATRIX_SET_ID_PM,tmshm);
			this._wmts.buffer=0;
			this._wmts.style="default";
			
			// Then request is sent according to the layer parameters
			this._handler = Async.asyncHandler(this,assertChangeLayerTileMatrixSetIfNotCompatibleWithMapProjection,
				2000,null,noRequestSend);
			
			this._wmts.addEventListener(TileEvent.TILE_LOAD_START,this._handler);
			
			this._map.addLayer(this._wmts);
			
		}
		
		private function assertChangeLayerTileMatrixSetIfNotCompatibleWithMapProjection(event:TileEvent,obj:Object):void
		{
			this._wmts.removeEventListener(TileEvent.TILE_LOAD_START,this._handler);
			
			assertTrue("Layer should be available", this._wmts.available);
			assertEquals("Layers projection should be in map projection", this._wmts.projection, this._map.projection);
			assertEquals("Layer TileMatrixSet should be LAMB93_2.5m", this._wmts.tileMatrixSet, MATRIX_SET_ID);
		}
		
		private function noRequestSend(event:TimerEvent):void
		{
			if(this._handler!=null && this._wmts)
				this._wmts.removeEventListener(TileEvent.TILE_LOAD_START,this._handler);
			
			this._timer.stop();
			if(this._handlerFail!=null)
				this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this._handlerFail);
			
			Assert.fail("No request sent");
		}
		
		
	}
}