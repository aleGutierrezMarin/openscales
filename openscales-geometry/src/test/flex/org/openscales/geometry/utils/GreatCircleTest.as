package org.openscales.geometry.utils
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Unit;

	public class GreatCircleTest
	{		
		protected var point1:Point;
		protected var point2:Point;
		protected var greatCircle:GreatCircleDistance;
		
		[Before]
		public function setUp():void
		{
			point1=new Point(1.5,2.56);
			point2=new Point(1.5,45.56);
			greatCircle= new GreatCircleDistance();
		}
		
		[After]
		public function tearDown():void
		{
			point1=null;
			point2=null;
			greatCircle=null;
			
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
		public function testKILOMETER():void {
			
			var num:Number=greatCircle.calculateDistanceBetweenTwoPoints(point1,point2);
			num /= 1000;
			assertTrue("should be equal",num<4790 && num>4780);
		}
		
		[Test]
		public function testWithMeterUnit():void {
			
			var num:Number=greatCircle.calculateDistanceBetweenTwoPoints(point1,point2);
		
			//num/=Unit.getInchesPerUnit(Unit.METER);			
			//assertTrue("should be equal",num<2990 && num>2960);
			//assertEquals("should be equal",num,2971);
			num = num*Math.pow(10,3);
			num = Math.floor(num);
			num = num / Math.pow(10,3);
			
			
			assertTrue("should be equal",num<4790000 && num>4780000);
		}
		
		[Test]
		public function testWithMileUnit():void {
			
			var num:Number=greatCircle.calculateDistanceBetweenTwoPoints(point1,point2);
			num*=39.3700787;
			num/=Unit.getInchesPerUnit(Unit.MILE);
			
			//num/=Unit.getInchesPerUnit(Unit.METER);			
			//assertTrue("should be equal",num<2990 && num>2960);
			//assertEquals("should be equal",num,2971);
			num = num*Math.pow(10,3);
			num = Math.floor(num);
			num = num / Math.pow(10,3);
			
			
			assertTrue("should be equal",num<2990 && num>2960);
			//assertEquals("should be equal",num,2990);
		}
		
		[Test]
		public function testWithNauticMileUnit():void {
			
			var num:Number=greatCircle.calculateDistanceBetweenTwoPoints(point1,point2);
			num/=1000;
			num/=1.852;
			
			
			//num/=Unit.getInchesPerUnit(Unit.METER);			
			//assertTrue("should be equal",num<2990 && num>2960);
			//assertEquals("should be equal",num,2971);
			num = num*Math.pow(10,3);
			num = Math.floor(num);
			num = num / Math.pow(10,3);
			
			
			assertTrue("should be equal",num<2590 && num>2570);
			//assertEquals("should be equal",num,2990);
		}
		
		
		
		
	}
}