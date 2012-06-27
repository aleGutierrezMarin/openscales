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
		private var slices:int = 12;
		private var radius:int = 6;
		private var rotationspeed:int = 80;
		private var _color:uint = 0x000000;
		
		public function FxSpinner()	{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
		}

		protected function onCreationComplete(event:FlexEvent):void{
			if (x >= 0 && y>= 0) {
				this.control = new Spinner(slices, radius, rotationspeed, color, new Pixel(x,y));
			}	
			this.control.active = true;		
		}
		
		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
		}

	}
}