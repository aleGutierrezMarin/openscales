package org.openscales.fx.control.layer
{
	
	import flash.events.Event;
	
	import mx.events.SliderEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.ChangeLayerAlpha;
	import org.openscales.fx.control.layer.LayerManager;
	
	public class ChangeLayerOpacityTest extends OpenScalesTest
	{	
		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map;
		private var _layer1:Layer;
		private var _opacity:ChangeLayerAlpha;
		
		public function ChangeLayerOpacityTest() {}
		
		[Before(ui)]
		override public function setUp():void
		{
			super.setUp();
			
			this._map = new Map();
			this._layer1 = new Layer("layer");
			
			this._map.addLayer(this._layer1);
			
			this._opacity = new ChangeLayerAlpha();
			this._opacity.layer = this._layer1;
			
			this._container.addElement(this._opacity);
		}
		
		[After]
		override public function tearDown():void
		{
			super.tearDown();
			if(this._opacity) {
				this._container.removeElement(this._opacity);
				this._opacity.layer = null;
				this._opacity = null;
			}
			
			if(this._map) {
				this._map.removeAllLayers();
				this._map = null;
			}
			
			if(this._layer1) {
				this._layer1.destroy();
				this._layer1 = null;
			}
		}
		
		[Test(ui)]
		public function testSliderOpacityChange():void
		{
			this._opacity.layerControlOpacity.value = 50;
			this._opacity.layerOpacity(new Event(Event.CHANGE));
			Assert.assertEquals(this._opacity.layerControlOpacity.value, (this._layer1.alpha*100));
		}
		
		
		[Test(ui)]
		public function testLayerOpacityChange():void
		{
			this._layer1.alpha = 0.5;
			
			Assert.assertEquals((this._layer1.alpha*100), this._opacity.layerControlOpacity.value);
		}
	}
}