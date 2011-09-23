package
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.KML;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	[SWF(width='1200',height='700')]
	public class KMLExample extends Sprite
	{
		protected var _map:Map;
		private var url:String;
		private var url2:String;
		
		public function KMLExample()
		{
			super();
			this.url = "http://www.parisavelo.net/velib.kml";
			
			//Trace.useFireBugConsole = true;
			_map=new Map();
			_map.size=new Size(1200, 700);
			
			// Add a base layer to the map	
			var wmsLayer:WMS = new WMS("Scan","http://pp-gpp3-wxs-ign-fr.aw.atosorigin.com/cleok/rok4");
			wmsLayer.version = "1.3.0";
			wmsLayer.layers = "SCANDEP_PNG_IGNF_LAMB93";
			wmsLayer.projection = "EPSG:4326";
			this._map.addLayer(wmsLayer);
			
				
			//add the KML layer; fetch data from url
			var kmlLayer:KML = new KML("Stations Vélib Paris", this.url);
			this._map.addLayer(kmlLayer);
			Trace.debug("kmlLayer projection :"+kmlLayer.projSrsCode);
			
			
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
			_map.resolution = new Resolution(0.00034332275390625,"EPSG:4326");
			_map.center = new Location(2.418611,48.842222,"EPSG:4326");
			this.addChild(_map);
			
		}
	}
}