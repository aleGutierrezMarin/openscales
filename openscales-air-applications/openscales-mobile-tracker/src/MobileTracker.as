package {
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.GeolocationEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.TransformGestureEvent;
	import flash.sensors.Geolocation;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.handler.multitouch.PanGestureHandler;
	import org.openscales.core.handler.multitouch.ZoomGestureHandler;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.proj4as.ProjProjection;
	
	public class MobileTracker extends Sprite {
		
		protected var _map:Map;
		protected var t:TextField;
		protected var geo:Geolocation;
		protected var firstPass:Boolean = true;
		
		public function MobileTracker() {
			_map=new Map();
			_map.size=new Size(stage.stageWidth, stage.stageHeight);
			
			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projection);		
			_map.addLayer(mapnik);
			
			var markers:FeatureLayer = new FeatureLayer("markers");
			markers.projection = new ProjProjection("EPSG:4326");
			markers.style = Style.getDefaultPointStyle();
			markers.tweenOnZoom = false;
					
			_map.addLayer(markers);
			
			// Add Controls to map
			var mousePosition:MousePosition = new MousePosition();
			mousePosition.displayProjection = new ProjProjection("EPSG:4326");
			_map.addControl(mousePosition);			
			
			
			if(Multitouch.supportsGestureEvents) {
				_map.addHandler(new ZoomGestureHandler());
				_map.addHandler(new PanGestureHandler());
			} else {
				_map.addHandler(new DragHandler());
				_map.addHandler(new WheelHandler());
			}
			
			
			this.stage.addEventListener(Event.DEACTIVATE,this.onDeactivate);
			
			// Set the map center
			_map.center=new Location(538850.47459,5740916.1243,mapnik.projection);
			_map.zoom=5;
			
			this.addChild(_map);
			
			/*********************************
			 *               GPS             *
			 *********************************/
			
			t = new TextField();
			t.x = 200;
			t.width = 400;
			t.text = "Status ..."
			_map.addChild(t);
			if (Geolocation.isSupported)
			{
				geo = new Geolocation();
				geo.setRequestedUpdateInterval(10000);
				geo.addEventListener(GeolocationEvent.UPDATE, geolocationUpdateHandler);
				t.text = "Geolocation activated";
			} else {
				t.text = "Geolocation not supported";
			}

			/*********************************
			 *    Manage screen orientation  *
			 *********************************/
			
			stage.align = StageAlign.TOP_LEFT; 
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
			
			// Stile beta some comment this for now
			//stage.addEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotate);
			
		}
		
		private function onRotate(event:TransformGestureEvent):void {
			_map.layerContainer.rotationZ -= event.rotation;
			_map.bitmapTransition.rotationZ -= event.rotation;
		}
		
		private function onDeactivate(event:Event):void {
			NativeApplication.nativeApplication.exit();
		}

		private function geolocationUpdateHandler(event:GeolocationEvent):void
		{
			t.text = "Latitude " + event.latitude + ", longitude " + event.longitude;
			(_map.getLayerByName("markers") as FeatureLayer).addFeature(PointFeature.createPointFeature(new Location(event.longitude, event.latitude)));
			if(firstPass) {
				firstPass = false;
				this._map.moveTo(new Location(event.longitude, event.latitude), 16, false, true);
			}
		}
		
		private function onOrientationChange(event:StageOrientationEvent):void 
		{ 
			_map.size = new Size(stage.stageWidth, stage.stageHeight);
		}
		
	}
}
