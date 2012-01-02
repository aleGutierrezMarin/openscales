package org.openscales.core.layer.ogc
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.gml.GMLFormat;
	import org.openscales.core.layer.IFileUser;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	
	/**
	 * GML layer; version 3.2.1 is supported 
	 * 
	 * @param name: the name of the layer
	 * 
	 * @param version
	 * 
	 * @param url: the url of the file that contains the gpx data
	 * 
	 * @param data: the file that contains the gpx data
	 * 
	 * @param projection: the data projection for this layer
	 * All the projections are not supported (@see class ProjProjection)
	 * 
	 * The data and url params are not compatible with each other
	 */
	
	
	public class GML extends VectorLayer implements IFileUser
	{	
		private static const ACCEPTED_FILE_EXTENSIONS:Vector.<String> = new <String>["xml","gml"];
		
		private var _gmlFormat:GMLFormat = null;
		private var _request:XMLRequest = null;
		private var _version:String;
		
		public function GML(name:String, 
							version:String,
							projection:*,
							url:String = null,
							data:XML = null,
							style:Style = null)
		{
			super(name);
			this.projection = projection;
			this.version = version;
			this.gmlFormat = new GMLFormat(this.addFeature,null);
			this.gmlFormat.version = version;
			if(style){
				this.style = style;
				this.style.rules.push(new Rule());
			}
			else this.style = null;
			
			
			if (url){
				if (! this._request) {
					this.loading = true;
					this._request = new XMLRequest(url, onSuccess, onFailure);
					this._request.proxy = this.proxy;
					this._request.security = this.security;
					this._request.send();
				}
			}
			else // load data from local file
			{
				this.data = data;
				
			}
			
		}
		
		public function onSuccess(event:Event):void
		{
			this.loading = true;
			var loader:URLLoader = event.target as URLLoader;
			this.data = new XML(loader.data);
			
			if(this.data)
				this.draw();
		}
		
		protected function onFailure(event:Event):void {
			this.loading = false;
			Trace.error("Error when loading gml file" + this.url);			
		}
		
		override protected function draw():void{
			if(this.featuresID && this.featuresID.length == 0 && this.data) {

				this._gmlFormat.read(this.data);
				
			} else {
				super.draw();
			}
		}
		
		override public function addFeature(feature:Feature, dispatchFeatureEvent:Boolean=true, reproject:Boolean=true):void {
			
			var pointStyle:Style = Style.getDefaultPointStyle();
			var lineStyle:Style = Style.getDefaultLineStyle();
			var surfaceStyle:Style = Style.getDefaultSurfaceStyle();
			
			if(this.style){
				feature.style = this.style;
			}
			else//default style
			{
				if(feature is PointFeature || feature is MultiPointFeature) {
					feature.style = pointStyle;
				}
				else if (feature is LineStringFeature || feature is MultiLineStringFeature){
					feature.style = lineStyle;
				}
				else
					feature.style = surfaceStyle;
			}

			super.addFeature(feature, dispatchFeatureEvent, reproject);
		}
		
		/**
		 * Getters and Setters
		 */ 
		public function get gmlFormat():GMLFormat
		{
			return _gmlFormat;
		}
		
		public function set gmlFormat(value:GMLFormat):void
		{
			_gmlFormat = value;
		}

		public function get version():String
		{
			return _version;
		}

		public function set version(value:String):void
		{
			_version = value;
		}
		
		/**
		 * List of accepted file extensions for GML files ("gml" and "xml")
		 */ 
		public function get acceptedFileExtensions():Vector.<String>
		{
			return ACCEPTED_FILE_EXTENSIONS;
		}
	}
}