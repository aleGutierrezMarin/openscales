package org.openscales.core.events
{
	public class StyleEvent extends OpenScalesEvent
	{
		/**
		 * Event type dispatched when the external graphic ressource is loaded
		 */
		public static const EXTERNAL_GRAPHIC_LOADED:String = "openscales.styleevent.externalgraphicloaded";
		
		public function StyleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}