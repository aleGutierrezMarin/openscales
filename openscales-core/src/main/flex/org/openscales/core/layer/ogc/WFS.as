package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.gml.GMLFormat;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.layer.capabilities.GetCapabilities;
	import org.openscales.core.layer.params.ogc.WFSParams;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.proj4as.ProjProjection;
	import org.osmf.events.TimeEvent;
	
	/**
	 * Instances of WFS are used to display data from OGC Web Feature Services.
	 * It supports 1.0.0, 1.1.0 and 2.0.0 versions of WFS standard.
	 */
	public class WFS extends VectorLayer
	{
		private var _writer:Format = null;
		
		/**
		 * @private
		 * An HashMap containing the capabilities of the layer.
		 */
		private var _capabilities:HashMap = null;
		/**
		 * @private
		 * Do we use get capabilities?
		 */
		private var _useCapabilities:Boolean = false;
		
		/**
		 * @private
		 * WFS version
		 */
		private var _version:String = "2.0.0";
		/**
		 * @private
		 * WFS params
		 */
		private var _params:WFSParams = null;
		/**
		 * @private
		 * the xmlrequest used in the layer. It prevents simultaneous requests.
		 */ 
		protected var _request:XMLRequest = null;
		
		/**
		 * @private
		 * Indicates if the layer haven't been displayed yet.
		 */
		private var _firstRendering:Boolean = true;
		/**
		 * @private
		 * Indicates if the layer should be fully redrawn
		 */
		private var _fullRedraw:Boolean = false;
		
		protected var _gmlFormat:GMLFormat = null;
		
		private var _currentScale:uint = 0;
		
		private const  _MAX_NUMBER_OF_SCALES:uint = 5;
		
		private var _previousCenter:Location = null;
		
		private var _previousResolution:Resolution = null;
		
		/**
		 * @private
		 * Hashmap containing id of features that have allready been drawn
		 */
		private var _featuresids:HashMap = new HashMap();
		
		/**
		 * WFS class constructor
		 *
		 * @param Layer's name
		 * @param The WFS server url to request
		 * @param the WFS typename
		 * @param The wfs version
		 */	                    
		public function WFS(name:String,
							url:String,
							typename:String,
							
							version:String = "2.0.0")
		{
			super(name);

			this._params = new WFSParams(typename, version);
			this.url = url;
			
			this._gmlFormat = new GMLFormat(this.addFeature,
				this.featuresids,
				true);
			this.version = version;
		}
		
		/**
		 * Combine the layer's url with its params.
		 * 
		 * @return the full request url 
		 */
		public function getFullRequestString():String {
			
			var requestString:String = this.url;
			
			if (this.projection != null || this.map.projection != null) {
				if(this.version=="1.0.0")
					this.params.srs = (this.projection == null) ? this.map.projection.srsCode : this.projection.srsCode;
				else
					this.params.srs = (this.projection == null) ? this.map.projection.urnCode : this.projection.urnCode;
			}
			
			var lastServerChar:String = url.charAt(url.length - 1);
			if ((lastServerChar == "&") || (lastServerChar == "?")) {
				requestString += this.params.toGETString();
			} 
			else {
				if (url.indexOf('?') == -1) {
					requestString += '?' + this.params.toGETString();
				} 
				else {
					requestString += '&' + this.params.toGETString();
				}
			}
			
			return requestString;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if(this._request)
				this._request.destroy();
			this._request = null;
			
			if(!this._featuresids){
				var farray:Array = this._featuresids.getValues();
				var i:uint = farray.length;
				for(;i>0;--i)
					this.removeFeature(farray.pop(),true);
				this._featuresids.clear();
				this._featuresids = null;
			}
			super.destroy();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set map(map:Map):void {
			super.map = map;
			// GetCapabilities request made here in order to have the proxy set 
			if (url != null && url != "" && this.capabilities == null && useCapabilities == true) {
				var getCap:GetCapabilities = new GetCapabilities("wfs", url, this.capabilitiesGetter,
					version, this.proxy, this.security);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function redraw(fullRedraw:Boolean = false):void {
			
			if (this.map == null)
				return;
			
			if(this.aggregate){
				this.visible = this.aggregate.shouldIBeVisible(this,this.map.resolution);
			}
			
			
			if (!this.available || !this.visible)
			{
				this.clear();
				this._initialized = false;
				return;
			}
			
			var centerChangedCache:Boolean = this._centerChanged;
			var resolutionChangedCache:Boolean = this._resolutionChanged;
			var projectionChangedCache:Boolean = this._projectionChanged;
			var mapReloadCache:Boolean = this._mapReload;
			this._centerChanged = false;
			this._projectionChanged = false;
			this._resolutionChanged = false;
			this._mapReload = false;
			if (fullRedraw)
			{
				this.clear();
			}
			
			if (!this._initialized || fullRedraw)
			{
				this.featuresBbox = this.defineBounds();
				this.loadFeatures(this.getFullRequestString());
				this._currentScale = 0;
				this.x = 0;
				this.y = 0;
				this.scaleX = 1;
				this.scaleY = 1;
				this.resetFeaturesPosition();
				this.draw();
				this._previousResolution = this.map.resolution;
				this._previousCenter = this.map.center.clone();
				this._initialized = true;
				return;
			}
			if (mapReloadCache)
			{
				this.actualizeFeatures();
			}
			if (resolutionChangedCache)
			{
				this.cacheAsBitmap = false;
				var ratio:Number = this._previousResolution.value / this.map.resolution.value;
				this.scaleLayer(ratio, new Pixel(this.map.size.w/2, this.map.size.h/2));
				this._previousResolution = this.map.resolution;
				resolutionChangedCache = false;
				this.cacheAsBitmap = true;
			}
			
			if (centerChangedCache)
			{
				var deltaLon:Number = this.map.center.lon - this._previousCenter.lon;
				var deltaLat:Number = this.map.center.lat - this._previousCenter.lat;
				var deltaX:Number = deltaLon/this.map.resolution.value;
				var deltaY:Number = deltaLat/this.map.resolution.value;
				
				this.x = this.x - deltaX;
				this.y = this.y + deltaY;
				this._previousCenter = this.map.center.clone();
				centerChangedCache = false;
			}
		}
		
		private function actualizeFeatures():void
		{
			var previousFeatureBbox:Bounds;
			previousFeatureBbox = this.featuresBbox;
			this.featuresBbox = this.defineBounds();
			
			if (!previousFeatureBbox.containsBounds(this.featuresBbox))
			{
				this.loadFeatures(this.getFullRequestString());
			}
			previousFeatureBbox = this.featuresBbox;
			this.featuresBbox = this.defineBounds();
			
			/*if (!previousFeatureBbox.containsBounds(this.featuresBbox))
			{
				this.loadFeatures(this.getFullRequestString());
			}*/
			this._currentScale = 0;
			this.x = 0;
			this.y = 0;
			this.scaleX = 1;
			this.scaleY = 1;
			this.resetFeaturesPosition();
			this.draw();
			var evt:MapEvent = new MapEvent(MapEvent.ACTIVATE_HANDLER, this.map);
			this.map.dispatchEvent(evt);
		}
		
		private function scaleLayer(scale:Number, offSet:Pixel = null):void
		{
			if (offSet == null)
			{
				offSet = new Pixel(0, 0);
			}
			var temporaryScale:Number = this.scaleX * scale;
			this.scaleX = this.scaleY = temporaryScale;
			this.x -= (offSet.x - this.x) * (scale - 1);
			this.y -= (offSet.y - this.y) * (scale - 1);
		}
		
		private function onTimerEnd(event:TimerEvent):void
		{
			// To activate (if needed) SelectFeaturesHandler

			
			this._centerChanged = true;
			this._resolutionChanged = true;
		}
		
		override protected function onMapResolutionChanged(event:MapEvent):void
		{
			// To disactivate (if needed) SelectFeaturesHandler
			var evt:MapEvent = new MapEvent(MapEvent.DISACTIVATE_HANDLER, this.map);
			this.map.dispatchEvent(evt);
			super.onMapResolutionChanged(event);
		}
		
		private function defineBounds():Bounds
		{
			var layerMaxExtent:Bounds;
			var mapExtent:Bounds;
			var layerExtent:Bounds;
			
			// Define the maxExtent of the layer
			if (this.capabilities != null)
			{
				layerMaxExtent = this.capabilities.getValue("Extent");
			}
			else
				layerMaxExtent = this.maxExtent;
			
			// Intersect with the extent of the map
			mapExtent = this.map.extent.clone();
			
			if (this.projection != mapExtent.projection)
			{
				mapExtent = mapExtent.preciseReprojectBounds(this.projection);
				layerMaxExtent = layerMaxExtent.preciseReprojectBounds(this.projection);
			}
			
			if (!(mapExtent.width == 0 || mapExtent.height == 0))
				layerExtent = mapExtent.getIntersection(layerMaxExtent);
			else
				layerExtent = layerMaxExtent.clone();
			
			// Update the bbox
			if (layerExtent != null)
			{
				if (this.params.version != "1.0.0" && !this.projection.lonlat)
					this.params.bbox = layerExtent.toString(-1, false);
				else
					this.params.bbox = layerExtent.toString();
			}
			
			// Return the bounds
			return layerExtent;
		}
		
		override protected function checkAvailability():Boolean
		{
			return (super.checkAvailability() && this.defineBounds() && (!this.useCapabilities || this.projection))
		}
		
		/**
		 * Indicates the WFS typename
		 */
		public function get typename():String {
			return this.params.typename;
		}
		/**
		 * @private
		 */
		public function set typename(value:String):void {
			this.params.typename = value;
		}
		/**
		 * Indicates the capabilities result
		 */
		public function get capabilities():HashMap {
			return this._capabilities;
		}
		/**
		 * @private
		 */
		public function set capabilities(value:HashMap):void {
			this._capabilities = value;
		}
		
		/**
		 * Callback method called by the capabilities retriever.
		 *
		 * @param the GetCapabilities instance which call it.
		 */
		public function capabilitiesGetter(caller:GetCapabilities):void {
			if (this.params != null) {
				this._capabilities = caller.getLayerCapabilities(this.params.typename);
			}
			if ((this._capabilities != null) && (this.projection == null || this.useCapabilities)) {
				this.projection = this._capabilities.getValue("SRS");
				//Setting availableProjections
				var aProj:Vector.<String> = new Vector.<String>();
				aProj.push(this._capabilities.getValue("SRS"));
				var otherSRS:Vector.<String> = (this._capabilities.getValue("OtherSRS") as Vector.<String>);
				for each(var oSrs:String in otherSRS) {
					if(aProj.indexOf(oSrs) < 0) {
						aProj.push(oSrs);
					}
				}
				this.availableProjections = aProj;
				
				if(this.map)
					this.redraw(true);
			}
		}
		
		/**
		 * Perform the request allowing to get features.
		 * It aborts any pending requests and issue another request for data.
		 *
		 * @param the url to request
		 */
		protected function loadFeatures(url:String):void {		
			if (map) {
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_LOAD_START, this ));
			} else {
				Trace.warn("Warning : no LAYER_LOAD_START dispatched because map event dispatcher is not defined");
			}
			
			if(_request)
				_request.destroy();
			this.loading = true;
			
			_request = new XMLRequest(url, onSuccess, onFailure);
			_request.proxy = this.proxy;
			_request.security = this.security;
			_request.send();
		}
		
		/**
		 * Called on return from request succcess.
		 *
		 * @param the success event
		 */
		protected function onSuccess(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			
			this.loading = false;
			
			if(this.map)
				this.parseResponse(loader.data as String);
			
			if (map) {
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_LOAD_END, this ));
			} else {
				Trace.warn("Warning : no LAYER_LOAD_END dispatched because map event dispatcher is not defined"); 	
			}
		}
		
		/**
		 * Parse the wfs response
		 * 
		 * @param the xml corresponding to the wfs response
		 */
		public function parseResponse(wfsResponse:String):void{
			this._gmlFormat.externalProjection = this.projection;
			this._gmlFormat.internalProjection = this.map.projection;
			this._gmlFormat.read(wfsResponse);
			//this._wfsFormat.read(wfsResponse);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addFeature(feature:Feature, dispatchFeatureEvent:Boolean=true, reproject:Boolean=true):void {
			if(!feature)
				return;
			super.addFeature(feature,dispatchFeatureEvent, reproject);
			if(feature.layer==null)
				return;
			this._featuresids.put(feature.name,feature);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeFeature(feature:Feature, dispatchFeatureEvent:Boolean=true):void {
			if(feature != null){
				this._featuresids.remove(feature.name);
				super.removeFeature(feature,dispatchFeatureEvent);
			}
		}
		
		/**
		 * Called on return from request failure.
		 *
		 * @param the failure event
		 */
		protected function onFailure(event:Event):void {
			this.loading = false;
			if(this._fullRedraw) {
				this._fullRedraw = false;
				this.reset();
			}
			Trace.error("Error when loading WFS request " + this.url);			
		}
		
		// getters setters
		
		/**
		 * Indicates the id of features allready displayed
		 */
		public function get featuresids():HashMap {
			return this._featuresids;
		}
		
		/**
		 * Indicates the wfs params
		 */
		public function get params():WFSParams {
			return this._params;
		}
		/**
		 * @private
		 */
		public function set params(value:WFSParams):void {
			this._params = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set url(value:String):void {
			this._firstRendering = true;
			super.url=value;
		}
		
		/**
		 * Indicates if capabilities should be used.
		 * Default false
		 */
		public function get useCapabilities():Boolean {
			return this._useCapabilities;
		}
		/**
		 * @private
		 */
		public function set useCapabilities(value:Boolean):void {
			this._useCapabilities = value;
			if (value)
				this.projection = null;
			this.available = this.checkAvailability();
		}
		
		/**
		 * Indicates the wfs version.
		 * Default 1.0.0
		 */
		public function get version():String {
			return this._version;
		}
		/**
		 * @private
		 */
		public function set version(value:String):void {
			this._version = value;
			if(this._params != null)
				this._params.version = value;
			switch (value) {
				case "1.0.0":
					this._gmlFormat.version = "2.1.1";
					break;
				case "1.1.0":
					this._gmlFormat.version = "3.1.1";
					break;
				case "2.0":
				case "2.0.0":
					this._version = "2.0.0";
					this._gmlFormat.version = "3.2.1";
					break;
				default:
					this._gmlFormat.version = null;
			}
		}
		
		/**
		 * Indicates if vectorial data attributes must be extracted from the XML or if only
		 * the object geometry is extracted 
		 */
		public function get extractAttributes():Boolean {
			return this._gmlFormat.extractAttributes;
		}
		/**
		 * @private
		 */
		public function set extractAttributes(value:Boolean):void {
			this._gmlFormat.extractAttributes = value;
		}
	}
}

