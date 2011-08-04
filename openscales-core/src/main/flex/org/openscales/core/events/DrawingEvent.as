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
		public static const CREATE_GEOMETRY:String = "openscales.drawing.create_geometry";
		
		
		private var _drawHandler:AbstractDrawHandler = null;

		public function DrawingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get drawHandler():AbstractDrawHandler{
			return _drawHandler;
		}
		public function set drawHandler(value:AbstractDrawHandler):void{
			_drawHandler = value;
		}
	}
}

