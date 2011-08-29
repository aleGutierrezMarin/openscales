package org.openscales.core.handler.keyboard
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
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
		private var _slideRatio:Number = 75;
		
		private var _slideRatioShiftkey:Number = 225;
		
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
				case _panWest:
					if(event.shiftKey)
						this.map.pan(-_slideRatioShiftkey,0,true);
					else
						this.map.pan(-_slideRatio,0,true);
					break;
				case _panNorth:
					if(event.shiftKey)
						this.map.pan(0,-_slideRatioShiftkey,true);
					else
						this.map.pan(0,-_slideRatio,true);
					break;
				case _panEast:
					if(event.shiftKey)
						this.map.pan(_slideRatioShiftkey,0,true);
					else
						this.map.pan(_slideRatio,0,true);
					break;
				case _panSouth:
					if(event.shiftKey)
						this.map.pan(0,_slideRatioShiftkey,true);
					else
						this.map.pan(0,_slideRatio,true);
					break;
				case _zoomIn:
					this.map.moveTo(this.map.center,this.map.zoom + 1,false,true);
					break;
				case _zoomIn2:
					if(event.shiftKey)
						this.map.moveTo(this.map.center,this.map.zoom + 1,false,true);
					break;
				case _zoomOut:
					this.map.moveTo(this.map.center,this.map.zoom - 1,false,true);
					break;
				case _zoomOut2:
					if(!event.shiftKey)
						this.map.moveTo(this.map.center,this.map.zoom - 1,false,true);
					break;
			}
		}
		
		/**
		 * This method sets commands to defaults
		 */
		public function setKeyCodesToDefault():void
		{
			this.slideRatio = 75;
			this.slideRatioShiftkey = 225;
			this.panWest = Keyboard.LEFT;
			this.panNorth = Keyboard.UP;
			this.panEast = Keyboard.RIGHT;
			this.panSouth = Keyboard.DOWN;
			this.zoomIn = 107;
			//this.zoomIn2 = 187;
			this.zoomOut = 109;
			//this.zoomOut2 = 54;
		}
		
		/**
		 * Step (in pixels) used to calculate new map position when panning without shift key pressed
		 * <p>Default is 75</p>
		 */
		public function get slideRatio():Number
		{
			return _slideRatio;
		}
		
		/**
		 * @private
		 */
		public function set slideRatio(value:Number):void
		{
			_slideRatio = value;
		}
		
		/**
		 * Step (in pixels) used to calculate new map position when panning with shift key pressed
		 * <p>Default is 225</p>
		 */
		public function get slideRatioShiftkey():Number
		{
			return _slideRatioShiftkey;
		}
		
		/**
		 * @private
		 */
		public function set slideRatioShiftkey(value:Number):void
		{
			_slideRatioShiftkey = value;
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