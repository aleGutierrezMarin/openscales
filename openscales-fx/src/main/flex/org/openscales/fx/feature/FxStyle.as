package org.openscales.fx.feature
{
	import mx.core.UIComponent;
	
	import org.openscales.core.style.Style;
	
	/**
	 * <p>Style Flex wrapper.</p>
	 * <p>To use it, declare a &lt;Style /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxStyle extends UIComponent
	{
		private var _style:Style;	
		
		public function FxStyle()
		{
			this._style = new Style();
			super();
		}
		
		public function get style():Style {
			return this._style;
		}
	}
}