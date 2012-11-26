package org.openscales.core.utils
{
	/**
	 * Mimic a chronometer using Epoch time
	 * 
	 *@example This example shows how to use Chronometer
	 * 
	 * <listing version="3.0"> 
	 * 	var c:Chronometer = new Chronometer();
	 *	c.start();
	 *	this.format.read(wmcFile);
	 * 	c.stop();
	 * 	var elapsed:Number = c.elapsed;
	 * </listing> 
	 * 
	 */
	public class Chronometer
	{
		private var _begin:Number;
		private var _end:Number;
		private var _elapsed:Number;
		private var _running:Boolean = false;
		
		public function Chronometer()
		{
		}
		
		/**
		 * Start the chronometer
		 */ 
		public function start():void{
			_begin = new Date().time;
			_running = true;
		}
		
		/**
		 * Stop the chronometer (will do nothing if start() is not called before)
		 */
		public function stop():void{
			if(_running){
				_end = new Date().time;
				_elapsed = _end - _begin;
				_running = false;
			}
		}
		
		/**
		 * Elapsed time in milliseconds (will be null if start() then stop() have not been called before)
		 */ 
		public function get elapsed():Number{
			return _elapsed;
		}
		
	}
}