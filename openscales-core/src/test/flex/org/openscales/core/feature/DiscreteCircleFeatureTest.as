package org.openscales.core.feature
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.openscales.core.ns.os_internal;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;

	use namespace os_internal; 
	
	public class DiscreteCircleFeatureTest
	{	
		private var _instance:DiscreteCircleFeature;
		private var _defaultDiscretization:Number = DiscreteCircleFeature.discretization;
		
		public function DiscreteCircleFeatureTest(){
		}
		
		[Before]
		public function setUp():void
		{
			var center:Location = new Location(-4.35,48.34,"EPSG:4326");
			_instance = new DiscreteCircleFeature(center,15000);
		}
		
		[After]
		public function tearDown():void
		{
			_instance = null;
			DiscreteCircleFeature.discretization = _defaultDiscretization;
		}	
		
		[Test]
		public function shouldHaveAsManyPointsAsDefaultDiscretizationNumber():void{
			//DiscreteCircleFeature.discretization = 48;
			_instance.calculateGeometry();
			assertEquals("There should be as many points as default discretization value",
				DiscreteCircleFeature.discretization,
				((_instance.geometry as Polygon).componentByIndex(0) as MultiPoint).componentsLength
				);
		}
		
		[Test]
		public function shouldHaveAsManyPointsAsUserDefinedDiscretizationNumber():void{
			DiscreteCircleFeature.discretization = 25;
			_instance.calculateGeometry();
			assertEquals("There should be as many points as user defined discretization value",
				25,
				((_instance.geometry as Polygon).componentByIndex(0) as MultiPoint).componentsLength
			);
		}
		
		[Test]
		public function shouldNotRecalculateGeometryByDefault():void{
			var expected:Geometry = _instance.geometry;
			_instance.draw();
			var result:Geometry = _instance.geometry;
			assertEquals("The geometry is relaculated at each redraw, it should not be the case",expected,result);
		}
		
		[Test]
		public function shouldRecalculateGeometryOnRedrawWhenRadiusHasChanged():void{
			var geom:Geometry = _instance.geometry;
			_instance.radius = _instance.radius * 0.90;
			_instance.draw();
			var result:Geometry = _instance.geometry;
			assertFalse("Changing radius value should cause geometry to be recalculated at next redraw", geom == result);
		}
		
		[Test]
		public function shouldRecalculateGeometryOnRedrawWhenCenterHasChanged():void{
			var geom:Geometry = _instance.geometry;
			_instance.center = new Location(_instance.x*0.90,_instance.y*0.90);
			_instance.draw();
			var result:Geometry = _instance.geometry;
			assertFalse("Changing center value should cause geometry to be recalculated at next redraw", geom == result);
		}
	}
}