package org.openscales.core.layer.ogc {
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.TileEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.capabilities.WMTS100;
	import org.openscales.core.layer.ogc.wmts.TileMatrix;
	import org.openscales.core.layer.ogc.wmts.TileMatrixSet;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class WMTSTest {
		
		private const THICK_TIME:uint = 5000;
		private const THICK_TIME_OUT:uint = 7000;
		private const NAME:String = "WMTS Layer";
		
		private const URL:String = "http://someServer.com/wmts";
		private const REAL_URL:String = "http://openscales.org/geoserver/gwc/service/wmts";
		
		private const LAYER:String = "SCAN50_PNG_LAMB93";
		private const REAL_LAYER:String = "topp:world_borders";
		
		private const CRS:String = "IGNF:LAMB93";
		private const REAL_CRS:String = "EPSG:900913";
		
		private const MATRIX_SET_ID:String = "LAMB93_2.5m";
		private const REAL_MATRIX_SET_ID:String = "EPSG:900913";
		
		private const STYLE:String = "default";
		
		private const FORMAT:String = "image/jpeg";
		
		private var _map:Map = null;
		
		private var _timer:Timer;
		
		
		private var _handler:Function = null;
		
		private var _tileMatrixSets:HashMap;
		
		[Embed(source="/assets/layer/capabilities/wmtscapabilities.xml",mimeType="application/octet-stream")]
		private const SIMPLECAPABILITIES:Class;
		
		public function WMTSTest() {}
		
		[Before]
		public function setUp():void
		{
			this._timer = new Timer(THICK_TIME);
			this._timer.start();
		}
		
		[After]
		public function tearDown():void
		{
			_map = null;
			this._timer.stop();
		}
		
		/**
		 * @private
		 * On timer function to launch method asynchronous on timer event
		 * @param event The event received
		 * @param passThroughData An object given as parameter for the function to call
		 */
		private function onTimer(event:TimerEvent,passThroughData:Object):void{
			
			var steps:Array = passThroughData as Array;
			
			if(steps.length){
				var step:Object = steps.shift();
				var f:Function = null;
				var args:Array = [];
				
				if(step is Function){
					f = step as Function;
				}
				else{
					f = step.shift() as Function;
					args = step as Array;
				}
				
				f.apply(this,args);
				var handler:Function = Async.asyncHandler(this,this.onTimer,THICK_TIME+100,steps);
				this._timer.addEventListener(TimerEvent.TIMER,handler);
			}
			else{
				this._timer.stop();
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
			assertEquals("Incorrect default projection","EPSG:4326",layer.projSrsCode);
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
			var map:Map = new Map();
			map.size = new Size(256,256);
			map.center = new Location(0,12000000,"IGNF:LAMB93");
			
			// And a WMTS layer on this map
			var cap:WMTS100 = new WMTS100();
			var layers:HashMap = cap.read(new XML(new SIMPLECAPABILITIES()));
			var tmshm:HashMap = (layers.getValue(LAYER) as HashMap).getValue("TileMatrixSets") as HashMap;
			var wmts:WMTS = new WMTS(NAME,URL,LAYER, MATRIX_SET_ID,tmshm);
			wmts.buffer=0;
			wmts.style="default";
			map.addLayer(wmts);
			
			// Then request is sent according to the layer parameters
			wmts.addEventListener(TileEvent.TILE_LOAD_START,Async.asyncHandler(this,function(event:TileEvent,obj:Object):void{
				
				var url:String = event.tile.url;
				assertTrue("Request sent to incorrect server",url.match('^'+wmts.url));
				
				// OGC parameters (version, service & request)
				assertTrue("Incorrect VERSION", url.match('VERSION=1.0.0'));
				assertTrue("Incorrect REQUEST", url.match('REQUEST=GetTile'));
				assertTrue("Incorrect SERVICE", url.match('SERVICE=WMTS'));
				
				// wmts specific parameters
				assertTrue("Incorrect LAYER parameter",url.match('LAYER='+wmts.layer));
				assertTrue("Incorrect TILEMATRIXSET parameter", url.match('TILEMATRIXSET='+wmts.tileMatrixSet));
				assertTrue("Incorrect STYLE parameter",url.match('STYLE='+wmts.style));
				
			},100,null,function(obj:Object):void{
				
				fail("No request sent");
			}));
			
			// When layer is redrawn
			wmts.redraw();
			
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
			this._handler = Async.asyncHandler(this,this.onTimer,6000,[
				[this.assertGenerateCorrectTileMatrixSetsWithAGetCapabilities,this._map]] );
			
			
			this._timer.addEventListener(TimerEvent.TIMER,this._handler);
		}
		
		private function assertGenerateCorrectTileMatrixSetsWithAGetCapabilities(passThroughData:Object):void{
			
			this._timer.removeEventListener(TimerEvent.TIMER,this._handler);
			
			this._map = passThroughData as Map;
			
			assertNotNull("Incorrect map can't be null", this._map);
			
			// Then the layer is added with the given properties, is visible and its opacity is equal to 1
			assertTrue(mapHasLayer(this._map, WMTS));
			
			var wmts:WMTS = this._map.layers[0] as WMTS;
			
			assertNotNull("Incorrect layer musn't be null", wmts);
			
			assertEquals("Incorrect name", wmts.name,NAME);
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
			
			var wmts:WMTS = new WMTS(NAME,REAL_URL,REAL_LAYER,REAL_MATRIX_SET_ID);
			var wms:WMS = new WMS("wms", "http://openscales.org/geoserver/wms", "pg:ign_geopla_dep", null, "image/jpeg");
			wms.version =  "1.3.0";
			
			this._map.addLayer(wmts);
			this._map.addLayer(wms);
			
			// When the WMTS is loaded
			wmts.addEventListener(TileEvent.TILE_LOAD_START,Async.asyncHandler(this,function(event:TileEvent,obj:Object):void{
		
				var map:Map = obj as Map;
				assertNotNull("Inccorect Map", map); 
				
				// Then the map contains the two layers and both are displayed
				assertEquals("Incorrect number of layers in the map", 2, map.layers.length);
				assertNotNull("Inccorect baselayer type", (map.baseLayer as WMTS)); 
				
				assertNotNull("Inccorect layer 0 should be WMTS", (map.layers[0] as WMTS)); 
				assertNotNull("Inccorect layer 1 should be WMS", (map.layers[1]  as WMS)); 
				
				assertTrue("Incorrect display value for the WMTS layer", map.layers[0].displayed);
				assertTrue("Incorrect display value for the WMS layer", map.layers[1].displayed);
				
			},100,this._map,function(obj:Object):void{
				
				fail("No request sent");
			}));
			
		}
		
	}
}