package org.openscales.core.layer
{
	import org.flexunit.Assert;
	import org.openscales.core.Map;
	import org.openscales.core.ns.os_internal;
	
	use namespace os_internal;

	public class GraticuleTest
	{
		
		[Test]
		public function testBestInterval():void {
			var graticule:Graticule = new Graticule("test", null);
			var interval:Number = graticule.getBestInterval(0, 100, 0, 100);
			Assert.assertEquals("testBestInterval 1", 30, interval); 
			interval = graticule.getBestInterval(0, 80, 0, 80);
			Assert.assertEquals("testBestInterval 2", 20, interval);
			interval = graticule.getBestInterval(0, 100, 0, 80);
			Assert.assertEquals("testBestInterval 3", 20, interval);
			interval = graticule.getBestInterval(0, 80, 0, 100);
			Assert.assertEquals("testBestInterval 4", 20, interval);
		}
		
		[Test]
		public function testFirstCoordinateForGraticule():void {
			var graticule:Graticule = new Graticule("test", null);
			var firstCoordinate:Number = graticule.getFirstCoordinateForGraticule(69, 10);
			Assert.assertEquals("testFirstCoordinateForGraticule 1", 60, firstCoordinate); 
			firstCoordinate = graticule.getFirstCoordinateForGraticule(71, 10);
			Assert.assertEquals("testFirstCoordinateForGraticule 2", 70, firstCoordinate);
			firstCoordinate = graticule.getFirstCoordinateForGraticule(69.7, 0.2);
			Assert.assertTrue("testFirstCoordinateForGraticule 3", firstCoordinate <= 69.6000001 && firstCoordinate >= 69.5999999);
		}
		
		[Test]
		public function testIntervals():void {
			var graticule:Graticule = new Graticule("test", null);
			graticule.intervals = [50, 25, 10, 5, 1, 0.5, 0.1];
			Assert.assertEquals("testIntervals 1", 7, graticule.intervals.length);
			var interval:Number = graticule.getBestInterval(0, 100, 0, 100);
			Assert.assertEquals("testIntervals 2", 25, interval);
		}
		
		[Test]
		public function testMinNumberOfLines():void {
			var graticule:Graticule = new Graticule("test", null);
			graticule.minNumberOfLines = 5;
			Assert.assertEquals("testMinNumberOfLines 1", 5, graticule.minNumberOfLines);
			var interval:Number = graticule.getBestInterval(0, 100, 0, 100);
			Assert.assertEquals("testMinNumberOfLines 2", 10, interval);
		}
	}
}