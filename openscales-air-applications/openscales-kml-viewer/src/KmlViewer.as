package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.KML;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.popup.Anchored;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	
	public class KmlViewer extends Sprite
	{
		protected var _map:Map;
		private var openFile:File = new File()
		private var popup:Anchored;
		
		public function KmlViewer()
		{
			super();
			_map=new Map();
			
			// Add layers to map
			var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
			mapnik.proxy = "http://openscales.org/proxy.php?url=";
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			_map.addLayer(mapnik);
			
			_map.addControl(new DragHandler());
			_map.addControl(new WheelHandler());
			
			// Set the map center
			_map.center=new Location(538850.47459,5740916.1243,mapnik.projSrsCode);
			_map.resolution = new Resolution(mapnik.resolutions[5],mapnik.projSrsCode);
			
			this.addChild(_map);
			
			openFile.addEventListener(Event.SELECT, onOpenFileComplete);
			var kmlFilter:FileFilter = new FileFilter("KML files", "*.kml");

			openFile.browse([kmlFilter]);
			
			
		}
		
		private function onOpenFileComplete(event:Event):void {
			var kml:KML = new KML("kml", event.target.nativePath);
			_map.addLayer(kml);
			this._map.addEventListener(FeatureEvent.FEATURE_CLICK, onFeatureClick);
		}
		
		private function onFeatureClick(event:FeatureEvent):void {
			if(popup) {
				popup.destroy();
			}
			popup = null;
			popup = new Anchored();
			popup.feature = event.feature;
			this._map.addPopup(popup, true);
		}
	}
}