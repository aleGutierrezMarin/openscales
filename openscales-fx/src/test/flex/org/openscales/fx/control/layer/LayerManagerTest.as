package org.openscales.fx.control.layer {
	
	import org.flexunit.asserts.*;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	
	public class LayerManagerTest {		
		
		private var _map:Map;
		private var _layer1:Layer;
		private var _layer2:Layer;
		private var _layer3:Layer;
		
		private var _layerManager:LayerManager;
		
		public function LayerManagerTest() {}
		
		[Before]
		public function setUp():void{
			
			// Given an empty map
			_map = new Map();
			
			// And that map has three layers
			_layer1 = new Layer("layer1");
			_map.addLayer(_layer1);
			_layer2 = new Layer("layer2");
			_map.addLayer(_layer2);
			_layer3 = new Layer("layer3");
			_map.addLayer(_layer3);
			
			// And given a LayerManager
			_layerManager = new LayerManager();
		}
		
		[After]
		public function cleanUp():void{
			
			_map.removeAllLayers();
			_map = null;
			
			_layerManager = null;
		}
		
		/**
		 * Validates that a LayerManager displays the layers of the map
		 */
		[Test]
		public function shouldDisplayTheLayersOfTheMap():void{
			
			// When the LayerManager is added to the map
			_map.addControl(_layerManager);
			
			// Then it displays the layers of the map, in reverse order			
			assertLayerManagerHasTheSameLayersAsTheMap();
		}
		
		/**
		 * Validates that when a layer is added in the map, 
		 * it is displayed in the LayerManager, at the same index
		 */
		[Test]
		public function shouldUpdateAfterALayerIsAdded():void{
			
			// Given the LayerManager is added to the map
			_map.addControl(_layerManager);
			
			// And a new layer
			var layer4:Layer = new Layer("layer4");			
			
			// When the layer is added to the map
			_map.addLayer(layer4);
			
			// Then the LayerManager displays the layers of the map, in reverse order			
			assertLayerManagerHasTheSameLayersAsTheMap();
		}
		
		/**
		 * Validates that the layer
		 */
		[Test]
		public function shouldUpdateAfterALayerIsRemoved():void{
			
			// Given the LayerManager is added to the map
			_map.addControl(_layerManager);
			
			// When a first layer is removed
			_map.removeLayer(_layer2);
			
			// Then the LayerManager displays the layers of the map, in reverse order			
			assertLayerManagerHasTheSameLayersAsTheMap();
		}
		
		/**
		 * Validates that layers are properly moved to the front
		 */
		[Test]
		public function shouldMoveLayerForward():void{
			
			// Given the LayerManager is added to the map
			_map.addControl(_layerManager);
			
			// When a layer is moved up
			_layerManager.moveForward(_layer2);
			
			// Then the layer position is updated in the Map
			assertEquals("Layer 2 in wrong position", 2, _map.layers.indexOf(_layer2));
			
			// And in the LayerManager
			assertLayerManagerHasTheSameLayersAsTheMap();
		} 
		
		/**
		 * Validates that layer are properly moved back
		 */
		[Test]
		public function shouldMoveLayerBack():void{
			
			// Given the LayerManager is added to the map
			_map.addControl(_layerManager);
			
			// When a layer is moved up
			_layerManager.moveBack(_layer2);
			
			// Then the layer position is updated in the Map
			assertEquals("Layer 2 in wrong position", 0, _map.layers.indexOf(_layer2));
			
			// And in the LayerManager
			assertLayerManagerHasTheSameLayersAsTheMap();
		}
		
		/**
		 * Validates that layers are moved up
		 * according to their position after filtering
		 * if a filter is applied to the layer list
		 */
		[Test]
		public function shouldMoveLayerForwardWhenFiltered():void{
			
			// Given the LayerManager is added to the map
			_map.addControl(_layerManager);
			
			// And a filter is applied to the layer list
			_layerManager.layers.filterFunction = filterLayers;
			_layerManager.layers.refresh();
			
			// When Layer 1 is moved forward
			_layerManager.moveForward(_layer1);
			
			// Then it has come on top of Layer 3
			assertEquals("Layer 1 in wrong position", 2, _map.layers.indexOf(_layer1));
		}
		
		
		/**
		 * Validates that layers are moved up
		 * according to their position after filtering
		 * if a filter is applied to the layer list
		 */
		[Test]
		public function shouldMoveLayerBackWhenFiltered():void{
			
			// Given the LayerManager is added to the map
			_map.addControl(_layerManager);
			
			// And a filter is applied to the layer list
			_layerManager.layers.filterFunction = filterLayers;
			_layerManager.layers.refresh();
			
			// When Layer 1 is moved forward
			_layerManager.moveBack(_layer1);
			
			// Then it has come on top of Layer 3
			assertEquals("Layer 1 in wrong position", 0, _map.layers.indexOf(_layer1));
		}
		
		/**
		 * Validates that layers can be moved at a specific index
		 */
		[Test]
		public function shouldMoveLayerAtGivenIndex():void{
			
			// Given the LayerManager is added to the map
			_map.addControl(_layerManager);
			
			// When Layer 1 is moved forward
			_layerManager.moveLayerAtIndex(_layer1,1);
			
			// Then it has come on top of Layer 3
			assertEquals("Layer 1 in wrong position", 1, _map.layers.indexOf(_layer1));			
		}
		
		
		protected function filterLayers(layer:Layer):Boolean{
			
			// Makes the list become layer1,layer3
			// instead of layer1,layer2,layer3 to make
			// reordering tests meaningfull
			return layer == _layer1 || layer == _layer3;
		}
		
		protected function assertLayerManagerHasTheSameLayersAsTheMap():void{
			
			var nbLayers:uint = _map.layers.length;
			for(var i:uint = 0; i<nbLayers; i++){
				
				var layer:Layer = _map.layers[i]
				assertEquals("Layer {"+layer.identifier+"} not in LayerManager",layer,_layerManager.layers.getItemAt(nbLayers-1-i));
			}
		}
	}
}