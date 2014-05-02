package org.openscales.fx.handler
{
	import org.openscales.core.handler.keyboard.KeyboardHandler;
	
	public class FxKeyboardHandler extends FxHandler
	{
		public function FxKeyboardHandler()
		{
			super();
			this.handler = new KeyboardHandler();
		}
		
		/**
		 * Pan north key code getter
		 * <p>Default is Keyboard.UP</p>
		 */
		public function get panNorthKeyCode():uint
		{
			return (this.handler as KeyboardHandler).panNorthKeyCode;
		}
		
		/**
		 * @private
		 */
		public function set panNorthKeyCode(value:uint):void
		{
			(this.handler as KeyboardHandler).panNorthKeyCode = value;
		}
		
		/**
		 * Pan south key code getter
		 * <p>Default is Keyboard.DOWN</p>
		 */
		public function get panSouthKeyCode():uint
		{
			return (this.handler as KeyboardHandler).panSouthKeyCode;
		}
		
		/**
		 * @private
		 */
		public function set panSouthKeyCode(value:uint):void
		{
			(this.handler as KeyboardHandler).panSouthKeyCode = value;
		}
		
		/**
		 * Pan west key code getter
		 * <p>Default is Keyboard.LEFT</p>
		 */
		public function get panWestKeyCode():uint
		{
			return (this.handler as KeyboardHandler).panWestKeyCode;
		}
		
		/**
		 * @private
		 */
		public function set panWestKeyCode(value:uint):void
		{
			(this.handler as KeyboardHandler).panWestKeyCode = value;
		}
		
		/**
		 * Pan east key code getter
		 * <p>Default is Keyboard.RIGHT</p>
		 */
		public function get panEastKeyCode():uint
		{
			return (this.handler as KeyboardHandler).panEastKeyCode;
		}
		
		/**
		 * @private
		 */
		public function set panEastKeyCode(value:uint):void
		{
			(this.handler as KeyboardHandler).panEastKeyCode = value;
		}
		
		/**
		 * Zoom in key code getter
		 * <p>Default is plus sign (on numerical pad) code</p>
		 */
		public function get zoomInKeyCode():uint
		{
			return (this.handler as KeyboardHandler).zoomInKeyCode;
		}
		
		/**
		 * @private
		 */
		public function set zoomInKeyCode(value:uint):void
		{
			(this.handler as KeyboardHandler).zoomInKeyCode = value;
		}
		
		/**
		 * Zoom out key code getter
		 * <p>Default is minus sign (on numerical pad) code</p>
		 */
		public function get zoomOutKeyCode():uint
		{
			return (this.handler as KeyboardHandler).zoomOutKeyCode;
		}
		
		/**
		 * @private
		 */
		public function set zoomOutKeyCode(value:uint):void
		{
			(this.handler as KeyboardHandler).zoomOutKeyCode = value;
		}
		
		/**
		 * Step (in pixels) used to calculate new map position when panning without shift key pressed
		 * <p>Default is 75</p>
		 */
		public function get panStep():Number
		{
			return (this.handler as KeyboardHandler).panStep;
		}
		
		/**
		 * @private
		 */
		public function set panStep(value:Number):void
		{
			(this.handler as KeyboardHandler).panStep = value;
		}
		
		/**
		 * Step (in pixels) used to calculate new map position when panning with shift key pressed
		 * <p>Default is 225</p>
		 */
		public function get panStepShiftkey():Number
		{
			return (this.handler as KeyboardHandler).panStepShiftkey;
		}
		
		/**
		 * @private
		 */
		public function set panStepShiftkey(value:Number):void
		{
			(this.handler as KeyboardHandler).panStepShiftkey = value;
		}
	}
}