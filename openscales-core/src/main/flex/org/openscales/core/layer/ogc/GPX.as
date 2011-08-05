package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.format.GPXFormat;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	
	/**
	 * GPX layer; versions 1.0 & 1.1 supported 
	 * 
	 * @param name: the name of the layer
	 * 
	 * @param version
	 * 
	 * @param url: the url of the file that contains the gpx data
	 * 
	 * @param data: the file that contains the gpx data
	 * 
	 * The data and url params are not compatible with each other
	 * 
	 * The data projection for this layer is set to "EPSG:4326" by default (@see class Layer)
	 */
	
	
	
	
	public class GPX extends FeatureLayer
	{
		private var _featureVector:Vector.<Feature> = null;
		private var _gpxData:XML = null;
		private var _gpxFormat:GPXFormat;
		
		private var _request:XMLRequest = null;
		
		public function GPX(name:String, 
							version:String,
							url:String = null,
							data:XML = null)
		{
			super(name);
			this.gpxFormat = new GPXFormat(new HashMap());
			
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
				this.gpxData = data;
				
			}
		}
		
		
		public function onSuccess(event:Event):void
		{
			this.loading = true;
			var loader:URLLoader = event.target as URLLoader;
			this.gpxData = new XML(loader.data);
			
			if(this.gpxData) 
				this.draw();
		}
		
		protected function onFailure(event:Event):void {
			this.loading = false;
			Trace.error("Error when loading gpx file" + this.url);			
		}
			
		override protected function draw():void{
			
			if(this.featureVector == null && this.gpxData){
				
				var pointStyle:Style = Style.getDefaultPointStyle();
				var lineStyle:Style = Style.getDefaultLineStyle();
				pointStyle.rules.push(new Rule());
				lineStyle.rules.push(new Rule());
				pointStyle.rules[0].symbolizers.push(new PointSymbolizer(new Marker(7, 3,2)));
				lineStyle.rules[0].symbolizers.push(new LineSymbolizer(new Stroke(0x008800,3,1,Stroke.LINECAP_BUTT)));
				
				this.featureVector = this.gpxFormat.parseGpxFile(this.gpxData);
				var i:uint;
				var vectorLength:uint = this.featureVector.length;
				for (i = 0; i < vectorLength; i++){
					if(this.featureVector[i] is PointFeature) {
						this.featureVector[i].style = pointStyle;
					}
					else // feature is linestring or multilinestring
						this.featureVector[i].style = lineStyle;
					this.addFeature(this.featureVector[i]);
				}
			}else{
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

		public function get gpxData():XML
		{
			return _gpxData;
		}

		public function set gpxData(value:XML):void
		{
			_gpxData = value;
		}

		public function get gpxFormat():GPXFormat
		{
			return _gpxFormat;
		}

		public function set gpxFormat(value:GPXFormat):void
		{
			_gpxFormat = value;
		}


	}
}