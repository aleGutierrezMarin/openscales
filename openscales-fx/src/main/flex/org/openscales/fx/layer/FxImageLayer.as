package org.openscales.fx.layer
{
	import org.openscales.core.layer.ImageLayer;

	/**
	 * <p>ImageLayer Flex wrapper.</p>
	 * <p>To use it, declare a &lt;ImageLayer /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxImageLayer extends FxLayer
	{
		public function FxImageLayer()
		{
			this._layer = new ImageLayer("", "", null);
			super();
		}
		
		public function set url(value:String):void {
			if(this._layer != null)
				(this._layer as ImageLayer).url = value;
		}
		
		public function set bounds(value:String):void {
			this.maxExtent = value;
		}
		
	}
}