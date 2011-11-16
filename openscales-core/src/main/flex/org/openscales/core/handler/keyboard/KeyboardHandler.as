package org.openscales.core.handler.keyboard
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.handler.Handler;

	/**
	 * Handler for keyboard
	 * 
	 * <p>
	 * By default handled keys are:
	 * <ul>
	 * 		<li>4 arrow keys (for panning in 4 directions, can be configured)</li>
	 * 		<li>minus and plus keys on numeric pad (for zooming, can be configured)</li>
	 * 		<li>minus and plus keys on alphanumerical pad (for zooming, can not be configured)</li>
	 * </ul> 
	 * </p>
	 * 
	 * @author htulipe
	 */ 
	public class KeyboardHandler extends Handler
	{
		private var _panStep:Number = 75;
		
		private var _panStepShiftkey:Number = 225;
		
		private var _panWestKeyCode:uint = Keyboard.LEFT;
		
		private var _panNorthKeyCode:uint = Keyboard.UP;
		
		private var _panEastKeyCode:uint = Keyboard.RIGHT;
		
		private var _panSouthKeyCode:uint = Keyboard.DOWN;
		
		private var _zoomInKeyCode:uint = 107;
		
		private var _zoomInKeyCode2:uint = 187;
		
		private var _zoomOutKeyCode:uint = 109;
		
		private var _zoomOutKeyCode2:uint = 54;
		
		/**
		 * Constructor
		 * 
		 * @param target The Map that will be concerned by event handling
		 * @param active Boolean defining if the handler is active or not (default=true)
		 */ 
		public function KeyboardHandler(target:Map = null, active:Boolean = true)
		{
			super(target,active);
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function registerListeners():void {
			if (this.map) {
				this.map.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
				this.map.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			}
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
				this.map.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			}
		}
		
		/**
		 * Set the focus to the map when the mouse is over the map
		 * Avoid the user to click on the map to give it focus after focusing on another map control
		 */
		private function onMouseOver(event:MouseEvent):void
		{
			this.map.stage.focus = this.map;
		}
		
		/**
		 * @private
		 * 
		 * Method to handle keyboard events
		 */ 
		private function onKeyDown(event:KeyboardEvent):void
		{			
			switch(event.keyCode)
			{
				case _panWestKeyCode:
					if(event.shiftKey)
						this.map.pan(-_panStepShiftkey,0);
					else
						this.map.pan(-_panStep,0);
					break;
				case _panNorthKeyCode:
					if(event.shiftKey)
						this.map.pan(0,-_panStepShiftkey);
					else
						this.map.pan(0,-_panStep);
					break;
				case _panEastKeyCode:
					if(event.shiftKey)
						this.map.pan(_panStepShiftkey,0);
					else
						this.map.pan(_panStep,0);
					break;
				case _panSouthKeyCode:
					if(event.shiftKey)
						this.map.pan(0,_panStepShiftkey);
					else
						this.map.pan(0,_panStep);
					break;
				case _zoomInKeyCode:
					this.map.zoomIn();
					break;
				case _zoomInKeyCode2:
					if(event.shiftKey)
						this.map.zoomIn();
					break;
				case _zoomOutKeyCode:
					this.map.zoomOut();
					break;
				case _zoomOutKeyCode2:
					if(!event.shiftKey)
						this.map.zoomOut();
					break;
				default:
					return;
			}
		}
		
		/**
		 * This method sets commands to defaults
		 */
		public function setKeyCodesToDefault():void
		{
			this.panStep = 75;
			this.panStepShiftkey = 225;
			this.panWestKeyCode = Keyboard.LEFT;
			this.panNorthKeyCode = Keyboard.UP;
			this.panEastKeyCode = Keyboard.RIGHT;
			this.panSouthKeyCode = Keyboard.DOWN;
			this.zoomInKeyCode = 107;
			//this.zoomInKeyCode2 = 187;
			this.zoomOutKeyCode = 109;
			//this.zoomOutKeyCode2 = 54;
		}
		
		/**
		 * Step (in pixels) used to calculate new map position when panning without shift key pressed
		 * <p>Default is 75</p>
		 */
		public function get panStep():Number
		{
			return _panStep;
		}
		
		/**
		 * @private
		 */
		public function set panStep(value:Number):void
		{
			_panStep = value;
		}
		
		/**
		 * Step (in pixels) used to calculate new map position when panning with shift key pressed
		 * <p>Default is 225</p>
		 */
		public function get panStepShiftkey():Number
		{
			return _panStepShiftkey;
		}
		
		/**
		 * @private
		 */
		public function set panStepShiftkey(value:Number):void
		{
			_panStepShiftkey = value;
		}
		
		/**
		 * Pan west key code
		 * <p>Default is Keyboard.LEFT</p>
		 */
		public function get panWestKeyCode():uint
		{
			return _panWestKeyCode;
		}

		/**
		 * @private
		 */
		public function set panWestKeyCode(value:uint):void
		{
			_panWestKeyCode = value;
		}

		/**
		 * Pan north key code
		 * <p>Default is Keyboard.UP</p>
		 */
		public function get panNorthKeyCode():uint
		{
			return _panNorthKeyCode;
		}

		/**
		 * @private
		 */
		public function set panNorthKeyCode(value:uint):void
		{
			_panNorthKeyCode = value;
		}

		/**
		 * Pan east key code
		 * <p>Default is Keyboard.RIGHT</p>
		 */
		public function get panEastKeyCode():uint
		{
			return _panEastKeyCode;
		}

		/**
		 * @private
		 */
		public function set panEastKeyCode(value:uint):void
		{
			_panEastKeyCode = value;
		}

		/**
		 * Pan south key code
		 * <p>Default is Keyboard.DOWN</p>
		 */
		public function get panSouthKeyCode():uint
		{
			return _panSouthKeyCode;
		}

		/**
		 * @private
		 */
		public function set panSouthKeyCode(value:uint):void
		{
			_panSouthKeyCode = value;
		}

		/**
		 * Zoom in key code
		 * <p>Default is plus sign (on numerical pad) code</p>
		 */
		public function get zoomInKeyCode():uint
		{
			return _zoomInKeyCode;
		}

		/**
		 * @private
		 */
		public function set zoomInKeyCode(value:uint):void
		{
			_zoomInKeyCode = value;
		}
		
		/**
		 * Zoom out key code
		 * <p>Default is minus sign (on numerical pad) code</p>
		 */
		public function get zoomOutKeyCode():uint
		{
			return _zoomOutKeyCode;
		}

		/**
		 * @private
		 */
		public function set zoomOutKeyCode(value:uint):void
		{
			_zoomOutKeyCode = value;
		}
		
	}
}