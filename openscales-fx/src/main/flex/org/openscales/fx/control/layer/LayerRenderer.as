package org.openscales.fx.control.layer
{

	import mx.core.IVisualElement;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.LayerManagerEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.LayerManager;
	
	import spark.components.Group;
	import spark.components.List;
	import spark.components.supportClasses.ItemRenderer;
	
	
	/**
	 * Basic class for LayerRenderer use with LayerManager.
	 * No controls are set in this component but mandatory functions are implemented.
	 * Inherit from this class to implement your own LayerSwitcherRenderer.
	 * 
	 * @author ajard
	 * 
	 * @example
	 */
	
	public class LayerRenderer extends ItemRenderer
	{
		/**
		 * The layer associated to the current item
		 * @default null
		 */
		protected var _layer:Layer = null;
		
		/**
		 * The rendererOptions Object define by the LayerManager rendererOtpions attribute
		 * @default null
		 */
		protected var _rendererOptions:Object = null;
		
		/**
		 * Use the rendererOptions in the LayerManager to set the current optional controls
		 * Get the owner of this rendrer (the List and get its parent to get the LayerManager)
		 */
		public function LayerRenderer():void
		{
		}
		
		/**
		 * Give the current layer (corresponding to an item of the LayerManager List)
		 * to all the LayerControl defined in the LayerRenderer
		 * 
		 * Call the setLayer function to the first child of the LayerRenderer
		 */
		public function setLayerToControls():void
		{
			this.setLayer(this.getElementAt(0));
		}
		
		/**
		 * Recursively set the layer of the current IVisualElement and its child 
		 * if they are LayerControl type
		 * @param elt The current visualElement to set the layer if it is type of LayerControl
		 */
		public function setLayer(elt:IVisualElement):void
		{
			var group:Group = null;
			var i:uint;
			var sizeElement:uint;
			
			// if is a LayerControl, set the map 
			if (elt is LayerControl) {
				(elt as LayerControl).layer = this._layer;
			}
	
			// if contains object that contains LayerControl
			else
			{
				if(elt is Group)
				{
					group = elt as Group;
					
					i = 0;
					sizeElement = group.numElements;
					
					for(i=0; i<sizeElement; i++) {
						var subElement:IVisualElement = group.getElementAt(i);
						this.setLayer(subElement);
					}
				}
			}
		}

		/**
		 * Manage rendererOptions : get the rendererOptions object in the LayerManager owner
		 * and set the current rendererOptions with it
		 * Override this method to add your own actions according to the rendererOptions contents
		 */
		public function manageRendererOptions():void
		{
			// get the rendererOptions in the LayerManager parent
			var searching:Boolean = true;
			
			// the list owner
			var object:Object = this.owner;
			
			while(searching)
			{
				object = object.parent;
				if( object == null )
					searching = false; // no more parents
					
				else if( object is LayerManager)
				{
					this._rendererOptions = (object as LayerManager).rendererOptions;
					searching = false;
				}
			}
		}

		/**
		 * Function call when the data is set to the LayerRenderer.
		 * Functions setLayerToControls and manageRendererOptions are called at that time.
		 * @param value The data value from the current item of the LayerManager List
		 */
		override public function set data(value:Object):void 
		{
			super.data = value;
			this._layer = value as Layer;
			
			if((this.layer != null) )
			{			
				// setting the layer to the sub LayerManager Control component :
				this.setLayerToControls();
			}

			this.manageRendererOptions();
		}


		/**
		 * The layer associated to the current item
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
