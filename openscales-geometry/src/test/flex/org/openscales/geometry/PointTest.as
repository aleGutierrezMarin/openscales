package org.openscales.geometry
{
	import org.flexunit.Assert;
	import org.openscales.geometry.basetypes.Bounds;
	
	public class PointTest
	{		
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
		
		[Test]
		public function testClonePoint():void {
			
			var point:Point =  new Point(4,5);
			var point2:Point = point.clone() as Point;
			Assert.assertStrictlyEquals(point.x,point2.x);
			Assert.assertStrictlyEquals(point.y,point2.y);
		}
		
		[Test]
		public function testEqualsPoint():void {
			
			var point:Point =  new Point(4,5);
			var point2:Point = point.clone() as Point;
			Assert.assertTrue(point.equals(point2));
		}
		
		[Test]
		public function testToShortSTringPoint():void {
			
			var point:Point =  new Point(4,5);
			
			Assert.assertEquals(point.toShortString(),"4, 5"); 
		}
		
		[Test]
		public function testMovePoint():void {
			
			var point:Point =  new Point(4,5);
			point.move(2,4);
			Assert.assertStrictlyEquals(point.x,6);
			Assert.assertStrictlyEquals(point.y,9);
		}
		
		[Test]
		public function testTransformPoint():void {
			Assert.fail("TODO");
		}
		
		[Test]
		public function testIntersectsPoint():void {
			
			var point:Point =  new Point(4,5);
			var point2:Point = new Point(4,5);
			point.intersects(point2);
		}
		
		[Test]
		public function testDistanceToPoint():void {
			Assert.fail("TODO");
		}
		
		[Test]
		public function testBoundsToPoint():void {
			var point:Point =  new Point(4,5);
			var bounds:Bounds = point.bounds;
			Assert.assertStrictlyEquals(4,bounds.right);
			Assert.assertStrictlyEquals(4,bounds.left);
			Assert.assertStrictlyEquals(5,bounds.top);
			Assert.assertStrictlyEquals(5,bounds.bottom);
		}
		
		
	}
}