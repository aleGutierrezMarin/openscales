package
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.OverviewMapRatio;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.security.ign.IGNGeoRMSecurity;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	[SWF(width='1200',height='700')]
	public class OverviewMapRatioExample extends Sprite
	{
		protected var _map:Map;
		
		public function OverviewMapRatioExample()
		{
			
			_map = new Map();
			_map.size=new Size(1200, 700);
			
			// Main map creation
			var IGN:WMSC = new WMSC("OrthoPhoto", "http://wxs.ign.fr/geoportail/wmsc", "ORTHOIMAGERY.ORTHOPHOTOS");
			IGN.projection = "IGNF:GEOPORTALFXX";
			var resoArray:Array = new Array(39135.75,19567.875,9783.9375,4891.96875,2445.984375,2048,1024,512,256,128,64,32,16,8,4,2,1,0.5,0.25,0.125,0.0625);
			IGN.resolutions = resoArray;
			IGN.minZoomLevel = 5;
			IGN.maxZoomLevel = 17;
			IGN.method = "POST";
			IGN.version ="1.1.1";
			
			IGN.maxExtent = new Bounds(-1048576,3670016,2097152,6815744, "IGNF:GEOPORTALFXX");
			var securityIGN:IGNGeoRMSecurity = new IGNGeoRMSecurity(_map, "1905042184761803857", "http://www.openscales.org/proxy.php?url=", "http://jeton-api.ign.fr", "POST");
			IGN.security = securityIGN;
			_map.addLayer(IGN);
			
			
			// Overview map Creation
			var mapnik:Mapnik=new Mapnik("Mapnik");
			mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);
			
			var position:Pixel = new Pixel(100, 100);
			var overview:OverviewMapRatio = new OverviewMapRatio(position, mapnik);
			overview.ratio = 4;
			overview.map = _map;
			overview.size = new Size(200, 200);
			_map.addControl(overview);
			_map.addControl(new MousePosition());
			_map.addControl(new LayerManager());
			_map.addControl(new PanZoomBar());
			
			var selectHandler: SelectFeaturesHandler = new SelectFeaturesHandler();
			selectHandler.enableClickSelection = false;
			selectHandler.enableBoxSelection = false;
			selectHandler.enableOverSelection = true;
			selectHandler.active = true;
			
			_map.addControl(selectHandler);
			_map.addControl(new WheelHandler());
			_map.addControl(new DragHandler());
			
			_map.zoom = 6;
			_map.center = new Location(-0.14908,46.99964, IGN.projSrsCode);
			
			this.addChild(_map);
			
		}
	}
}