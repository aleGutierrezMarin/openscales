package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.format.GeoRssFormat;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;

	public class GeoRss extends FeatureLayer
	{
		
		private var _featureVector:Vector.<Feature> = null;
		private var _georssFormat:GeoRssFormat;
		private var _georssData:XML = null;
		
		private var _request:XMLRequest = null;
		private var _refresh:int;
		private var _timer:Timer;
		private var _timerOn:Boolean = false;
		
		public function GeoRss(name:String, 
							   url:String = null,
							   refreshDelay:int = 60000,
							   style:Style = null)
		{
			super(name);
			this.url = url;	
			if(style){
				this.style = style;
				this.style.rules.push(new Rule());
			}
			else this.style = null;
			this.georssFormat = new GeoRssFormat(new HashMap());	
			this.refresh = refreshDelay;
			
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
			this.georssData = new XML(loader.data);
			if (this.georssData)
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
				
				this.featureVector = this.georssFormat.read(this.georssData) as Vector.<Feature>;
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

		public function get georssData():XML
		{
			return _georssData;
		}

		public function set georssData(value:XML):void
		{
			_georssData = value;
		}

		public function get georssFormat():GeoRssFormat
		{
			return _georssFormat;
		}

		public function set georssFormat(value:GeoRssFormat):void
		{
			_georssFormat = value;
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


	}
}