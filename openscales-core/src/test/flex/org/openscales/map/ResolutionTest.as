package org.openscales.map
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;

	public class ResolutionTest
	{
		public function ResolutionTest()
		{
		}
		
		/**
		 * Validate that if you set a resolution, minResolution or maxResolution to the map,
		 *  if they are not in the same projection as the resolution of the map, they are reprojected
		 */
		[Test]
		public function shouldReprojectMinAndMaxResolutionIfNotInTheSameProjectionAsResolution():void
		{
			// Given a map with a EPSG:4326 projection
			var _map:Map = new Map(600,400,"EPSG:4326");
			
			// When I set resolution, a minResolution and a maxResolution in EPSG:2154 projection
			_map.resolution = new Resolution(10, "EPSG:2154");
			_map.maxResolution = new Resolution(2000, "EPSG:2154");
			_map.minResolution = new Resolution(2, "EPSG:2154");
			
			// Then they are reprojected in EPSG:4326 when they are in the map
			assertEquals("The resolution is not in the proper projection", "EPSG:4326", _map.resolution.projection);
			assertEquals("The maxResolution is not in the proper projection", "EPSG:4326", _map.maxResolution.projection);
			assertEquals("The minResolution is not in the proper projection", "EPSG:4326", _map.minResolution.projection);
		}
		
		/**
		 * Validate that if you change the projection of the map, then the projection of the
		 * resolutions are changed.
		 */
		[Test]
		public function shouldChangeTheProjectionOfTheResolutionsIfProjectOfTheMapIsChanged():void
		{
			// Given a map with a EPSG:4326 projection and a EPSG:4326 resolution, maxResolution and minResolution in it
			var _map:Map = new Map(600, 400, "EPSG:4326");
			_map.resolution = new Resolution(10, "EPSG:4326");
			_map.maxResolution = new Resolution(2000, "EPSG:4326");
			_map.minResolution = new Resolution(2, "EPSG:4326");
			
			// When I change the projection of the map.
			_map.projection = "EPSG:2154"
				
			// Then the projection of resolution, maxResolution and minResolution is changed and their value are reprojected
			assertEquals("The resolution is not in the proper projection", "EPSG:2154", _map.resolution.projection);
			assertEquals("The maxResolution is not in the proper projection", "EPSG:2154", _map.maxResolution.projection);
			assertEquals("The minResolution is not in the proper projection", "EPSG:2154", _map.minResolution.projection);
		}
		
		
		/**
		 * Validate that when you use the zoomIn method, the resolution is multiplied by the
		 * default zoomIn factor
		 */
		[Test]
		public function shouldChangeResolutionByTheDefaultZoomInFactorWhenZoomIn():void
		{
			// Given a map with a resolution
			var _map:Map = new Map(600, 400, "EPSG:4326");
			_map.resolution = new Resolution(10, "EPSG:4326");
			
			// When I zoomIn
			_map.defaultZoomInFactor = 0.9;
			_map.zoomIn();
			
			// Then the resolution is multiplied by the default zoomIn factor
			assertEquals("The resolution has not been properly changed by the zoomIn", 9, _map.resolution.value); 
		}
		
		/**
		 * Validate that when you use the zoomOut method, the resolution is multiplied by the
		 * default zoomOut factor
		 */
		[Test]
		public function shouldChangeResolutionByTheDefaultZoomOutFactorWhenZoomOut():void
		{
			// Given a map with a resolution
			var _map:Map = new Map(600, 400, "EPSG:4326");
			_map.resolution = new Resolution(10, "EPSG:4326");
			
			// When I zoomOut
			_map.defaultZoomOutFactor = 1.1;
			_map.zoomOut();
			
			// Then the resolution is multiplied by the default zoomOut factor
			assertEquals("The resolution has not been properly changed by the zoomOut", 11, _map.resolution.value);
		}
		
		/**
		 * Validate that when you use the zoom method with a factor as parameter, this parameter
		 * is used to multiply the resolution
		 */
		[Test]
		public function shouldChangeResolutionByTheGivenZoomFactorWhenZoom():void
		{
			// Given a map with a resolution
			var _map:Map = new Map(600, 400, "EPSG:4326");
			_map.resolution = new Resolution(10, "EPSG:4326");
			
			// When I zoom with a factor as parameter
			_map.zoom(1.2);

			// Then the resolution is multiplied by the given factor
			assertEquals("The resolution has not been properly changed by the zoom", 12, _map.resolution.value);
		}
		
		/**
		 * Validate that if you try to zoom above the maxResolution, the resolution
		 * is setted to maxResolution
		 */
		[Test]
		public function shouldSetResolutionToMaxResolutionIfZoomWhentTooFar():void
		{
			// Given a map with a resolution and a maxResolution
			var _map:Map = new Map(600, 400, "EPSG:4326");
			_map.resolution = new Resolution(10, "EPSG:4326");
			_map.maxResolution = new Resolution(12, "EPSG:4326");
			
			// When I zoom with a factor that will set the resolution above the maxResolution
			_map.zoom(1.3);
			
			// Then the resolution is setted to maxResolution
			assertEquals("The resolution has not been set to maxResolution", 12, _map.resolution.value);
		}
		
		/**
		 * Validate that if you try to zoom below the minResolution, the resolution
		 * is setted to minResolution
		 */
		[Test]
		public function shouldSetResolutionToMinResolutionIfZoomWhentTooFar():void
		{
			// Given a map with a resolution and a minResolution
			var _map:Map = new Map(600, 400, "EPSG:4326");
			_map.resolution = new Resolution(10, "EPSG:4326");
			_map.minResolution = new Resolution(8, "EPSG:4326");
			
			// When I zoom with a factor that will set the resolution below the minResolution
			_map.zoom(0.7);
			
			// Then the resolution is setted to minResolution
			assertEquals("The resolution has not been set to minResolution", 8, _map.resolution.value);
		}
	}
}