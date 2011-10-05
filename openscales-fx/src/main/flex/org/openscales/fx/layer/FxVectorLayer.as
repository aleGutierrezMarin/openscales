package org.openscales.fx.layer
{
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	
	/**
	 * <p>FeatureLayer Flex wrapper.</p>
	 * <p>To use it, declare a &lt;FeatureLayer /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxVectorLayer extends FxLayer
	{
		public function FxVectorLayer() {
			super();
		}
		
		override public function init():void {
			this._layer = new VectorLayer("");
		}
		
		public function get style():Style{
			return (this._layer as VectorLayer).style;
		}
		
		public function set style(value:Style):void{
			if (this._layer) {
				(this._layer as VectorLayer).style = value; 
			}
		}
		
	}		
}