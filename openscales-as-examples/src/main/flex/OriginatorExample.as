package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.openscales.core.Map;
	import org.openscales.core.control.Copyright;
	import org.openscales.core.control.DataOriginatorsDisplay;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.NumericScale;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoom;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.control.ScaleLine;
	import org.openscales.core.control.TermsOfService;
	import org.openscales.core.control.Zoom;
	import org.openscales.core.control.LogoRotator;
	import org.openscales.core.control.ui.Button;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.security.ign.IGNGeoRMSecurity;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	
	[SWF(width='1200',height='700')]
	public class OriginatorExample extends Sprite {
		
		protected var _map:Map;
		protected var _ign:WMSC;
		
		[Embed(source="/assets/images/featureDeleteLastVertex-upskin.png")]
		private var _btnImg:Class;
		
		
		public function OriginatorExample() {
			_map=new Map();
			_map.size=new Size(1200, 700);

			_ign = new WMSC("OrthoPhoto", "http://wxs.ign.fr/geoportail/wmsc", "ORTHOIMAGERY.ORTHOPHOTOS");
			_ign.projection = "IGNF:GEOPORTALFXX";
			var resoArray:Array = new Array(39135.75,19567.875,9783.9375,4891.96875,2445.984375,2048,1024,512,256,128,64,32,16,8,4,2,1,0.5,0.25,0.125,0.0625);
			_ign.resolutions = resoArray;
			_ign.minZoomLevel = 0;
			_ign.maxZoomLevel = 21;
			_ign.method = "POST";
			_ign.version ="1.1.1";
			
			_ign.maxExtent = new Bounds(-1048576,3670016,2097152,6815744, "IGNF:GEOPORTALFXX");
			var securityIGN:IGNGeoRMSecurity = new IGNGeoRMSecurity(_map, "1905042184761803857", "http://www.openscales.org/proxy.php?url=", "http://jeton-api.ign.fr", "POST");
			_ign.security = securityIGN;
			//IGN.security.initialize();
			_map.addLayer(_ign);
		
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
			_map.center=new Location(538850.47459,5740916.1243,_ign.projection);
			_map.zoom=5;
			
			this.addChild(_map);
			
			var btn:Button = new Button("Change displayInLayerManager", new _btnImg(), new Pixel(1160,310));
			btn.addEventListener(MouseEvent.CLICK, this.changeDisplayInLayerManager);
			
			this.addChild(btn);
			
		}
		
		public function changeDisplayInLayerManager(event:Event):void
		{
			_ign.displayInLayerManager = !_ign.displayInLayerManager;
		}
	}
}
