package org.openscales.core.style.fill {
	import flash.display.Graphics;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.filter.expression.IExpression;

	/**
	 * Class defining a solid fill, which is characterized by its color and opacity
	 */
	public class SolidFill implements Fill {
		private var _color:Object;

		private var _opacity:Number;

		public function SolidFill(color:uint=0xffffff, opacity:Number=1) {
			this.color = color;
			this.opacity = opacity;
		}

		/**
		 * The color of the fill. Color may be either a uint or a IExpression
		 */
		public function get color():Object {

			return this._color;
		}

		public function set color(value:Object):void {

			if (!(value is uint || value is IExpression)) {

				throw ArgumentError("color attribute must be either a uint or a IExpression");
			}

			this._color = value;
		}

		/**
		 * The opacity of the fill
		 */
		public function get opacity():Number {

			return this._opacity;
		}

		public function set opacity(value:Number):void {

			this._opacity = value;
		}

		public function configureGraphics(graphics:Graphics, feature:Feature):void {

			var color:uint;
			if (this._color is uint) {

				color = this._color as uint;
			} else {

				color = (this._color as IExpression).evaluate(feature) as uint;
			}

			graphics.beginFill(color, this._opacity);
		}

		public function clone():Fill
		{
			var cloneSolidFill:SolidFill = new SolidFill(0xffffff, this._opacity);
			cloneSolidFill.color = this._color;
			return cloneSolidFill;
		}
	}
}