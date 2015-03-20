package org.openscales.core.layer.originator
{
	import org.flexunit.Assert;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Bounds;

	public class ConstraintOriginatorTest
	{		
		[Test]
		public function testConstraintOriginatorInitialization():void {
			
			var bounds:Bounds = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,"");		
			
			var maxResolution:Resolution = Layer.DEFAULT_NOMINAL_RESOLUTION;
			var minResolution:Resolution = new Resolution(maxResolution.value/Layer.DEFAULT_NUM_ZOOM_LEVELS
														,maxResolution.projection);
			var constraint:ConstraintOriginator = new ConstraintOriginator(bounds, minResolution, maxResolution);
			
			Assert.assertEquals(bounds, constraint.extent);
			Assert.assertEquals(minResolution, constraint.minResolution);
			Assert.assertEquals(maxResolution, constraint.maxResolution);
		}
	}
}