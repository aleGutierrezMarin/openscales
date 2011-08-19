package
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.ogc.GeoRss;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	
	[SWF(width='1200',height='700')]
	public class GeoRssExample extends Sprite
	{
		protected var _map:Map;
		private var url:String;
		
		public function GeoRssExample()
		{
			super();
			this.url = "http://openscales.org:80/geoserver/sf/wms?height=332&bbox=589851.4376666048%2C4914490.882968263%2C608346.4603107043%2C4926501.8980334345&width=512&layers=sf%3Aarchsites&request=GetMap&service=wms&styles=point&srs=EPSG%3A26713&format=application%2Frss+xml&transparent=false&version=1.1.1";
			
			//Trace.useFireBugConsole = true;
			_map=new Map();
			_map.size=new Size(1200, 700);
			_map.projection = "EPSG:4326";
			
			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			_map.addLayer(mapnik);
			
			
			//GeoRss layer; fetch data from url
			var georssLayer:GeoRss = new GeoRss("Archeological Sites", this.url);
			this._map.addLayer(georssLayer);
			
	
			// Add Controls to map
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
			
			//Set map size and zoom level
			_map.resolution= new Resolution(1.40625, "EPSG:4326");
			_map.center = new Location(-103.6,44.5,"WGS84");
			this.addChild(_map);
	
		}
	}
}