package org.openscales.map
{
	import flash.events.TimerEvent;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.MapEvent;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;

	public class ProjectionTest
	{
		
		/**
		 * Map used for the tests. It's created for each test and destroyed after each test
		 */
		private var _map:Map;
		
		public function ProjectionTest()
		{
		}
		
		/**
		 * Validates that when you change the projection of the map, an event is dispatched
		 * with the proper attributes to allow listening methods to know the old and new 
		 * projection
		 */		
		[Test(async)]
		public function shouldDispatchEventWithOldAndNewProjectionParamWhenProjectionChanged():void
		{
			// Given a map with a defined projection
			this._map = new Map(600, 400, "EPSG:2154");
			
			
			this._map.addEventListener(MapEvent.PROJECTION_CHANGED,Async.asyncHandler(this,this.assertProjectionEventDispatched,2000,null,this.onTimeOut));
			
			// When you set a new projection
			this._map.projection = "EPSG:4326";
			
		}
		
		private function assertProjectionEventDispatched(event:MapEvent, passThroughtData:Object):void
		{
			// Then, an event is dispatched with the proper attributes
			assertEquals("The oldProjection parameter is not good","EPSG:2154", event.oldProjection); 
			assertEquals("The newProjection parameter is not good","EPSG:4326", event.newProjection); 
		}
		
		/**
		 * Validates that when you change the projection of the map, the projection of the center, the 
		 * maxExtent and the resolution is also changed
		 */
		[Test(async)]
		public function shouldChangedResolutionMaxExtentAndCenterProjectionWhenChangingMapProjection():void
		{
			// Given a map with a defined projection, a resolution and a center
			this._map = new Map(600, 400, "EPSG:2154");
			this._map.maxExtent = new Bounds(-5, 42, 5, 45, "EPSG:2154");
			this._map.resolution = new Resolution(12000,"EPSG:2154");
			this._map.center = new Location(0, 43, "EPSG:2154");
			
			this._map.addEventListener(MapEvent.PROJECTION_CHANGED, Async.asyncHandler(this, this.assertMapVariablesProjectionChanged, 2000, this._map, this.onTimeOut));
			
			// When you set a new projection
			this._map.projection = "EPSG:4326";
		}
		
		private function assertMapVariablesProjectionChanged(event:MapEvent, passThroughtData:Object):void
		{
			var _theMap:Map = (passThroughtData as Map);
			
			// Then, the resolution, the maxExtent and the center are reprojected
			assertEquals("The map resolution has not been reprojected", "EPSG:4326", _theMap.resolution.projection);
			assertEquals("The map center has not been reprojected", "EPSG:4326", _theMap.center.projSrsCode);
			assertEquals("The map maxExtent has not been reprojected", "EPSG:4326", _theMap.maxExtent.projSrsCode);
		}
		
		/**
		 * TimeOut function launched when the asyncHandler times out
		 */
		private function onTimeOut(event:TimerEvent):void{
			fail("Timeout");
		}
	}
}