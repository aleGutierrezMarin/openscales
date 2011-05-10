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
			if(this.layer != null)
				//((this.layer as WMS).params as WMSParams).layers = value;
				(this.layer as WMS).layers=value;
		}

		public function set styles(value:String):void {
			if(this.layer != null)
				//((this.layer as WMS).params as WMSParams).styles = value;
				(this.layer as WMS).style=value;
		}

		public function set format(value:String):void {
			if(this.layer != null)
				//((this.layer as WMS).params as WMSParams).format = value;
				(this.layer as WMS).format=value;
		}

		override public function set projection(value:String):void {
			super.projection = value;
			if(this.layer != null) {
				//((this.layer as WMS).params as WMSParams).srs = value;
				(this.layer as WMS).projection=value;
			}
		}

		public function set transparent(value:Boolean):void {
			if(this.layer != null)
				//((this.layer as WMS).params as WMSParams).transparent = value;
				(this.layer as WMS).transparent=value;
		}

		public function set bgcolor(value:String):void {
			if(this.layer != null)
				//((this.layer as WMS).params as WMSParams).bgcolor = value;
				(this.layer as WMS).bgcolor=value;
		}

		public function set tiled(value:Boolean):void {
			if(this.layer != null)
				//((this.layer as WMS).params as WMSParams).tiled = value;
				(this.layer as WMS).tiled=value;
		}

		public function set exceptions(value:String):void {
			if(this.layer != null)
				//((this.layer as WMS).params as WMSParams).exceptions = value;
				(this.layer as WMS).exception=value;
		}		
		
		public function set version(value:String):void{
			if(this.layer != null){
				(this.layer as WMS).version=value;
			}
		}
		
		override public function set url(value:String):void {
			if(this.layer != null)
				(this.layer as WMS).url=value;
		}
		
		public function set tHeight(value:Number):void{
			if(this.layer != null){
				(this.layer as WMS).tileHeight=value;
			}
		}
		
		public function get tHeight():Number{
			return (this.layer as WMS).tileHeight;
		}
		
		
		public function set tWidth(value:Number):void{
			if(this.layer != null){
				(this.layer as WMS).tileWidth = value;
			}
		}
		
		public function get tWidth():Number{
			return (this.layer as WMS).tileHeight;
		}
	}
}
