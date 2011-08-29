package org.openscales.core
{
	import org.flexunit.Assert;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	
	public class MapTest
	{
		public static const EPSILON:Number = 0.01;
		
		[Test]
		public function testEmptyNewMap( ) : void {
			var map:Map = new Map();
			Assert.assertNotNull(map);
		}
		
		[Test]
		public function testSize( ) : void {
			var map:Map = new Map();
			var size:Size = new Size(100, 200);
			map.size = size;	
			Assert.assertEquals(size.h, map.size.h);
			Assert.assertEquals(size.w, map.size.w);
		}
		
		[Test]
		public function testDefaultMaxExtent( ) : void {
			var map:Map = new Map();
			var defaultMaxExtent:Bounds = map.maxExtent;
			
			// Default max extent shoudl be worldlide
			Assert.assertEquals(-180, defaultMaxExtent.left);
			Assert.assertEquals(-90, defaultMaxExtent.bottom);
			Assert.assertEquals(180, defaultMaxExtent.right);
			Assert.assertEquals(90, defaultMaxExtent.top);
		}
		
		[Test]
		public function testMaxExtent( ) : void {
			var map:Map = new Map();
			map.maxExtent = new Bounds(1, 2, 3, 4, "EPSG:4326");
			var defaultMaxExtent:Bounds = map.maxExtent;
			
			Assert.assertEquals(1, defaultMaxExtent.left);
			Assert.assertEquals(2, defaultMaxExtent.bottom);
			Assert.assertEquals(3, defaultMaxExtent.right);
			Assert.assertEquals(4, defaultMaxExtent.top);
		}
		
		[Test]
		public function testDefaultCenter( ) : void {
			var map:Map = new Map();
			Assert.assertEquals("Incorrect center", Map.DEFAULT_CENTER, map.center);			
		}
		
		[Test]
		public function testCenter( ) : void {
			var map:Map = new Map();
			map.center = new Location(1,2);
			Assert.assertEquals(1, map.center.lon);
			Assert.assertEquals(2, map.center.lat);
		}
		
		/**
		 * Should zoom to the given extent when the zoomToExtent function is called
		 */
		[Test]
		public function shouldZoomToGivenExtent():void
		{
			// Given a map and a bounds that is contains in map maxExtent
			var map:Map = new Map();
			map.maxExtent = new Bounds(-180, -90, 180, 90, "EPSG:4326");			
			var bounds:Bounds = new Bounds(-50, -10, 50, 10, "EPSG:4326");
			
			// When the function zoomToExtent is called
			map.zoomToExtent(bounds);
			
			// Then the map current extent is the given extent
			var newExtent:Bounds = map.extent;
			
			Assert.assertTrue("incorrect asked extent must be in current", newExtent.containsBounds(bounds));
			
			// lon or lat should be at given extent :
			var isLon:Boolean = (Math.abs(newExtent.left-bounds.left)<EPSILON);
			var isLat:Boolean = (Math.abs(newExtent.top-bounds.top)<EPSILON);
			
			Assert.assertTrue("incorrect at least lon or lat should be at given extent", (isLon || isLat));
			
		}
		
		/**
		 * Should not zoom to a given extent that is not contain by the map max extent
		 */
		[Test]
		public function shouldNotZoomToGivenExtentIfNotInMaxExtent():void
		{
			// Given a map and a bounds that is NOT contains in map maxExtent
			var map:Map = new Map();
			map.maxExtent = new Bounds(-180, -90, 180, 90, "EPSG:4326");			
			var bounds:Bounds = new Bounds(-200, -100, -200, -100, "EPSG:4326");
			var oldBounds:Bounds = map.extent;
			
			// When the function zoomToExtent is called
			map.zoomToExtent(bounds);
			
			// Then the map current extent hasn't changed
			var newExtent:Bounds = map.extent;
			
			Assert.assertTrue("Incorrect left extent value", (Math.abs(newExtent.left-oldBounds.left)<EPSILON));
			Assert.assertTrue("Incorrect right extent value", (Math.abs(newExtent.right-oldBounds.right)<EPSILON));
			Assert.assertTrue("Incorrect top extent value", (Math.abs(newExtent.top-oldBounds.top)<EPSILON));
			Assert.assertTrue("Incorrect bottom extent value", (Math.abs(newExtent.bottom-oldBounds.bottom)<EPSILON));
			Assert.assertEquals("Incorrect projection value", oldBounds.projSrsCode, newExtent.projSrsCode);
			
		}

	}
}