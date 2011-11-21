package org.openscales.fx.layer
{
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.openscales.core.layer.Aggregate;
	import org.openscales.core.layer.Layer;

	
	public class FxAggregate extends FxLayer
	{
		private var _bufferedAlpha:Number=NaN;
		private var _bufferedVisible:Number=-1;
		
		public function FxAggregate(){
		}
		
		override public function init():void {
			this._layer = new Aggregate(this.name);
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		override public function configureLayer():Layer{
			this._layer.name = this.name;
			return this._layer;
		}
		
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
		
		
		override public function set alpha(value:Number):void {
			super.alpha = value;
			this._bufferedAlpha = value;
		}
			
		override public function set visible(value:Boolean):void {
			super.visible = value;
			this._bufferedVisible = value ? 1 : 0; 
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
		 * Apply FxAggregate buffered values to added layers
		 * 
		 * @param layer
		 */ 
		private function applyBufferedAttributes(layer:FxLayer):void{
			if(!isNaN(this._bufferedAlpha)) layer.alpha = this._bufferedAlpha;
			if(this._bufferedVisible==1) layer.visible = true;
			else if(this._bufferedVisible==0) layer.visible = false;
		}
			
	}
}