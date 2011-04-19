package {
	import flash.display.Sprite;
	
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
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	[SWF(width='1200',height='700')]
	public class WMS11xExample extends Sprite {
		protected var _map:Map;
		
		public function WMS11xExample() {
			Trace.useFireBugConsole = true;
			_map=new Map();
			_map.size=new Size(1200, 700);
			
			// Add layers to map
			
			_map.proxy="http://openscales.org/proxy.php?url=";
			var layerWMS111:WMS = new WMS("Germany","http://wms.wheregroup.com/cgi-bin/mapserv?map=/data/umn/germany/germany.map","Germany");
			layerWMS111.maxExtent = new Bounds(5.60075,47.2441,15.425,55.0317,"EPSG:4326");
			layerWMS111.version="1.1.1";
			this._map.addLayer(layerWMS111);
			
			
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
			//_map.center=new Location(538850.47459,5740916.1243,mapnik.projSrsCode);
			//_map.zoom=5;
			
			this.addChild(_map);
		}
	}
}
