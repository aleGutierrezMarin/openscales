package org.openscales.core.style.symbolizer
{
	import org.openscales.core.style.Style;
	import org.openscales.core.style.graphic.Graphic;
	import org.openscales.core.style.stroke.Stroke;
	
	public class ArrowSymbolizer extends LineSymbolizer
	{
		
		/**
		 * The Style that will be drawn at the left side of the line
		 */
		private var _leftGraphic:Graphic;
		
		/**
		 * The Style that will be drawn at the right side of the line
		 */
		private var _rightGraphic:Graphic;
		
		public function ArrowSymbolizer(stroke:Stroke=null, leftGraphic:Graphic = null, rigthGraphic:Graphic = null)
		{
			this._leftGraphic = leftGraphic;
			this._rightGraphic = rigthGraphic;
			super(stroke);
		}
		
		/**
		 * The Style that will be drawn at the left side of the line
		 * If you want your arrow in the continuity of the line be sure that 
		 * the Style has the sharp part of the arrow oriented to the top
		 */
		public function get leftGraphic():Graphic
		{
			return this._leftGraphic;
		}
		
		/**
		 * @private
		 */
		public function set leftGraphic(value:Graphic):void
		{
			this._leftGraphic = value;
		}
		
		/**
		 * The Style that will be drawn at the right side of the line
		 * If you want your arrow in the continuity of the line be sure that 
		 * the Style has the sharp part of the arrow oriented to the top
		 */
		public function get rightGraphic(): Graphic
		{
			return this._rightGraphic;
		}
		
		/**
		 * @private
		 */
		public function set rightGraphic(value:Graphic):void
		{
			this._rightGraphic = value;
		}
		
		override public function clone():Symbolizer{
			var leftGraphic:Graphic;
			var rightGraphic:Graphic;
			if (this.leftGraphic)
			{
				leftGraphic = this.leftGraphic.clone();	
			}
			if (this.rightGraphic)
			{
				rightGraphic = this.rightGraphic.clone();
			}
			var arrowSymb:ArrowSymbolizer = new ArrowSymbolizer(this.stroke.clone(), leftGraphic,rightGraphic);
			arrowSymb.geometry = this.geometry;
			return arrowSymb;
		}
	}
}