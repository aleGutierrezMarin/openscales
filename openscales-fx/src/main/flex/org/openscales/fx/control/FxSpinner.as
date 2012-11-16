package org.openscales.fx.control
{
	import mx.events.FlexEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.Spinner;
	import org.openscales.core.events.MapEvent;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * <p>Spinner Flex wrapper</p>
	 * <p>To use it, declare a &lt;Spinner /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxSpinner extends FxControl
	{
		
		private var _slices:int = 12;
		private var _radius:int = 6;
		private var _rotationspeed:int = 80;
		private var _color:uint = 0x000000;
		
		public function FxSpinner()	{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
		}

		protected function onCreationComplete(event:FlexEvent):void{
			if (x >= 0 && y>= 0) {
				this.control = new Spinner(_slices, _radius, _rotationspeed, color, new Pixel(x,y));
			}	
			this.control.active = true;		
		}
		
		/**
		 * Color of the spinner slices
		 * @default 0x000000
		 */ 
		public function get color():uint
		{
			return _color;
		}

		/**
		 * @private
		 */ 
		public function set color(value:uint):void
		{
			_color = value;
		}

		/**
		 * Number of slices in the spinner
		 * @default 12
		 */ 
		public function get slices():int
		{
			return _slices;
		}

		/**
		 * @private
		 */
		public function set slices(value:int):void
		{
			_slices = value;
		}

		/**
		 * Radius of the spinner (in pixel)
		 * @default 6
		 */ 
		public function get radius():int
		{
			return _radius;
		}

		/**
		 * @private
		 */
		public function set radius(value:int):void
		{
			_radius = value;
		}

		/**
		 * Rotation speed of the spinner (in milliseconds)
		 * @default 80
		 */ 
		public function get rotationspeed():int
		{
			return _rotationspeed;
		}

		/**
		 * @private
		 */
		public function set rotationspeed(value:int):void
		{
			_rotationspeed = value;
		}

	}
}