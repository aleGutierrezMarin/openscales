package org.openscales.core.events
{
	import org.openscales.core.handler.feature.draw.AbstractDrawHandler;
	import org.openscales.core.layer.VectorLayer;

	/**
	 * Event related to the drawing action :
	 *
	 * In order to not mix all handler (pan, drawing...), this event can determine when you're drawing.
	 * So if there are problems with control (like zoomBox or selectBox), you can easily manage
	 * all different handlers.
	 **/
	public class DrawingEvent extends OpenScalesEvent
	{
		/**
		 * Drawing mode is enabled
		 */
		public static const ENABLED:String="openscales.drawing.enabled";
		
		/**
		 * Drawing mode is disabled
		 */
		public static const DISABLED:String="openscales.drawing.disabled";
		
		/**
		 * 
		 */
		public static const DRAW_HANDLER_ACTIVATED:String = "openscales.drawing.draw_handler_activated";
		public static const EDIT_HANDLER_ACTIVATED:String = "openscales.drawing.edit_handler_activated";
		public static const MOVE_HANDLER_ACTIVATED:String = "openscales.drawing.move_handler_activated";
		public static const SELECT_HANDLER_ACTIVATED:String = "openscales.drawing.select_handler_activated";
		public static const ATTRIBUTES_HANDLER_ACTIVATED:String = "openscales.drawing.attributes_handler_activated";
		public static const ATTRIBUTES_UPDATED:String = "openscales.drawing.attributes_updated";
		public static const CHANGE_ACTIVE_HANDLER:String = "openscales.drawing.change_active_handler";
		
		/**
		 * 
		 */
		private var _activeHandler:String;
		private var _data:Array;
		private var _attributes:Array;
		private var _layer:VectorLayer;
		
		
		public function DrawingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get activeHandler():String{
			return _activeHandler;
		}
		public function set activeHandler(value:String):void{
			_activeHandler = value;
		}
		
		public function get data():Array{
			return this._data;
		}
		public function set data(value:Array):void{
			this._data = value;
		}
		
		public function get attributes():Array{
			return this._attributes;
		}
		public function set attributes(value:Array):void{
			this._attributes = value;
		}
		
		public function get layer():VectorLayer{
			return this._layer;
		}
		public function set layer(value:VectorLayer):void{
			this._layer = value;
		}
	}
}

