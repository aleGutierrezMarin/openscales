package org.openscales.fx.control
{
	import org.openscales.core.Map;
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
		
		public function set displayProjSrsCode(value:String):void {
			if (this.control != null && value != null)
				(this.control as MousePosition).displayProjSrsCode = value;
		}
		
		public function set numdigits(value:Number):void {
			if (this.control != null)
				(this.control as MousePosition).numdigits = value;
		}
		
		public function set localNSEW(value:String):void {
			if (this.control != null && value != null)
				(this.control as MousePosition).localNSEW = value;
		}
		
		public function set map(value:Map):void {
			if (this.control != null && value != null)
				(this.control as MousePosition).map = value;
		}
		
	}
}