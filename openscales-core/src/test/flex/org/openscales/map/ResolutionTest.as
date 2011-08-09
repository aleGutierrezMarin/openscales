package org.openscales.map
{
	import org.flexunit.asserts.fail;

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
			// When I set resolution, a minResolution and a maxResolution in EPSG:2154 projection
			// Then they are reprojected in EPSG:4326 when they are in the map
			fail("Not implemented yet");
		}
		
		/**
		 * Validate that if you change the projection of the map, then the projection of the
		 * resolutions are changed.
		 */
		[Test]
		public function shouldChangeTheProjectionOfTheResolutionsIfProjectOfTheMapIsChanged():void
		{
			// Given a map with a EPSG:4326 projection and a EPSG:4326 resolution, maxResolution and minResolution in it
			// When I change the projection of the map.
			// Then the projection of resolution, maxResolution and minResolution is changed and their value are reprojected
			fail("Not implemented yet");
		}
		
	}
}