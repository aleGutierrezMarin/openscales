package org.openscales.fx.control
{
	import flash.events.Event;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.fx.layer.FxLayer;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	
	/**
	 * <p>OverviewMap Flex wrapper.</p>
	 * <p>To use it, declare a &lt;OverviewMap /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxOverviewMap extends Group
	{
		private var overviewmap:OverviewMap;
		public function FxOverviewMap()
		{
			super();
			overviewmap = new OverviewMap();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
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
		private function onCreationComplete(event:Event):void {
			var i:uint;
			var element:IVisualElement;
			for(i=0; i<this.numElements; i++) {
				element = this.getElementAt(i);
				if (element is FxLayer) {
					this.addFxLayer(element as FxLayer);
				}
			}
		}
		private function addFxLayer(l:FxLayer):void {
			l.configureLayer();
			if(overviewmap.baselayer == null) {
				overviewmap.baselayer = l.layer;
			} else {
			}
		}
	}
}