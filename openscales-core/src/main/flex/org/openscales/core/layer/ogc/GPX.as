package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.format.GPXFormat;
	import org.openscales.core.layer.IFileUser;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.utils.Trace;
	
	/**
	 * GPX layer; versions 1.0 and 1.1 supported 
	 * 
	 * @param name the name of the layer
	 * @param version
	 * @param url the url of the file that contains the gpx data
	 * @param data the file that contains the gpx data
	 * The data and url params are not compatible with each other
	 * The data projection for this layer is set to "EPSG:4326" by default (@see class Layer)
	 * @see GPX 1.1 specification: all coordinates are relative to the WGS84 datum
	 * 
	 */
	public class GPX extends VectorLayer implements IFileUser
	{
		private static const ACCEPTED_FILE_EXTENSIONS:Vector.<String> = new <String>["xml","gpx"];
		
		private var _featureVector:Vector.<Feature> = null;
		private var _gpxFormat:GPXFormat;
		
		private var _request:XMLRequest = null;
		private var _version:String;
		
		private var _extractAttributes:Boolean;
		private var _extractWaypoints:Boolean;
		private var _extractTracks:Boolean;
		private var _extractRoutes:Boolean;
		
		public function GPX(name:String, 
							version:String=null,
							url:String = null,
							data:XML = null,
							style:Style = null,
							extractWaypoints:Boolean = true,
							extractTracks:Boolean = true,
							extractRoutes:Boolean = true,
							extractAttributes:Boolean = true)
		{
			this._projection = "EPSG:4326";
			this.version = version;
			this.url = url;	
			this.data = data;
			super(name);
			
			if(style){
				this.style = style;
				this.style.rules.push(new Rule());
			}
			else this.style = null;
			
			this.gpxFormat = new GPXFormat(new HashMap(),version,extractWaypoints,extractTracks,extractRoutes,extractAttributes);	
		}
		
		override public function redraw(fullRedraw:Boolean = true):void {
			
			if (this.map == null)
				return;
			
			if (!displayed) {
				this.clear();
				return;
			}
			if (url)
			{
				if (! this._request) {
					this.loading = true;
					this._request = new XMLRequest(url, onSuccess, onFailure);
					this._request.proxy = this.proxy;
					this._request.security = this.security;
					this._request.send();
				} else {
					this.clear();
					this.draw();
				}	
			}
			else if (this.data)
			{	
				this.drawFeatures();				
			}
			else
			{
				this.clear();
				this.draw();
			}
		}
		
		public function onSuccess(event:Event):void
		{
			this.loading = false;
			var loader:URLLoader = event.target as URLLoader;
			this.data = new XML(loader.data);
			if (this.data)
				this.drawFeatures();	
		}
		
		protected function onFailure(event:Event):void {
			this.loading = false;
			Trace.error("Error when loading gpx file" + this.url);			
		} 
		
		public function drawFeatures():void{
			
			if(this._featureVector == null) {
				
				var pointStyle:Style = Style.getDefaultPointStyle();
				var lineStyle:Style = Style.getDefaultLineStyle();
				
				var lineStringFeatureVector:Vector.<Feature>= new Vector.<Feature>(); 
				var pointFeatureVector:Vector.<Feature> = new Vector.<Feature>();
				
				pointStyle.rules.push(new Rule());
				lineStyle.rules.push(new Rule());
				pointStyle.rules[0].symbolizers.push(new PointSymbolizer(new Marker(7, 3,2)));
				lineStyle.rules[0].symbolizers.push(new LineSymbolizer(new Stroke(0x008800,1,1,Stroke.LINECAP_BUTT)));
				
				this._featureVector = this.gpxFormat.read(this.data) as Vector.<Feature>;
				var i:uint;
				var vectorLength:uint = this._featureVector.length;
				for (i = 0; i < vectorLength; i++){
					
					if(this.style){
						this._featureVector[i].style = this.style;
					}
					else//default style
					{
						if(this._featureVector[i] is PointFeature) {
							this._featureVector[i].style = pointStyle;
							pointFeatureVector.push(this._featureVector[i]);
						}
						else{ // feature is linestring or multilinestring
							this._featureVector[i].style = lineStyle;
							lineStringFeatureVector.push(this._featureVector[i]);
						}
					}
				}
				this.addFeatures(lineStringFeatureVector);
				this.addFeatures(pointFeatureVector);
				
			}
			else {
				this.clear();
				this.draw();
			}			
		}
				
		/*
		 * Getters and Setters
		 */
		
		/**
		 * The list of features read from GPX data
		 */ 
		override public function get features():Vector.<Feature>
		{
			return _featureVector;
		}
		
		public function set features(value:Vector.<Feature>):void
		{
			_featureVector = value;
		}

		public function get gpxFormat():GPXFormat
		{
			return _gpxFormat;
		}
		
		public function set gpxFormat(value:GPXFormat):void
		{
			_gpxFormat = value;
		}
		
		public function get version():String
		{
			return _version;
		}
		
		public function set version(value:String):void
		{
			_version = value;
		}
		
		override public function set projection(value:String):void {
			// SRS code cannot be overriden. Graticule is always built in WGS84
			// and then reprojected to the projection of the map.
		}

		/**
		 * Defines if attribut objects should be extracted from the GPX source file.
		 * Default: true.
		 */
		public function get extractAttributes():Boolean
		{
			return _extractAttributes;
		}
		/**
		 * @private
		 */
		public function set extractAttributes(value:Boolean):void
		{
			_extractAttributes = value;
		}

		/**
		 * Defines if waypoint objects should be extracted from the GPX source file.
		 * Default: true.
		 */
		public function get extractWaypoints():Boolean
		{
			return _extractWaypoints;
		}
		/**
		 * @private
		 */
		public function set extractWaypoints(value:Boolean):void
		{
			_extractWaypoints = value;
		}

		/**
		 * Defines if tracks objects should be extracted from the GPX source file.
		 * Default: true.
		 */
		public function get extractTracks():Boolean
		{
			return _extractTracks;
		}
		/**
		 * @private
		 */
		public function set extractTracks(value:Boolean):void
		{
			_extractTracks = value;
		}

		/**
		 * Defines if routes objects should be extracted from the GPX source file.
		 * Default: true.
		 */
		public function get extractRoutes():Boolean
		{
			return _extractRoutes;
		}
		/**
		 * @private 
		 */
		public function set extractRoutes(value:Boolean):void
		{
			_extractRoutes = value;
		}

		/**
		 * List of accepted file extensions for GPX files ("gpx" and "xml")
		 */ 
		public function get acceptedFileExtensions():Vector.<String>
		{
			return ACCEPTED_FILE_EXTENSIONS;
		}

	}
}