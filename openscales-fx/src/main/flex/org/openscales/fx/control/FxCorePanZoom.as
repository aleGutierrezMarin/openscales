package org.openscales.fx.control
{
	import org.openscales.core.control.PanZoom;

	public class FxCorePanZoom extends FxControl
	{
		public function FxCorePanZoom()
		{
			this.control = new org.openscales.core.control.PanZoom();
			super();
		}
		
	}
}