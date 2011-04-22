package org.openscales.core.handler.keyboard
{
	import flash.events.KeyboardEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.handler.Handler;

	/**
	 * Handler for keyboard
	 * 
	 * <p>
	 * Handled keys are:
	 * <ul>
	 * 		<li>4 arrow keys (for panning in 4 directions)</li>
	 * 		<li>minus and plus keys on numeric pad (for zooming)</li>
	 * 		<li>minus and plus keys on alphanumerical pad (for zooming)</li>
	 * </ul> 
	 * </p>
	 * 
	 * @author htulipe
	 */ 
	public class KeyboardHandler extends Handler
	{
		/**
		 * @private
		 * Left arrow code
		 */ 
		private static const _LEFT:uint = 37;
		
		/**
		 * @private
		 * Up arrow code
		 */ 
		private static const _UP:uint = 38;
		
		/**
		 * @private
		 * Right arrow code
		 */ 
		private static const _RIGHT:uint = 39;
		
		/**
		 * @private
		 * Down arrow code
		 */ 
		private static const _DOWN:uint = 40;
		
		/**
		  * @private
		 *  Plus sign (on numerical pad) code
		 */ 
		private static const _PLUS:uint = 107;
		
		/**
		 * @private
		 * 
		 * Plus sign (on alphanumerical pad) code
		 */ 
		private static const _PLUS2:uint = 187;
		
		/**
		 * @private
		 * Minus sign (on numerical pad) code
		 */ 
		private static const _MINUS:uint = 109;
		
		/**
		 * @private
		 * Minus sign (on alphanumerical pad) code
		 */ 
		private static const _MINUS2:uint = 54;
		
		/**
		 * @private
		 * Ratio used to calculate new map position when panning
		 */ 
		private static const _SLIDE_RATIO:Number = 0.3;
		
		/**
		 * Constructor
		 * 
		 * @param target The Map that will be concerned by event handling
		 * @param active Boolean defining if the handler is active or not (default=false)
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
				case _LEFT:
					this.map.pan(- Math.floor(this.map.width * _SLIDE_RATIO),0,true);
					break;
				case _UP:
					this.map.pan(0, - Math.floor(this.map.height * _SLIDE_RATIO), true);
					break;
				case _RIGHT:
					this.map.pan( Math.floor(this.map.width * _SLIDE_RATIO),0,true);
					break;
				case _DOWN:
					this.map.pan(0, Math.floor(this.map.height * _SLIDE_RATIO), true);
					break;
				case _PLUS:
					this.map.moveTo(this.map.center, this.map.zoom+1,false,true);
					break;
				case _PLUS2:
					if(event.shiftKey)this.map.moveTo(this.map.center, this.map.zoom+1,false,true);
					break;
				case _MINUS:
					this.map.moveTo(this.map.center, this.map.zoom-1,false,true);
					break;
				case _MINUS2:
					if (!event.shiftKey)this.map.moveTo(this.map.center, this.map.zoom-1,false,true);
					break;
			}
		}
	}
}