package org.openscales.core.events
{
	import org.openscales.core.handler.feature.draw.AbstractDrawHandler;

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
		public static const MODIFY_HANDLER_ACTIVATED:String = "openscales.drawing.modify_handler_activated";
		
		/**
		 * 
		 */
		private var _activeHandler:String;
		
		
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
	}
}

