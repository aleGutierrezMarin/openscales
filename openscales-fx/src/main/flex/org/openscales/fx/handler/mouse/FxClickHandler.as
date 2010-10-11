package org.openscales.fx.handler.mouse
{
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.fx.handler.FxHandler;

	/**
	 * ClickHandler Flex wrapper
	 * To use it, declare a &lt;ClickHandler /&gt; MXML component using xmlns="http://openscales.org"
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