package org.openscales.fx.control.layer
{


	import mx.core.IVisualElement;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.LayerManagerEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.LayerManager;
	
	import spark.components.List;
	import spark.components.supportClasses.ItemRenderer;
	
	public class LayerRenderer extends ItemRenderer
	{
		/**
		 * The layer associated with the current item
		 */
		private var _layer:Layer;
		
		/**
		 * The rendererOptions Object define by the LayerManager rendererOtpions attribute
		 */
		private var _rendererOptions:Object = null;
		
		/**
		 * Use the rendererOptions in the LayerManager to set the current optional controls
		 * Get the owner of this rendrer (the List and get its parent to get the LayerManager)
		 */
		public function LayerRenderer():void
		{
			var list:List = (this.owner as List);
			this._rendererOptions = (list.parent.parent as LayerManager).rendererOptions;
		}
		
		/**
		 * TODO : check for all children !
		 * Give the current layer to the LayerManager Control which are on this renderer
		 */
		public function setLayerToControls():void
		{
			var i:uint = 0;
			var j:uint = 0;
			var sizeElement:uint = this.numElements;
			
			var element:IVisualElement = null;
			var subElement:IVisualElement = null;
			
			// Check elements in the Group
			for(i=0; i<sizeElement; i++) {
				element = this.getElementAt(i);
				
				if (subElement is LayerControl) {
					(subElement as LayerControl).layer = this._layer;
				} 
			}
		}


		/**
		 * Set the data
		 * @param value
		 */
		override public function set data(value:Object):void 
		{
			this._layer = value as Layer;
			
			if((this.layer != null) )
			{			
				// setting the layer to the sub LayerManager Control component :
				this.setLayerToControls();
			}
		}


		/**
		 * Get the layer that the List into the LayerManager.mxml send to display it
		 * @return return the layer
		 */
		public function get layer():Layer 
		{
			return this._layer;
		}
		
		/**
		 * @private
		 */
		public function set layer(value:Layer):void
		{
			this._layer = value;
		}
		
		
		/**
		 * The rendererOptions Object define by the LayerManager rendererOtpions attribute
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
			this._rendererOptions = value;
		}
	}
}
