package org.openscales.fx.control
{
	import org.openscales.core.control.PanZoom;

	/**
	 * <p>PanZoom pure ActionScript3 control Flex wrapper. You should use Flex based PanZoom control instead</p>
	 * 
	 * <p>To use it, declare a &lt;CorePanZoom /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxCorePanZoom extends FxControl
	{
		public function FxCorePanZoom()
		{
			this.control = new org.openscales.core.control.PanZoom();
			super();
		}
		
	}
}