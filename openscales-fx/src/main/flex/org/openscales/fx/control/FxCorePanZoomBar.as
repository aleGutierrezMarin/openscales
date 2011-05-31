package org.openscales.fx.control
{
	import org.openscales.core.control.PanZoomBar;

	/**
	 * <p>PanZoomBar pure ActionScript3 control Flex wrapper. You should use Flex based PanZoom control instead.</p>
	 * 
	 * <p>To use it, declare a &lt;CorePanZoomBar /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxCorePanZoomBar extends FxControl
	{
		public function FxCorePanZoomBar()
		{
			this.control = new PanZoomBar();
			super();
		}
		
	}
}