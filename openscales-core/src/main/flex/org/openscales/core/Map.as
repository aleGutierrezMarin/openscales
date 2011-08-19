package org.openscales.core
{
	
	import com.adobe.serialization.json.JSON;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Cubic;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import mx.events.DragEvent;
	
	import org.hamcrest.core.throws;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.configuration.IConfiguration;
	import org.openscales.core.control.IControl;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.handler.feature.DragFeatureHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.i18n.Locale;
	import org.openscales.core.i18n.provider.I18nJSONProvider;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.popup.Popup;
	import org.openscales.core.security.ISecurity;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Instances of Map are interactive maps that can be embedded in a web pages or in
	 * Flex or AIR applications.
	 *
	 * Create a new map with the Map constructor.
	 *
	 * To extend a map, it's necessary to add controls (Control), handlers (Handler) and
	 * layers (Layer) to the map.
	 *
	 * Map is a pure ActionScript class. Flex wrapper and components can be found in the
	 * openscales-fx module.
	 */
	public class Map extends Sprite
	{
		
		/**
		 * Draw a debug shape on the map representig the maxExtent
		 */
		public static const DEBUG_MAX_EXTENT:Boolean = true;
		
		/**
		 * Default SRS Code of the Map
		 */
		public static const DEFAULT_SRS_CODE:String = "EPSG:4326";
		
		/**
		 * Default Resolution of the map. The projection of the resolution is the DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_RESOLUTION:Resolution = new Resolution(1, DEFAULT_SRS_CODE);
		
		/**
		 * Default MaxExtent of the map. The projection of the maxExtent is the DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_MAX_EXTENT:Bounds = new Bounds(-180, -90, 180, 90, DEFAULT_SRS_CODE);
		
		/**
		 * Default Center of the map. The projection of the center is the DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_CENTER:Location = new Location(0, 0, DEFAULT_SRS_CODE);
		
		/**
		 * Default Min Resolution of the map. The projection of the min resolution is the DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_MIN_RESOLUTION:Resolution = new Resolution(0, DEFAULT_SRS_CODE);
		
		/**
		 * Default Max Resolution of the map. The projection of the max resolution is the DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_MAX_RESOLUTION:Resolution = new Resolution(1.5, DEFAULT_SRS_CODE);
		
		/**
		 * Number of attempt for downloading an image tile
		 */
		public var IMAGE_RELOAD_ATTEMPTS:Number = 0;
		
		/**
		 * The url to the default Theme (OpenscalesTheme)
		 * TODO : fix and set the real path to  the default theme
		 */
		public var URL_THEME:String = "http://openscales.org/nexus/service/local/repo_groups/public-snapshots/content/org/openscales/openscales-fx-theme/2.0.0-SNAPSHOT/openscales-fx-theme-2.0.0-20110517.142043-5.swf";
		
		private var _baseLayer:Layer = null;
		//private var _layerContainer:Sprite = null;
		private var _controls:Vector.<IHandler> = new Vector.<IHandler>();
		private var _size:Size = null;
		protected var _zoom:Number = 0;
		private var _zooming:Boolean = false;
		private var _dragging:Boolean = false;
		private var _loading:Boolean;
		protected var _center:Location = DEFAULT_CENTER;
		private var _maxExtent:Bounds = DEFAULT_MAX_EXTENT;
		private var _destroying:Boolean = false;
		private var _tweenZoomEnabled:Boolean = true;
		
		private var _proxy:String = null;
		private var _bitmapTransition:Sprite;
		private var _configuration:IConfiguration;
		
		private var _securities:Vector.<ISecurity>=new Vector.<ISecurity>();
		
		private var _cptGTween:uint = 0;
		
		private var _projection:String = DEFAULT_SRS_CODE;
		
		private var _resolution:Resolution = DEFAULT_RESOLUTION;
		
		private var _defaultZoomInFactor:Number = 0.9;
		private var _defaultZoomOutFactor:Number = 1.1;
		
		private var _targetZoomPixel:Pixel = null;
		
		private var _centerShape:Shape;
		
		private var _extenTDebug:Shape;

		/**
		 * @private
		 * The minimum resolution of the map
		 * @default 0 in EPSG:4326
		 */
		private var _minResolution:Resolution = DEFAULT_MIN_RESOLUTION;
		
		/**
		 * @private
		 * The maximum resolution of the map
		 * @default 1.5 in EPSG:4326
		 */
		private var _maxResolution:Resolution = DEFAULT_MAX_RESOLUTION;
		
		/**
		 * The location where the layer container was re-initialized (on-zoom)
		 */
		//private var _layerContainerOrigin:Location = null;
		
		//Source file for i18n english translation
		[Embed(source="/assets/i18n/EN.json", mimeType="application/octet-stream")]
		private const ENLocale:Class;
		[Embed(source="/assets/i18n/FR.json", mimeType="application/octet-stream")]
		private const FRLocale:Class;

		/** 
		 * @private
		 * Url to the theme used to custom the components of the current map
		 * @default URL_THEME (url to the basic OpenscalesTheme)
		 */
		private var _theme:String = URL_THEME;
		
		/**
		 * Map constructor
		 *
		 * @param width the map's width in pixels
		 * @param height the map's height in pixels
		 * @param projection the map's projection
		 */
		public function Map(width:Number=600, height:Number=400, projection:String="EPSG:4326") {
			super();
			
			//load i18n module
			I18nJSONProvider.addTranslation(ENLocale);
			I18nJSONProvider.addTranslation(FRLocale);
			
			this._projection = projection;
			this.size = new Size(width, height);
			//this._layerContainer = new Sprite();
			// It is necessary to draw something before to define the size...
			this.graphics.beginFill(0xFFFFFF,0);
			this.graphics.drawRect(0,0,this.size.w,this.size.h);
			this.graphics.endFill();
			// ... and then the size may be defined.
			this.width = this.size.w;
			this.height = this.size.h;
			// The sprite is now fully defined.
			//this.addChild(this._layerContainer);
			
			this.addEventListener(LayerEvent.LAYER_LOAD_START,layerLoadHandler);
			this.addEventListener(LayerEvent.LAYER_LOAD_END,layerLoadHandler);	
			//this.addEventListener(MapEvent.PROJECTION_CHANGED,this.onMapProjectionChanged);
			
			if (DEBUG_MAX_EXTENT)
			{
				this.addEventListener(Event.ENTER_FRAME, this.onDraw);
			}
//			this.addEventListener(LayerEvent.LAYER_PROJECTION_CHANGED, layerProjectionChanged);
			
			Trace.stage = this.stage;
			
			this.focusRect = false;// Needed to hide yellow rectangle around map when focused
			this.addEventListener(MouseEvent.CLICK, onMouseClick); //Needed to prevent focus losing 

			
		}
		
		private function onDraw(event:Event):void
		{
			if (_extenTDebug == null)
			{
				_extenTDebug = new Shape();
			} else
			{
				_extenTDebug.graphics.clear();
			}
			var extent:Bounds = this.maxExtent; //new Bounds(-180, -90, 180, 90, "EPSG:4326");
			var topLeft:Pixel = this.getMapPxFromLocation(new Location(extent.left, extent.top));
			var bottomRight:Pixel = this.getMapPxFromLocation(new Location(extent.right, extent.bottom));
			
			_extenTDebug.graphics.beginFill(0xFF0000, 0.3);
			_extenTDebug.graphics.drawRect(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
			_extenTDebug.graphics.endFill();
			this.addChild(_extenTDebug);
		}
		
		/**
		 * Reset all layers, handlers and controls
		 */
		public function reset():void {
			this.removeAllLayers();
			
			if (this._controls != null) {
				for each(var control:IHandler in this._controls) {
					this.removeControl(control);
				}
			}
			
			var i:int = this._securities.length;
			for(i;i>0;--i)
				this._securities.pop().destroy();
		}
		
		/**
		 * Change the resolution of the projection of all the variables in the map
		 * when the resolution of the map is changed
		 */
		private function onMapProjectionChanged(event:MapEvent):void
		{
			this._resolution = this._resolution.reprojectTo(event.newProjection);
			this._maxExtent =  this._maxExtent.reprojectTo(event.newProjection);
			this._center = this.center.reprojectTo(event.newProjection);
			this._maxResolution = this._maxResolution.reprojectTo(event.newProjection);
			this._minResolution = this._minResolution.reprojectTo(event.newProjection);
		}
		
		
		
		// Layer management
		
		/**
		 * Add a new layer to the map.
		 * A LayerEvent.LAYER_ADDED event is triggered.
		 *
		 * @param layer The layer to add.
		 * @return true if the layer have been added, false if it has not.
		 */
		public function addLayer(layer:Layer, isBaseLayer:Boolean = false, redraw:Boolean = true):Boolean {
			var i:uint = 0;
			var j:uint = this.layers.length;
			for(; i < j; ++i) {
				if (this.layers[i] == layer) {
					return false;
				}
			}
			
			this.addChild(layer);
			
			layer.map = this;
			
			if (redraw){
				layer.redraw();	
			}
			
			var _centerPoint:Shape = new Shape();
			_centerPoint.graphics.clear();
			_centerPoint.graphics.lineStyle(1, 0xFF0000);
			_centerPoint.graphics.moveTo(this.width/2 - 5, this.height/2);
			_centerPoint.graphics.lineTo(this.width/2 + 5, this.height/2);
			_centerPoint.graphics.moveTo(this.width/2, this.height/2 - 5);
			_centerPoint.graphics.lineTo(this.width/2, this.height/2 + 5);
			this.addChild(_centerPoint);
			
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_ADDED, layer));
			
			return true;
		}
		
		/**
		 * Add a group of layers.
		 * @param layers to add.
		 */
		public function addLayers(layers:Vector.<Layer>):void {
			var layersNb:uint = layers.length;
			for (var i:uint=0; i<layersNb; ++i) {
				this.addLayer(layers[i]);
			}
		}
		
		/**
		 * @deprecated
		 * The current baseLayer.
		 * 
		 * The baseLayer is used to identify what layer is used to define map display projection,
		 * resolutions, min resolution and max resolution.
		 *
		 * @param newBaseLayer the new base layer, must be one of the map layers
		 */
		/*public function set baseLayer(newBaseLayer:Layer):void {
			if (! newBaseLayer) {
				this._baseLayer = null;
				return;
			}
			
			var oldExtent:Bounds = (this.baseLayer) ? this.baseLayer.extent : null;
			
			if (this.bitmapTransition != null)
				this.bitmapTransition.visible = false;
			
			if (newBaseLayer != this.baseLayer) {
				if (this.layers.indexOf(newBaseLayer) != -1) {
					// if we set a baselayer with a different projection, we
					// change the map's projected datas
					if (this.baseLayer) {
						if ((this.baseLayer.projSrsCode != newBaseLayer.projSrsCode)
							||(newBaseLayer.resolutions==null)) {
							// FixMe : why testing (newBaseLayer.resolutions==null) ?
							if (this.center != null)
								this.center = this.center.reprojectTo(newBaseLayer.projSrsCode);
							
							if (this._layerContainerOrigin != null)
								this._layerContainerOrigin = this._layerContainerOrigin.reprojectTo(newBaseLayer.projSrsCode);
							
							oldExtent = null;
							this.maxExtent = newBaseLayer.maxExtent;
						}
					}
					
					this._baseLayer = newBaseLayer;
					
					var center:Location = this.center;
					if (center != null) {
						if (oldExtent == null) {
							this.moveTo(center, this.zoom);
						} else {
							this.moveTo(oldExtent.center, this.getZoomForExtent(oldExtent));
						}
					} else {
						// The map must be fully defined as soon as its baseLayer is defined
						this.moveTo(this._baseLayer.maxExtent.center, this.getZoomForExtent(this._baseLayer.maxExtent));
					}
					
					this.dispatchEvent(new LayerEvent(LayerEvent.BASE_LAYER_CHANGED, newBaseLayer));
				}
			}
		}

		public function get baseLayer():Layer {
			return this._baseLayer;
		}*/
		
		/**
		 * Get a layer from its name.
		 * @param name the layer name to find.
		 * @return the found layer. Null if no layer have been found.
		 *
		 */
		public function getLayerByName(name:String):Layer {
			var foundLayer:Layer = null;
			var i:uint = 0;
			var j:uint = this.layers.length;
			for (; i < j; ++i) {
				var layer:Layer = this.layers[i];
				if (layer.name == name) {
					foundLayer = layer;
				}
			}
			return foundLayer;
		}
		
		/**
		 * Removes a layer from the map by removing its visual element, then removing
		 * it from the map's internal list of layers.
		 * You have to call layer.destroy after this function if needed !
		 *
		 * A LayerEvent.LAYER_REMOVED event is triggered.
		 *
		 * @param layer the layer to remove.
		 * @param setNewBaseLayer if set to true, a new base layer will be set if the removed
		 * 	layer was a based layer
		 */
		public function removeLayer(layer:Layer):void {
			
			//layer.destroy();
			var l:Vector.<Layer> = this.layers;
			var i:int = l.indexOf(layer);
			if(i>-1)
				l.splice(i,1);
			
			layer.map = null;
			this.removeChild(layer);
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_REMOVED, layer));
			
		}
		
		
		/**
		 * Remove all layers of the map
		 */
		public function removeAllLayers():void {
			for(var i:int=this.layers.length-1; i>=0; i--) {
				removeLayer(this.layers[i]);
			}
		}
		
		/**
		 * @param {OpenLayers.Popup} popup
		 * @param {Boolean} exclusive If true, closes all other popups first
		 **/
		public function addPopup(popup:Popup, exclusive:Boolean = true):void {
			var i:Number;
			if(exclusive){
				var child:DisplayObject;
				for(i=this.numChildren-1;i>=0;i--){
					child = this.getChildAt(i);
					if(child is Popup){
						if(child != popup) {
							Trace.warn("Map.addPopup: popup already displayed so escape");
							return;
						}
						this.removePopup(child as Popup);
					}
				}
			}
			if (popup != null){
				popup.map = this;
				popup.draw();
				this.addChild(popup);
			}
		}
		
		public function removePopup(popup:Popup):void {
			if(this.contains(popup))
				this.removeChild(popup);
		}
		
		/**
		 * Allows user to pan by a value of screen pixels.
		 *
		 * @param dx horizontal pixel offset
		 * @param dy verticial pixel offset
		 * @param tween use tween effect
		 */
		public function pan(dx:int, dy:int, tween:Boolean=false):void {
			// Is there a real offset ?
			if ((dx==0) && (dy==0)) {
				return;
			}		
			if(this.center) {
				//var newCenterPx:Pixel = this.getMapPxFromLocation(this.center).add(dx, -dy);
				var newCenterLocation:Location = this.center.add(dx*this.resolution.value, -dy*this.resolution.value);
				this.center = newCenterLocation;
			}
		}
		
		/**
		 * Zoom in
		 * It use the defaultZoomInFactor parameter of the map to change the resolution.
		 * You can change this parameter to change the zoom factor for this method
		 * If you want to give a zoom factor that will change frequently, use the zoom method
		 * If the resolution reach a value below the minResolution, the resolution is setted
		 * to minResolution
		 * 
		 * You can give a pixel to specify the pixel where to zoom. The default value is the center of the 
		 * map
		 */
		public function zoomIn(targetPixel:Pixel = null):void
		{
			var _newResolution:Number = this.resolution.value * this._defaultZoomInFactor;
			
			if (targetPixel == null)
			{
				targetPixel = this.getMapPxFromLocation(this.center);
			}
			this.zoomTo(new Resolution(_newResolution, this.resolution.projection), targetPixel);
		}
		
		/**
		 * Zoom out
		 * It use the defaultZoomOutFactor parameter of the map to change the resolution.
		 * You can change this parameter to change the zoom factor for this method
		 * If you want to give a aoom factor that will change frequently, use the zoom method
		 * If the resolution reach a value above the maxResolution, the resolution is setted
		 * to maxResolution
		 * 
		 * You can give a pixel to specify the pixel where to zoom. The default value is the center of the 
		 * map
		 */
		public function zoomOut(targetPixel:Pixel = null):void
		{
			var _newResolution:Number = this.resolution.value * this._defaultZoomOutFactor;
			
			if (targetPixel == null)
			{
				targetPixel = this.getMapPxFromLocation(this.center);
			}
			this.zoomTo(new Resolution(_newResolution, this.resolution.projection), targetPixel);
		}
		
		/**
		 * Zoom
		 * It use the given parameter to change the resolution.
		 * The parameter must be above 0. If the factor is bellow 0, this method throw an argument error.
		 * If the resolution reach a value above the maxResolution or below the minResolution,
		 * the Resolution is setted to maxResolution or minResolution
		 * 
		 * You can give a pixel to specify the pixel where to zoom. The default value is the center of the 
		 * map
		 */
		public function zoom(factor:Number, targetPixel:Pixel = null):void
		{
			if (factor < 0)
				throws(new ArgumentError);
			
			var _newResolution:Number = this.resolution.value * factor;
			
			if (targetPixel == null)
			{
				targetPixel = this.getMapPxFromLocation(this.center);
			}
			this.zoomTo(new Resolution(_newResolution, this.resolution.projection), targetPixel);
		
		}
		
		/**
		 * @private
		 * This method is the one that will execute the zoom.
		 * It's called by every zoom method exposed by the API 
		 * this method will check that the resolution is in range
		 * of min and max resolution
		 */
		private function zoomTo(resolution:Resolution, zoomTarget:Pixel):void
		{
			// Manage while dragging?
			// Temporary 
			var dragTween:Boolean = false;
			
			this._targetZoomPixel = null;
			var mapEvent:MapEvent;
			var newResolution:Number = resolution.value
				
			if (newResolution > this.maxResolution.value)
			{
				newResolution = this.maxResolution.value;
			}
			
			if (newResolution < this.minResolution.value)
			{
				newResolution = this.minResolution.value;
			}
			var targetResolution:Resolution = new Resolution(newResolution, this.resolution.projection);
			var resolutionChanged:Boolean = (this.isValidResolution(targetResolution) && (targetResolution.value != this._resolution.value));
			//var validLocation:Boolean = this.isValidLocation(newCenter);
			
			/*if (newCenter && !validLocation) {
				Trace.log("Not a valid center, so do nothing");
				return;
			}*/
			
			//var centerChanged:Boolean = validLocation && (! newCenter.equals(this.center));
			
			if (resolutionChanged /*|| centerChanged*/) {
				
				mapEvent = new MapEvent(MapEvent.MOVE_START, this);
				this.dispatchEvent(mapEvent);
				

				//var ratio:Number = this.resolution.value/targetResolution.value;
				//var newCenter:Location = this.getLocationFromMapPx(new Pixel(this.width*ratio/2, this.height*ratio/2));
				
				
				//var centerPixel:Pixel = this.getMapPxFromLocation(this.center);
				var zoomTargetLoc:Location = this.getLocationFromMapPx(zoomTarget);
				var deltaX:Number = zoomTarget.x - this.width/2;
				var deltaY:Number = zoomTarget.y - this.height/2;
				var deltaLon:Number = deltaX*targetResolution.value;
				var deltaLat:Number = deltaY*targetResolution.value;
				var newCenter:Location = new Location(zoomTargetLoc.lon - deltaLon, zoomTargetLoc.lat + deltaLat, this.center.projSrsCode);
				if (resolutionChanged) {
					
					if(!this.maxExtent.containsLocation(zoomTargetLoc) || !this.maxExtent.containsLocation(newCenter)){
						this._targetZoomPixel = new Pixel(this.width/2,this.height/2);
					}
					else{
						this._targetZoomPixel = zoomTarget;
					}
					this.resolution = targetResolution;
				}
				
				
				if (! zoomTargetLoc.equals(this.center))
				{
					/*var deltaX:Number = zoomTarget.x - this.width/2;
					var deltaY:Number = zoomTarget.y - this.height/2;
					var deltaLon:Number = deltaX*this.resolution.value;
					var deltaLat:Number = deltaY*this.resolution.value;
					Trace.debug("Zoom Location :"+zoomTargetLoc.lon+", "+zoomTargetLoc.lat);
					Trace.debug("Delta Location :"+deltaLon+", "+deltaLat);
					var newCenter:Location = new Location(zoomTargetLoc.lon - deltaLon, zoomTargetLoc.lat + deltaLat, this.center.projSrsCode);
					*/
					
					if(!this.maxExtent.containsLocation(zoomTargetLoc) || !this.maxExtent.containsLocation(newCenter)){
						this.center = new Location(this.width/2,this.height/2,this.center.projSrsCode);
					}
					else{
						this.center = newCenter;
					}
				}
				
				//var centerPx:Pixel = this.getMapPxFromLocation(zoomTarget);
				var centerPx:Pixel = this.getMapPxFromLocation(this.center);
				if (_centerShape != null)
				{
					this.removeChild(_centerShape);
				}
				_centerShape = new Shape();
				_centerShape.graphics.clear();
				_centerShape.graphics.lineStyle(1, 0x00FF00);
				_centerShape.graphics.moveTo(centerPx.x - 5, centerPx.y);
				_centerShape.graphics.lineTo(centerPx.x + 5, centerPx.y);
				_centerShape.graphics.moveTo(centerPx.x, centerPx.y - 5);
				_centerShape.graphics.lineTo(centerPx.x, centerPx.y + 5);
				this.addChild(_centerShape);
			}
		}
		
		/**
		 * Set the map center (and optionally, the zoom level).
		 *
		 * This method shoud be refactored in order to make panning and zooming more independant.
		 *
		 * @param lonlat the new center location.
		 * @param zoom optional zoom level
		 * @param dragging Specifies whether or not to trigger movestart/end events
		 * @param forceZoomChange Specifies whether or not to trigger zoom change events (needed on baseLayer change)
		 * @param dragTween Tween effect when panning
		 * @param zoomTween Tween effect when zooming
		 *
		 */
		public function moveTo(newCenter:Location,
								newResolution:Resolution = null,
								dragTween:Boolean = false,
								zoomTween:Boolean = false):void {
					
			/*if (newResolution != null)
				var resolutionChanged:Boolean = (this.isValidResolution(newResolution) && (newResolution.resolutionValue != this._resolution.resolutionValue));
			var validLocation:Boolean = this.isValidLocation(newCenter);
			var mapEvent:MapEvent = null;
			
			if (newCenter && !validLocation) {
				Trace.log("Not a valid center, so do nothing");
				return;
			}	*/	
			
			/*// If the map is not initialized, the center of the extent is used
			// as the current center
			if (!this.center && !validLocation) {
				newCenter = this.maxExtent.center;
			} else if(this.center && !newCenter) {
				newCenter = this.center;
			}			
			if (newCenter.projSrsCode && (newCenter.projSrsCode!=this.projection)) {
				newCenter = newCenter.reprojectTo(this.projection);
			}*/
			
			//var centerChanged:Boolean = validLocation && (! newCenter.equals(this.center));
			//validLocation = this.isValidLocation(newCenter);
			//var oldResolution:Resolution = this.resolution;
			//if(!resolutionChanged){
			//  newResolution = oldResolution; 
			//}
			//var oldCenter:Location = this._center;
			
			
		/*	if (resolutionChanged || centerChanged) {
				
				mapEvent = new MapEvent(MapEvent.MOVE_START, this);
				//mapEvent.oldResolution = oldResolution;
				//mapEvent.newResolution = newResolution;
				//mapEvent.oldCenter = oldCenter;
				//mapEvent.newCenter = newCenter;
				this.dispatchEvent(mapEvent);

				if (zoomChanged && zoomTween) {
					this.zoomTransition(newZoom, newCenter);
					return;
				}
				
				if (centerChanged) {
					if ((!resolutionChanged) && (this.center) && !this._dragging) {
						this.centerLayerContainer(newCenter, dragTween);
					}
					this.center = newCenter.clone();
					//var mapEventCenter:MapEvent = new MapEvent(MapEvent.CENTER_CHANGED, this);
					//mapEventCenter.oldCenter = oldCenter;
					//mapEventCenter.newCenter = newCenter;
					//this.dispatchEvent(mapEventCenter);
				}
				
				if ((resolutionChanged) || (this._layerContainerOrigin == null)) {
					this._layerContainerOrigin = this.center.clone();
					this._layerContainer.x = 0;
					this._layerContainer.y = 0;
				}
				
				if (resolutionChanged) {
					this.resolution = newResolution;
					//var mapEventZoom:MapEvent = new MapEvent(MapEvent.ZOOM_CHANGED, this);
					//mapEventZoom.oldResolution = oldResolution;
					//mapEventZoom.newResolution = newResolution;
					//this.dispatchEvent(mapEventZoom);
				}
				
				
				if (!dragTween) {
					mapEvent = new MapEvent(MapEvent.MOVE_END, this);
					mapEvent.oldResolution = oldResolution;
					mapEvent.newResolution = newResolution;
					mapEvent.oldCenter = oldCenter;
					mapEvent.newCenter = newCenter;
					this.dispatchEvent(mapEvent);
				}
			}*/
		}
		
		/**
		 * Reset the bitmap center depending on the current map center
		 * 
		 * @param tween use tween effect if set to true (default)
		 */
		public function resetCenterLayerContainer(tween:Boolean = true):void {
			//this.centerLayerContainer(this.center, tween);
		}
		
		/**
		 * This function takes care to recenter the layerContainer and bitmapTransition.
		 *
		 * @param lonlat the new layer container center
		 * @param tween use tween effect if set to true
		 */
		/*private function centerLayerContainer(lonlat:Location, tween:Boolean = false):void {
			
			var originPx:Pixel = this.getMapPxFromLocation(this._layerContainerOrigin);
			var newPx:Pixel = this.getMapPxFromLocation(lonlat);
			
			if (originPx == null || newPx == null)
				return;
			
			// X and Y positions for the layer container and bitmap transition, respectively.
			var lx:Number = originPx.x - newPx.x;
			var ly:Number = originPx.y - newPx.y; 
			if (bitmapTransition != null) {
				var bx:Number = bitmapTransition.x + lx - _layerContainer.x;
				var by:Number = bitmapTransition.y + ly - _layerContainer.y;
			}
			
			if(tween) {
				var layerContainerTween:GTween = new GTween(this._layerContainer, 0.5, {x: lx, y: ly}, {ease: Cubic.easeOut});
				layerContainerTween.onComplete = onDragTweenComplete;
				this._cptGTween++;
				if(bitmapTransition != null) {
					new GTween(bitmapTransition, 0.5, {x: bx, y: by}, {ease: Cubic.easeOut});
				} 
			} else {
				this._layerContainer.x = lx;
				this._layerContainer.y = ly;    
				if(bitmapTransition != null) {
					bitmapTransition.x = bx;
					bitmapTransition.y = by;
				} 
			}
		}*/
		
		private function onDragTweenComplete(tween:GTween):void
		{
			this._cptGTween--;
			if(this._cptGTween == 0)
				this.dispatchEvent(new MapEvent(MapEvent.MOVE_END, this));
		}
		
		/**
		 * Check if a zoom level is valid on this map.
		 *
		 * @param zoomLevel the zoom level to test
		 * @return Whether or not the zoom level passed in is non-null and within the min/max
		 * range of zoom levels.
		 */
		private function isValidResolution(resolution:Resolution):Boolean {
			
			if (resolution.value < this.minResolution.value)
			{
				return false;
			}
			
			if (resolution.value > this.maxResolution.value)
			{
				return false;
			}
			return true
		}
		
		/**
		 *  Check if a coordinate is valid on this map.
		 *
		 * @param lonlat the coordinate to test
		 * @return Whether or not the lonlat passed in is non-null and within the maxExtent bounds
		 */
		private function isValidLocation(lonlat:Location):Boolean {
			return (lonlat!=null) && this.maxExtent.containsLocation(lonlat);
		}
		
		/**
		 * Find the resolution that most closely fits the specified bounds. Note that this may
		 * result in a resolution that does not exactly contain the entire extent.
		 *
		 * @param bounds the extent to use
		 * @return the matching resolution
		 *
		 */
		private function getResolutionForExtent(bounds:Bounds):Resolution {
			// TODO : Reimplement to use resolution
			var zoom:int = -1;
			/*if (this.baseLayer != null) {
				zoom = this.baseLayer.getZoomForExtent(bounds);
			}*/
			return new Resolution(0, "EPSG:4326");
		}
		
		/**
		 * A suitable zoom level for the specified bounds. If no baselayer is set, returns null.
		 *
		 * @param resolution the resolution to use
		 * @return the matching zoom level
		 *
		 */
		/*public function getZoomForResolution(resolution:Number):Number {
			var zoom:int = -1;
			if (this.baseLayer != null) {
				zoom = this.baseLayer.getZoomForResolution(resolution);
			}
			return zoom;
		}*/
		
		/**
		 * Zoom to the given extent
		 * Change the map center and resolution to be at the exetnt given
		 *
		 * @param bounds
		 */
		public function zoomToExtent(bounds:Bounds):void 
		{
			if(this.maxExtent.containsBounds(bounds))
			{
				if(bounds.projSrsCode != this.projection)
					bounds = bounds.reprojectTo(this.projection);
				
				var x:Number = (bounds.left + bounds.right)/2;
				var y:Number = (bounds.top + bounds.bottom)/2;
				this.center = new Location(x, y, this.projection);
				
				var resolutionX:Number = (bounds.right-bounds.left) / this.width;
				var resolutionY:Number = (bounds.top-bounds.bottom) / this.height;
				
				// choose max resolution to be sure that all the extent is include in the current map
				var resolution:Number = (resolutionX > resolutionY) ? resolutionX : resolutionY;
				this.resolution = new Resolution(resolution, this.projection);
			}
		}
		
		/**
		 * Zoom to the full extent and recenter.
		 */
		public function zoomToMaxExtent():void {
			this.zoomToExtent(this.maxExtent);
		}
		
		/**
		 * <p>
		 * Zoom to the closest resolution.
		 * This methods choose within the resolution array of the baseLayer the zoom level
		 * which associated resolution is the closest to the specifed one and zoom to it.
		 * </p>
		 * <p>
		 * The resolution must be in the same unity as the one of the base layer
		 * </p>
		 * 
		 * @example The following code explains how to zoom to a specified resolution
		 * 
		 * <listing version="3.0">
		 * 	var myMap:Map = new Map(); 
		 * 	myMap.zoomToResolution(125420);
		 * </listing>
		 */ 
		/*public function zoomToResolution(resolution:Number):void
		{
			if ((resolution >= minResolution) && (resolution <= maxResolution))
			{
				if (baseLayer != null)
				{
					var targetResolution:Number = resolution;
					var bestZoomLevel:int = 0;
					var bestRatio:Number = 0;
					var i:int = Math.max(0, this.baseLayer.minZoomLevel);
					var len:int = Math.min(this.baseLayer.resolutions.length, this.baseLayer.maxZoomLevel+1);
					for (i; i < len; ++i)
					{
						var ratio:Number = this.baseLayer.resolutions[i] / targetResolution;
						if ( ratio > 1){
							ratio = 1/ratio;
						}
						if ( ratio > bestRatio){
							bestRatio = ratio;
							bestZoomLevel = i;
						}
					}
					this.zoom = bestZoomLevel;
				}
			}
		}*/
				
		/**
		 * Return a Location which is the passed-in view port Pixel, translated into lon/lat
		 *	by the current base layer
		 */
		public function getLocationFromMapPx(px:Pixel, res:Resolution = null):Location {
			var lonlat:Location = null;
			if (px != null) {
				var size:Size = this.size;
				var center:Location = this.center;
				if (center) {
					if (!res)
					{
						res = this.resolution;
					}
					
					var delta_x:Number = px.x - (size.w / 2);
					var delta_y:Number = px.y - (size.h / 2);
					
					lonlat = new Location(center.lon + delta_x * res.value, center.lat - delta_y * res.value, this.projection);
				}
			}
			return lonlat;
		}
		
		/**
		 * Return a Pixel which is the passed-in Location, translated into map
		 * pixels by the current base layer
		 */
		public function getMapPxFromLocation(lonlat:Location):Pixel {
			var px:Pixel = null;
			var b:Bounds = this.extent;
			if (lonlat != null && b) {
				var resolution:Number = this.resolution.value;
				px = new Pixel(Math.round((lonlat.lon - b.left) / resolution), Math.round((b.top - lonlat.lat) / resolution));
			}	
			return px;
		}
		
		/**
		 * Return a map Pixel computed from a layer Pixel.
		 */
		/*public function getMapPxFromLayerPx(layerPx:Pixel):Pixel {
			var viewPortPx:Pixel = null;
			if (layerPx != null) {
				var dX:int = int(this.x);
				var dY:int = int(this.y);
				viewPortPx = layerPx.add(dX, dY);
			}
			return viewPortPx;
		}*/
		
		/**
		 * Return a layer Pixel computed from a map Pixel.
		 */
		/*public function getLayerPxFromMapPx(mapPx:Pixel):Pixel {
			var layerPx:Pixel = null;
			if (mapPx != null) {
				var dX:int = -int(this.x);
				var dY:int = -int(this.y);
				layerPx = mapPx.add(dX, dY);
			}
			return layerPx;
		}*/
		
		/**
		 * Return a Location computed from a layer Pixel.
		 */
		/*public function getLocationFromLayerPx(px:Pixel):Location {
			px = this.getMapPxFromLayerPx(px);
			return this.getLocationFromMapPx(px);
		}*/
		
		/**
		 * Return a layer Pixel computed from a Location.
		 */
		/*public function getLayerPxFromLocation(lonlat:Location):Pixel {
			var px:Pixel = this.getMapPxFromLocation(lonlat);
			return this.getLayerPxFromMapPx(px);
		}*/
		
		/**
		 * Remove a Security
		 * @param the security to remove
		 * @return  Boolean true or false depends on the success of removing
		 **/
		public function removeSecurity(security:ISecurity):Boolean {
			var i:int = this._securities.indexOf(security);
			if(i!=-1) {
				this._securities.splice(i,1);
				return true;
			}
			return false;
		}
		/**
		 * find a security requester by its class name
		 * @return the security 
		 * */
		public function findSecurityByClass(securityClass:String):ISecurity{
			var i:int = this._securities.length - 1;
			for(i;i>-1;--i){
				var test:String = getQualifiedClassName(this._securities[i]);
				if(securityClass==getQualifiedClassName(this._securities[i])){
					return this._securities[i];
				}
			}
			return null;
		}
		
		
		/**
		 * To add a securities Array
		 * @param securities: The securities Array to add
		 * @return Boolean true or false depends on the adding or not
		 * */
		public function addSecurities(securities:Array):Boolean{
			
			if(securities==null) return false;
			var i:int = securities.length - 1;
			for(i;i>-1;--i){
				var security:ISecurity=securities[i] as ISecurity;
				//security is not null 
				if(security!=null)
					//The security 
					if(this.addSecurity(security)==false){
						return false;
						break;
					}
			}
			return true;
		}
		/**
		 * To add a security 
		 * @param security: The security to add
		 * @return Boolean true or false depends on the adding or not
		 * */
		public function addSecurity(security:ISecurity):Boolean{
			//if security is not null && there is not the same type of security 
			if(security==null) {
				return false;
			}
			var i:int = this._securities.length - 1;
			for(;i>-1;--i){
				if(getQualifiedClassName(security)==getQualifiedClassName(this._securities[i])){
					return false;
				}
			}
			this._securities.push(security);
			return true;
		}
		// Getters & setters as3
		
		/**
		 * Map center coordinates
		 */
		public function get center():Location
		{
			return _center;
		}
		
		public function set center(newCenter:Location):void
		{
			var event:MapEvent = new MapEvent(MapEvent.CENTER_CHANGED, this);
			event.oldCenter = this._center;
			event.newCenter = newCenter;
			event.oldResolution = this.resolution;
			event.newResolution = this.resolution;
			if (newCenter.projSrsCode != this.projection)
			{
				newCenter = newCenter.reprojectTo(this.projection);
			}
			Trace.debug("Trying Center : "+newCenter.x+", "+newCenter.y+", "+ newCenter.projSrsCode);
			if (this.maxExtent.containsLocation(newCenter))
			{
				this._center = newCenter;
				this.dispatchEvent(event);
			}
			else
			{
				Trace.debug("Center out of maxExtent so do nothing");
			}
			
			
			/*this.graphics.beginFill(0xFFFFFF,0);
			this.graphics.drawRect(0,0,this.size.w,this.size.h);
			this.graphics.endFill();*/
			
		}
		
		/**
		 * Current map zoom level
		 */
		/*public function get zoom():Number
		{
			return _zoom;
		}
		public function set zoom(newZoom:Number):void 
		{
			this.moveTo(this.center, newZoom);
		}*/
		
		
		/**
		 * Copy the layerContainer in a bitmap and display this (this function is use for zoom)
		 */
		/*private function zoomTransition(newZoom:Number, newCenter:Location):void {
			if (!_zooming && newZoom >= 0) {
				
				// Disable more zooming until this zooming is complete 
				this._zooming = true;
				
				// We calculate de scale multiplicator according to the actual and new resolution
				var resMult:Number = this.resolution / this.baseLayer.resolutions[newZoom];
				// We intsanciate a bitmapdata with map's size
				var bitmapData:BitmapData = new BitmapData(this.width,this.height);
				
				// We draw the old transition before drawing the better-fitting tiles on top and removing the old transition. 
				if(this.bitmapTransition != null) {
					if(this._loading ) {
						bitmapData.draw(this.bitmapTransition, bitmapTransition.transform.matrix);
					}
					this.removeChild(this.bitmapTransition);
					var bmp:Bitmap = bitmapTransition.removeChildAt(0) as Bitmap;
					bmp.bitmapData.dispose();
					bmp.bitmapData = null;
					
				}				

				var hiddenLayers:Vector.<Layer> = new Vector.<Layer>();
				for each(var layer:Layer in this.layers) {
					if(!layer.tweenOnZoom) {				
						hiddenLayers.push(layer);
						layer.visible = false;
					}
				}
				
				// We draw the loaded tiles onto the background transition.
				try {
					// Can sometimes throw a security exception.
					bitmapData.draw(this.layerContainer, this.layerContainer.transform.matrix);
				} catch (e:Error) {
					Trace.error("Error zooming image: " + e);
				}				
				
				// We create the background layer from the bitmap data
				this.bitmapTransition = new Sprite();
				var bitmap:Bitmap = new Bitmap(bitmapData);
				bitmap.smoothing = true;
				this.bitmapTransition.addChild(bitmap);		
				
				for each(var hiddenLayer:Layer in hiddenLayers) {
					layer.visible = true;
				}
				
				this.addChildAt(bitmapTransition, 0);
				
				// We hide the layerContainer (to avoid zooming out issues)
				this.layerContainer.visible = false;
				
				//We calculate the bitmapTransition position
				var pix:Pixel = this.getMapPxFromLocation(newCenter);
				
				var bt:Sprite = this.bitmapTransition;
				var oldCenterPix:Pixel = new Pixel(bt.x+bt.width/2, bt.y+bt.height/2);
				var centerOffset:Pixel = new Pixel(oldCenterPix.x-pix.x, oldCenterPix.y-pix.y);
				var alpha:Number = Math.pow(2, newZoom-this.zoom);
				var x:Number = bt.x-((resMult-1)*(bt.width))/2+alpha*centerOffset.x;
				var y:Number = bt.y-((resMult-1)*(bt.height))/2+alpha*centerOffset.y;
				
				//The tween effect to scale and re-position the bitmapTransition
				var tween:GTween = new GTween(this.bitmapTransition,0.3,
					{
						scaleX: resMult,
						scaleY: resMult,
						x: x,
						y: y
					}, {ease: Cubic.easeOut});
				tween.onComplete = clbZoomTween;
			}
			
			// The zoom tween callback method defined here to avoid a class attribute for newZoom
			function clbZoomTween(tween:GTween):void {
				_zooming = false;
				moveTo(newCenter, newZoom);
				layerContainer.visible = true;
				dispatchEvent(new MapEvent(MapEvent.LAYERCONTAINER_IS_VISIBLE, null));
				clearBitmapTransition();
			} 

		}*/
		
		public function clearBitmapTransition():void {
			if(this._bitmapTransition != null && this._bitmapTransition.visible && this._baseLayer != null && this._baseLayer.loadComplete) {
				this._bitmapTransition.visible=false;
			}
		}
		
		/**	
		 * Event handler for LayerLoadComplete event. Check here if all layers have been loaded
		 * and if so, MapEvent.LOAD_COMPLETE can be dispatched
		 */
		private function layerLoadHandler(event:LayerEvent):void {
			
			switch(event.type) {
				case LayerEvent.LAYER_LOAD_START: {
					this.loading = true;
					break;
				}	
				case LayerEvent.LAYER_LOAD_END: {
					
					
					
					this.clearBitmapTransition();
					
					// check all layers 
					var l:Vector.<Layer> = this.layers;
					var i:int = l.length -1;
					for (;i>-1;--i)	{
						var layer:Layer = l[i];
						if (layer != null && !layer.loadComplete)
							return;	
					}
					// all layers are done loading.					
					this.loading = false;
					break;
				}						
			}
		}
	
		
		
		
		/**
		 * Call when a Layer has its projection changed.
		 * If this layer is the baselayer, reproject other layers
		 */
		/*public function redrawLayers():void
		{
			
			var i:int = 0;
			var j:int = layers.length;
			for(; i<j; ++i)
			{
				if(layers[i] != this.baseLayer)
				{
					layers[i].redraw(true);
					
					if( layers[i] is WMTS)
					{
						(layers[i] as WMTS).initGriddedTiles(this.extent);
					}
				}
			}
		}*/
		
		/**
		 * Map size in pixels.
		 */
		public function get size():Size {
			return (_size) ? _size.clone() : null;
		}
		public function set size(value:Size):void {
			if (value) {
				_size = value;
				this.graphics.clear();
				this.graphics.beginFill(0xFFFFFF);
				this.graphics.drawRect(0,0,this.size.w,this.size.h);
				this.graphics.endFill();
				this.scrollRect = new Rectangle(0,0,this.size.w,this.size.h);
				
				this.dispatchEvent(new MapEvent(MapEvent.RESIZE, this));
				// TODO Refactor?
				//this.moveTo(null,this.resolution);
				

				
			} else {
				Trace.error("Map - size not changed since the value is not valid");
			}
		}
		
		/**
		 * Map width in pixels.
		 */
		override public function set width(value:Number):void {
			if (! isNaN(value)) {
				this.size = new Size(value, this.size.h);
			} else {
				Trace.error("Map - width not changed since the value is not valid");
			}
		}
		
		/**
		 * Map height in pixels.
		 */
		override public function set height(value:Number):void {
			if (! isNaN(value)) {
				this.size = new Size(this.size.w, value);
			} else {
				Trace.error("Map - height not changed since the value is not valid");
			}
		}
		
		/**
		 * Map container where layers are added. It is used for panning and scaling layers.
		 */
		public function get layerContainer():Sprite {
			return this;
		}
		
		/**
		 * Bitmap representation of the map display used for tween effects
		 */
		public function get bitmapTransition():Sprite {
			return this._bitmapTransition;
		}
		
		public function set bitmapTransition(value:Sprite):void {
			this._bitmapTransition = value;
		}
		
		public function set maxExtent(value:Bounds):void {
			if (value.projSrsCode != this.projection)
			{
				value = value.reprojectTo(this.projection);
			}
			this._maxExtent = value;
		}
		
		/**
		 * The maximum extent for the map.
		 */
		public function get maxExtent():Bounds {
			// use map maxExtent
		//	var maxExtent:Bounds = this._maxExtent;
			
			// If no maxExtent is defined, generate a worldwide maxExtent in the right projection
			/*if(maxExtent == null) {
				maxExtent = Layer.DEFAULT_MAXEXTENT;
				maxExtent = maxExtent.reprojectTo(this.projection);
			}*/
			return this._maxExtent;
		}
		
		/**
		 * Extent currently displayed in the map.
		 */
		public function get extent():Bounds {
			var extent:Bounds = null;
			
			if ((this.center != null) && (this.resolution != null)) {
				var center:Location;
				if(this.center.projSrsCode.toUpperCase() != this.projection.toUpperCase())
					center = this.center.reprojectTo(this.projection.toUpperCase());
				else
					center = this.center;
				var w_deg:Number = this.size.w * this.resolution.value;
				var h_deg:Number = this.size.h * this.resolution.value;
				
				extent = new Bounds(center.lon - w_deg / 2,
					center.lat - h_deg / 2,
					center.lon + w_deg / 2,
					center.lat + h_deg / 2,
					center.projSrsCode);
			} 
			
			return extent;

		}
		
		public function getExtentForResolution(resolution:Resolution):Bounds
		{
			var extent:Bounds = null;
			
			if (this.center != null) {
				var center:Location;
				if(this.center.projSrsCode.toUpperCase() != this.projection.toUpperCase())
					center = this.center.reprojectTo(this.projection.toUpperCase());
				else
					center = this.center;
				var w_deg:Number = this.size.w * resolution.value;
				var h_deg:Number = this.size.h * resolution.value;
				
				extent = new Bounds(center.lon - w_deg / 2,
					center.lat - h_deg / 2,
					center.lon + w_deg / 2,
					center.lat + h_deg / 2,
					center.projSrsCode);
			} 
			
			return extent;
		}
		
		

		
		/**
		 * Current scale denominator of the map. 
		 */
		// TODO : remove?
		/*public function get scale():Number {
			var scale:Number = NaN;
			if (this.baseLayer) {
				var units:String = ProjProjection.getProjProjection(this.baseLayer.projSrsCode).projParams.units;
				scale = Unit.getScaleFromResolution(this.resolution, units, this.baseLayer.dpi);
			}
			return scale;
		}
		*/
		/**
		 * List all layers of this map
		 */
		public function get layers():Vector.<Layer> {
			var layerArray:Vector.<Layer> = new Vector.<Layer>();
			if (this.layerContainer == null) {
				return layerArray;
			}
			var s:DisplayObject;
			var i:int = this.layerContainer.numChildren - 1;
			for (i;i>-1;--i) {
				s = this.layerContainer.getChildAt(i);
				if(s is Layer) {
					layerArray.push(s);
				}
			}
			return layerArray.reverse();
		}
		/**
		 * Change the layer index (position in the display list)
		 * @param layer layer that will be updated
		 * @param newIndex its new index (0 based) 
		 * */
		public function changeLayerIndex(layer:Layer,newIndex:int):void{
			var layers:Vector.<Layer> = this.layers;
			var i:int = layers.indexOf(layer);
			var delta:int = newIndex - i;
			if(i==-1 || delta==0 || i+delta>=layers.length)
				return;
			
			i+=delta;
			if(i<0)
				return;
			
			var targetLayer:Layer = layers[i];
			var targetNum:int = this.layerContainer.getChildIndex(targetLayer);
			
			if(targetNum<0)
				return;
			
			this.layerContainer.setChildIndex(layer,targetNum);
			
			if(delta>0)
				this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVED_UP , layer));
			else
				this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVED_DOWN , layer));
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_CHANGED_ORDER, layer));
		}
		/**
		 * Change the layer index (position in the display list) by a delta relative to its current index
		 * @param layer layer that will be updated
		 * @param step value that will be added to the current index (could be negative) 
		 * */
		public function changeLayerIndexByStep(layer:Layer,step:int):void{
			var indexLayer:int = this.layerContainer.getChildIndex(layer);
			var length:int = this.layerContainer.numChildren ;
			var newIndex:int = indexLayer + step;
			if(newIndex >= 0 && newIndex < length)
			  this.layerContainer.setChildIndex(layer,newIndex);
			
			if(step>0)
				this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVED_UP , layer));
			else
				this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVED_DOWN , layer));
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_CHANGED_ORDER, layer));
		}
		
		/**
		 * List all feature layers (including layers that inherit FeatureLayer like WFS) of the map
		 **/
		public function get featureLayers():Vector.<VectorLayer> {
			var layerArray:Vector.<VectorLayer> = new Vector.<VectorLayer>();
			if (this.layerContainer == null) {
				return layerArray;
			}
			var s:DisplayObject;
			var i:int = this.layerContainer.numChildren -1;
			for (i;i>-1;--i) {
				s = this.layerContainer.getChildAt(i);
				if(s is VectorLayer) {
					layerArray.push(s);
				}
			}
			return layerArray.reverse();
		}
		
		/**
		 * Proxy (usually a PHP, Python, or Java script) used to request remote servers like
		 * WFS servers in order to allow crossdomain requests. Remote servers can be used without
		 * proxy script by using crossdomain.xml file like http://openscales.org/crossdomain.xml
		 */
		public function get proxy():String {
			return this._proxy
		}
		
		public function set proxy(value:String):void {
			this._proxy = value;
		}
		
		/**
		 * Set the configuration implementation, for example Configuration or FxConfiguration,
		 * used to parse xml configuration files.
		 */
		public function set configuration(value:IConfiguration):void{
			_configuration = value;
			_configuration.map = this;
		} 
		
		public function get configuration():IConfiguration{
			return _configuration;
		}
		
		/**
		 * Enable or disable tween effect when zooming
		 */
		public function set tweenZoomEnabled(value:Boolean):void{
			_tweenZoomEnabled = value;
		} 
		
		public function get tweenZoomEnabled():Boolean{
			return _tweenZoomEnabled;
		}
		
		/**
		 * Url to the theme used to custom the components of the current map
		 * @default URL_THEME (url to the basic OpenscalesTheme)
		 */
		public function get theme():String
		{
			return this._theme;
		}
		
		/**
		 * @private
		 */
		public function set theme(value:String):void
		{
			this._theme = value;
		}
		
		
		/**
		 * The maximum resolution of the map.
		 * If the given max resolution is inferior than the actual map resolution
		 * then the map resolution is set to the new maxResolution
		 */
		public function get maxResolution():Resolution
		{
			return this._maxResolution;
		}
		
		/**
		 * @private
		 */
		public function set maxResolution(value:Resolution):void
		{
			if (value.projection != this.projection)
			{
				value = value.reprojectTo(this.projection);
			}
			
			if(value.value < this.resolution.value)
			{
				this.resolution = new Resolution(value.value, this.projection);
			}
			this._maxResolution = value;		
			this.dispatchEvent(new MapEvent(MapEvent.MIN_MAX_RESOLUTION_CHANGED, this));
		}
		
		/**
		 * The minimum resolution of the map.
		 * You cannot reach a resolution lower than this resolution
		 * If you try to reach a resolution behind the minResolution nothing will be done
		 */
		public function get minResolution():Resolution
		{
			return this._minResolution;
		}
		
		/**
		 * @private
		 */
		public function set minResolution(value:Resolution):void
		{
			if (value.projection != this.projection)
			{
				value = value.reprojectTo(this.projection);
			}
			
			if(value.value > this.resolution.value)
			{
				this.resolution = new Resolution(value.value, this.projection);
			}
			this._minResolution = value;
			
			this.dispatchEvent(new MapEvent(MapEvent.MIN_MAX_RESOLUTION_CHANGED, this));
		}
		
	
		/**
		 * Indicates if the map is currently dragged or not
		 */
		public function get dragging():Boolean
		{
			return this._dragging;
		}
		
		/**
		 * @private
		 */
		public function set dragging(value:Boolean):void
		{
			this._dragging = value;
		}
		
		/**
		 * Whether or not the map is loading data
		 */
		public function get loadComplete():Boolean {
			return !this._loading;
		}
		
		/**
		 * Used to set loading status of map
		 */
		protected function set loading(value:Boolean):void {
			if (value == true && this._loading == false) {
				this._loading = value;
				dispatchEvent(new MapEvent(MapEvent.LOAD_START,this));
			}
			
			if (value == false && this._loading == true) {
				this._loading = value;
				dispatchEvent(new MapEvent(MapEvent.LOAD_END,this));
			} 
		}
		
		
		/**
		 * @private
		 * 
		 * Method called when the map is clicked
		 * <p>
		 * It happens that map loses focus when clicked.
		 * This method ensures that focus stays on the map object.</p>
		 */ 
		private function onMouseClick(event:MouseEvent):void
		{
			this.stage.focus = this;
		}
		
		/**
		 * Indicates the active locale key
		 */
		public function get locale():String {
			return Locale.activeLocale.localeKey;
		}
		/**
		 * @Private
		 */
		public function set locale(value:String):void {
			if(value) {
				var locale:Locale = Locale.getLocaleByKey(value);
				if(locale) {
					Locale.activeLocale = locale;
					Trace.info("Locale changed to: "+locale.localeKey);
					this.dispatchEvent(new I18NEvent(I18NEvent.LOCALE_CHANGED,locale));
				}
			}
		}
		
		
		// --- Control and Handler management -- //
		/**
		 * Add a new control to the map or register a handler as one of the handlers of the map.
		 * The handler must have its map property setted to this before.
		 * The handler is not automatically activated. If needed, you have to do
		 * it by using the active setter of the handler.
		 * For a handler, this function should only be called by the Handler.map setter !
		 * 
		 * @param control the control or handler to add.
		 * @param attach if true, the control will be added as child component of the map. This
		 *  parameter may be for example set to false when adding a Flex component displayed
		 *  outside the map.
		 */
		public function addControl(control:IHandler, attach:Boolean=true):void {
			
			// Is the input control valid ?
			if (!control) {
				Trace.warn("Map.addControl: null control not added");
				return;
			}
			
			if (!(control is IControl)) {
				// control is an IHandler
				// If no map is defined, define this one as the map
				if (!control.map) {
					control.map = this;
				} else if (control.map != this) {
					Trace.error("Map.addControl: handler not added because it is associated to an other map");
					return;
				}
			}
			
			var i:uint = 0;
			var j:uint = this._controls.length;
			for (; i<j; ++i) {
				if (control == this._controls[i]) {
					Trace.warn("Map.addControl: this control is already registered (" + getQualifiedClassName(control) + ")");
					return;
				}
				// if control is an IHandler
				if (!(control is IControl) && (getQualifiedClassName(control) == getQualifiedClassName(this._controls[i]))) {
					Trace.warn("Map.addControl: an other handler is already registered for " + getQualifiedClassName(control));
					return;
				}
			}
			
			// If the control is a new control, register it
			if (i == j) {
				Trace.log("Map.addControl: add a new control " + getQualifiedClassName(control));
				this._controls.push(control);
				
				if (control is IControl) {
					control.map = this;
					(control as IControl).draw();
					if (attach) {
						this.addChild(control as Sprite)
						if((control as Sprite))
							(control as Sprite).visible = true;
					}
				}
			}
		}
		
		/**
		 * Detects if given control or handler is linked to this map.
		 * 
		 * @return true if the control or handler controls this map, false otherwise.
		 */
		public function hasControl(control:IHandler):Boolean {
			
			return (this._controls.indexOf(control) != -1);
		}
		
		/**
		 * Removes given control from the map or unregister given handler as one of the handlers of the map.
		 * If the control or handler is not present on the map, nothing happens.
		 * The handler must have its map property setted null before or after.
		 * The handler is not automatically deactivated. You have to do it by
		 * using the active setter of the handler.
		 * For a handler, this function should only be called by the Handler.map setter !
		 * 
		 * @param control the control or handler to remove.
		 */
		public function removeControl(control:IHandler):void {
			
			var i:int = this._controls.indexOf(control);
			if (i != -1) {
				this._controls.splice(i,1);
				
				if (control is IControl) {
					if ((control as DisplayObject).parent == this) {
						this.removeChild(control as DisplayObject);
					}
					(control as IControl).destroy();
				}
				else {
					control.active = false;
					control.map = null;
				}
			}
		}
		
		/**
		 * Map controls and handlers
		 */
		public function get controls():Vector.<IHandler> {
			return this._controls;
		}
		
		/**
		 * The projection of the map. This is the display projection of the map
		 * If a layer is not in the same projection as the projection of the map
		 * he will not be displayed. 
		 * 
		 * @default EPSG:4326
		 */
		public function set projection(value:String):void
		{
			var event:MapEvent = new MapEvent(MapEvent.PROJECTION_CHANGED, this);
			event.oldProjection = this._projection;
			event.newProjection = value;
			this._projection = value;
			this._resolution = this._resolution.reprojectTo(event.newProjection);
			this._maxExtent =  this._maxExtent.reprojectTo(event.newProjection);
			this._center = this.center.reprojectTo(event.newProjection);
			this._maxResolution = this._maxResolution.reprojectTo(event.newProjection);
			this._minResolution = this._minResolution.reprojectTo(event.newProjection);
			this.dispatchEvent(event);
		}
		
		/**
		 * @private
		 */
		public function get projection():String
		{
			return this._projection;
		}
		
		/**
		 * Current resolution (units per pixel) of the map with its related projection
		 */
		public function set resolution(value:Resolution):void
		{		
			var event:MapEvent = new MapEvent(MapEvent.RESOLUTION_CHANGED, this);
			if (value.projection != this.projection)
			{
				value = value.reprojectTo(this.projection);
			}
			if (value > this.maxResolution)
			{
				value = maxResolution;
			}
			if (value < this.minResolution)
			{
				value = minResolution;
			}
			event.oldResolution = this._resolution;
			event.newResolution = value;
			event.newCenter = this.center;
			event.oldCenter = this.center;
			if (this._targetZoomPixel == null)
			{
				this._targetZoomPixel = new Pixel(this.width/2, this.height/2);
			}
			event.targetZoomPixel = this._targetZoomPixel;
			this._targetZoomPixel = null;
			this._resolution = value;
			this.dispatchEvent(event);
			Trace.log("Changing resolution"+ event.newResolution.value);
		}
		
		/**
		 * @private
		 */
		public function get resolution():Resolution {
			return this._resolution;
		}	
		
		/**
		 * The default zoomIn factor that will be used by zoomIn().
		 * This parameter must be between 0 and 1, if you try to set
		 * a value that is not between 0 and 1, and argument error is
		 * thrown
		 */
		public function set defaultZoomInFactor(value:Number):void
		{
			if (value < 0 || value > 1)
				throws(new ArgumentError);
			
			this._defaultZoomInFactor = value;
		}
		
		/**
		 * @private
		 */
		public function get defaultZoomInFactor():Number
		{
			return this._defaultZoomInFactor;
		}
		
		/**
		 * The default zoomOut factor that will be used by zoomOut().
		 * This parameter must be between above 1, if you try to set
		 * a value that is not above 1, and argument error is thrown
		 */
		public function set defaultZoomOutFactor(value:Number):void
		{
			if (value < 1)
				throws(new ArgumentError);
			
			this._defaultZoomOutFactor = value;
		}
		
		/**
		 * @private
		 */
		public function get defaultZoomOutFactor():Number
		{
			return this._defaultZoomOutFactor;
		}
	}
}
