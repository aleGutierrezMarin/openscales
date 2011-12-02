package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.format.GeoRssFormat;
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
	 * Rss layer; version 2.0 is supported
	 * GeoRss version 1.1 supported
	 * 
	 * @param name The name of the layer
	 * @param url The url of the file that contains the RSS data
	 * @param refreshDelay The refresh time between two operations of reading the file at the given URL
	 * @param style
	 * @param width the width of the popup window 
	 * @param height the height of the popup window
	 * 
	 * The srs code of the layer projection is "WGS84"
	 * 
	 */
	public class GeoRss extends VectorLayer implements IFileUser
	{
		
		private static const ACCEPTED_FILE_EXTENSIONS:Vector.<String> = new <String>["xml","rss"];
		
		private var _featureVector:Vector.<Feature> = null;
		private var _georssFormat:GeoRssFormat;
		
		private var _request:XMLRequest = null;
		private var _refresh:int;
		private var _timer:Timer;
		private var _timerOn:Boolean = false;
		
		private var _popUpWidth:Number;
		private var _popUpHeight:Number;
		private var _useFeedTitle:Boolean = false;
		
		public function GeoRss(name:String, 
							   url:String = null,
							   data:XML = null,
							   refreshDelay:int = 300000,
							   style:Style = null,
							   width:Number = 300,
							   height:Number = 300,
							   useFeedTitle:Boolean = false)
		{
			super(name);
			this.url = url;	
			this.data = data;
			this._projection = "WGS84";
			if(style){
				this.style = style;
				this.style.rules.push(new Rule());
			}
			else this.style = null;
			this.georssFormat = new GeoRssFormat(new HashMap());	
			this.refresh = refreshDelay;
			this.popUpWidth = width;
			this.popUpHeight = height;
			this.useFeedTitle = useFeedTitle;
			
			this.timer = new Timer(refreshDelay, 1);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onCompleteTimer,false,0,true);
			this.timer.start();	
			this._timerOn = true;
			Trace.debug("Sart timer");
				
		}
		
		public function onCompleteTimer(event:TimerEvent):void{
			this.timer.start();
			Trace.debug("Restart timer on timer expiration");
			this.redraw();	
		}
		
		override public function destroy():void
		{
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onCompleteTimer);
			this.timer.stop();
			Trace.debug("Stop timer when destroying layer");
		}
		
		override public function redraw(fullRedraw:Boolean = true):void {
			
			if (this.map == null)
				return;
			
			//if the user chooses not to display this layer, stop timer to save ressources
			if (!displayed) {
				this.clear();
				if(this._timerOn){
					this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onCompleteTimer);
					this.timer.stop();
					this._timerOn = false;
					Trace.debug("Stop timer if layer is not displayed");
				}
				return;
			}
			else{
				if(!this._timerOn){
					this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onCompleteTimer,false,0,true);
					this.timer.start();	
					this._timerOn = true;
					Trace.debug("Restart timer if layer is displayed again");
				}		
			}
			if (url){
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
			Trace.error("Error while loading the geoRss file" + this.url);			
		} 
		
		public function drawFeatures():void{
			
			if(this.featureVector == null) {
				
				var pointStyle:Style = Style.getDefaultPointStyle();
				var lineStyle:Style = Style.getDefaultLineStyle();
				var surfStyle:Style = Style.getDefaultSurfaceStyle();
				pointStyle.rules.push(new Rule());
				lineStyle.rules.push(new Rule());
				pointStyle.rules[0].symbolizers.push(new PointSymbolizer(new Marker(7, 3,2)));
				lineStyle.rules[0].symbolizers.push(new LineSymbolizer(new Stroke(0x008800,3,1,Stroke.LINECAP_BUTT)));
				
				this.featureVector = this.georssFormat.read(this.data) as Vector.<Feature>;
				if(this.useFeedTitle)
					this.name = this.georssFormat.title;
				
				var i:uint;
				var vectorLength:uint = this.featureVector.length;
				for (i = 0; i < vectorLength; i++){
					
					if(this.style){
						this.featureVector[i].style = this.style;
					}
					else//default style
					{
						if(this.featureVector[i] is PointFeature) {
							this.featureVector[i].style = pointStyle;
						}
						else if(this.featureVector[i] is LineStringFeature){
							this.featureVector[i].style = lineStyle;
						} 
						else// feature is polygon
							this.featureVector[i].style = surfStyle;
					}
					this.addFeature(this.featureVector[i]);
				}
				var evt:LayerEvent = new LayerEvent(LayerEvent.LAYER_CHANGED, this);
				this.map.dispatchEvent(evt);
			}
			else {
				this.clear();
				this.draw();
			}			
		}
		
		/**
		 * Setters and getters
		 */ 
		
		public function get featureVector():Vector.<Feature>
		{
			return _featureVector;
		}

		public function set featureVector(value:Vector.<Feature>):void
		{
			_featureVector = value;
		}

		public function get georssFormat():GeoRssFormat
		{
			return _georssFormat;
		}

		public function set georssFormat(value:GeoRssFormat):void
		{
			_georssFormat = value;
		}
		
		override public function set projection(value:String):void {
			// SRS code cannot be overriden. Graticule is always built in WGS84
			// and then reprojected to the projection of the map.
		}
		
		public function get refresh():int
		{
			return _refresh;
		}

		public function set refresh(value:int):void
		{
			_refresh = value;
		}

		public function get timer():Timer
		{
			return _timer;
		}

		public function set timer(value:Timer):void
		{
			_timer = value;
		}

		public function get popUpWidth():Number
		{
			return _popUpWidth;
		}

		public function set popUpWidth(value:Number):void
		{
			_popUpWidth = value;
		}

		public function get popUpHeight():Number
		{
			return _popUpHeight;
		}

		public function set popUpHeight(value:Number):void
		{
			_popUpHeight = value;
		}


		public function get useFeedTitle():Boolean
		{
			return _useFeedTitle;
		}

		public function set useFeedTitle(value:Boolean):void
		{
			_useFeedTitle = value;
		}
		
		/**
		 * List of accepted file extensions for GeoRss files ("rss" and "xml")
		 */ 
		public function get acceptedFileExtensions():Vector.<String>{
			return ACCEPTED_FILE_EXTENSIONS;
		}

	}
}