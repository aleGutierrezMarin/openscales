package org.openscales.fx.layer.osm {
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.fx.layer.FxTMS;

	/**
	 * <p>CycleMap Flex wrapper.</p>
	 * <p>To use it, declare a &lt;CycleMap /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxCycleMap extends FxTMS {
		public function FxCycleMap() {
			this._layer=new CycleMap("");
			super();
		}

	}
}