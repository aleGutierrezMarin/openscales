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
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.security.ign.IGNGeoRMSecurity;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.osmf.utils.Version;
	
	[SWF(width='1200',height='700')]
	public class TileStretchingExample extends Sprite {
		protected var _map:Map;
		
		public function TileStretchingExample() {
			_map=new Map();
			_map.size=new Size(1200, 700);
			
			
			// Add layers to map
			//var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			//mapnik.proxy = "http://openscales.org/proxy.php?url=";
			//mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			//_map.addLayer(mapnik);
			
			//var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			//cycle.proxy = "http://openscales.org/proxy.php?url=";
			//_map.addLayer(cycle); 
			
			
			var IGN:WMSC = new WMSC("OrthoPhoto", "http://wxs.ign.fr/geoportail/wmsc", "ORTHOIMAGERY.ORTHOPHOTOS");
			IGN.projSrsCode = "IGNF:GEOPORTALFXX";
			var resoArray:Array = new Array(39135.75,19567.875,9783.9375,4891.96875,2445.984375,2048,1024,512,256,128,64,32,16,8,4,2,1,0.5,0.25,0.125,0.0625);
			IGN.resolutions = resoArray;
			IGN.minZoomLevel = 5;
			IGN.maxZoomLevel = 17;
			IGN.method = "POST";
			IGN.version ="1.1.1";
			
			IGN.maxExtent = new Bounds(-1048576,3670016,2097152,6815744, "IGNF:GEOPORTALFXX");
			var securityIGN:IGNGeoRMSecurity = new IGNGeoRMSecurity(_map, "1905042184761803857", "http://www.openscales.org/proxy.php?url=", "http://jeton-api.ign.fr", "POST");
			IGN.security = securityIGN;
			//IGN.security.initialize();
			_map.addLayer(IGN);
			
			
			//var regions:WMSC = new WMSC("IGN - Geopla (Region)", "http://openscales.org/geoserver/pg/wms","pg:ign_geopla_region");
			var regions:WMS = new WMS("IGN - Geopla (Region)", "http://openscales.org/geoserver/pg/wms","pg:ign_geopla_region");
			regions.projSrsCode = "EPSG:4326";
			regions.version = "1.3.0";
			regions.alpha = 0.5;
			_map.addLayer(regions);
			
			//var layerWMS111:WMS = new WMS("Germany","http://wms.wheregroup.com/cgi-bin/mapserv?map=/data/umn/germany/germany.map","Germany");
			//var layerWMS110:WMSC = new WMSC("topp:states","http://openscales.org/geoserver/wms","topp:states");
			//layerWMS110.projSrsCode = "EPSG:4326";

			//layerWMS110.maxExtent = new Bounds(99226.0,6049647.0,1242375.0,7110524.0,"EPSG:4326");
			//layerWMS110.version="1.3.0";
			//layerWMS110.setTiledToDisplay(true);
			//this._map.addLayer(layerWMS110);
			//layerWMS110.setTransparencyToDisplay(true);
			//layerWMS110.alpha = 0.5;
			
			//var geoServer:WMSC = new WMSC("nasa", "http://openscales.org/geoserver/wms", "topp:states");
			//geoServer.style = "";
			//geoServer.setSLDToDisplay("");
			//geoServer.version = "1.1.0";
			//geoServer.maxExtent = new Bounds(-180,-90,180,90, geoServer.projSrsCode);
			//_map.addLayer(geoServer);
			//mapnik.alpha = 0.5;
			//geoServer.alpha = 0.5;
			
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
			
			_map.zoom = 6;
			_map.center = new Location(-0.14908,46.99964, IGN.projSrsCode);
			
			/*_map.zoom = 6;
			_map.center = new Location(4.833,45.767, regions.projSrsCode);*/
			
			this.addChild(_map);
		}
	}
}