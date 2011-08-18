package org.openscales.fx.layer
{
	import org.openscales.core.layer.Graticule;
	import org.openscales.core.style.Style;
	
	public class FxGraticule extends FxFeatureLayer
	{
		/**
		 * Default constructor.
		 */
		public function FxGraticule() {
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			this._layer = new Graticule("", null);
		}
		
		/**
		 * @return Array of possible graticule widths in degrees, from biggest to smallest.
		 */
		public function get intervals():Array
		{
			return (this._layer as Graticule).intervals;
		}
		
		/**
		 * @param value Array of possible graticule widths in degrees, from biggest to smallest.
		 */
		public function set intervals(value:Array):void
		{
			(this._layer as Graticule).intervals = value;
		}
		
		/**
		 * @return Minimum number of lines to display for the graticule.
		 */
		public function get minNumberOfLines():uint
		{
			return (this._layer as Graticule).minNumberOfLines;
		}
		
		/**
		 * @param value Minimum number of lines to display for the graticule.
		 */
		public function set minNumberOfLines(value:uint):void
		{
			(this._layer as Graticule).minNumberOfLines = value;
		}
	}
}