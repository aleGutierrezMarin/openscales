package org.openscales.core.control
{
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.events.OriginatorEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	
	
	/**
	 * Instances of DataOriginators are used to keep the different originator informations (logo / copyright)
	 * for all the layer of a map.
	 * This orignators are keep on a list which is updated when layers are changed (add / remove / visibility change...)
	 * This list is updated when the extent and the resolution of the map is changed
	 * This list is also updated when an originator is add or change on the layer.
	 * This list contains originators with no double.
	 * 
	 * This DataOriginators class represents a list of originators to be stored on a DataOriginatorsDisplay component.
	 * 
	 * @author ajard
	 */ 
	
	public class DataOriginators extends Control
	{
		/**
		 * @private
		 * @default null
		 * The list of current originators to display on the map.
		 * This list is linked to the Hashmap with the name of the originator.
		 */
		private var _originators:Vector.<DataOriginator> = null;
		
		/**
		 * @private
		 * @default null
		 * Number of layers refering to a same originator.
		 * A hashMap is used for keeping the number of layer linked to the same Originator.
		 * The number of layer is linked to the uid of the originators in the LinkedList of LinkedListBitmapNode
		 */
		private var _originatorsLayersCount:HashMap = null;
		
		/**
		 * Constructor of the class DataOriginators.
		 * 
		 * The current layers on the map are use to create the fisrt list of originators
		 * This first list of originator is made by calling generateLinkedList.
		 * @param position Indicates the position of this component in the current stage
		 */ 
		public function DataOriginators(position:Pixel = null)
		{
			super(position);
			
			_originators = new Vector.<DataOriginator>();
			_originatorsLayersCount = new HashMap();
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Remove the DataOriginators from the map and remove reference on object.
		 */
		override public function destroy():void 
		{
			super.destroy();
			
			this._originators = null;
			this._originatorsLayersCount = null;
			
			// remove listener
			this._map.removeEventListener(LayerEvent.LAYER_ADDED, this.onLayerChanged);
			this._map.removeEventListener(LayerEvent.LAYER_REMOVED, this.onLayerChanged);
			this._map.removeEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, this.onLayerChanged);
			this._map.removeEventListener(LayerEvent.LAYER_CHANGED_ORIGINATORS, this.onOriginatorListChange);
			this._map.removeEventListener(MapEvent.CENTER_CHANGED, this.onMapChanged);
			this._map.removeEventListener(MapEvent.RESOLUTION_CHANGED, this.onMapChanged);
			this._map.removeEventListener(MapEvent.PROJECTION_CHANGED, this.onMapChanged);
		}
		
		
		/**
		 * Add an originator in the list
		 * If the originator exist : increment its layers count
		 * Else add The originator in the list and set the layers count to 1
		 * 
		 * @param originator The DataOriginator to add in the list
		 */
		public function addOriginator(originator:DataOriginator):void
		{
			// Is the input originator valid ?
			if (!originator) 
			{
				Trace.debug("DataOriginators: null originator not added");
				return;
			}
			
			// check if the originator already exist
			var i:uint = this._originators.length;
			var found:Boolean = false;
			while (i>0 && !found) {
				if (originator.equals(this._originators[i-1])) 
				{			
					// increment the number of layer pointing at this originator
					var count:Number = this._originatorsLayersCount.getValue(originator.key);
					this._originatorsLayersCount.put(originator.key, ++count);
					found = true;
					break; // ending the search
				}
				--i;
			}
			
			// if not found during the for : new originator
			if( !found )
			{
				this._originators.push(originator);
				this._originatorsLayersCount.put(originator.key, 1);
				
				// Event Originator_added
				this.dispatchEvent(new OriginatorEvent(OriginatorEvent.ORIGINATOR_ADDED, originator));
			}
		}
		
		/**
		 * Add all originators of one layer
		 * If the originator exist : increment its layers count
		 * Else add The originator in the list and set the layers count to 1
		 * 
		 * @param layer The layer which contains a list of originators to add.
		 */
		public function addOriginators(layer:Layer):void
		{
			// if the layer is displayed :
			if(layer.displayed)
			{
				var i:uint = 0;
				var j:uint = layer.originators.length;
				var originator:DataOriginator = null;
				// if originator cover the current area :
				var mapExtent:Bounds = this._map.extent;
				
				// for each originators of this layer :
				for (; i<j; ++i) 
				{
					originator = layer.originators[i];
					// if no contraint : display
					if(originator.constraints.length == 0)
						addOriginator(originator);
					// else check if the current extent fit with  the originator constraint
					else if(mapExtent &&  originator.isCoveredArea(mapExtent, this._map.resolution))
						addOriginator(originator);
				}
			}
		}
		
		/**
		 * Remove an originator in the list
		 * If the originator layers count is > 1, decrement it
		 * Else remove the originator from the list 
		 * 
		 * @param originator The DataOriginator to remove from the list
		 */
		public function removeOriginator(originator:DataOriginator):void
		{
			// get the originator to remove
			var i:int = this._originators.indexOf(originator);
			
			if(i!=-1) 
			{
				var count:Number = this._originatorsLayersCount.getValue(originator.key);
				
				// if not yet setted to 0
				if(count > 0)
				{
					// decrement the layers counter
					this._originatorsLayersCount.put(originator.key, --count);
				}
				
				// if it was the last link to the originator, delete it
				if(count == 0)
				{
					// remove form the list
					this._originators.splice(i,1);
					
					// remove form the hasmap
					this._originatorsLayersCount.remove(originator.key);
					
					// Event Originator_removed
					this.dispatchEvent(new OriginatorEvent(OriginatorEvent.ORIGINATOR_REMOVED, originator, i));
				}
			}
			else
			{
				Trace.debug("DataOriginators.removeOriginator : originator not in the list, can't be removed");
			}
		}
		
		/**
		 * Remove all originators of a given layer.
		 * If the originator layers count is > 1, decrement it
		 * Else remove the originator from the list 
		 * 
		 * @param layer The layer which contains the originators list to remove.
		 */
		public function removeOriginators(layer:Layer):void
		{
			var i:uint = 0;
			var j:uint = layer.originators.length;
			
			// for each originators of this layer :
			for (; i<j; ++i) 
			{
				removeOriginator(layer.originators[i]);
			}	
		}
		
		/**
		 * Remove all the originators.
		 */
		public function removeAll():void
		{
			// remove all originators
			while(this._originators.length > 0)
			{
				this._originators.pop();
			}
			
			// remove all counter
			this._originatorsLayersCount.clear();
			
		}
		
		/**
		 * Generate the list of originators using the current layers in the map.
		 * Also store the number of layers which refer to a same originator
		 */ 
		public function generateOriginators():void
		{
			var layers:Vector.<Layer> = this._map.layers;
			var i:uint = 0;
			var j:uint = layers.length;
			
			// for each layer
			for (; i<j; ++i) 
			{
				// for each originator of a layer
				var n:uint = 0;
				var m:uint = layers[i].originators.length;
				
				for (; n<m; ++n) 
				{
					addOriginators(layers[i]);
				}
			}
		}
		
		/**
		 * Update the current list of originators according to the current layers in the map.
		 * Reset the layers counters to zero.
		 * Remove originator if no layer refer to it anymore.
		 * Add an originator if a layer refer to one which is not in the list.
		 or increment the number of layers for the existing originator.
		 */
		public function updateOriginators():void
		{
			this.removeAll();
			
			var layers:Vector.<Layer> = this._map.layers;
			var i:uint = 0;
			var j:uint = layers.length;
			
			// for each layer in the current map
			for (; i<j; ++i) 
			{
				addOriginators(layers[i]);
			}
			
		}	
		
		// Events
		/**
		 * Call when a layerEvent occur
		 * Three LayerEvent are handled :
		 * LAYER_ADDED
		 * LAYER_REMOVED
		 * LAYER_VISIBLE_CHANGED
		 * 
		 * After this events originators have to be updated
		 * 
		 * @param event The event received.
		 */
		public function onLayerChanged(event:LayerEvent):void
		{
			// a new layer has been added
			if (event.type == LayerEvent.LAYER_ADDED) 
			{		
				// add its originators
				addOriginators(event.layer);
			}
			
			// a layer has been removed
			if (event.type == LayerEvent.LAYER_REMOVED) 
			{
				// remove all its originators
				removeOriginators(event.layer);
			}
			
			// a layer has his visibility changed
			if (event.type == LayerEvent.LAYER_VISIBLE_CHANGED) 
			{
				// if layer become visible, add its originators :
				if(event.layer.visible)
				{
					// add its originators
					addOriginators(event.layer);
				}
				else // become unvisible : remove originators
				{
					// remove all its originators
					removeOriginators(event.layer);
				}
			}
		}
		
		/**
		 * Call when a MapEvent occur
		 * MapEvent handled :
		 * MOVE_END
		 * 
		 * After this events originators have to be updated.
		 * 
		 * @param event The event received.
		 */
		public function onMapChanged(event:MapEvent):void
		{
			// pan or zoom : update list in order to check if originitor constraint still valide
			updateOriginators();
		}	
		
		/**
		 * Call when an LayerEvent.LAYER_CHANGED_ORIGINATORS occur (when the originators list of a layer changed)
		 * LayerEvent handled : LAYER_CHANGED_ORIGINATORS
		 * 
		 * After this events originators have to be updated.
		 * 
		 * @param event The event received.
		 */
		public function onOriginatorListChange(event:LayerEvent):void
		{
			// update the current list in DataOriginators control
			updateOriginators();
		}
		
		/**
		 * Find an originator in the originators list by its key.
		 * 
		 * @param The key of the searched originator.
		 * @return The DataOriginator corresponding to the given name if find
		 * else return null
		 */
		public function findOriginatorByKey(key:String):DataOriginator
		{
			var i:uint = 0;
			var j:uint = originators.length;
			
			// for each originator in the list
			for (; i<j; ++i) 
			{
				if( originators[i].key == key )
				{
					return originators[i];
				}
			}			
			return null;
		}
		
		// getters / setters
		/**
		 * Set the map linked to this DataOriginators control
		 * @param map The current map linked to this component.
		 */
		override public function set map(map:Map):void 
		{
			if(this._map!=null)
			{
				// remove actual listener
				this._map.removeEventListener(LayerEvent.LAYER_ADDED, this.onLayerChanged);
				this._map.removeEventListener(LayerEvent.LAYER_REMOVED, this.onLayerChanged);
				this._map.removeEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, this.onLayerChanged);
				this._map.removeEventListener(LayerEvent.LAYER_CHANGED_ORIGINATORS, this.onOriginatorListChange);
				this._map.removeEventListener(MapEvent.CENTER_CHANGED, this.onMapChanged);
				this._map.removeEventListener(MapEvent.RESOLUTION_CHANGED, this.onMapChanged);
				this._map.removeEventListener(MapEvent.PROJECTION_CHANGED, this.onMapChanged);
			}
			super._map = map;
			if(map!=null) 
			{
				// add listener on Layer
				this._map.addEventListener(LayerEvent.LAYER_ADDED, this.onLayerChanged);
				this._map.addEventListener(LayerEvent.LAYER_REMOVED, this.onLayerChanged);
				this._map.addEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, this.onLayerChanged);
				this._map.addEventListener(LayerEvent.LAYER_CHANGED_ORIGINATORS, this.onOriginatorListChange);
				
				// add listener on Map
				this._map.addEventListener(MapEvent.CENTER_CHANGED, this.onMapChanged);
				this._map.addEventListener(MapEvent.RESOLUTION_CHANGED, this.onMapChanged);
				this._map.addEventListener(MapEvent.PROJECTION_CHANGED, this.onMapChanged);
				// generate the first list of originators :
				generateOriginators();
			}
		}
		/**
		 * Number of layers refering to a same originator.
		 */
		public function get originators():Vector.<DataOriginator>
		{
			return this._originators;
		}
		
		/**
		 * @private
		 */
		public function set originators(originators:Vector.<DataOriginator>):void
		{
			this._originators = originators;
		}
		
		/**
		 * Number of layers refering to a same originator.
		 */
		public function get originatorsLayersCount():HashMap
		{
			return this._originatorsLayersCount;
		}
		
		/**
		 * @private
		 */
		public function set originatorsLayersCount(originatorsLayersCount:HashMap):void
		{
			this._originatorsLayersCount = originatorsLayersCount;
		}
		
	}
}