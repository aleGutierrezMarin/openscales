package org.openscales.fx.handler.mouse
{
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.fx.handler.FxHandler;

	/**
	 * DragHandler Flex wrapper
	 * To use it, declare a &lt;DragHandler /&gt; MXML component using xmlns="http://openscales.org"
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