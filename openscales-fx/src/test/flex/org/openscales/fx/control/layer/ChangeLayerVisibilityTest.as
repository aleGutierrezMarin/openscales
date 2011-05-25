package org.openscales.fx.control.layer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.SliderEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.ChangeLayerVisibility;
	import org.openscales.fx.control.layer.LayerManager;
	
	public class ChangeLayerVisibilityTest
	{		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map = null;
		private var _layer1:Layer = null;
		private var _visibility:ChangeLayerVisibility = null;
		
		[Before]
		public function setUp():void
		{
			_map = new Map();
			_layer1 = new Layer("layer");
		
			_map.addLayer(_layer1);
			
			_visibility = new ChangeLayerVisibility();
			_visibility.layer = _layer1;
		}
		
		/**
		 * Test if the layer visibility is set to false when the checkbox is unchecked
		 */
		[Test]
		public function hideLayerTest():void
		{
			_layer1.visible = true;
			_visibility.layerVisible(new MouseEvent(MouseEvent.CLICK));
			
			Assert.assertFalse(_layer1.visible);
		}
		
		/**
		 * Test if the layer visibility is set to true when the checkbox is checked
		 */
		[Test]
		public function showLayerTest():void
		{
			_layer1.visible = false;
			_visibility.layerVisible(new MouseEvent(MouseEvent.CLICK));
			
			Assert.assertTrue(_layer1.visible);
		}
		
		/**
		 * Test if the checkbox is unchecked when a layer is not visible
		 */
		[Test]
		public function hiddenLayerEvent():void
		{
			_layer1.visible = false;
			
			Assert.assertFalse(_visibility.layerSwitcherCheckBox.selected);
		}
		
		/**
		 * Test if the checkbox is checked when a layer is visible
		 */
		[Test]
		public function showLayerEvent():void
		{
			_layer1.visible = true;
			
			Assert.assertTrue(_visibility.layerSwitcherCheckBox.selected);
		}
	}
}