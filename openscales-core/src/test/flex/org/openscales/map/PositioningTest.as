package org.openscales.map {
	
	import flash.events.Event;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Location;
	
	public class PositioningTest{ 		
				
		/**
		 * Precision for Number comparisons
		 */
		private const PRECISION:Number = 1e-7;
		
		/**
		 * Initial resolution of the map
		 */
		private const INITIAL_RESOLUTION:Resolution = new Resolution(0.3515625, "EPSG:4326");
		
		private var _map:Map;
		
		public function PositioningTest() {}
		
		[Before]
		public function setUpMap():void{
			
			// Given a map centered on 0,0 
			this._map = new Map();
			_map.center = new Location(0,0,'EPSG:4326');
			
			// And that map has a layer (mandatory for correct pan behaviour)
			var layer:Layer = new Layer('Some layer');
			layer.projSrsCode = 'EPSG:4326';
			_map.addLayer(layer);
			
			// And that map is displayed at a resolution of 0.3515625°/px
			_map.maxResolution = Map.DEFAULT_MAX_RESOLUTION;
			_map.minResolution = Map.DEFAULT_MIN_RESOLUTION;
			_map.resolution = INITIAL_RESOLUTION;
		}
		
		/**
		 * Validates map center change when panning
		 */
		[Test(async)]
		public function shouldUpdateMapCenterWhenPanning():void{
			
			// Then an event is dispatched advertising center change
			_map.addEventListener(MapEvent.CENTER_CHANGED,Async.asyncHandler(this,function(event:MapEvent,obj:Object):void{
			},2000,null,function(event:Event):void{
				fail("No event received for center change");
			}));
			
			// When the map is panned.
			_map.pan(40,40);	
			
			// And the map center is changed accordingly
			assertTrue("Incorrect map lattitude",-14.0625 - _map.center.lat < PRECISION);
			assertTrue("Incorrect map longitude",-14.0625 - _map.center.lon < PRECISION);
		}
		
		/**
		 * 
		 */
		[Test(async)]
		public function shouldUpdateMapResolution():void{
			
			// Then an event is dispatched advertising zoom change
			_map.addEventListener(MapEvent.RESOLUTION_CHANGED, Async.asyncHandler(this, function(event:MapEvent,obj:Object):void{
			},2000, null, function(event:Event):void{
				
				fail("No event received for zoom change");
			}));
			
			// When map resolution is setted
			_map.resolution = new Resolution(0.703125, "EPSG:4326");
			
			// And resolution is set to this value
			assertTrue('Incorrect resolution', 0.703125 - _map.resolution.value < PRECISION);
		}
		
		/**
		 * Validates map resolution change when zooming in
		 */
		[Test(async)]
		public function shouldZoomTheMapIn():void{
			_map.resolution = _map.maxResolution;
			// Then an event is dispatched advertising zoom change
			_map.addEventListener(MapEvent.RESOLUTION_CHANGED, Async.asyncHandler(this, function(event:MapEvent,obj:Object):void{
			},2000, null, function(event:Event):void{
				
				fail("No event received for zoom change");
			}));
			
			_map.zoomIn();
			
			// And the map resolution is changed
			assertTrue("Incorrect map resolution",(_map.resolution.value < _map.maxResolution.value) &&  (_map.resolution.value >= _map.minResolution.value));
		}
		
		/**
		 * Validates map resolution change when zooming out
		 */
		[Test(async)]
		public function shouldZoomTheMapOut():void{
			_map.resolution = _map.minResolution;
			
			// Then an event is dispatched advertising zoom change
			_map.addEventListener(MapEvent.RESOLUTION_CHANGED, Async.asyncHandler(this, function(event:MapEvent,obj:Object):void{
			},2000, null, function(event:Event):void{
				fail("No event received for zoom change");
			}));
			
			_map.zoomOut();
			
			// And the map resolution is changed
			assertTrue("Incorrect map resolution",(_map.resolution.value <= _map.maxResolution.value) &&  (_map.resolution.value > _map.minResolution.value));
		}
		
		[Test(async)]
		public function shouldNotZoomOutIfMaxResolutionIsReached():void{
			_map.resolution = _map.maxResolution;
			
			// Then no event is dispatched advertising zoom change
			_map.addEventListener(MapEvent.RESOLUTION_CHANGED, Async.asyncHandler(this, function(event:MapEvent,obj:Object):void{
				if(event.map.resolution.value < event.map.maxResolution.reprojectTo(event.map.resolution.projection).value)
					fail("Event received for zoom change");
			},2000, null, function(event:Event):void{
			}));
			
			_map.zoomOut();
			
			// And the map resolution is changed
			assertTrue("Incorrect map resolution",_map.maxResolution.value - _map.resolution.value < PRECISION);
		}
		
		[Test(async)]
		public function shouldNotZoomInIfMinResolutionIsReached():void{
			// Given the map has a minResolution
			_map.resolution = _map.minResolution;
			
			// Then no event is dispatched advertising zoom change
			_map.addEventListener(MapEvent.RESOLUTION_CHANGED, Async.asyncHandler(this, function(event:MapEvent,obj:Object):void{
				if(event.map.resolution.value < event.map.minResolution.reprojectTo(event.map.resolution.projection).value)
					fail("Event received for zoom change");
			},2000, null, function(event:Event):void{
			}));
			
			_map.zoomIn();
			
			// And the map resolution is changed
			assertTrue("Incorrect map resolution",_map.minResolution.value - _map.resolution.value < PRECISION);
		}
	}
}
		
		
