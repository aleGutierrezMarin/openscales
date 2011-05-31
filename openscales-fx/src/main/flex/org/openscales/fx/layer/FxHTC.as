package org.openscales.fx.layer
{
	import org.openscales.core.layer.HTC;
	
	/**
	 * <p>HTC Flex wrapper.</p>
	 * <p>To use it, declare a &lt;HTC /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxHTC extends FxTMS
	{
		public function FxHTC() {
			this._layer=new HTC("","");
			super();
		}

		public function set directoryPrefix(value:String):void {
			if(this._layer != null)
				(this._layer as HTC).directoryPrefix = value;
		}
	}
}