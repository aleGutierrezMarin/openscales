package org.openscales.core.layer
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequestMethod;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
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
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * KML layer, most useful features of KML 2.0 and 2.2 specifications are supported
	 */
	public class KML extends VectorLayer implements IFileUser
	{
		private static const ACCEPTED_FILE_EXTENSIONS:Vector.<String> = new <String>["xml","kml"];
		
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
			
			if(this._featureVector == null) 
			{
				
				if (this.map.projection != null && this.projection != null && this.projection != this.map.projection) {
					this._kmlFormat.externalProjection = this.projection;
					this._kmlFormat.internalProjection = this.map.projection;
				}
				this._kmlFormat.proxy = this.proxy;
				
				this._featureVector = this.kmlFormat.read(this.data) as Vector.<Feature>;
				var i:uint;
				var vectorLength:uint = this._featureVector.length;
				for (i = 0; i < vectorLength; i++){
					//If feature is a Label, update bounds of it
					if(this._featureVector[i] is LabelFeature) {
						var middlePixel:Pixel = this.map.getMapPxFromLocation(new Location((this._featureVector[i] as LabelFeature).labelPoint.x, (this._featureVector[i] as LabelFeature).labelPoint.y, this.map.projection));
						var leftPixel:Pixel = new Pixel();
						var rightPixel:Pixel = new Pixel();
						leftPixel.x = middlePixel.x - (this._featureVector[i] as LabelFeature).labelPoint.label.width / 2;
						leftPixel.y = middlePixel.y + (this._featureVector[i] as LabelFeature).labelPoint.label.height / 2;
						rightPixel.x = middlePixel.x + (this._featureVector[i] as LabelFeature).labelPoint.label.width / 2;
						rightPixel.y = middlePixel.y - (this._featureVector[i] as LabelFeature).labelPoint.label.height / 2;
						var rightLoc:Location = this.map.getLocationFromMapPx(rightPixel);
						var leftLoc:Location = this.map.getLocationFromMapPx(leftPixel);
						(this._featureVector[i] as LabelFeature).labelPoint.updateBounds(leftLoc.x,leftLoc.y,rightLoc.x,rightLoc.y,this.map.projection);
					}
					
					this.addFeature(this._featureVector[i],true,false);
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
				if (this.map.projection != null && this.projection != null && this.projection != this.map.projection) {
					this._kmlFormat.externalProjection = this.projection;
					this._kmlFormat.internalProjection = this.map.projection;
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
		override public function set projection(value:*):void {
			// SRS code cannot be overriden. Graticule is always built in EPSG:4326
			// and then reprojected to the projection of the map.
		}
		
		public function get kmlFormat():KMLFormat
		{
			return _kmlFormat;
		}
		
		public function get acceptedFileExtensions():Vector.<String>{
			return ACCEPTED_FILE_EXTENSIONS;
		}
	}
}