package org.openscales.geometry.basetypes
{
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	/**
	 * Test class for the Bounds
	 */
	public class BoundsTest
	{
		public function BoundsTest()
		{
		}
		
		/**
		 * Validate that the intersectsBounds return true with two bounds that are 
		 * in intersection in the same projection
		 */
		[Test]
		public function shouldReturnTrueWithTwoIntersectBoundsInSameProjection():void
		{
			// Given two bounds with same projection that are in intersection
			var bounds1:Bounds = new Bounds(1,2,3,4,"EPSG:2154");
			var bounds2:Bounds = new Bounds(1,2,3,4,"EPSG:2154");
			
			// When the intersectsBounds is called
			var result:Boolean = bounds1.intersectsBounds(bounds2);
			
			// Then the function return true
			Assert.assertTrue("Bounds should intersect", result);
		}
		
		/**
		 * Validate that the intersectsBounds return false with two bounds that are 
		 * not in intersection in the same projection
		 */
		[Test]
		public function shouldReturnFalseWithTwoBoundsInSameProjectionWithNoIntersection():void
		{
			// Given two bounds with same projection that are in intersection
			var bounds1:Bounds = new Bounds(1,2,3,4,"EPSG:2154");
			var bounds2:Bounds = new Bounds(10,5,10,7,"EPSG:2154");
			
			// When the intersectsBounds is called
			var result:Boolean = bounds1.intersectsBounds(bounds2);
			
			// Then the function return true
			Assert.assertFalse("Bounds should intersect", result);
			Assert.assertFalse("Bounds should intersect", bounds2.intersectsBounds(bounds1));
		}
		
		/**
		 * Validate that the intersectsBounds return true with two bounds that are in intersection
		 * but defined in two different projections
		 */
		[Test]
		public function shouldReturnTrueWithTwoIntersectBoundsInDifferentProjection():void
		{
			// Given two bounds with different projection that are in intersection
			var bounds1:Bounds = new Bounds(1,2,3,4,"EPSG:2154");
			var bounds2:Bounds = new Bounds(1,2,3,4,"EPSG:2154");
			bounds2.reprojectTo("EPSG:4326");
			
			// When the intersectsBounds is called
			var result:Boolean = bounds1.intersectsBounds(bounds2);
			
			// Then the function return true
			Assert.assertTrue("Bounds should intersect", result);
			Assert.assertTrue("Bounds should intersect",  bounds2.intersectsBounds(bounds1));
		}
		
		/**
		 * Validate that the intersectsBounds return false with two bounds that are not in intersection
		 * and defined in two different projections
		 */
		[Test]
		public function shouldReturnFalseWithTwoBoundsInDifferentProjectionWithNoIntersection():void
		{
			// Given two bounds with different projection that are not in intersection
			var bounds1:Bounds = new Bounds(1,2,3,4,"EPSG:2154");
			var bounds2:Bounds = new Bounds(10,5,10,7,"EPSG:2154");
			bounds2.reprojectTo("EPSG:4326");
			
			// When the intersectsBounds is called
			var result:Boolean = bounds1.intersectsBounds(bounds2);
			
			// Then the function return true
			Assert.assertFalse("Bounds should intersect", result);
			Assert.assertFalse("Bounds should intersect",  bounds2.intersectsBounds(bounds1));
		}
		
		/**
		 * Validate that the containsBounds return true with two bounds that are contains one by other
		 * but defined in two different projections
		 */
		[Test]
		public function shouldReturnTrueWithTwoContainsBoundsInDifferentProjection():void
		{
			// Given two bounds with different projection that are in contains one than another one
			var bounds1:Bounds = new Bounds(1,2,10,10,"EPSG:2154");
			var bounds2:Bounds = new Bounds(1,2,3,4,"EPSG:2154");
			bounds2.reprojectTo("EPSG:4326");
			
			// When the intersectsBounds is called
			var result:Boolean = bounds1.containsBounds(bounds2);
			
			// Then the function return true
			Assert.assertTrue("Bounds should intersect", result);
		}
		
		
		/**
		 * Validate that the bounds returner by getIntersection return a proper bounds 
		 * between this bounds and the given one.
		 */
		[Test]
		public function shouldReturnTheIntersectionOfHimselfAndTheGivenBounds():void
		{
			// Given two bounds with an intersection different from on of the two bounds
			var firstBounds:Bounds = new Bounds(-180, -90, 50, 40, "EPSG:4326");
			var secondBounds:Bounds = new Bounds(-50, -40, 180, 90, "EPSG:4326");
			
			// When you ask for the intersection of the two
			var intersectionBounds:Bounds = firstBounds.getIntersection(secondBounds);
			
			// Then the result is the intersection
			assertTrue("The intersect bounds is not correct", intersectionBounds.equals(new Bounds(-50, -40, 50, 40, "EPSG:4326")));	
		}
		
		/**
		 * Validate that the bounds returned is empty if no intersection exists
		 * between this bounds and the given one
		 */
		[Test]
		public function shouldReturnEmptyBoundsIfNoIntersection():void
		{
			// Given two bounds with no intersection between them
			var firstBounds:Bounds = new Bounds(-180, -90, 0, 0, "EPSG:4326");
			var secondBounds:Bounds = new Bounds(10, 10, 180, 90, "EPSG:4326");
			
			// When you ask for the intersection of the two
			var intersectionBounds:Bounds = firstBounds.getIntersection(secondBounds);
			
			// Then the result is an empty bounds
			assertTrue("The intersect bounds is not empty", intersectionBounds.equals(new Bounds(0, 0, 0, 0, "EPSG:4326")));
		}
		
		/**
		 * Validate that if the given bounds is not in the same projection, this bounds
		 * and the given one are reprojected in EPSG:4326 to compute the intersection
		 * and the returned bounds is in EPSG:4326
		 */
		[Test]
		public function shouldReturnAnIntersectionInEPSG4326IfProjectionAreDifferent():void
		{
			// Given two bounds with an intersection with different projections
			var firstBounds:Bounds = new Bounds(-6679169.447596414, -6446275.841017161, 5565974.539663678, 4865942.279503176, "EPSG:900913");
			var secondBounds:Bounds = new Bounds(-50, -40, 180, 90, "EPSG:4326");
			
			// When you sak for the intersection of the two
			var intersectionBounds:Bounds = firstBounds.getIntersection(secondBounds);

			// Then the result is the intersection with EPSG:4326 projection
			assertTrue("The intersect bounds is not correct", intersectionBounds.equals(new Bounds(-50, -40, 49.99999999999999, 39.99999999999999, "EPSG:4326")));	
		}
		
		/**
		 * Validates that return a bounds correct according to a given string with 4 params
		 */
		[Test]
		public function shouldReturnBoundsWithDefaultProjection():void
		{
			// Given : a string (left,bottom,right,top)
			var string:String = "1,2,3,4";
			
			// When the function is called
			var bounds:Bounds = Bounds.getBoundsFromString(string);
			
			// Then the bounds retun is in default projection :
			assertEquals("Incorrect left value", 1, bounds.left);
			assertEquals("Incorrect bottom value", 2, bounds.bottom);
			assertEquals("Incorrect right value", 3, bounds.right);
			assertEquals("Incorrect top value", 4, bounds.top);
			assertEquals("Incorrect projection", "EPSG:4326", bounds.projSrsCode);
		}
		
		/**
		 * Validates that return a bounds correct according to a given string with 4 params and a given projection
		 */
		[Test]
		public function shouldReturnBoundsWithGivenProjection():void
		{
			// Given : a string (left,bottom,right,top) and a projection
			var string:String = "1,2,3,4";
			var projection:String = "EPSG:2154";
			
			// When the function is called with the string and projection
			var bounds:Bounds = Bounds.getBoundsFromString(string, projection);
			
			// Then the bounds retun is in with the given projection :
			assertEquals("Incorrect left value", 1, bounds.left);
			assertEquals("Incorrect bottom value", 2, bounds.bottom);
			assertEquals("Incorrect right value", 3, bounds.right);
			assertEquals("Incorrect top value", 4, bounds.top);
			assertEquals("Incorrect projection", projection, bounds.projSrsCode);
		}
		
		/**
		 * Validates that return a bounds correct according to a given string with 5 params
		 */
		[Test]
		public function shouldReturnBoundsWith5ParamsString():void
		{
			// Given : a string (left,bottom,right,top,projection)
			var string:String = "1,2,3,4,EPSG:2154";
			
			// When the function is called with the string and projection
			var bounds:Bounds = Bounds.getBoundsFromString(string);
			
			// Then the bounds retun is in with the given projection :
			assertEquals("Incorrect left value", 1, bounds.left);
			assertEquals("Incorrect bottom value", 2, bounds.bottom);
			assertEquals("Incorrect right value", 3, bounds.right);
			assertEquals("Incorrect top value", 4, bounds.top);
			assertEquals("Incorrect projection", "EPSG:2154", bounds.projSrsCode);
		}
		
		[Test]
		public function shouldIntersectBoundsReprojectedInEPSG4326():void
		{
			// Given two intersected bounds in IGNF:LAMB93
			var firstBounds:Bounds = new Bounds(0, -14214400, 26214400, 12000000, "IGNF:LAMB93");
			var secondBounds:Bounds = new Bounds(409600, 6265600, 614400, 6470400, "IGNF:LAMB93");
			
			// When you reproject these bounds in EPSG:4326
			var firstBoundsReproj:Bounds = firstBounds.preciseReprojectBounds(firstBounds,"IGNF:LAMB93","EPSG:4326");
			var secondBoundsReproj:Bounds = secondBounds.preciseReprojectBounds(secondBounds,"IGNF:LAMB93","EPSG:4326");
			
			// Then the bounds are still intersected
			assertEquals("Incorrect bounds intersection", firstBounds.intersectsBounds(secondBounds), firstBoundsReproj.intersectsBounds(secondBoundsReproj));
		}
	}
}