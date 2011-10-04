package {
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.GeolocationEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.TransformGestureEvent;
	import flash.sensors.Geolocation;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.handler.multitouch.PanGestureHandler;
	import org.openscales.core.handler.multitouch.ZoomGestureHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class MobileTracker extends Sprite {
		
		protected var _map:Map;
		protected var t:TextField;
		protected var geo:Geolocation;
		protected var firstPass:Boolean = true;
		
		private var _rotation:Number = 0;
		
		public function MobileTracker() {
			_map=new Map();
			
			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projection);		
			_map.addLayer(mapnik);
			
			var markers:VectorLayer = new VectorLayer("markers");
			markers.projection = "EPSG:4326";
			markers.style = Style.getDefaultPointStyle();
					
			_map.addLayer(markers);
			
			// Add Controls to map
			var mousePosition:MousePosition = new MousePosition();
			mousePosition.displayProjSrsCode = "EPSG:4326";
			_map.addControl(mousePosition);			
			
			
			if(Multitouch.supportsGestureEvents) {
				_map.addControl(new ZoomGestureHandler());
				_map.addControl(new PanGestureHandler());
			} else {
				_map.addControl(new DragHandler());
				_map.addControl(new WheelHandler());
			}
			
			
			this.stage.addEventListener(Event.DEACTIVATE,this.onDeactivate);
			this.stage.addEventListener(Event.ACTIVATE,this.onActivate);
						
			// Set the map center
			_map.center = new Location(538850.47459,5740916.1243,mapnik.projection);
			_map.resolution = new Resolution(mapnik.resolutions[5],mapnik.projection);
			
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
			
			//stage.addEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotate);
			
		}
		
		private function onRotate(event:TransformGestureEvent):void {
			_rotation += event.rotation;
			
			if((_rotation > 135 && _rotation < 225)
				|| (_rotation < -135 && _rotation > -225)) {
				if(_rotation>0)
					_map.rotationZ = 180;
				else
					_map.rotationZ = 180;
			}
			else if((_rotation > 45 && rotation < 125 )
				|| (_rotation < -45 && _rotation > -125)) {
				var i:Number = _map.width;
				_map.width = _map.height;
				_map.height = i;
				if(event.rotation>0)
					_map.rotationZ = 90;
				else
					_map.rotationZ = 90;
			}
			
		}
		
		private function onDeactivate(event:Event):void {
			NativeApplication.nativeApplication.exit();
		}
		
		private function onActivate(event:Event):void {
			_map.size = new Size(stage.stageWidth, stage.stageHeight);
			NativeApplication.nativeApplication.activeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onWindowResize);
		}
		
		private function onWindowResize(event:Event):void {
			_map.size = new Size(stage.stageWidth, stage.stageHeight);
		}
				

		private function geolocationUpdateHandler(event:GeolocationEvent):void
		{
			t.text = "Latitude " + event.latitude + ", longitude " + event.longitude;
			(_map.getLayerByName("markers") as VectorLayer).addFeature(PointFeature.createPointFeature(new Location(event.longitude, event.latitude)));
			if(firstPass) {
				firstPass = false;
				this._map.center = new Location(event.longitude, event.latitude, "EPGS:4326");
			}
		}
		
		private function onOrientationChange(event:StageOrientationEvent):void 
		{ 
			_map.size = new Size(stage.stageWidth, stage.stageHeight);
		}
		
	}
}
