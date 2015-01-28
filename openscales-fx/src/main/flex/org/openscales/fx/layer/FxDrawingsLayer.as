package org.openscales.fx.layer
{
	import org.openscales.core.layer.DrawingsLayer;

	public class FxDrawingsLayer extends FxVectorLayer
	{
		public function FxDrawingsLayer()
		{
			super();
		}
		
		override public function init():void {
			this._layer = new DrawingsLayer(this._identifier);
		}
	}
}