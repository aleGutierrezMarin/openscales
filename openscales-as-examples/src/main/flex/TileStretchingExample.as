package {
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.capabilities.WMS110;
	import org.openscales.core.layer.capabilities.WMS111;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WFST;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	[SWF(width='1200',height='700')]
	public class TileStretchingExample extends Sprite {
		protected var _map:Map;
		
		public function TileStretchingExample() {
			_map=new Map();
			_map.size=new Size(1200, 700);
			
			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			//mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			_map.addLayer(mapnik);
			
			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			cycle.proxy = "http://openscales.org/proxy.php?url=";
			//_map.addLayer(cycle); 
			
			
			var regions:WMS = new WMS("IGN - Geopla (Region)", "http://openscales.org/geoserver/pg/wms","pg:ign_geopla_region");
			regions.projSrsCode = "EPSG:2154";
			
			regions.style = Style.getDefaultSurfaceStyle();
			regions.alpha = 0.5;
			_map.addLayer(regions);
			
			var geoServer:WMSC = new WMSC("nasa", "http://openscales.org/geoserver/gwc/service/wms", "bluemarble");
			geoServer.version = "1.1.1";
			geoServer.maxExtent = new Bounds(-180,-90,180,90, geoServer.projSrsCode);
			//_map.addLayer(geoServer);
			mapnik.alpha = 0.5;
			geoServer.alpha = 0.5;
			
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
			_map.center=new Location(538850.47459,5740916.1243,mapnik.projSrsCode);
			_map.zoom=5;
			
			this.addChild(_map);
		}
	}
}