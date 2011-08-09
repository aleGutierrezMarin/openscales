package org.openscales.fx.control.layer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.ChangeLayerPosition;
	import org.openscales.fx.control.layer.LayerManager;
	
	public class ChangeLayerPositionTest extends OpenScalesTest
	{		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map = null;
		private var _layer1:Layer = null;
		private var _layer2:Layer = null;
		private var _layer3:Layer = null;
		private var _position:ChangeLayerPosition = null;
		
		public function ChangeLayerPositionTest() {}
		
		[Before]
		override public function setUp():void
		{
			super.setUp();
			
			_map = new Map();
			
			_layer1 = new Layer("layer 1");
			_layer2 = new Layer("layer 2");
			_layer3 = new Layer("layer 3");
			
			// add kayers to the current map
			_map.addLayer(_layer1);
			_map.addLayer(_layer2);
			_map.addLayer(_layer3);
			
			// change position control
			_position = new ChangeLayerPosition();
			_position.layer = _layer2;
			
			this._container.addElement(_position);
		}
		
		[After]
		override public function tearDown():void {
			super.tearDown();
			this._container.removeElement(_position);
			_position.layer = null;
			_position = null;
			_map.removeAllLayers();
			_map = null;
			_layer1.destroy();
			_layer1 = null;
			_layer2.destroy();
			_layer2 = null;
			_layer3.destroy();
			_layer3 = null;
		}
		
		/**
		 * Test if the index of the layer in the containerChild of map change when the layer is moveUp
		 */
		[Test]
		public function moveLayerUp():void
		{
			var current:uint = _map.layerContainer.getChildIndex(_layer2);
			_position.upLayer(new MouseEvent(MouseEvent.MOUSE_DOWN));			
			Assert.assertEquals(current+1, _map.layerContainer.getChildIndex(_layer2));
		}
		
		/**
		 * Test if the index of the layer in the containerChild of map change when the layer is moveDown
		 */
		[Test]
		public function moveLayerDown():void
		{
			var current:uint = _map.layerContainer.getChildIndex(_layer2);		
			_position.downLayer(new MouseEvent(MouseEvent.MOUSE_DOWN));	
			Assert.assertEquals(current-1, _map.layerContainer.getChildIndex(_layer2));
		}
	}
}