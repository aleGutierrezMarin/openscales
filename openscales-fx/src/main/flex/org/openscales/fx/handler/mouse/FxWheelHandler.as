package org.openscales.fx.handler.mouse
{
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.fx.handler.FxHandler;

	/**
	 * <p>WheelHandler Flex wrapper.</p>
	 * <p>To use it, declare a &lt;WheelHandler /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxWheelHandler extends FxHandler
	{
		public function FxWheelHandler()
		{
			this.handler = new WheelHandler();
			super();
		}
	}
}