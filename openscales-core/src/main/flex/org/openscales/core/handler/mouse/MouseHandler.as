package org.openscales.core.handler.mouse
{
	import org.openscales.core.Map;
	import org.openscales.core.handler.Handler;

	/**
	 * This handler encapsulates all handlers that are mouse related and add them to the map.
	 * <p>
	 * The user can enable/disable any encapsulated handler. By default all encapsulated 
	 * handlers are enabled. 
	 * </p>
	 * <p>
	 * Encapsulated handlers are ClickHandler, DragHandler and WheelHandler
	 * </p>
	 * 
	 * @see ClickHandler
	 * @see DragHandler
	 * @see WheelHandler
	 */ 
	public class MouseHandler extends Handler
	{
		/**
		 * Constant used to enable/disable the click handler
		 */ 
		public static const CLICK_HANDLER:String = "clickHandler";
		
		/**
		 * Constant used to enable/disable the drag handler
		 */ 
		public static const DRAG_HANDLER:String = "dragHandler";
		
		/**
		 * Constant used to enable/disable the wheel handler
		 */ 
		public static const WHEEL_HANDLER:String = "wheelHandler";
		
		private var _clickHandler:ClickHandler;
		private var _dragHandler:DragHandler;
		private var _wheelHandler:WheelHandler;
		
		/**
		 * Constructor. All encapsulated handlers are enabled.
		 * 
		 * @param target The Map that will be concerned by event handling
		 * @param active Boolean defining if the handler is active or not (default=true)
		 */ 
		public function MouseHandler(map:Map=null, active:Boolean=true)
		{
			super(map, active);
			_clickHandler = new ClickHandler(map,true);
			_dragHandler = new DragHandler(map,true);
			_wheelHandler = new WheelHandler(map,true);	
		}
		
		/**
		 * Enable a handler
		 * 
		 * @param handlerCode The code of the handler to disable (possible values are defined in the class constants). If code is not valid, nothing is done.
		 */ 
		public function enableHandler(handlerCode:String):void
		{
			switch(handlerCode)
			{
				case CLICK_HANDLER:
					_clickHandler.active = true;
					break;
				case DRAG_HANDLER:
					_dragHandler.active = true;
					break;
				case WHEEL_HANDLER:
					_wheelHandler.active = true;
					break;				
			}
		}
		
		/**
		 * Disable a handler
		 * 
		 * @param handlerCode The code of the handler to disable (possible values are defined in the class constants). If code is not valid, nothing is done.
		 */ 
		public function disableHandler(handlerCode:String):void
		{
			switch(handlerCode)
			{
				case CLICK_HANDLER:
					_clickHandler.active = false;
					break;
				case DRAG_HANDLER:
					_dragHandler.active = false;
					break;
				case WHEEL_HANDLER:
					_wheelHandler.active = false;
					break;				
			}
		}
		
		/**
		 * @inheritDoc 
 		 */
		override public function set map(value:Map):void
		{
			super.map = value;
			
			if(this.map)// Handler constructor calls "set map" with null value, need to check
			{
				this.map.addHandler(_clickHandler);
				this.map.addHandler(_dragHandler);
				this.map.addHandler(_wheelHandler);
			}
		}
	}
}