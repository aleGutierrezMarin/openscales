package {
	import flash.display.Sprite;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Pixel;
	import org.openscales.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.proj4as.ProjProjection;

	[SWF(width='1200',height='700')]
	public class OpenscalesApplication extends Sprite {
		protected var _map:Map;

		public function OpenscalesApplication() {
			Trace.useFireBugConsole = true;
			_map=new Map();
			_map.size=new Size(1200, 700);

			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			//mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projection);		
			_map.addLayer(mapnik);

			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			cycle.proxy = "http://openscales.org/proxy.php?url=";
			_map.addLayer(cycle); 
			
			
			var regions:WFS = new WFS("IGN - Geopla (Region)", "http://openscales.org/geoserver/wfs","pg:ign_geopla_region");
			regions.projection = new ProjProjection("EPSG:2154");
			regions.style = Style.getDefaultSurfaceStyle();
			
			_map.addLayer(regions);

			// Add Controls to map
			_map.addControl(new MousePosition());
			_map.addControl(new LayerManager());
			_map.addControl(new PanZoomBar());
			

			var selectHandler: SelectFeaturesHandler = new SelectFeaturesHandler();
			selectHandler.enableClickSelection = false;
			selectHandler.enableBoxSelection = false;
			selectHandler.enableOverSelection = true;
			selectHandler.active = true;
			
			_map.addHandler(selectHandler);
			_map.addHandler(new WheelHandler());
			_map.addHandler(new DragHandler());

			// Set the map center
			_map.center=new Location(538850.47459,5740916.1243,mapnik.projection);
			_map.zoom=5;
						
			this.addChild(_map);
			var overview:OverviewMap = new OverviewMap(new Pixel(100,100));
			overview.size = new Size(250,200);
			overview.map = _map;
			var cycle2:CycleMap=new CycleMap("Cycle2");
			cycle2.proxy = "http://openscales.org/proxy.php?url=";
			overview.baselayer = cycle2;
			addChild(overview);
		}
	}
}
