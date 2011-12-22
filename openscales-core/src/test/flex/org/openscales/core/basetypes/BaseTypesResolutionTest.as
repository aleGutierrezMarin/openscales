package org.openscales.core.basetypes
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.geometry.Geometry;
	import org.openscales.proj4as.ProjProjection;

	public class BaseTypesResolutionTest
	{
		
		private var _resolution:Resolution;
		
		public function BaseTypesResolutionTest()
		{
		}
		
		/**
		 * Validate that the resolution returned is reprojected if asked for 
		 * a different projection
		 */
		[Test]
		public function shouldReprojectResolution():void
		{
			// Given a resolution in EPSG:4326
			_resolution = new Resolution(2, Geometry.DEFAULT_SRS_CODE);
			
				
			// When I ask for a reprojection in EPSG:2154
			var _theOtherOne:Resolution = _resolution.reprojectTo("EPSG:2154");
			
			// Then the returned resolution is in EPSG:2154
			assertEquals("The projection has not changed", ProjProjection.getProjProjection("EPSG:2154"), _theOtherOne.projection);
			assertTrue("The resolution value is wrong", _theOtherOne.value < 293042.5523);
			assertTrue("The resolution value is wrong", _theOtherOne.value > 293042.5522);
		}
	}
}