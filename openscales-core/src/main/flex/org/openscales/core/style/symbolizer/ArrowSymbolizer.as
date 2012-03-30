package org.openscales.core.style.symbolizer
{
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.stroke.Stroke;
	
	public class ArrowSymbolizer extends LineSymbolizer
	{
		
		/**
		 * The marker that will be drawn at the left side of the line
		 */
		private var _leftMarker:Marker;
		
		/**
		 * The marker that will be drawn at the right side of the line
		 */
		private var _rightMarker:Marker;
		
		public function ArrowSymbolizer(stroke:Stroke=null, leftMarker:Marker = null, rigthMarker:Marker = null)
		{
			this._leftMarker = leftMarker;
			this._rightMarker = rigthMarker;
			super(stroke);
		}
		
		/**
		 * The marker that will be drawn at the left side of the line
		 * If you want your arrow in the continuity of the line be sure that 
		 * the marker has the sharp part of the arrow oriented to the top
		 */
		public function get leftMarker():Marker
		{
			return this._leftMarker;
		}
		
		/**
		 * @private
		 */
		public function set leftMarker(value:Marker):void
		{
			this._leftMarker = value;
		}
		
		/**
		 * The marker that will be drawn at the right side of the line
		 * If you want your arrow in the continuity of the line be sure that 
		 * the marker has the sharp part of the arrow oriented to the top
		 */
		public function get rightMarker(): Marker
		{
			return this._rightMarker;
		}
		
		/**
		 * @private
		 */
		public function set rightMarker(value:Marker):void
		{
			this._rightMarker = value;
		}
	}
}