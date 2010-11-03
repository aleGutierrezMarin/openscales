package org.openscales.core.layer {
	
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.security.ISecurity;
	import org.openscales.core.security.events.SecurityEvent;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * A Layer displays raster (image) of vector datas on the map, usually loaded from a remote datasource.
	 * Unit of the baseLayer is managed by the projection.
	 * To access : ProjProjection.getProjProjection(layer.projSrsCode).projParams.units
	 *
	 * @author Bouiaw
	 */
	public class Layer extends Sprite {
		
		public static const DEFAULT_NOMINAL_RESOLUTION:Number = 1.40625;
		public static const RESOLUTION_TOLERANCE:Number = 0.000001;
		public static const DEFAULT_NUM_ZOOM_LEVELS:uint = 18;

		public static function get DEFAULT_MAXEXTENT():Bounds {
			return new Bounds("EPSG:4326", -180, -90, 180, 90);
		}

		private var _map:Map = null;
		private var _projection:ProjProjection = null;
		private var _resolutions:Array = null;
		private var _maxExtent:Bounds = null;
		private var _minResolution:Number = NaN;
		private var _maxResolution:Number = NaN;
		private var _proxy:String = null;
		private var _isFixed:Boolean = false;		
		private var _security:ISecurity = null;
		private var _loading:Boolean = false;
		private var _autoResolution:Boolean = true;
		protected var _imageSize:Size = null;
		private var _tweenOnZoom:Boolean = true;
		private var _tweenOnLoad:Boolean = true;

		/**
		 * Layer constructor
		 */
		public function Layer(name:String) {
			this.name = name;
			this.visible = true;
			this.doubleClickEnabled = true;
			this.projSrsCode = Geometry.DEFAULT_SRS_CODE;
			this.generateResolutions();
		}

		/**
		 * Generate resolutions array for a nominal resolution (higher one) and a number of zoom levels. 
		 * The array is generated with the following principle : resolutions[i] = resolutions[i-1] / 2
		 */
		public function generateResolutions(numZoomLevels:uint=Layer.DEFAULT_NUM_ZOOM_LEVELS, nominalResolution:Number=NaN):void {

			if (isNaN(nominalResolution)) {
				if (this.projSrsCode == Geometry.DEFAULT_SRS_CODE) {
					nominalResolution = Layer.DEFAULT_NOMINAL_RESOLUTION;
				} else {
					nominalResolution = Proj4as.unit_transform(Geometry.DEFAULT_SRS_CODE, this.projSrsCode, Layer.DEFAULT_NOMINAL_RESOLUTION);
				}
			}
			// numZoomLevels must be strictly greater than zero
			if (numZoomLevels == 0) {
				numZoomLevels = 1;
			}
			// Generate default resolutions
			this._resolutions = new Array();
			this._resolutions.push(nominalResolution);
			var i:int = 1;
			for (i; i < numZoomLevels; ++i) {
				this._resolutions.push(this.resolutions[i - 1] / 2);
			}
			this._resolutions.sort(Array.NUMERIC | Array.DESCENDING);

			this._autoResolution = true;
		}

		/**
		 * Detroy the map, including removing all event listeners
		 */
		public function destroy():void {
			this.removeEventListenerFromMap();
			this.map = null;
		}

		/**
		 * Remove map related event listeners
		 */
		public function removeEventListenerFromMap():void {
			if (this.map != null) {
				map.removeEventListener(SecurityEvent.SECURITY_INITIALIZED, onSecurityInitialized);
				map.removeEventListener(MapEvent.MOVE_END, onMapMove);
				map.removeEventListener(MapEvent.RESIZE, onMapResize);
			}
		}

		protected function onMapResize(e:MapEvent):void {
			if(this.visible) {
				this.redraw();
			}
		}

		/**
		 * Set the map where this layer is attached.
		 * Here we take care to bring over any of the necessary default properties from the map.
		 */
		public function set map(map:Map):void {
			if (this.map != null) {
				removeEventListenerFromMap();
			}

			this._map = map;

			if (this.map) {
				this.map.addEventListener(SecurityEvent.SECURITY_INITIALIZED, onSecurityInitialized);
				this.map.addEventListener(MapEvent.MOVE_END, onMapMove);
				this.map.addEventListener(MapEvent.RESIZE, onMapResize);
				if (! this.maxExtent) {
					this.maxExtent = this.map.maxExtent;
				}
			}
		}
		
		protected function onSecurityInitialized(e:SecurityEvent):void {
			this.redraw();
		}

		protected function onMapMove(e:MapEvent):void {
			this.redraw(e.zoomChanged);
		}

		/**
		 * Return a reference to the map where belong this layer
		 */
		public function get map():Map {
			return this._map;
		}

		/**
		 * A Bounds object which represents the location bounds of the current extent display on the map.
		 */
		public function get extent():Bounds {
			return this.map.extent;
		}

		/**
		 * Return the closest zoom level match the extent passed as parameter
		 */
		public function getZoomForExtent(extent:Bounds):Number {
			var viewSize:Size = this.map.size;
			var idealResolution:Number = Math.max(extent.width / viewSize.w, extent.height / viewSize.h);
			return this.getZoomForResolution(idealResolution);
		}

		/**
		 * Return The index of the zoomLevel (entry in the resolutions array)
		 * that corresponds to the best fit resolution given the passed in
		 * value and the 'closest' specification.
		 */
		public function getZoomForResolution(resolution:Number):Number {
			if(resolution > this.resolutions[0]) {
				return 0;
			}
			if(resolution < this.resolutions[this.resolutions.length - 1]) {
				return this.resolutions.length - 1;
			}
			var i:int = 1;
			var j:int = this.resolutions.length - 1;
			for (i; i < j; ++i) {
				if ((this.resolutions[i] < resolution) && (Math.abs(this.resolutions[i] - resolution) > RESOLUTION_TOLERANCE)) {
					break;
				}
			}
			return i - 1;
		}

		/**
		 * Return a LonLat which is the passed-in map Pixel, translated into
		 * lon/lat by the layer.
		 */
		public function getLocationFromMapPx(viewPortPx:Pixel):Location {
			var lonlat:Location = null;
			if (viewPortPx != null) {
				var size:Size = this.map.size;
				var center:Location = this.map.center;
				if (center) {
					var res:Number = this.map.resolution;
					var delta_x:Number = viewPortPx.x - (size.w / 2);
					var delta_y:Number = viewPortPx.y - (size.h / 2);
					lonlat = new Location(this.projSrsCode, center.lon + delta_x * res, center.lat - delta_y * res);
				}
			}
			return lonlat;
		}

		/**
		 * Return a Pixel which is the passed-in LonLat,translated into map pixels.
		 */
		public function getMapPxFromLocation(lonlat:Location):Pixel {
			var px:Pixel = null;
			if (lonlat != null) {
				var resolution:Number = this.map.resolution;
				var extent:Bounds = this.map.extent;
				px = new Pixel(Math.round((lonlat.lon - extent.left) / resolution), Math.round((extent.top - lonlat.lat) / resolution));
			}
			return px;
		}

		/**
		 * Clear the layer graphics
		 */
		public function clear():void {
			
		}

		/**
		 * Reset layer data
		 */
		public function reset():void {
		}

		/**
		 * Reset layer data
		 */
		protected function draw():void {
			// nothing to do for a generic layer
		}

		/**
		 * Is this layer currently displayed ?
		 */
		public function get displayed():Boolean {
			return this.visible && this.inRange && this.extent;
		}	

		/**
		 * Clear and draw, if needed, layer based on current data eventually retreived previously by moveTo function.
		 * 
		 * @param fullRedraw boolean forece the redraw
		 */
		public function redraw(fullRedraw:Boolean = true):void {
			this.clear();
			if (this.displayed) {
				this.draw();
			}
		}

		/**
		 * Is this layer currently in range, based on its min and max resolutions
		 */
		public  function get inRange():Boolean {
	    	var inRange:Boolean = false;
			if (this.map) {
		    	var resolutionProjected:Number = this.map.resolution;
			    if (this.isBaseLayer != true && this.projSrsCode != this.map.baseLayer.projSrsCode) {
					resolutionProjected = Proj4as.unit_transform(this.map.baseLayer.projSrsCode,this.projSrsCode,this.map.resolution);
				}
	    		inRange = ((resolutionProjected >= this.minResolution) && (resolutionProjected <= this.maxResolution));
			}
	    	return inRange;
		}

		/**
		 * Return layer URL
		 */
		public function getURL(bounds:Bounds):String {
			return null;
		}

		/**
		 * For layers with a gutter, the image is larger than
		 * the tile by twice the gutter in each dimension.
		 */
		public function get imageSize():Size {
			return this._imageSize;
		}

		public function set imageSize(value:Size):void {
			this._imageSize = value;
		}

		/**
		 * Current layer position in the display list
		 */
		public function get zindex():int {
			return this.parent.getChildIndex(this);
		}

		public function set zindex(value:int):void {
			this.parent.setChildIndex(this, value);
		}
		
		/**
		 * Minimal valid resolution for this layer
		 */
		public function get minResolution():Number {
			var minRes:Number = this._minResolution;;
			if (isNaN(minRes) && this.resolutions && (this.resolutions.length > 0)) {
				minRes = this.resolutions[this.resolutions.length - 1];
			}
			return minRes;
		}
		
		public function set minResolution(value:Number):void {
			this._minResolution = value;
		}
		
		/**
		 * Maximal valid resolution for this layer
		 */
		public function get maxResolution():Number {
			var maxRes:Number = this._maxResolution;
			
			if (isNaN(maxRes) &&  this.resolutions && (this.resolutions.length > 0)) {
				maxRes = this.resolutions[0];
			}
			return maxRes;
		}
		
		public function set maxResolution(value:Number):void {
			this._maxResolution = value;
		}

		/**
		 * Return the minimum zoom level allowed, based on map max resolution
		 */
		public function get minZoomLevel():Number {
			if(isNaN(this._maxResolution))
				return 0;
			else
				return getZoomForResolution(this._maxResolution);
		}
		
		public function set minZoomLevel(value:Number):void {
			if ((value >= 0) && (value < this.resolutions.length)) {
				this._maxResolution = this.resolutions[value];
			} else {
				Trace.error("Layer: invalid maxZoomLevel for the layer " + this.name + ": " + value + " is not in [0;" + (this.resolutions.length - 1) + "]");
			}
		}
		
		/**
		 * Return the mamximum zoom level allowed, based on map min resolution
		 */
		public function get maxZoomLevel():Number {
			if (isNaN(this._minResolution)) {
				return this.resolutions.length - 1;
			} else {
				return getZoomForResolution(this._minResolution);
			}
		}
		
		public function set maxZoomLevel(value:Number):void {
			if ((value >= 0) && (value < this.resolutions.length)) {
				this._minResolution = this.resolutions[value];
			} else {
				Trace.error("Layer: invalid maxZoomLevel for the layer " + this.name + ": " + value + " is not in [0;" + (this.resolutions.length - 1) + "]");
			}
		}
		
		/**
		 * Number of zoom levels (resolutions array length)
		 */
		public function get numZoomLevels():Number {
			return this.resolutions.length;
		}
		
		/**
		 * Maximum extent for this layer. No data outside the extent will be displayed
		 */
		public function get maxExtent():Bounds {
			return this._maxExtent;
		}
		
		public function set maxExtent(value:Bounds):void {
			this._maxExtent = value;
		}
		
		/**
		 * A list of map resolutions (map units per pixel) in descending
		 * order. If this is not set in the layer constructor, it will be set
		 * based on other resolution related properties (maxExtent, maxResolution, etc.).
		 */
		public function get resolutions():Array {
			return this._resolutions;
		}
		
		public function set resolutions(value:Array):void {
			this._resolutions = value;
			if (this._resolutions == null || this._resolutions.length == 0) {
				this.generateResolutions();
			} else {
				this._autoResolution = false;
			}
			this._resolutions.sort(Array.NUMERIC | Array.DESCENDING);
		}
		
		/**
		 * Define the layer projection by its SRS code.
		 * When this layer is the baselayer, the associated projection is used as the map display projection.
		 * When this layer is not the baselayer, it is used to perform the right repojection algorithm.
		 */
		public function get projSrsCode():String {
			return (this._projection==null) ? null : this._projection.srsCode;
		}
		
		public function set projSrsCode(value:String):void {
			this._projection = ProjProjection.getProjProjection(value);
			if (this._autoResolution) {
				this.generateResolutions();
			}
		}
		
		/**
		 * Whether or not this layer is a baselayer.
		 */
		public function get isBaseLayer():Boolean {
			if ((! this._map) || (! this._map.baseLayer)) {
				return false;
			}
			return (this.map.baseLayer == this);
		}
		
		/**
		 * Whether or not the layer is a fixed layer.
		 * Fixed layers cannot be controlled by users
		 */
		public function get isFixed():Boolean {
			return this._isFixed;
		}
		
		public function set isFixed(value:Boolean):void {
			this._isFixed = value;
		}
		
		/**
		 * Proxy (usually a PHP, Python, or Java script) used to request remote servers like
		 * WFS servers in order to allow crossdomain requests. Remote servers can be used without
		 * proxy script by using crossdomain.xml file like http://openscales.org/crossdomain.xml
		 *
		 * There is 3 cases :
		 *  - proxy is explicitly defined
  		 *  - proxy is explicitly defined to "" => no proxy will be used
  		 *  - proxy is null => use the proxy of the map
		 */
		public function get proxy():String {
			if (this._proxy == null && map && map.proxy) {
				return map.proxy;
			}
			return this._proxy;
		}
		
		public function set proxy(value:String):void {
			this._proxy = value;
		}
		
		/**
		 * Security manager associated to this layer
		 */
		public function get security():ISecurity {
			return this._security;
		}
		
		public function set security(value:ISecurity):void {
			this._security = value;
		}
		
		/**
		 * Define if this layer is visible (displayed) or not
		 */
		public override function set visible(value:Boolean):void {
			super.visible = value;
			if (this.map != null) {
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_VISIBLE_CHANGED, this));
			}
		}
		
		/**
		 * Whether or not the layer is loading data
		 */
		public function get loadComplete():Boolean {
			return (! this._loading);
		}
		
		/**
		 * Used to set loading status of layer
		 */
		protected function set loading(value:Boolean):void {
			if (value == true && this._loading == false && this.map != null) {
				_loading = value;
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_LOAD_START, this));
			}

			if (value == false && this._loading == true && this.map != null) {
				_loading = value;
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_LOAD_END, this));
			}
		}
		
		/**
		 * Define if the layer is displayed during tween zoom effect. This can be used to hide Point
		 * layers if order to avoid bad looking effects when zooming a layer with a lot of points.
		 */
		public function get tweenOnZoom():Boolean {
			return _tweenOnZoom;
		}
		
		public function set tweenOnZoom(value:Boolean):void {
			_tweenOnZoom = value;
		}
		
		/**
		 * Define if a tween effect should be used when loading a new data.
		 * Currently, only implemented for image tile, but may be used widely in the future
		 */
		public function get tweenOnLoad():Boolean {
			return _tweenOnLoad;
		}
		
		public function set tweenOnLoad(value:Boolean):void {
			_tweenOnLoad = value;
		}
		
	}
}

