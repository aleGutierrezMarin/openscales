package org.openscales.fx.layer {
	import org.openscales.core.layer.ogc.WMSC;

	/**
	 * <p>WMSC Flex wrapper.</p>
	 * <p>To use it, declare a &lt;WMSC /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxWMSC extends FxWMS {
		public function FxWMSC() {
			super();
		}

		override public function init():void {
			this._layer=new WMSC();
		}

	}
}