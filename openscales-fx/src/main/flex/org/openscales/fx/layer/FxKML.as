package org.openscales.fx.layer
{
	import org.openscales.core.layer.KML;

	/**
	 * <p>KML Flex wrapper.</p>
	 * <p>To use it, declare a &lt;KML /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxKML extends FxVectorLayer
	{
		public function FxKML()
		{
			super();
		}

	    override public function init():void {
			this._layer = new KML("", "", null);
	    }
		
		/**
		 * Getters and setters 
		 */
		
		override public function get name():String
		{
			if(this._layer != null)
				return this._layer.name;
			return null;
		}
		
		override public function set name(value:String):void
		{
			if(this._layer != null)
				(this._layer as KML).name = value;
		}
		
		public function get url():String
		{
			if(this._layer != null)
				return this._layer.url;
			return null;
		}
		
		public function set url(value:String):void {
			if(this._layer != null)
				(this._layer as KML).url = value;
		}

		public function set srs(value:String):void {
			if (this._layer != null) {
				this._layer.projection = value;
			}
		}
		
	}
}