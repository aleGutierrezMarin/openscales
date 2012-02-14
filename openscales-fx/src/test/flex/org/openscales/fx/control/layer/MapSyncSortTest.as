package org.openscales.fx.control.layer{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import org.flexunit.asserts.assertEquals;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	
	public class MapSyncSortTest{
		
		public function MapSyncSortTest(){}
		
		[Test]
		public function shouldSortLayersOppositeToMapOrder():void{
			
			// Given an ArrayCollection of 4 layers
			var layer1:Layer = new Layer('Layer 1');
			var layer2:Layer = new Layer('Layer 2');
			var layer3:Layer = new Layer('Layer 3');
			var layer4:Layer = new Layer('Layer 4');
			var collection:ArrayCollection = new ArrayCollection([layer2,layer4,layer3,layer1]);
			
			// And a Map with these layers in another order
			var map:Map = new Map();
			map.addLayers(new <Layer>[layer1,layer2,layer3,layer4]);
			
			// When a MapSyncSort is applied to the collection
			var sort:Sort = new MapSyncSort(map);
			collection.sort = sort;
			collection.refresh();
			
			// Then the layers are sorted in the opposite order of the map layers
			for(var i:int=0;i<map.layers.length;i++){
				
				assertEquals("Layer "+map.layers[i].identifier+" in wrong position",map.layers[i],collection.getItemAt(map.layers.length-1-i));
			}
			
		}
	}
}