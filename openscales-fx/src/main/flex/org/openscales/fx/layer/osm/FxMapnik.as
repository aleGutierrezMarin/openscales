package org.openscales.fx.layer.osm {
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.fx.layer.FxTMS;

	/**
	 * Mapnik Flex wrapper
	 * To use it, declare a &lt;Mapnik /&gt; MXML component using xmlns="http://openscales.org"
	 */
	public class FxMapnik extends FxTMS {
		public function FxMapnik() {
			this._layer=new Mapnik("");
			super();
		}

	}
}