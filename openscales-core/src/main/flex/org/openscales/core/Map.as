package org.openscales.core
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Pixel;
	import org.openscales.basetypes.Size;
	import org.openscales.basetypes.Unit;
	import org.openscales.core.configuration.Configuration;
	import org.openscales.core.configuration.IConfiguration;
	import org.openscales.core.control.IControl;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.popup.Popup;
	import org.openscales.core.security.ISecurity;
	
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
		public var IMAGE_RELOAD_ATTEMPTS:Number = 0;
		
		/**
		 * The location at which the layer container was re-initialized (on-zoom)
		 */
		private var _layerContainerOrigin:Location = null;
		
		private var _baseLayer:Layer = null;
		private var _layerContainer:Sprite = null;
		private var _controls:Vector.<IControl> = new Vector.<IControl>();
		private var _handlers:Vector.<IHandler> = new Vector.<IHandler>();
		private var _size:Size = null;
		private var _zoom:Number = 0;
		private var _zooming:Boolean = false;
		private var _loading:Boolean;
		private var _center:Location = null;
		private var _maxExtent:Bounds = null;
		private var _destroying:Boolean = false;
		
		private var _proxy:String = null;
		private var _configuration:IConfiguration;
		
		private var _securities:Vector.<ISecurity>=new Vector.<ISecurity>();
		private var _extent:Bounds;
		/**
		 * Map constructor
		 *
		 * @param width the map's width in pixels
		 * @param height the map's height in pixels
		 */
		public function Map(width:Number=600, height:Number=400) {
			super();
			
			this.size = new Size(width, height);
			
			this._layerContainer = new Sprite();
			// It is necessary to draw something before to define the size...
			this._layerContainer.graphics.beginFill(0xFFFFFF,0);
			this._layerContainer.graphics.drawRect(0,0,this.size.w,this.size.h);
			this._layerContainer.graphics.endFill();
			// ... and then the size may be defined.
			this._layerContainer.width = this.size.w;
			this._layerContainer.height = this.size.h;
			// The sprite is now fully defined.
			this.addChild(this._layerContainer);
			
			this.addEventListener(LayerEvent.LAYER_LOAD_START,layerLoadHandler);
			this.addEventListener(LayerEvent.LAYER_LOAD_END,layerLoadHandler);						
			
			Trace.map = this;
			
			this._configuration = new Configuration();
		}
		
		private function destroy():Boolean {
			var l:Vector.<Layer> = this.layers;
			var i:int;
			if (l != null) {
				i = l.length - 1;
				for(i;i>-1;--i){
					l[i].destroy();
				}
				this.removeAllLayers();
			}
			//TODO
			if (this._controls != null) {
				i = this._controls.length - 1;
				for(i;i>-1;--i){
					this._controls[i].destroy();
				}
				this._controls = null;
			}
			return true;
		}
		
		// Layer management
		
		/**
		 * Add a new layer to the map.
		 * A LayerEvent.LAYER_ADDED event is triggered.
		 *
		 * @param layer The layer to add.
		 * @return true if the layer have been added, false if it has not.
		 */
		public function addLayer(layer:Layer):Boolean {
			var i:uint = 0;
			var j:uint = this.layers.length;
			for(; i < j; ++i) {
				if (this.layers[i] == layer) {
					return false;
				}
			}
			
			this._layerContainer.addChild(layer);
			
			layer.map = this;
			
			if (layer.isBaseLayer) {
				if (this.baseLayer == null) {
					this.baseLayer = layer;
				} else {
					layer.visible = false;
					layer.zindex = 0; 
				}
			}
			//commit temporaly to correct the fact if you  add layer dynamicaly (wms/wmcs) , that not draw the layer
			if(layer.visible){
				layer.redraw();	
			}
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_ADDED, layer));
			
			return true;
		}
		
		/**
		 * Add a group of layers.
		 * @param layers to add.
		 */
		public function addLayers(layers:Vector.<Layer>):void {
			var j:uint = layers.length;
			var i:uint = 0;
			for (i; i <  j; ++i) {
				this.addLayer(layers[i]);
			}
		}
		
		/**
		 * Allows user to specify one of the currently-loaded layers as the Map's
		 * new base layer.
		 *
		 * @param newBaseLayer the new base layer.
		 */
		public function set baseLayer(newBaseLayer:Layer):void {
			if (! newBaseLayer) {
				return;
			}
			
			var oldExtent:Bounds = (this.baseLayer) ? this.baseLayer.extent : null;
						
			if (newBaseLayer != this.baseLayer) {
				if (this.layers.indexOf(newBaseLayer) != -1) {
					// if we set a baselayer with a different projection, we
					// change the map's projected datas
					if (this.baseLayer) {
						if ((this.baseLayer.projection.srsCode != newBaseLayer.projection.srsCode)
							||(newBaseLayer.resolutions==null)) {
							// FixMe : why testing (newBaseLayer.resolutions==null) ?
							if (this.center != null)
								this.center = this.center.reprojectTo(newBaseLayer.projection);
							
							if (this._layerContainerOrigin != null)
								this._layerContainerOrigin = this._layerContainerOrigin.reprojectTo( newBaseLayer.projection);
							
							oldExtent = null;
							this.maxExtent = newBaseLayer.maxExtent;
						}
					}
					
					this._baseLayer = newBaseLayer;
					this._baseLayer.visible = true;
					
					var center:Location = this.center;
					if (center != null) {
						if (oldExtent == null) {
							this.moveTo(center, this.zoom, true);
						} else {
							this.moveTo(oldExtent.center,
								this.getZoomForExtent(oldExtent), true);
						}
					} else {
						// The map must be fully defined as soon as its baseLayer is defined
						this.moveTo(this._baseLayer.maxExtent.center,
							this.getZoomForExtent(this._baseLayer.maxExtent), true);
					}
					
					this.dispatchEvent(new LayerEvent(LayerEvent.BASE_LAYER_CHANGED, newBaseLayer));
				}
			}
		}
		
		/**
		 * The currently selected base layer.
		 * A BaseLayer is a special kind of Layer that determines the projection,
		 * min/max zoom level, etc...
		 */
		public function get baseLayer():Layer {
			return this._baseLayer;
		}
		
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
		public function removeLayer(layer:Layer, setNewBaseLayer:Boolean=true):void {
			this._layerContainer.removeChild(layer);
			layer.map = null;
			var l:Vector.<Layer> = this.layers;
			var i:int = l.indexOf(layer);
			if(i>-1)
				l.splice(i,1);
			
			if (setNewBaseLayer && (this.baseLayer == layer)) {
				this._baseLayer = null;
				i = l.length;
				
				for(var j:int=0; j < i; ++j) {
					var iLayer:Layer = l[j];
					if (iLayer.isBaseLayer) {
						this.baseLayer = iLayer;
						break;
					}
				}
			}
			
			this.dispatchEvent(new LayerEvent(LayerEvent.LAYER_REMOVED, layer));
		}
		
		public function removeAllLayers():void {
			for(var i:int=this.layers.length-1; i>=0; i--) {
				removeLayer(this.layers[i],false);
			}
		}
		
		/**
		 * Add a new control to the map.
		 *
		 * @param control the control to add.
		 * @param attach if true, the control will be added as child component of the map. This
		 *  parameter may be for example set to false when adding a Flex component displayed
		 *  outside the map.
		 */
		public function addControl(control:IControl, attach:Boolean=true):void {
			// Is the input control valid ?
			if (! control) {
				Trace.warning("Map.addControl: null control not added");
				return;
			}
			/*if (control.map != this) {
			Trace.error("Map.addControl: control not added because it is associated to an other map");
			return;
			}*/
			// Is the input control already rgistered ?
			// Or an other control of the same type ?
			var i:uint = 0;
			var j:uint = this._controls.length;
			for (; i<j; ++i) {
				if (control == this._controls[i]) {
					Trace.warning("Map.addControl: this control is already registered ("+getQualifiedClassName(control)+")");
					return;
				}
				if (getQualifiedClassName(control) == getQualifiedClassName(this.controls[i])) {
					Trace.warning("Map.addControl: an other control is already registered for "+getQualifiedClassName(control));
					return;
				}
			}
			// If the control is a new control, register it
			if (i == j) {
				Trace.log("Map.addControl: add a new control "+getQualifiedClassName(control));
				this._controls.push(control);
				control.map = this;
				control.draw();
				if (attach) {
					this.addChild(control as Sprite);
				}
			}
		}
		
		/**
		 * Register a handler as one of the handlers of the map.
		 * The handler must have its map property setted to this before.
		 * The handler is not automatically activated. If needed, you have to do
		 * it by using the active setter of the handler.
		 * This function should only be called by the Handler.map setter !
		 *  
		 * @param handler the handler to add.
		 */
		public function addHandler(handler:IHandler):void {
			// Is the input handler valid ?
			if (! handler) {
				Trace.warning("Map.addHandler: null handler not added");
				return;
			}
			
			// If not map is defined, define this one as the map
			if(!handler.map) {
				handler.map = this;
			} else if (handler.map != this) {
				Trace.error("Map.addHandler: handler not added because it is associated to an other map");
				return;
			}
			
			// Is the input handler already registered ?
			// Or an other handler of the same type ?
			var i:uint = 0;
			var j:uint = this.handlers.length;
			for (; i<j; ++i) {
				if (handler == this.handlers[i]) {
					Trace.warning("Map.addHandler: this handler is already registered ("+getQualifiedClassName(handler)+")");
					return;
				}
				if (getQualifiedClassName(handler) == getQualifiedClassName(this.handlers[i])) {
					Trace.warning("Map.addHandler: an other handler is already registered for "+getQualifiedClassName(handler));
					return;
				}
			}
			// If the handler is a new handler, register it
			if (i == j) {
				Trace.log("Map.addHandler: add a new handler "+getQualifiedClassName(handler));
				this._handlers.push(handler);
				//handler.map = this; // this is done by the Handler.map setter
			}
		}
		
		/**
		 * Unregister a handler as one of the handlers of the map.
		 * The handler must have its map property setted null before or after.
		 * The handler is not automatically deactivated. You have to do it by
		 * using the active setter of the handler.
		 * This function should only be called by the Handler.map setter !
		 * 
		 * @param handler the handler to remove.
		 */
		public function removeHandler(handler:IHandler):void {
			var newHandlers:Vector.<IHandler> = new Vector.<IHandler>();
			for each (var mapHandler:IHandler in this._handlers) {
				if (mapHandler == handler) {
					handler.active = false;
					handler.map = null;
				} else {
					newHandlers.push(mapHandler);
				}
			}
			this._handlers = newHandlers;
		}
		
		/**
		 * @param {OpenLayers.Popup} popup
		 * @param {Boolean} exclusive If true, closes all other popups first
		 **/
		public function addPopup(popup:Popup, exclusive:Boolean = true):void {
			var i:Number;
			if(exclusive){
				var child:DisplayObject;
				for(i=this._layerContainer.numChildren-1;i>=0;i--){
					child = this._layerContainer.getChildAt(i);
					if(child is Popup){
						if(child != popup) {
							Trace.warning("Map.addPopup: popup already displayed so escape");
							return;
						}
						this.removePopup(child as Popup);
					}
				}
			}
			if (popup != null){
				popup.map = this;
				popup.draw();
				this._layerContainer.addChild(popup);
			}
		}
		
		public function removePopup(popup:Popup):void {
			if(this._layerContainer.contains(popup))
				this._layerContainer.removeChild(popup);
		}
			
		/**
		 * Allows user to pan by a value of screen pixels.
		 *
		 * @param dx horizontal pixel offset
		 * @param dy verticial pixel offset
		 * @param tween use tween effect
		 */
		public function pan(dx:int, dy:int):void {
			// Is there a real offset ?
			if ((dx==0) && (dy==0)) {
				return;
			}		
			if(this.center) {
				var newCenterPx:Pixel = this.getMapPxFromLocation(this.center).add(dx, dy);
				var newCenterLonLat:Location = this.getLocationFromMapPx(newCenterPx);
				this.moveTo(newCenterLonLat);
			}
		}
		
		/**
		 * Set the map center (and optionally, the zoom level).
		 *
		 * This method shoud be refactored in order to make panning and zooming more independant.
		 *
		 * @param lonlat the new center location.
		 * @param zoom optional zoom level
		 * @param forceMove Specifies whether or not to trigger zoom change events (needed on baseLayer change)
		 *
		 */
		public function moveTo(lonlat:Location,
								  zoom:Number = NaN,
								  forceMove:Boolean = false):void {
			var zoomChanged:Boolean = forceMove || (this.isValidZoomLevel(zoom) && (zoom!=this._zoom));
			
			if (lonlat && !this.isValidLocation(lonlat)) {
				Trace.log("Not a valid center, so do nothing");
				return;
			}
			
			// If the map is not initialized, the center of the extent is used
			// as the current center
			if (!this.center && !this.isValidLocation(lonlat)) {
				lonlat = this.maxExtent.center;
			} else if(this.center && !lonlat) {
				lonlat = this.center;
			}
			var validLonLat:Boolean = this.isValidLocation(lonlat);
			var centerChanged:Boolean = validLonLat && (! lonlat.equals(this.center));
			
			if (zoomChanged || centerChanged) {
				if(this._baseLayer!=null && this._baseLayer.projection!=null) {
					lonlat = lonlat.reprojectTo(this._baseLayer.projection);
				}
				
				if (centerChanged) {
					this.dispatchEvent(new MapEvent(MapEvent.MOVE_START, this));
					if ((!zoomChanged) && (this.center)) {
						var originPx:Pixel = this.getMapPxFromLocation(this._layerContainerOrigin);
						var newPx:Pixel = this.getMapPxFromLocation(lonlat);
						
						if (originPx == null || newPx == null)
							return;
						this._layerContainer.x = originPx.x - newPx.x;
						this._layerContainer.y = originPx.y - newPx.y;
					}
					this._center = lonlat.clone();
				}
				
				if ((zoomChanged) || (this._layerContainerOrigin == null)) {
					this._layerContainerOrigin = this.center.clone();
					this._layerContainer.x = 0;
					this._layerContainer.y = 0;
				}
				
				if (zoomChanged) {
					this._zoom = zoom;
				}
				
				if (zoomChanged) {
					this.dispatchEvent(new MapEvent(MapEvent.ZOOM_END, this));
				}
			}
			
			if (centerChanged) {
				this.dispatchEvent(new MapEvent(MapEvent.MOVE_END, this));
			}
		}
				
		/**
		 * Check if a zoom level is valid on this map.
		 *
		 * @param zoomLevel the zoom level to test
		 * @return Whether or not the zoom level passed in is non-null and within the min/max
		 * range of zoom levels.
		 */
		private function isValidZoomLevel(zoomLevel:Number):Boolean {
			return (this.baseLayer && !isNaN(zoomLevel) && (zoomLevel >= this.baseLayer.minZoomLevel) && (zoomLevel <= this.baseLayer.maxZoomLevel));
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
		 * Find the zoom level that most closely fits the specified bounds. Note that this may
		 * result in a zoom that does not exactly contain the entire extent.
		 *
		 * @param bounds the extent to use
		 * @return the matching zoom level
		 *
		 */
		private function getZoomForExtent(bounds:Bounds):Number {
			var zoom:int = -1;
			if (this.baseLayer != null) {
				zoom = this.baseLayer.getZoomForExtent(bounds);
			}
			return zoom;
		}
		
		/**
		 * A suitable zoom level for the specified bounds. If no baselayer is set, returns null.
		 *
		 * @param resolution the resolution to use
		 * @return the matching zoom level
		 *
		 */
		public function getZoomForResolution(resolution:Number):Number {
			var zoom:int = -1;
			if (this.baseLayer != null) {
				zoom = this.baseLayer.getZoomForResolution(resolution);
			}
			return zoom;
		}
		
		/**
		 * Zoom to the passed in bounds, recenter.
		 *
		 * @param bounds
		 */
		public function zoomToExtent(bounds:Bounds):void {
			this.moveTo(bounds.center, this.getZoomForExtent(bounds));
		}
		
		/**
		 * Zoom to the full extent and recenter.
		 */
		public function zoomToMaxExtent():void {
			this.zoomToExtent(this.maxExtent);
		}
		
		
		/**
		 * Return a LonLat which is the passed-in view port Pixel, translated into lon/lat
		 *	by the current base layer
		 */
		public function getLocationFromMapPx(px:Pixel):Location {
			var lonlat:Location = null;
			if (this.baseLayer != null) {
				lonlat = this.baseLayer.getLonLatFromMapPx(px);
			}
			return lonlat;
		}
		
		/**
		 * Return a Pixel which is the passed-in LonLat, translated into map
		 * pixels by the current base layer
		 */
		public function getMapPxFromLocation(lonlat:Location):Pixel {
			var px:Pixel = null;
			if (this.baseLayer != null) {
				px = this.baseLayer.getMapPxFromLocation(lonlat);
			}
			return px;
		}
		
		/**
		 * Return a map Pixel computed from a layer Pixel.
		 */
		public function getMapPxFromLayerPx(layerPx:Pixel):Pixel {
			var viewPortPx:Pixel = null;
			if (layerPx != null) {
				var dX:int = int(this._layerContainer.x);
				var dY:int = int(this._layerContainer.y);
				viewPortPx = layerPx.add(dX, dY);
			}
			return viewPortPx;
		}
		
		/**
		 * Return a layer Pixel computed from a map Pixel.
		 */
		public function getLayerPxFromMapPx(mapPx:Pixel):Pixel {
			var layerPx:Pixel = null;
			if (mapPx != null) {
				var dX:int = -int(this._layerContainer.x);
				var dY:int = -int(this._layerContainer.y);
				layerPx = mapPx.add(dX, dY);
			}
			return layerPx;
		}
		
		/**
		 * Return a LonLat computed from a layer Pixel.
		 */
		public function getLocationFromLayerPx(px:Pixel):Location {
			px = this.getMapPxFromLayerPx(px);
			return this.getLocationFromMapPx(px);
		}
		
		/**
		 * Return a layer Pixel computed from a LonLat.
		 */
		public function getLayerPxFromLocation(lonlat:Location):Pixel {
			var px:Pixel = this.getMapPxFromLocation(lonlat);
			return this.getLayerPxFromMapPx(px);
		}
		
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
		 * Map center coordinates.
		 */
		public function get center():Location
		{
			return _center;
		}
		public function set center(newCenter:Location):void
		{
			this.moveTo(newCenter);
		}
		
		/**
		 * Current map zoom level.
		 */
		public function get zoom():Number
		{
			return _zoom;
		}
		public function set zoom(newZoom:Number):void 
		{
			this.moveTo(this.center, newZoom);
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
				
				if (this.baseLayer != null) {
					this.moveTo(null, this.zoom, true);
				}
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
		 * Map controls
		 */
		public function get controls():Vector.<IControl> {
			return this._controls;
		}
		
		/**
		 * Map handlers
		 */
		public function get handlers():Vector.<IHandler> {
			return this._handlers;
		}
		
		/**
		 * Map container where layers are added. It is used for panning and scaling layers.
		 */
		public function get layerContainer():Sprite {
			return this._layerContainer;
		}
		
		public function set maxExtent(value:Bounds):void {
			this._maxExtent = value;
		}
		
		/**
		 * The maximum extent for the map.
		 */
		public function get maxExtent():Bounds {
			// use map maxExtent
			var maxExtent:Bounds = this._maxExtent;
			
			// If baselayer is defined, override with baselayer maxExtent
			if (this.baseLayer) {
				maxExtent = this.baseLayer.maxExtent;
			}
			
			// If no maxExtent is defined, generate a worldwide maxExtent in the right projection
			if(maxExtent == null) {
				maxExtent = Layer.DEFAULT_MAXEXTENT;
				if (this.baseLayer && (this.baseLayer.projection.srsCode != Layer.DEFAULT_SRS_CODE)) {
					maxExtent.transform(Layer.DEFAULT_PROJECTION, this.baseLayer.projection)
				}
			}
			return maxExtent;
		}
		
		public function get extent():Bounds {
			if(_extent == null){
				var extent:Bounds = null;
				
				if ((this.center != null) && (this.resolution != -1)) {
					
					var w_deg:Number = this.size.w * this.resolution;
					var h_deg:Number = this.size.h * this.resolution;
					
					extent = new Bounds(this.center.lon - w_deg / 2,
						this.center.lat - h_deg / 2,
						this.center.lon + w_deg / 2,
						this.center.lat + h_deg / 2);
				} 
				
				return extent;
			}
			else return _extent;
		}
		public function set extent(bounds:Bounds):void {
			_extent = bounds;
		}
		public function get resolution():Number {
			return (this.baseLayer) ? this.baseLayer.resolutions[this.zoom] : NaN;
		}
		
		public function get scale():Number {
			var scale:Number = NaN;
			if (this.baseLayer) {
				var units:String = this.baseLayer.projection.projParams.units;
				scale = Unit.getScaleFromResolution(this.resolution, units);
			}
			return scale;
		}
		
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
		
		public function get featureLayers():Vector.<Layer> {
			var layerArray:Vector.<Layer> = new Vector.<Layer>();
			if (this.layerContainer == null) {
				return layerArray;
			}
			var s:DisplayObject;
			var i:int = this.layerContainer.numChildren -1;
			for (i;i>-1;--i) {
				s = this.layerContainer.getChildAt(i);
				if(s is FeatureLayer) {
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
		
		public function set configuration(value:IConfiguration):void{
			_configuration = value;
		} 
		
		public function get configuration():IConfiguration{
			return _configuration;
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
	}
}

