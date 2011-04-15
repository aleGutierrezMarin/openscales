package org.openscales.core.control
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	
	
	/**
	 * Instances of DataOriginators are used to show the different originator informations (logo / copyright)
	 * for all the layer of a map.
	 * This list is updated when layer are changed (add / remove / visibility change...)
	 * This list contains originator with no double.
	 * 
	 * This DataOriginators class represents a component to add to the map.
	 * 
	 * @example The following code describe how to add a copyright on a map : 
	 * 
	 * <listing version="3.0">
	 *   var theMap = geoportal.Map();
	 *   theMap.addComponent(new DataOriginators());
	 * </listing>
	 *
	 * @author ajard
	 */ 
	
	public class DataOriginators extends logoRotator
	{
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
		 */ 
		public function DataOriginators()
		{
			generateOriginators();
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Remove the DataOriginators from the map and remove reference on object.
		 */
		override public function destroy():void {
			super.destroy();
			
			this._originatorsLayersCount = null;
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Display the DataOriginators component on the map.
		 */
		override public function draw():void 
		{
			super.draw();
		}
		
		/**
		 * Add an originator in the list
		 * If the originator exist : increment its layers count
		 * Else add The originator in the list and set the layers count to 1
		 */
		public function addOriginator():void
		{
			
		}
		
		/**
		 * Remove an originator in the list
		 * If the originator layers count is > 1, decrement it
		 * Else remove the originator from the list 
		 */
		public function removeOriginator():void
		{
			
		}

		/**
		 * Generate the list of originators using the current layers in the map.
		 * Also store the number of layers which refer to a same originator
		 */ 
		public function generateOriginators():void
		{
			
		}
		
		/**
		 * Update the current list of originators according to the current layers in the map
		 * Remove originator if no layer refer to it anymore
		 * Add an originator if a layer refer to one which is not in the list
		   or increment the number of layers for the existing originator
		 */
		public function updateOriginators():void
		{
			
		}	
		
		/**
		 * Reset all the current layers count to zero
		 */
		public function resetOriginatorsLayersCount():void
		{
			
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
		 */
		public function onLayerChanged(evt:LayerEvent):void
		{
			
		}
			
		/**
		 * Call when a MapEvent occur
		 * Two LayerEvent are handled :
		 * MOVE_END
		 * RESIZE
		 * 
		 * After this events originators have to be updated
		 */
		public function onMapChanged(evt:MapEvent):void
		{
			
		}	
	

		// getters / setters
		/**
		 * Number of layers refering to a same originator.
		 */
		public function get originatorsLayersCount():HashMap
		{
			return this._originatorsLayersCount;
		}
		
		public function set originatorsLayersCount(originatorsLayersCount:HashMap):void
		{
			this._originatorsLayersCount = originatorsLayersCount;
		}
			
	}
}