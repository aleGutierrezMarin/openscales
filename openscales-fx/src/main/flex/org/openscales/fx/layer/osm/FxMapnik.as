package org.openscales.fx.layer.osm {
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.fx.layer.FxTMS;

	/**
	 * <p>Mapnik Flex wrapper.</p>
	 * <p>To use it, declare a &lt;Mapnik /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxMapnik extends FxTMS {
		public function FxMapnik() {
			this._layer=new Mapnik("");
			super();
		}

	}
}