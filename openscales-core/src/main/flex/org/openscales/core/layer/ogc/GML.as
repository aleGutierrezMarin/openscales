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
	import org.openscales.core.format.GML32Format;
	import org.openscales.core.format.GMLFormat;
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
		private var _gmlFormat:GML32Format = null;
		private var _gmlData:XML = null;
		private var _featureVector:Vector.<Feature> = null;
		private var _request:XMLRequest = null;
		
		public function GML(name:String, 
							version:String,
							projection:String,
							style:Style,
							url:String = null,
							data:XML = null)
		{
			super(name);
			this.projSrsCode = projection;
			this.gmlFormat = new GML32Format(null,null);
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
				
				var pointStyle:Style = Style.getDefaultPointStyle();
				var lineStyle:Style = Style.getDefaultLineStyle();
				var surfaceStyle:Style = Style.getDefaultSurfaceStyle();
				
				featureVector = this._gmlFormat.parseGmlFile(this.gmlData);
				var i:uint;
				var vectorLength:uint = this.featureVector.length;
				for (i = 0; i < vectorLength; i++){
					
					if(this.featureVector[i] is PointFeature || this.featureVector[i] is MultiPointFeature) {
						this.featureVector[i].style = pointStyle;
					}
					else if (this.featureVector[i] is LineStringFeature || this.featureVector[i] is MultiLineStringFeature){
						this.featureVector[i].style = lineStyle;
					}
					else
						this.featureVector[i].style = surfaceStyle;				
					this.addFeature(this.featureVector[i]);
				}
			} else {
				super.draw();
			}
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
		
		public function get gmlFormat():GML32Format
		{
			return _gmlFormat;
		}
		
		public function set gmlFormat(value:GML32Format):void
		{
			_gmlFormat = value;
		}
		
		
	}
}