package org.openscales.fx.layer
{
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.params.ogc.WMSParams;

	/**
	 * <p>WMS Flex wrapper</p>
	 * <p>To use it, declare a &lt;WMS /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxWMS extends FxGrid
	{
		public function FxWMS() {
			super();
		}

		override public function init():void {
			this._layer = new WMS();
		}

		public function set layers(value:String):void {
			if(this._layer != null)
				//((this.layer as WMS).params as WMSParams).layers = value;
				(this._layer as WMS).layers=value;
		}

		public function set styles(value:String):void {
			if(this._layer != null)
				//((this.layer as WMS).params as WMSParams).styles = value;
				(this._layer as WMS).style=value;
		}

		public function set format(value:String):void {
			if(this._layer != null)
				//((this.layer as WMS).params as WMSParams).format = value;
				(this._layer as WMS).format=value;
		}

		override public function set projection(value:String):void {
			super.projection = value;
			if(this._layer != null) {
				//((this.layer as WMS).params as WMSParams).srs = value;
				(this._layer as WMS).projection=value;
			}
		}

		public function set transparent(value:Boolean):void {
			if(this._layer != null)
				//((this.layer as WMS).params as WMSParams).transparent = value;
				(this._layer as WMS).transparent=value;
		}

		public function set bgcolor(value:String):void {
			if(this._layer != null)
				//((this.layer as WMS).params as WMSParams).bgcolor = value;
				(this._layer as WMS).bgcolor=value;
		}

		override public function set tiled(value:Boolean):void {
			if(this._layer != null)
				//((this.layer as WMS).params as WMSParams).tiled = value;
				(this._layer as WMS).tiled=value;
		}

		public function set exceptions(value:String):void {
			if(this._layer != null)
				//((this.layer as WMS).params as WMSParams).exceptions = value;
				(this._layer as WMS).exceptions=value;
		}		
		
		public function set version(value:String):void{
			if(this._layer != null){
				(this._layer as WMS).version=value;
			}
		}
		
		override public function set url(value:String):void {
			if(this._layer != null)
				(this._layer as WMS).url=value;
		}
		
		/**
		 * The height of the tiles requested.
		 * If the layer is not in tiled mode, the value of tHeight 
		 * is the height of the map or NaN if the layer is not in a map
		 */
		public function set tHeight(value:Number):void{
			if(this._layer != null){
				(this._layer as WMS).tileHeight=value;
			}
		}
		/**
		 * @private
		 */
		public function get tHeight():Number{
			return (this._layer as WMS).tileHeight;
		}
		
		/**
		 * The width of the tiles requested.
		 * If the layer is not in tiled mode, the value of tWidth 
		 * is the width of the map or NaN if the layer is not in a map
		 */
		public function set tWidth(value:Number):void{
			if(this._layer != null){
				(this._layer as WMS).tileWidth = value;
			}
		}
		
		/**
		 * @private
		 */
		public function get tWidth():Number{
			return (this._layer as WMS).tileHeight;
		}
	}
}
