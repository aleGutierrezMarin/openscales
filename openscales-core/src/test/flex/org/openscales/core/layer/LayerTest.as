package org.openscales.core.layer
{
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;

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
		
		[Test]
		public function shouldTellIfLayerHasMultiBBoxes():void{
			var layer:Layer = new Layer("test");
			assertFalse("Null constraints should tell no multi bboxes", layer.hasMultiBBoxes());
			var csts:Vector.<Constraint> = new Vector.<Constraint>();
			layer.constraints = csts;
			assertFalse("Empty constraints should tell no multi bboxes", layer.hasMultiBBoxes());
			csts.push(new Constraint(null,null));
			layer.constraints = csts;
			assertFalse("Constraints with no MultiBoundingBoxConstraint should tell no multi bboxes", layer.hasMultiBBoxes());
			csts = new Vector.<Constraint>();
			csts.push(new MultiBoundingBoxConstraint(null,null,null));
			layer.constraints = csts;
			assertTrue("Constraints with at least one MultiBoundingBoxConstraint should tell yes", layer.hasMultiBBoxes());
		}
		
		[Test]
		public function shouldTellAvailableOrNotForMultiBBoxLayer():void{
			var map:Map = new Map(600,400,"WGS84");
			var layer:Layer = new Layer("test");
			
			var csts:Vector.<Constraint> = new Vector.<Constraint>();
			var bboxes:Vector.<Bounds> = new Vector.<Bounds>();
			bboxes.push(new Bounds(-6.0, 55.0, 39.0, 71.0, "WGS84")); // Norway bbox
			bboxes.push(new Bounds(-8.38, 38.14, 14.11, 55.92, "WGS84")); // Metropolitan France bbox
			csts.push(new MultiBoundingBoxConstraint(
					new Resolution(Unit.getResolutionFromScaleDenominator(200,Unit.DEGREE), "WGS84"),
					new Resolution(Unit.getResolutionFromScaleDenominator(18316743,Unit.DEGREE), "WGS84"), 
					bboxes));
			layer.constraints = csts;
			map.resolution = new Resolution(Unit.getResolutionFromScaleDenominator(30000, Unit.DEGREE), "WGS84");
			map.center = new Location(5,45,"WGS84");
			map.addLayer(layer);
			assertTrue("Layer should be available when map is contained in at least one bbox",layer.available);
			
			map.zoomToExtent(new Bounds(-65,42,-48,54,"WGS84"));
			
			assertTrue("Layer should not be available when map is outside every bbox", !layer.available);
			
			map.zoomToExtent(new Bounds(18,67,35,73,"WGS84"));
				
			assertTrue("Layer should be available when map intersect at least one bbox", layer.available);	
			
			map.zoomToExtent(new Bounds(-25,32,54,70,"WGS84"));
			
			assertTrue("Layer should not be available when map is out of all constraints resolution range", !layer.available);
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
		
		[Test]
		public function shouldNotAddNullSRSInAvailableProjWhileUsingAVector():void{
			var availableProj:Vector.<String> = new Vector.<String>();
			availableProj.push("ESPG:4326");
			availableProj.push(null);
			var l:Layer=new Layer("test");
			l.availableProjections = availableProj;
			
			assertEquals("Should contain one projection",1, l.availableProjections.length);
			assertEquals("Should contain one projection","ESPG:4326", l.availableProjections[0]);
			
		}
	}
}