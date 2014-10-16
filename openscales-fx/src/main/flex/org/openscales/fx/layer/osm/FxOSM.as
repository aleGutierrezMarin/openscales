package org.openscales.fx.layer.osm {
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.layer.osm.OSM;
	import org.openscales.fx.layer.FxTMS;

	/**
	 * <p>OSM Flex wrapper.</p>
	 * <p>To use it, declare a &lt;OSM /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxOSM extends FxTMS {
		
		public function FxOSM() {
			this._layer=new OSM("");
			this.numZoomLevels = 18;
			this.maxResolution = OSM.DEFAULT_MAX_RESOLUTION;
			super();
		}
	}
}