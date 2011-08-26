package
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.ogc.GPX;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	
	[SWF(width='1200',height='700')]
	public class GPXExample extends Sprite
	{
		protected var _map:Map;
		private var url:String;
		
		[Embed(source="/assets/gpx11Sample.xml",mimeType="application/octet-stream")]
		private const GPXFILE:Class;
		
		public function GPXExample()
		{
			super();
			this.url = "http://openscales.org/assets/simple_dep.gpx";
			
			//Trace.useFireBugConsole = true;
			_map=new Map();
			_map.size=new Size(1200, 700);
			
			
			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			_map.addLayer(mapnik);
			
			
			//GPX layer; fetch data from url (draws roads and points in France)
			var gpxData:XML = new XML(new GPXFILE());
			var url:String = "http://openscales.org/assets/simple_dep.gpx";
			var gpxLayer:GPX = new GPX("Départements","1.0",url,gpxData);
			_map.addLayer(gpxLayer);
			
			
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
			
			//Set map center and zoom level
			_map.zoom=6;
			_map.center = new Location(2.4,46.9,"EPSG:4326");
			this.addChild(_map);
			
		}
	}
}