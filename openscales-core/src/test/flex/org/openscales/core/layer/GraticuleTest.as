package org.openscales.core.layer
{
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.openscales.core.Map;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.style.Style;
	
	use namespace os_internal;

	public class GraticuleTest
	{
		private var _instance:Graticule;
		private var _uiComponent:UIComponent;
		
		public function GraticuleTest() {}
		
		[Before(async,ui)]
		public function setUp():void{
			
			this._instance = new Graticule("graticule");
			
			this._uiComponent = new UIComponent();
			this._uiComponent.addChild(this._instance);
			
			Async.proceedOnEvent(this, this._uiComponent, FlexEvent.CREATION_COMPLETE);
			
			UIImpersonator.addChild(this._uiComponent);
		}
		
		[After]
		public function tearDown():void{
			try {
				UIImpersonator.removeChild(this._uiComponent);
				this._uiComponent.removeChild(this._instance);
			} catch(e:Error) {}
			this._uiComponent = null;
			this._instance = null;
		}
		
		[Test(async,ui)]
		public function shouldSetVisible():void{
			this._instance.visible=false;
			assertTrue("Setting visible does not work", !this._instance.visible);
		}
		
		[Test]
		public function shouldSetName():void{
			this._instance.name =  "myName";
			assertEquals("Name not set properly", "myName", this._instance.name);
		}
		
		[Test]
		public function shouldDisplayInLayerManager():void{
			this._instance.displayInLayerManager =  false;
			assertEquals("displayInLayerManager not set properly", false, this._instance.displayInLayerManager);
			this._instance.displayInLayerManager =  true;
			assertEquals("displayInLayerManager not set properly", true, this._instance.displayInLayerManager);
		}
		
		[Test]
		public function shouldSetAlpha():void{
			this._instance.alpha =  0.5;
			assertEquals("Alpha not set properly", 0.5, this._instance.alpha);
		}
		
		[Test]
		public function shouldSetMinNumberOfLines():void{
			this._instance.minNumberOfLines =  50;
			assertEquals("MinNumberOfLines not set properly", 50, this._instance.minNumberOfLines);
		}
		
		[Test]
		public function shouldSetIntervals():void{
			this._instance.intervals =  new Array(5.0,4.0);
			assertEquals("Intervals not set properly", 5.0, this._instance.intervals[0]);
			assertEquals("Intervals not set properly", 4.0, this._instance.intervals[1]);
			assertEquals("Intervals not set properly", 2, this._instance.intervals.length);
		}
		
		[Test]
		public function shouldSetStyle():void{
			var style:Style = new Style();
			this._instance.style = style; 
			assertEquals("Style not set properly", style, this._instance.style);
		}
		
		[Test]
		public function shouldAddToMapWhenMapIsSetAndVisibleIsTrue():void{
			//given a map and visible set to true
			var map:Map = new Map();
			this._instance.visible = true;
			
			// When setting map
			this._instance.map = map;
			
			// graticule should be added to map
			assertTrue("Map does not contain graticule", map.layers.indexOf(this._instance));
			
		}
		
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
			Assert.assertEquals("testFirstCoordinateForGraticule 1", 70, firstCoordinate); 
			firstCoordinate = graticule.getFirstCoordinateForGraticule(71, 10);
			Assert.assertEquals("testFirstCoordinateForGraticule 2", 80, firstCoordinate);
			firstCoordinate = graticule.getFirstCoordinateForGraticule(69.7, 0.2);
			Assert.assertTrue("testFirstCoordinateForGraticule 3", firstCoordinate <= 69.8000001 && firstCoordinate >= 69.7999999);
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