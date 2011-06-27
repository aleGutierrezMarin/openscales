package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.GMLFormat;
	import org.openscales.core.format.WFSFormat;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.capabilities.GetCapabilities;
	import org.openscales.core.layer.params.ogc.WFSParams;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	
	/**
	 * Instances of WFS are used to display data from OGC Web Feature Services.
	 */
	public class WFS extends FeatureLayer
	{
		private var _writer:Format = null;
		
		private var _geometryColumn:String = null;
		
		private var _featuresids:HashMap = new HashMap();
		
		protected var _filter:XML;
		
		/**
		 * 	 Should the WFS layer parse attributes from the retrieved
		 *     GML? Defaults to false. If enabled, parsing is slower, but
		 *     attributes are available in the attributes property of
		 *     layer features.
		 */
		private var _extractAttributes:Boolean = true;
		
		/**
		 * An HashMap containing the capabilities of the layer.
		 */
		private var _capabilities:HashMap = null;
		
		/**
		 * Do we get capabilities ?
		 */
		private var _useCapabilities:Boolean = false;
		
		private var _capabilitiesVersion:String = "1.1.0";
		
		private var _params:WFSParams = null;
		
		protected var _request:XMLRequest = null;	
		
		private var _firstRendering:Boolean = true;
		
		private var _fullRedraw:Boolean = false;
		
		protected var _wfsFormat:WFS2Format = null;
		
		
		/**
		 * WFS class constructor
		 *
		 * @param name Layer's name
		 * @param url The WFS server url to request
		 * @param params
		 * @param isBaseLayer
		 * @param visible
		 * @param projection
		 * @param proxy
		 * @param capabilities
		 * @param useCapabilities
		 */	                    
		public function WFS(name:String,
							url:String,
							typename:String) {
			
			super(name);
			
			if (!(this.geometryColumn)) {
				this.geometryColumn = "the_geom";
			}    
			
			this.params = new WFSParams(typename);
			this.url = url;
			this._wfsFormat = new WFSFormat(this);
		}
		override public function destroy():void {
			if(this._request)
				this._request.destroy();
			this._request = null;
			if(this._wfsFormat != null)
				this._wfsFormat.destroy();
			this._wfsFormat = null;
			
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
		override public function set map(map:Map):void {
			super.map = map;
			
			// GetCapabilities request made here in order to have the proxy set 
			if (url != null && url != "" && this.capabilities == null && useCapabilities == true) {
				var getCap:GetCapabilities = new GetCapabilities("wfs", url, this.capabilitiesGetter,
					capabilitiesVersion, this.proxy);
			}
		}
		
		override public function redraw(fullRedraw:Boolean = true):void {
			this.clear();
			if (!displayed) {
				return;
			}
			if(this.useCapabilities && !this.projSrsCode)
				return;
			
			var projectedBounds:Bounds = this.map.extent.clone();
			
			if (this.projSrsCode != projectedBounds.projSrsCode) {
				projectedBounds = projectedBounds.reprojectTo(this.projSrsCode);
			}
			var center:Location = projectedBounds.center;
			
			if (projectedBounds.containsBounds(this.maxExtent)) {
				projectedBounds = this.maxExtent.clone();
			}
			
			var previousFeatureBbox:Bounds = this.featuresBbox; 
			if(previousFeatureBbox!=null)
				previousFeatureBbox = previousFeatureBbox.clone();
			//bbox are mutually exclusive with filter and featurid
			if(!_filter){
				this.params.bbox = projectedBounds.toString();
			}
			if (this._firstRendering) {
				this.featuresBbox = projectedBounds;
				this.loadFeatures(this.getFullRequestString());
				this._firstRendering = false;
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
			}
		}
		
		/**
		 * Combine the layer's url with its params and these newParams.
		 *
		 * @param newParams
		 * @param altUrl Use this as the url instead of the layer's url
		 */
		public function getFullRequestString(altUrl:String = null):String {
			var url:String;
			
			if (altUrl != null)
				url = altUrl;
			else
				url = this.url;
			
			var requestString:String = url;
			
			if (this.projSrsCode != null || this.map.baseLayer.projSrsCode != null) {
				this.params.srs = (this.projSrsCode == null) ? this.map.baseLayer.projSrsCode : this.projSrsCode;
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
		
		public function set typename(value:String):void {
			this.params.typename = value;
		}
		
		public function get typename():String {
			return this.params.typename;
		}
		
		public function get capabilities():HashMap {
			return this._capabilities;
		}
		
		public function set capabilities(value:HashMap):void {
			this._capabilities = value;
		}
		
		/**
		 * TODO: Refactor this to use events
		 *
		 * Callback method called by the capabilities retriever.
		 *
		 * @param caller The GetCapabilities instance which call it.
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
		 * Abort any pending requests and issue another request for data.
		 *
		 * Input are function pointers for what to do on success and failure.
		 *
		 * @param success
		 * @param failure
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
		 * @param request
		 */
		protected function onSuccess(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			
			this.loading = false;			
			
			if(this._wfsFormat != null)
				this._wfsFormat.reset();
			
			
			if (this.map.baseLayer.projSrsCode != null && this.projSrsCode != null && this.projSrsCode != this.map.baseLayer.projSrsCode) {
				this._wfsFormat.externalProjSrsCode = this.projSrsCode;
				this._wfsFormat.internalProjSrsCode = this.map.baseLayer.projSrsCode;
			}
			
			this.parseResponse(loader.data as String);
			
			if (map) {
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_LOAD_END, this ));
			} else {
				Trace.warn("Warning : no LAYER_LOAD_END dispatched because map event dispatcher is not defined"); 	
			}
		}
		
		public function parseResponse(wfsResponse:String):void{
			
			this._wfsFormat.read(wfsResponse);
		}
		
		public function get featuresids():HashMap {
			return this._featuresids;
		}
		
		
		
		override public function addFeature(feature:Feature, dispatchFeatureEvent:Boolean=true, reproject:Boolean=true):void {
			super.addFeature(feature,dispatchFeatureEvent, reproject);
			if(feature.layer==null)
				return;
			feature.draw();
			this._featuresids.put(feature.name,feature);
		}
		
		override public function removeFeature(feature:Feature, dispatchFeatureEvent:Boolean=true):void {
			if(feature != null){
				this._featuresids.remove(feature.name);
				super.removeFeature(feature,dispatchFeatureEvent);
			}
		}
		
		
		/**
		 * Called on return from request failure.
		 *
		 * @param event
		 */
		protected function onFailure(event:Event):void {
			this.loading = false;
			if(this._fullRedraw) {
				this._fullRedraw = false;
				this.reset();
			}
			Trace.error("Error when loading WFS request " + this.url);			
		}
		
		public function get params():WFSParams {
			return this._params;
		}
		
		public function set params(value:WFSParams):void {
			this._params = value;
		}
		
		override public function set url(value:String):void {
			this._firstRendering = true;
			super.url=value;
		}
		
		public function get writer():Format {
			return this._writer;
		}
		
		public function set writer(value:Format):void {
			this._writer = value;
		}
		
		public function get featureNS():String {
			return this._wfsFormat.featureNS;
		}
		
		public function set featureNS(value:String):void {
			this._wfsFormat.featureNS = value;
		}
		
		public function get featurePrefix():String {
			return this._wfsFormat.featurePrefix;
		}
		
		public function set featurePrefix(value:String):void {
			this._wfsFormat.featurePrefix = value;
		}
		
		public function get geometryColumn():String {
			return this._geometryColumn;
		}
		
		public function set geometryColumn(value:String):void {
			this._geometryColumn = value;
		}
		
		public function get extractAttributes():Boolean {
			return this._wfsFormat.extractAttributes;
		}
		
		public function set extractAttributes(value:Boolean):void {
			this._wfsFormat.extractAttributes = value;
		}
		
		public function get useCapabilities():Boolean {
			return this._useCapabilities;
		}
		
		public function set useCapabilities(value:Boolean):void {
			this._useCapabilities = value;
			if (value)
				this.projSrsCode = null;
		}
		
		public function set capabilitiesVersion(value:String):void {
			this._capabilitiesVersion = value;
		}
		
		public function get capabilitiesVersion():String {
			return this._capabilitiesVersion;
		}
		
		public function get filter():XML
		{
			return _filter;
		}
		
		public function set filter(value:XML):void
		{
			_filter = value;
		}
		
		
	}
}

