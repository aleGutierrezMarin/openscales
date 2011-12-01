package org.openscales.fx.layer
{
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.openscales.core.layer.Aggregate;
	import org.openscales.core.layer.Layer;

	/**
	 * Mapping class for Aggregate
	 * 
	 * @see org.openscales.core.layer.Aggregate
	 */	
	public class FxAggregate extends FxLayer
	{
		private var _bufferedAlpha:Number=NaN;
		private var _bufferedVisible:Number=-1;
		
		public function FxAggregate(){
		}
		
		/**
		 * @inheritDoc
		 */ 
		override public function init():void {
			this._layer = new Aggregate(this.name);
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		/**
		 * @inheritDoc
		 */  
		override public function configureLayer():Layer{
			this._layer.name = this.name;
			return this._layer;
		}
		
		/**
		 * Add a layer to the list of aggregated layers.
		 * 
		 * @param layer A layer to be added
		 * @return true if layer has been added, false otherwise
		 */ 
		public function addLayer(layer:Layer):Boolean{
			return (this._layer as Aggregate).addLayer(layer);
		}
		
		/**
		 * Add a set of layers to the list of aggregated layers.
		 * 
		 * @param layers A set of layers to be addeds
		 */ 
		public function addLayers(layers:Vector.<Layer>):void{
			(this._layer as Aggregate).addLayers(layers);
		}
		
		/**
		 * Remove the specified layer from the aggregated layers list.
		 * 
		 * @param layer The layer to be removed
		 */ 
		public function removeLayer(layer:Layer):void{
			(this._layer as Aggregate).removeLayer(layer);
		}
		
		/**
		 * Remove every layers from the aggregated layers list.
		 */ 
		public function removeAllLayers():void{
			(this._layer as Aggregate).removeAllLayers();
		}
		
		/**
		 * @inheritDoc
		 */ 
		protected function onCreationComplete(event:FlexEvent):void{
			// We use an interlediate Array in order to avoid adding new component it the loop
			// because it will modify numChildren
			var componentToAdd:Array = new Array();
			var element:IVisualElement = null;
			var i:uint;
			
			for(i=0; i<this.numElements; i++) {
				element = this.getElementAt(i);
				if (element is FxLayer) {
					this.addFxLayer(element as FxLayer);
					this.applyBufferedAttributes(element as FxLayer);
				}
			}
		}
		
		/**
		 * Add a Flex wrapper layer to the aggregate
		 */
		private function addFxLayer(l:FxLayer):void {
			l.displayInLayerManager=false;
			if(l.nativeLayer){
				(this._layer as Aggregate).addLayer(l.nativeLayer);
			}
		}
		
		/**
		 * Apply FxAggregate buffered values to specified layer
		 * 
		 * @param layer A FxLayer
		 */ 
		private function applyBufferedAttributes(layer:FxLayer):void{
			if(!isNaN(this._bufferedAlpha)) layer.alpha = this._bufferedAlpha;
			if(this._bufferedVisible==1) layer.visible = true;
			else if(this._bufferedVisible==0) layer.visible = false;
		}
		
		/**
		 * The aggregated layers
		 */ 
		public function get layers():Vector.<Layer>{
			return (this._layer as Aggregate).layers;
		} 
		
		/**
		 * Set the alpha of the aggregate and all its aggregated layers
		 */ 
		override public function set alpha(value:Number):void {
			super.alpha = value;
			this._bufferedAlpha = value;
		}
			
		/**
		 * Set the visibilty of the aggregate and all its aggregated layers
		 */ 
		override public function set visible(value:Boolean):void {
			super.visible = value;
			this._bufferedVisible = value ? 1 : 0; 
		} 					
	}
}