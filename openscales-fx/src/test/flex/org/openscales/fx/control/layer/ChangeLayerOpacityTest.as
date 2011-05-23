package org.openscales.fx.control.layer
{
	
	import flash.events.Event;
	
	import mx.events.SliderEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.Map;
	import org.openscales.fx.control.layer.ChangeLayerOpacity;
	import org.openscales.fx.control.layer.LayerManager;
	
	public class ChangeLayerOpacityTest
	{	
		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map = null;
		private var _layer1:Layer = null;
		private var _opacity:ChangeLayerOpacity = null;
		
		[Before]
		public function setUp():void
		{
			_map = new Map();
			_layer1 = new Layer("layer");
			_opacity = new ChangeLayerOpacity();
			_opacity.layer = _layer1;
		}
		
		[Test]
		public function testOpacityChange():void
		{
			var opacityValue:Number = 0.5;
			
			_opacity.layerControlOpacity.value = opacityValue;
			
			Assert.assertEquals(opacityValue, _layer1.alpha);
			
		}
	}
}