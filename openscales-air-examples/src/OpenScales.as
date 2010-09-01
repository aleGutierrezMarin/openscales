package {
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.events.GeolocationEvent;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.sensors.Geolocation;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.control.LayerSwitcher;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.events.TraceEvent;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.multitouch.PanGestureHandler;
	import org.openscales.core.handler.multitouch.ZoomGestureHandler;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.proj4as.ProjProjection;
	
	[SWF(width='480',height='800')]
	public class OpenScales extends Sprite {
		
		protected var _map:Map;
		protected var t:TextField;
		protected var geo:Geolocation;
		
		public function OpenScales() {
			_map=new Map();
			_map.size=new Size(480, 800);
			
			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.isBaseLayer = true;
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projection);		
			_map.addLayer(mapnik);
			
			var markers:FeatureLayer = new FeatureLayer("markers");
			markers.projection = new ProjProjection("EPSG:4326");
			markers.style = Style.getDefaultPointStyle();
			_map.addLayer(markers);
			
			markers.addFeature(PointFeature.createPointFeature(new Location(event.longitude, event.latitude)));
			
			// Add Controls to map
			_map.addControl(new MousePosition());
			_map.addControl(new LayerSwitcher());
			_map.addControl(new PanZoomBar());
			
			
			_map.addHandler(new ZoomGestureHandler());
			_map.addHandler(new PanGestureHandler());
			
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
		}

		private function geolocationUpdateHandler(event:GeolocationEvent):void
		{
			t.text = "Latitude " + event.latitude + ", longitude " + event.longitude;
			(_map.getLayerByName("markers") as FeatureLayer).addFeature(PointFeature.createPointFeature(new Location(event.longitude, event.latitude)));
		}
		
		private function onOrientationChange(event:StageOrientationEvent):void 
		{ 
			switch (event.afterOrientation) { 
				case StageOrientation.DEFAULT: 
					_map.size = new Size(480, 800);
					break; 
				case StageOrientation.ROTATED_RIGHT: 
					_map.size = new Size(800, 480);
					break; 
				case StageOrientation.ROTATED_LEFT: 
					_map.size = new Size(800, 480);
					break; 
				case StageOrientation.UPSIDE_DOWN: 
					_map.size = new Size(480, 800);
					break; 
			}
		}
		
	}
}
