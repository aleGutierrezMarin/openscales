package {
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.Copyright;
	import org.openscales.core.control.DataOriginatorsDisplay;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.control.ScaleLine;
	import org.openscales.core.control.TermsOfService;
	import org.openscales.core.control.logoRotator;
	import org.openscales.core.control.NumericScale;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	[SWF(width='1200',height='700')]
	public class OriginatorExample extends Sprite {
		protected var _map:Map;
		
		public function OriginatorExample() {
			_map=new Map();
			_map.size=new Size(1200, 700);
			
			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			//mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			_map.addLayer(mapnik);
			
			var originatorIGN:DataOriginator = new DataOriginator("IGN", "http://www.ign.fr/", "http://www.ign.fr/imgs/logo.gif");
			mapnik.addOriginator(originatorIGN);
			
			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			cycle.proxy = "http://openscales.org/proxy.php?url=";
			_map.addLayer(cycle); 
			
			var originatorPlanet:DataOriginator = new DataOriginator("Planet Observer", "http://www.planetobserver.com/", "http://www.toulousespaceshow.eu/tss08/logos/logo_planetobserver.jpg");
			cycle.addOriginator(originatorPlanet);
			
			var regions:WFS = new WFS("IGN - Geopla (Region)", "http://openscales.org/geoserver/wfs","pg:ign_geopla_region");
			regions.projSrsCode = "EPSG:2154";
			regions.style = Style.getDefaultSurfaceStyle();
			_map.addLayer(regions);
			
			var originatorAutre:DataOriginator = new DataOriginator("Trace GPS", "http://www.tracegps.com/", "http://www.bouger-en-nouvelle-caledonie.com/img/logo/tracegps.jpg");
			regions.addOriginator(originatorAutre);
			
			var originatorOSM:DataOriginator = new DataOriginator("OSM", "http://wiki.openstreetmap.org/wiki/Main_Page", "http://www.populationdata.net/images/articles/openstreetmap-logo.png");
			regions.addOriginator(originatorOSM);
			
			
			
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
			
			_map.addHandler(selectHandler);
			_map.addHandler(new WheelHandler());
			_map.addHandler(new DragHandler());
			
			// Set the map center
			_map.center=new Location(538850.47459,5740916.1243,mapnik.projSrsCode);
			_map.zoom=5;
			
			this.addChild(_map);
			
			
		}
	}
}
