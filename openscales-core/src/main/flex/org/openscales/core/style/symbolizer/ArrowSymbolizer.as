package org.openscales.core.style.symbolizer { 
	
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.basetypes.Location;
	
	public class ArrowSymbolizer extends Symbolizer{
		
		public static const POSITION_BEGINNING:int = 0;
		
		public static const POSITION_END:int = -1;
		
		private var _position:uint;
		
		public function ArrowSymbolizer(position:int){
			
			this._position = position;
		}
		
		
		/**
		 * Position of the arrow on the line
		 */
		public function get position():int{
			
			return this._position;
		}
		
		public function set position(value:int):void{
			
			this._position = value;
		}
	}
}