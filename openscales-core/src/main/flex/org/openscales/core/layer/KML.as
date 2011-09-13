package org.openscales.core.layer
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequestMethod;
	
	import org.openscales.core.Trace;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.format.KMLFormat;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.geometry.basetypes.Bounds;
	
	/**
	 * KML layer, most useful features of KML 2.0 and 2.2 specifications are supported
	 */
	public class KML extends VectorLayer
	{
		private var _request:XMLRequest = null;
		private var _kmlFormat:KMLFormat = null;
		private var _featureVector:Vector.<Feature> = null;

		private var _xml:XML = null;
		
		public function KML(name:String,
							url:String = null,
							data:XML = null,
							style:Style = null,
							bounds:Bounds = null) 
		{
			super(name);
			this.url = url;
			this.data = data;
			this.maxExtent = bounds;
			this._kmlFormat = new KMLFormat();
			this._kmlFormat.userDefinedStyle = style;
		}
		
		override public function destroy():void {
			if (this._request) {
				this._request.destroy();
				this._request = null;
			}
			this.loading = false;
			super.destroy();
		}
		
		override public function redraw(fullRedraw:Boolean = true):void {
			
			if (this.map == null)
				return;
			
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
		
		public function drawFeatures():void{
			
			if(this._featureVector == null) {
				
				if (this.map.projection != null && this.projSrsCode != null && this.projSrsCode != this.map.projection) {
					this._kmlFormat.externalProjSrsCode = this.projSrsCode;
					this._kmlFormat.internalProjSrsCode = this.map.projection;
				}
				this._kmlFormat.proxy = this.proxy;
				
				this._featureVector = this.kmlFormat.read(this.data) as Vector.<Feature>;
				var i:uint;
				var vectorLength:uint = this._featureVector.length;
				for (i = 0; i < vectorLength; i++){
				
					this.addFeature(this._featureVector[i]);
				}
			}
			else {
				this.clear();
				this.draw();
			}			
		}
		
		public function onSuccess(event:Event):void
		{
			this.loading = false;
			var loader:URLLoader = event.target as URLLoader;
			
			// To avoid errors if the server is dead
			try {
				this._xml = new XML(loader.data);
				if (this.map.projection != null && this.projSrsCode != null && this.projSrsCode != this.map.projection) {
					this._kmlFormat.externalProjSrsCode = this.projSrsCode;
					this._kmlFormat.internalProjSrsCode = this.map.projection;
				}
				this._kmlFormat.proxy = this.proxy;
				var features:Vector.<Feature> = this._kmlFormat.read(this._xml) as Vector.<Feature>;
				this.addFeatures(features);
				
				this.clear();
				this.draw();
			}
			catch(error:Error) {
				Trace.error(error.message);
			}
		}
		
		protected function onFailure(event:Event):void {
			this.loading = false;
			Trace.error("Error when loading kml " + this.url);			
		}

		override public function getURL(bounds:Bounds):String {
			return this.url;
		}
		
		/**
		 * Getters and Setters
		 */ 
		public function get projection():String
		{
			return this._projSrsCode;	
		}
		
		public function set projection(value:String):void
		{
			this._projSrsCode = value;
		}
		
		public function get kmlFormat():KMLFormat
		{
			return _kmlFormat;
		}
	}
}