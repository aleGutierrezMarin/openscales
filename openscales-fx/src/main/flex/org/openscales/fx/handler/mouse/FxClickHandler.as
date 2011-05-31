package org.openscales.fx.handler.mouse
{
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.fx.handler.FxHandler;

	/**
	 * <p>ClickHandler Flex wrapper.</p>
	 * <p>To use it, declare a &lt;ClickHandler /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxClickHandler extends FxHandler
	{
		/**
		 * Constructor of the handler component
		 */
		public function FxClickHandler()
		{
			super();
			this.handler = new ClickHandler();
		}
		
	}
}