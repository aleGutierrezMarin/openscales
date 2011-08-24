package org.openscales.fx.handler.mouse
{
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.fx.handler.FxHandler;

	/**
	 * <p>DragHandler Flex wrapper.</p>
	 * <p>To use it, declare a &lt;DragHandler /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxDragHandler extends FxHandler
	{
		public function FxDragHandler()
		{
			super();
			this.handler = new DragHandler();
		}
		
	}
}