package org.openscales.core.style.fill {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.openscales.core.feature.Feature;

	/**
	 * Fill using a bitmap texture
	 */
	public class BitmapFill implements Fill {
		private var _bitmap:BitmapData;
		private var _matrix:Matrix;
		private var _repeat:Boolean;
		private var _smooth:Boolean;

		public function BitmapFill(bitmap:BitmapData, matrix:Matrix=null, repeat:Boolean=true, smooth:Boolean=false) {
			this._bitmap = bitmap;
			this._matrix = matrix;
			this._repeat = repeat;
			this._smooth = smooth;
		}

		/**
		 * The bitmap data used for the fill
		 */
		public function get bitmap():BitmapData {

			return this._bitmap;
		}

		public function set bitmap(value:BitmapData):void {

			this._bitmap = value;
		}

		/**
		 * The matrix for placing the bitmap
		 */
		public function get matrix():Matrix {

			return this._matrix;
		}

		public function set matrix(value:Matrix):void {

			this.matrix = value;
		}


		/**
		 * Whether the bitmap should be repeated
		 */
		public function get repeat():Boolean {

			return this._repeat;
		}

		public function set repeat(value:Boolean):void {

			this._repeat = value;
		}


		/**
		 * Whether the bitmap should be smoothed
		 */
		public function get smooth():Boolean {

			return this._smooth;
		}

		public function set smooth(value:Boolean):void {

			this._smooth = value;
		}

		public function configureGraphics(graphics:Graphics, feature:Feature):void {

			graphics.beginBitmapFill(this._bitmap, this._matrix, this._repeat, this._smooth);
		}

		public function clone():Fill
		{
			var bitmap:BitmapData = this._bitmap == null ? new BitmapData(0, 0) : this.bitmap.clone();
			var matrix:Matrix = this._matrix == null ? null : this._matrix.clone();
			return new BitmapFill(bitmap, matrix, this._repeat, this._smooth);
		}
	}
}