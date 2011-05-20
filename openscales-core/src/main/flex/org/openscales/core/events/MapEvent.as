package org.openscales.core.events{

	import org.openscales.core.Map;
	import org.openscales.geometry.basetypes.Location;

	/**
	 * Event related to a map.
	 */
	public class MapEvent extends OpenScalesEvent {

		/**
		 * Map concerned by the event.
		 */
		private var _map:Map = null;
		
		/**
		 * old zoom of the map
		 */
		 private var _oldZoom:Number = 0;
		 
		 /**
		  * old zoom of the map
		  */
		 private var _newZoom:Number = 0;
		 
		 /**
		  * old center of the map
		  */
		 private var _oldCenter:Location = null;

		 /**
		  * old center of the map
		  */
		 private var _newCenter:Location = null;
		 
		/**
		 * Event type dispatched before map move (drag or zoom).
		 */
		public static const MOVE_START:String="openscales.mapmovestart";

		/**
		 * Event type dispatched after map move if the center and/or zoom has changed.
		 * There is no DRAG_END since a MOVE_END event is emitted if the center has finally changed
		 */
		public static const MOVE_END:String="openscales.mapmoveend";

		/**
		 * Event type dispatched when the map didn't move after a move_start or a drag_start
		 */
		public static const MOVE_NO_MOVE:String="openscales.mapnomove";
		
		/**
		 * Event type dispatched just before dragging the map.
		 */
		public static const DRAG_START:String="openscales.mapdragstart";
		
		/**
 		 * Event type dispatched during map resize.
		 */
		public static const RESIZE:String="openscales.mapresize";
		
		/**
 		 * Event type dispatched during map resize.
 		 * Cannot use namingconvention with dot "." here because name is used in mxml
		 */
		public static const LOAD_START:String="openscales.maploadstart";
		
		/**
 		 * Event type dispatched when map has been loaded completely.
 		 * Cannot use namingconvention with dot "." here because name is used in mxml
		 */
		public static const LOAD_END:String="openscales.maploadend";
		
		
		/**
		 * Event type dispatched when zoom of the map has been changed.
		 * Cannot use namingconvention with dot "." here because name is used in mxml
		 */
		public static const ZOOM_CHANGED:String="openscales.mapzoomchanged";
		
		/**
		 * Event type dispatched when center of the map has been changed.
		 * Cannot use namingconvention with dot "." here because name is used in mxml
		 */
		public static const CENTER_CHANGED:String="openscales.mapcenterchanged";

		/**
		 * Instances of MapEvent are events dispatched by the Map
		 */
		public function MapEvent(type:String, map:Map, bubbles:Boolean = false, cancelable:Boolean = false){
			this._map = map;
			super(type, bubbles, cancelable);
		}

		public function get map():Map {
			return this._map;
		}

		public function set map(map:Map):void {
			this._map = map;	
		}
		
		public function get oldZoom():Number {
			return this._oldZoom;
		}

		public function set oldZoom(value:Number):void {
			this._oldZoom = value;	
		}
		
		public function get newZoom():Number {
			return this._newZoom;
		}

		public function set newZoom(value:Number):void {
			this._newZoom = value;	
		}
		
		public function get newCenter():Location
		{
			return _newCenter;
		}
		
		public function set newCenter(value:Location):void
		{
			_newCenter = value;
		}
		
		public function get oldCenter():Location
		{
			return _oldCenter;
		}
		
		public function set oldCenter(value:Location):void
		{
			_oldCenter = value;
		}
		
		public function get zoomChanged():Boolean {
			if(this._newZoom != this._oldZoom)
				return true;
			return false;
		}
		
		public function get centerChanged():Boolean {
			if(this._newCenter != this._oldCenter)
				return true;
			return false;
		}
	}
}

