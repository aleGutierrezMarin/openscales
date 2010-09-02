package org.openscales.core.layer
{
	import flexunit.framework.Assert;
	

	public class LayerTest
	{
		
		[Test]
		public function testDefaultResolutions():void {
			var layer:Layer = new Layer("test");
			
			Assert.assertEquals(Layer.DEFAULT_NUM_ZOOM_LEVELS, layer.resolutions.length);
			Assert.assertEquals(Layer.DEFAULT_NOMINAL_RESOLUTION, layer.resolutions[0]);
		}
		
		[Test]
		public function testResolutions():void {
			var layer:Layer = new Layer("test");
			layer.resolutions = [0, 1, 2 , 3 , 4, 5, 6, 7, 8, 9];
			
			Assert.assertEquals(10, layer.resolutions.length);
			
			// Test resolutions sorting
			Assert.assertEquals(9, layer.resolutions[0]);
			Assert.assertEquals(0, layer.resolutions[9]);
		}
		
		[Test]
		public function testGeneratedResolutions():void {
			var layer:Layer = new Layer("test");
			layer.generateResolutions(5, 2);
			
			Assert.assertEquals(5, layer.resolutions.length);
			
			// Test resolutions sorting
			Assert.assertEquals(2, layer.resolutions[0]);
			Assert.assertEquals(1, layer.resolutions[1]);
			Assert.assertEquals(0.5, layer.resolutions[2]);
			Assert.assertEquals(0.25, layer.resolutions[3]);
			Assert.assertEquals(0.125, layer.resolutions[4]);
		}
		
		
		
		
		
		
	}
}