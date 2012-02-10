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
	 * Encapsulated handlers are ClickHandler, DragHandler, ZoomBoxHandler (shift mode) and WheelHandler
	 * </p>
	 * 
	 * @see ClickHandler
	 * @see DragHandler
	 * @see WheelHandler
	 * @see ZoomBoxHandler
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
		
		/**
		 * Constant used to enable/disable the zoom box handler
		 */ 
		public static const ZOOM_BOX_HANDLER:String = "zoomBoxHandler";
		
		private var _clickHandler:ClickHandler = null;

		public function get clickHandler():ClickHandler
		{
			return _clickHandler;
		}

		public function set clickHandler(value:ClickHandler):void
		{
			_clickHandler = value;
		}

		private var _dragHandler:DragHandler = null;

		public function get dragHandler():DragHandler
		{
			return _dragHandler;
		}

		public function set dragHandler(value:DragHandler):void
		{
			_dragHandler = value;
		}

		private var _wheelHandler:WheelHandler = null;
		private var _zoomBoxHandler:ZoomBoxHandler = null;
		
		/**
		 * Enabled or disabled the wheel handler
		 */
		private var _zoomWheelEnabled:Boolean;
		
		/**
		 * Enabled or disabled the zoom box handler
		 */
		private var _zoomBoxEnabled:Boolean;
		
		/**
		 * Constructor. All encapsulated handlers are enabled.
		 * 
		 * @param target The Map that will be concerned by event handling
		 * @param active Boolean defining if the handler is active or not (default=true)
		 */ 
		public function MouseHandler(map:Map=null, active:Boolean=true)
		{
			super(map, active);
			_clickHandler = new ClickHandler(map,active);
			_dragHandler = new DragHandler(map,active);
			_wheelHandler = new WheelHandler(map,active);
			_zoomBoxHandler = new ZoomBoxHandler(true,map,active);
			
			_zoomWheelEnabled = active;
			_zoomBoxEnabled = active;
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
					_zoomWheelEnabled = true;
					break;	
				case ZOOM_BOX_HANDLER:
					_zoomBoxHandler.active = true;
					_zoomBoxEnabled = true;
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
					_zoomWheelEnabled = false;
					break;	
				case ZOOM_BOX_HANDLER:
					_zoomBoxHandler.active = false;
					_zoomBoxEnabled = false;
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
				this.map.addControl(_clickHandler);
				this.map.addControl(_dragHandler);
				this.map.addControl(_wheelHandler);
				this.map.addControl(_zoomBoxHandler);
			}
		}
		
		/**
		 * zoomWheelEnabled getter
		 */
		public function get zoomWheelEnabled():Boolean
		{
			return _zoomWheelEnabled;
		}
		
		/**
		 * zoomWheelEnabled setter
		 */
		public function set zoomWheelEnabled(value:Boolean):void
		{
			_wheelHandler.active = value;
			_zoomWheelEnabled = value;
		}
		
		/**
		 * zoomBoxEnabled getter
		 */
		public function get zoomBoxEnabled():Boolean
		{
			return _zoomBoxEnabled;
		}
		
		/**
		 * zoomBoxEnabled setter
		 */
		public function set zoomBoxEnabled(value:Boolean):void
		{
			_zoomBoxHandler.active = value;
			_zoomBoxEnabled = value;
		}
		
		override public function set active(value:Boolean):void {
			super.active = value;
			
			if(_clickHandler)
				_clickHandler.active = value; 
			if(_dragHandler)
				_dragHandler.active = value;
			if(_wheelHandler)
				_wheelHandler.active = value && _zoomWheelEnabled;
			if(_zoomBoxHandler)
				_zoomBoxHandler.active = value && _zoomBoxEnabled;
		}

	}
}
