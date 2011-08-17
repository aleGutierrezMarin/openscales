package org.openscales.fx.layer
{
	import org.openscales.core.layer.Graticule;
	import org.openscales.core.style.Style;
	
	public class FxGraticule extends FxFeatureLayer
	{
		public function FxGraticule() 
		{
			super();
		}
		
		
		override public function init():void {
			var monStyle:Style = Style.getDefaultLineStyle();
			this._layer = new Graticule("Test graticule", monStyle);
		}
	}
}