package {
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.control.DataOriginators;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.Bing;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;

	[SWF(width='1200',height='700')]
	public class OpenscalesApplication extends Sprite {
		protected var _map:Map;

		public function OpenscalesApplication() {
			_map=new Map();
			_map.size=new Size(1200, 700);
			_map.projection = "EPSG:900913";
			_map.center = new Location(2,48, "EPSG:4326");
			_map.resolution = new Resolution(100000.0339, "EPSG:900913");
			_map.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,"EPSG:900913");
			
			var mapnik:Mapnik=new Mapnik("Mapnik");
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projection);
			mapnik.alpha = 0.4;
			//_map.addLayer(mapnik);
			
			// bing road
			var bing:Bing = new Bing("Ar3-LKk-acyISMevsF2bqH70h21mzr_FN9AhHfi7pS26F5hMH1DmpI7PBK1VCLBk");
			_map.addLayer(bing);
			// bing aerial
			bing = new Bing("Ar3-LKk-acyISMevsF2bqH70h21mzr_FN9AhHfi7pS26F5hMH1DmpI7PBK1VCLBk","Aerial");
			//_map.addLayer(bing);

			_map.addControl(new WheelHandler());
			_map.addControl(new DragHandler());
						
			this.addChild(_map);
			_map.addControl(new LayerManager());
			
		}
	}
}
