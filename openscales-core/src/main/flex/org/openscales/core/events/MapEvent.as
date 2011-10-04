package org.openscales.core.events{
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	/**
	 * Event related to a map.
	 */
	public class MapEvent extends OpenScalesEvent {
		
		/**
		 * Map concerned by the event.
		 */
		private var _map:Map = null;
		
		/**
		 * new size of the map
		 */
		private var _newSize:Size = null;
		
		/**
		 * old zoom of the map
		 */
		private var _oldZoom:Number = 0;
		
		/**
		 * new zoom of the map
		 */
		private var _newZoom:Number = 0;
		
		/**
		 * old projection of the map
		 */
		private var _oldProjection:String = null;
		
		/**
		 * new projection of the map
		 */
		private var _newProjection:String = null;
		
		/**
		 * old center of the map
		 */
		private var _oldCenter:Location = null;
		
		/**
		 * new center of the map
		 */
		private var _newCenter:Location = null;
		
		/**
		 * old resolution of the map
		 */
		private var _oldResolution:Resolution = new Resolution(0, "EPSG:4326");
		
		/**
		 * new resolution of the map
		 */
		private var _newResolution:Resolution = new Resolution(0, "EPSG:4326");
		
		/**
		 * Target pixel to zoom
		 */
		private var _targetZoomPixel:Pixel = null;
			
		/**
		 * name of the component which has been changed
		 */
		private var _componentName:String = null;
		
		/**
		 * state of the component which has been changed
		 */
		private var _componentIconified:Boolean = false;
		
		/**
		 * old maxExtent of the map
		 */
		private var _oldMaxExtent:Bounds = null;
		
		/**
		 * new maxExtent of the map
		 */
		private var _newMaxExtent:Bounds = null;
		
		/**
		 * Event type dispatched before map move (drag or zoom).
		 */
		public static const MOVE_START:String="openscales.mapmovestart";
		
		/**
		 * Event type dispatched after map creation complete.
		 */
		public static const MAP_LOADED:String="openscales.maploaded";
		
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
		 * Event type dispatched when the projection of the map is changed
		 */
		public static const PROJECTION_CHANGED:String = "openscales.mapprojectionchanged";
		
		/**
		 * Event type dispatched when the resolution of the map has been changed.
		 */
		public static const RESOLUTION_CHANGED:String="openscales.mapresolutionchanged";
		
		/**
		 * Event type dispatched just before dragging the map.
		 */
		public static const DRAG_START:String="openscales.mapdragstart";
		
		/**
		 * Event type dispatched just after the map was dragged.
		 */
		public static const DRAG_END:String = "openscales.dragEnd";
		
		/**
		 * Event type dispatched during map resize.
		 */
		public static const RESIZE:String="openscales.mapresize";
		
		/**
		 * Event type dispatched when layers start loading
		 */
		public static const LAYERS_LOAD_START:String="openscales.layersloadstart";
		
		/**
		 * Event type dispatched when all map layers has dispatched load end
		 */
		public static const LAYERS_LOAD_END:String="openscales.layersloadend";
		
		/**
		 * Event type dispatched when the center of the map has been changed.
		 */
		public static const CENTER_CHANGED:String="openscales.mapcenterchanged";
		
		/**
		 * Event type dispatched when a component of the map is toggled or iconified.
		 */
		public static const COMPONENT_CHANGED:String="openscales.componentChanged";
		
		/**
		 * Event type dispatched when min or max map resolution changed
		 */
		public static const MIN_MAX_RESOLUTION_CHANGED:String="openscales.minMaxresolutionChanged";
		
		/**
		 * Event type dispatched when the map LayerContainer visibility is set to true
		 */
		public static const LAYERCONTAINER_IS_VISIBLE:String="openscales.layercontainerIsVisible";
		
		/**
		 * Event type dispatched when the map maxExtent is changed
		 */
		public static const MAX_EXTENT_CHANGED:String="openscales.maxextentchanged";
		
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
		
		/**
		 * newSize getter and setter
		 */
		public function get newSize():Size
		{
			return _newSize;
		}
		public function set newSize(value:Size):void
		{
			_newSize = value;
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
		
		public function set oldProjection(value:String):void
		{
			this._oldProjection = value;
		}
		
		public function get oldProjection():String
		{
			return this._oldProjection;
		}
		
		public function set newProjection(value:String):void
		{
			this._newProjection = value;
		}
		
		public function get newProjection():String
		{
			return this._newProjection;
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
		
		public function get oldResolution():Resolution
		{
			return  _oldResolution;
		}
		
		public function set oldResolution(value:Resolution):void
		{
			_oldResolution = value;
		}
		
		public function get newResolution():Resolution
		{
			return _newResolution;
		}
		
		public function set newResolution(value:Resolution):void
		{
			_newResolution = value;
		}
		
		public function get targetZoomPixel():Pixel
		{
			return this._targetZoomPixel;
		}
		
		public function set targetZoomPixel(value:Pixel):void
		{
			_targetZoomPixel = value;
		}
		
		public function get oldMaxExtent():Bounds
		{
			return this._oldMaxExtent;
		}
		
		public function set oldMaxExtent(value:Bounds):void
		{
			_oldMaxExtent = value;
		}
		
		public function get newMaxExtent():Bounds
		{
			return this._newMaxExtent;
		}
		
		public function set newMaxExtent(value:Bounds):void
		{
			_newMaxExtent = value;
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
		
		// getter and setter for the _componentIconified property
		public function set componentIconified(value:Boolean):void
		{
			this._componentIconified = value;
		}
		public function get componentIconified():Boolean
		{
			return this._componentIconified;
		}
		
		// getter and setter for the _componentName property
		public function set componentName(value:String):void
		{
			this._componentName = value;
		}
		public function get componentName():String
		{
			return this._componentName;
		}
	}
}

