package org.openscales.core.basetypes
{
	import flash.events.Event;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class ResolutionTest
	{
		/**
		 * Precision for Number comparisons
		 */
		private const PRECISION:Number = 1e-7;
		
		/**
		 * Initial resolution of the map
		 */
		//private const INITIAL_RESOLUTION:Number = 0.3515625;
		private const INITIAL_RESOLUTION:Resolution = new Resolution(0.3515625);
		
		private var _map:Map;
		
		public function ResolutionTest() {}
		
		[Before]
		public function setUpMap():void{
			
			// Given a 100x100px map centered on 0,0 
			this._map = new Map();
			this._map.size = new Size(100,100);
			this._map.center = new Location(0,0,'EPSG:4326');
			
			// And that map has a layer (mandatory for correct pan behaviour)
			var layer:Layer = new Layer('Some layer');
			layer.projection = 'EPSG:4326';

			_map.addLayer(layer);
			
			// And that map is displayed at a resolution of 0.3515625°/px
			_map.resolution = INITIAL_RESOLUTION;
		}

	}
}