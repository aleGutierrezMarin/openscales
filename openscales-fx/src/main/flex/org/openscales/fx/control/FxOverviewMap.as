package org.openscales.fx.control
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import org.openscales.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.control.OverviewMap;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	
	public class FxOverviewMap extends Group
	{
		private var overviewmap:OverviewMap;
		public function FxOverviewMap()
		{
			super();
			overviewmap = new OverviewMap();
		}
		
		public function set map(value:Map):void {
			overviewmap.map = value;
			this.draw();
		}
		
		public function set extentColor(value:uint):void {
			overviewmap.extentColor = value;
		}
		
		public function set newExtentColor(value:uint):void {
			overviewmap.newExtentColor = value;
		}
		
		private function draw():void {
			var mapContainer:SpriteVisualElement = new SpriteVisualElement();
			this.addElementAt(mapContainer, 0);
			mapContainer.addChild(this.overviewmap);
			this.overviewmap.size = new Size(this.width,this.height);
		}
	}
}