package org.openscales.fx.control.layer
{
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.LayerManager;
	
	public class LayerManagerTest extends OpenScalesTest
	{		
		private var _map:Map;
		private var _layer1:Layer;
		private var _layer2:Layer;
		private var _layer3:Layer;
		
		private var _layerManager:LayerManager;
		
		public function LayerMetadatasTest() {}
		
		[Before]
		override public function setUp():void
		{
			super.setUp();
			
			_map = new Map();
			
			_layer1 = new Layer("layer1");
			_layer2 = new Layer("layer2");
			_layer3 = new Layer("layer3");
			
			_map.addLayer(_layer1);
			_map.addLayer(_layer2);
			_map.addLayer(_layer3);
			
			_layerManager = new LayerManager();
			_map.addControl(_layerManager);
			
			this._container.addElement(_layerManager);
		}
		
		/**
		 * When a LayerSwicther is added to a map this control
		 * synchronise and add item in the LayerSwitcher list corresponding to the current layer in the map
		 */
		[Test]
		public function layerSwitcherInitializeTest():void
		{
			var layerManager:LayerManager = new LayerManager();

			_map.addControl(layerManager);
			this._container.addElement(layerManager);
			
			var size:Number = layerManager.dataProvider.length;
			
			Assert.assertEquals(_map.layers.length, size);
			
			var findLayer1:Boolean = false;
			var findLayer2:Boolean = false;
			var findLayer3:Boolean = false;
			
			var i:uint = 0;
			
			for(; i<size; ++i)
			{
				var elt:Layer = (layerManager.layerList.dataProvider[i] as Layer);
				if(elt.name == _layer1.name)
					findLayer1 = true;
				
				if(elt.name == _layer2.name)
					findLayer2 = true;
				
				if(elt.name == _layer3.name)
					findLayer3 = true;
			}
			
			Assert.assertTrue(findLayer1);
			Assert.assertTrue(findLayer2);
			Assert.assertTrue(findLayer3);
		}
		
		/**
		 * Test if a layer is added to the LayerSwitcherComponent when a layer is added on the map
		 */
		[Test]
		public function layerAddedTest():void
		{
			var size:int = _layerManager.layerList.dataProvider.length;
			var layer4:Layer = new Layer("layer4");
			
			_map.addLayer(layer4);
			
			// one layer more in the layerSwitcher
			Assert.assertEquals(size+1, _layerManager.layerList.dataProvider.length);
			
			var findLayer4:Boolean = false;
			
			var i:uint = 0;
			
			for(; i<size; ++i)
			{
				var elt:Layer = (_layerManager.layerList.dataProvider[i] as Layer);
				
				if(elt.name == layer4.name)
					findLayer4 = true;
			}
			
			// layer "layer4" added on the LayerSwitcher list
			Assert.assertTrue(findLayer4);
		}
		
		/**
		 * Test if the layer is removed from the LayerSwitcher when it is removed from the map
		 */
		[Test]
		public function layerRemovedTest():void
		{
			var size:int = _layerManager.layerList.dataProvider.length;
			
			_map.removeLayer(_layer2);
			size-=1;
			
			// layer removed from LayerSwitcher list
			Assert.assertEquals(size, _layerManager.layerList.dataProvider.length);
			
			
			var findLayer4:Boolean = false;
			
			var i:uint = 0;
			
			for(; i<size; ++i)
			{
				var elt:Layer = (_layerManager.layerList.dataProvider[i] as Layer);
				
				if(elt.name == _layer2.name)
					findLayer4 = true;
			}
			
			// Not find int he LayerSwitcher list
			Assert.assertFalse(findLayer4);
		}
		
		/**
		 * Test the setting of a rendererOptions object in the LayerManager
		 */
	}
}