package org.openscales.fx.control.layer
{
	
	import flash.events.Event;
	
	import mx.events.SliderEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.ChangeLayerOpacity;
	import org.openscales.fx.control.layer.LayerManager;
	
	public class ChangeLayerOpacityTest extends OpenScalesTest
	{	
		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map = null;
		private var _layer1:Layer = null;
		private var _opacity:ChangeLayerOpacity = null;
		
		[Before]
		override public function setUp():void
		{
			super.setUp();
			
			_map = new Map();
			_layer1 = new Layer("layer");
			
			_map.addLayer(_layer1);
			
			_opacity = new ChangeLayerOpacity();
			_opacity.layer = _layer1;
			
			this._container.addElement(_opacity);
		}
		
		[Test]
		public function testSliderOpacityChange():void
		{
			_opacity.layerControlOpacity.value = 50;
			
			Assert.assertEquals(_opacity.layerControlOpacity.value, (_layer1.alpha*100));
		}
		
		
		[Test]
		public function testLayerOpacityChange():void
		{
			_layer1.alpha = 0.5;
			
			Assert.assertEquals((_layer1.alpha*100), _opacity.layerControlOpacity.value);
		}
	}
}