package org.openscales.fx.control.layer
{
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.layer.Layer;
	
	import spark.components.SkinnableContainer;
	
	public class LayerControl extends SkinnableContainer
	{
		/**
		 * @private 
		 * The layer associated to the current item
		 * @default null
		 */
		protected var _layer:Layer = null;
		
		/**
		 * The layer associated to the current item
		 * @default null
		 */
		public function get layer():Layer
		{
			return this._layer;
		}
		
		/**
		 * 
		 */
		public function set layer(value:Layer):void
		{
			this._layer = value;
			
			if(value)
			{
				if(this._layer.map)
					this._layer.map.addEventListener(I18NEvent.LOCALE_CHANGED,onMapLanguageChange);
			}
		}
		
		/**
		 * Do actions on Map language change if necessary
		 */
		public function onMapLanguageChange(event:I18NEvent):void 
		{ }
		
		/**
		 * 
		 */		
		public function LayerControl()
		{	
			super();
		}
	}
}