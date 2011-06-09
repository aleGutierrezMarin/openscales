package org.openscales.fx.layer
{
	import org.openscales.core.layer.KML;

	/**
	 * <p>KML Flex wrapper.</p>
	 * <p>To use it, declare a &lt;KML /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxKML extends FxFeatureLayer
	{
		public function FxKML()
		{
			super();
		}

	    override public function init():void {
			this._layer = new KML("", "", null);
	    }
		
		public function set url(value:String):void {
			if(this._layer != null)
				(this._layer as KML).url = value;
		}

		public function set srs(value:String):void {
			if (this._layer != null) {
				this._layer.projSrsCode = value;
			}
		}
		
	}
}