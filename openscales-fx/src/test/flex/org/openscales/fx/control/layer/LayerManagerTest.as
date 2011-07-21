package org.openscales.fx.control.layer
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.FxMap;
	import org.openscales.fx.control.layer.LayerManager;
	
	public class LayerManagerTest extends OpenScalesTest
	{		
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
		 */
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