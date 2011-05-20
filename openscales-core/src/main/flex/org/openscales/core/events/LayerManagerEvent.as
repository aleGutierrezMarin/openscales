package org.openscales.core.events
{
	import org.openscales.core.layer.Layer;

	public class LayerManagerEvent extends OpenScalesEvent
	{
		
		/**
		 * Layer that dispatched the event
		 */
		private var _layer:Layer;
		
		/**
		 * Position of the button that dispatch the event
		 */
		private var _x:int=0;
		
		private var _y:int=0;
		
		
		/**
		 * Event type dispatched when a button opacity is clicked
		 */
		public static const COMPONENT_OPACITY:String="openscales.opacity";
		
		
		public function LayerManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		public function set layer(value:Layer):void
		{
			this._layer = value;
		}
		public function get layer():Layer
		{
			return this._layer;
		}
		
		public function set x(value:int):void
		{
			this._x = value;
		}
		public function get x():int
		{
			return this._x;
		}
		
		public function set y(value:int):void
		{
			this._y = value;
		}
		public function get y():int
		{
			return this._y;
		}
	}
}