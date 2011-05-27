package org.openscales.core.handler.keyboard
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
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
		/**
		 * @private
		 * Ratio used to calculate new map position when panning
		 */ 
		private static const _SLIDE_RATIO:Number = 0.3;
		
		private var _panWest:uint = Keyboard.LEFT;
		
		private var _panNorth:uint = Keyboard.UP;
		
		private var _panEast:uint = Keyboard.RIGHT;
		
		private var _panSouth:uint = Keyboard.DOWN;
		
		private var _zoomIn:uint = 107;
		
		private var _zoomIn2:uint = 187;
		
		private var _zoomOut:uint = 109;
		
		private var _zoomOut2:uint = 54;
		
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
			}
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function unregisterListeners():void {
			if (this.map) {
				this.map.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
			}
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
				case _panWest:
					this.map.pan(- Math.floor(this.map.width * _SLIDE_RATIO),0,true);
					break;
				case _panNorth:
					this.map.pan(0, - Math.floor(this.map.height * _SLIDE_RATIO), true);
					break;
				case _panEast:
					this.map.pan( Math.floor(this.map.width * _SLIDE_RATIO),0,true);
					break;
				case _panSouth:
					this.map.pan(0, Math.floor(this.map.height * _SLIDE_RATIO), true);
					break;
				case _zoomIn:
					this.map.moveTo(this.map.center, this.map.zoom+1,false,true);
					break;
				case _zoomIn2:
					if(event.shiftKey)this.map.moveTo(this.map.center, this.map.zoom+1,false,true);
					break;
				case _zoomOut:
					this.map.moveTo(this.map.center, this.map.zoom-1,false,true);
					break;
				case _zoomOut2:
					if (!event.shiftKey)this.map.moveTo(this.map.center, this.map.zoom-1,false,true);
					break;
			}
		}
		
		/**
		 * This method sets commands to defaults
		 */ 
		public function setKeyCodesToDefault():void
		{
			this.panWest = Keyboard.LEFT;
			this.panNorth = Keyboard.UP;
			this.panEast = Keyboard.RIGHT;
			this.panSouth = Keyboard.DOWN;
			this.zoomIn = 107;
			//this.zoomIn2 = 187;
			this.zoomOut = 109;
			//this.zoomOut2= 54;
		}

		/**
		 * Pan west key code
		 * <p>Default is Keyboard.LEFT</p>
		 */
		public function get panWest():uint
		{
			return _panWest;
		}

		/**
		 * @private
		 */
		public function set panWest(value:uint):void
		{
			_panWest = value;
		}

		/**
		 * Pan north key code
		 * <p>Default is Keyboard.UP</p>
		 */
		public function get panNorth():uint
		{
			return _panNorth;
		}

		/**
		 * @private
		 */
		public function set panNorth(value:uint):void
		{
			_panNorth = value;
		}

		/**
		 * Pan east key code
		 * <p>Default is Keyboard.RIGHT</p>
		 */
		public function get panEast():uint
		{
			return _panEast;
		}

		/**
		 * @private
		 */
		public function set panEast(value:uint):void
		{
			_panEast = value;
		}

		/**
		 * Pan south key code
		 * <p>Default is Keyboard.DOWN</p>
		 */
		public function get panSouth():uint
		{
			return _panSouth;
		}

		/**
		 * @private
		 */
		public function set panSouth(value:uint):void
		{
			_panSouth = value;
		}

		/**
		 * Zoom in key code
		 * <p>Default is plus sign (on numerical pad) code</p>
		 */
		public function get zoomIn():uint
		{
			return _zoomIn;
		}

		/**
		 * @private
		 */
		public function set zoomIn(value:uint):void
		{
			_zoomIn = value;
		}

		
		/**
		 * Zoom in 2 key code
		 * <p>Default is plus sign (on alphanumerical pad) code</p>
		 */
		 /*
		public function get zoomIn2():uint
		{
			return _zoomIn2;
		}
		*/
		/**
		 * @private
		 */
		/*
		public function set zoomIn2(value:uint):void
		{
			_zoomIn2 = value;
		}*/
		
		/**
		 * Zoom out key code
		 * <p>Default is minus sign (on numerical pad) code</p>
		 */
		public function get zoomOut():uint
		{
			return _zoomOut;
		}

		/**
		 * @private
		 */
		public function set zoomOut(value:uint):void
		{
			_zoomOut = value;
		}

		/**
		 * Zoom out 2 key code
		 * 
		 * <p> Default is minus sign (on alphanumerical pad) code</p>
		 */
		/*
		public function get zoomOut2():uint
		{
			return _zoomOut2;
		}*/

		/**
		 * @private
		 */
		/*
		public function set zoomOut2(value:uint):void
		{
			_zoomOut2 = value;
		}*/


	}
}