package {
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.control.ScaleLine;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;

	[SWF(width='1200',height='700')]
	public class OpenscalesApplication extends Sprite {
		protected var _map:Map;

		public function OpenscalesApplication() {
			_map=new Map();
			//_map.size=new Size(1200, 700);
			_map.projection = "EPSG:4326";
			// Add layers to map
			var wms:WMSC = new WMSC("blueMarble", "http://openscales.org/geoserver/wms","bluemarble");
			wms.maxExtent = new Bounds(-180, -90, 180, 90, "EPSG:4326");
			_map.addLayer(wms);
			//var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			//mapnik.proxy = "http://openscales.org/proxy.php?url=";
			//mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			//_map.addLayer(mapnik);

			
			/*var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			cycle.proxy = "http://openscales.org/proxy.php?url=";
			_map.addLayer(cycle); */
			
			
			/*var regions:WFS = new WFS("IGN - Geopla (Region)", "http://openscales.org/geoserver/wfs","pg:ign_geopla_region");
			regions.projSrsCode = "EPSG:2154";
			regions.style = Style.getDefaultSurfaceStyle();
			
			_map.addLayer(regions);*/

	
			// Add Controls to map
			//_map.addControl(new MousePosition());
			//_map.addControl(new LayerManager());
			//_map.addControl(new PanZoomBar());
			//_map.addControl(new ScaleLine(new Pixel(100, 100)));
			

			//var selectHandler: SelectFeaturesHandler = new SelectFeaturesHandler();
			//selectHandler.enableClickSelection = false;
			//selectHandler.enableBoxSelection = false;
			//selectHandler.enableOverSelection = true;
			//selectHandler.active = true;
			
			//_map.addControl(selectHandler);
			_map.addControl(new WheelHandler());
			_map.addControl(new DragHandler());

			// Set the map center
			_map.center=new Location(0, 42, "EPSG:4326");
			//_map.zoom=13;
						
			this.addChild(_map);
		}
	}
}
