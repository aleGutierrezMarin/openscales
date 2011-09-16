package org.openscales.fx.layer.osm {
	import org.openscales.core.layer.osm.Osmarender;
	import org.openscales.fx.layer.FxTMS;

	/**
	 * <p>Osmarender Flex wrapper.</p>
	 * <p>To use it, declare a &lt;Osmarender /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxOsmarender extends FxTMS {
		public function FxOsmarender() {
			this._layer=new Osmarender("");
			super();
		}

	}
}