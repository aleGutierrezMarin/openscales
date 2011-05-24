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
	
	public class LayerRenderer extends ItemRenderer
	{
		/**
		 * The layer associated with the current item
		 */
		protected var _layer:Layer;
		
		/**
		 * The rendererOptions Object define by the LayerManager rendererOtpions attribute
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
		 * Give the current layer to the LayerManager Control which are on this renderer
		 */
		public function setLayerToControls():void
		{
			this.setLayer(this.getElementAt(0));
		}
		
		/**
		 * Recursively set the layer of all LayerControl in the LayerRenderer
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
		 * Manage rendererOptions : get the rendererOptions object in the LayerMananger owner
		 */
		public function manageRendererOptions():void
		{
			// get the rendererOptions in the LayerManager parent
			var searching:Boolean = true;
			
			// the list owner
			var list:List = (this.owner as List);
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

			this.manageRendererOptions();
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
