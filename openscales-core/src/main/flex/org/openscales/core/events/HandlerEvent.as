package org.openscales.core.events
{
	import org.openscales.core.events.OpenScalesEvent;
	import org.openscales.core.handler.Handler;
	
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
		private var _handler:Handler = null;
		
		public function HandlerEvent(type:String, handler:Handler=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._handler = handler;
		}

		public function get handler():Handler
		{
			return _handler;
		}

		public function set handler(value:Handler):void
		{
			_handler = value;
		}

	}
}