package org.openscales.core.layer.ogc
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Trace;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.gml.GMLFormat;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
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
	
	
	public class GML extends FeatureLayer
	{	
		private var _gmlFormat:GMLFormat = null;
		private var _gmlData:XML = null;
		private var _featureVector:Vector.<Feature> = null;
		private var _request:XMLRequest = null;
		private var _version:String;
		
		public function GML(name:String, 
							version:String,
							projection:String,
							style:Style,
							url:String = null,
							data:XML = null)
		{
			super(name);
			this.projSrsCode = projection;
			this.version = version;
			this.gmlFormat = new GMLFormat(this.addFeature,null);
			this.gmlFormat.version = version;
			this.style = style;
			this.style.rules.push(new Rule());
			
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
				this.gmlData = data;
				
			}
			
		}
		
		public function onSuccess(event:Event):void
		{
			this.loading = true;
			var loader:URLLoader = event.target as URLLoader;
			this.gmlData = new XML(loader.data);
			
			if(this.gmlData)
				this.draw();
		}
		
		protected function onFailure(event:Event):void {
			this.loading = false;
			Trace.error("Error when loading gml file" + this.url);			
		}
		
		override protected function draw():void{
			if(this._featureVector == null && this.gmlData) {

				this._gmlFormat.read(this.gmlData);
				
			} else {
				super.draw();
			}
		}
		
		override public function addFeature(feature:Feature, dispatchFeatureEvent:Boolean=true, reproject:Boolean=true):void {
			
			var pointStyle:Style = Style.getDefaultPointStyle();
			var lineStyle:Style = Style.getDefaultLineStyle();
			var surfaceStyle:Style = Style.getDefaultSurfaceStyle();
			
			if(feature is PointFeature || feature is MultiPointFeature) {
				feature.style = pointStyle;
			}
			else if (feature is LineStringFeature || feature is MultiLineStringFeature){
				feature.style = lineStyle;
			}
			else
				feature.style = surfaceStyle;
			super.addFeature(feature, dispatchFeatureEvent, reproject);
		}
		
		/**
		 * Getters & Setters
		 */ 
		
		public function get featureVector():Vector.<Feature>
		{
			return _featureVector;
		}
		
		public function set featureVector(value:Vector.<Feature>):void
		{
			_featureVector = value;
		}
		
		public function get gmlData():XML
		{
			return _gmlData;
		}
		
		public function set gmlData(value:XML):void
		{
			_gmlData = value;
		}
		
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
		
		
	}
}