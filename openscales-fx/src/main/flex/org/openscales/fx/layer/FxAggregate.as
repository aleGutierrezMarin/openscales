package org.openscales.fx.layer
{
	import mx.core.IVisualElement;
	
	import org.openscales.core.layer.Aggregate;

	public class FxAggregate extends FxLayer
	{
		public function FxAggregate(){
		}
		
		override public function init():void {
			this._layer = new Aggregate(this.name);
			
			// We use an interlediate Array in order to avoid adding new component it the loop
			// because it will modify numChildren
			var componentToAdd:Array = new Array();
			var element:IVisualElement = null;
			var i:uint;
			
			for(i=0; i<this.numElements; i++) {
				element = this.getElementAt(i);
				if (element is FxLayer) {
					this.addFxLayer(element as FxLayer);
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
			
	}
}