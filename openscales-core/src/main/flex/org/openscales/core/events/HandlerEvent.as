package org.openscales.core.events
{
	import org.openscales.core.events.OpenScalesEvent;
	
	public class HandlerEvent extends OpenScalesEvent
	{
		/**
		 * Event type dispatched when a handler is activated.
		 */
		public static const HANDLER_ACTIVATION:String="handler.activation";
		
		/**
		 * Event type dispatched when a handler is desactivated.
		 */
		public static const HANDLER_DESACTIVATION:String="handler.desactivation";
		
		/**
		 * behaviour of the handler which has dispatched the event
		 */
		private var _behaviour:String = null;
		
		public function HandlerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, behaviour:String=null)
		{
			super(type, bubbles, cancelable);
		}

		public function get behaviour():String
		{
			return _behaviour;
		}

		public function set behaviour(value:String):void
		{
			_behaviour = value;
		}

	}
}