package
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.KML;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;

	
	[SWF(width='1200',height='700')]
	public class KMLFeatureExample extends Sprite
	{
		protected var _map:Map;
		private var url:String;
		
		public function KMLFeatureExample()
		{
			super();
			this.url = "http://code.google.com/intl/fr/apis/kml/documentation/KML_Samples.kml";
			
			//Trace.useFireBugConsole = true;
			_map=new Map();
			_map.size=new Size(1200, 700);
			
			
			// Add a base layer to the map
			var wmsclayer:WMSC = new WMSC("nasa","http://openscales.org/geoserver/ows","bluemarble");
			wmsclayer.projection = "EPSG:4326";
			wmsclayer.format = "image/jpeg";
			wmsclayer.version = "1.1.1";
			this._map.addLayer(wmsclayer);
			
			//add the KML layer; fetch data from url
			var kmlLayer:KML = new KML("KML Features", this.url);
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
			//_map.zoom=7;
			_map.center = new Location(-116.953,37.267,"EPSG:4326");
			this.addChild(_map);
			
		}
	}
}