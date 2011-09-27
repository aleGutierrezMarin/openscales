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
	import org.openscales.core.layer.ogc.GML;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	[SWF(width='1200',height='700')]
	public class GML321Example extends Sprite
	{
		protected var _map:Map;
		
		[Embed(source="/assets/GML32Sample1.xml",mimeType="application/octet-stream")]
		private const XMLCONTENT:Class;
		
		[Embed(source="/assets/GML32Sample3.xml",mimeType="application/octet-stream")]
		private const XMLCONTENTPOINTS:Class;
		
		[Embed(source="/assets/GML32Sample2.xml",mimeType="application/octet-stream")]
		private const XMLCONTENTLINES:Class;
		
		public function GML321Example()
		{
			super();
			
			//Trace.useFireBugConsole = true;
			_map=new Map();
			_map.size=new Size(1200, 700);
			_map.projection = "EPSG:4326";
			
			// Add a base layer to the map  
			var wmsLayer:WMS = new WMS("Scan","http://pp-gpp3-wxs-ign-fr.aw.atosorigin.com/cleok/rok4");
			wmsLayer.version = "1.3.0";
			wmsLayer.layers = "SCANDEP_PNG_IGNF_LAMB93";
			wmsLayer.projection = "EPSG:4326";
			this._map.addLayer(wmsLayer);
			
			// GML 3.2.1 layer; fetch data from url (polygons World Borders)
			//if data is fetched from file (xml), change the projection to 2154
			var xml:XML = new XML(new XMLCONTENT());
			var style:Style = Style.getDefaultSurfaceStyle();
			var GMLlayer:GML = new GML("World Borders", "3.2.1","EPSG:4326",
				"http://openscales.org/geoserver/topp/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=topp:world_borders&maxFeatures=50&outputFormat=text/xml;%20subtype=gml/3.2",
				xml,null);
			_map.addLayer(GMLlayer);
			
			// GML 3.2.1 layer; fetch data from url or file; (points in New York)
			var xml3:XML = new XML(new XMLCONTENTPOINTS());
			var style3:Style = Style.getDefaultPointStyle();
			var GMLlayer3:GML = new GML("New York Points", "3.2.1","EPSG:4326"
				/*"http://openscales.org/geoserver/tiger/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=tiger:poi&maxFeatures=50&outputFormat=text/xml;%20subtype=gml/3.2"*/,
				null,xml3,null);
			_map.addLayer(GMLlayer3);
			
			
			//GML 3.2.1 layer; fetch data from url or file; (lines in Tasmania)
			var xml2:XML = new XML(new XMLCONTENTLINES());
			var style2:Style = Style.getDefaultLineStyle();
			var GMLlayer2:GML = new GML("Tasmania Roads", "3.2.1","EPSG:4326",null,
				/*"http://openscales.org/geoserver/topp/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=topp:tasmania_roads&maxFeatures=50&outputFormat=text/xml;%20subtype=gml/3.2",*/
				xml2,null);
			_map.addLayer(GMLlayer2);
			
			
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
			_map.resolution = new Resolution(1.40625, "EPSG:4326");
			_map.center = new Location(-34.6,17.2, "EPSG:4326");
			this.addChild(_map);
			
		}
	}
}