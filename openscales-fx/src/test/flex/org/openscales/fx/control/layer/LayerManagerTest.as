package org.openscales.fx.control.layer {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.FxMap;
	
	public class LayerManagerTest {		
		
		private var _map:Map;
		private var _layer1:Layer;
		private var _layer2:Layer;
		private var _layer3:Layer;
		
		private var _layerManager:LayerManager;
		
		private var _timer:Timer;
		private const THICK_TIME:uint = 800;
		private var _handler:Function = null;
		
		public function LayerManagerTest() {}
		
		[Before]
		override public function setUp():void{

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
			
			_timer = new Timer(THICK_TIME, 1);
		}
		
		[After]
		override public function tearDown():void{
			super.tearDown();
			if(this._handler!=null)
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this._handler);
			_timer.stop();
			_timer=null;
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
		 * Validates that the layerManager display is synchronised with the layer idsplayInLayerManager value
		 */
		[Test(async)]
		public function shouldSynchroniseWithDisplayInLayerManagerValues():void
		{
			// Given a fxmap with several layer (with displayInLayerManager property set to true or false)
			// and a LayerManager control 

			// When the layerManager is init :	
			this._handler = Async.asyncHandler(this,assertSynchroniseWithDisplayInLayerManagerValues,1500,null, timeOut);
			this._timer.addEventListener(TimerEvent.TIMER_COMPLETE, this._handler, false, 0, true );
			
			this._timer.start();
			
		}
		
		private function assertSynchroniseWithDisplayInLayerManagerValues(event:TimerEvent, obj:Object):void
		{
			// Then the layerManager onshould have all layers
			Assert.assertEquals("Incorrect number of layer in LayerManager", this._map.layers.length, this._layerManager.dataProvider.length);
			
			var i:int;
			var j:int = this._map.layers.length-1;
			
			for(i=0; i<=j; ++i)
			{
				Assert.assertEquals("Incorrect layer in LayerManager",this._map.layers[j-i].name, (this._layerManager.dataProvider[i] as Layer).name);
			}
		}
		
		/**
		 * Validates that the layerManager display updated when a layer has its displayInLayerManager property changed
		[Test(async)]
		public function shouldUpdateWhenADisplayInLayerManagerValueChange():void
		{
			// given a map with layers and layerManager control
			
			// when the layer displayInLayerManager properties are changed :
			this._layer1.displayInLayerManager = false;
			this._layer2.displayInLayerManager = true;
			this._layer3.displayInLayerManager = false;
			
			this._handler = Async.asyncHandler(this,assertUpdateWhenADisplayInLayerManagerValueChange,1500,null, timeOut);
			this._timer.addEventListener(TimerEvent.TIMER_COMPLETE, this._handler, false, 0, true );
			
			this._timer.start();
		}
		
		private function assertUpdateWhenADisplayInLayerManagerValueChange(event:TimerEvent, obk:Object):void
		{
			// Then the layerManager only display the layer with the true value (layer 2)
			Assert.assertEquals("Incorrect number of layer in LayerManager", 1, this._layerManager.dataProvider.length);
			
			Assert.assertEquals("Incorrect layer in LayerManager",this._layer2.name, (this._layerManager.dataProvider[0] as Layer).name);
			
		}
		
		private function timeOut():void
		{
			fail("Timer out");
		}
	}
}