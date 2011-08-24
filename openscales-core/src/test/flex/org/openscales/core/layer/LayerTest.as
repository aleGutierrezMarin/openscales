package org.openscales.core.layer
{
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.openscales.core.Map;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.geometry.basetypes.Pixel;

	public class LayerTest
	{
		
		[Test]
		public function testDefaultResolutions():void {
			var layer:Layer = new Layer("test");
			
			Assert.assertEquals(Layer.DEFAULT_NUM_ZOOM_LEVELS, layer.resolutions.length);
			Assert.assertEquals(Layer.DEFAULT_NOMINAL_RESOLUTION.value, layer.resolutions[0]);
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
		
		[Test]
		public function testMinZoomLevel():void {
			var layer:Layer = new Layer("test");
			layer.resolutions = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
			layer.minZoomLevel = 2;
			
			Assert.assertEquals(layer.minZoomLevel, 2);
			Assert.assertEquals(layer.minResolution, 0);
			Assert.assertEquals(layer.maxResolution, 7);
		}
		
		[Test]
		public function testMaxZoomLevel():void {
			var layer:Layer = new Layer("test");
			layer.resolutions = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
			layer.maxZoomLevel = 8;
			
			Assert.assertEquals(layer.maxZoomLevel, 8);
			Assert.assertEquals(layer.minResolution, 1);
			Assert.assertEquals(layer.maxResolution, 9);
		}
		
		[Test]
		public function testInvalidMaxZoomLevel():void {
			var layer:Layer = new Layer("test");
			layer.resolutions = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
			
			// Define valid maxZoomLevel
			layer.maxZoomLevel = 5;
			// Now invalid one
			layer.maxZoomLevel = 11;
						
			Assert.assertEquals(layer.maxZoomLevel, 5);
		}
		
		[Test]
		public function testInvalidMinZoomLevel():void {
			var layer:Layer = new Layer("test");
			layer.resolutions = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
			
			// Define valid maxZoomLevel
			layer.minZoomLevel = 5;
			// Now invalid one
			layer.minZoomLevel = -1;
			
			Assert.assertEquals(layer.minZoomLevel, 5);
		}
		
		[Test]
		public function testOriginators():void 
		{
			var layer:Layer = new Layer("test");
			
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			
			var dataOriginators:Vector.<DataOriginator> = new Vector.<DataOriginator>();
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			
			dataOriginators.push(originator);
			
			// set originators
			layer.originators = dataOriginators;
			
			Assert.assertEquals(originator, layer.originators[0]);
			
			// add Originator
			var originator2:DataOriginator = new DataOriginator("originator2", url, urlPicture);
			layer.addOriginator(originator2);
			
			Assert.assertEquals(originator2, layer.originators[1]);
			
		}
		
		
		/**
		 * Validates that the layer alpha is correctly set
		 */
		[Test]
		public function shouldSetAlpha():void
		{
			// Given a Layer and a number value
			var layer:Layer = new Layer("layer");
			var alpha:Number = 0.43;
			
			// When the alpha is set
			layer.alpha = alpha;
			
			var epsilon:Number = 0.01;
			
			// Then the opacity parameter is set to the given value
			Assert.assertTrue("Incorrect opacity value", Math.abs(alpha-layer.alpha) < epsilon);
		}
		
		/**
		 * Validates that the layer alpha minimum value is 0 even if a lower value is given
		 */
		[Test]
		public function shouldSetMinimumAlpha():void
		{
			// Given a Layer and a number value under 0
			var layer:Layer = new Layer("layer");
			var alpha:Number = -5;
			
			// When the opacity is set
			layer.alpha = alpha;
			
			// Then the alpha parameter should be the minimum value : 0
			Assert.assertEquals("Incorrect opacity value", 0, layer.alpha);
		}
		
		/**
		 * Validates that the layer opacity maximum value is 1 even if a higher value is given
		 */
		[Test]
		public function shouldSetMaximumAlpha():void
		{
			// Given a Layer and a number value higher than 1
			var layer:Layer = new Layer("layer");
			var alpha:Number = 5;
			
			// When the opacity is set
			layer.alpha = alpha;
			
			// Then the opacity parameter should be the maximum value : 1
			Assert.assertEquals("Incorrect opacity value", 1, layer.alpha);
		}
		
		/**
		 * Validates that the displayInLayerManager param is correctly set
		 */
		[Test]
		public function shouldSetDisplayInLayerManager():void
		{
			// Given a layer
			var layer:Layer = new Layer("Layer");
			
			// the default value should be true
			Assert.assertTrue("Incorect displayInLayerManager default value ", layer.displayInLayerManager);
			
			// When the displayInLayerManager value is changed to false
			layer.displayInLayerManager = false;
			
			// Then the displayInLayerManager value should be false
			Assert.assertFalse("Incorect displayInLayerManager value ", layer.displayInLayerManager);
			
		}
		
		/**
		 * Validates that when you ask to convert a mapPixel into a layer pixel it simply add
		 * the origin offset of the layer to the map Pixel.
		 */
		[Test]
		public function shouldReturnLayerPixelAsMapPixelWithOriginOffset():void
		{
			// Given a map, and a layer with an offset
			var _map:Map = new Map();
			var _layer:Layer = new Layer("testLayer");
			_map.addLayer(_layer);
			_layer.x = -100;
			_layer.y = -50;
			
			// When I ask for a map pixel into a layer pixel
			var _returnedPixel:Pixel = _layer.getLayerPxFromMapPx(new Pixel(300, 200));
				
			// Then the returned pixel is properly computed
			assertEquals("The getLayerPxFromMapPx return a wrong value for the X coordinate of the layer pixel", 400, _returnedPixel.x); 
			assertEquals("The getLayerPxFromMapPx return a wrong value for the Y coordinate of the layer pixel", 250, _returnedPixel.y); 
		}
	}
}