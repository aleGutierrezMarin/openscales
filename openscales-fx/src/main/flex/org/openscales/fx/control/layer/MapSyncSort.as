package org.openscales.fx.control.layer{
	
	import mx.collections.Sort;
	
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	
	/**
	 * Sort to be used on a ListCollectionView containing layers to sort
	 * them in the opposite order to the order they appear on given map
	 */
	public class MapSyncSort extends Sort{
		
		private var _map:Map;
		
		public function MapSyncSort(map:Map){
			
			_map = map;
		}
		
		/**
		 * The map used as reference for the order
		 */
		public function get map():Map{
		
			return _map;
		}
		
		public function set map(value:Map):void{
			
			_map = value;
		}
		
		override public function findItem(items:Array, values:Object, mode:String, returnInsertionIndex:Boolean=false, compareFunction:Function=null):int{
			
			var nbItems:int = items.length;
			if(mode == Sort.LAST_INDEX_MODE){
				
				while(nbItems--){
					
					if(items[nbItems] == values){
						
						return nbItems;
					}
				}
				
				return -1
			}
			else{
				
				for(var i:uint = 0; i<nbItems; i++){
					
					if(items[i] == values){
						
						return i;
					}
				}
				
				return -1
			}			
		}
		
		override public function sort(items:Array):void{
			
			if(!_map || !items || items.length <= 1){
				return;				
			}
			
			var sortedItems:Array = [];
			
			for each(var layer:Layer in _map.layers){
				
				var index:int = items.indexOf(layer);
				if(index != -1){
					
					sortedItems.push(items[index]);
				}
			}
			
			sortedItems = sortedItems.reverse();
			
			for (var i:int; i< sortedItems.length; i++){
				
				items[i] = sortedItems[i];
			}
		}
	}
}