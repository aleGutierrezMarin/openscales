package org.openscales.map
{
	import flash.events.Event;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.Layer;
	
	public class LayerManagementTest
	{
		public function LayerManagementTest() {}
		
		/**
		 * Tests that when a layer is added to a map, it is listed in the layers of the map. 
		 */
		[Test(async)]
		public function shouldContainTheLayerAfterItIsAdded():void{
			
			// Given a map
			var map:Map = new Map();
			var initialLayersCount:uint = map.layers.length;
			
			// And a layer that is not on the map
			var layer:Layer = new Layer('SomeLayer');
			
			// Then an event is dispatched advertising a layer has been added
			map.addEventListener(LayerEvent.LAYER_ADDED,Async.asyncHandler(this,function(item:LayerEvent,obj:Object):void{
				
				assertEquals("Event not advertising correct layer",layer,item.layer);
			},2000,null,function(event:Event):void{
				
				fail("No event because a layer was added");
			}));
			
			// When the layer is added to the map
			map.addLayer(layer);
			
			// And this layer is in the map
			this.assertLayerIsInTheMap(map,layer);
		}
		
		/**
		 * Validates the addition of multiple layers through the <code>addLayers()</code> method
		 */
		[Test]
		public function shouldContainTheLayersAfterTheyAreAdded():void{
			
			// Given a map
			var map:Map = new Map();
			
			// And multiple layers not added to the map
			var layer1:Layer = new Layer("Layer 1");
			var layer2:Layer = new Layer("Layer 2");
			
			// When the layers are added to the map
			var layers:Vector.<Layer> = new Vector.<Layer>();
			layers.push(layer1);
			layers.push(layer2);
			map.addLayers(layers);
			
			// Then these layers are on the map
			this.assertLayerIsInTheMap(map, layer1);
			this.assertLayerIsInTheMap(map, layer2);
		}
		
		/**
		 * Tests that when a layer is removed from the map, it no longer appears in the layers of the map.
		 */
		[Test(async)]
		public function shouldNotContainLayerAfterItIsRemoved():void{
			
			// Given a map
			var map:Map = new Map();
			
			// And it has a layer in it
			var layer:Layer = new Layer('SomeLayer');
			map.addLayer(layer);
			var initialLayersCount:uint = map.layers.length;
			
			// Then an event is dispatched advertising a layer has been removed
			// Then an event is dispatched advertising a layer has been added
			map.addEventListener(LayerEvent.LAYER_REMOVED,Async.asyncHandler(this,function(item:LayerEvent,obj:Object):void{
				
				assertEquals("Event not advertising correct layer",layer,item.layer);
			},2000,null,function(event:Event):void{
				
				fail("No event because a layer was removed");
			}));
			
			// When the layer is removed
			map.removeLayer(layer);
			
			// Then the map has one less layer
			var layers:Vector.<Layer> = map.layers;
			assertEquals("Incorrect count of layers",initialLayersCount-1, layers.length);
			
			// And the layer no longer is in the map
			assertTrue("Layer is still in the map", layers.indexOf(layer) == -1);
		}
		
		// --- Utility methods --- //
		private function assertLayerIsInTheMap(map:Map, layer:Layer):void{
			
			assertTrue("Layer is not in the map", map.layers.indexOf(layer) != -1);			
		}
	}
}