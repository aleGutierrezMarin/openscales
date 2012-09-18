package org.openscales.core
{
	import flash.display.DisplayObject;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ShaderFilter;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.configuration.IConfiguration;
	import org.openscales.core.control.Control;
	import org.openscales.core.control.IControl;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.i18n.Locale;
	import org.openscales.core.i18n.provider.I18nJSONProvider;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.popup.Popup;
	import org.openscales.core.security.ISecurity;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	import org.osmf.events.TimeEvent;
	
	use namespace os_internal;

	// LAYER EVENTS
	
	/**
	 * @eventType org.openscales.core.events.LayerEvent.LAYER_ADDED  
	 */
	[Event(name="openscales.addlayer", type="org.openscales.core.events.LayerEvent")]
	
	/**
	 * @eventType org.openscales.core.events.LayerEvent.LAYER_REMOVED
	 */
	[Event(name="openscales.removelayer", type="org.openscales.core.events.LayerEvent")]
	
	/** 
	 * Dispatched when a layer is moved up in the layer manager
	 * 
	 * @eventType org.openscales.core.events.LayerEvent.LAYER_MOVED_UP 
	 */ 
	[Event(name="openscales.layerMovedUp", type="org.openscales.core.events.LayerEvent")]
	
	/** 
	 * Dispatched when a layer is moved down in the layer manager
	 * 
	 * @eventType org.openscales.core.events.LayerEvent.LAYER_MOVED_DOWN 
	 */ 
	[Event(name="openscales.layerMovedDown", type="org.openscales.core.events.LayerEvent")]
	
	/**
	 * @eventType org.openscales.core.events.LayerEvent.LAYER_CHANGED_ORDER
	 */
	[Event(name="openscales.layerChangeOrder", type="org.openscales.core.events.LayerEvent")]
	
	// MAP EVENTS
	/**
	 * @eventType org.openscales.core.events.MapEvent.MOVE_START
	 */
	[Event(name="openscales.mapmovestart", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.MOVE_END
	 */
	[Event(name="openscales.mapmoveend", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.LAYERS_LOAD_START
	 */
	[Event(name="openscales.layersloadstart", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.LAYERS_LOAD_END
	 */
	[Event(name="openscales.layersloadend", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.CENTER_CHANGED
	 */
	[Event(name="openscales.mapcenterchanged", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.RESIZE
	 */
	[Event(name="openscales.mapresize", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.MAX_EXTENT_CHANGED
	 */
	[Event(name="openscales.maxextentchanged", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.MIN_MAX_RESOLUTION_CHANGED
	 */
	[Event(name="openscales.minMaxresolutionChanged", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.PROJECTION_CHANGED
	 */
	[Event(name="openscales.mapprojectionchanged", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.RESOLUTION_CHANGED
	 */
	[Event(name="openscales.mapresolutionchanged", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * @eventType org.openscales.core.events.MapEvent.RELOAD
	 */
	[Event(name="openscales.mapreload", type="org.openscales.core.events.MapEvent")]
	
	// I18N EVENTS
	/**
	 * This event is dispatched when the locale has changed
	 *
	 *  @eventType org.openscales.core.events.I18NEvent.LOCALE_CHANGED
	 *  
	 */
	[Event(name="openscales.localeChanged", type="org.openscales.core.events.I18NEvent")]
	
	/**
	 * Instances of Map are interactive maps that can be embedded in a web pages or in
	 * Flex or AIR applications.
	 *
	 * <p>
	 * Create a new map with the Map constructor.
	 * </p>
	 * <p>
	 * To extend a map, it's necessary to add controls (Control), handlers (Handler) and
	 * layers (Layer) to the map.
	 * </p>
	 * <p>	
	 * Map is responsible for event dispatching. In component/layer/etc... documentation, listed events are dispatched by the map (expect when specified). 
	 * </p>
	 * <p>
	 * Map is a pure ActionScript class. Flex wrapper and components can be found in the
	 * openscales-fx module.
	 * </p>
	 */
	public class Map extends Sprite
	{
		/**
		 * Default Resolution of the map. The projection of the resolution is the Geometry.DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_RESOLUTION:Resolution = new Resolution(1, Geometry.DEFAULT_SRS_CODE);
		/**
		 * Default MaxExtent of the map. The projection of the maxExtent is the Geometry.DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_MAX_EXTENT:Bounds = new Bounds(-180, -90, 180, 90, Geometry.DEFAULT_SRS_CODE);
		/**
		 * Default Center of the map. The projection of the center is the Geometry.DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_CENTER:Location = new Location(0, 0, Geometry.DEFAULT_SRS_CODE);
		/**
		 * Default Min Resolution of the map. The projection of the min resolution is the Geometry.DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_MIN_RESOLUTION:Resolution = new Resolution(0.0000000001, Geometry.DEFAULT_SRS_CODE);
		/**
		 * Default Max Resolution of the map. The projection of the max resolution is the Geometry.DEFAULT_SRS_CODE
		 */
		public static const DEFAULT_MAX_RESOLUTION:Resolution = new Resolution(1.5, Geometry.DEFAULT_SRS_CODE);
		/**
		 * Default zoomIn factor
		 */
		public static const DEFAULT_ZOOM_IN_FACTOR:Number = 0.75;
		/**
		 * Default zoomIn factor
		 */
		public static const DEFAULT_ZOOM_OUT_FACTOR:Number = 1.33;
		
		/**
		 * DEfault map reload timeout in ms for setCenter
		 */
		public static const DEFAULT_MAP_RELOAD_TIMEOUT_CENTER:Number = 50;
		
		/**
		 * DEfault map reload timeout in ms for setResolution
		 */
		public static const DEFAULT_MAP_RELOAD_TIMEOUT_RES:Number = 300;
		
		/**
		 * Number of attempt for downloading an image tile
		 */
		public var IMAGE_RELOAD_ATTEMPTS:Number = 0;
		/**
		 * The url to the default Theme (OpenscalesTheme)
		 * TODO : fix and set the real path to  the default theme
		 */
		public var URL_THEME:String = "http://openscales.org/nexus/service/local/repo_groups/public-snapshots/content/org/openscales/openscales-fx-theme/2.0.0-SNAPSHOT/openscales-fx-theme-2.0.0-20110517.142043-5.swf";
		
		private var _size:Size = null;
		
		private var _zooming:Boolean = false;
		private var _dragging:Boolean = false;
		private var _loading:Boolean = false;
		protected var _center:Location = DEFAULT_CENTER;
		
		private var _maxExtent:Bounds = DEFAULT_MAX_EXTENT;
		private var _restrictedExtent:Bounds = null;
		
		private var _destroying:Boolean = false;
		
		private var _proxy:String = null;
		// list of domains that does'nt require proxy
		private var _noProxyDomains:Array = new Array();
		
		private var _configuration:IConfiguration;
		
		private var _securities:Vector.<ISecurity>=new Vector.<ISecurity>();
		
		private var _projection:ProjProjection = null;
		private var _resolution:Resolution = DEFAULT_RESOLUTION;
		private var _initialized:Boolean = false;
		private var _backTileColor:uint = 0xFFFFFF;
		private var _timer:Timer;
		private var _resizeTimer:Timer;
		
		// Layer used for OpenLS search and for geolocation
		private var _resultLayer:VectorLayer = new VectorLayer("Search results");
		
		/**
		 * @private
		 * The minimum resolution of the map
		 * @default 0 in Geometry.DEFAULT_SRS_CODE
		 */
		private var _minResolution:Resolution = DEFAULT_MIN_RESOLUTION;
		/**
		 * @private
		 * The maximum resolution of the map
		 * @default 1.5 in Geometry.DEFAULT_SRS_CODE
		 */
		private var _maxResolution:Resolution = DEFAULT_MAX_RESOLUTION;
		private var _defaultZoomInFactor:Number = DEFAULT_ZOOM_IN_FACTOR;
		private var _defaultZoomOutFactor:Number = DEFAULT_ZOOM_OUT_FACTOR;
		private var _targetZoomPixel:Pixel = null;
		
		private var _debug_max_extent:Boolean = false;
		
		private var _extenTDebug:Shape;
		
		private var _loadingLayers:Vector.<Layer> = new Vector.<Layer>();
		
		
		//we maintain a list of controls and layers
		private var _controls:Vector.<IHandler> = new Vector.<IHandler>();
		private var _layers:Vector.<Layer> = new Vector.<Layer>();
		
		//We have a container for all layers
		// => DO NOT USER FOR DRAG, PAN ...
		private var _layersContainer:Sprite;
		
		private var _mouseNavigationEnabled:Boolean = true;
		private var _backGround:Shape;
		private var _panNavigationEnabled:Boolean = true;
		private var _zoomNavigationEnabled:Boolean = true;
		private var _doubleclickZoomEnabled:Boolean = true;
		private var _keyboardNavigationEnabled:Boolean = true;
		private var _clickedPoint:Pixel = new Pixel(0,0);
		
		/** 
		 * @private
		 * Url to the theme used to custom the components of the current map
		 * @default URL_THEME (url to the basic OpenscalesTheme)
		 */
		private var _theme:String = URL_THEME;
		
		//Source file for i18n english translation
		[Embed(source="/assets/i18n/EN.json", mimeType="application/octet-stream")]
		private const ENLocale:Class;
		[Embed(source="/assets/i18n/FR.json", mimeType="application/octet-stream")]
		private const FRLocale:Class;
		
		[Embed(source="/assets/tone_mapping.pbj", mimeType="application/octet-stream")]
		public const toneMappingFilterClass:Class;	
		private var _toneMappingFilter:ShaderFilter;
		private var _toneMappingActive:Boolean;
		
		private var _toneMappingBuffer:Array;

		private var notice:ContextMenuItem = null;
		/**
		 * Map constructor
		 *
		 * @param width the map's width in pixels
		 * @param height the map's height in pixels
		 * @param projection the map's projection
		 */
		public function Map(width:Number=600, height:Number=400, projection:*=null) {
			super();
			
			/**
			 * Contextual informations
			 */
			try {
				var menu:ContextMenu = new ContextMenu();
				menu.hideBuiltInItems();
				notice = new ContextMenuItem("Powered by OpenScales");
				notice.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openLink);
				menu.customItems.push(notice);
				contextMenu = menu;
			}
			catch(e:Error) {
				// if mobile, no contextmenu
			}
			
			//load i18n module
			I18nJSONProvider.addTranslation(ENLocale);
			I18nJSONProvider.addTranslation(FRLocale);
			
			Catalog.catalog.addEventListener(I18NEvent.LOCALE_CHANGED, this.localeChanged);
			this._timer = new Timer(DEFAULT_MAP_RELOAD_TIMEOUT_CENTER,1);
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimerEnd);
			this._resizeTimer = new Timer(100,1);
			this._resizeTimer.addEventListener(TimerEvent.TIMER, this.applyResize);
			this.projection = projection;
			this.size = new Size(width, height);
			// It is necessary to draw something before to define the size...
			this.graphics.beginFill(_backTileColor,0);
			this.graphics.drawRect(0,0,this.size.w,this.size.h);
			this.graphics.endFill();
			// ... and then the size may be defined.
			this.width = this.size.w;
			this.height = this.size.h;
			
			this._resultLayer.displayInLayerManager = false;
			this._resultLayer.editable = false;
			
			if (_debug_max_extent)
			{
				this.addEventListener(Event.ENTER_FRAME, this.onDraw);
			}
			
			Trace.stage = this.stage;
			
			this.focusRect = false;// Needed to hide yellow rectangle around map when focused
			this.addEventListener(MouseEvent.CLICK, onMouseClick); //Needed to prevent focus losing 
			
			this.addEventListener(LayerEvent.LAYER_LOAD_START, onLayerLoadStart);
			this.addEventListener(LayerEvent.LAYER_LOAD_END, onLayerLoadEnd);
			
			//Init the layers container
			this._layersContainer = new Sprite();
//			this._layersContainer.width = this.width;
//			this._layersContainer.height = this.height;
			this.addChildAt(this._layersContainer, 0);
			
			var shader:Shader = new Shader(new toneMappingFilterClass() );
			this._toneMappingFilter = new ShaderFilter( shader );
			this._layersContainer.filters = [];
			this._toneMappingActive = false;
			
			this._initialized = true;
			//this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			
		}
		
		/*public function onMouseDown(evt:MouseEvent):void
		{
			this._clickedPoint = new Pixel(this.mouseX, this.mouseY);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		public function onMouseUp(evt:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if ((Math.abs(this._clickedPoint.x - this.mouseX) < 2) && (Math.abs(this._clickedPoint.y - this.mouseY) < 2))
			{
				var clickEvent:MapEvent = new MapEvent(MapEvent.MOUSE_CLICK, this);
				this.dispatchEvent(clickEvent);
			}
			
		}*/
		
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
		
		// Layer management
		/**
		 * Add a new layer to the map.
		 * A LayerEvent.LAYER_ADDED event is triggered.
		 *
		 * @param layer The layer to add.
		 * @return true if the layer have been added, false if it has not.
		 */
		public function addLayer(layer:Layer, redraw:Boolean = true):Boolean {
			if(this._layers.indexOf(layer)!=-1)
				return false;
			
			/**
			 * As layers should allways be at the bottom of the display list,
			 * we use the firsts display indexes for layers. The size of the
			 * _layer vector correspond to the first index not used
			 * by a layer!
			 */
			this._layersContainer.addChildAt(layer,this._layers.length);
			this._layers.push(layer);
			layer.map = this;
			
			//If a search layer has been added, we force it to be on top
			var resultIndex:int = this.layers.indexOf(this.resultLayer);
			if(resultIndex != -1)
			{
				this.changeLayerIndex(this.resultLayer, this._layers.length -1);
			}
			
			if (redraw){
				layer.redraw(redraw);	
			}
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_ADDED, layer));
			
			return true;
		}
		
		// manage layers
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
		 * Get a layer from its identifier.
		 * @param identifier the layer identifier to find.
		 * @return the found layer. Null if no layer have been found.
		 *
		 */
		public function getLayerByIdentifier(identifier:String):Layer {
			var i:uint = this._layers.length;
			if(i>0) {
				for(;i>0;--i)
					if(this._layers[i-1].identifier == identifier)
						return this._layers[i-1];
			}
			return null;
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
			var i:int = this._layers.indexOf(layer);
			var j:int = this._loadingLayers.indexOf(layer);
			if(i==-1)
				return;
			
			this._layers.splice(i,1);
			
			if(j==-1)
				this._loadingLayers.splice(j,1);
			
			layer.map = null;
			this._layersContainer.removeChild(layer);
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_REMOVED, layer));
			
		}
		
		/**
		 * Remove all layers of the map
		 */
		public function removeAllLayers():void {
			for(var i:int=this._layers.length-1; i>=0; i--) {
				removeLayer(this._layers[i]);
			}
		}
		
		/**
		 * Change the layer index (position in the display list)
		 * @param layer layer that will be updated
		 * @param newIndex its new index (0 based) 
		 * */
		public function changeLayerIndex(layer:Layer,newIndex:int):void{	
			if(newIndex<0 || newIndex>=this._layers.length)return;
			var currentIndex:int = this._layers.indexOf(layer);
			if(currentIndex<0)return;
			var delta:int = newIndex - currentIndex;
			this.changeLayerIndexByDelta(layer,delta);
		}
		/**
		 * Change the layer index (position in the display list) by a delta relative to its current index
		 * @param layer layer that will be updated
		 * @param delta value that will be added to the current index (could be negative) 
		 * */
		public function changeLayerIndexByDelta(layer:Layer,delta:int):void{
			var currentIndex:int = this._layers.indexOf(layer);
			var length:int = this._layers.length;
			var newIndex:int = currentIndex + delta;
			if(currentIndex==-1 || delta==0 || newIndex<0 || newIndex>=this._layers.length)
				return;
			
			this._layersContainer.setChildIndex(layer,newIndex);
			
			if(delta>0) {
				this._layers.splice(currentIndex,1);
				this._layers.splice(newIndex,0,layer);
				this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVED_UP , layer));
			}
			else {
				this._layers.splice(currentIndex,1);
				this._layers.splice(newIndex,0,layer);
				this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVED_DOWN , layer));
			}
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_CHANGED_ORDER, layer));
		}
		
		// popup management
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
		 */
		public function pan(dx:int, dy:int):void {
			// Is there a real offset ?
			if ((dx==0) && (dy==0)) {
				return;
			}		
			if(this.center) {
				var newCenterLocation:Location = this.center.add(dx*this.resolution.value, -dy*this.resolution.value);
				if(isValidExtentWithRestrictedExtent(newCenterLocation, this.resolution))
					this.center = newCenterLocation;
			}
		}
		
		// zoom management
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
		public function zoomBy(factor:Number, targetPixel:Pixel = null):void
		{
			if (factor < 0)
				throw(new ArgumentError);
			
			var _newResolution:Number = this.resolution.value * factor;
			
			if (targetPixel == null)
			{
				targetPixel = this.getMapPxFromLocation(this.center);
			}
			this.zoomTo(new Resolution(_newResolution, this.resolution.projection), targetPixel);
			
		}
		
		/**
		 * Zoom to the given extent
		 * Change the map center and resolution to be at the exetnt given
		 *
		 * @param bounds
		 */
		public function zoomToExtent(bounds:Bounds):void 
		{
			var newBounds:Bounds = this.maxExtent.getIntersection(bounds);
			
			if( newBounds )
			{
				this.dispatchEvent(new MapEvent(MapEvent.MOVE_START, this));
				if(newBounds.projection != this.projection)
					newBounds = newBounds.reprojectTo(this.projection);
				
				var x:Number = (newBounds.left + newBounds.right)/2;
				var y:Number = (newBounds.top + newBounds.bottom)/2;
				this.center = new Location(x, y, this.projection);
				
				var resolutionX:Number = (newBounds.right - newBounds.left) / this.size.w;
				var resolutionY:Number = (newBounds.top - newBounds.bottom) / this.size.h;
				
				// choose max resolution to be sure that all the extent is include in the current map
				var resolution:Number = (resolutionX > resolutionY) ? resolutionX : resolutionY;
				this.resolution = new Resolution(resolution, this.projection);
				
				this.dispatchEvent(new MapEvent(MapEvent.MOVE_END, this));
			}
		}
		
		/**
		 * Zoom to the full extent and recenter.
		 */
		public function zoomToMaxExtent():void {
			this.zoomToExtent(this.maxExtent);
		}
		
		// location management
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
		public function getMapPxFromLocation(lonlat:Location, res:Resolution = null, extent:Bounds = null):Pixel {
			if (!lonlat)
				return null;
			
			if (!res)
			{
				res = this.resolution;
			}
			
			if(!ProjProjection.isEquivalentProjection(lonlat.projection, this.projection)) {
				lonlat.reprojectTo(this.projection);
			}
			
			var px:Pixel = null;
			var b:Bounds = this.getExtentForResolution(res);
			if (extent)
				b = extent;
			
			if (lonlat != null && b) {
				
				px = new Pixel((lonlat.lon - b.left) / res.value, (b.top - lonlat.lat) / res.value);
			}	
			return px;
		}
		
		// security management
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
		
		public function getExtentForResolution(resolution:Resolution):Bounds
		{
			var extent:Bounds = null;
			
			if (this.center != null) {
				var center:Location;
				if(this.center.projection != this.projection)
					center = this.center.reprojectTo(this.projection);
				else
					center = this.center;
				var w_deg:Number = this.size.w * resolution.value;
				var h_deg:Number = this.size.h * resolution.value;
				
				extent = new Bounds(center.lon - w_deg / 2,
					center.lat - h_deg / 2,
					center.lon + w_deg / 2,
					center.lat + h_deg / 2,
					center.projection);
			} 
			
			return extent;
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
				return;
			}
			
			if (!(control is IControl)) {
				// control is an IHandler
				// If no map is defined, define this one as the map
				if (!control.map) {
					control.map = this;
				} else if (control.map != this) {
					return;
				}
			}
			
			var i:uint = 0;
			var j:uint = this._controls.length;
			for (; i<j; ++i) {
				if (control == this._controls[i]) {
					return;
				}
				// if control is an IHandler
				if (!(control is IControl) && (getQualifiedClassName(control) == getQualifiedClassName(this._controls[i]))) {					return;
				}
			}
			
			// If the control is a new control, register it
			if (i == j) {
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
					if ((control as DisplayObject).parent == this)
						this.removeChild(control as DisplayObject);
					(control as IControl).destroy();
				}
				else {
					control.active = false;
					control.map = null;
				}
			}
		}
		
		/**
		 * This method will hide all visual controls of the map
		 * 
		 * <p>Control won't be desactivated, their <code>visible</code> property will only be set to false</p>
		 * 
		 * <p>To revert the method effect, use <code>showAllControls</code></p>
		 */ 
		public function hideAllControls():void{
			for each(var handler:IHandler in this._controls){
				if(handler is Control) 
					(handler as Control).visible = false;
			}
		}
		
		/**
		 * This method will show all visual controls of the map
		 * 
		 * <p>For each control, its <code>visible</code> property will be set to true</p>
		 */ 
		public function showAllControls():void{
			for each(var handler:IHandler in this._controls){
				if(handler is Control) 
					(handler as Control).visible = true;
			}
		}
		
		protected function onLayerLoadStart(e:LayerEvent):void
		{
			// fisrt layer load : dispatch layers load
			if(this._loadingLayers.length == 0)
			{
				this._loading = true;
				this.dispatchEvent(new MapEvent(MapEvent.LAYERS_LOAD_START, this));
			}
			
			if(this._loadingLayers.indexOf(e.layer)<0) this._loadingLayers.push(e.layer);
		}
		
		protected function onLayerLoadEnd(e:LayerEvent):void
		{
			var i:int = this._loadingLayers.indexOf(e.layer);
			if(i==-1)
				return;
			
			this._loadingLayers.splice(i,1);
			
			if(this._loadingLayers.length == 0)
			{
				this._loading = false;
				this.dispatchEvent(new MapEvent(MapEvent.LAYERS_LOAD_END, this));
			}
		}
		
		private function openLink(e:ContextMenuEvent):void{
			navigateToURL(new URLRequest("http://www.openscales.org"));
		}
		private function localeChanged(event:I18NEvent):void {
			if(event.locale == Locale.activeLocale) {
				this.dispatchEvent(new I18NEvent(I18NEvent.LOCALE_CHANGED,Locale.activeLocale));
			}
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
		private function onDraw(event:Event):void
		{
			if (_extenTDebug == null)
			{
				_extenTDebug = new Shape();
			} else
			{
				_extenTDebug.graphics.clear();
			}
			var extent:Bounds = this.maxExtent;
			var topLeft:Pixel = this.getMapPxFromLocation(new Location(extent.left, extent.top));
			var bottomRight:Pixel = this.getMapPxFromLocation(new Location(extent.right, extent.bottom));
			
			_extenTDebug.graphics.beginFill(0xFF0000, 0.3);
			_extenTDebug.graphics.drawRect(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
			_extenTDebug.graphics.endFill();
			this.addChild(_extenTDebug);
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
			
			if (resolutionChanged) {
				
				mapEvent = new MapEvent(MapEvent.MOVE_START, this);
				this.dispatchEvent(mapEvent);
				
				var zoomTargetLoc:Location = this.getLocationFromMapPx(zoomTarget);
				var deltaX:Number = zoomTarget.x - this.width/2;
				var deltaY:Number = zoomTarget.y - this.height/2;
				var deltaLon:Number = deltaX*targetResolution.value;
				var deltaLat:Number = deltaY*targetResolution.value;
				var newCenter:Location = new Location(zoomTargetLoc.lon - deltaLon, zoomTargetLoc.lat + deltaLat, this.center.projection);
				
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
					if(!this.maxExtent.containsLocation(zoomTargetLoc) || !this.maxExtent.containsLocation(newCenter)){
						this.center = new Location(this.width/2,this.height/2,this.center.projection);
					}
					else{
						this.center = newCenter;
					}
				}
				
				mapEvent = new MapEvent(MapEvent.MOVE_END, this);
				this.dispatchEvent(mapEvent);
			}
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
		 * Check if the extent define around a Location is contains by the restrictedExtent
		 * 
		 * @param extent The center of the extent to check
		 */
		os_internal function isValidExtentWithRestrictedExtent(center:Location, resolution:Resolution):Boolean
		{
			if(!restrictedExtent)
				return true;
			
			if (resolution.projection != this.projection)
			{
				resolution = resolution.reprojectTo(this.projection);
				
				if (resolution.value > this.maxResolution.value)
				{
					resolution = maxResolution;
				}
				if (resolution.value < this.minResolution.value)
				{
					resolution = minResolution;
				}
			}
			
			
			var bounds:Bounds = new Bounds(center.lon-this.width/2*resolution.value,
				center.lat-this.height/2*resolution.value,
				center.lon+this.width/2*resolution.value,
				center.lat+this.height/2*resolution.value,
				this.projection);
			
			return restrictedExtent.containsBounds(bounds);
		}
		
		/**
		 * Change the map resolution and center to displayed all the available datas according to the restrictedExtent
		 * 
		 * If the restrictedExtent has different ratio than the current viewer, limit the extent at the minimum resolution
		 */
		os_internal function zoomToRestrictedExtent():void
		{
			if( restrictedExtent )
			{
				// remove restricted extent otherwise change center and resolution won't appear
				var tmpExtent:Bounds = restrictedExtent.clone();
				this._restrictedExtent = null;
				
				this.dispatchEvent(new MapEvent(MapEvent.MOVE_START, this));
				
				if(tmpExtent.projection != this.projection)
					tmpExtent = tmpExtent.reprojectTo(this.projection);
				
				var x:Number = (tmpExtent.left + tmpExtent.right)/2;
				var y:Number = (tmpExtent.top + tmpExtent.bottom)/2;
				
				// change resolution first
				var resolutionX:Number = (tmpExtent.right-tmpExtent.left) / this.width;
				var resolutionY:Number = (tmpExtent.top-tmpExtent.bottom) / this.height;
				
				// choose min resolution to be sure that no allowed data are displayed
				var resolution:Number = (resolutionX < resolutionY) ? resolutionX : resolutionY;
				this.resolution = new Resolution(resolution, this.projection);
				
				// change the center				
				this.center = new Location(x, y, this.projection);
				
				// Put back the restricted value :
				this._restrictedExtent = tmpExtent.clone();
				
				this.dispatchEvent(new MapEvent(MapEvent.MOVE_END, this));
			}
		}
		
		/**
		 * Default layer used for search results
		 */
		public function get resultLayer():VectorLayer
		{
			return _resultLayer;
		}
		
		/**
		 * Map center coordinates
		 */
		public function get center():Location
		{
			return _center;
		}
		/**
		 * @private
		 */
		public function set center(newCenter:Location):void
		{
			var event:MapEvent = new MapEvent(MapEvent.CENTER_CHANGED, this);
			event.oldCenter = this._center;
			event.newCenter = newCenter;
			event.oldResolution = this.resolution;
			event.newResolution = this.resolution;
			if (newCenter.projection != this.projection)
				newCenter = newCenter.reprojectTo(this.projection);
			
			// only change center according to restrictedExtent
			if(!isValidExtentWithRestrictedExtent(newCenter, this.resolution))
				return;
			
			if (this.maxExtent.containsLocation(newCenter))
			{
				this._center = newCenter;
				this._timer.reset();
				this._timer.start();
				if(this._toneMappingActive && !this._toneMappingBuffer && this._layersContainer)
				{
					this._toneMappingBuffer = this._layersContainer.filters;
					this._layersContainer.filters = [];
				}
				this.dispatchEvent(event);
			}
			

		}
		/**
		 * Map size in pixels.
		 */
		public function get size():Size {
			return (_size) ? _size.clone() : null;
		}
		/**
		 * @private
		 */
		public function set size(value:Size):void {
			if (value) {
				var theEvent:MapEvent = new MapEvent(MapEvent.RESIZE, this);
				theEvent.oldSize = this._size;
				theEvent.newSize = value;
				_size = value;
				this._resizeTimer.reset();
				this._resizeTimer.start();
				this.dispatchEvent(theEvent);
				//this.dispatchEvent(new MapEvent(MapEvent.RELOAD,this));
				
			} else {
				Trace.error("Map - size not changed since the value is not valid");
			}
		}
		
		/**
		 * Callback that will apply the mapResize.
		 * We use a timer to handle resize to avoid the flashplayer to use CPU during smooth resizing 
		 * of the flashContainer.
		 * Using too much CPU may result in flash player kill in some browsers.
		 */
		private function applyResize(event:TimerEvent):void
		{
			
			this.graphics.clear();
			this.graphics.beginFill(_backTileColor);
			this.graphics.drawRect(0,0,this.size.w,this.size.h);
			this.graphics.endFill();
			this.scrollRect = new Rectangle(0,0,this.size.w,this.size.h);
			this.dispatchEvent(new MapEvent(MapEvent.RELOAD,this))
		}
		
		/**
		 * back tile color
		 */
		public function get backTileColor():uint
		{
			return this._backTileColor;
		}
		/**
		 * @private
		 */
		public function set backTileColor(value:uint):void
		{
			this._backTileColor = value;
			this.graphics.clear();
			this.graphics.beginFill(_backTileColor);
			this.graphics.drawRect(0,0,this.size.w,this.size.h);
			this.graphics.endFill();
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
		 * The maximum extent for the map.
		 * Datas out of maxEtent are not requested
		 */
		public function get maxExtent():Bounds {
			
			if(!restrictedExtent)
				return this._maxExtent;
			
			if(this._maxExtent.containsBounds(this._restrictedExtent))
				return this._restrictedExtent;
			
			return this._maxExtent;
		}
		/**
		 * @private
		 */
		public function set maxExtent(value:Bounds):void {
			if(value)
			{
				if (value.projection != this.projection)
				{
					value = value.preciseReprojectBounds(this.projection);
				}
				
				var event:MapEvent = new MapEvent(MapEvent.MAX_EXTENT_CHANGED, this);
				event.oldMaxExtent = this._maxExtent;
				event.newMaxExtent = value;
				
				this._maxExtent = value;
				
				this.dispatchEvent(event);
			}
		}
		
		/**
		 * The RestrictedExtent to pan or zoom the map
		 * If the asked resolution display more datas than the restrictedExtent bounds allowed, 
		 * the map is center to the restrictedExtent
		 * 
		 * @default null no constraint
		 */
		public function get restrictedExtent():Bounds
		{
			return _restrictedExtent;
		}
		
		/**
		 * @private
		 */
		public function set restrictedExtent(value:Bounds):void
		{
			if(value)
			{
				if (value.projection != this.projection)
				{
					value = value.preciseReprojectBounds(this.projection);
				}
				_restrictedExtent = value;
				
				var current:Bounds = this.extent;
				if(!restrictedExtent.containsBounds(current))
					this.zoomToRestrictedExtent();
			}
			else
				_restrictedExtent = null;
		}
		
		/**
		 * Extent currently displayed in the map.
		 */
		public function get extent():Bounds {
			var extent:Bounds = null;
			if ((this.center != null) && (this.resolution != null)) {
				var center:Location;
				if(this.center.projection != this.projection)
					center = this.center.reprojectTo(this.projection);
				else
					center = this.center;
				var w_deg:Number = this.size.w * this.resolution.value;
				var h_deg:Number = this.size.h * this.resolution.value;
				extent = new Bounds(center.lon - w_deg / 2,
					center.lat - h_deg / 2,
					center.lon + w_deg / 2,
					center.lat + h_deg / 2,
					center.projection);
			} 
			return extent;
			
		}
		/**
		 * List all layers of this map
		 */
		public function get layers():Vector.<Layer> {
			var layerArray:Vector.<Layer> = new Vector.<Layer>();
			var i:int = this._layers.length- 1;
			for (i;i>-1;--i) {
				layerArray.push(this._layers[i]);
			}
			return layerArray.reverse();
		}
		
		/**
		 * List all feature layers (including layers that inherit FeatureLayer like WFS) of the map
		 **/
		public function get featureLayers():Vector.<VectorLayer> {
			var layerArray:Vector.<VectorLayer> = new Vector.<VectorLayer>();
			if (this._layers== null) {
				return layerArray;
			}
			var i:int = this._layers.length -1;
			var s:Layer;
			for (i;i>-1;--i) {
				s = this._layers[i];
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
		/**
		 * @private
		 */
		public function set proxy(value:String):void {
			this._proxy = value;
		}
		
		/**
		 * In case of proxy definition, this allow to define domains that do not require proxy.
		 */
		public function get noProxyDomains():Array {
			return this._noProxyDomains;
		}
		/**
		 * @private
		 */
		public function set noProxyDomains(value:Array):void {
			this._noProxyDomains = value;
		}
		
		/**
		 * Set the configuration implementation, for example Configuration or FxConfiguration,
		 * used to parse xml configuration files.
		 */
		public function set configuration(value:IConfiguration):void {
			_configuration = value;
			_configuration.map = this;
		}
		/**
		 * @private
		 */
		public function get configuration():IConfiguration{
			return _configuration;
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
			
			this._maxResolution = value;
			if(this._maxResolution.value < this._resolution.value)
			{
				this._resolution = this._maxResolution;
			}
			
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
			
			this._minResolution = value;
			if(this._minResolution.value >= this.resolution.value)
			{
				this.resolution = this._minResolution;
			}
			
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
		 * Indicates if the layers of the map are currently loading or not
		 */
		public function get loading():Boolean
		{
			return this._loading;
		}
		/**
		 * @private
		 */
		public function set loading(value:Boolean):void
		{
			this._loading = value;
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
					this.dispatchEvent(new I18NEvent(I18NEvent.LOCALE_CHANGED,locale));// kept for backward compatibility 
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
		 * @default Geometry.DEFAULT_SRS_CODE
		 */
		public function get projection():ProjProjection
		{
			return this._projection;
		}
		/**
		 * @private
		 */
		public function set projection(value:*):void
		{
			var proj:ProjProjection = null;
			proj = ProjProjection.getProjProjection(value);
			if(proj == null)
				proj = ProjProjection.getProjProjection(Geometry.DEFAULT_SRS_CODE);
			if(proj == this.projection)
				return;
			var event:MapEvent = new MapEvent(MapEvent.PROJECTION_CHANGED, this);
			event.oldProjection = this._projection;
			event.newProjection = proj;
			this._projection = proj;
			this._resolution = this._resolution.reprojectTo(event.newProjection);
			this._maxExtent =  this._maxExtent.preciseReprojectBounds(event.newProjection);
			this._center = this.center.reprojectTo(event.newProjection);
			this._maxResolution = this._maxResolution.reprojectTo(event.newProjection);
			this._minResolution = this._minResolution.reprojectTo(event.newProjection);
			this._timer.reset();
			this._timer.start();
			if(this._toneMappingActive && !this._toneMappingBuffer && this._layersContainer)
			{
				this._toneMappingBuffer = this._layersContainer.filters;
				this._layersContainer.filters = [];
			}
			this.dispatchEvent(event);
		}
		
		/**
		 * Current resolution (units per pixel) of the map with its related projection
		 */
		public function get resolution():Resolution {
			return this._resolution;
		}
		/**
		 * @private
		 */
		public function set resolution(value:Resolution):void
		{		
			var event:MapEvent = new MapEvent(MapEvent.RESOLUTION_CHANGED, this);
			if (value.projection != this.projection)
			{
				value = value.reprojectTo(this.projection);
			}
			if (value.value > this.maxResolution.value)
			{
				value = maxResolution;
			}
			if (value.value < this.minResolution.value)
			{
				value = minResolution;
			}
			
			// only change resolution according to restrictedExtent
			if(!isValidExtentWithRestrictedExtent(this.center, value))
			{
				this.zoomToRestrictedExtent();
				return;
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
			this._timer.reset();
			this._timer.removeEventListener(TimerEvent.TIMER, this.onTimerEnd);
			this._timer = new Timer(DEFAULT_MAP_RELOAD_TIMEOUT_RES, 1);
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimerEnd);
			this._timer.start();
			if(this._toneMappingActive && !this._toneMappingBuffer && this._layersContainer)
			{
				this._toneMappingBuffer = this._layersContainer.filters;
				this._layersContainer.filters = [];
			}
		}	
		
		/**
		 * The default zoomIn factor that will be used by zoomIn().
		 * This parameter must be between 0 and 1, if you try to set
		 * a value that is not between 0 and 1, and argument error is
		 * thrown
		 */
		public function get defaultZoomInFactor():Number
		{
			return this._defaultZoomInFactor;
		}
		/**
		 * @private
		 */
		public function set defaultZoomInFactor(value:Number):void
		{
			if (value < 0 || value > 1) {
				Trace.warn("Map.defaultZoomInFactor: bad value");
				throw(new ArgumentError);
			}
			
			this._defaultZoomInFactor = value;
		}
		
		/**
		 * The default zoomOut factor that will be used by zoomOut().
		 * This parameter must be between above 1, if you try to set
		 * a value that is not above 1, and argument error is thrown
		 */
		public function get defaultZoomOutFactor():Number
		{
			return this._defaultZoomOutFactor;
		}
		/**
		 * @private
		 */
		public function set defaultZoomOutFactor(value:Number):void
		{
			if (value < 1) {
				Trace.warn("Map.defaultZoomOutFactor: bad value");
				throw(new ArgumentError);
			}
			
			this._defaultZoomOutFactor = value;
		}
		
		override public function set contextMenu(cm:ContextMenu):void {
			try {
				if(!cm) {
					cm = new ContextMenu();
					cm.hideBuiltInItems();
				}
				if(cm.customItems.indexOf(this.notice)==-1)
					cm.customItems.push(notice);
				super.contextMenu = cm;
			} catch(e:Error) {
				// if mobile, no contextmenu
			}
		}
		
		/**
		 * Draw a debug shape on the map representig the maxExtent
		 */
		public function get debug_max_extent():Boolean
		{
			return _debug_max_extent;
		}
		/**
		 * @private
		 */
		public function set debug_max_extent(value:Boolean):void
		{
			_debug_max_extent = value;
		}
		
		/**
		 * The state of the map. True if the map initialization is complete.
		 */
		public function get mapInitialized():Boolean
		{
			return this._initialized;
		}
		/**
		 * @private
		 */
		public function set mapInitialized(value:Boolean):void
		{
			this._initialized = value;
		}
		
		/**
		 * To enabled/disabled mouse navigation
		 */
		public function get mouseNavigationEnabled():Boolean
		{
			return _mouseNavigationEnabled;
		}
		/**
		 * @private
		 */
		public function set mouseNavigationEnabled(value:Boolean):void
		{
			_mouseNavigationEnabled = value;
		}
		
		/**
		 * To enabled/disabled the zoom on double click
		 */
		public function get doubleclickZoomEnabled():Boolean
		{
			return this._doubleclickZoomEnabled
		}
		
		
		/**
		 * @private
		 */
		public function set doubleclickZoomEnabled(value:Boolean):void
		{
			this._doubleclickZoomEnabled = value;
		}
		
		/**
		 * To enabled/disabled pan navigation
		 */
		public function get panNavigationEnabled():Boolean
		{
			return _panNavigationEnabled;
		}
		/**
		 * @private
		 */
		public function set panNavigationEnabled(value:Boolean):void
		{
			_panNavigationEnabled = value;
		}	
		
		/**
		 * To enabled/disabled zoom navigation
		 */
		public function get zoomNavigationEnabled():Boolean
		{
			return _zoomNavigationEnabled;
		}
		/**
		 * @private
		 */
		public function set zoomNavigationEnabled(value:Boolean):void
		{
			_zoomNavigationEnabled = value;
		}
		
		/**
		 * To enabled/disabled keyboard navigation
		 */
		public function get keyboardNavigationEnabled():Boolean
		{
			return _keyboardNavigationEnabled;
		}
		/**
		 * @private
		 */
		public function set keyboardNavigationEnabled(value:Boolean):void
		{
			_keyboardNavigationEnabled = value;
		}
		
		private function onTimerEnd(event:TimerEvent):void
		{
			this._timer.stop();
			this._timer.removeEventListener(TimerEvent.TIMER, this.onTimerEnd)
			this._timer = new Timer(DEFAULT_MAP_RELOAD_TIMEOUT_CENTER, 1);
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimerEnd);
			var mapevent:MapEvent = new MapEvent(MapEvent.RELOAD, this);
			this.dispatchEvent(mapevent);
			if(this._toneMappingBuffer && this._layersContainer)
			{
				if(this._toneMappingBuffer.length == 0)
					this._toneMappingBuffer = null
				else
				{
					this._layersContainer.filters = this._toneMappingBuffer;
					this._toneMappingBuffer = null;
				}
			}
		}
		
		/**
		 * Return the identifier list of the edited vector layers that are in the map
		 * Edited layers are vector layer which have been modified by the drawing tools
		 */
		public function getEditedLayers():Vector.<String>
		{
			var identifierList:Vector.<String> = new Vector.<String>();
			var length:int = this.layers.length;
			for (var i:int = 0; i<length; ++i)
			{
				if (this.layers[i] is VectorLayer)
				{
					if ((this.layers[i] as VectorLayer).edited)
					{
						identifierList.push(this.layers[i].identifier)
					}
				}
			}
			return identifierList;
		}
		
		/**
		 * Return the list of the editable vector layers that are in the map
		 * Editable layers are vector layer which can be modified by the drawing tools
		 */
		public function getEditableLayers():Vector.<VectorLayer>
		{
			var resultList:Vector.<VectorLayer> = new Vector.<VectorLayer>();
			var length:int = this.layers.length;
			for (var i:int = 0; i<length; ++i)
			{
				if (this.layers[i] is VectorLayer)
				{
					if ((this.layers[i] as VectorLayer).editable)
					{
						resultList.push(this.layers[i] as VectorLayer)
					}
				}
			}
			return resultList;
		}
		
		/**
		 * Return the indentifier list of the layers that are in the map
		 */
		public function getMapLayers():Vector.<String>
		{
			var identifierList:Vector.<String> = new Vector.<String>();
			var length:int = this.layers.length;
			for (var i:int = 0; i<length; ++i)
			{
				identifierList.push(this.layers[i].identifier)
			}
			return identifierList;
		}
		
		public function getProxy(value:String):String {
			if(!value)
				return null;
			if(this._noProxyDomains) {
				var i:uint = this._noProxyDomains.length;
				for(;i>0;--i) {
					if(value.indexOf(this._noProxyDomains[i-1])!=-1)
						return null;
				}
			}
			return this._proxy;
		}
		
		/**
		 * Toggle the activation of the tone mapping filter
		 */
		public function toggleToneMapping():void
		{
			if(this._toneMappingActive)
			{
				this._layersContainer.filters = [];
				this._toneMappingActive = false;
			}
			else
			{
				this._layersContainer.filters = [this._toneMappingFilter];
				this._toneMappingActive = true;
			}
		}
		
		
		public function get toneMappingActive():Boolean
		{
			return _toneMappingActive;
		}
		
		public function set toneMappingActive(value:Boolean):void
		{
			_toneMappingActive = value;
		}
	}
}
