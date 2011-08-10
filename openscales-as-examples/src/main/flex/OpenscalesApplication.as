package {
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.control.ScaleLine;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.KML;
	import org.openscales.core.layer.ogc.GML;
	import org.openscales.core.layer.ogc.GPX;
	import org.openscales.core.layer.ogc.WFS;
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
		
		[Embed(source="/assets/GML32Sample1.xml",mimeType="application/octet-stream")]
		private const XMLCONTENT:Class;
		
		[Embed(source="/assets/GML32Sample2.xml",mimeType="application/octet-stream")]
		private const XMLCONTENTLINES:Class;
		
		[Embed(source="/assets/GML32Sample3.xml",mimeType="application/octet-stream")]
		private const XMLCONTENTPOINTS:Class;
		
		[Embed(source="/assets/gpx11Sample.xml",mimeType="application/octet-stream")]
		private const GPXFILE:Class;

		public function OpenscalesApplication() {
			_map=new Map();
			_map.size=new Size(1000, 700);

			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			_map.addLayer(mapnik);
			
			// GML 3.2.1 layer; fetch data from url (polygons World Borders)
			var xml:XML = new XML(new XMLCONTENT());
			var style:Style = Style.getDefaultSurfaceStyle();
			var GMLlayer:GML = new GML("World Borders", "3.2.1","EPSG:4326",style,
			"http://openscales.org/geoserver/topp/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=topp:world_borders&maxFeatures=50&outputFormat=text/xml;%20subtype=gml/3.2",
			xml);
			_map.addLayer(GMLlayer);
			
			// GML 3.2.1 layer; fetch data from url; (points in New York)
			var xml3:XML = new XML(new XMLCONTENTPOINTS());
			var style3:Style = Style.getDefaultPointStyle();
			var GMLlayer3:GML = new GML("New York Points", "3.2.1","EPSG:4326", style3,
			"http://openscales.org/geoserver/tiger/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=tiger:poi&maxFeatures=50&outputFormat=text/xml;%20subtype=gml/3.2",
			xml3);
			_map.addLayer(GMLlayer3);
			
			
			//GML 3.2.1 layer; fetch data from url; (lines in Tasmania)
			var xml2:XML = new XML(new XMLCONTENTLINES());
			var style2:Style = Style.getDefaultLineStyle();
			var GMLlayer2:GML = new GML("Tasmania Roads", "3.2.1","EPSG:4326", style2,
			"http://openscales.org/geoserver/topp/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=topp:tasmania_roads&maxFeatures=50&outputFormat=text/xml;%20subtype=gml/3.2",
			xml2);
			_map.addLayer(GMLlayer2);
			
			
			//GPX layer; fetch data from url (draws roads and point in France)
			var gpxData:XML = new XML(new GPXFILE());
			var url:String = "http://openscales.org/assets/simple_dep.gpx";
			var gpxLayer:GPX = new GPX("Australia lines&points","1.0",url,gpxData);
			_map.addLayer(gpxLayer);
			
			/*
			var regions:WFS = new WFS("IGN - Geopla (Region)", "http://openscales.org/geoserver/wfs","pg:ign_geopla_region");
			regions.projSrsCode = "EPSG:2154";
			regions.style = Style.getDefaultSurfaceStyle();
			
			_map.addLayer(regions);
			*/

			// Add Controls to map
			_map.addControl(new MousePosition(new Pixel(200,0)));
			_map.addControl(new LayerManager());
			_map.addControl(new PanZoomBar());
			_map.addControl(new ScaleLine(new Pixel(100, 100)));
			

			var selectHandler: SelectFeaturesHandler = new SelectFeaturesHandler();
			selectHandler.enableClickSelection = false;
			selectHandler.enableBoxSelection = false;
			selectHandler.enableOverSelection = true;
			selectHandler.active = true;
			
			_map.addControl(selectHandler);
			_map.addControl(new WheelHandler());
			_map.addControl(new DragHandler());

			// Set the map center
			_map.zoom=3;
						
			this.addChild(_map);
		}
	}
}
