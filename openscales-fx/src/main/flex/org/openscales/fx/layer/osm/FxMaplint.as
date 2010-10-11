package org.openscales.fx.layer.osm {
	import org.openscales.core.layer.osm.Maplint;
	import org.openscales.fx.layer.FxTMS;

	/**
	 * <p>Maplint Flex wrapper.</p>
	 * <p>To use it, declare a &lt;Maplint /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxMaplint extends FxTMS {
		public function FxMaplint() {
			this._layer=new Maplint("");
			super();
		}

	}
}