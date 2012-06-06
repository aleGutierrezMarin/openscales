package org.openscales.fx.control.layer
{
	import flash.events.Event;
	
	import mx.core.ClassFactory;
	
	import org.openscales.fx.control.Control;
	
	import spark.components.List;
	
	public class LayerManager extends Control
	{
		public function LayerManager()
		{
			super();
		}
		
		import mx.collections.ArrayCollection;
		import mx.core.IFactory;
		import mx.events.DragEvent;
		
		import org.openscales.core.Map;
		import org.openscales.core.events.I18NEvent;
		import org.openscales.core.events.LayerEvent;
		import org.openscales.core.events.MapEvent;
		import org.openscales.core.i18n.Catalog;
		import org.openscales.core.layer.Layer;
		import org.openscales.fx.control.layer.itemrenderer.DefaultLayerManagerItemRenderer;
		
		import spark.components.Group;
		
		
		[SkinPart(required="true")]
		public var layerList:List;
		
		
		
		/**
		 * Indicates if the drawing tools should be shown
		 */
		
		/**
		 * The dataProvider use for the list.
		 */
		protected var _layers:ArrayCollection = new ArrayCollection();
		
		/**
		 * @private
		 * Options for the LayerManager renderer (for additionnal controls to display like Metadatas, legend...)
		 * @default null
		 */
		[Bindable]
		private var _rendererOptions:Object = null;
		
		

		override protected function partAdded(partName:String, instance:Object):void{
			if(instance==layerList){
				layerList.dataProvider=this.layers;
			}
		}
		
		/**
		 * Set the map
		 * @param value
		 */	 
		override public function set map(value:Map):void {
			
			super.map = value;
			
			if(this._map != null) 
			{
				var overlayArray:Vector.<Layer>  = this.map.layers;
				var ac:ArrayCollection = new ArrayCollection();
				var i:int = overlayArray.length;
				for(i;i>0;--i)
					ac.addItem(overlayArray[i-1]);
				this.layers = ac;
				
				_layers.sort = new MapSyncSort(_map);
				_layers.filterFunction = shallDisplayLayer;
				_layers.refresh();
			}
			
			if(this.active){
				
				this.activate();
			}
		} 
		
		/**
		 * @inherit
		 */
		override public function activate():void 
		{
			super.activate();
			
			if(this._map)
			{
				//Listening of layer event
				this._map.addEventListener(LayerEvent.LAYER_ADDED,onLayerAdded);
				//	this._map.addEventListener(LayerEvent.LAYER_CHANGED,this.refresh);
				this._map.addEventListener(LayerEvent.LAYER_REMOVED,onLayerRemoved);
				this._map.addEventListener(LayerEvent.LAYER_CHANGED_ORDER,this.refresh);
				this._map.addEventListener(LayerEvent.LAYER_DISPLAY_IN_LAYERMANAGER_CHANGED,onLayerDisplayInLayerManagerChange);
			}
		}
		
		/**
		 * @inherit
		 */
		override public function desactivate():void 
		{	
			super.desactivate();
			
			if(this._map)
			{
				this._map.removeEventListener(LayerEvent.LAYER_ADDED,onLayerAdded);
				//	this._map.removeEventListener(LayerEvent.LAYER_CHANGED,this.refresh);
				this._map.removeEventListener(LayerEvent.LAYER_REMOVED,onLayerRemoved);
				this._map.removeEventListener(LayerEvent.LAYER_CHANGED_ORDER,this.refresh);
				this._map.removeEventListener(LayerEvent.LAYER_DISPLAY_IN_LAYERMANAGER_CHANGED,onLayerDisplayInLayerManagerChange);
			}
		}
		
		/**
		 * Refresh the LayerSwitcher when a layer is add, delete or update
		 * @param event Layer event
		 */
		public function refresh(event:Event = null):void {	
			
			_layers.refresh();
			//	this.invalidateDisplayList();
		}
		
		protected function onLayerAdded(event:LayerEvent):void{
			
			this._layers.addItemAt(event.layer,0);
			this.refresh();
		}
		
		protected function onLayerRemoved(event:LayerEvent):void{
			
			var layer:Layer = event.layer as Layer;
			_layers.filterFunction = null;
			_layers.sort = null;
			_layers.refresh();
			var index:int = _layers.getItemIndex(layer);
			if(index != -1){
				_layers.removeItemAt(index);
			}
			_layers.filterFunction = shallDisplayLayer;
			_layers.sort = new MapSyncSort(_map);
			_layers.refresh();
		}
		
		protected function onLayerDisplayInLayerManagerChange(event:LayerEvent):void{
			
			this.refresh();
		}
		
		/**
		 * Checks if the layer shall be displayed in the LayerManager
		 */
		public function shallDisplayLayer(layer:Layer):Boolean{
			
			return layer.displayInLayerManager;
		}
		
		/**
		 * Moves given layer closer to the user, 
		 * unless it is already on top of all the other layers 
		 */
		public function moveForward(layer:Layer):void{
			
			var index:uint = _layers.getItemIndex(layer);
			
			if(index > 0){
				
				var nextLayer:Layer = _layers.getItemAt(index-1) as Layer;
				var nextLayerPositionInMap:int = _map.layers.indexOf(nextLayer);
				
				_map.changeLayerIndex(layer,nextLayerPositionInMap);	
			}
		}
		
		/**
		 * Moves back the layer,
		 * unless it is already behing all the other layers 
		 */
		public function moveBack(layer:Layer):void{
			
			var index:uint = _layers.getItemIndex(layer);
			
			if(index < _layers.length -1){
				
				var nextLayer:Layer = _layers.getItemAt(index+1) as Layer;
				var nextLayerPositionInMap:int = _map.layers.indexOf(nextLayer);
				
				_map.changeLayerIndex(layer,nextLayerPositionInMap);	
			}
		}
		
		/**
		 * Moves layer at given index
		 */
		public function moveLayerAtIndex(layer:Layer,index:uint):void{
			
			if( index < 0 && index > _layers.length-1 ){
				return;
			}
			
			var layerAtIndex:Layer = _layers.getItemAt(index) as Layer;
			var mapIndex:int = _map.layers.indexOf(layerAtIndex);
			_map.changeLayerIndex(layer,mapIndex);
		}
		
		/**
		 * Update layers order when a user change it
		 * @param event Drag event
		 */
		public function changeLayerOrder(event:DragEvent):void{
			var layer:Layer = layerList.selectedItem as Layer;
			this.map.changeLayerIndex(layer,layerList.selectedIndex);
		}
		
		// getter / setter
		/**
		 * The list of layers displayed in the LayerSwitcher
		 */
		[Bindable]
		public function get layers():ArrayCollection
		{
			return this._layers;
		}
		
		/**
		 * @private
		 */
		public function set layers(value:ArrayCollection):void
		{
			this._layers=value;
		}
		
		/**
		 * Options for the LayerManager renderer (for additionnal controls to display like Metadatas, legend...)
		 */
		public function get rendererOptions():Object
		{
			return this._rendererOptions;
		}
		
		/**
		 * @private
		 */
		public function set rendererOptions(value:Object):void
		{
			this._rendererOptions=value;
		}
		
		/**
		 * 
		 */
		override public function toggleDisplay(event:Event=null):void{
			
			super.toggleDisplay();
			var newEvent:MapEvent = new MapEvent(MapEvent.COMPONENT_CHANGED, this._map);
			newEvent.componentName = "LayerSwitcher";
			newEvent.componentIconified = this._isReduced;
			this._map.dispatchEvent(newEvent);
		}
		
	}
}