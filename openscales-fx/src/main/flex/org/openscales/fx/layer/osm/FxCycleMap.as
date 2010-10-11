package org.openscales.fx.layer.osm {
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.fx.layer.FxTMS;

	/**
	 * CycleMap Flex wrapper
	 * To use it, declare a &lt;CycleMap /&gt; MXML component using xmlns="http://openscales.org"
	 */
	public class FxCycleMap extends FxTMS {
		public function FxCycleMap() {
			this._layer=new CycleMap("");
			super();
		}

	}
}