package org.openscales.fx.handler
{
	import mx.core.UIComponent;
	
	import org.openscales.core.handler.IHandler;

	/**
	 * Abstract Handler Flex wrapper, use inherited classes
	 */
	public class FxHandler extends UIComponent
	{
		private var _handler:IHandler;
		
		public function FxHandler()
		{
			super();
		}
		
		public function get handler():IHandler {
			return this._handler;
		}
		public function set handler(value:IHandler):void {
			this._handler = value;
		}

		[Bindable]
		public function get active():Boolean {
			return this._handler.active;
		}
		public function set active(value:Boolean):void {
			this._handler.active = value;
		}
				
	}
}