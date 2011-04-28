package org.openscales.core.control
{
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * Display an overview linked with the map.
	 * The map and the overview resolutions are linked with a ratio.
	 * This ratio will be kept when you zoom on the map.
	 * The overview map is a single layer
	 * 
	 * @author Viry Maxime
	 * 
	 */	
	public class OverviewMapRatio extends Control
	{
		
		/**
		 * @private
		 * Current map of the overvew
		 */
		private var _overviewMap:Map;
		
		/**
		 * @private
		 * Ratio between the overview resolution and the map resolution
		 * The ratio is MapResolution/OverviewMapResolution
		 */
		private var _ratio:Number;
		
		/**
		 * Constructor of the overview map
		 * 
		 * @param position Position of the overview map
		 * 
		 */
		public function OverviewMapRatio(position:Pixel = null)
		{
		}
		
		/**
		 * The curent layer of the overview map
		 * 
		 * @param layer The layer of the overview
		 * 
		 */
		public function set layer(layer:Layer):void
		{
			
		}
		
		/**
		 * 
		 * @private
		 */
		public function get layer():Layer
		{
			return null;
		}
		
		/**
		 * Ratio between the overview resolution and the map resolution
		 * The ratio is MapResolution/OverviewMapResolution
		 * 
		 * @param The curent ratio between the overview map and the map
		 */
		public function set ratio(ratio:Number):void
		{
			
		}
	}
}