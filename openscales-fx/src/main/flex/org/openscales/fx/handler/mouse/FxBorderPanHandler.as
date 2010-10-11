package org.openscales.fx.handler.mouse
{
	import org.openscales.core.handler.mouse.BorderPanHandler;
	import org.openscales.fx.handler.FxHandler;

	/**
	 * BorderPanHandler Flex wrapper
	 * To use it, declare a &lt;BorderPanHandler /&gt; MXML component using xmlns="http://openscales.org"
	 */
	public class FxBorderPanHandler extends FxHandler
	{
		public function FxBorderPanHandler()
		{
			this.handler = new BorderPanHandler();
			super();
		}
		
	}
}