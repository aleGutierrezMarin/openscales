package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.format.gml.GMLFormat;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.layer.capabilities.GetCapabilities;
	import org.openscales.core.layer.params.ogc.WFSParams;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Instances of WFS are used to display data from OGC Web Feature Services.
	 * It supports 1.0.0, 1.1.0 and 2.0.0 versions of WFS standard.
	 */
	public class WFS extends VectorLayer
	{
		private var _currentScale:uint = 0;
		private var _initialized:Boolean = false;
		
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
		private var _version:String = "1.0.0";
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
							version:String = "1.0.0")
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
			
			if (this.projSrsCode != null || this.map.projection != null) {
				this.params.srs = (this.projSrsCode == null) ? this.map.projection : this.projSrsCode;
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
					version, this.proxy);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function redraw(fullRedraw:Boolean = true):void {
			/*
			
			if(this.useCapabilities && !this.projSrsCode)
				return;
			
			var projectedBounds:Bounds = this.map.extent.clone();
			var projectedMaxExtent:Bounds = this.maxExtent;
			
			if (this.projSrsCode != projectedBounds.projSrsCode) {
				projectedBounds = projectedBounds.reprojectTo(this.projSrsCode);
				projectedMaxExtent = projectedMaxExtent.reprojectTo(this.projSrsCode);
			}
			
			var center:Location = projectedBounds.center;
			
			if (projectedBounds.containsBounds(projectedMaxExtent)) {
				projectedBounds = projectedMaxExtent.clone();
			}
			
			var previousFeatureBbox:Bounds = this.featuresBbox; 
			if(previousFeatureBbox!=null)
				previousFeatureBbox = previousFeatureBbox.clone();
			//bbox are mutually exclusive with filter and featurid
			if(this.params.version == "1.1.0" && ProjProjection.projAxisOrder[this.projSrsCode]!=ProjProjection.AXIS_ORDER_EN)
				this.params.bbox = projectedBounds.toString(-1,false);
			else
				this.params.bbox = projectedBounds.toString();
			
			if (this._firstRendering) {
				this.featuresBbox = projectedBounds;
				this.loadFeatures(this.getFullRequestString());
				this._firstRendering = false;
				this.draw();
			} else {
				// Use GetCapabilities to know if all features have already been retreived.
				// If they are, we don't request data again
				if (fullRedraw || (!previousFeatureBbox.containsBounds(projectedBounds)
					&& ((this.capabilities == null) || (this.capabilities != null && !this.featuresBbox.containsBounds(this.capabilities.getValue("Extent")))))){
					if(fullRedraw && this.features.length>0) {
						this._fullRedraw = true;
					}
					this.featuresBbox = projectedBounds;
					this.loadFeatures(this.getFullRequestString());
					this.draw();
				}else {
					this.loading = true;
					this.draw();
					this.loading = false;
				}
			}*/
			
			if (!this.available)
			{
				this.clear();
				this._initialized = false;
				return;
			}
			
			if (!this._initialized)
			{
				this.featuresBbox = this.defineBounds();
				this.loadFeatures(this.getFullRequestString());
				this._initialized = true;
			}
			if (this._centerChanged || this._projectionChanged || this._resolutionChanged)
			{
				var previousFeatureBbox:Bounds = this.featuresBbox;
				this.featuresBbox = this.defineBounds();
				
				if (this._centerChanged && !this._resolutionChanged)
				{
					if (!previousFeatureBbox.containsBounds(this.featuresBbox))
					{
						this.loadFeatures(this.getFullRequestString());
					}
					this._centerChanged = false;
				}
				if (this._resolutionChanged)
				{
					if (this._currentScale > 5)
					{
						this._currentScale = 0;
						if (!previousFeatureBbox.containsBounds(this.featuresBbox))
						{
							this.loadFeatures(this.getFullRequestString());
						}
						this.x = 0;
						this.y = 0;
						this.scaleX = 1;
						this.scaleY = 1;
						this.resetFeaturesPosition();
						this.draw();
					}
					this._resolutionChanged = false;
				}
				if (this._projectionChanged)
				{
					this._projectionChanged = false;
				}
			}
		}
		
		override protected function onMapResolutionChanged(event:MapEvent):void
		{
			var px:Pixel = new Pixel(this.map.mouseX, this.map.mouseY);
			var ratio:Number = event.oldResolution.value / event.newResolution.value;
			this.x -= (px.x - this.x) * (ratio - 1);
			this.y -= (px.y - this.y) * (ratio - 1);
			this.scaleX = this.scaleX * ratio;
			this.scaleY = this.scaleY * ratio;
			this._currentScale++;
			this._resolutionChanged = true;
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
			
			if (this.projSrsCode != mapExtent.projSrsCode)
			{
				mapExtent = mapExtent.preciseReprojectBounds(mapExtent,mapExtent.projSrsCode,this.projSrsCode);
				//fix bug
				layerMaxExtent.projSrsCode = "EPSG:4326";
				layerMaxExtent = layerMaxExtent.preciseReprojectBounds(layerMaxExtent,layerMaxExtent.projSrsCode,this.projSrsCode);
			}
			
			//fix bug
			if(!(mapExtent.left == 0 && mapExtent.right == 0 && mapExtent.bottom == 0 && mapExtent.top == 0))
				layerExtent = mapExtent.getIntersection(layerMaxExtent);
			else
				layerExtent = layerMaxExtent.clone();
			
			// Update the bbox
			if (layerExtent != null)
			{
				if (this.params.version == "1.1.0" && ProjProjection.projAxisOrder[this.projSrsCode] != ProjProjection.AXIS_ORDER_EN)
					this.params.bbox = layerExtent.toString(-1, false);
				else
					this.params.bbox = layerExtent.toString();
			}
			
			// Return the bounds
			return layerExtent;
		}
		
		override protected function onMapCenterChanged(event:MapEvent):void
		{
			if (!this._resolutionChanged)
			{
				var deltaLon:Number = event.newCenter.lon - event.oldCenter.lon;
				var deltaLat:Number = event.newCenter.lat - event.oldCenter.lat;
				var deltaX:Number = deltaLon / this.map.resolution.value;
				var deltaY:Number = deltaLat / this.map.resolution.value;
				this.x -= deltaX;
				this.y += deltaY;
				super.onMapCenterChanged(event);
			}
		}
		
		override public function get available():Boolean
		{
			if (this.useCapabilities && !this.projSrsCode)
				return false;
			
			if (!this.defineBounds())
				return false;
			
			return true;
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
			if ((this._capabilities != null) && (this.projSrsCode == null || this.useCapabilities)) {
				this.projSrsCode = this._capabilities.getValue("SRS");
				if(this.map)
					this.redraw();
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
			this._gmlFormat.externalProjSrsCode = this.projSrsCode;
			this._gmlFormat.internalProjSrsCode = this.map.projection;
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
			feature.draw();
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
				this.projSrsCode = null;
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

