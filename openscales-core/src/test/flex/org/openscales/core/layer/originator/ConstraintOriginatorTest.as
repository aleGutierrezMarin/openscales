package org.openscales.core.layer.originator
{
	import org.flexunit.Assert;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.core.layer.Layer;

	public class ConstraintOriginatorTest
	{		
		[Test]
		public function testConstraintOriginatorInitialization():void {
			
			var bounds:Bounds = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,"");		
			
			var maxResolution:Number = Layer.DEFAULT_NOMINAL_RESOLUTION;
			var minResolution:Number = maxResolution/Layer.DEFAULT_NUM_ZOOM_LEVELS;
			var constraint:ConstraintOriginator = new ConstraintOriginator(bounds, minResolution, maxResolution);
			
			Assert.assertEquals(bounds, constraint.extent);
			Assert.assertEquals(minResolution, constraint.minResolution);
			Assert.assertEquals(maxResolution, constraint.maxResolution);
		}
	}
}