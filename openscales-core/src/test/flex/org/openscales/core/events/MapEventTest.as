package org.openscales.core.events
{
	import flash.events.TimerEvent;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.geometry.basetypes.Location;

	public class MapEventTest
	{		
		private var _map:Map;
		
		private var _layer1:WMS;
		private var _layer2:WMS;
		private var _layer3:WMS;
		
		private const URL:String = "http://some.domain.com/wms";
		private const LAYERS:String = "bluemarble";
		private const FORMAT:String = "image/jpeg";
		
		private var _handler:Function = null;
		
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
		
		/**
		 * Validates that when the LAYERS_LOAD_START is dispatched at least one layer of the map is currently loading
		 */
		[Test(async)]
		public function shouldDispatchLayersLoadStartWhenALayerStartLoading():void
		{
			// Given a map
			this._map = new Map();
			
			_layer1 = new WMS("Layer 1", URL, LAYERS, "", FORMAT);
			_layer2 = new WMS("Layer 2", URL, LAYERS, "", FORMAT);
			_layer3 = new WMS("Layer 3", URL, LAYERS, "", FORMAT);
			
			this._handler = Async.asyncHandler(this,assertDispatchLayersLoadStartWhenALayerStartLoading,
				2000,null,noEventReceived);
			
			// When the LAYERS_LOAD_START is dispatched
			this._map.addEventListener(MapEvent.LAYERS_LOAD_START,this._handler);
			
			this._map.addLayer(_layer1);
			this._map.addLayer(_layer2);
			this._map.addLayer(_layer3);
			this._map.center = new Location(2,48,"EPSG:4326");
		}
		
		private function noEventReceived(event:TimerEvent):void
		{
			if(this._handler!=null && this._map)
				this._map.removeEventListener(MapEvent.LAYERS_LOAD_START,this._handler);
			
			Assert.fail("No event received");
		}
		
		private function assertDispatchLayersLoadStartWhenALayerStartLoading(event:MapEvent,obj:Object):void
		{		
			if(this._handler!=null && this._map)
				this._map.removeEventListener(MapEvent.LAYERS_LOAD_START,this._handler);
			
			// Then at least one layer is loading
			var result:Boolean = false;
			var i:int = 0;
			var j:int = this._map.layers.length;
			for(; i<j; ++i)
			{
				if(this._map.layers[i].loadComplete==false)
				{
					result = true;
					break;
				}
			}
			
			assertTrue("Incorerct must be one layer loading",result);
			
		}
		
		/**
		 * Validates that when the LAYERS_LOAD_END is dispatched when no layer of the map is currently loading
		 */
		[Test(async)]
		public function shouldDispatchLayersLoadEndWhenLayersStopLoading():void
		{
			// Given a map
			this._map = new Map();
			
			_layer1 = new WMS("Layer 1", URL, LAYERS, "", FORMAT);
			_layer2 = new WMS("Layer 2", URL, LAYERS, "", FORMAT);
			_layer3 = new WMS("Layer 3", URL, LAYERS, "", FORMAT);
			
			this._handler = Async.asyncHandler(this,assertDispatchLayersLoadEndWhenLayersStopLoading,
				2000,null,noEventReceived);
			
			// When the LAYERS_LOAD_START is dispatched
			this._map.addEventListener(MapEvent.LAYERS_LOAD_END,this._handler);
			
			this._map.addLayer(_layer1);
			this._map.addLayer(_layer2);
			this._map.addLayer(_layer3);
			this._map.center = new Location(2,48,"EPSG:4326");
		}
		
		private function assertDispatchLayersLoadEndWhenLayersStopLoading(event:MapEvent,obj:Object):void
		{
			if(this._handler!=null && this._map)
				this._map.removeEventListener(MapEvent.LAYERS_LOAD_START,this._handler);
			
			// Then at least one layer is loading
			var result:Boolean = false;
			var i:int = 0;
			var j:int = this._map.layers.length;
			for(; i<j; ++i)
			{
				if(this._map.layers[i].loadComplete==false)
				{
					result = true;
					break;
				}
			}
			
			Assert.assertFalse("Incorerct must be no layer loading",result);
			
		}
	}
}