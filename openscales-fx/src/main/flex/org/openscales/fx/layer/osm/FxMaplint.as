package org.openscales.fx.layer.osm {
	import org.openscales.core.layer.osm.Maplint;
	import org.openscales.fx.layer.FxTMS;

	/**
	 * Maplint Flex wrapper
	 * To use it, declare a &lt;Maplint /&gt; MXML component using xmlns="http://openscales.org"
	 */
	public class FxMaplint extends FxTMS {
		public function FxMaplint() {
			this._layer=new Maplint("");
			super();
		}

	}
}