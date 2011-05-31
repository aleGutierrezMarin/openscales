package org.openscales.fx.layer
{
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.core.layer.TMS;
	
	/**
	 * Abstract TMS Flex wrapper
	 */
	public class FxTMS extends FxGrid
	{
		public function FxTMS()
		{
			super();
			if(this._layer == null)
				this._layer = new TMS("","");
		}
		public function set format(value:String):void {
			if(this._layer != null)
				(this._layer as TMS).format = value;
		}
		public function set origin(value:String):void {
			if(this._layer != null) {
				(this._layer as TMS).origin = Location.getLocationFromString(value);
			}
		}
		
		public function set layerName(value:String):void {
			if(this._layer != null) {
				(this._layer as TMS).layerName = value;
			}
		}
	}
}