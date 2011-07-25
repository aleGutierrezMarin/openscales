package {
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.Copyright;
	import org.openscales.core.control.DataOriginatorsDisplay;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.NumericScale;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.control.Zoom;
	import org.openscales.core.control.PanZoom;
	import org.openscales.core.control.ScaleLine;
	import org.openscales.core.control.TermsOfService;
	import org.openscales.core.control.logoRotator;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	import org.openscales.core.security.ign.IGNGeoRMSecurity;
	
	[SWF(width='1200',height='700')]
	public class OriginatorExample extends Sprite {
		protected var _map:Map;
		
		public function OriginatorExample() {
			_map=new Map();
			_map.size=new Size(1200, 700);

			var IGN:WMSC = new WMSC("OrthoPhoto", "http://wxs.ign.fr/geoportail/wmsc", "ORTHOIMAGERY.ORTHOPHOTOS");
			IGN.projection = "IGNF:GEOPORTALFXX";
			var resoArray:Array = new Array(39135.75,19567.875,9783.9375,4891.96875,2445.984375,2048,1024,512,256,128,64,32,16,8,4,2,1,0.5,0.25,0.125,0.0625);
			IGN.resolutions = resoArray;
			IGN.minZoomLevel = 0;
			IGN.maxZoomLevel = 21;
			IGN.method = "POST";
			IGN.version ="1.1.1";
			
			IGN.maxExtent = new Bounds(-1048576,3670016,2097152,6815744, "IGNF:GEOPORTALFXX");
			var securityIGN:IGNGeoRMSecurity = new IGNGeoRMSecurity(_map, "1905042184761803857", "http://www.openscales.org/proxy.php?url=", "http://jeton-api.ign.fr", "POST");
			IGN.security = securityIGN;
			//IGN.security.initialize();
			_map.addLayer(IGN);
		
			// Add Controls to map
			_map.addControl(new MousePosition());
			_map.addControl(new LayerManager());
			_map.addControl(new PanZoomBar());
			_map.addControl(new Copyright("openscales", new Pixel(50, 600)));
			_map.addControl(new TermsOfService("http://openscales.org/index.html", "Terms of services", new Pixel(150, 600)));
			_map.addControl(new DataOriginatorsDisplay(2, new Pixel(300, 250)));
			
			_map.addControl(new ScaleLine(new Pixel(500, 550)));
			_map.addControl(new NumericScale(new Pixel(400, 600)));
			
			var selectHandler: SelectFeaturesHandler = new SelectFeaturesHandler();
			selectHandler.enableClickSelection = false;
			selectHandler.enableBoxSelection = false;
			selectHandler.enableOverSelection = true;
			selectHandler.active = true;
			
			_map.addControl(selectHandler);
			_map.addControl(new WheelHandler());
			_map.addControl(new DragHandler());
			
			// Set the map center
			_map.center=new Location(538850.47459,5740916.1243,IGN.projection);
			_map.zoom=5;
			
			this.addChild(_map);
			
			
		}
	}
}
