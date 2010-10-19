package org.openscales.fx.control
{
	import org.openscales.proj4as.ProjProjection;
	
	import org.openscales.core.control.MousePosition;

	/**
	 * <p>MousePosition Flex wrapper.</p>
	 * <p>To use it, declare a &lt;MousePosition /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxMousePosition extends FxControl
	{
		public function FxMousePosition()
		{
			this.control = new MousePosition();
			super();
		}
		
		public function set displayProjection(value:String):void {
			if (this.control != null && value != null)
				(this.control as MousePosition).displayProjection = new ProjProjection(value);
		}
		
		public function set numdigits(value:Number):void {
			if (this.control != null)
				(this.control as MousePosition).numdigits = value;
		}
		
	}
}